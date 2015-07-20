;  $ID: plot_scatter_seviri_caliop_reg_option.ncl 07/15/2015 09:10 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_seviri_caliop_reg_option.ncl PLOTS SCATTER PLOT FOR TWO 
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
undef("plot_scatter_seviri_caliop_reg_option")
procedure plot_scatter_seviri_caliop_reg_option \
          (wks        :graphic,  stime        :string,   \;INPUT
           xtick_name :string,   ytick_name   :string,   \;INPUT
           xmin       :numeric,  xmax         :numeric,  \;INPUT
           ymin       :numeric,  ymax         :numeric,  \;INPUT
           data1      :numeric,  data2        :numeric)   ;INPUT

begin

   oned_data1 = ndtooned(data1)
   oned_data2 = ndtooned(data2)

;  SET UP THE POSITION OF THE SCATTER PLOT
   res                        = True
   res@vpWidthF               = 0.7
   res@vpHeightF              = 0.7
   res@vpXF                   = 0.20
   res@vpYF                   = 0.85
   res@gsnDraw                = False
   res@gsnFrame               = False
   res@trXMaxF                = xmax
   res@trXMinF                = xmin
   res@trYMaxF                = ymax
   res@trYMinF                = ymin
   res@tmXBMajorLengthF       = 0.01
   res@tmXBMinorLengthF       = 0.005
   res@tmXBMajorOutwardLengthF= 0.0
   res@tmXBMinorOutwardLengthF= 0.0
   res@tmXTMajorLengthF       = 0.01
   res@tmXTMinorLengthF       = 0.005
   res@tmXTMajorOutwardLengthF= 0.0
   res@tmXTMinorOutwardLengthF= 0.0
   res@tmYLMajorLengthF       = 0.01
   res@tmYLMinorLengthF       = 0.005
   res@tmYLMajorOutwardLengthF= 0.0
   res@tmYLMinorOutwardLengthF= 0.0
   res@tmYRMajorLengthF       = 0.01
   res@tmYRMinorLengthF       = 0.005
   res@tmYRMajorOutwardLengthF= 0.0
   res@tmYRMinorOutwardLengthF= 0.0
   res@xyXStyle               = "Log"
   res@xyYStyle               = "Log"
;  SET RESOURCES FOR SCATTER PLOT
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
   res@tiXAxisString     = xtick_name
   res@tiYAxisString     = ytick_name

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
   gsn_text_ndc(wks,"Y   = ", 0.285, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", rc), 0.35, 0.82, tres)
   gsn_text_ndc(wks,"X + ", 0.40, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", rc@yintercept), 0.45, 0.82, tres)
   gsn_text_ndc(wks,"R~S~2~N~ = ", 0.285, 0.79, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.335, 0.79, tres)
   gsn_text_ndc(wks,"N   = ", 0.285, 0.76,tres)
   gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.335, 0.76,tres)
   draw(plot)
   frame(wks)
   end if
end
