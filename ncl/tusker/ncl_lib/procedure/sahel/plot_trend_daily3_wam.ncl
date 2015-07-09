; $ID: plot_trend_daily3_wam.ncl V01 01/13/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_daily3_wam IS USED TO PLOT THE SIMILAR TREND LINE 
;  AMONG THREE ONE-DIMENSIONAL ARRAYS, INCLUDING WRFCHEM AOD, AERONET AOD, AND 
;  MODIS AOD, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) sitename   (string)  : AERONET SITE NAME                        [---]
;  (3 ) year       (integer) : AERONET OBSERVATION YEAR                 [---]
;  (4 ) month      (integer) : AERONET OBSERVATION MONTH                [---]
;  (5 ) date       (integer) : AERONET OBSERVATION DATE, INCLUDING YEAR, MONTH, 
;                              DAY, AND HOUR                            [---]
;  (6 ) data1      (float)   : AERONET OBSERVATION DATA                 [---]
;  (7 ) data2      (float)   : SELETED WRFCHEM DATA DEPENDING ON AERONET[---]
;  (8 ) data3      (float)   : MODIS AOD                                [---]
;  (9 ) data4      (float)   : AERONET OBSERVATION DATA STANDARD 
;                              DEVIATION                                [---]
;  (10) data5      (float)   : SELECTED WRFCHEM DATA STANDARD DEVIATION 
;                              DEPENDING ON AERONET                     [---]
;  (11) data6      (float)   : STANDARD DEVIATION OF MODIS AOD          [---]
;  (12) data7      (float)   : AERONET OBSERVATION DATA MONTHLY AVERAGE [---]
;  (13) data8      (float)   : SELECTED WRFCHEM DATA MONTHLY AVERAGE    [---]
;  (14) data9      (float)   : MODIS AOD MONTHLY AVERAGE                [---]
;  (15) nday       (integer) : TOTAL # OF AERONET OBSERVATION DAYS      [---]
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

undef("plot_trend_daily3_wam")
procedure plot_trend_daily3_wam \
                           (wks    :graphic, sitename:string,  \ ; INPUT
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
;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

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
   resr@xyMarkLineMode         = (/"MarkLines", "Markers"/)
   resr@xyMarkers              = (/16, 6/)
   resr@xyDashPatterns         = (/0, 0/)
   resr@xyMarkerSizes          = (/5, 5/)
   resr@xyMarkerThicknessF     = 2.0
   resr@xyMarkerColors         = (/"Blue", "Black"/)
   resr@xyLineColors           = (/"Blue", "White"/)
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
   resr@tmYRMajorLengthF       = 0.01
   resr@tmYRMinorLengthF       = 0.005
   resr@tmYRMajorOutwardLengthF= 0.0
   resr@tmYRMinorOutwardLengthF= 0.0

;  SET LEGEND
   resr@pmLegendDisplayMode    = "Always"
   resr@pmLegendSide           = "Top"
   resr@pmLegendParallelPosF   = (/0.21, 0.18/)
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resr@pmLegendOrthogonalPosF = (/-0.52, 0.48/)
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/" WRF-Chem (500nm) ", " MODIS   (550nm) "/)
   resr@trYMaxF                = 1.0
   resr@trYMinF                = 0.0
   resr@tmYRMaxTicks           = 5
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

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.20
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.38 TO -0.35)
   resl@pmLegendOrthogonalPosF =-0.34
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/" AERONET (500nm)"/)
   resl@trYMaxF                = 1.0
   resl@trYMinF                = 0.0
   resl@tmYLMaxTicks           = 5
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
       .not.all(ismissing(data2))) then
    data      = new((/2, dim/), float)
    data(0,:) = data1
    data(1,:) = data2
    avgdata1  = avg(data1)
    avgdata2  = avg(data2)
    stddata1  = dim_stddev_n(data1, 0)
    stddata2  = dim_stddev_n(data2, 0)
    ecr12     = esccr(data1,data2,0)
    prob12    = rtest(ecr12,nday,0)
    rc12      = regline(data1,data2)
    cor12     = correlation(data1, data2)
;  CALCULATE RMSE
    ndata1    = onedtond(data1, (/dim, dim/))
    ndata2    = onedtond(data2, (/dim, dim/))
    rmse12    = wgt_arearmse(ndata1, ndata2, 1.0, 1.0, 0)
    if (.not.all(ismissing(data3))) then
     avgdata3  = avg(data3)
     stddata3  = dim_stddev_n(data3, 0)
     ecr23     = esccr(data2,data3,0)
     prob23    = rtest(ecr23,nday,0)
     rc23      = regline(data2,data3)
     cor23     = correlation(data2, data3)
;  CALCULATE RMSE
     ndata3    = onedtond(data3, (/dim, dim/))
     rmse23    = wgt_arearmse(ndata2, ndata3, 1.0, 1.0, 0)
    else
     avgdata3  = bv2
     stddata3  = bv2
     ecr23     = bv2
     prob23    = bv2
     rc23      = bv2
     cor23     = bv2
     rmse23    = bv2
    end if

;  SET UP TEXT RESOURCES
    tres               = True
    tres@txFontHeightF = 0.015
    gsn_text_ndc(wks,"N = ", 0.19, 0.75,tres)
    gsn_text_ndc(wks,sprinti("%4.0i", rc12@nptxy), 0.22, 0.75,tres)
    gsn_text_ndc(wks,"AERONET  : ", 0.228, 0.73,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.31, 0.73,tres)
    gsn_text_ndc(wks,"~F34~1", 0.34, 0.73,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.38, 0.73,tres)
    gsn_text_ndc(wks,"(R = " + sprintf("%5.2f", cor12) + "  RMSE = " + \
                     sprintf("%5.2f", rmse12) + ")", 0.53, 0.73, tres)
    if (.not.all(ismissing(data3))) then
     gsn_text_ndc(wks,"MODIS       : ", 0.228, 0.71,tres) 
     gsn_text_ndc(wks,sprintf("%5.2f", avgdata3), 0.31, 0.71,tres)
     gsn_text_ndc(wks,"~F34~1", 0.34, 0.71,tres)
     gsn_text_ndc(wks,sprintf("%5.2f", stddata3), 0.38, 0.71,tres)
     gsn_text_ndc(wks,"(R = " + sprintf("%5.2f", cor23) + "  RMSE = " + \
                      sprintf("%5.2f", rmse23) + ")", 0.53, 0.71, tres)
    end if
    gsn_text_ndc(wks,"WRF-Chem : ", 0.228, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.31, 0.69,tres)
    gsn_text_ndc(wks,"~F34~1", 0.34, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.38, 0.69,tres)

   end if
   draw(mpplot)
   draw(tawplot)
   frame(wks)
   delete([/resl, resr, eres1, eres2, eres3/])
;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "plot_trend_daily3_wam.ncl", 0)

return
end
