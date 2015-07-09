; $ID: plot_profile_errorbar_count_method2.ncl V01 06/03/2015 21:24 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_profile_errorbar_count_method2 PLOTS DATA VERTICAL PROFILE WITH 
;  ERROR BAR.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/03/2015)
;******************************************************************************

undef("plot_profile_errorbar_count_method2")
procedure plot_profile_errorbar_count_method2 \
          (wks       :graphic, bv2    :float,   \ ; INPUT
           xbnd      :float,   ybnd   :float,   \ ; INPUT
           data      :numeric)

begin
;  CALCULATE AVERAGE AND STANDARD DIVIATION
   ndim        = dimsizes(data)
   data_avg    = new((/ndim(0)/), float, bv2)
   data_avg    = 0.0
   data_stddev = new((/ndim(0)/), float, bv2)
   data_stddev = 0.0
   data_allavg = avg(data)
   do i = 0, ndim(0)-1
      if (.not.all(ismissing(data(i, :)))) then
         data_avg(i) = sum(data(i, :))
      end if
      if (.not.all(ismissing(data(i, :)))) then
         data_stddev(i) = stddev(data(i, :))
      end if
   end do

   nx = dimsizes(xbnd)
   ny = dimsizes(ybnd)

;  SET UP RESOURCES ERROR BAR PLOT
   res                      = True
   res@xyLineColor          = "blue"
   res@xyLineThicknessF     = 5.0
   res@tmXBMode             = "Manual"
   res@trXMinF              = 0
   res@trXMaxF              = 50
   res@tmXBTickSpacingF     = 25
   res@tmXBLabelFontHeightF = 0.018
   res@tmXBFormat           = "f"
   res@tmXBMinorOn          = True
   res@tmXTMinorOn          = False

   res@trYMinF              = -0.5
   res@trYMaxF              =  ny-0.5
   res@trYReverse           = True           ; reverses y-axis

   y = fspan(res@trYMinF,res@trYMaxF, ny)
   res@tmYLMode             = "Explicit"                ; explicit labels
   res@tmYLValues           = y
   res@tmYLLabels           = ybnd

   res@tiXAxisString        = "Count"
   res@tiYAxisString        = "CTP [hPa]"
   res@tiXAxisFontHeightF   = 0.025
   res@tiYAxisFontHeightF   = 0.025

;  SET UP THE POSITION OF THE MAP             NORMAL ; WIDER
   res@vpWidthF             = 0.10 ; 0.20   ; 0.15
   res@vpHeightF            = 0.78 ; 0.20   ; 0.15
   res@vpXF                 = 0.13 ; 0.57   ; 0.67
   res@vpYF                 = 0.92 ; 0.80   ; 0.85
   res@gsnDraw              = False
   res@gsnFrame             = False

   y_half   = y + 0.5
   plot     = gsn_csm_xy(wks, data_avg, y_half(0:ny-2), res)

;----------------------------------------------------------------------
; SET UP RESOURCES OF ERROR BAR
   pres                     = True
   pres@gsLineColor         = "Red"
   pres@gsLineThicknessF    = 5.0
   bar_length               = 0.05

; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
   do j = 0, ndim(0)-1
    if(.not.ismissing(data_avg(j)) .and. .not.ismissing(data_stddev(j)))then
    gsn_polyline(wks, plot, (/data_avg(j)-data_stddev(j), data_avg(j)+data_stddev(j)/), \
                            (/y_half(j), y_half(j)/), pres)
    gsn_polyline(wks, plot, (/data_avg(j)+data_stddev(j), data_avg(j)+data_stddev(j)/), \
                            (/y_half(j)-bar_length, y_half(j)+bar_length/), pres)
    gsn_polyline(wks, plot, (/data_avg(j)-data_stddev(j), data_avg(j)-data_stddev(j)/), \
                            (/y_half(j)-bar_length, y_half(j)+bar_length/), pres)
    end if
   end do
   draw(plot)
   frame(wks)
end
