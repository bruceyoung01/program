; $ID: plot_wrf_profile_pm25_bar.ncl V01 10/17/2012 23:24 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_wrf_profile_pm25_bar PLOTS DATA VERTICAL PROFILE WITH 
;  ERROR BAR.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (10/17/2012)
;******************************************************************************

procedure plot_wrf_profile_pm25_bar \
          (wks       : graphic, time   :character,\ ; INPUT
           layer     : integer,                   \ ; INPUT
           height    : float,   data   :float,    \ ; INPUT
           error     : float)

begin

; SET UP RESOURCES ERROR BAR PLOT
   vres                  = True
   vres@xyLineColor      = "blue"
   vres@xyLineThicknessF = 2.0
   vres@trYMinF          = 0.0
   vres@trYMaxF          = 10.0
   vres@tiYAxisString    = "Z AGL (km)"
   vres@trXMinF          = 0.0
   vres@trXMaxF          = 50.0
   vres@tiXAxisString    = "PM~B~2.5~N~ Mass Concentration (~F33~m~F0~g/m~S~3~N~)"
   vres@tiMainString     = "WRFCHEM " + time
   vres@gsnDraw          = False
   vres@gsnFrame         = False

;----------------------------------------------------------------------
; SET UP RESOURCES OF ERROR BAR
   pvres                 = True
   pvres@gsLineColor     = "blue"
   pvres@gsLineThicknessF= 2.0

   plot     = gsn_csm_xy(wks, data, height, vres)
; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
   do j = 0, layer-1
    if(.not.ismissing(data(j)) .and. .not.ismissing(error(j)))then
    gsn_polyline(wks, plot, (/data(j), data(j)+error(j)/), (/height(j), height(j)/), pvres)
    gsn_polyline(wks, plot, (/data(j)+error(j), data(j)+error(j)/), (/height(j)-0.1, height(j)+0.1/), pvres)
    end if
   end do
   draw(plot)
   frame(wks)


end
