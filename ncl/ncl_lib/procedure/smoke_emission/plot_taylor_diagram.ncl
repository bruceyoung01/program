;   $ID: plot_taylor_diagram.ncl V01 09/18/2013 11:31 BRUCE EXP$
;
;******************************************************************************
;   PROGRAM plot_taylor_diagram READS TEST FIELD AND REFERENCE FIELD, AND 
;   COMPUTES CORRELATION COEFFICIENT (R), THE CENTERED RMS DIFFERENCE (E), 
;   AND THE STANDARD DEVIATIONS OF THE "TEST" FIELD AND THE REFERENCE FIELD.
;   BOTH TEST AND REFERENCE FIELDS ARE 2-D ARRAY.
;
;   VARIABLES:
;   ===========================================================================
;   (1 ) wks         (GRAPHIC): WORK STATION                              [---]
;   (2 ) l_switch    (STRING) : STRING TO JUDGE USING STANDARD DEVIATION
;                               OR CORRELATION OF VARIATION.              [---]
;   (3 ) times       (STRING) : TIME STRING (YEAR, MONTH, DAY, TIMES)     [---]
;   (4 ) caselabel   (STRING) : CASE LABEL                                [---]
;   (5 ) varlabel    (STRING) : VARIABLE LABEL                            [---]
;   (6 ) test        (NUMERIC): TEST FIELD (2-D ARRAY)                    [---]
;   (7 ) ref         (NUMERIC): REFERENCE FIELD (2-D ARRAY)               [---]
;   (8 ) plot        (GRAPHIC): GRAPHIC TO PLOT IMAGE                     [---]
;
;   NOTES:
;   ===========================================================================
;   (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/18/2013)
;******************************************************************************
;
undef("plot_taylor_diagram")
procedure plot_taylor_diagram \
          (wks       :graphic,                       \ ;INPUT
           l_switch  :string,    times     :string,  \ ;INPUT
           caselabel :string,    varlabel  :string,  \ ;INPUT
           test      :numeric,   ref       :numeric, \ ;INPUT
           plot      :graphic)                         ;OUTPUT

begin

;  CALCULATE HOURLY TYLOR DIAGRAM INFO
   ndim   = dimsizes(test)
   ncase  = dimsizes(caselabel)
   nvar   = dimsizes(varlabel)
   sigmat = stddev(test)
   sigmar = stddev(ref)
   avg_r  = avg(ref)

;  DEFINE NEW ARRAY FOR CALCULATING TAYLOR DIAGRAM INFO
   r          = new((/ncase, nvar/), float)
   rmse       = new((/ncase, nvar/), float)
   avg_t      = new((/ncase, nvar/), float)
   sigmaf     = new((/ncase, nvar/), float)
   sigmaratio = new((/ncase, nvar/), float)

   do i = 0, ncase-1
      do j = 0, nvar-1
         r(i, j)     = correlation_nd(test(i, :, :), ref)
         rmse(i, j)  = wgt_arearmse(test(i, :, :), ref, 1.0, 1.0, 1)
; SWITCH TO CALCULATE STANDARD DEVIATION OR CORRELATION OF VARIATION
         if (l_switch .eq. "t_stddev") then
            sigmaf(i, j) = stddev(test(i, :, :))
         else if (l_switch .eq. "t_cv") then
            if (avg(test(i, :, :)) .eq. 0.0) then
               sigmaf(i, j) = stddev(test(i, :, :))
            else
               avg_t(i, j)  = avg(test(i, :, :))
               sigmaf(i, j) = sigmat/avg_t(i, j)
            end if
         end if
         end if
         sigmaratio(i, j) = sigmaf(i, j)/sigmar
      end do
   end do
print("sigmaf     = " + sigmaf)
print("sigmaratio = " + sigmaratio)

;  SET UP TYLOR DIAGRAM RESOURCES
   res                       = True
   res@Markers               = (/16, 16, 16, 16, 16, 16/)
   res@gsMarkerSizeF         = 0.02
   res@txFontHeightF         = 0.02
   res@Colors                = (/"blue", "red", "pink", "purple", "green", "black"/)
   res@caseLabels            = caselabel
   res@caseLabelsFontHeightF = 0.15
   res@varLabels             = varlabel
   res@varLabelsFontHeightF  = 0.0001
   res@tiMainString          = "Smoke Emission PM2.5"
   res@stnRad                = (/ 0.5, 1.5, 2.5, 3.5 /)
   res@ccRays                = (/ 0.3, 0.6, 0.7, 0.8, 0.9 /)
   res@centerDiffRMS         = True
   res@tiMainString          = "Smoke Emission PM2.5 " + times
   plot = taylor_diagram(wks, sigmaratio, r, res)

end
