; $ID: plot_trend_hourly5_year.ncl V01 09/15/2013 11:38 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_hourly5_year IS USED TO PLOT THE SIMILAR TREND LINE 
;  AMONG FIVE ONE-DIMENSIONAL ARRAYS, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks          (graphic) : WORK STATION                             [---]
;  (2 ) l_leap       (logical) : LEAP OR NON-LEAP YEAR                    [---]
;  (3 ) nday         (integer) : # OF DAY                                 [---]
;  (4 ) nhr          (integer) : # OF HOUR PER DAY (24)                   [---]
;  (5 ) emissionname (string)  : FIRE SMOKE EMISSION NAMES                [---]
;  (6 ) data         (float)   : FIVE SMOKE EMISSION DATA                 [---]
;  (7 ) data_mean    (float)   : MEAN OF FIVE SMOKE EMISSION DATA         [---]
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

undef("plot_trend_hourly5_year")
procedure plot_trend_hourly5_year \
         (wks           :graphic, l_leap        :logical, \ ; INPUT
          nday          :integer, nhr           :integer, \ ; INPUT
          emissionname  :string,                          \ ; INPUT
          data          :float,   data_mean     :float)     ; INPUT

begin

   if (l_leap) then
      xvalue      = (/0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335/)*nhr
      xminorvalue = (/15, 31, 60, 75,  91,  106, 121, 136, 152, 167, 182, 197, \
                      213, 228, 244, 259, 274, 289, 305, 320, 335, 350, 366/)*nhr
   else
      xvalue      = (/0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334/)*nhr
      xminorvalue = (/15, 31, 59, 74,  90,  105, 120, 135, 151, 166, 181, 196, \
                      212, 227, 243, 258, 273, 288, 304, 319, 334, 349, 365/)*nhr
   end if
   x              = ispan(1,nday*nhr,1)
   xtick          = (/"01", "02", "03", "04", "05", "06", \
                      "07", "08", "09", "10", "11", "12"/)

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                        = True
   res@vpWidthF               = 0.8
   res@vpHeightF              = 0.35
   res@vpXF                   = 0.15
   res@vpYF                   = 0.85
   res@gsnDraw                = False
   res@gsnFrame               = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   dashpatterns               = (/0, 1, 2, 3, 4/)
   linecolors                 = (/"Blue", "Black", "Red", "Purple", "Green"/)
   res@xyMarkLineMode         = "Lines"
   res@xyDashPatterns         = dashpatterns
   res@xyLineColors           = linecolors
;  SET X AXIS LABELS
   res@tmXBMode               = "Explicit"
   res@tmXBValues             = xvalue
   res@tmXBLabels             = xtick
   res@tmXBMajorLengthF       = 0.01
   res@tmXBMinorLengthF       = 0.005
   res@tmXBMajorOutwardLengthF= 0.0
   res@tmXBMinorOutwardLengthF= 0.0
   res@tmXBMinorValues        = xminorvalue
   res@tmXTMajorLengthF       = 0.01
   res@tmXTMinorLengthF       = 0.005
   res@tmXTMajorOutwardLengthF= 0.0
   res@tmXTMinorOutwardLengthF= 0.0
   res@tmXTMinorValues        = xminorvalue
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
   res@pmLegendOrthogonalPosF = (/-0.60, 0.48/)
   res@pmLegendWidthF         = 0.12
   res@pmLegendHeightF        = 0.12
   res@lgLabelFontHeightF     = 0.015
   res@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels = emissionname
   res@trYMaxF                = 10.0
   res@trYMinF                = 0.0
   res@tmYRMaxTicks           = 4
   res@tiXAxisString          = "Month 2010"
   res@tiYAxisString          = "Smoke Mass (Tg)"
   res@tiMainString           = "Smoke Mass ( 2010) Hourly"

   plot   = gsn_csm_xy(wks, x, data, res)

;  OVER PLOT YEARLY AVERAGE
   eres                    = True
   eres0                   = True
   eres0                   = eres
   eres0@gsLineDashPattern = dashpatterns(0)
   eres0@gsLineColor       = linecolors(0)
   if (.not.all(ismissing(data_mean(0)))) then
    gsn_polyline(wks, plot, (/x(0), x(nday*nhr-1)/), \
                               (/data_mean(0), data_mean(0)/), eres0)
   end if

   eres1                   = True
   eres1                   = eres
   eres1@gsLineDashPattern = dashpatterns(1)
   eres1@gsLineColor       = linecolors(1)
   if (.not.all(ismissing(data_mean(1)))) then
    gsn_polyline(wks, plot, (/x(0), x(nday*nhr-1)/), \
                               (/data_mean(1), data_mean(1)/), eres1)
   end if

   eres2                   = True
   eres2                   = eres
   eres2@gsLineDashPattern = dashpatterns(2)
   eres2@gsLineColor       = linecolors(2)
   if (.not.all(ismissing(data_mean(2)))) then
    gsn_polyline(wks, plot, (/x(0), x(nday*nhr-1)/), \
                               (/data_mean(2), data_mean(2)/), eres2)
   end if

   eres3                   = True
   eres3                   = eres
   eres3@gsLineDashPattern = dashpatterns(3)
   eres3@gsLineColor       = linecolors(3)
   if (.not.all(ismissing(data_mean(3)))) then
    gsn_polyline(wks, plot, (/x(0), x(nday*nhr-1)/), \
                               (/data_mean(3), data_mean(3)/), eres3)
   end if

   eres4                   = True
   eres4                   = eres
   eres4@gsLineDashPattern = dashpatterns(4)
   eres4@gsLineColor       = linecolors(4)
   if (.not.all(ismissing(data_mean(4)))) then
    gsn_polyline(wks, plot, (/x(0), x(nday*nhr-1)/), \
                               (/data_mean(4), data_mean(4)/), eres4)
   end if

   eres1                   = True
   eres1                   = eres
   eres1@gsLineDashPattern = dashpatterns(0)
   eres1@gsLineColor       = linecolors(0)
   if (.not.all(ismissing(data_mean(0)))) then
    gsn_polyline(wks, plot, (/x(0), x(nday*nhr-1)/), \
                               (/data_mean(0), data_mean(0)/), eres1)
   end if

   draw(plot)
   frame(wks)

return
end
