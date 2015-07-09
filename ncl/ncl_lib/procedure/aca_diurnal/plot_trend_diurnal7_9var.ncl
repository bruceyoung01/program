; $ID: plot_trend_diurnal7_9var.ncl V01 02/24/2013 16:39 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_diurnal7_9var IS USED TO PLOT THE TREND LINE 
;  USING ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS. THIS 
;  PROCEDURE CAN PLOT 9 VARIABLES WITHIN 9 LOOPS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks           (graphic):WORK STATION                             [   ]
;  (2 ) ivariable     (scalar) :VARIABLE                                 [   ]
;  (2 ) variable_name (1-D)    :NAME                                     [   ]
;  (3 ) data          (2-D)    :DATA                                     [   ]
;  (4 ) data_mean     (1-D)    :DATA MEAN                                [   ]
;  (5 ) nhour         (scalar) :TOTAL # OF HOURS                         [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (06/09/2012)
;  (5 ) MODIFIED FROM plot_trend_daily2_aod.ncl. (02/24/2013)
;  (6 ) MODIFIED FROM plot_trend_line_epa_diurnal.ncl. (09/15/2013)
;  (7 ) MODIFIED FROM plot_trend_diurnal7.ncl BY ADDING PLOTTING MORE VARIABLES
;       WITHIN 9 LOOPS. (BRUCE, 07/02/2015)
;******************************************************************************

undef("plot_trend_diurnal7_9var")
procedure plot_trend_diurnal7_9var \
         (wks           :graphic, ivariable  :integer, \;INPUT
          variable_name :string,                       \;INPUT
          data          :float,   data_mean  :float,   \;INPUT
          nhour         :integer)                       ;INPUT

begin

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.8
   res@vpHeightF               = 0.55
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   dashpatterns1              = (/0, 0, 0, 0, 0, 0, 0, 0, 0, 0/)
   dashpatterns               = (/2, 2, 2, 2, 2, 2, 2, 2, 2, 2/)
   markers                    = (/4, 4, 4, 4, 4, 4, 4, 4, 4, 4/)
   linecolors                 = (/"blue", "red", "pink", "purple", "green", \
                                  "gold4", "brown", "peru", "orange", "black"/)
   res@xyMarkLineMode         = "MarkLines"
   res@xyMarkers              = markers
   res@xyMarkerColors         = linecolors
   res@xyMarkerThicknessF     = 1.5
   res@xyMarkerSizeF          = 0.007
   res@xyDashPatterns         = dashpatterns1
   res@xyLineColors           = linecolors
   res@xyLineThicknessF       = 2.0

;  SET X AXIS LABELS
   x                           = ispan(1,nhour,1)
   xtick                       = (/"00", "01", "02", "03", "04", "05", \
                                   "06", "07", "08", "09", "10", "11", \
                                   "12", "13", "14", "15", "16", "17", \
                                   "18", "19", "20", "21", "22", "23" /)
   res@tmXBMode                = "Explicit"
   res@tmXBValues              = x(0:nhour-1:8)
   res@tmXBLabels              = xtick(0:23:2)
   res@trXMaxF                 = 97
   res@tmXBMajorLengthF        = 0.01
   res@tmXBMinorLengthF        = 0.005
   res@tmXBMajorOutwardLengthF = 0.0
   res@tmXBMinorOutwardLengthF = 0.0
   res@tmXBMinorValues         = ispan(2,nhour-1,1)
   res@tmYLMajorLengthF        = 0.01
   res@tmYLMinorLengthF        = 0.005
   res@tmYLMajorOutwardLengthF = 0.0
   res@tmYLMinorOutwardLengthF = 0.0

;  SET LEGEND
   res@pmLegendDisplayMode     = "Always"
   res@pmLegendSide            = "Top"
   res@pmLegendParallelPosF    = 0.15
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   res@pmLegendOrthogonalPosF  =-0.50
   res@pmLegendWidthF          = 0.12
   res@pmLegendHeightF         = 0.17
   res@lgLabelFontHeightF      = 0.013
   res@lgPerimOn               = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels  = variable_name
   res@tiXAxisString           = "Diurnal Variation (UTC)"
   res@tiMainString            = "ACA and Cloud Interaction"

;  SPECIFY RESOURSES CHANGING WITH VARIOUS VARIABLES
   if (ivariable .eq. 0) then
      res@trYMaxF                     = 10.0
      res@trYMinF                     = -30.0
      res@tiYAxisString               = "Latitude (Degree)"
      res@tmYMajorGrid                = True
      res@tmYMajorGridThicknessF      = 1.0
      res@tmYMajorGridLineDashPattern = 2
   else if (ivariable .eq. 1) then
      res@trYMaxF                     = 20.0
      res@trYMinF                     = -20.0
      res@tiYAxisString               = "Longitude (Degree)"
      res@tmYMajorGrid                = True
      res@tmYMajorGridThicknessF      = 1.0
      res@tmYMajorGridLineDashPattern = 2
   else if (ivariable .eq. 2) then
      res@trYMaxF              = 3.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Above Cloud Water Vapor (cm)"
   else if (ivariable .eq. 3) then
      res@trYMaxF              = 30.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Cloud Optical Thickness 16"
   else if (ivariable .eq. 4) then
      res@trYMaxF              = 5.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Cloud Optical Thickness 16 PCL"
   else if (ivariable .eq. 5) then
      res@trYMaxF              = 30.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Cloud Effective Radius 16 (~F33~m~F21~m)"
   else if (ivariable .eq. 6) then
      res@trYMaxF              = 30.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Cloud Effective Radius 16 PCL (~F33~m~F21~m)"
   else if (ivariable .eq. 7) then
      res@trYMaxF              = 300.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Cloud Water Path 16 (g/m~S~2~N~)"
   else if (ivariable .eq. 8) then
      res@trYMaxF              = 50.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Cloud Water Path 16 PCL (g/m~S~2~N~)"
   else if (ivariable .eq. 9) then
      res@trYMaxF              = 00.0
      res@trYMinF              = -90.0
      res@tiYAxisString        = "Cloud Top Temperature (~F34~0~F21~C)"
   else if (ivariable .eq.10) then
      res@trYMaxF              = 0.0
      res@trYMinF              = -10.0
      res@tiYAxisString        = "Surface Temperature (K)"
   else if (ivariable .eq.11) then
      res@trYMaxF              = 5.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Aerosol Base Altitude (km)"
   else if (ivariable .eq.12) then
      res@trYMaxF              = 5.0
      res@trYMinF              = 0.0
      res@tiYAxisString        = "Cloud Top Altitude (km)"
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if

   plot   = gsn_csm_xy(wks, x, data, res)

;  OVER PLOT MONTHLY AVERAGE
   eres                   = True
   eres                   = eres
   ndim                   = dimsizes(data_mean)
   
   do i = 0, ndim-1
      eres@gsLineDashPattern = dashpatterns(i)
      eres@gsLineColor       = linecolors(i)
      if (.not.all(ismissing(data_mean(i)))) then
         gsn_polyline(wks, plot, (/x(i), x(nhour-1)/), \
                              (/data_mean(i), data_mean(i)/), eres)
      end if
   end do

   draw(plot)
   frame(wks)
return
end
