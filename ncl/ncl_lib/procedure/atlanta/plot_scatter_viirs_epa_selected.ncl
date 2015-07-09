; $ID: plot_scatter_viirs_epa_selected.ncl V01 02/27/2013 11:33 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_viirs_epa_selected PLOTS SCATTER PLOT WITH 
;  CORRELATION INFO.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic) : WORK STATION                               [---]
;  (2 ) ndim     (integer) : # OF TOTAL DAYS                            [---]
;  (3 ) time      (string) : TIME                                       [---]
;  (4 ) data1      (float) : VIIRS OBSERVATION DATA                     [---]
;  (5 ) data2      (float) : SELETED OBSERVED DATA                      [---]
;  (6 ) tawplot  (graphic) : SCATTER PLOT                               [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/19/2012)
;  (2 ) MODIFIED FROM plot_scatter_modis_viirs.ncl. (06/19/2012)
;  (3 ) MODIFIED FROM plot_scatter_viirs_site.ncl. (02/06/2013)
;  (4 ) MODIFIED FROM plot_scatter_viirs_epa.ncl. (02/27/2013)
;******************************************************************************

undef("plot_scatter_viirs_epa_selected")
procedure plot_scatter_viirs_epa_selected \
                       (wks      :graphic,  site_id  :string,   \; INPUT
                        bv2      :float,                        \; INPUT
                        data1    :float,    data2    :float,    \; INPUT
                        data3    :float,    data4    :float)     ; INPUT

begin
;  DEFINE TWO ZERO ARRAY TO PLOT XY COORDINATES
   x  = new((/2/), float, bv2)
   y  = new((/2/), float, bv2)
   x  = 0.0
   y  = 0.0

;  IGNORE SMALL AND NAGETIVE VALUE
   index2 = ind(data1 .gt.  100.0 .or. \
                data1 .lt. -100.0)
   if (.not.all(ismissing(index2))) then
    data1(index2) = bv2
   end if
;  SELECT DATA WITH MOON AND WITHOUT MOON
;  index1 = ind(data3 .lt. 120.0)
;  if (.not.all(ismissing(index1))) then
;   data1(index1) = bv2
;  end if
printMinMax(data1, True)
printMinMax(data2, True)

;  SET UP THE POSITION OF THE SCATTER PLOT
   vres                  = True
   vres@vpWidthF         = 0.5
   vres@vpHeightF        = 0.45
   vres@vpXF             = 0.25
   vres@vpYF             = 0.85
   vres@gsnDraw          = False
   vres@gsnFrame         = False
   xmax                  =  100.0
   xmin                  =  0.0
   vres@trXMaxF          = xmax
   vres@trXMinF          = xmin
   ymax                  =  5.0
   ymin                  = -5.0
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
   res@xyMarkers         = 1
   res@xyMarkerSizes     = 0.01
   res@xyMarkerColors    = "Black"

;  SET TITLE RESOURCES
   res@tiMainString      = "VIIRS vs EPA Hourly W Moon " + site_id
   res@tiXAxisString     = "EPA PM~B~2.5~N~/cos(~F8~q~F21~)(~F33~m~F21~g/m~S~3~N~)"
   res@tiYAxisString     = "Log(VIIRS DNB radiance) (Wm~S~-2~N~str~S~-1~N~~F33~m~F21~m~S~-1~N~)"
   plot = gsn_csm_xy(wks, x, y,res)

;  ADD POLYMARKER TO THE PLOT
   ndim = dimsizes(data1)
   cres                    =  True
   cres@gsMarkerSizeF      =  0.015
   cres@gsMarkerThicknessF =  2.2
   cres@tfPolyDrawOrder    = "PreDraw"
;  DO THE POINT LOOP TO ADD DOTS ON THE PLOT
   do i = 0, ndim-1
    if (.not.ismissing(data1(i)) .and. \
        .not.ismissing(data2(i))) then
     if (data3(i) .lt. 120.0 .and. \
         data4(i) .lt. 90.0) then
      cres@gsMarkerColor = "Blue"
      cres@gsMarkerIndex =  4
     else if (data3(i) .lt. 120.0 .and. \
              data4(i) .ge. 90.0) then
      cres@gsMarkerColor = "Blue"
      cres@gsMarkerIndex =  12
     else if (data3(i) .ge. 120.0 .and. \
              data4(i) .lt. 90.0) then
      cres@gsMarkerColor = "Red"
      cres@gsMarkerIndex =  4
     else if (data3(i) .ge. 120.0 .and. \
              data4(i) .ge. 90.0) then
      cres@gsMarkerColor = "Red"
      cres@gsMarkerIndex =  12
     end if
     end if
     end if
     end if
     gsn_polymarker(wks, plot, data1(i), data2(i), cres)
    end if
   end do

;  ADD LABEL BAR FOR COLOR-CODED
   tres1                   = True
   tres1@txFontHeightF     = 0.015
   cres1                   = True
   cres1                   = cres
   cres1@gsMarkerColor     = "Blue"
   cres1@gsMarkerIndex     =  4
   gsn_polymarker_ndc(wks, 0.53, 0.82, cres1)
   gsn_text_ndc(wks, "~F8~h~F21~ < 120~S~o~N~ ~F8~q~F21~~B~0~N~ < 90~S~o~N~", 0.64, 0.82, tres1)
   cres2                   = True
   cres2                   = cres
   cres2@gsMarkerColor     = "Blue"
   cres2@gsMarkerIndex     =  12
   gsn_polymarker_ndc(wks, 0.53, 0.80, cres2)
   gsn_text_ndc(wks, "~F8~h~F21~ < 120~S~o~N~ ~F8~q~F21~~B~0~N~ > 90~S~o~N~", 0.64, 0.80, tres1)
   cres3                   = True
   cres3                   = cres
   cres3@gsMarkerColor     = "Red"
   cres3@gsMarkerIndex     =  4
   gsn_polymarker_ndc(wks, 0.53, 0.78, cres3)
   gsn_text_ndc(wks, "~F8~h~F21~ > 120~S~o~N~ ~F8~q~F21~~B~0~N~ < 90~S~o~N~", 0.64, 0.78, tres1)
   cres4                   = True
   cres4                   = cres
   cres4@gsMarkerColor     = "Red"
   cres4@gsMarkerIndex     =  12
   gsn_polymarker_ndc(wks, 0.53, 0.76, cres4)
   gsn_text_ndc(wks, "~F8~h~F21~ > 120~S~o~N~ ~F8~q~F21~~B~0~N~ > 90~S~o~N~", 0.64, 0.76, tres1)

;  CALCULATE CORRELATION
;  DEFINE LOCAL ARRAY
   if (.not.all(ismissing(data1)) .and. \
       .not.all(ismissing(data2))) then
    data      = new((/2, ndim/), float)
    tdata     = new((/2, ndim/), float)
    data(0,:) = data1
    data(1,:) = data2
    avgdata1  = avg(data1)
    avgdata2  = avg(data2)
    stddata1  = dim_stddev_n(data1, 0)
    stddata2  = dim_stddev_n(data2, 0)
    data!0    = "EPA"
    data!1    = "VIIRS"
    ecr       = esccr(data1, data2, 0)
    prob      = rtest(ecr, ndim, 0)
    rc        = regline(data1, data2)
    cor       = correlation(data1, data2)
    tdata(0,:)= data2
    tdata(1,:)= rc*(data1-rc@xave) + rc@yave
    tdata(1,0)= rc*(xmin-rc@xave)  + rc@yave
    tdata(1,1)= rc*(xmax-rc@xave)  + rc@yave

;  CALCULATE RMSE
    ndata1    = onedtond(data1, (/ndim, ndim/))
    ndata2    = onedtond(data2, (/ndim, ndim/))
    rmse      = wgt_arearmse(ndata1, ndata2, 1.0, 1.0, 0)

;  SET UP TEXT RESOURCES
    tres               = True
    tres@txFontHeightF = 0.015
    gsn_text_ndc(wks,"Y = ", 0.28, 0.82, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc), 0.32, 0.82, tres)
    gsn_text_ndc(wks,"X + ", 0.37, 0.82, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc@yave-rc*rc@xave), 0.42, 0.82, tres)
    gsn_text_ndc(wks,"R = ", 0.28, 0.80, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.32, 0.80, tres)
    gsn_text_ndc(wks,"N = ", 0.28, 0.78,tres)
    gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.31, 0.78,tres)
;   gsn_text_ndc(wks,"RMSE = ", 0.28, 0.78,tres)
;   gsn_text_ndc(wks,sprintf("%5.2f", rmse), 0.33, 0.78,tres)
    gsn_text_ndc(wks,"EPA         : ", 0.316, 0.76,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.40, 0.76,tres)
    gsn_text_ndc(wks,"~F34~1", 0.43, 0.76,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.48, 0.76,tres)
    gsn_text_ndc(wks,"VIIRS      : ", 0.316, 0.74,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.40, 0.74,tres)
    gsn_text_ndc(wks,"~F34~1", 0.43, 0.74,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.48, 0.74,tres)

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
    lres@xyLineColors      = (/"black", "red"/)
    lplot = gsn_csm_xy(wks, xnew, tynew, lres)
    draw(plot)
    draw(lplot)
    frame(wks)
    delete([/vres, res, tres, lres/])
   end if
return
end
