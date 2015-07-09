; $ID: plot_wrf_contour_vector_pm25_column.ncl V01 05/16/2012 15:00 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_vector_pm25_column PLOTS CONTOUR WITH VECTOR 
;  OVERLAIED ON IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic): WORK STATION                               [---]
;  (2 ) minlat   (float)  : MINIMUM LATITUDE                           [deg]
;  (3 ) maxlat   (float)  : MAXIMUM LATITUDE                           [deg]
;  (4 ) minlon   (float)  : MINIMUM LONGITUDE                          [deg]
;  (5 ) maxlon   (float)  : MAXIMUM LONGITUDE                          [deg]
;  (6 ) time     (string) : TIME                                       [---]
;  (7 ) u        (float)  : U WIND                                     [m/s]
;  (8 ) v        (float)  : V WIND                                     [m/s]
;  (9 ) data     (float)  : CONTOUR DATA                               [---]
;  (10) plot     (graphic): PLOT                                       [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/16/2012)
;******************************************************************************

undef("plot_wrf_contour_vector_pm25_column")
procedure plot_wrf_contour_vector_pm25_column \
          (wks        :graphic,                    \ ; INPUT
           minlat     :float,   maxlat     :float, \ ; INPUT
           minlon     :float,   maxlon     :float, \ ; INPUT
           time       :character,                  \ ; INPUT
           u          :float,   v          :float, \ ; INPUT
           data       :float,                      \ ; INPUT
           plot       :graphic)                      ; OUTPUT

begin

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res                              = True

;  SET UP MAP PROJECTION AND LIMITED REGION
   res@mpProjection                 = "CylindricalEquidistant"
   res@mpCenterRotF                 = 0.0
   res@mpGridAndLimbOn              = True
   res@mpGridLatSpacingF            = 5.0
   res@mpGridLonSpacingF            = 5.0
   res@mpLimitMode                  = "latlon"
   res@mpMinLatF                    = minlat
   res@mpMaxLatF                    = maxlat
   res@mpMinLonF                    = minlon
   res@mpMaxLonF                    = maxlon
;  COLOR OF CONTINIENTAL OUTLINES
   res@mpFillOn                     = False
   res@mpOutlineOn                  = True
   res@mpGeophysicalLineColor       = "Black"
   res@mpNationalLineColor          = "Black"
   res@mpUSStateLineColor           = "Black"
   res@mpGridLineColor              = "Black"
   res@mpLimbLineColor              = "Black"
   res@mpPerimLineColor             = "Black"
   res@mpGeophysicalLineThicknessF  = 3.0
   res@mpGridLineThicknessF         = 1.5
   res@mpLimbLineThicknessF         = 2.0
   res@mpNationalLineThicknessF     = 3.0
   res@mpUSStateLineThicknessF      = 2.0
   res@mpGridLineDashPattern        = 2
   res@mpOutlineBoundarySets        = "National";"GeophysicalAndUSStates"

;  TURN ON MAP TICKNARKS
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   map  = gsn_csm_map(wks,res)

;  MAXIMIZE PLOT IN FRAME
   res@gsnMaximize                  = True
;  THE DATA IS NOT GLOBAL
   res@gsnAddCyclic                 = False
;  SET UP THE FEATRUED TITLE
   res@gsnLeftString                = "Smoke Mass Loading"
   res@gsnStringFontHeightF         = 0.02
   res@gsnRightStringOrthogonalPosF = 0.02
   res@gsnLeftStringOrthogonalPosF  = 0.02

;  COLOR PLOT DEDIRED
   res@cnFillOn                     = True
;  TURN OFF CONTOUR LINES
   res@cnLinesOn                    = False
;  TURN OFF CONTOUR LABELS
   res@cnLineLabelsOn               = False

;  SET UP COLOR MAP AND LABEL
   res@gsnSpreadColors              = True
   res@gsnSpreadColorStart          = 2
   res@gsnSpreadColorEnd            = 200
   res@cnInfoLabelOn                = False
   res@cnInfoLabelPerimOn           = False
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnMinLevelValF               = 0.0
   res@cnMaxLevelValF               = 100.0
   res@cnLevelSpacingF              = 1.0
;  res@cnLevelSelectionMode         = "ExplicitLevels"
;  DUST + SMOKE
;  res@cnLevels                     = (/5, 10, 20, 30, 40, 50, 100, 150, 200, 250, 300, \
;                                       350, 400, 450, 500, 550, 600, 650, 700, 750,    \
;                                       800, 850, 900, 950, 1000/)
;  SMOKE
;  res@cnLevels                     = (/5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, \
;                                       70, 75, 80, 85, 90, 95, 100, 105, 110/)

;  SET UP LABEL BAR
   res@pmLabelBarOrthogonalPosF     = 0.085
   res@pmLabelBarParallelPosF       = 0.5
   res@pmLabelBarWidthF             = 0.6
   res@pmLabelBarHeightF            = 0.068
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelStride                = 20
   res@lbBoxLinesOn                 = False

;  SET UP COLOR BAR
   res@tiMainFontHeightF            = 0.02
   res@tiMainString                 = "WRF-Chem Smoke + Surface Wind " + time
   res@lbTitleString                = "Smoke Mass Loading (~F21~mg/m~S~2~N~)"
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"
;  SET UP VECTOR RESOURCES
   resvc                            = True
   resvc                            = res
   resvc@gsnScalarContour           = True
   resvc@vcRefMagnitudeF            = 10.0
   resvc@vcRefLengthF               = 0.05
   resvc@vcRefAnnoOrthogonalPosF    = -1.0
   resvc@vcRefAnnoArrowLineColor    = "purple"
   resvc@vcRefAnnoArrowUseVecColor  = False
   resvc@vcGlyphStyle               = "CurlyVector"
   resvc@vcLineArrowColor           = "purple"
   resvc@vcLineArrowThicknessF      = 2.0
   resvc@vcVectorDrawOrder          = "PostDraw"
   resvc@vcMinDistanceF             = 0.03
   data@units                       = "~F21~mg/m~S~2~N~"
   plot = gsn_csm_vector_scalar_map_ce(wks, u, v, data, resvc)
   draw(plot)
   frame(wks)
   delete(res)
   delete(resvc)

return
end
