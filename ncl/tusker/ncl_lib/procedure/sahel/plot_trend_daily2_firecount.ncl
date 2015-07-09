; $ID: plot_trend_daily2_firecount.ncl V01 01/13/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_daily2_firecount IS USED TO PLOT THE SIMILAR TREND 
;  LINE BETWEEN TWO ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK 
;  MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                              [---]
;  (2 ) data1      (float)   : MODIS FIRE COUNT DAYTIME                  [---]
;  (3 ) data2      (float)   : MODIS FIRE COUNT NIGHTTIME                [---]
;  (4 ) data3      (float)   : MODIS FIRE COUNT DAYTIME MONTHLY AVERAGE  [---]
;  (5 ) data4      (float)   : MODIS FIRE COUNT NIGHTTIME MONTHLY AVERAGE[---]
;  (6 ) nday       (integer) : TOTAL # OF MODIS OBSERVATION DAYS         [---]
;  (7 ) tawplot    (graphic) : TREND LINE PLOT                           [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (06/09/2012)
;******************************************************************************

undef("plot_trend_daily2_firecount")
procedure plot_trend_daily2_firecount \
         (wks    :graphic,                   \ ; INPUT
          data1  :integer, data2   :integer, \ ; INPUT
          data3  :float,   data4   :float,   \ ; INPUT
          nday   :integer,                   \ ; INPUT
          tawplot:graphic)                     ; OUTPUT

begin

;  MATCH DATA1 AND DATA2
   index1 = ind(ismissing(data1))
   if(.not.all(ismissing(index1)))then
    data2(index1) = bv2
   end if
   index2 = ind(ismissing(data2))
   if(.not.all(ismissing(index2)))then
    data1(index2) = bv2
   end if
   delete([/index1, index2/])

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.7
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   resr                        = True
   resr                        = res
   resr@xyMarkLineMode         = "MarkLines"
   resr@xyMarkers              = 16
   resr@xyMarkerSizes          = 5
   resr@xyMarkerThicknessF     = 2.0
   resr@xyMarkerColors         = "Blue"
   resr@xyLineColor            = "Blue"
;  SET X AXIS LABELS
   x                           = ispan(1,nday,1)
   xtick                       = (/"01", "03", "05", "07", "09", \
                                   "11", "13", "15", "17", "19", \
                                   "21", "23", "25", "27", "29"/)
   resr@tmXBMode               = "Explicit"
   resr@tmXBValues             = x(0:nday-1:2)
   resr@tmXBLabels             = xtick
   resr@tmXBMajorLengthF       = 0.01
   resr@tmXBMinorLengthF       = 0.005
   resr@tmXBMajorOutwardLengthF= 0.0
   resr@tmXBMinorOutwardLengthF= 0.0
   resr@tmXBMinorValues        = ispan(2,nday,2)
   resr@tmXTMajorLengthF       = 0.01
   resr@tmXTMinorLengthF       = 0.005
   resr@tmXTMajorOutwardLengthF= 0.0
   resr@tmXTMinorOutwardLengthF= 0.0
   resr@tmXTMinorValues        = ispan(2,  nday,2)
   resr@tmYLMajorLengthF       = 0.01
   resr@tmYLMinorLengthF       = 0.005
   resr@tmYLMajorOutwardLengthF= 0.0
   resr@tmYLMinorOutwardLengthF= 0.0
   resr@tmYRMajorLengthF       = 0.01
   resr@tmYRMinorLengthF       = 0.005
   resr@tmYRMajorOutwardLengthF= 0.0
   resr@tmYRMinorOutwardLengthF= 0.0

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
   resr@xyExplicitLegendLabels = (/" Nighttime "/)
   resr@trYMaxF                = 400.0
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Date in February 2008"
   resr@tiYAxisString          = "Nighttime Fire Count"
   resr@tiMainString           = "MODIS Fire Count Daytime/Nighttime (Feb 2008)"

;  SET RIGHT Y AXIS LABEL
   resl                        = True
   resl                        = res
   resl@xyMarkLineMode         = "MarkLines"
   resl@xyMarkers              = 7
   resl@xyMarkerSizes          = 5
   resl@xyMarkerThicknessF     = 2.0
   resl@xyMarkerColors         = "Red"
   resl@xyLineColor            = "Red"
;  SET X AXIS LABELS
   resl@tmXBMode               = "Explicit"
   resl@tmXBValues             = x(0:nday-1:2)
   resl@tmXBLabels             = xtick
   resl@tmXBMajorLengthF       = 0.01
   resl@tmXBMinorLengthF       = 0.005
   resl@tmXBMajorOutwardLengthF= 0.0
   resl@tmXBMinorOutwardLengthF= 0.0
   resl@tmXBMinorValues        = ispan(2,nday,2)
   resl@tmXTMajorLengthF       = 0.01
   resl@tmXTMinorLengthF       = 0.005
   resl@tmXTMajorOutwardLengthF= 0.0
   resl@tmXTMinorOutwardLengthF= 0.0
   resl@tmXTMinorValues        = ispan(2,nday,2)
   resl@tmYLMajorLengthF       = 0.01
   resl@tmYLMinorLengthF       = 0.005
   resl@tmYLMajorOutwardLengthF= 0.0
   resl@tmYLMinorOutwardLengthF= 0.0
   resl@tmYRMajorLengthF       = 0.01
   resl@tmYRMinorLengthF       = 0.005
   resl@tmYRMajorOutwardLengthF= 0.0
   resl@tmYRMinorOutwardLengthF= 0.0

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.23
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.38 TO -0.35)
   resl@pmLegendOrthogonalPosF =-0.38
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/"Daytime"/)
   resl@trYMaxF                = 9000.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Date in February 2008"
   resl@tiYAxisString          = "Daytime Fire Count"

   tawplot   = gsn_csm_xy2(wks, x, data1, data2, resl, resr)

   nrl = resl@trYMaxF/resr@trYMaxF
;  OVER PLOT MONTHLY AVERAGE
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres1                       = True
   eres1@gsLineColor           = "Red"
   eres1@gsLineThicknessF      = 2.0
   eres1@gsLineDashPattern     = 2
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres2                       = True
   eres2@gsLineColor           = "blue"
   eres2@gsLineThicknessF      = 2.0
   eres2@gsLineDashPattern     = 2
   if (.not.all(ismissing(data3))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data3, data3/), eres1)
   end if
   if (.not.all(ismissing(data4))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data4, data4/)*nrl, eres2)
   end if

   draw(tawplot)
   frame(wks)
   delete([/resl, resr, eres1, eres2/])
return
end
