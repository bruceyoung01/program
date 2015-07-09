; $ID: plot_cesm_contour_vector_t_point.ncl V01 04/13/2014 12:08 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_cesm_contour_vector_t_point PLOTS CONTOUR WITH VECTOR 
;  OVERLAIED ON IT AND ADDS POINTS.
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

undef("plot_cesm_contour_vector_t_point")
procedure plot_cesm_contour_vector_t_point \
          (wks        :graphic,                    \ ; INPUT
           minlat     :float,   maxlat     :float, \ ; INPUT
           minlon     :float,   maxlon     :float, \ ; INPUT
           latitude   :float,   longitude  :float, \ ; INPUT
           time       :string,  level      :string,\ ; INPUT
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
   res@mpFillOn                     = False
   res@mpOutlineOn                  = True
;  res@mpOutlineBoundarySets        = "AllBoundaries"
;  res@mpDataSetName                = "Earth..4"
;  res@mpDataBaseVersion            = "MediumRes"
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"

;  TURN ON MAP TICKNARKS
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   map  = gsn_csm_map(wks,res)

;  MAXIMIZE PLOT IN FRAME
   res@gsnMaximize                  = True
;  THE DATA IS NOT GLOBAL
   res@gsnAddCyclic                 = False
;  SET UP THE FEATRUED TITLE
   res@gsnLeftString                = "Dust Mass Concentration"
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
   res@gsnSpreadColorEnd            = 200
   res@cnInfoLabelOn                = False
   res@cnInfoLabelPerimOn           = False
;  res@cnLevelSelectionMode         = "ManualLevels"
;  res@cnMinLevelValF               = 200.0
;  res@cnMaxLevelValF               = 350.0
;  res@cnLevelSpacingF              = 1.0

;  SET UP LABEL BAR
   res@pmLabelBarOrthogonalPosF     = 0.085
   res@pmLabelBarParallelPosF       = 0.5
   res@pmLabelBarWidthF             = 0.6
   res@pmLabelBarHeightF            = 0.068
   res@lbLabelFontHeightF           = 0.013
   res@lbLabelStride                = 1
   res@lbBoxLinesOn                 = False

;  SET UP COLOR BAR
   res@tiMainFontHeightF            = 0.02
   res@tiMainString                 = "CESM Temperature  [~F33~s~F21~ Pressure:  " + level + "mba  Time: " + time + "]"
   res@lbTitleString                = "Temperature (K)"
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
   data@units                       = "(K)"
   plot = gsn_csm_vector_scalar_map_ce(wks, u, v, data, resvc)
   draw(plot)

;  Now you can add some information to the plot.
   pmres                     = True
   pmres@gsMarkerColor       = "deeppink"
   pmres@gsMarkerIndex       = 16
   pmres@gsMarkerSizeF       = 0.02
   cpmres                    = True
   cpmres@gsMarkerColor      = "black"
   cpmres@gsMarkerIndex      = 4
   cpmres@gsMarkerThicknessF = 4
   cpmres@gsMarkerSizeF      = 0.023
   nsite = dimsizes(latitude)
   do i = 0, nsite-1
      gsn_polymarker(wks, plot, longitude(i), latitude(i), pmres)
      gsn_polymarker(wks, plot, longitude(i), latitude(i), cpmres)
   end do
;  draw(plot)
   frame(wks)
   delete(res)
   delete(resvc)

return
end
