; $ID: plot_trend_hourly2_pm_epa_liu.ncl V01 01/13/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_hourly2_pm_epa_liu IS USED TO PLOT THE SIMILAR TREND 
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

undef("plot_trend_hourly2_pm_epa_liu")
procedure plot_trend_hourly2_pm_epa_liu \
         (wks    :graphic, sitename:string,  \ ; INPUT
          dataa  :float,   datab   :float,   \ ; INPUT
          mpplot :graphic)                     ; INPUT

begin
;  CONVERT N-DIM TO 1-DIM
   data1 = ndtooned(dataa)
   data2 = ndtooned(datab)
   ndim  = dimsizes(data1)
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
;  0*24   = 0
;  15*24  = 360
;  31*24  = 744
;  46*24  = 1104
;  61*24  = 1464
;  76*24  = 1824
;  92*24  = 2208
;  107*24 = 2568
;  122*24 = 2928
;  137*24 = 3288
;  153*24 = 3672
;  168*24 = 4032
   res@tmXBValues              = (/0, 360, 740, 1104, 1464, 1824, \
                                   2208, 2568, 2928, 3288, 3672, 4032/)
   res@tmXBLabels              = xtick
   res@trXMaxF                 = ndim
   res@trXMinF                 = 0
   res@tmXBMajorLengthF        = 0.01
   res@tmXBMinorLengthF        = 0.005
   res@tmXBMajorOutwardLengthF = 0.0
   res@tmXBMinorOutwardLengthF = 0.0
   res@tmXBMinorValues         = ispan(2,ndim,1*24)
   res@tmXTMajorLengthF        = 0.01
   res@tmXTMinorLengthF        = 0.005
   res@tmXTMajorOutwardLengthF = 0.0
   res@tmXTMinorOutwardLengthF = 0.0
   res@tmXTMinorValues         = ispan(2, ndim,1*24)
   res@tmYLMajorLengthF        = 0.01
   res@tmYLMinorLengthF        = 0.005
   res@tmYLMajorOutwardLengthF = 0.0
   res@tmYLMinorOutwardLengthF = 0.0
   res@tmYRMajorLengthF        = 0.01
   res@tmYRMinorLengthF        = 0.005
   res@tmYRMajorOutwardLengthF = 0.0
   res@tmYRMinorOutwardLengthF = 0.0

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   resr                        = True
   resr                        = res
   resr@xyMarkLineMode         = "MarkLines"
   resr@xyMarkers              = 15
   resr@xyMarkerSizes          = 0.001
   resr@xyMarkerThicknessF     = 1.0
   resr@xyMarkerColors         = "Blue"
   resr@xyLineColor            = "Blue"

;  SET LEGEND
   resr@pmLegendDisplayMode    = "Always"
   resr@pmLegendSide           = "Top"
   resr@pmLegendParallelPosF   = 0.21
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resr@pmLegendOrthogonalPosF =-0.45
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/"Liu PM~B~2.5~N~"/)
   resr@trYMaxF                = 50.0
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Date in Aug 2012"
   resr@tiYAxisString          = "Liu PM~B~2.5~N~(~F33~m~F21~g/m~S~3~N~)"
   resr@tiMainString           = "EPA vs Liu (Aug/2012-Jan/2013) " + sitename

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
   resl@pmLegendOrthogonalPosF =-0.37
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/"EPA PM~B~2.5~N~"/)
   resl@trYMaxF                = 50.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Date in Aug/2012-Jan/2013"
   resl@tiYAxisString          = "EPA PM~B~2.5~N~(~F33~m~F21~g/m~S~3~N~)"

   tawplot   = gsn_csm_xy2(wks, x, data1, data2, resl, resr)

   data5     = avg(data1)
   data6     = avg(data2)
   nrl = resl@trYMaxF/resr@trYMaxF
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres1                       = True
   eres1@gsLineColor           = "Red"
   eres1@gsLineThicknessF      = 2.0
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres2                       = True
   eres2@gsLineColor           = "blue"
   eres2@gsLineThicknessF      = 2.0
;  OVER PLOT MONTHLY AVERAGE
   eres1@gsLineDashPattern = 2
   eres2@gsLineDashPattern = 2
   if (.not.all(ismissing(data5))) then
    gsn_polyline(wks, tawplot, (/x(0), x(ndim-1)/), \
                               (/data5, data5/), eres1)
   end if
   if (.not.all(ismissing(data6))) then
    gsn_polyline(wks, tawplot, (/x(0), x(ndim-1)/), \
                               (/data6, data6/)*nrl, eres2)
   end if

;  CALCULATE CORRELATION
;  DEFINE LOCAL ARRAY
   if (.not.all(ismissing(data1)) .and. \
       .not.all(ismissing(data2))) then
    dim       = dimsizes(data2)
    data      = new((/2, dim/), float)
    tdata     = new((/2, dim/), float)
    data(0,:) = data1
    data(1,:) = data2
    avgdata1  = avg(data1)
    avgdata2  = avg(data2)
    stddata1  = dim_stddev_n(data1, 0)
    stddata2  = dim_stddev_n(data2, 0)
    data!0    = "EPA"
    data!1    = "Liu"
    ecr       = esccr(data1,data2,0)
    prob      = rtest(ecr,ndim,0)
    rc        = regline(data1,data2)
    cor       = correlation(data1, data2)
    tdata(0,:)= data2
    tdata(1,:)= rc*(data1-rc@xave) + rc@yave
;  CALCULATE RMSE
    ndata1    = onedtond(data1, (/dim, dim/))
    ndata2    = onedtond(data2, (/dim, dim/))
    rmse      = wgt_arearmse(ndata1, ndata2, 1.0, 1.0, 0)

;  SET UP TEXT RESOURCES
    tres               = True
    tres@txFontHeightF = 0.015
    gsn_text_ndc(wks,"y = ", 0.23, 0.77, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc), 0.27, 0.77, tres)
    gsn_text_ndc(wks,"x + ", 0.32, 0.77, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc@yave-rc*rc@xave), 0.36, 0.77, tres)
    gsn_text_ndc(wks,"R = ", 0.23, 0.75, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.27, 0.75, tres)
    gsn_text_ndc(wks,"N = ", 0.23, 0.73,tres)
    gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.26, 0.73,tres)
    gsn_text_ndc(wks,"RMSE = ", 0.36, 0.73,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rmse), 0.43, 0.73,tres)
    gsn_text_ndc(wks,"EPA  : ", 0.245, 0.71,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.30, 0.71,tres)
    gsn_text_ndc(wks,"~F34~1", 0.34, 0.71,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.38, 0.71,tres)
    gsn_text_ndc(wks,"Liu    : ", 0.245, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.30, 0.69,tres)
    gsn_text_ndc(wks,"~F34~1", 0.34, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.38, 0.69,tres)
   end if
   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/resl, resr, eres1, eres2/])
return
end
