; $ID: plot_trend_xy2_4.ncl V01 03/05/2015 17:58 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_xy2_4 PLOTS THE TREND LINES OF MY TOEFL SCORE .
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks          (graphic) : WORK STATION                             [---]
;  (2 ) nscore       (integer) : TOTAL # OF TOEFL SCORES                  [---]
;  (3 ) section      (string)  : SECTION NAME                             [---]
;  (4 ) stotal       (string)  : TOTAL NAME                               [---]
;  (5 ) data1        (float)   : EVERY SECTION SCORE                      [---]
;  (6 ) data2        (float)   : TOTAL SCORE                              [---]
;  (7 ) plot         (graphic) : PLOT                                     [---]
;  (8 ) plot1        (graphic) : PLOT                                     [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/05/2015)
;******************************************************************************

undef("plot_trend_xy2_4")
procedure plot_trend_xy2_4 \
         (wks           :graphic,                         \ ; INPUT
          nscore        :integer, section       :string,  \ ; INPUT
          statol        :string,                          \ ; INPUT
          data1         :float,   data2         :float,   \ ; INPUT
          plot          :graphic)                           ; OUTPUT

begin

   ndim           = dimsizes(data1)
   nndim          = dimsizes(ndim)
   if (nndim .eq. 1) then
      ncase       = 1
   else
      ncase       = ndim(0)
   end if
   x              = ispan(1,nscore,1)
   xvalue         = x
   xtick          = (/"2009", "Oct2014", "Nov2014", " "/)

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                        = True
   res@vpWidthF               = 0.8
   res@vpHeightF              = 0.55
   res@vpXF                   = 0.15
   res@vpYF                   = 0.85
   res@gsnMaximize            = True
   res@gsnDraw                = False
   res@gsnFrame               = False

;  SET X AXIS LABELS
   res@tmXBMode                = "Explicit"
   res@tmXBValues              = xvalue
   res@tmXBLabels              = xtick
   res@tmXBMajorLengthF        = 0.01
   res@tmXBMinorLengthF        = 0.005
   res@tmXBMajorOutwardLengthF = 0.0
   res@tmXTMajorLengthF        = 0.01
   res@tmXTMajorOutwardLengthF = 0.0

   resr                        = True
   resr                        = res
   resl                        = True
   resl                        = res
;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   dashpatternsl                = (/0, 0, 0, 0/)
   markersl                     = (/6, 7, 8, 13/)
   linecolorsl                  = (/"blue", "red", "pink", "green"/)
   resl@xyMarkLineMode          = "MarkLines"
   resl@xyMarkers               = markersl
   resl@xyMarkerColors          = linecolorsl
   resl@xyMarkerThicknessF      = 2.5
   resl@xyMarkerSizeF           = 0.01
   resl@xyDashPatterns          = dashpatternsl
   resl@xyLineColors            = linecolorsl
   resl@xyLineThicknessF        = 4.0
   resl@tmYLMajorLengthF       = 0.01
   resl@tmYLMinorLengthF       = 0.005
   resl@tmYLMajorOutwardLengthF= 0.0
   resl@tmYLMinorOutwardLengthF= 0.0
   dashpatternsr               = (/2/)
   markersr                    = (/4/)
   linecolorsr                 = (/"black"/)
   resr@xyMarkLineMode          = "MarkLines"
   resr@xyMarkers               = markersr
   resr@xyMarkerColors          = linecolorsr
   resr@xyMarkerThicknessF      = 2.5
   resr@xyMarkerSizeF           = 0.01
   resr@xyDashPatterns          = dashpatternsr
   resr@xyLineColors            = linecolorsr
   resr@xyLineThicknessF        = 8.0
   resr@tmYRMajorLengthF       = 0.01
   resr@tmYRMinorLengthF       = 0.005
   resr@tmYRMajorOutwardLengthF= 0.0
   resr@tmYRMinorOutwardLengthF= 0.0

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.15
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resl@pmLegendOrthogonalPosF = -0.50
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.17
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = section
;  SET LEGEND
   resr@pmLegendDisplayMode    = "Always"
   resr@pmLegendSide           = "Top"
   resr@pmLegendParallelPosF   = 0.125
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resr@pmLegendOrthogonalPosF = -0.43
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.17
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = statol
;  X Y RANGE
   resl@trXMaxF                = nscore
   resl@trXMinF                = 0
   resl@trYMaxF                = 30.0
   resl@trYMinF                = 12.0
   resr@trYMaxF                = 90.0
   resr@trYMinF                = 72.0
   resl@tmYRMaxTicks           = 5
   resl@tiXAxisString          = "TOEFL Date"
   resl@tiYAxisString          = "Section Score"
   resr@tiYAxisString          = "Total Score"
   resl@tiMainString           = "Bruce's TOEFL Scores"

   plot   = gsn_csm_xy2(wks, x, data1, data2, resl, resr)

draw(plot)
return
end
