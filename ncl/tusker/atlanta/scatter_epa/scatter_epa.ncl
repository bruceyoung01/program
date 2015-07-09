;  $ID: scatter_epa.ncl V01 03/25/2013 16:46 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter_epa READS THE OUTPUT OF SELECTED EPA DATA AND 
;  PLOT THE SCATTER PLOT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/27/2013)
;  (2 ) MODIFIED FROM scatter_viirs_epa.ncl BY BRUCE. (03/25/2013)
;******************************************************************************
;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/correlation.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_selected_viirs_epa.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/calculate_viirs_epa_cloud.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_scatter_epa.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_scatter_epa_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
   
;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   logic_leap = "leap"

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

;  DECLARE ARRARY FOR SUBROUTINE read_selected_viirs_epa.ncl
   nrow       = 182
   date       = new((/nsite, nrow, 4/),  integer, bv1)
   info_data  = new((/nsite, nrow, 7/),  float,   bv2)
   pm_data    = new((/nsite, nrow, 2/),  float,   bv2)
   rad_data   = new((/nsite, nrow, 25/), float,   bv2)
   c_data     = new((/nsite, nrow, 1/),  integer, bv1)

;  DECLARE ARRARY FOR SUBROUTINE calculate_viirs_epa_cloud.ncl
   pm_avg    = new((/nsite, nrow/), float, bv2)
   rad_avg   = new((/nsite, nrow/), float, bv2)
;  DO SITE LOOP
   do isite = 0, nsite-1

;  CALL SUBROUTINE read_selected_viirs_epa.ncl TO READ SELECTED VIIRS AND EPA DATA
    read_selected_viirs_epa \
    (dir, fname1(isite), fname2(isite), fname3(isite), fnamec, \
     date(isite, :, :), info_data(isite, :, :), pm_data(isite, :, :), \
     rad_data(isite, :, :), c_data(isite, :, :))

;  CALL SUBROUTINE calculate_viirs_epa_cloud.ncl TO CALCULATE AVERAGE OF VIIRS DATA 
;  AND EPA DATA, AND SELECTS THE CLEAR SKY DATA
    calculate_viirs_epa_cloud \
    (bv2, pm_data(isite, :, :), rad_data(isite, :, :), c_data(isite, :, :), \
     pm_avg(isite, :), rad_avg(isite, :))

   end do

;  CALL SUBROUTINE plot_scatter_epa.ncl TO PLOT SCATTER PLOT
   plot_scatter_epa \
   (wks, site_id(0), bv2, pm_avg(0, :), pm_avg(4, :))

end
