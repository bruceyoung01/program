;  $ID: trend_line4.ncl V01 03/05/2015 18:08 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line4 READS BRUCE'S TOEFL SCORE AND PLOTS AS TREND LINE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/05/2015)
;******************************************************************************
;
;  LOADING FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/mixed/plot_trend_xy2_4.ncl"


begin

;  ECHO SYSTEM TIME
   tstrt     = systemfunc("date")

;  SET UP THE PLOT PLATFORM
;  type      = "x11"
   type      = "pdf"
;  type      = "png"
   wks        = gsn_open_wks(type,"1plt_trend_line4")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv2    = -999.0

;  ASSIGN TOEFL SCORE TO THE ARRAY
   nscore = 4
   tdate  = (/"Reading", "Listening", "Speaking", "Writing"/)
   statol = (/"Total"/)
   reading   = (/26, 23, 20/)
   listening = (/19, 19, 23/)
   speaking  = (/15, 17, 20/)
   writing   = (/15, 25, 23/)
   total     = new((/nscore/), float, bv2)
   total(0:2)= (/75, 84, 86/)
   total(3)  = bv2
   score  = new((/4, 4/), float, bv2)
   score(:, 0:2)  = (/reading, listening, speaking, writing/)
   score(:, 3) = bv2
   plot   = new(1, graphic)

;  CALL SUBROUTINE plot_trend4.ncl TO PLOT TREND LINE
   plot_trend_xy2_4 \
   (wks, nscore, tdate, statol, score, total, plot)

end
