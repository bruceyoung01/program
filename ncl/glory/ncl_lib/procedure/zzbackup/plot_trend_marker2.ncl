; $ID: plot_trend_marker2.ncl V01 05/11/2012/ 13:18 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_marker2 PLOTS TREND WITH MARKERS AND REGRESSION LINE
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

undef("plot_trend_marker2")
procedure plot_trend_marker2 \
          (wks       :graphic, sitename    :string,   \ ; INPUT
           x         :integer, data1       :float,    \ ; INPUT
           data2     :float,                          \ ; INPUT
           tawplot   :graphic)                          ; OUTPUT

begin

;  SET UP THE POSITION OF THE SCATTER PLOT
   res                         = True
   res@vpWidthF                = 0.7
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False
   xmax                        = 11
   xmin                        = 0
   res@trXMaxF                 = xmax
   res@trXMinF                 = xmin
   res@tmXBLabelStride         = 1
   res@tmXBMajorLengthF        = 0.01
   res@tmXBMinorLengthF        = 0.005
   res@tmXBMajorOutwardLengthF = 0.0
   res@tmXBMinorOutwardLengthF = 0.0
   res@tmXTMinorPerMajor       = 0
   res@tmXTMajorLengthF        = 0.01
   res@tmXTMinorLengthF        = 0.005
   res@tmXTMajorOutwardLengthF = 0.0
   res@tmXTMinorOutwardLengthF = 0.0
   res@tmYLMajorLengthF        = 0.01
   res@tmYLMinorLengthF        = 0.005
   res@tmYLMajorOutwardLengthF = 0.0
   res@tmYLMinorOutwardLengthF = 0.0
   res@tmYRMajorLengthF        = 0.01
   res@tmYRMinorLengthF        = 0.005
   res@tmYRMajorOutwardLengthF = 0.0
   res@tmYRMinorOutwardLengthF = 0.0

;  SET UP RIGHT Y AXIS RESOURCES
   resr                        = True
   resr                        = res
   resr@xyMarkLineMode         = "Markers"
   resr@xyMarkers              = 16
   resr@xyMarkerSizes          = 10
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
   resr@pmLegendWidthF         = 0.10
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.02
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/"Root Mean Square Error"/)
   resr@trYMaxF                = 0.5
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Averaging Time (Days)"
   resr@tiYAxisString          = "RMSE"
   resr@tiMainString           = "Correlation and RMSE   " + sitename

;  SET UP LEFT Y AXIS RESOURCES
   resl                        = True
   resl                        = res
   resl@xyMarkLineMode         = "Markers"
   resl@xyMarkers              = 6
   resl@xyMarkerSizes          = 10
   resl@xyMarkerThicknessF     = 2.0
   resl@xyMarkerColors         = "Red"
   resl@xyLineColor            = "Red"

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resl@pmLegendOrthogonalPosF =-0.35
   resl@pmLegendWidthF         = 0.10
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.02
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/"Correlation   Coefficient"/)
   resl@trYMaxF                = 1.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Averaging Time (Days)"
   resl@tiYAxisString          = "Correlation Coefficient"
   resl@tiMainString           = "Correlation and RMSE   " + sitename

   tawplot   = gsn_csm_xy2(wks, x, data1, data2, resl, resr)

;  PLOT REGRESSION LINE
   xnew      = (/xmin, xmax/)
   tdata     = new((/2, 2/), float)
   rc1       = regline(x, data1)
   tdata(0,0)= rc1*(xmin-rc1@xave) + rc1@yave
   tdata(0,1)= rc1*(xmax-rc1@xave) + rc1@yave
   rc2       = regline(x, data2)
   tdata(1,0)= rc2*(xmin-rc2@xave) + rc2@yave
   tdata(1,1)= rc2*(xmax-rc2@xave) + rc2@yave

;  SET UP RESOURCES OF LINE PLOT
   lresr                   = True
   lresr                   = res
   lresr@trYMaxF           = 0.5
   lresr@trYMinF           = 0.0
   lresr@xyDashPatterns    = 1
   lresr@xyLineThicknesses = 1.0
   lresr@xyLineColors      = "Blue"
   lresl                   = True
   lresl                   = res
   lresl@trYMaxF           = 1.0
   lresl@trYMinF           = 0.0
   lresl@xyDashPatterns    = 1
   lresl@xyLineThicknesses = 1.0
   lresl@xyLineColors      = "Red"

   lplot = gsn_csm_xy2(wks, xnew, tdata(0, :), tdata(1, :), lresl, lresr)

   draw(tawplot)
   draw(lplot)
   frame(wks)
   delete([/res, resr, resl, lresr, lresl/])
return
end
