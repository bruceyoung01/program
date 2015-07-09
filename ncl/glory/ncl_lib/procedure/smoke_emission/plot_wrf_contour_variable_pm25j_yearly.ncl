; $ID: plot_wrf_contour_variable_pm25j_yearly.ncl V01 07/18/2012 07:41 BRUCE EXP$
;
;******************************************************************************
;  plot_wrf_contour_variable_pm25j_yearly PLOTS THE CONTOUR PLOT USING WRF/CHEM 
;  OUTPUT THE STEPS ARE AS FOLLOWING : 
;  1, INPUT WRFCHEM DATA
;  2, PLOT A CONTOUR OVER A MAP
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks          (graphic)  : WORK STATION                            [---]
;  (2 ) emissionname (string)   : SMOKE EMISSION NAME                     [---]
;  (3 ) minlat       (float)    : MINIMUM LATITUDE                        [deg]
;  (4 ) maxlat       (float)    : MAXIMUM LATITUDE                        [deg]
;  (5 ) minlon       (float)    : MINIMUM LONGITUDE                       [deg]
;  (6 ) maxlon       (float)    : MAXIMUM LONGITUDE                       [deg]
;  (7 ) data         (float)    : VARIABLE OF WRFCHEM DATA                [---]
;  (8 ) times        (string)   : TIME STEP OF PLOT                       [---]
;  (9 ) plot         (graphic)  : PLOT                                    [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;  (2 ) MODIFIED FROM plot_wrf_contour_variable_no.ncl BY BRUCE. (07/18/2012)
;******************************************************************************

undef("plot_wrf_contour_variable_pm25j_yearly")
procedure plot_wrf_contour_variable_pm25j_yearly\
          (wks        :graphic, emissionname  :string, \ ; INPUT
           minlat     :float,   maxlat        :float,  \ ; INPUT
           minlon     :float,   maxlon        :float,  \ ; INPUT
           data       :float,   times         :string, \ ; INPUT
           plot       :graphic)                          ; OUTPUT

begin

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res                              = True
;  SET UP MAP PROJpm25TION AND LIMITED REGION
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
;  THE DATA IS NOT GLOBAL
   res@gsnAddCyclic                 = False
;  SET UP THE FEATRUED TITLE
   res@gsnLeftString                = "Smoke Emissions"
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
   res@cnInfoLabelOn                = True
   res@cnInfoLabelFontHeightF       = 0.01
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnConstFLabelFormat          = "#+^se"
   res@cnMinLevelValF               = 0
   res@cnMaxLevelValF               = 3000.0
   res@cnLevelSpacingF              = 25
;  res@cnLevelSelpm25tionMode         = "ExplicitLevels"
;  res@cnLevels                     = (/1, 2, 3, 4, 5, 10, 15, 20, 30, 40, 50, 60, 80, 100, 150, 200, 250/)

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelStride                = 20
   res@lbLabelFontThicknessF        = 0.3
   res@lbBoxLinesOn                 = False

;  PLOT THE CONTOUR OVER THE CE MAP
   res@tiMainString                 = emissionname + times
   res@tiMainFontHeightF            = 0.02
   data@description                 = "Smoke Emission"
   data@units                       = "~F33~m~F0~g/m~S~2~N~/s"
   res@lbTitleString                = data@description + "  " + "(" + data@units + ")"
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"
   plot                             = gsn_csm_contour_map(wks, data, map, res)
   return(plot)
   delete(res)

end
