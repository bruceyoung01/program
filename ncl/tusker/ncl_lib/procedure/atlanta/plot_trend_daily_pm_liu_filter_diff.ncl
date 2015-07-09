; $ID: plot_trend_daily_pm_liu_filter_diff.ncl V01 04/02/2012 00:35 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_daily_pm_liu_filter_diff IS USED TO PLOT THE SIMILAR 
;  TREND LINE BETWEEN TWO ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS 
;  TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) sitename   (string)  : OBS SITE NAME                            [---]
;  (3 ) dataa      (float)   : OBS OBSERVATION DATA                     [---]
;  (4 ) datab      (float)   : SELETED WRFCHEM DATA DEPENDING ON FMF    [---]
;  (5 ) nday       (integer) : TOTAL # OF FMF OBSERVATION DAYS          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (06/09/2012)
;  (5 ) MODIFIED FROM plot_trend_daily2_aod.ncl. (11/08/2012)
;  (6 ) MODIFIED FROM plot_trend_hourly2_pm.ncl. (03/12/2013)
;  (7 ) MODIFIED FROM plot_trend_daily2_pm_epa_liu.ncl. (04/01/2013)
;  (8 ) MODIFIED FROM plot_trend_daily2_pm_epa_liu_filter.ncl. (04/02/2013)
;******************************************************************************

undef("plot_trend_daily_pm_liu_filter_diff")
procedure plot_trend_daily_pm_liu_filter_diff \
         (wks    :graphic, dataa   :float,   \ ; INPUT
          mpplot :graphic)                     ; INPUT

begin
;  CONVERT N-DIM TO 1-DIM
   data1 = ndtooned(dataa)
   dim   = dimsizes(data1)
   ndim  = dim(0)

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.7
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET X AXIS LABELS
   x                           = ispan(1, ndim, 1)
   xtick                       = (/"Jan05", "10", "15", "20", \
                                   "25", "Feb01", "05"/)
   res@tmXBMode                = "Explicit"
;  NOTE : HOW TO CALCULATE tmXBValues
;  0
;  5
;  10
;  15
;  20
;  27
;  32
   res@tmXBValues              = (/1, 6, 11, 16, 21, 28, \
                                   32/)
   res@tmXBLabels              = xtick
   res@trXMaxF                 = ndim
   res@trXMinF                 = 0
   res@tmXBMajorLengthF        = 0.01
   res@tmXBMinorLengthF        = 0.005
   res@tmXBMajorOutwardLengthF = 0.0
   res@tmXBMinorOutwardLengthF = 0.0
   res@tmXBMinorValues         = ispan(2,ndim,1)
   res@tmXTMajorLengthF        = 0.01
   res@tmXTMinorLengthF        = 0.005
   res@tmXTMajorOutwardLengthF = 0.0
   res@tmXTMinorOutwardLengthF = 0.0
   res@tmXTMinorValues         = ispan(2, ndim,1)
   res@tmYLMajorLengthF        = 0.01
   res@tmYLMinorLengthF        = 0.005
   res@tmYLMajorOutwardLengthF = 0.0
   res@tmYLMinorOutwardLengthF = 0.0
   res@tmYRMajorLengthF        = 0.01
   res@tmYRMinorLengthF        = 0.005
   res@tmYRMajorOutwardLengthF = 0.0
   res@tmYRMinorOutwardLengthF = 0.0

;  SET RIGHT Y AXIS LABEL
   res@xyMarkLineMode          = "MarkLines"
   res@xyMarkers               = 7
   res@xyMarkerSizes           = 0.010
   res@xyMarkerThicknessF      = 2.0
   res@xyMarkerColors          = "Red"
   res@xyLineColor             = "Red"

;  SET LEGEND
   res@pmLegendDisplayMode     = "Always"
   res@pmLegendSide            = "Top"
   res@pmLegendParallelPosF    = 0.22
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.38 TO -0.35)
   res@pmLegendOrthogonalPosF  =-0.47
   res@pmLegendWidthF          = 0.12
   res@pmLegendHeightF         = 0.12
   res@lgLabelFontHeightF      = 0.015
   res@lgPerimOn               = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels  = (/"GRIMM-EPA Difference"/)
   res@trYMaxF                 =  10.0
   res@trYMinF                 = -10.0
   res@gsnYRefLine             =  0.0
   res@gsnYRefLineColor        = "Black"
   res@gsnYRefLineDashPattern  =  0
   res@gsnYRefLineThicknessF   =  2.0
   res@tiXAxisString           = "Date in Jan-Feb/2013"
   res@tiYAxisString           = "GRIMM-EPA Difference"
   res@tiMainString            = "Liu GRIMM/EPA Difference (Jan-Feb/2013) "

   tawplot   = gsn_csm_xy(wks, x, data1, res)

   data2     = avg(data1)
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres                        = True
   eres@gsLineColor            = "Red"
   eres@gsLineThicknessF       = 2.0
;  OVER PLOT MONTHLY AVERAGE
   eres@gsLineDashPattern      = 2
   if (.not.all(ismissing(data2))) then
    gsn_polyline(wks, tawplot, (/x(0), x(ndim-1)/), \
                               (/data2, data2/), eres)
   end if

   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/res, eres/])
return
end
