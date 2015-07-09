; $ID: plot_trend_marker.ncl V01 05/11/2012/ 13:18 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_marker PLOTS TREND WITH MARKERS AND REGRESSION LINE
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic): WORK STATION                                 [---]
;  (2 ) sitename (string) : AERONET SITE NAME                            [---]
;  (3 ) x        (integer): X AXIS                                       [---]
;  (4 ) data1    (float)  : DATA1 TO PLOT TREND MARKER                   [---]
;  (5 ) data2    (float)  : DATA2 TO PLOT TREND MARKER                   [---]
;  (6 ) tawplot  (graphic): TREND MARKER PLOT                            [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/11/2012)
;******************************************************************************

undef("plot_trend_marker")
procedure plot_trend_marker \
          (wks       :graphic, sitename    :string,   \ ; INPUT
           x         :integer, data1       :float,    \ ; INPUT
           data2     :float,                          \ ; INPUT
           tawplot   :graphic)                          ; OUTPUT

begin

;  SET UP THE POSITION OF THE SCATTER PLOT
   vres                        = True
   vres@vpWidthF               = 0.7
   vres@vpHeightF              = 0.35
   vres@vpXF                   = 0.15
   vres@vpYF                   = 0.85
   vres@gsnDraw                = False
   vres@gsnFrame               = False
   xmax                        = 10
   xmin                        = 0
   vres@trXMaxF                = xmax
   vres@trXMinF                = xmin
   vres@tmXBMajorLengthF       = 0.01
   vres@tmXBMinorLengthF       = 0.005
   vres@tmXBMajorOutwardLengthF= 0.0
   vres@tmXBMinorOutwardLengthF= 0.0
   vres@tmXTMajorLengthF       = 0.01
   vres@tmXTMinorLengthF       = 0.005
   vres@tmXTMajorOutwardLengthF= 0.0
   vres@tmXTMinorOutwardLengthF= 0.0
   vres@tmYLMajorLengthF       = 0.01
   vres@tmYLMinorLengthF       = 0.005
   vres@tmYLMajorOutwardLengthF= 0.0
   vres@tmYLMinorOutwardLengthF= 0.0
   vres@tmYRMajorLengthF       = 0.01
   vres@tmYRMinorLengthF       = 0.005
   vres@tmYRMajorOutwardLengthF= 0.0
   vres@tmYRMinorOutwardLengthF= 0.0

;  SET UP RIGHT Y AXIS RESOURCES
   vresr                       = True
   vresr                       = vres
   resr@xyMarkLineMode         = "Markers"
   resr@xyMarkers              = 16
   resr@xyMarkerSizes          = 5
   resr@xyMarkerThicknessF     = 2.0
   resr@xyMarkerColors         = "Blue"
   resr@xyLineColor            = "Blue"

;  SET LEGEND
   resr@pmLegendDisplayMode    = "Always"
   resr@pmLegendSide           = "Top"
   resr@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resr@pmLegendOrthogonalPosF =-0.45
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/"RMSE"/)
   resr@trYMaxF                = 0.5
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Averaging Time (Days)"
   resr@tiYAxisString          = "RMSE"
   resr@tiMainString           = "Correlation and RMSE " + sitename

;  SET UP LEFT Y AXIS RESOURCES
   vresl                       = True
   vresl                       = vres
   resl@xyMarkLineMode         = "Markers"
   resl@xyMarkers              = 6
   resl@xyMarkerSizes          = 5
   resl@xyMarkerThicknessF     = 2.0
   resl@xyMarkerColors         = "Red"
   resl@xyLineColor            = "Red"

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resl@pmLegendOrthogonalPosF =-0.45
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/"Correlation Coefficient"/)
   resl@trYMaxF                = 1.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Averaging Time (Days)"
   resl@tiYAxisString          = "Correlation Coefficient"
   resl@tiMainString           = "Correlation and RMSE " + sitename

   tawplot   = gsn_csm_xy2(wks, x, data1, data2, resl, resr)

   delete([/vres, resr, resl/])
return
end
