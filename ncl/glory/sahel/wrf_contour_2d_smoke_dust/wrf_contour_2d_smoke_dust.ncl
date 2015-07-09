;  $ID: wrf_contour_2d_smoke_dust.ncl V01 10/30/2012/ 10:47 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_2d_smoke_dust READS WRFCHEM OUTPUT AND PLOTS CONTOUR WITH
;  SMOKE AND DUST FRACTION, AND SMOKE AND DUST TOTAL MASS CONCENTRATION.
;  HERE WE USE THE 2-D COLOR TABLE. THE X-AXIS IS MASS CONCENTRATION, THE 
;  Y-AXIS IS SMOKE AND DUST FRACTION.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (10/30/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;  SET UP THE PLOT PLATFORM
   type      = "x11" 
;  type      = "pdf"
;  type      = "ps"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_contour_2d_smoke_dust_v01")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")














end
