;  $ID: plot_scatter_lwp_alt_reg.ncl 06/23/2015 15:22 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_lwp_alt_pl.ncl PLOTS SCATTER PLOT FOR TWO 
;  VARIABLES WITH VARIOUS DIMENSIONS, AND ADDS REGRESSION LINE WITH STATISTICAL
;  VARIABLES
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (workstation):WORK STATION                               [   ]
;  (2 ) stime    (a string)   :ATTRIBUTES                                 [   ]
;  (3 ) data1    (multi-D)    :DATA FOR X AXIS                            [   ]
;  (4 ) data2    (multi-D)    :DATA FOR Y AXIS                            [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/23/2015)
;******************************************************************************
undef("plot_scatter_lwp_alt_reg")
procedure plot_scatter_lwp_alt_reg \
          (wks       :graphic,  stime        :string,   \;INPUT
           data1     :numeric,  data2        :numeric)   ;INPUT

begin

   oned_data1 = ndtooned(data1)
   oned_data2 = ndtooned(data2)

;  SET UP THE POSITION OF THE SCATTER PLOT
   vres                        = True
   vres@vpWidthF               = 0.7
   vres@vpHeightF              = 0.7
   vres@vpXF                   = 0.15
   vres@vpYF                   = 0.85
   vres@gsnDraw                = False
   vres@gsnFrame               = False
   xmin                        = 1.0
   xmax                        = 300.0
   vres@trXMaxF                = xmax
   vres@trXMinF                = xmin
   ymin                        = 0.0
   ymax                        = 5.0
   vres@trYMaxF                = ymax
   vres@trYMinF                = ymin
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
   res@xyMarkLineModes   = (/"Markers", "Lines"/)
   res@xyMarkers         = 16
   res@xyMarkerSizes     = 6
   res@xyMarkerColor     = (/"Blue"/)
   res@xyLineThicknessF  = 5
   res@xyLineColor       = (/"Red"/)

;  SET TITLE RESOURCES
   res@tiMainString      =  stime
   res@tiYAxisString     = "Altitude Difference (km)"
   res@tiXAxisString     = "Cloud Liquid Water (g/m~S~2~N~)"

   if (.not.all(ismissing(oned_data1)) .and. \
       .not.all(ismissing(oned_data1))) then
;  CALCULATE STATISTIS BEWTEEN data1 AND data2
   rc   = regline(oned_data1, oned_data2)
   cor  = correlation(oned_data1, oned_data2)
   df   = rc@nptxy-2
   prob = (1 - betainc(df/(df+rc@tval^2), df/2.0, 0.5) ) ;  also: prob = cdft_p(rc@tval,df)
   yReg = rc*oned_data1 + rc@yintercept
   oned_data3 = (/oned_data2, yReg/)
   
   plot = gsn_csm_xy(wks, oned_data1, oned_data3, res)
;  DRAW Y AVERAGE AS A HORIZONTAL LINE
   lres                  = True
   lres@gsLineColor      = "Blue"
   lres@gsLineThicknessF = 5.0
   if (.not.all(ismissing(oned_data2)))
      data2_avg = avg(oned_data2)
      dum       = gsn_add_polyline(wks, plot, (/0, xmax/), (/data2_avg, data2_avg/), lres)
   end if

;  ADD STATISTICS INFO ON THE PLOT
;  SET UP TEXT RESOURCES
   tres               = True
   tres@txFontHeightF = 0.018
   gsn_text_ndc(wks,"Y = ", 0.23, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%7.4f", rc), 0.29, 0.82, tres)
   gsn_text_ndc(wks,"X + ", 0.36, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", rc@yintercept), 0.40, 0.82, tres)
   gsn_text_ndc(wks,"R = ", 0.23, 0.79, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.28, 0.79, tres)
   gsn_text_ndc(wks,"N = ", 0.23, 0.76,tres)
   gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.28, 0.76,tres)
   draw(plot)
   frame(wks)
   end if
end
