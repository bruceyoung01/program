;   $ID: plot_taylor_diagram_read.ncl V01 09/18/2013 11:31 BRUCE EXP$
;
;******************************************************************************
;   PROGRAM plot_taylor_diagram_read READS RATIO AND CORRELATION COEFFICIENT 
;   FOR BOTH TEST AND REFERENCE FIELDS ARE 2-D ARRAY, AND PLOTS IT.
;
;   VARIABLES:
;   ===========================================================================
;   (1 ) wks         (GRAPHIC): WORK STATION                              [---]
;   (2 ) l_switch    (STRING) : STRING TO JUDGE USING STANDARD DEVIATION
;                               OR CORRELATION OF VARIATION.              [---]
;   (3 ) times       (STRING) : TIME STRING (YEAR, MONTH, DAY, TIMES)     [---]
;   (4 ) caselabel   (STRING) : CASE LABEL                                [---]
;   (5 ) varlabel    (STRING) : VARIABLE LABEL                            [---]
;   (6 ) ratio       (NUMERIC): RATIO (1-D ARRAY)                         [---]
;   (7 ) r           (NUMERIC): CORRELATION (1-D ARRAY)                   [---]
;   (8 ) plot        (GRAPHIC): GRAPHIC TO PLOT IMAGE                     [---]
;
;   NOTES:
;   ===========================================================================
;   (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/18/2013)
;******************************************************************************
;
undef("plot_taylor_diagram_read")
procedure plot_taylor_diagram_read \
          (wks       :graphic,   times     :string,  \ ;INPUT
           caselabel :string,    varlabel  :string,  \ ;INPUT
           ratio     :numeric,   r         :numeric, \ ;INPUT
           plot      :graphic)                         ;OUTPUT

begin

;  SET UP TYLOR DIAGRAM RESOURCES
   res                       = True
   res@Markers               = (/16, 16, 16, 16, 16, 16, 16/)
   res@gsMarkerSizeF         = 0.02
   res@txFontHeightF         = 0.02
   res@Colors                = (/"blue", "red", "pink", "purple", "green", "black", "brown"/)
   res@caseLabels            = caselabel
   res@caseLabelsFontHeightF = 0.15
   res@varLabels             = varlabel
   res@varLabelsFontHeightF  = 0.0001
   res@tiMainString          = "Smoke Emission PM2.5"
   res@stnRad                = (/ 0.5, 1.5, 2.5, 3.5 /)
   res@ccRays                = (/ 0.3, 0.6, 0.7, 0.8, 0.9 /)
   res@centerDiffRMS         = True
   res@tiMainString          = "Smoke Emission PM2.5 " + times
   plot = taylor_diagram(wks, ratio, r, res)

end
