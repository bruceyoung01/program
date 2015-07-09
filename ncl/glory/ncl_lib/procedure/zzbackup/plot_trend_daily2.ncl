; $ID: plot_trend_daily2.ncl V01 01/13/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_daily2 IS USED TO PLOT THE SIMILAR TREND LINE BETWEEN 
;  TWO ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) sitename   (string)  : FMF SITE NAME                            [---]
;  (3 ) year       (integer) : FMF OBSERVATION YEAR                     [---]
;  (4 ) month      (integer) : AEROENT OBSERVATION MONTH                [---]
;  (5 ) date       (integer) : FMF OBSERVATION DATE, INCLUDING YEAR, MONTH, 
;                              DAY, AND HOUR                            [---]
;  (6 ) data1      (float)   : FMF OBSERVATION DATA                     [---]
;  (7 ) data2      (float)   : SELETED WRFCHEM DATA DEPENDING ON FMF    [---]
;  (8 ) data3      (float)   : FMF OBSERVATION DATA STANDARD 
;                              DEVIATION                                [---]
;  (9 ) data4      (float)   : SELECTED WRFCHEM DATA STANDARD DEVIATION 
;                              DEPENDING ON FMF                         [---]
;  (10) data5      (float)   : FMF OBSERVATION DATA MONTHLY AVERAGE     [---]
;  (11) data6      (float)   : SELECTED WRFCHEM DATA MONTHLY AVERAGE    [---]
;  (12) nday       (integer) : TOTAL # OF FMF OBSERVATION DAYS          [---]
;  (13) bv1        (integer) : MISSING VALUE FOR INTEGER                [---]
;  (14) bv2        (float)   : MISSING VALUE FOR FLOAT                  [---]
;  (15) mpplot     (graphic) : MAP WITH MARKERS                         [---]
;  (16) tawplot    (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;******************************************************************************

undef("plot_trend_daily2")
procedure plot_trend_daily2(wks    :graphic, sitename:string,  \ ; INPUT
                            year   :integer, month   :integer, \ ; INPUT
                            date   :integer,                   \ ; INPUT
                            data1  :float,   data2   :float,   \ ; INPUT
                            data3  :float,   data4   :float,   \ ; INPUT
                            data5  :float,   data6   :float,   \ ; INPUT
                            nday   :integer,                   \ ; INPUT
                            bv1    :integer, bv2     :float,   \ ; INPUT
                            mpplot :graphic,                   \ ; INPUT
                            tawplot:graphic)                     ; OUTPUT

begin

;  MATCH DATA1 AND DATA2
   index1 = ind(ismissing(data1))
   if(.not.all(ismissing(index1)))then
    data2(index1) = bv2
   end if
   index2 = ind(ismissing(data2))
   if(.not.all(ismissing(index2)))then
    data1(index2) = bv2
   end if
   delete([/index1, index2/])

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
   x                           = ispan(1,nday,1)
   xtick                       = (/"01", "03", "05", "07", "09", \
                                   "11", "13", "15", "17", "19", \
                                   "21", "23", "25", "27", "29"/)
   resr@tmXBMode               = "Explicit"
   resr@tmXBValues             = x(0:nday-1:2)
   resr@tmXBLabels             = xtick
   resr@tmXBMajorLengthF       = 0.01
   resr@tmXBMinorLengthF       = 0.005
   resr@tmXBMajorOutwardLengthF= 0.0
   resr@tmXBMinorOutwardLengthF= 0.0
   resr@tmXBMinorValues        = ispan(2,nday,2)
   resr@tmXTMajorLengthF       = 0.01
   resr@tmXTMinorLengthF       = 0.005
   resr@tmXTMajorOutwardLengthF= 0.0
   resr@tmXTMinorOutwardLengthF= 0.0
   resr@tmXTMinorValues        = ispan(2,  nday,2)
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
   resr@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resr@pmLegendOrthogonalPosF =-0.45
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/" 440 - 870  Ang "/)
   resr@trYMaxF                = 2.0
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Date in February 2008"
   resr@tiYAxisString          = "440-870 Ang"
   resr@tiMainString           = "440-870 Ang VS FMF(Feb 2008)  Daily " + sitename

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
   resl@tmXBValues             = x(0:nday-1:2)
   resl@tmXBLabels             = xtick
   resl@tmXBMajorLengthF       = 0.01
   resl@tmXBMinorLengthF       = 0.005
   resl@tmXBMajorOutwardLengthF= 0.0
   resl@tmXBMinorOutwardLengthF= 0.0
   resl@tmXBMinorValues        = ispan(2,nday,2)
   resl@tmXTMajorLengthF       = 0.01
   resl@tmXTMinorLengthF       = 0.005
   resl@tmXTMajorOutwardLengthF= 0.0
   resl@tmXTMinorOutwardLengthF= 0.0
   resl@tmXTMinorValues        = ispan(2,nday,2)
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
   resl@pmLegendParallelPosF   = 0.23
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.38 TO -0.35)
   resl@pmLegendOrthogonalPosF =-0.38
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/" FMF(500 nm)"/)
   resl@trYMaxF                = 2.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Date in February 2008"
   resl@tiYAxisString          = "Fine Mode Fraction (500nm)"

   tawplot   = gsn_csm_xy2(wks, x, data1, data2, resl, resr)

;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres1                       = True
   eres1@gsLineColor           = "Red"
   eres1@gsLineThicknessF      = 2.0
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres2                       = True
   eres2@gsLineColor           = "blue"
   eres2@gsLineThicknessF      = 2.0

   nrl = resl@trYMaxF/resr@trYMaxF
;  PLOT ERROR BAR
    do j = 0, nday-1
     k = j + 1
     if(.not.ismissing(data1(j)) .and. \
        .not.ismissing(data3(j))) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data1(j)-data3(j),\
                                data1(j)/), eres1)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data1(j)-data3(j),\
                                data1(j)-data3(j)/), eres1)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data1(j),   \
                                data1(j)+data3(j)/), eres1)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data1(j)+data3(j),\
                                data1(j)+data3(j)/), eres1)
     end if
     if(.not.ismissing(data2(j)) .and. \
        .not.ismissing(data4(j))) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data2(j)-data4(j),\
                                data2(j)/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data2(j)-data4(j),\
                                data2(j)-data4(j)/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data2(j),   \
                                data2(j)+data4(j)/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data2(j)+data4(j),\
                                data2(j)+data4(j)/)*nrl, eres2)
     end if

    end do

;  OVER PLOT MONTHLY AVERAGE
   eres1@gsLineDashPattern = 2
   eres2@gsLineDashPattern = 2
   if (.not.all(ismissing(data5))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data5, data5/), eres1)
   end if
   if (.not.all(ismissing(data6))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
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
    data!0    = "FMF"
    data!1    = "440-870 Ang"
    ecr       = esccr(data1,data2,0)
    prob      = rtest(ecr,nday,0)
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
    gsn_text_ndc(wks,"FMF(500nm): ", 0.268, 0.71,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.35, 0.71,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.71,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.42, 0.71,tres)
    gsn_text_ndc(wks,"440-870 Ang: ", 0.27, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.35, 0.69,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.42, 0.69,tres)
   end if
   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/resl, resr, eres1, eres2/])
return
end
