;  $ID: plot_scatter_lwp_aba.ncl 06/23/2015 15:22 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_lwp_aba.ncl PLOTS SCATTER PLOT FOR TWO VARIABLES WITH 
;  VARIOUS DIMENSIONS.
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
undef("plot_scatter_lwp_aba")
procedure plot_scatter_lwp_aba \
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
   xmax                        = 300.0
   vres@trXMaxF                = xmax
   vres@trXMinF                = xmin
   ymin                        = 0.0
   ymax                        = 20.0
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
   res@xyMarkLineModes   = (/"Markers"/)
   res@xyMarkers         = 16
   res@xyMarkerSizes     = 6
   res@xyMarkerColors    = "Blue"

;  SET TITLE RESOURCES
   res@tiMainString      =  stime
   res@tiYAxisString     = "Aerosol Base Altitude (km)"
   res@tiXAxisString     = "Cloud Liquid Water (g/m~S~2~N~)"

   plot = gsn_csm_xy(wks, oned_data1, oned_data2,res)
   draw(plot)
   frame(wks)

end
