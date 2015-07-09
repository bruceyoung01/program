; $ID: plot_trend_line_epa_diurnal_all.ncl V01 02/24/2013 16:39 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_line_epa_diurnal_all IS USED TO PLOT THE TREND LINE 
;  USING ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) sitename   (string)  : AERONET SITE NAME                        [---]
;  (3 ) data1      (float)   : EPA OBSERVATION DATA                     [---]
;  (4 ) data2      (float)   : EPA OBSERVATION DATA STANDARD DEVIATION  [---]
;  (5 ) data3      (float)   : EPA OBSERVATION DATA TOTAL AVERAGE       [---]
;  (6 ) nhour      (integer) : TOTAL # OF FMF OBSERVATION HOURS         [---]
;  (7 ) plot       (graphic) : TREND LINE PLOT                          [---]
;  (8 ) plot1      (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (06/09/2012)
;  (5 ) MODIFIED FROM plot_trend_daily2_aod.ncl. (02/24/2013)
;******************************************************************************

undef("plot_trend_line_epa_diurnal_all")
procedure plot_trend_line_epa_diurnal_all \
         (wks    :graphic, sitename  :string,  \ ; INPUT
          data1  :float,   data2     :float,   \ ; INPUT
          data3  :float,   nhour     :integer, \ ; INPUT
          marker :integer, linecolor :string,  \ ; INPUT
          plot   :graphic, plot1     :graphic)   ; OUTPUT

begin
   data = new((/nhour+1/), typeof(data1), -9999.)
   data(0:nhour-1) = data1

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.85
   res@vpHeightF               = 0.20
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res@xyMarkLineMode          = "MarkLines"
   res@xyMarkers               = marker
   res@xyMarkerSizes           = 5
   res@xyMarkerThicknessF      = 2.0
   res@xyMarkerColor           = linecolor
   res@xyLineColor             = linecolor
   res@xyDashPatterns          = 0
   res@xyLineThicknessF        = 2.0
;  SET X AXIS LABELS
   x                           = ispan(1,nhour+1,1)
   xtick                       = (/"00", "01", "02", "03", "04", "05", \
                                   "06", "07", "08", "09", "10", "11", \
                                   "12", "13", "14", "15", "16", "17", \
                                   "18", "19", "20", "21", "22", "23", "  "/)
   res@tmXBMode                = "Explicit"
   res@tmXBValues              = x(0:nhour:2)
   res@tmXBLabels              = xtick(0:nhour:2)
   res@trXMaxF                 = 25
   res@tmXBMajorLengthF        = 0.01
   res@tmXBMinorLengthF        = 0.005
   res@tmXBMajorOutwardLengthF = 0.0
   res@tmXBMinorOutwardLengthF = 0.0
   res@tmXBMinorValues         = ispan(2,nhour,2)
   res@tmXBLabelFontHeightF    = 0.03
   res@tmXBLabelStride         = 1
   res@tmYLMajorLengthF        = 0.01
   res@tmYLMinorLengthF        = 0.005
   res@tmYLMajorOutwardLengthF = 0.0
   res@tmYLMinorOutwardLengthF = 0.0
   res@tmYLLabelFontHeightF    = 0.03
   res@tmYLLabelStride         = 2.5

;  SET LEGEND
   res@pmLegendDisplayMode     = "Always"
   res@pmLegendSide            = "Top"
   res@pmLegendParallelPosF    = 0.12
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   res@pmLegendOrthogonalPosF  =-0.46
   res@pmLegendWidthF          = 0.12
   res@pmLegendHeightF         = 0.12
   res@lgLabelFontHeightF      = 0.015
   res@lgPerimOn               = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels  = sitename
   res@trYMinF                 = 5.0
   res@trYMaxF                 = 16.0
   res@tiXAxisString           = "Diurnal Variation (EST)"
   res@tiYAxisString           = "PM~B~2.5~N~(~F33~m~F21~g/m~S~3~N~)"
;  res@tiMainString            = "EPA Observed (08/2012-01/2013) " + sitename
   plot   = gsn_csm_xy(wks, x, data, res)

;  OVER PLOT MONTHLY AVERAGE
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres                        = True
   eres@gsLineColor            = linecolor
   eres@gsLineThicknessF       = 2.0
   eres@gsLineDashPattern      = 2
   if (.not.all(ismissing(data3))) then
    plot1 = gsn_add_polyline(wks, plot, (/x(0), x(nhour-1)/), \
                            (/data3, data3/), eres)
   end if
   delete([/res/])
return
end
