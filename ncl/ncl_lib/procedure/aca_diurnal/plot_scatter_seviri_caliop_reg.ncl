;  $ID: plot_scatter_seviri_caliop_reg.ncl 07/15/2015 09:10 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_seviri_caliop_reg.ncl PLOTS SCATTER PLOT FOR TWO 
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
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/15/2015)
;******************************************************************************
undef("plot_scatter_seviri_caliop_reg")
procedure plot_scatter_seviri_caliop_reg \
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
   xmin                        = 0.0
   xmax                        = 1.0
   vres@trXMaxF                = xmax
   vres@trXMinF                = xmin
   ymin                        = 0.0
   ymax                        = 50.0
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
   res@tiMainFontHeightF = 0.015
   res@tiMainString      = stime
   res@tiYAxisString     = "CER"
   res@tiXAxisString     = "AOD"

   if (.not.all(ismissing(oned_data1)) .and. \
       .not.all(ismissing(oned_data1))) then
;  CALCULATE STATISTIS BEWTEEN data1 AND data2
   rc   = regline_stats(oned_data1, oned_data2)
   cor  = rc@r2
   yreg = rc*oned_data1 + rc@yintercept
   
   plot = gsn_csm_xy(wks, oned_data1, oned_data2, res)
;  DRAW REGRESSION LINE
   lres                  = True
   lres@gsLineColor      = "Red"
   lres@gsLineThicknessF = 5.0
   if (.not.all(ismissing(oned_data2)))
      yregmin = rc*xmin + rc@yintercept
      yregmax = rc*xmax + rc@yintercept
      dum     = gsn_add_polyline(wks, plot, (/xmin, xmax/), (/yregmin, yregmax/), lres)
   end if

;  ADD STATISTICS INFO ON THE PLOT
;  SET UP TEXT RESOURCES
   tres               = True
   tres@txFontHeightF = 0.018
   gsn_text_ndc(wks,"Y   = ", 0.235, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%7.4f", rc), 0.31, 0.82, tres)
   gsn_text_ndc(wks,"X + ", 0.38, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", rc@yintercept), 0.43, 0.82, tres)
   gsn_text_ndc(wks,"R~S~2~N~ = ", 0.235, 0.79, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.285, 0.79, tres)
   gsn_text_ndc(wks,"N   = ", 0.235, 0.76,tres)
   gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.285, 0.76,tres)
   draw(plot)
   frame(wks)
   end if
end
