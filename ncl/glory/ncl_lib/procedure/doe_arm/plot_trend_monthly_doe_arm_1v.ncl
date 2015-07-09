; $ID: plot_trend_monthly_doe_arm_1v.ncl V01 04/06/2012 16:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_monthly_doe_arm_1v IS USED TO PLOT THE TREND LINE 
;  OF ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) data       (float)   : DOE ARM OBSERVATION DATA                 [---]
;  (3 ) nmonth     (integer) : # OF TOTAL MONTHES IN MULTIYEAR          [---]
;  (4 ) mpplot     (graphic) : MAP WITH MARKERS                         [---]
;  (5 ) tawplot    (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED FROM plot_trend_daily.ncl. (04/06/2012)
;******************************************************************************

undef("plot_trend_monthly_doe_arm_1v")
procedure plot_trend_monthly_doe_arm_1v \ 
                          (wks    :graphic,                   \ ; INPUT
                           data   :float,   nmonth :integer,  \ ; INPUT
                           mpplot :graphic,                   \ ; INPUT
                           tawplot:graphic)                     ; OUTPUT

begin

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.7
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res@xyMarkLineMode         = "MarkLines"
   res@xyMarkers              = 16
   res@xyMarkerSizes          = 5
   res@xyMarkerThicknessF     = 2.0
   res@xyMarkerColors         = "Blue"
   res@xyLineColor            = "Blue"
;  SET X AXIS LABELS
   x                           = ispan(1,nmonth,1)
;  xtick                       = (/"11 01", "02", "03", "04", "05", \
;                                  "06", "07", "08", "09", "10", "11", "12"/)
   xtick                       = (/"93", "95", "97", "99", "01", \
                                   "03", "05", "07", "09", "11"/)
   res@tmXBMode               = "Explicit"
;  FOR PARTICLE CONCENTRATION
;  res@tmXBValues             = x(0:nmonth-1:2)
;  FOR ALL LONG-TERM
   res@tmXBValues             = x(0:nmonth-1:24)
   res@tmXBLabels             = xtick
   res@tmXBMajorLengthF       = 0.01
   res@tmXBMinorLengthF       = 0.005
   res@tmXBMajorOutwardLengthF= 0.0
   res@tmXBMinorOutwardLengthF= 0.0
;  FOR PARTICLE CONCENTRATION
;  res@tmXBMinorValues        = ispan(2,nmonth,1)
;  FOR ALL LONG-TERM
   res@tmXBMinorValues        = ispan(2,nmonth,3)
   res@tmXTMajorLengthF       = 0.01
   res@tmXTMinorLengthF       = 0.005
   res@tmXTMajorOutwardLengthF= 0.0
   res@tmXTMinorOutwardLengthF= 0.0
;  FOR PARTICLE CONCENTRATION
;  res@tmXTMinorValues        = ispan(2,nmonth,1)
;  FOR ALL LONG-TERM
   res@tmXTMinorValues        = ispan(2,nmonth,3)
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
   res@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   res@pmLegendOrthogonalPosF =-0.55
   res@pmLegendWidthF         = 0.12
   res@pmLegendHeightF        = 0.12
   res@lgLabelFontHeightF     = 0.015
   res@lgPerimOn              = False
;  LABELS FOR THE LEGEND
;  DOE ARM AAOD (441 nm)
;  DOE ARM NCCN
;  Particle Concentration
   res@xyExplicitLegendLabels = (/" DOE ARM NCCN"/)
   res@trYMaxF                = 5000
   res@trYMinF                = 0.0
   res@tiXAxisString          = "Year"
;  Aerosol Absorption Optical Depth(441 nm)
;  Number of CCN (m~S~-3~N~)
;  Particle Concentration (m~S~-3~N~)
   res@tiYAxisString          = "Number of CCN (m~S~-3~N~)"
   res@tiMainString           = "DOE ARM NCCN Monthly  SGP (Multiyear)"

   tawplot   = gsn_csm_xy(wks, x, data(2, :), res)

;  SET UP RESOURCES OF ERROR BAR FOR DOE ARM
   eres                       = True
   eres@gsLineColor           = "blue"
   eres@gsLineThicknessF      = 2.0
   do j = 0, nmonth-1
     k = j + 1
     if(.not.ismissing(data(2,j)) .and. \
        .not.ismissing(data(3,j))) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data(2,j)-data(3,j),\
                                data(2,j)/), eres)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data(2,j)-data(3,j),\
                                data(2,j)-data(3,j)/), eres)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data(2,j),   \
                                data(2,j)+data(3,j)/), eres)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data(2,j)+data(3,j),\
                                data(2,j)+data(3,j)/), eres)
     end if

    end do

;  OVER PLOT MULTIYEAR AVERAGE
   eres@gsLineDashPattern = 2
   avgdata                = avg(data(2, :))
   gsn_polyline(wks, tawplot, (/x(0), x(nmonth-1)/), \
                               (/avgdata, avgdata/), eres)
   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/res, eres/])
return
end
