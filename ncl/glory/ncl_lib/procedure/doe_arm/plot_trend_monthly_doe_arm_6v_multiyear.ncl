; $ID: plot_trend_monthly_doe_arm_6v_multiyear.ncl V01 04/06/2012 16:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_monthly_doe_arm_6v_multiyear IS USED TO PLOT THE 
;  TREND LINE OF ONE-DIMENSIONAL ARRAY FOR SIX VARIABLES, 
;  ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) data       (float)   : DOE ARM OBSERVATION DATA                 [---]
;  (3 ) ynmonth    (integer) : # OF TOTAL MONTHES IN MULTIYEAR          [---]
;  (4 ) mpplot     (graphic) : MAP WITH MARKERS                         [---]
;  (5 ) tawplot    (graphic) : TREND LINE PLOT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED FROM plot_trend_daily.ncl. (04/06/2012)
;  (2 ) MODIFIED FROM plot_trend_monthly_doe_arm_1v_multiyear.ncl. (04/07/2012)
;******************************************************************************

undef("plot_trend_monthly_doe_arm_6v_multiyear")
procedure plot_trend_monthly_doe_arm_6v_multiyear \ 
                          (wks    :graphic,bv2     :float,    \ ; INPUT
                           data   :float,  ynmonth :integer,  \ ; INPUT
                           mpplot :graphic,                   \ ; INPUT
                           tawplot:graphic)                     ; OUTPUT

begin

;  DEFINE A NEW ARRARY JUST INCLUDING VARIABLES
   ndata                       = new((/6, ynmonth/), float, bv2)
   ndata(0:5, :)               = data(1:6, :)

;  SET UP THE POSITION OF THE CONTOUR PLOT
   resl                         = True
   resl@vpWidthF                = 0.7
   resl@vpHeightF               = 0.35
   resl@vpXF                    = 0.15
   resl@vpYF                    = 0.85
   resl@gsnDraw                 = False
   resl@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   resl@xyMarkLineMode         = "MarkLines"
   resl@xyMarkers              = (/16, 11, 16, 11, 16, 11/)
   resl@xyMarkerSizes          = (/5, 5, 5, 5, 5, 5/)
   resl@xyMarkerThicknesses    = (/2, 2, 2, 2, 2, 2/)
   resl@xyMarkerColors         = (/"Green", "Green", "Blue", \
                                  "Blue",  "Red",   "Red"/)
   resl@xyLineColors           = (/"Green", "Green", "Blue", \
                                  "Blue",  "Red",   "Red"/)

;  SET X AXIS LABELS
   x                           = ispan(1,ynmonth,1)
   xtick                       = (/"JAN", "FEB", "MAR", "APR", "MAY", "JUN", \
                                   "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"/)
   resl@tmXBMode               = "Explicit"
   resl@tmXBValues             = x(0:ynmonth-1:1)
   resl@tmXBLabels             = xtick
   resl@tmXBMajorLengthF       = 0.01
   resl@tmXBMinorLengthF       = 0.005
   resl@tmXBMajorOutwardLengthF= 0.0
   resl@tmXBMinorOutwardLengthF= 0.0
   resl@tmXBMinorValues        = ispan(2,ynmonth,1)
   resl@tmXTMajorLengthF       = 0.01
   resl@tmXTMinorLengthF       = 0.005
   resl@tmXTMajorOutwardLengthF= 0.0
   resl@tmXTMinorOutwardLengthF= 0.0
   resl@tmXTMinorValues        = ispan(2,ynmonth,1)
   resl@tmYLMajorLengthF       = 0.01
   resl@tmYLMinorLengthF       = 0.005
   resl@tmYLMajorOutwardLengthF= 0.0
   resl@tmYLMinorOutwardLengthF= 0.0
   resl@tmYRMajorLengthF       = 0.01
   resl@tmYRMinorLengthF       = 0.005
   resl@tmYRMajorOutwardLengthF= 0.0
   resl@tmYRMinorOutwardLengthF= 0.0

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resl@pmLegendOrthogonalPosF =-0.60
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
;  DOE ARM AAOD (441 nm)
;  DOE ARM NCCN
;  Particle Concentration
;  Aerosol Absorption Coefficient
   resl@xyExplicitLegendLabels = (/" AAC Green (1 ~F33~m~F0~m)", \
                                  " AAC Green (10 ~F33~m~F0~m)", \
                                  " AAC Blue (1 ~F33~m~F0~m)", \
                                  " AAC Blue (10 ~F33~m~F0~m)", \
                                  " AAC Red (1 ~F33~m~F0~m)", \
                                  " AAC Red (10 ~F33~m~F0~m)"/)
   resl@trYMaxF                = 15.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Year"
;  Aerosol Absorption Optical Depth
;  Number of CCN
;  Particle Concentration
;  Aerosol Absorption Coefficient (Mm~S~-1~N~)
   resl@tiYAxisString          = "Aerosol Absorption Coefficient (Mm~S~-1~N~)"
   resl@tiMainString           = "DOE ARM AAC Monthly  SGP (Multiyear)"

   tawplot   = gsn_csm_xy(wks, x, ndata, resl)
   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/resl, mpplot, tawplot/])
return
end
