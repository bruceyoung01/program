; $ID: wrf_contour_sites.ncl V01 02/21/2012 15:52 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_sites PLOT SITES OBSERVATION ONTO THE WRFCHEM 
;  SIMULATION MAP PLOT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/21/2012)
;******************************************************************************

; LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_sites_2008_0201_0229_v01_fb_ndust")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_800_fb_ndust/"
   sfile      = "wrfout_d01_2008-02*"


end

