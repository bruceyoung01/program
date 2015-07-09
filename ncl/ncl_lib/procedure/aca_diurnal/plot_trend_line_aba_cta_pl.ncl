;  $ID: plot_trend_line_aba_cta_pl.ncl V01 06/23/2015 16:50 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_trend_line_aba_cta_pl.ncl PLOTS THE TIME TREND LINE OF TWO 
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
undef("plot_trend_line_aba_cta_pl")
procedure plot_trend_line_aba_cta_pl \
          (wks         :graphic, stime      :string,  \;INPUT
           start_year  :integer, end_year   :integer, \;INPUT
           start_month :integer, end_month  :integer, \;INPUT
           data1       :numeric, data2      :numeric)  ;INPUT

begin

   ndim = dimsizes(data1)
   nday = ndim(0)
;  if (.not.all(ismissing(data1)) .and. \
;      .not.all(ismissing(data2))) then
      data1_mean = dim_avg_n(data1, 1)
      data2_mean = dim_avg_n(data2, 1)
;  end if

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
   resr@pmLegendParallelPosF   = 0.23
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resr@pmLegendOrthogonalPosF =-0.44
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/"Cloud Top Altitude"/)
   resr@trYMaxF                = 5.0
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Date"
   resr@tiYAxisString          = "Altitude (km)"
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
   resl@xyExplicitLegendLabels = (/"Aerosol Base Altitude"/)
   resl@trYMaxF                = 5.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Date"
   resl@tiYAxisString          = "Altitude (km)"

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

   tawplot   = gsn_csm_xy2(wks, x, data1_mean, data2_mean, resl, resr)
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres1                       = True
   eres1@gsLineColor           = "Red"
   eres1@gsLineThicknessF      = 1.0
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres2                       = True
   eres2@gsLineColor           = "blue"
   eres2@gsLineThicknessF      = 1.0

   nrl = resl@trYMaxF/resr@trYMaxF

;  PLOT ERROR BAR
   if (.not.all(ismissing(data1)) .and. \
       .not.all(ismissing(data2))) then
    do j = 0, nday-1
     k = j + 1
     if(.not.all(ismissing(data1(j, :)))) then
      data1_avg = avg(data1(j, :))
      data3 = stddev(data1(j, :))
      if(.not.ismissing(data3)) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data1_avg-data3,\
                                data1_avg/), eres1)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data1_avg-data3,\
                                data1_avg-data3/), eres1)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data1_avg,   \
                                data1_avg+data3/), eres1)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data1_avg+data3,\
                                data1_avg+data3/), eres1)
     end if
    end if
    if(.not.all(ismissing(data2(j, :)))) then
     data2_avg = avg(data2(j, :))
     data4 = stddev(data2(j, :))
     if(.not.ismissing(data4)) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data2_avg-data4,\
                                data2_avg/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data2_avg-data4,\
                                data2_avg-data4/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data2_avg,   \
                                data2_avg+data4/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data2_avg+data4,\
                                data2_avg+data4/)*nrl, eres2)
     end if
    end if
    end do
;  OVER PLOT MONTHLY AVERAGE
   eres1@gsLineDashPattern = 2
   eres1@gsLineThicknessF  = 5.0
   eres2@gsLineDashPattern = 2
   eres2@gsLineThicknessF  = 5.0
   data5 = avg(data1)
   if (.not.all(ismissing(data5))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data5, data5/), eres1)
   end if
   data6 = avg(data2)
   if (.not.all(ismissing(data6))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data6, data6/)*nrl, eres2)
   end if
   end if
   draw(tawplot)
   frame(wks)
return
end
