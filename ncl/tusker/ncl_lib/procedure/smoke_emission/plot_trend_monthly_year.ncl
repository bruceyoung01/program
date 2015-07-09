; $ID: plot_trend_monthly_year.ncl V01 09/15/2013 11:38 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_monthly_year IS USED TO PLOT THE SIMILAR TREND LINE 
;  AMONG FIVE ONE-DIMENSIONAL ARRAYS, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks          (graphic) : WORK STATION                             [---]
;  (2 ) nmonth       (integer) : TOTAL # OF OBSERVATION MONTHS            [---]
;  (3 ) emissionname (string)  : FIRE SMOKE EMISSION NAMES                [---]
;  (4 ) data         (float)   : FIVE SMOKE EMISSION DATA                 [---]
;  (5 ) data_mean    (float)   : AVERAGE OF FIVE SMOKE EMISSION DATA      [---]
;  (6 ) plot         (graphic) : PLOT                                     [---]
;  (7 ) plot1        (graphic) : PLOT                                     [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (05/12/2012)
;  (5 ) MODIFIED FROM plot_trend_daily3_tcf.ncl. (05/28/2012)
;  (6 ) MODIFIED FROM plot_trend_daily3_wam.ncl. (09/15/2013)
;  (7 ) MODIFIED FROM plot_trend_hourly5.ncl. (09/24/2013)
;******************************************************************************

undef("plot_trend_monthly_year")
procedure plot_trend_monthly_year \
         (wks           :graphic,                         \ ; INPUT
          nmonth        :integer, emissionname  :string,  \ ; INPUT
          data          :float,   data_mean     :float,   \ ; INPUT
          plot          :graphic, plot1         :graphic)   ; OUTPUT

begin

   ndim           = dimsizes(data)
   nndim          = dimsizes(ndim)
   if (nndim .eq. 1) then
      ncase       = 1
   else
      ncase       = ndim(0)
   end if
   x              = ispan(1,nmonth,1)
   xvalue         = x
   xtick          = (/"Jan", "Feb", "Mar", "Apr", "May", "Jun", \
                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"/)

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                        = True
   res@vpWidthF               = 0.8
   res@vpHeightF              = 0.55
   res@vpXF                   = 0.15
   res@vpYF                   = 0.85
   res@gsnMaximize            = True
   res@gsnDraw                = False
   res@gsnFrame               = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   dashpatterns1              = (/0, 0, 0, 0, 0, 0, 0/)
   dashpatterns               = (/2, 2, 2, 2, 2, 2, 2/)
   markers                    = (/4, 4, 4, 4, 4, 4, 4/)
   linecolors                 = (/"blue", "red", "pink", "purple", "green", "black", "brown"/)
   res@xyMarkLineMode         = "MarkLines"
   res@xyMarkers              = markers
   res@xyMarkerColors         = linecolors
   res@xyMarkerThicknessF     = 1.5
   res@xyMarkerSizeF          = 0.007

   res@xyDashPatterns         = dashpatterns1
   res@xyLineColors           = linecolors
   res@xyLineThicknessF       = 2.0

;  SET X AXIS LABELS
   res@tmXBMode               = "Explicit"
   res@tmXBValues             = xvalue
   res@tmXBLabels             = xtick
   res@tmXBMajorLengthF       = 0.01
   res@tmXBMinorLengthF       = 0.005
   res@tmXBMajorOutwardLengthF= 0.0
   res@tmXTMajorLengthF       = 0.01
   res@tmXTMajorOutwardLengthF= 0.0
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
   res@pmLegendParallelPosF   = 0.15
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   res@pmLegendOrthogonalPosF = -0.50
   res@pmLegendWidthF         = 0.12
   res@pmLegendHeightF        = 0.17
   res@lgLabelFontHeightF     = 0.015
   res@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels = emissionname
;  X Y RANGE
   res@trXMaxF                = nmonth
   res@trXMinF                = 0
   res@trYAxisType            = "LogAxis"
   res@trYMaxF                = 10000.0
   res@trYMinF                = 1.0
   res@tmYRMaxTicks           = 4
   res@tiXAxisString          = "Month 2010"
   res@tiYAxisString          = "Smoke Mass (Gg)"
   res@tiMainString           = "Smoke Mass ( 2010) Monthly"

   plot   = gsn_csm_xy(wks, x, data, res)

;  OVER PLOT YEARLY AVERAGE
   eres                    = True
   do i = 0, ncase-1
      eres@gsLineDashPattern  = dashpatterns(i)
      eres@gsLineColor        = linecolors(i)
      if (.not.all(ismissing(data_mean(i)))) then
         plot1(i) = gsn_add_polyline(wks, plot, (/x(0), x(nmonth-1)/), \
                               (/data_mean(i), data_mean(i)/), eres)
      end if
   end do
   draw(plot)
   frame(wks)
return
end
