; $ID: plot_trend_hourly.ncl V01 01/13/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_hourly IS USED TO PLOT THE SIMILAR TREND LINE BETWEEN 
;  TWO ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) sitename   (string)  : AERONET SITE NAME                        [---]
;  (3 ) year       (integer) : AERONET OBSERVATION YEAR                 [---]
;  (4 ) month      (integer) : AEROENT OBSERVATION MONTH                [---]
;  (5 ) date       (integer) : AERONET OBSERVATION DATE, INCLUDING YEAR, MONTH, 
;                              DAY, AND HOUR                            [---]
;  (6 ) data1      (float)   : AERONET OBSERVATION DATA                 [---]
;  (7 ) data2      (float)   : SELETED WRFCHEM DATA DEPENDING ON AERONET[---]
;  (8 ) sitem      (integer) : SELETED AEROENT DATA VARIABLE            [---]
;  (9 ) nlines     (integer) : TOTAL AEROENT OBSERVATION TIMES          [---]
;  (10) nday       (integer) : TOTAL # OF AERONET OBSERVATION DAYS      [---]
;  (11) nhour      (integer) : # OF HOURS PER DAY(24)                   [---]
;  (12) bv1        (integer) : MISSING VALUE FOR INTEGER                [---]
;  (13) bv2        (float)   : MISSING VALUE FOR FLOAT                  [---]
;  (14) mpplot     (graphic) : MAP WITH MARKERS                         [---]
;  (15) tawplot    (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR HOURLY TREND LINE PLOT. (02/20/2012)
;******************************************************************************

undef("plot_trend_hourly")
procedure plot_trend_hourly(wks    :graphic, sitename:string,  \ ; INPUT
                            year   :integer, month   :integer, \ ; INPUT
                            date   :integer, nfiles  :integer, \ ; INPUT
                            data1  :float,   data2   :float,   \ ; INPUT
                            sitem  :integer, nlines  :integer, \ ; INPUT
                            nday   :integer, nhour   :integer, \ ; INPUT
                            bv1    :integer, bv2     :float,   \ ; INPUT
                            mpplot :graphic,                   \ ; INPUT
                            tawplot:graphic)                     ; OUTPUT

begin

;  REWRITE data1 AND data2 TO 24 HOURS PER DAY
   redata1      = new(nday*nhour, float, bv2)
   redata2      = new(nday*nhour, float, bv2)
   redate       = new((/nday*nhour,4/), integer, bv1)
   nhourly_true = num(.not.ismissing(date(:, 0)))
   do i = 0, nday-1
    do j = 0, nhour-1
     imark = 0
     do k = 0, nhourly_true-1
     if (date(k, 2) .eq. i+1 .and. date(k, 3) .eq. j+1 .and. \
         imark .eq. 0) then
      redata1(i*nhour+j)  = data1(k, sitem)
      redata2(i*nhour+j)  = data2(k)
      redate(i*nhour+j, :)= date(k, :)
      imark = 1
     end if
     end do
     if (imark .eq. 0) then
      redata1(i*nhour+j)  = bv2
      redata2(i*nhour+j)  = bv2
      redate(i*nhour+j, :)= (/year(0), month(0), i+1, j+1/)
     end if
    end do
   end do

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.7
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   resr                        = True
   resr                        = res
   resr@xyMarkLineMode         = "Markers"
   resr@xyMarkers              = 16
   resr@xyMarkerSizes          = 5
   resr@xyMarkerThicknessF     = 2.0
   resr@xyMarkerColors         = "Blue"
;  SET X AXIS LABELS
   x                           = ispan(1,nday*nhour,1)
   xtick                       = (/"Feb01", "02", "03", "04", "05"/)
;  xtick                       = (/"Feb01", "03", "05", "07", "09", \
;                                  "11", "13", "15", "17", "19", \
;                                  "21", "23", "25", "27", "29"/)
   resr@tmXBMode               = "Explicit"
   resr@tmXBValues             = x(0:nday*nhour-1:nhour*2)
   resr@tmXBLabels             = xtick
;  SET LEGEND
   resr@pmLegendDisplayMode    = "Always"
   resr@pmLegendSide           = "Top"
   resr@pmLegendParallelPosF   = 0.24
   resr@pmLegendOrthogonalPosF =-0.50
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/" WRFCHEM (600 nm)"/)
   resr@trYMaxF                = 0.3
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Date"
   resr@tiYAxisString          = " "
   resr@tiMainString           = "WRF/CHEM VS AERONET(Feb 2008)  " + sitename
;  SET RIGHT Y AXIS LABEL
   resl                        = True
   resl                        = res
   resl@xyMarkLineMode         = "Markers"
   resl@xyMarkers              = 7
   resl@xyMarkerSizes          = 5
   resl@xyMarkerThicknessF     = 2.0
   resl@xyMarkerColors         = "Red"
;  SET X AXIS LABELS
   resl@tmXBMode               = "Explicit"
   resl@tmXBValues             = x(0:nday*nhour-1:nhour*2)
   resl@tmXBLabels             = xtick

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.23
   resl@pmLegendOrthogonalPosF =-0.40
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/" AERONET(675 nm)"/)
   resl@trYMaxF                = 3.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Date"
   resl@tiYAxisString          = "AOD"
;  CALCULATE CORRELATION
;  DEFINE LOCAL ARRAY
   dim       = dimsizes(data2)
   data      = new((/2, dim/), float)
   tdata     = new((/2, dim/), float)
   data(0,:) = data1(:, sitem)
   data(1,:) = data2
   avgdata1  = avg(data1(:, sitem))
   avgdata2  = avg(data2)
   stddata1  = dim_stddev_n(data1(:, sitem), 0)
   stddata2  = dim_stddev_n(data2, 0)
   data!0    = "AERONET"
   data!1    = "WRFCHEM"
   ecr       = esccr(data1(:, sitem),data2,0)
   prob      = rtest(ecr,nfiles,0)
   rc        = regline(data1(:, sitem),data2)
   cor       = correlation(data1(:, sitem), data2)
   tdata(0,:)= data2
   tdata(1,:)= rc*(data1(:, sitem)-rc@xave) + rc@yave
;  CALCULATE RMSE
    ndata1    = onedtond(data1(:, sitem), (/dim, dim/))
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
   gsn_text_ndc(wks,"AEORNET : ", 0.268, 0.71,tres)
   gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.35, 0.71,tres)
   gsn_text_ndc(wks,"~F34~1", 0.38, 0.71,tres)
   gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.42, 0.71,tres)
   gsn_text_ndc(wks,"WRFCHEM: ", 0.27, 0.69,tres)
   gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.35, 0.69,tres)
   gsn_text_ndc(wks,"~F34~1", 0.38, 0.69,tres)
   gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.42, 0.69,tres)
   draw(mpplot)
   tawplot = gsn_csm_xy2(wks, x, redata1, redata2, resl, resr)
   overlay(mpplot, tawplot)
   delete([/resl, resr, tres, data, tdata/])
return
end
