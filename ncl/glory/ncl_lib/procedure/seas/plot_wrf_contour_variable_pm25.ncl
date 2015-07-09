; $ID: plot_wrf_contour_variable_pm25.ncl V01 03/29/2012 10:05 BRUCE EXP$
;
;******************************************************************************
;  PURPOSE OF THIS FUNCTION : PLOT THE CONTOUR PLOT USING WRF/CHEM OUTPUT
;  THE STEPS ARE AS FOLLOWING : 
;  1, INPUT WRFCHEM DATA
;  2, PLOT A CONTOUR OVER A MAP
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks     (graphic)  : WORK STATION                                [---]
;  (2 ) minlat  (float)    : MINIMUM LATITUDE                            [deg]
;  (3 ) maxlat  (float)    : MAXIMUM LATITUDE                            [deg]
;  (4 ) minlon  (float)    : MINIMUM LONGITUDE                           [deg]
;  (5 ) maxlon  (float)    : MAXIMUM LONGITUDE                           [deg]
;  (6 ) data    (float)    : VARIABLE OF WRFCHEM DATA                    [---]
;  (7 ) times   (character): TIME STEP OF PLOT                           [---]
;
;  pm25TES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;******************************************************************************

undef("plot_wrf_contour_variable_pm25")
procedure plot_wrf_contour_variable_pm25\
          (wks        :graphic,                     \ ; INPUT
           minlat     :float,   maxlat     :float,  \ ; INPUT
           minlon     :float,   maxlon     :float,  \ ; INPUT
           data       :float,   times      :character); INPUT

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
   res@mpUSStateLineThicknessF      = 3.0
   res@mpGridLineDashPattern        = 2    
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
;  ADD US COUNTIES BOUNDAIRES
   res@mpOutlineBoundarySets        = "AllBoundaries"
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
;  THE DATA IS pm25T GLOBAL
   res@gsnAddCyclic                 = False
;  SET UP THE FEATRUED TITLE
   res@gsnLeftString                = "PM2.5 Emissions"
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
;  res@cnMinLevelValF               = 0.00001
;  res@cnMaxLevelValF               = 0.0005
;  res@cnLevelSpacingF              = 0.00001
   res@cnLevelSelectionMode         = "ExplicitLevels"
   res@cnLevels                     = (/1, 2, 3, 4, 5, 6, 7, 8, 9,  \
                                        10, 15, 20, 25, 30, 35, 40, \
                                        45, 50, 60, 70, 80, 90, 100,\
                                        120, 140/)

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelStride                = 3
   res@lbLabelFontThicknessF        = 0.3
   res@lbBoxLinesOn                 = False

;  PLOT THE CONTOUR OVER THE CE MAP
   res@tiMainString                 = "INTEX PM2.5  "+times
   res@tiMainFontHeightF            = 0.02
   data@description                 = "PM2.5 Emission"
   data@units                       = "10~S~-4~N~ ~F33~m~F0~g/m~S~3~N~ m/s"
   res@lbTitleString                = data@description + "  " + "(" + data@units + ")"
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"
   plot                             = gsn_csm_contour_map(wks, data, map, res)
   draw(plot)
   frame(wks)
   return(plot)
   delete(res)

end
