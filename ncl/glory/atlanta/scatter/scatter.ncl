;  $ID: scatter.ncl V01 12/10/2012 11:03 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter.ncl READS DATA, CALCULATES STANDARD DEVIATION, AND PLOTS IT
;  AS SCATTER PLOT WITH TREND LINE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (12/10/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_scatter_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  




end
