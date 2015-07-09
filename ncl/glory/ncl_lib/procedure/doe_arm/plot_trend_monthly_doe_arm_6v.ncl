; $ID: plot_trend_monthly_doe_arm_6v.ncl V01 04/06/2012 16:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_monthly_doe_arm_6v IS USED TO PLOT THE TREND LINE 
;  OF ONE-DIMENSIONAL ARRAY FOR SIX VARIABLES, ALSO WITH SPECIFIED X AXIS 
;  TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) data       (float)   : DOE ARM OBSERVATION DATA                 [---]
;  (3 ) nmonth     (integer) : # OF TOTAL MONTHES IN MULTIYEAR          [---]
;  (4 ) mpplot     (graphic) : MAP WITH MARKERS                         [---]
;  (5 ) tawplot    (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED FROM plot_trend_daily.ncl. (04/06/2012)
;  (2 ) MODIFIED FROM plot_trend_monthly_doe_arm_1v.ncl. (04/07/2012)
;******************************************************************************

undef("plot_trend_monthly_doe_arm_6v")
procedure plot_trend_monthly_doe_arm_6v \ 
                          (wks    :graphic, bv2    :float,    \ ; INPUT
                           data   :float,   nmonth :integer,  \ ; INPUT
                           mpplot :graphic,                   \ ; INPUT
                           tawplot:graphic)                     ; OUTPUT

begin
;  DEFINE A NEW ARRARY JUST INCLUDING VARIABLES
   ndata                       = new((/6, nmonth/), float, bv2)
   ndata(0:5, :)               = data(2:7, :)

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.7
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res@xyMarkLineMode         = "MarkLines"
   res@xyMarkers              = (/16, 11, 16, 11, 16, 11/)
   res@xyMarkerSizes          = (/5, 5, 5, 5, 5, 5/)
   res@xyMarkerThicknesses    = (/2, 2, 2, 2, 2, 2/)
   res@xyMarkerColors         = (/"Green", "Green", "Blue", \
                                  "Blue",  "Red",   "Red"/)
   res@xyLineColors           = (/"Green", "Green", "Blue", \
                                  "Blue",  "Red",   "Red"/)

;  SET X AXIS LABELS
   x                           = ispan(1,nmonth,1)
;  FOR AEROSOL ABSORPTION COEFFICIENT
   xtick                       = (/"07", "08", "09", "10", "11"/)
;  FOR ALL THE LONG-TERM
;  xtick                       = (/"93", "95", "97", "99", "01", \
;                                  "03", "05", "07", "09", "11"/)
   res@tmXBMode               = "Explicit"
   res@tmXBValues             = x(0:nmonth-1:12)
;  res@tmXBValues             = x(0:nmonth-1:24)
   res@tmXBLabels             = xtick
   res@tmXBMajorLengthF       = 0.01
   res@tmXBMinorLengthF       = 0.005
   res@tmXBMajorOutwardLengthF= 0.0
   res@tmXBMinorOutwardLengthF= 0.0
   res@tmXBMinorValues        = ispan(2,nmonth,1)
   res@tmXTMajorLengthF       = 0.01
   res@tmXTMinorLengthF       = 0.005
   res@tmXTMajorOutwardLengthF= 0.0
   res@tmXTMinorOutwardLengthF= 0.0
   res@tmXTMinorValues        = ispan(2,nmonth,3)
   res@tmYLMajorLengthF       = 0.01
   res@tmYLMinorLengthF       = 0.005
   res@tmYLMajorOutwardLengthF= 0.0
   res@tmYLMinorOutwardLengthF= 0.0
   res@tmYRMajorLengthF       = 0.01
   res@tmYRMinorLengthF       = 0.005
   res@tmYRMajorOutwardLengthF= 0.0
   res@tmYRMinorOutwardLengthF= 0.0

;  SET LEGEND
   res@pmLegendDisplayMode    = "Always"
   res@pmLegendSide           = "Top"
   res@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   res@pmLegendOrthogonalPosF =-0.60
   res@pmLegendWidthF         = 0.12
   res@pmLegendHeightF        = 0.12
   res@lgLabelFontHeightF     = 0.015
   res@lgPerimOn              = False
;  LABELS FOR THE LEGEND
;  DOE ARM AAOD (441 nm)
;  DOE ARM NCCN
;  Particle Concentration
;  Aerosol Absorption Coefficient
   res@xyExplicitLegendLabels = (/" AAC Green (1 ~F33~m~F0~m)", \
                                  " AAC Green (10 ~F33~m~F0~m)", \
                                  " AAC Blue (1 ~F33~m~F0~m)", \
                                  " AAC Blue (10 ~F33~m~F0~m)", \
                                  " AAC Red (1 ~F33~m~F0~m)", \
                                  " AAC Red (10 ~F33~m~F0~m)"/)
   res@trYMaxF                = 15.0
   res@trYMinF                = 0.0
   res@tiXAxisString          = "Year"
;  Aerosol Absorption Optical Depth
;  Number of CCN
;  Particle Concentration(m~S~-3~N~)
;  Aerosol Absorption Coefficient (Mm~S~-1~N~)
   res@tiYAxisString          = "Aerosol Absorption Coefficient (Mm~S~-1~N~)"
   res@tiMainString           = "DOE ARM AAC Monthly  SGP (Multiyear)"

   tawplot   = gsn_csm_xy(wks, x, ndata, res)
   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/res, mpplot, tawplot/])
return
end
