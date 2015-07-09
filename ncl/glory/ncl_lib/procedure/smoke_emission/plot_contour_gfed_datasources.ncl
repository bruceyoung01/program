;  $ID: plot_contour_gfed_datasources.ncl V01 09/09/2013 15:05 BRUCE EXP$
;
;******************************************************************************
;  plot_contour_gfed_datasources PLOTS THE CONTOUR PLOT USING GFEDV3 EMISSION 
;  DATA.
;  THE STEPS ARE AS FOLLOWING : 
;  1, INPUT EMISSION DATA
;  2, PLOT A CONTOUR OVER A MAP
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks     (graphic)  : WORK STATION                                [---]
;  (2 ) minlat  (float)    : MINIMUM LATITUDE                            [deg]
;  (3 ) maxlat  (float)    : MAXIMUM LATITUDE                            [deg]
;  (4 ) minlon  (float)    : MINIMUM LONGITUDE                           [deg]
;  (5 ) maxlon  (float)    : MAXIMUM LONGITUDE                           [deg]
;  (6 ) data    (float)    : VARIABLE OF EMISSION DATA                   [---]
;  (7 ) times   (character): TIME STEP OF PLOT                           [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;  (2 ) MODIFIED FROM plot_wrf_contour_variable_no.ncl BY BRUCE. (09/09/2013)
;******************************************************************************

undef("plot_contour_gfed_datasources")
procedure plot_contour_gfed_datasources\
          (wks        :graphic,                     \ ; INPUT
           minlat     :float,   maxlat     :float,  \ ; INPUT
           minlon     :float,   maxlon     :float,  \ ; INPUT
           data       :integer, times      :integer)  ; INPUT

begin

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res                              = True
;  SET UP MAP PROJECTION AND LIMITED REGION
   res@mpProjection                 = "CylindricalEquidistant"
   res@mpCenterRotF                 = 0.0
   res@mpGridAndLimbOn              = True
   res@mpGridLatSpacingF            = 30.0
   res@mpGridLonSpacingF            = 30.0
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
   res@mpUSStateLineThicknessF      = 3.0
   res@mpGridLineDashPattern        = 2    
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
;  ADD US COUNTIES BOUNDAIRES
;  res@mpOutlineBoundarySets        = "AllBoundaries"
;  res@mpDataBaseVersion            = "Ncarg4_1"
;  res@mpDataSetName                = "Earth..2"
;  TURN ON MAP TICKNARKS
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   map  = gsn_csm_map(wks,res)
;  TURN ON MAP TICKMARKS
   res@pmTickMarkDisplayMode        = "always"
;  MAXIMIZE PLOT IN FRAME
   res@gsnMaximize                  = True
;  THE DATA IS NOT GLOBAL
   res@gsnAddCyclic                 = False
;  SET UP THE FEATRUED TITLE
   res@gsnLeftString                = "Vegetation Types"
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
   res@cnInfoLabelOn                = True
   res@cnInfoLabelFontHeightF       = 0.01
;  res@cnLevelSelectionMode         = "ManualLevels"
;  res@cnConstFLabelFormat          = "#+^se"
;  res@cnMinLevelValF               = 0.0
;  res@cnMaxLevelValF               = 3.0
;  res@cnLevelSpacingF              = 1.0
   res@cnLevelSelectionMode         = "ExplicitLevels"
   res@cnLevels                     = (/0, 1, 2, 3, 4/)

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelStride                = 1
   res@lbLabelFontThicknessF        = 0.3
   res@lbBoxLinesOn                 = False
   res@lbLabelAlignment             = "BoxCenters"
   res@lbLabelStrings               = (/"N/A", "F", "S/S", "C/G", "N/I"/)
;  res@lbLabelStrings               = (/"0", "Forest", "Shrub/Savannas", "Crop/Grass", "N/A"/)

;  PLOT THE CONTOUR OVER THE CE MAP
   res@tiMainString                 = "GFED V3  "+times
   res@tiMainFontHeightF            = 0.02
   data@description                 = "Vegetation Types"
   data@units                       = " "
   res@lbTitleString                = data@description
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"
   plot                             = gsn_csm_contour_map(wks, data, map, res)
   draw(plot)
   frame(wks)
   return(plot)
   delete(res)

end
