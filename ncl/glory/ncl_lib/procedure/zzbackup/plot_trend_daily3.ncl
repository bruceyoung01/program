; $ID: plot_trend_daily3.ncl V01 01/13/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_daily3 IS USED TO PLOT THE SIMILAR TREND LINE BETWEEN 
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
;  (8 ) data3      (float)   : DATA3                                    [---]
;  (9 ) data4      (float)   : FMF OBSERVATION DATA STANDARD 
;                              DEVIATION                                [---]
;  (10) data5      (float)   : SELECTED WRFCHEM DATA STANDARD DEVIATION 
;                              DEPENDING ON FMF                         [---]
;  (11) data6      (float)   : STANDARD DEVIATION OF DATA3              [---]
;  (12) data7      (float)   : FMF OBSERVATION DATA MONTHLY AVERAGE     [---]
;  (13) data8      (float)   : SELECTED WRFCHEM DATA MONTHLY AVERAGE    [---]
;  (14) data9      (float)   : DATA3 MONTHLY AVERAGE                    [---]
;  (15) nday       (integer) : TOTAL # OF FMF OBSERVATION DAYS          [---]
;  (16) bv1        (integer) : MISSING VALUE FOR INTEGER                [---]
;  (17) bv2        (float)   : MISSING VALUE FOR FLOAT                  [---]
;  (18) mpplot     (graphic) : MAP WITH MARKERS                         [---]
;  (19) tawplot    (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (05/12/2012)
;******************************************************************************

undef("plot_trend_daily3")
procedure plot_trend_daily3(wks    :graphic, sitename:string,  \ ; INPUT
                            year   :integer, month   :integer, \ ; INPUT
                            date   :integer,                   \ ; INPUT
                            data1  :float,   data2   :float,   \ ; INPUT
                            data3  :float,   data4   :float,   \ ; INPUT
                            data5  :float,   data6   :float,   \ ; INPUT
                            data7  :float,   data8   :float,   \ ; INPUT
                            data9  :float,   nday   :integer,  \ ; INPUT
                            bv1    :integer, bv2     :float,   \ ; INPUT
                            mpplot :graphic,                   \ ; INPUT
                            tawplot:graphic)                     ; OUTPUT

begin

   dim       = dimsizes(data2)
   tdata     = new((/2, dim/), float)
   tdata(0,:) = data2
   tdata(1,:) = data3

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
   resr@xyMarkers              = (/16, 6/)
   resr@xyDashPatterns         = (/0, 0/)
   resr@xyMarkerSizes          = (/5, 5/)
   resr@xyMarkerThicknessF     = 2.0
   resr@xyMarkerColors         = (/"Blue", "Black"/)
   resr@xyLineColors           = (/"Blue", "Black"/)
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
   resr@pmLegendParallelPosF   = (/0.26, 0.23/)
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resr@pmLegendOrthogonalPosF = (/-0.52, 0.48/)
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/" Coarse Mode AOD (500nm) ", " Total AOD (500 nm)      "/)
   resr@trYMaxF                = 4.0
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Date in February 2008"
   resr@tiYAxisString          = "AOD"
   resr@tiMainString           = "AOD (Feb 2008)  Daily " + sitename

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
   resl@pmLegendParallelPosF   = 0.245
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.38 TO -0.35)
   resl@pmLegendOrthogonalPosF =-0.34
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/" Fine Mode AOD (500 nm)"/)
   resl@trYMaxF                = 4.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Date in February 2008"
   resl@tiYAxisString          = "AOD"

   tawplot   = gsn_csm_xy2(wks, x, data1, tdata, resl, resr)

;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres1                       = True
   eres1@gsLineColor           = "Red"
   eres1@gsLineThicknessF      = 2.0
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres2                       = True
   eres2@gsLineColor           = "blue"
   eres2@gsLineThicknessF      = 2.0
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres3                       = True
   eres3@gsLineColor           = "black"
   eres3@gsLineThicknessF      = 2.0

   nrl = resl@trYMaxF/resr@trYMaxF
;  PLOT ERROR BAR
    do j = 0, nday-1
     k = j + 1
     if(.not.ismissing(data1(j)) .and. \
        .not.ismissing(data4(j))) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data1(j)-data4(j),\
                                data1(j)/), eres1)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data1(j)-data4(j),\
                                data1(j)-data4(j)/), eres1)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data1(j),   \
                                data1(j)+data4(j)/), eres1)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data1(j)+data4(j),\
                                data1(j)+data4(j)/), eres1)
     end if
     if(.not.ismissing(data2(j)) .and. \
        .not.ismissing(data5(j))) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data2(j)-data5(j),\
                                data2(j)/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data2(j)-data5(j),\
                                data2(j)-data5(j)/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data2(j),   \
                                data2(j)+data5(j)/)*nrl, eres2)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data2(j)+data5(j),\
                                data2(j)+data5(j)/)*nrl, eres2)
     end if
     if(.not.ismissing(data3(j)) .and. \
        .not.ismissing(data6(j))) then
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data3(j)-data6(j),\
                                data3(j)/)*nrl, eres3)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data3(j)-data6(j),\
                                data3(j)-data6(j)/)*nrl, eres3)
      gsn_polyline(wks, tawplot, (/k, k/), \
                              (/data3(j),   \
                                data3(j)+data6(j)/)*nrl, eres3)
      gsn_polyline(wks, tawplot, (/k-0.2, k+0.2/), \
                              (/data3(j)+data6(j),\
                                data3(j)+data6(j)/)*nrl, eres3)
     end if
    end do

;  OVER PLOT MONTHLY AVERAGE
   eres1@gsLineDashPattern = 2
   eres2@gsLineDashPattern = 2
   eres3@gsLineDashPattern = 2
   if (.not.all(ismissing(data7))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data7, data7/), eres1)
   end if
   if (.not.all(ismissing(data8))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data8, data8/)*nrl, eres2)
   end if
   if (.not.all(ismissing(data9))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nday-1)/), \
                               (/data9, data9/)*nrl, eres3)
   end if

;  CALCULATE CORRELATION
;  DEFINE LOCAL ARRAY
   if (.not.all(ismissing(data1)) .and. \
       .not.all(ismissing(data2)) .and. \
       .not.all(ismissing(data3))) then
    dim       = dimsizes(data2)
    data      = new((/2, dim/), float)
    tdata     = new((/2, dim/), float)
    data(0,:) = data1
    data(1,:) = data2
    avgdata1  = avg(data1)
    avgdata2  = avg(data2)
    avgdata3  = avg(data3)
    stddata1  = dim_stddev_n(data1, 0)
    stddata2  = dim_stddev_n(data2, 0)
    stddata3  = dim_stddev_n(data3, 0)
    ecr       = esccr(data1,data2,0)
    prob      = rtest(ecr,nday,0)
    rc        = regline(data1,data2)
    cor       = correlation(data1, data2)
    tdata(0,:)= data2
    tdata(1,:)= rc*(data1-rc@xave) + rc@yave

;  SET UP TEXT RESOURCES
    tres               = True
    tres@txFontHeightF = 0.015
    gsn_text_ndc(wks,"N = ", 0.24, 0.75,tres)
    gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.27, 0.75,tres)
    gsn_text_ndc(wks,"FMAOD : ", 0.268, 0.73,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.35, 0.73,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.73,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.42, 0.73,tres)
    gsn_text_ndc(wks,"CMAOD : ", 0.268, 0.71,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.35, 0.71,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.71,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.42, 0.71,tres)
    gsn_text_ndc(wks,"TAOD     : ", 0.268, 0.69,tres) 
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata3), 0.35, 0.69,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata3), 0.42, 0.69,tres)
   end if
   draw(mpplot)
   draw(tawplot)
   frame(wks)
   delete([/resl, resr, eres1, eres2, eres3/])
return
end
