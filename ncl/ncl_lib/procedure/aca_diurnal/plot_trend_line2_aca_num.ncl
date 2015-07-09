;  $ID: plot_trend_line2_aca_num.ncl V01 06/23/2015 16:50 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_trend_line2_aca_num.ncl PLOTS THE TIME TREND LINE OF FOUR 
;  VARIABLES USING THE SAME LEFT Y EXIS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/23/2015)
;******************************************************************************
undef("plot_trend_line2_aca_num")
procedure plot_trend_line2_aca_num \
          (wks         :graphic, stime      :string,  \;INPUT
           start_year  :integer, end_year   :integer, \;INPUT
           start_month :integer, end_month  :integer, \;INPUT
           data1       :numeric, data2      :numeric)  ;INPUT

begin

   ndim   = dimsizes(data1)
   nday   = ndim(0)

;  CONVERT INTEGER TO STRING
   sstart_year = sprinti("%4.4i",  start_year)
   send_year   = sprinti("%4.4i",    end_year)
   sstart_month= sprinti("%2.2i", start_month)
   send_month  = sprinti("%2.2i",   end_month)
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
   x                           = ispan(1, nday, 1)
   xtick                       = (/sstart_year + "June", "July", "August"/)
   resr@tmXBMode               = "Explicit"
   resr@tmXBValues             = (/1, 31, 62/)
   resr@tmXBLabels             = xtick
   resr@trXMaxF                = x(nday-2)
   resr@tmXBMajorLengthF       = 0.01
   resr@tmXBMinorLengthF       = 0.005
;  resr@tmXBMajorOutwardLengthF= 0.0
;  resr@tmXBMinorOutwardLengthF= 0.0
   resr@tmXBMinorValues        = ispan(2, nday, 1)
   resr@tmXTMajorLengthF       = 0.01
   resr@tmXTMinorLengthF       = 0.005
   resr@tmXTMajorOutwardLengthF= 0.0
   resr@tmXTMinorOutwardLengthF= 0.0
   resr@tmXTMinorValues        = ispan(2, nday, 1)
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
   resr@xyExplicitLegendLabels = (/"# of Cloud Grids"/)
   resr@trYMaxF                = 100
   resr@trYMinF                = 0
   resr@tiXAxisString          = "Date"
   resr@tiYAxisString          = "Number of Grids"
   resr@tiMainString           = stime

;  SET RIGHT Y AXIS LABEL
   resl                        = True
   resl                        = res
   resl@xyMarkLineMode         = "MarkLines"
   resl@xyMarkers              = 7
   resl@xyMarkerSizes          = 5
   resl@xyMarkerThicknessF     = 2.0
   resl@xyMarkerColors         = "Red"
   resl@xyLineColor            = "Red"

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
   resl@tmXBValues             = resr@tmXBValues
   resl@tmXBLabels             = resr@tmXBLabels
   resl@trXMaxF                = resr@trXMaxF
   resl@tmXBMajorLengthF       = 0.01
   resl@tmXBMinorLengthF       = 0.005
;  resl@tmXBMajorOutwardLengthF= 0.0
;  resl@tmXBMinorOutwardLengthF= 0.0
   resl@tmXBMinorValues        = resr@tmXBMinorValues
   resl@tmXTMajorLengthF       = 0.01
   resl@tmXTMinorLengthF       = 0.005
   resl@tmXTMajorOutwardLengthF= 0.0
   resl@tmXTMinorOutwardLengthF= 0.0
   resl@tmXTMinorValues        = resr@tmXTMinorValues
   resl@tmYLMajorLengthF       = 0.01
   resl@tmYLMinorLengthF       = 0.005
   resl@tmYLMajorOutwardLengthF= 0.0
   resl@tmYLMinorOutwardLengthF= 0.0
   resl@tmYRMajorLengthF       = 0.01
   resl@tmYRMinorLengthF       = 0.005
   resl@tmYRMajorOutwardLengthF= 0.0
   resl@tmYRMinorOutwardLengthF= 0.0

;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/"# of Aerosol Grids"/)
   resl@trYMaxF                = 100
   resl@trYMinF                = 0
   resl@tiXAxisString          = "Date"
   resl@tiYAxisString          = "Number of Grids"

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.25
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.38 TO -0.35)
   resl@pmLegendOrthogonalPosF =-0.38
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False

   tawplot   = gsn_csm_xy2(wks, x, data1, data2, resl, resr)

   nrl = resl@trYMaxF/resr@trYMaxF
;  OVER PLOT MONTHLY AVERAGE
   eres1                   = True
   eres1@gsLineDashPattern = 2
   eres1@gsLineThicknessF  = 5.0
   eres1@gsLineColor       = "Red"
   eres2                   = True
   eres2@gsLineDashPattern = 2
   eres2@gsLineThicknessF  = 5.0
   eres2@gsLineColor       = "blue"
   if (.not.all(ismissing(data1))) then
    data5 = avg(data1)
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data5, data5/), eres1)
   end if
   if (.not.all(ismissing(data2))) then
    data6 = avg(data2)
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data6, data6/)*nrl, eres2)
   end if

   draw(tawplot)
   frame(wks)
return
end
