; $ID: plot_wrf_profile_pm25.ncl V01 10/17/2012 23:24 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_wrf_profile_pm25_polygon PLOTS DATA VERTICAL PROFILE WITH 
;  ERROR BAR.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (10/17/2012)
;******************************************************************************

undef("plot_wrf_profile_pm25")
procedure plot_wrf_profile_pm25 \
          (wks       : graphic, time   :character,\ ; INPUT
           layer     : integer,                   \ ; INPUT
           height    : float,   data   :float)      ; INPUT

begin

; SET UP RESOURCES ERROR BAR PLOT

   vres                  = True
   vres@xyLineColor      = "red"
   vres@xyLineThicknessF = 3.0
   vres@trYMinF          = 0.0
   vres@trYMaxF          = 10.0
   vres@tiYAxisString    = "Z AGL (km)"
   vres@trXMinF          = 0.0
   vres@trXMaxF          = 6.0
   vres@tiXAxisString    = "PM~B~2.5~N~ Mass Concentration (~F33~m~F0~g/m~S~3~N~)"
   vres@tiMainString     = "WRFCHEM " + time
   vres@gsnDraw          = False
   vres@gsnFrame         = False

   plot     = gsn_csm_xy(wks, data, height, vres)
   draw(plot)
   frame(wks)


end
