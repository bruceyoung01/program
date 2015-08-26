; $ID: plot_contour_vector_hpbl.ncl V01 08/12/2015 10:16 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_vector_hpbl PLOTS CONTOUR WITH VECTOR OVERLAIED ON IT.
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
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/12/2015)
;******************************************************************************

undef("plot_contour_vector_hpbl")
procedure plot_contour_vector_hpbl \
          (wks        :graphic,                    \ ; INPUT
           minlat     :float,   maxlat   :float,   \ ; INPUT
           minlon     :float,   maxlon   :float,   \ ; INPUT
           time       :string,                     \ ; INPUT
           lat        :float,   lon      :float,   \ ; INPUT
           u          :numeric, v        :numeric, \ ; INPUT
           data       :float)                        ; INPUT

begin

;  ASSIGN LATITUDE AND LONGITUDE TO THE DATA
   u!0                              = "lat"
   u!1                              = "lon"
   u&lat                            = lat
   u&lon                            = lon
   u&lat@units                      ="degrees_north"
   u&lon@units                      ="degrees_east"
   v!0                              = "lat"
   v!1                              = "lon"
   v&lat                            = lat
   v&lon                            = lon
   v&lat@units                      ="degrees_north"
   v&lon@units                      ="degrees_east"
   data!0                           = "lat"
   data!1                           = "lon"
   data&lat                         = lat
   data&lon                         = lon
   data&lat@units                   ="degrees_north"
   data&lon@units                   ="degrees_east"


;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res                              = True

;  SET UP MAP PROJECTION AND LIMITED REGION
   res@mpProjection                 = "CylindricalEquidistant"
   res@mpCenterRotF                 = 0.0
   res@mpGridAndLimbOn              = True
   res@mpGridLatSpacingF            = 10.0
   res@mpGridLonSpacingF            = 10.0
   res@mpLimitMode                  = "latlon"
   res@mpMinLatF                    = minlat
   res@mpMaxLatF                    = maxlat
   res@mpMinLonF                    = minlon
   res@mpMaxLonF                    = maxlon
;  COLOR OF CONTINIENTAL OUTLINES
   res@mpOutlineOn                  = True
   res@mpFillOn                     = False
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
   res@gsnStringFontHeightF         = 0.02

;  COLOR PLOT DEDIRED
   res@cnFillOn                     = True
;  TURN OFF CONTOUR LINES
   res@cnLinesOn                    = False
;  TURN OFF CONTOUR LABELS
   res@cnLineLabelsOn               = False

;  SET UP COLOR MAP AND LABEL
   res@gsnSpreadColors              = True
   res@gsnSpreadColorStart          = 1
   res@gsnSpreadColorEnd            = 200
   res@cnInfoLabelOn                = False
   res@cnInfoLabelPerimOn           = False
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnMinLevelValF               = 0.0
   res@cnMaxLevelValF               = 2000.0
   res@cnLevelSpacingF              = 10.0

;  SET UP LABEL BAR
   res@pmLabelBarOrthogonalPosF     = 0.085
   res@pmLabelBarParallelPosF       = 0.5
   res@pmLabelBarWidthF             = 0.4
   res@pmLabelBarHeightF            = 0.068
   res@lbLabelFontHeightF           = 0.013
   res@lbLabelStride                = 50
   res@lbBoxLinesOn                 = False

;  SET UP COLOR BAR
   res@tiMainFontHeightF            = 0.015
   res@tiMainString                 = "PBLH and Wind " + time
   res@lbTitleString                = "Planetary Boundary Layer Height (m)"
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
   resvc@vcRefAnnoFontHeightF       = 0.01
   resvc@vcGlyphStyle               = "CurlyVector"
   resvc@vcLineArrowColor           = "purple"
   resvc@vcLineArrowThicknessF      = 2.0
   resvc@vcVectorDrawOrder          = "PostDraw"
   resvc@vcMinDistanceF             = 0.03
   plot = gsn_csm_vector_scalar_map_ce(wks, u, v, data, resvc)
   draw(plot)
   frame(wks)

return
end
