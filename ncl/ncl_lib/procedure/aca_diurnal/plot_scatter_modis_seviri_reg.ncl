;  $ID: plot_scatter_modis_seviri_reg.ncl 07/21/2015 22:24 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_modis_seviri_reg.ncl PLOTS SCATTER PLOT FOR TWO 
;  VARIABLES WITH VARIOUS DIMENSIONS, AND ADDS REGRESSION LINE WITH STATISTICAL
;  VARIABLES
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (workstation):WORK STATION                               [   ]
;  (2 ) stime    (a string)   :ATTRIBUTES                                 [   ]
;  (3 ) ivariable(scalar)     :VARIABLE INDEX                             [   ]
;  (4 ) data1    (multi-D)    :DATA FOR X AXIS                            [   ]
;  (5 ) data2    (multi-D)    :DATA FOR Y AXIS                            [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/23/2015)
;******************************************************************************
undef("plot_scatter_modis_seviri_reg")
procedure plot_scatter_modis_seviri_reg \
          (wks       :graphic,  stime        :string,   \;INPUT
           ivariable :integer,                          \;INPUT
           data1     :numeric,  data2        :numeric)   ;INPUT

begin

   oned_data1 = ndtooned(data1)
   oned_data2 = ndtooned(data2)

;  SET UP THE POSITION OF THE SCATTER PLOT
   res                        = True
   res@vpWidthF               = 0.7
   res@vpHeightF              = 0.7
   res@vpXF                   = 0.15
   res@vpYF                   = 0.85
   res@gsnDraw                = False
   res@gsnFrame               = False
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

;  SET RESOURCES FOR SCATTER PLOT
   res@xyDashPatterns    = 1
   res@xyMarkLineModes   = (/"Markers", "Lines"/)
   res@xyMarkers         = 16
   res@xyMarkerSizes     = 6
   res@xyMarkerColor     = (/"Blue"/)
   res@xyLineThicknessF  = 5
   res@xyLineColor       = (/"Red"/)

;  SET TITLE RESOURCES
   res@tiYAxisString     = "SEVIRI"
   res@tiXAxisString     = "MODIS"

   if (ivariable .eq. 2) then
      vmin          = 0.0
      vmax          = 5.0
      variable_name = "Above Cloud Water Vapor (cm)"
   else if (ivariable .eq. 3) then
      vmin          = 0.0
      vmax          = 100.0
      variable_name = "Cloud Optical Thickness"
   else if (ivariable .eq. 4) then
      vmin          = 0.0
      vmax          = 50.0
      variable_name = "Cloud Effective Radius (~F33~m~F21~m)"
   else if (ivariable .eq. 5) then
      vmin          = 0.0
      vmax          = 500.0
      variable_name = "Cloud Water Path (g/m~S~2~N~)"
   else if (ivariable .eq. 6) then
      vmin          = 100.0
      vmax          = 1000.0
      variable_name = "Cloud Top Pressue (hPa)"
      res@trXReverse= True
      res@trYReverse= True
   else if (ivariable .eq. 7) then
      vmin          = 0.0
      vmax          = 18000.0
      variable_name = "Cloud Top Height (m)"
   else if (ivariable .eq. 8) then
      vmin          = -50.0
      vmax          = 0.0
      variable_name = "Cloud Top Temperature (~F34~0~F21~C)"
   end if
   end if
   end if
   end if
   end if
   end if
   end if

   res@trXMaxF                = vmax
   res@trXMinF                = vmin
   res@trYMaxF                = vmax
   res@trYMinF                = vmin
   res@tiMainString           = stime + " " + variable_name

   if (.not.all(ismissing(oned_data1)) .and. \
       .not.all(ismissing(oned_data1))) then
;  CALCULATE STATISTIS BEWTEEN data1 AND data2
   rc   = regline_stats(oned_data1, oned_data2)
   df   = rc@r2
   yReg = rc*oned_data1 + rc@yintercept
   oned_data3 = (/oned_data2, yReg/)
   
   plot = gsn_csm_xy(wks, oned_data1, oned_data3, res)

;  DRAW Y AVERAGE AS A HORIZONTAL LINE
   lres                  = True
   lres@gsLineColor      = "black"
   lres@gsLineDashPattern= 1
   lres@gsLineThicknessF = 5.0
   dum = gsn_add_polyline(wks, plot, (/vmin, vmax/), (/vmin, vmax/), lres)

;  ADD STATISTICS INFO ON THE PLOT
;  SET UP TEXT RESOURCES
   tres               = True
   tres@txFontHeightF = 0.018
   gsn_text_ndc(wks,"Y = ", 0.23, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%7.4f", rc), 0.29, 0.82, tres)
   if (rc@yintercept .ge. 0.0) then
      gsn_text_ndc(wks,"X + ", 0.36, 0.82, tres)
   else if (rc@yintercept .lt. 0.0) then
      gsn_text_ndc(wks,"X ", 0.36, 0.82, tres)
   end if
   end if
   gsn_text_ndc(wks,sprintf("%5.2f", rc@yintercept), 0.42, 0.82, tres)
   gsn_text_ndc(wks,"R~S~2~N~ = ", 0.23, 0.79, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", df), 0.28, 0.79, tres)
   gsn_text_ndc(wks,"N = ", 0.23, 0.76,tres)
   gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.28, 0.76,tres)
   draw(plot)
   frame(wks)
   end if
end
