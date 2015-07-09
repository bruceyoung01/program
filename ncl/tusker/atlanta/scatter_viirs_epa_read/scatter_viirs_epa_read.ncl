;  $ID: scatter_viirs_epa_read.ncl V01 02/27/2013 09:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter_viirs_epa_read READS THE OUTPUT OF SELECTED VIIRS DATA AND 
;  EPA PBSERVED PM, AND PLOT THE SCATTER PLOT.
;
;  SUBROUTINES:
;  ============================================================================
;  (1 ) correlation.ncl : 
;       CALCULATES PEARSON PRODUCT-MOMENT CORRELATION COEFFICIENT, WHICH 
;       MEASURES THE STRENGTH OF THE LINEAR ASSOCIATION BETWEEN VARIABLES.
;  (2 ) read_selected_viirs_epa.ncl :
;       READS THE PREPAIRED DATABASE, WHICH INCLUDES TIME, EPA SITE INFO 
;       (GEOLOCATION), PM2.5 MASS CONCENTRATION, VIIRS SATELLITE INFO, LUNAR 
;       INFO, AND RADIANCE. IT'S A TEXT FILE.
;  (3 ) calculate_viirs_epa_cloud.ncl :
;       CALCULATES VIIRS AND EPA DATA AVERAGE, AND REMOVE CLOUDY DAYS, WHICH 
;       USES A PREPAIRED CLOUD INFO TEXT FILE BASED ON THE VISUALIZATION OF 
;       DNB RADIANCE BLACK/WHITE IMAGES.
;  (4 ) plot_scatter_viirs_epa_selected.ncl : 
;       PLOTS SCATTER IMAGE BASED ON MATCHED VIIRS RADIANCE AND EPA PM2.5 MASS 
;       CONCENTRATION, WITH ALL THE STATISTICS.
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/27/2013)
;  (2 ) ADD COMMENTS TO READ IT EASIER. (04/05/2013)
;******************************************************************************
;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/correlation.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_visualized_cloudmask_date.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_selected_viirs_epa_4p.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/calculate_average_viirs_epa_cloud.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_select_highlight.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/match_epa_highliht_cloudmask.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_scatter_viirs_epa_selected_highlight.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_scatter_viirs_epa_bk_v07")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
   
;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   logic_leap = "leap"
   pi         = 3.1415926
   degree     = 180.0

;  SET UP VISUALIZED CLOUD MASK FILE INFO
   cdir       = "/lustre/work/jwang7/bruceyoung01/model/ncl/atlanta/scatter_viirs_epa_read/data/"
   cfilename  = "visualized_cloudmask_date.txt"

;  SET UP SELECTED DATABASE INFO
   dir        = "/work/jwang7/bruceyoung01/model/ncl/atlanta/viirs_contour_pixel_dnb_epa/"
   filelist1  = "1.txt"
   filelist2  = "2.txt"
   filelist3  = "3.txt"
   fnamec     = "visualized_couldmask.txt"
   fname1     = asciiread(dir + filelist1, -1, "string")
   fname2     = asciiread(dir + filelist2, -1, "string")
   fname3     = asciiread(dir + filelist3, -1, "string")
;  site_id    = (/"130770002", "130890002", "131210055", "131350002", \
;                 "131510002"/)
   site_id    = (/"131210055"/)
   nsite      = dimsizes(site_id)

;  SET UP SELECTED HIGHLIGHT PIXEL DATA
   pdir       = "./data/"
   pfilename  = "DNBdata_D_order.txt"

;  DECLARE ARRAY FOR SUBROUTINE read_visualized_cloudmask_date TO READ VISUALIZED 
;  CLOUD MASK
   nrowc      = 184
   cdate      = new((/nrowc, 3/), integer, bv1)
   cmask      = new((/nrowc/),    integer, bv1)

;  DECLARE ARRARY FOR SUBROUTINE read_selected_viirs_epa.ncl
   nrow       = 182
   date       = new((/nsite, nrow, 4/),  integer, bv1)
   info_data  = new((/nsite, nrow, 7/),  float,   bv2)
   pm_data    = new((/nsite, nrow, 4/),  float,   bv2)
   rad_data   = new((/nsite, nrow, 25/), float,   bv2)
   c_data     = new((/nsite, nrow, 1/),  integer, bv1)

;  DECLARE ARRARY FOR SUBROUTINE read_viirs_select_highlight.ncl
   nrow2      = 151
   pdate      = new((/nsite, nrow2, 4/), integer, bv1)
   pindex     = new((/nsite, nrow2, 2/), integer, bv1)
   prad       = new((/nsite, nrow2, 5/), float, bv2)

;  DECLARE ARRAY FOR MACHED EPA PM AND VIIRS HIGHLIGHT PIXEL RADIANCE
   pm_data_match = new((/nsite, nrow/), float, bv2)
   prad_match    = new((/nsite, nrow/), float, bv2)

;  CALL SUBROUTINE read_visualized_cloudmask_date.ncl TO READ VISUALIZED CLOUD MASK
   read_visualized_cloudmask_date \
   (cdir, cfilename, cdate, cmask)

;  DO SITE LOOP
   do isite = 0, nsite-1

;  CALL SUBROUTINE read_selected_viirs_epa_4p.ncl TO READ SELECTED VIIRS AND EPA DATA
    read_selected_viirs_epa_4p \
    (dir, fname1(isite), fname2(isite), fname3(isite), fnamec, \
     date(isite, :, :), info_data(isite, :, :), pm_data(isite, :, :), \
     rad_data(isite, :, :), c_data(isite, :, :))

;  CALL SUBROUTINE read_viirs_select_highlight.ncl TO READ SELECTED VIIRS HIGHLIGHT
;  PIXEL DATA
    read_viirs_select_highlight \
    (pdir, pfilename, site_id, pdate(isite, :, :), pindex(isite, :, :), prad(isite, :, :))

;  CALL SUBROUTINE match_epa_highliht_cloudmask.ncl TO MATCH THE EPA AND SELECTED HIGHLIGHT PIXEL
;  WITH CLOUDMASK
    match_epa_highliht_cloudmask \
    (bv2, cdate, cmask, date(isite, :, :), pdate(isite, :, :), pm_data(isite, :, :), prad(isite, :, :), \
     pm_data_match(isite, :), prad_match(isite, :))
;  CALL SUBROUTINE plot_scatter_viirs_epa_selected_highlight.ncl TO PLOT FOR EACH SITE
    plot_scatter_viirs_epa_selected_highlight \
    (wks, site_id(isite), bv2, pm_data_match(isite, :)/cos((info_data(isite, :, 2)/degree)*pi), \
     log(prad_match(isite, :)), info_data(isite, :, 4), info_data(isite, :, 5))
   end do

end
