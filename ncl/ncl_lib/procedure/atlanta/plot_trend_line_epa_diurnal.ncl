; $ID: plot_trend_line_epa_diurnal.ncl V01 02/24/2013 16:39 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_line_epa_diurnal IS USED TO PLOT THE TREND LINE 
;  USING ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) sitename   (string)  : AERONET SITE NAME                        [---]
;  (4 ) data1      (float)   : EPA OBSERVATION DATA                     [---]
;  (6 ) data2      (float)   : EPA OBSERVATION DATA STANDARD DEVIATION  [---]
;  (8 ) data3      (float)   : EPA OBSERVATION DATA TOTAL AVERAGE       [---]
;  (10) nhour      (integer) : TOTAL # OF FMF OBSERVATION HOURS         [---]
;  (11) bv1        (integer) : MISSING VALUE FOR INTEGER                [---]
;  (12) bv2        (float)   : MISSING VALUE FOR FLOAT                  [---]
;  (13) mpplot     (graphic) : MAP WITH MARKERS                         [---]
;  (14) tawplot    (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (06/09/2012)
;  (5 ) MODIFIED FROM plot_trend_daily2_aod.ncl. (02/24/2013)
;******************************************************************************

undef("plot_trend_line_epa_diurnal")
procedure plot_trend_line_epa_diurnal \
         (wks    :graphic, sitename:string,  \ ; INPUT
          data1  :float,   data2   :float,   \ ; INPUT
          data3  :float,   nhour   :integer)   ; INPUT

begin
   data = new((/nhour+1/), typeof(data1), -9999.)
   data(0:nhour-1) = data1

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.7
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res@xyMarkLineMode          = "MarkLines"
   res@xyMarkers               = 16
   res@xyMarkerSizes           = 5
   res@xyMarkerThicknessF      = 2.0
   res@xyMarkerColors          = "Blue"
   res@xyLineColor             = "Blue"
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
   res@tmYLMajorLengthF        = 0.01
   res@tmYLMinorLengthF        = 0.005
   res@tmYLMajorOutwardLengthF = 0.0
   res@tmYLMinorOutwardLengthF = 0.0

;  SET LEGEND
   res@pmLegendDisplayMode     = "Always"
   res@pmLegendSide            = "Top"
   res@pmLegendParallelPosF    = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   res@pmLegendOrthogonalPosF  =-0.45
   res@pmLegendWidthF          = 0.12
   res@pmLegendHeightF         = 0.12
   res@lgLabelFontHeightF      = 0.015
   res@lgPerimOn               = False
;  LABELS FOR THE LEGEND
   res@xyExplicitLegendLabels  = (/" EPA Observed "/)
   res@trYMaxF                 = 25.0
   res@trYMinF                 = 0.0
   res@tiXAxisString           = "Diurnal Variation (EST)"
   res@tiYAxisString           = "PM~B~2.5~N~(~F33~m~F21~g/m~S~3~N~)"
   res@tiMainString            = "EPA Observed (08/2012-01/2013) " + sitename
   plot   = gsn_csm_xy(wks, x, data, res)
   draw(plot)

;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres                        = True
   eres@gsLineColor            = "Red"
   eres@gsLineThicknessF       = 2.0

;  PLOT ERROR BAR
    do j = 0, nhour-1
     k = j + 1
     if(.not.ismissing(data1(j)) .and. \
        .not.ismissing(data2(j))) then
      gsn_polyline(wks, plot, (/k, k/), \
                              (/data1(j)-data2(j),\
                                data1(j)/), eres)
      gsn_polyline(wks, plot, (/k-0.2, k+0.2/), \
                              (/data1(j)-data2(j),\
                                data1(j)-data2(j)/), eres)
      gsn_polyline(wks, plot, (/k, k/), \
                              (/data1(j),   \
                                data1(j)+data2(j)/), eres)
      gsn_polyline(wks, plot, (/k-0.2, k+0.2/), \
                              (/data1(j)+data2(j),\
                                data1(j)+data2(j)/), eres)
     end if
    end do

;  OVER PLOT MONTHLY AVERAGE
   eres@gsLineDashPattern = 2
   if (.not.all(ismissing(data3))) then
    gsn_polyline(wks, plot, (/x(0), x(nhour-1)/), \
                            (/data3, data3/), eres)
   end if
   frame(wks)
   delete([/res, eres/])
return
end
