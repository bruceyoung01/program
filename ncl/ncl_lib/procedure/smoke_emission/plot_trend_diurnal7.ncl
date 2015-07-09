; $ID: plot_trend_diurnal7.ncl V01 02/24/2013 16:39 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_diurnal7 IS USED TO PLOT THE TREND LINE 
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

undef("plot_trend_diurnal7")
procedure plot_trend_diurnal7 \
         (wks    :graphic, emission :string,  \ ; INPUT
          data   :float,   data_mean:float,   \ ; INPUT
          nhour    :integer)                    ; INPUT

begin

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.8
   res@vpHeightF               = 0.55
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

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
   res@pmLegendOrthogonalPosF  =-0.50
   res@pmLegendWidthF          = 0.12
   res@pmLegendHeightF         = 0.17
   res@lgLabelFontHeightF      = 0.013
   res@lgPerimOn               = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels  = emission
   res@trYAxisType             = "LogAxis"
   res@trYMaxF                 = 10000.0
   res@trYMinF                 = 1.0
   res@tiXAxisString           = "Diurnal Variation (UTC)"
   res@tiYAxisString           = "Smoke Total Mass(Gg)"
   res@tiMainString            = "Smoke Emission (2010) "
   plot   = gsn_csm_xy(wks, x, data, res)
   draw(plot)

;  OVER PLOT MONTHLY AVERAGE
   eres                   = True
   eres                   = eres
   ndim                   = dimsizes(data_mean)

   do i = 0, ndim-1
      eres@gsLineDashPattern = dashpatterns(i)
      eres@gsLineColor       = linecolors(i)
      if (.not.all(ismissing(data_mean(i)))) then
         gsn_polyline(wks, plot, (/x(i), x(nhour-1)/), \
                              (/data_mean(i), data_mean(i)/), eres)
      end if
   end do

   draw(plot)
   frame(wks)
return
end
