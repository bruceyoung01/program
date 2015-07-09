; $ID: plot_scatter_viirs_aeronet.ncl V01 05/04/2012 09:34 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_viirs_aeronet PLOTS SCATTER PLOT WITH ERROR BAR AND 
;  CORRELATION INFO.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic) : WORK STATION                               [---]
;  (2 ) sitename (string)  : AERONET SITENAME                           [---]
;  (3 ) ndim     (integer) : # OF TOTAL DATA                            [---]
;  (4 ) sitem    (integer) : SELETED AEROENT DATA VARIABLE              [---]
;  (5 ) data1      (float) : AERONET OBSERVATION DATA                   [---]
;  (6 ) data2      (float) : SELETED VIIRS DATA DEPENDING ON AERONET    [---]
;  (7 ) data3      (float) : AERONET OBSERVATION DATA STANDARD 
;                            DEVIATION                                  [---]
;  (8 ) data4      (float) : SELECTED VIIRS DATA STANDARD DEVIATION 
;                            DEPENDING ON AERONET                       [---]
;  (9 ) data5      (float) : AERONET OBSERVATION DATA MONTHLY AVERAGE   [---]
;  (10) data6      (float) : SELECTED VIIRS DATA MONTHLY AVERAGE        [---]
;  (11) mpplot   (graphic) : MAP WITH MARKERS                           [---]
;  (12) tawplot  (graphic) : TREND LINE PLOT                            [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/04/2012)
;******************************************************************************

undef("plot_scatter_viirs_aeronet")
procedure plot_scatter_viirs_aeronet \
                       (wks      :graphic,  sitename :string,   \ ; INPUT
                        ndim     :integer,  sitem    :integer,  \ ; INPUT
                        data1    :float,    data2    :float,    \ ; INPUT
                        data3    :float,    data4    :float,    \ ; INPUT
                        data5    :float,    data6    :float,    \ ; INPUT
                        mpplot   :graphic,                      \ ; INPUT
                        plot     :graphic)

begin
;  SET UP THE POSITION OF THE SCATTER PLOT
   vres                  = True
   vres@vpWidthF         = 0.7
   vres@vpHeightF        = 0.35
   vres@vpXF             = 0.15
   vres@vpYF             = 0.85
   vres@gsnDraw          = False
   vres@gsnFrame         = False
   xmax                  = 0.5
   xmin                  = 0.0
   vres@trXMaxF          = xmax
   vres@trXMinF          = xmin
   ymax                  = 1.0
   ymin                  = 0.0
   vres@trYMaxF          = ymax
   vres@trYMinF          = ymin
   vres@tmXBMajorLengthF       = 0.01
   vres@tmXBMinorLengthF       = 0.005
   vres@tmXBMajorOutwardLengthF= 0.0
   vres@tmXBMinorOutwardLengthF= 0.0
   vres@tmXTMajorLengthF       = 0.01
   vres@tmXTMinorLengthF       = 0.005
   vres@tmXTMajorOutwardLengthF= 0.0 
   vres@tmXTMinorOutwardLengthF= 0.0 
   vres@tmYLMajorLengthF       = 0.01
   vres@tmYLMinorLengthF       = 0.005
   vres@tmYLMajorOutwardLengthF= 0.0
   vres@tmYLMinorOutwardLengthF= 0.0
   vres@tmYRMajorLengthF       = 0.01
   vres@tmYRMinorLengthF       = 0.005 
   vres@tmYRMajorOutwardLengthF= 0.0
   vres@tmYRMinorOutwardLengthF= 0.0

;  SET RESOURCES FOR SCATTER PLOT
   res                   = True
   res                   = vres
   res@xyDashPatterns    = 1
   res@xyMarkLineModes   = (/"Markers"/)
   res@xyMarkers         = 16
   res@xyMarkerSizes     = 6
   res@xyMarkerColors    = "Blue"

;  SET TITLE RESOURCES
   res@tiMainString      = "VIIRS VS AERONET (Feb 2012) " + sitename
   res@tiYAxisString     = "VIIRS (550 nm)"
   res@tiXAxisString     = "AERONET (550 nm)"
   
;  CALCULATE CORRELATION
;  DEFINE LOCAL ARRAY
   if (.not.all(ismissing(data1(:, sitem))) .and. \
       .not.all(ismissing(data2))) then
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
    data!1    = "VIIRS"
    ecr       = esccr(data1(:, sitem),data2,0)
    prob      = rtest(ecr,ndim,0)
    rc        = regline(data1(:, sitem),data2)
    cor       = correlation(data1(:, sitem), data2)
    tdata(0,:)= data2
    tdata(1,:)= rc*(data1(:, sitem)-rc@xave) + rc@yave
    tdata(1,0)= rc*(xmin-rc@xave) + rc@yave
    tdata(1,1)= rc*(xmax-rc@xave) + rc@yave
;  CALCULATE RMSE
    ndata1    = onedtond(data1(:, sitem), (/dim, dim/))
    ndata2    = onedtond(data2, (/dim, dim/))
    rmse      = wgt_arearmse(ndata1, ndata2, 1.0, 1.0, 0)

;  SET UP TEXT RESOURCES
    tres               = True
    tres@txFontHeightF = 0.015
    gsn_text_ndc(wks,"y = ", 0.23, 0.82, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc), 0.27, 0.82, tres)
    gsn_text_ndc(wks,"x + ", 0.32, 0.82, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc@yave-rc*rc@xave), 0.36, 0.82, tres)
    gsn_text_ndc(wks,"R = ", 0.23, 0.80, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.27, 0.80, tres)
    gsn_text_ndc(wks,"N = ", 0.23, 0.78,tres)
    gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.26, 0.78,tres)
    gsn_text_ndc(wks,"RMSE = ", 0.36, 0.78,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rmse), 0.43, 0.78,tres)
    gsn_text_ndc(wks,"AERONET : ", 0.268, 0.76,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.35, 0.76,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.76,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.42, 0.76,tres)
    gsn_text_ndc(wks,"VIIRS   : ", 0.27, 0.74,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.35, 0.74,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.74,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.42, 0.74,tres)
   end if
   draw(mpplot)
   tawplot = gsn_csm_xy(wks, data1(:,sitem), data2,res)

;  OVERPLOT REGLINE AND DIAGONAL LINE
   xnew  = (/xmin, xmax/)
   ynew  = (/ymin, ymax/)
   rynew = (/tdata(1,0), tdata(1,1)/)
   tynew = (/ynew, rynew/)
;  SET UP RESOURCES OF LINE PLOT
   lres                   = True
   lres                   = vres
   lres@xyDashPatterns    = (/1, 0/)
   lres@xyLineThicknesses = (/1.0, 2.0/)
   lres@xyLineColors      = (/"black", "black"/)
   lplot = gsn_csm_xy(wks, xnew, tynew, lres)

;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres1                       = True
   eres1@gsLineColor           = "Red"
   eres1@gsLineThicknessF      = 1.0
;  ERROR BAR FACTOR
   xbar                        = 0.02
   xbar_length                 = xbar*xmax
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres2                       = True
   eres2@gsLineColor           = "blue"
   eres2@gsLineThicknessF      = 1.0
;  ERROR BAR FACTOR
   ybar                        = 0.005
   ybar_length                 = ybar*ymax
;  PLOT ERROR BAR
    do j = 0, ndim-1
     k = j + 1
     if(.not.ismissing(data1(j,sitem)) .and. \
        .not.ismissing(data2(j))       .and. \
        .not.ismissing(data3(j,sitem))) then
      gsn_polyline(wks, tawplot, (/data1(j, sitem), data1(j, sitem)-data3(j,sitem)/), \
                                 (/data2(j), data2(j)/), eres1)

      gsn_polyline(wks, tawplot, (/data1(j, sitem)-data3(j,sitem), data1(j, sitem)-data3(j,sitem)/), \
                                 (/data2(j)-xbar_length, data2(j)+xbar_length/), eres1)

      gsn_polyline(wks, tawplot, (/data1(j, sitem), data1(j, sitem)+data3(j,sitem)/), \
                                 (/data2(j), data2(j)/), eres1)

      gsn_polyline(wks, tawplot, (/data1(j, sitem)+data3(j,sitem), data1(j, sitem)+data3(j,sitem)/), \
                                 (/data2(j)-xbar_length, data2(j)+xbar_length/), eres1)
     end if
     if(.not.ismissing(data1(j,sitem)) .and. \
        .not.ismissing(data2(j))       .and. \
        .not.ismissing(data4(j))) then
      gsn_polyline(wks, tawplot, (/data1(j, sitem), data1(j, sitem)/), \
                                 (/data2(j), data2(j)-data4(j)/), eres2)
      gsn_polyline(wks, tawplot, (/data1(j, sitem)-ybar_length, data1(j, sitem)+ybar_length/), \
                                 (/data2(j)-data4(j), data2(j)-data4(j)/), eres2)
      gsn_polyline(wks, tawplot, (/data1(j, sitem), data1(j, sitem)/), \
                                 (/data2(j), data2(j)+data4(j)/), eres2)
      gsn_polyline(wks, tawplot, (/data1(j, sitem)-ybar_length, data1(j, sitem)+ybar_length/), \
                                 (/data2(j)+data4(j), data2(j)+data4(j)/), eres2)
     end if
    end do

   draw(tawplot)
   overlay(mpplot, tawplot)
   draw(lplot)
   frame(wks)
   delete([/vres, res, lres, tres, eres1, eres2/])

return
end
