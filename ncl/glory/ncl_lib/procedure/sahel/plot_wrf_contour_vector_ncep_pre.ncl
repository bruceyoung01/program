; $ID: plot_wrf_contour_vector_ncep_pre.ncl V01 05/16/2012 15:00 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_vector_ncep_pre PLOTS CONTOUR WITH VECTOR OVERLAIED 
;  ON IT.
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

undef("plot_wrf_contour_vector_ncep_pre")
procedure plot_wrf_contour_vector_ncep_pre \
          (wks        :graphic,                    \ ; INPUT
           minlat     :float,   maxlat     :float, \ ; INPUT
           minlon     :float,   maxlon     :float, \ ; INPUT
           time       :string,                     \ ; INPUT
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
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"

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
   res@gsnLeftString                = "Surface Pressure"
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
   res@gsnSpreadColorStart          = 0
   res@gsnSpreadColorEnd            = 189
   res@cnInfoLabelOn                = False
   res@cnInfoLabelPerimOn           = False
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnMinLevelValF               = 750.0
   res@cnMaxLevelValF               = 1100.0
   res@cnLevelSpacingF              = 25.0

;  SET UP LABEL BAR
   res@pmLabelBarOrthogonalPosF     = 0.085
   res@pmLabelBarParallelPosF       = 0.5
   res@pmLabelBarWidthF             = 0.6
   res@pmLabelBarHeightF            = 0.068
   res@lbLabelFontHeightF           = 0.013
   res@lbLabelStride                = 2
   res@lbBoxLinesOn                 = False

;  SET UP COLOR BAR
   res@tiMainFontHeightF            = 0.02
   res@tiMainString                 = "Surface Pressure and Wind " + time
   res@lbTitleString                = "Surface Pressure (mba)"
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"
;  SET UP VECTOR RESOURCES
   resvc                            = True
   resvc                            = res
   resvc@gsnScalarContour           = True
   resvc@vcRefMagnitudeF            = 10.0
   resvc@vcRefLengthF               = 0.05
   resvc@vcRefAnnoOrthogonalPosF    = -1.0
   resvc@vcRefAnnoArrowLineColor    = "blue1"
   resvc@vcRefAnnoArrowUseVecColor  = False
   resvc@vcGlyphStyle               = "CurlyVector"
   resvc@vcLineArrowColor           = "blue1"
   resvc@vcLineArrowThicknessF      = 2.0
   resvc@vcVectorDrawOrder          = "PostDraw"
   resvc@vcMinDistanceF             = 0.03
   plot = gsn_csm_vector_scalar_map_ce(wks, u, v, data, resvc)
   draw(plot)
   frame(wks)
   delete(res)
   delete(resvc)

return
end
