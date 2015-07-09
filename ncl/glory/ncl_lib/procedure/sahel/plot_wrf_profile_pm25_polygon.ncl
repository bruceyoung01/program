; $ID: plot_wrf_profile_pm25_polygon.ncl V01 10/17/2012 23:24 BRUCE EXP$
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

procedure plot_wrf_profile_pm25_polygon \
          (wks       : graphic, time   :character,\ ; INPUT
           layer     : integer,                   \ ; INPUT
           height    : float,   data   :float,    \ ; INPUT
           error     : float)

begin

; SET UP RESOURCES ERROR BAR PLOT

   vres                  = True
   vres@xyLineColor      = "black"
   vres@xyLineThicknessF = 3.0
   vres@trYMinF          = 0.0
   vres@trYMaxF          = 10.0
   vres@tiYAxisString    = "Z AGL (km)"
   vres@trXMinF          = 0.0
   vres@trXMaxF          = 10.0
   vres@tiXAxisString    = "PM~B~2.5~N~ Mass Concentration (~F33~m~F0~g/m~S~3~N~)"
   vres@tiMainString     = "WRFCHEM " + time
   vres@gsnDraw          = False
   vres@gsnFrame         = False

;----------------------------------------------------------------------
; SET UP RESOURCES OF ERROR BAR
   pvres                 = True
   pvres@tfPolyDrawOrder = "Predraw"
   pvres@gsFillColor     = "skyblue2"

   plot     = gsn_csm_xy(wks, data, height, vres)
; PLOT STANDARD DEVIATION PLOYGON OF DATA
   xp   = new((/2*layer/), float)
   yp   = new((/2*layer/), float)

   do j = 0, layer-1
    xp(j)           = data(j) + error(j)
    yp(j)           = height(j)
    xp(2*layer-1-j) = data(j) - error(j)
    yp(2*layer-1-j) = height(j)
   end do
   dummy = gsn_add_polygon(wks, plot, xp, yp, pvres)   
   draw(plot)
   frame(wks)


end
