;  $ID: scatter_viirs_epa.ncl V01 02/27/2013 09:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter_viirs_epa READS THE OUTPUT OF SELECTED VIIRS DATA AND EPA
;  PBSERVED PM, AND PLOT THE SCATTER PLOT.
;
;  SUBROUTINES:
;  ============================================================================
;  (1 ) correlation.ncl : 
;       CALCULATES PEARSON PRODUCT-MOMENT CORRELATION COEFFICIENT, WHICH 
;       MEASURES THE STRENGTH OF THE LINEAR ASSOCIATION BETWEEN VARIABLES.
;  (2 ) read_selected_viirs_epa_cloudmask.ncl :
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
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_selected_viirs_epa_cloudmask.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/calculate_average_viirs_epa_cloud.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_scatter_viirs_epa_selected.ncl"

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

;  SET UP SELECTED DATABASE INFO
   dir        = "/work/jwang7/bruceyoung01/model/ncl/atlanta/viirs_contour_pixel_dnb_epa/results/data_w_background/"
   filelist1  = "1.txt"
   filelist2  = "2.txt"
   filelist3  = "3.txt"
   fnamec     = "visualized_couldmask.txt"
   fname1     = asciiread(dir + filelist1, -1, "string")
   fname2     = asciiread(dir + filelist2, -1, "string")
   fname3     = asciiread(dir + filelist3, -1, "string")
   nsite      = dimsizes(fname1)
   site_id    = (/"130770002", "130890002", "131210055", "131350002", \
                  "131510002"/)

;  DECLARE ARRARY FOR SUBROUTINE read_selected_viirs_epa_cloudmask.ncl
   nrow       = 182
   date       = new((/nsite, nrow, 4/),  integer, bv1)
   info_data  = new((/nsite, nrow, 7/),  float,   bv2)
   pm_data    = new((/nsite, nrow, 2/),  float,   bv2)
   rad_data   = new((/nsite, nrow, 25/), float,   bv2)
   c_data     = new((/nsite, nrow, 1/),  integer, bv1)

;  DECLARE ARRARY FOR SUBROUTINE calculate_viirs_epa_cloud.ncl
   pm_avg     = new((/nsite, nrow/), float, bv2)
   rad_avg    = new((/nsite, nrow/), float, bv2)
;  DO SITE LOOP
   do isite = 0, nsite-1

;  CALL SUBROUTINE read_selected_viirs_epa_cloudmask.ncl TO READ SELECTED VIIRS AND EPA DATA
    read_selected_viirs_epa_cloudmask \
    (dir, fname1(isite), fname2(isite), fname3(isite), fnamec, \
     date(isite, :, :), info_data(isite, :, :), pm_data(isite, :, :), \
     rad_data(isite, :, :), c_data(isite, :, :))

;  CALL SUBROUTINE calculate_average_viirs_epa_cloud.ncl TO CALCULATE AVERAGE OF VIIRS DATA 
;  AND EPA DATA, AND SELECTS THE CLEAR SKY DATA
    calculate_average_viirs_epa_cloud \
    (bv2, pm_data(isite, :, :), rad_data(isite, :, :), c_data(isite, :, :), \
     pm_avg(isite, :), rad_avg(isite, :))

;  CALL SUBROUTINE plot_scatter_viirs_epa_selected.ncl TO PLOT FOR EACH SITE
    plot_scatter_viirs_epa_selected \
    (wks, site_id(isite), bv2, pm_avg(isite, :)/cos((info_data(isite, :, 2)/degree)*pi), log(rad_avg(isite, :)), \
     info_data(isite, :, 4), info_data(isite, :, 5))
   end do

end
