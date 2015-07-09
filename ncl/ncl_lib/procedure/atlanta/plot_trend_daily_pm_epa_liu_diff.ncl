; $ID: plot_trend_daily_pm_epa_liu_diff.ncl V01 01/13/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_daily_pm_epa_liu_diff IS USED TO PLOT THE SIMILAR TREND 
;  LINE BETWEEN TWO ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS.
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
;******************************************************************************

undef("plot_trend_daily_pm_epa_liu_diff")
procedure plot_trend_daily_pm_epa_liu_diff \
         (wks    :graphic, sitename:string,  \ ; INPUT
          dataa  :float,                     \ ; INPUT
          mpplot :graphic)                     ; INPUT

begin
;  CONVERT N-DIM TO 1-DIM
   data1 = ndtooned(dataa)
   dim   = dimsizes(dataa)
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
   xtick                       = (/"Aug01", "15", "Sep01", "15", \
                                   "Oct01", "15", "Nov01", "15", \
                                   "Dec01", "15", "Jan01", "15"/)
   res@tmXBMode                = "Explicit"
;  NOTE : HOW TO CALCULATE tmXBValues
;  0
;  15
;  31
;  46
;  61
;  76
;  92
;  107
;  122
;  137
;  153
;  168
   res@tmXBValues              = (/0, 15, 31, 46, 61, 76, \
                                   92, 107, 122, 137, 153, 168/)
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
   resl                        = True
   resl                        = res
   resl@xyMarkLineMode         = "MarkLines"
   resl@xyMarkers              = 16
   resl@xyMarkerSizes          = 0.001
   resl@xyMarkerThicknessF     = 1.0
   resl@xyMarkerColors         = "Red"
   resl@xyLineColor            = "Red"

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.22
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.38 TO -0.35)
   resl@pmLegendOrthogonalPosF =-0.43
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/"Liu-EPA PM~B~2.5~N~"/)
   resl@trYMaxF                =  10.0
   resl@trYMinF                = -10.0
   resl@tiXAxisString          = "Date in Aug/2012-Jan/2013"
   resl@tiYAxisString          = "PM~B~2.5~N~(~F33~m~F21~g/m~S~3~N~)"
   resl@tiMainString           = "EPA vs Liu (Aug/2012-Jan/2013) " + sitename
   resl@gsnYRefLine            = 0.0

   tawplot   = gsn_csm_xy(wks, x, data1, resl)

   data5     = avg(data1)
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres1                       = True
   eres1@gsLineColor           = "Red"
   eres1@gsLineThicknessF      = 2.0
;  OVER PLOT MONTHLY AVERAGE
   eres1@gsLineDashPattern = 2
   if (.not.all(ismissing(data5))) then
    gsn_polyline(wks, tawplot, (/x(0), x(ndim-1)/), \
                               (/data5, data5/), eres1)
   end if

   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/resl, eres1/])
return
end
