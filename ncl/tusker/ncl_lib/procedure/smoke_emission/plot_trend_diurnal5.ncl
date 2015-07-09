; $ID: plot_trend_diurnal5.ncl V01 02/24/2013 16:39 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_diurnal5 IS USED TO PLOT THE TREND LINE 
;  USING ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) emission   (string)  : SMOKE EMISSION NAME                      [---]
;  (3 ) data       (float)   : SMOKE EMISSION DATA                      [---]
;  (4 ) data_mean  (float)   : SMOKE EMISSION DATA MEAN                 [---]
;  (5 ) nhour      (integer) : TOTAL # OF SMOKE EMISSION HOURS          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (06/09/2012)
;  (5 ) MODIFIED FROM plot_trend_daily2_aod.ncl. (02/24/2013)
;  (6 ) MODIFIED FROM plot_trend_line_epa_diurnal.ncl. (09/15/2013)
;******************************************************************************

undef("plot_trend_diurnal5")
procedure plot_trend_diurnal5 \
         (wks    :graphic, emission :string,  \ ; INPUT
          data   :float,   data_mean:float,   \ ; INPUT
          nhour    :integer)                    ; INPUT

begin

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.8
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   dashpatterns               = (/0, 1, 2, 3, 4/)
   linecolors                 = (/"Blue", "Black", "Red", "Purple", "Green"/)
   res@xyMarkLineMode         = "Lines"
   res@xyDashPatterns         = dashpatterns
   res@xyLineColors           = linecolors
   res@xyLineThicknessF       = 1.5

;  SET X AXIS LABELS
   x                           = ispan(1,nhour,1)
   xtick                       = (/"01", "02", "03", "04", "05", "06", \
                                   "07", "08", "09", "10", "11", "12", \
                                   "13", "14", "15", "16", "17", "18", \
                                   "19", "20", "21", "22", "23", "24" /)
   res@tmXBMode                = "Explicit"
   res@tmXBValues              = x(0:nhour-1:2)
   res@tmXBLabels              = xtick(0:nhour-1:2)
   res@trXMaxF                 = 25
   res@tmXBMajorLengthF        = 0.01
   res@tmXBMinorLengthF        = 0.005
   res@tmXBMajorOutwardLengthF = 0.0
   res@tmXBMinorOutwardLengthF = 0.0
   res@tmXBMinorValues         = ispan(2,nhour-1,2)
   res@tmYLMajorLengthF        = 0.01
   res@tmYLMinorLengthF        = 0.005
   res@tmYLMajorOutwardLengthF = 0.0
   res@tmYLMinorOutwardLengthF = 0.0

;  SET LEGEND
   res@pmLegendDisplayMode     = "Always"
   res@pmLegendSide            = "Top"
   res@pmLegendParallelPosF    = 0.15
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   res@pmLegendOrthogonalPosF  =-0.60
   res@pmLegendWidthF          = 0.12
   res@pmLegendHeightF         = 0.12
   res@lgLabelFontHeightF      = 0.015
   res@lgPerimOn               = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels  = emission
   res@trYMaxF                 = 800.0
   res@trYMinF                 = 0.0
   res@tiXAxisString           = "Diurnal Variation (UTC)"
   res@tiYAxisString           = "Smoke Flux( )"
   res@tiMainString            = "Smoke Emission (Feb 2010) "
   plot   = gsn_csm_xy(wks, x, data, res)
   draw(plot)

;  OVER PLOT MONTHLY AVERAGE
   eres                    = True
   eres0                   = True
   eres0                   = eres
   eres0@gsLineDashPattern = dashpatterns(0)
   eres0@gsLineColor       = linecolors(0)
   if (.not.all(ismissing(data_mean(0)))) then
    gsn_polyline(wks, plot, (/x(0), x(nhour-1)/), \
                               (/data_mean(0), data_mean(0)/), eres0)
   end if

   eres1                   = True
   eres1                   = eres
   eres1@gsLineDashPattern = dashpatterns(1)
   eres1@gsLineColor       = linecolors(1)
   if (.not.all(ismissing(data_mean(1)))) then
    gsn_polyline(wks, plot, (/x(0), x(nhour-1)/), \
                               (/data_mean(1), data_mean(1)/), eres1)
   end if

   eres2                   = True
   eres2                   = eres
   eres2@gsLineDashPattern = dashpatterns(2)
   eres2@gsLineColor       = linecolors(2)
   if (.not.all(ismissing(data_mean(2)))) then
    gsn_polyline(wks, plot, (/x(0), x(nhour-1)/), \
                               (/data_mean(2), data_mean(2)/), eres2)
   end if

   eres3                   = True
   eres3                   = eres
   eres3@gsLineDashPattern = dashpatterns(3)
   eres3@gsLineColor       = linecolors(3)
   if (.not.all(ismissing(data_mean(3)))) then
    gsn_polyline(wks, plot, (/x(0), x(nhour-1)/), \
                               (/data_mean(3), data_mean(3)/), eres3)
   end if

   eres4                   = True
   eres4                   = eres
   eres4@gsLineDashPattern = dashpatterns(4)
   eres4@gsLineColor       = linecolors(4)
   if (.not.all(ismissing(data_mean(4)))) then
    gsn_polyline(wks, plot, (/x(0), x(nhour-1)/), \
                               (/data_mean(4), data_mean(4)/), eres4)
   end if

   draw(plot)
   frame(wks)
return
end
