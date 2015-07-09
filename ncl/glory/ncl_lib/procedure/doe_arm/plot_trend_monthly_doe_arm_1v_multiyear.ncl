; $ID: plot_trend_monthly_doe_arm_1v_multiyear.ncl V01 04/06/2012 16:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_monthly_doe_arm_1v_multiyear IS USED TO PLOT THE 
;  TREND LINE OF ONE-DIMENSIONAL ARRAY FOR ONE VARIABLE, 
;  ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) data       (float)   : DOE ARM OBSERVATION DATA                 [---]
;  (3 ) ynmonth    (integer) : # OF TOTAL MONTHES IN MULTIYEAR          [---]
;  (4 ) mpplot     (graphic) : MAP WITH MARKERS                         [---]
;  (5 ) tawplot    (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED FROM plot_trend_daily.ncl. (04/06/2012)
;******************************************************************************

undef("plot_trend_monthly_doe_arm_1v_multiyear")
procedure plot_trend_monthly_doe_arm_1v_multiyear \ 
                          (wks    :graphic,                   \ ; INPUT
                           data   :float,  ynmonth :integer,  \ ; INPUT
                           mpplot :graphic,                   \ ; INPUT
                           tawplot:graphic)                     ; OUTPUT

begin

;  SET UP THE POSITION OF THE CONTOUR PLOT
   resl                         = True
   resl@vpWidthF                = 0.7
   resl@vpHeightF               = 0.35
   resl@vpXF                    = 0.15
   resl@vpYF                    = 0.85
   resl@gsnDraw                 = False
   resl@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   resl@xyMarkLineMode         = "MarkLines"
   resl@xyMarkers              = 16
   resl@xyMarkerSizes          = 5
   resl@xyMarkerThicknessF     = 2.0
   resl@xyMarkerColors         = "Blue"
   resl@xyLineColor            = "Blue"
;  SET X AXIS LABELS
   x                           = ispan(1,ynmonth,1)
   xtick                       = (/"JAN", "FEB", "MAR", "APR", "MAY", "JUN", \
                                   "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"/)
   resl@tmXBMode               = "Explicit"
   resl@tmXBValues             = x(0:ynmonth-1:1)
   resl@tmXBLabels             = xtick
   resl@tmXBMajorLengthF       = 0.01
   resl@tmXBMinorLengthF       = 0.005
   resl@tmXBMajorOutwardLengthF= 0.0
   resl@tmXBMinorOutwardLengthF= 0.0
   resl@tmXBMinorValues        = ispan(2,ynmonth,1)
   resl@tmXTMajorLengthF       = 0.01
   resl@tmXTMinorLengthF       = 0.005
   resl@tmXTMajorOutwardLengthF= 0.0
   resl@tmXTMinorOutwardLengthF= 0.0
   resl@tmXTMinorValues        = ispan(2,ynmonth,1)
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
   resl@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resl@pmLegendOrthogonalPosF =-0.55
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
;  DOE ARM AAOD (441 nm)
;  DOE ARM NCCN
;  Particle Concentration
   resl@xyExplicitLegendLabels = (/" DOE ARM NCCN"/)
   resl@trYMaxF                = 5000
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Year"
;  Aerosol Absorption Optical Depth (441 nm)
;  Number of CCN (m~S~-3~N~)
;  Particle Concentration (m~S~-3~N~)
   resl@tiYAxisString          = "Number of CCN (m~S~-3~N~)"
   resl@tiMainString           = "DOE ARM NCCN Monthly  SGP (Multiyear)"

   tawplot   = gsn_csm_xy(wks, x, data(1, :), resl)

;  SET UP RESOURCES OF ERROR BAR FOR DOE ARM
   eres                       = True
   eres@gsLineColor           = "blue"
   eres@gsLineThicknessF      = 2.0
   do j = 0, ynmonth-1
     k = j + 1
     if(.not.ismissing(data(1,j)) .and. \
        .not.ismissing(data(2,j))) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data(1,j)-data(2,j),\
                                data(1,j)/), eres)
      gsn_polyline(wks, tawplot, (/k-0.1, k+0.1/), \
                              (/data(1,j)-data(2,j),\
                                data(1,j)-data(2,j)/), eres)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data(1,j),   \
                                data(1,j)+data(2,j)/), eres)
      gsn_polyline(wks, tawplot, (/k-0.1, k+0.1/), \
                              (/data(1,j)+data(2,j),\
                                data(1,j)+data(2,j)/), eres)
     end if

    end do

;  OVER PLOT MULTIYEAR AVERAGE
   eres@gsLineDashPattern = 2
   avgdata                = avg(data(1, :))
   gsn_polyline(wks, tawplot, (/x(0), x(ynmonth-1)/), \
                               (/avgdata, avgdata/), eres)
   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/resl, eres/])
return
end
