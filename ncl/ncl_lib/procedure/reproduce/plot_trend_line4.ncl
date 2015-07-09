; $ID: plot_trend_line4.ncl V01 02/16/2015 19:03 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_line4 PLOTS THE SIMILAR TREND LINE 
;  AMONG TWO-DIMENSIONAL ARRAYS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks          (graphic) : WORK STATION                             [---]
;  (2 ) name         (string)  : LEGEND NAME                              [---]
;  (3 ) xdata        (float)   : DATA SERIALS                             [---]
;  (4 ) ydata        (float)   : DATA                                     [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/16/2015)
;******************************************************************************

undef("plot_trend_line4")
procedure plot_trend_line4 \
         (wks    :graphic, name          :string,  \ ; INPUT
          xdata  :float,   ydata         :float)     ; INPUT

begin

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                        = True
   res@vpWidthF               = 0.8
   res@vpHeightF              = 0.6 
   res@vpXF                   = 0.15
   res@vpYF                   = 0.85
   res@gsnDraw                = False
   res@gsnFrame               = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   dashpatterns               = (/0, 1, 2, 3/)
   linecolors                 = (/"Blue", "Black", "Red", "Purple"/)
   res@xyMarkLineMode         = "Lines"
   res@xyDashPatterns         = dashpatterns
   res@xyLineColors           = linecolors
   res@xyLineThicknessF       = 1.5
   res@xyXStyle               = "Log"
   res@xyComputeXMin          = True
;  SET X AXIS LABELS
   res@tmXBMajorLengthF       = 0.01
   res@tmXBMinorLengthF       = 0.005
   res@tmXBMajorOutwardLengthF= 0.0
   res@tmXBMinorOutwardLengthF= 0.0
   res@tmXTMajorLengthF       = 0.01
   res@tmXTMinorLengthF       = 0.005
   res@tmXTMajorOutwardLengthF= 0.0
   res@tmXTMinorOutwardLengthF= 0.0
   res@tmYLMajorLengthF       = 0.01
   res@tmYLMinorLengthF       = 0.005
   res@tmYLMajorOutwardLengthF= 0.0
   res@tmYLMinorOutwardLengthF= 0.0
   res@tmYRMajorLengthF       = 0.01
   res@tmYRMinorLengthF       = 0.005
   res@tmYRMajorOutwardLengthF= 0.0
   res@tmYRMinorOutwardLengthF= 0.0

;  SET LEGEND
   res@pmLegendDisplayMode    = "Always"
   res@pmLegendSide           = "Top"
   res@pmLegendParallelPosF   = (/0.37, 0.23/)
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   res@pmLegendOrthogonalPosF = (/-0.40, 0.48/)
   res@pmLegendWidthF         = 0.12
   res@pmLegendHeightF        = 0.12
   res@lgLabelFontHeightF     = 0.015
   res@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels = name
   res@trYMaxF                = 200.0
   res@trYMinF                = 0.0
   res@tmYLMaxTicks           = 4
   res@tiXAxisString          = "Particle Diameter [~F33~m~F21~m]"
   res@tiYAxisString          = "Threshold Friction Velocity [cm/s]"
   res@tiMainString           = "Figure 3"

   plot   = gsn_csm_xy(wks, xdata, ydata, res)

   draw(plot)
   frame(wks)
return
end
