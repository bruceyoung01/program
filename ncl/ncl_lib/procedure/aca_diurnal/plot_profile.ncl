; $ID: plot_profile.ncl V01 11/25/2015 10:54 ZHIFENG YANG EXP$
;
;******************************************************************************
;  PROCEDURE plot_profile PLOTS DATA VERTICAL PROFILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic):WORK STATION                                [   ]
;  (2 ) y              (1-D):Y AXIS VALUE                                [   ]
;  (3 ) data           (1-D):DATA TO PLOT AS VERTICAL PROFILE            [   ]
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (11/25/2015)
;******************************************************************************
;
undef("plot_profile")
procedure plot_profile \
          (wks       :graphic,                    \ ;INPUT
           y         :float,    data      :float)   ;INPUT

begin

;  SET UP RESOURCES ERROR BAR PLOT
   res                      = True
   res@xyLineColor          = "blue"
   res@xyLineThicknessF     = 5.0
   res@tmXBMode             = "Manual"
   res@trXMinF              = 0.0
   res@trXMaxF              = 100.0
   res@tmXBTickSpacingF     = 4.0
   res@tmXBLabelFontHeightF = 0.018
   res@tmXBFormat           = "f"
   res@tmXBMinorOn          = True
   res@tmXTMinorOn          = False

   res@trYMinF              = -0.5
   res@trYMaxF              = 10.0

   res@tiXAxisString        = "Number"
   res@tiYAxisString        = "Height (km)"
   res@tiXAxisFontHeightF   = 0.025
   res@tiYAxisFontHeightF   = 0.025
   res@tiMainString         = "CALIPSO Aerosol/Cloud Number"

;  SET UP THE POSITION OF THE MAP             NORMAL ; WIDER
   res@vpWidthF             = 0.80 ; 0.20   ; 0.15
   res@vpHeightF            = 0.70 ; 0.20   ; 0.15
   res@vpXF                 = 0.16 ; 0.57   ; 0.67
   res@vpYF                 = 0.85 ; 0.80   ; 0.85
   res@gsnDraw              = False
   res@gsnFrame             = False

   plot     = gsn_csm_xy(wks, data, y, res)

   draw(plot)
   frame(wks)
end
