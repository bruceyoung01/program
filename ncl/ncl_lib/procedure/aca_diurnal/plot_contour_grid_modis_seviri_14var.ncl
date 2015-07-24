; $ID: plot_contour_grid_modis_seviri_14var.ncl V01 07/21/2015 21:19 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_grid_modis_seviri_14var.ncl PLOTS CONTOUR WITH 
;  RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                               [   ]
;  (2 ) ivariable  (scalar)  : VARIABLE INDEX                             [   ]
;  (3 ) casemethod (a string):CASE AND MEHTOD NAME                        [   ]
;  (4 ) minlat     (scalar)  : MINIMUM LATITUDE                           [DEG]
;  (5 ) maxlat     (scalar)  : MAXIMUM LATITUDE                           [DEG]
;  (6 ) minlon     (scalar)  : MINIMUM LONGITUDE                          [DEG]
;  (7 ) maxlon     (scalar)  : MAXIMUM LONGITUDE                          [DEG]
;  (8 ) lat        (2-D)     : LATITUDE                                   [DEG]
;  (9 ) lon        (2-D)     : LONGITUDE                                  [DEG]
;  (10) data       (2-D)     : VARIABLE                                   [   ]
;  (11) times      (a string): TIME STEP OF PLOT                          [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2015)
;******************************************************************************

undef("plot_contour_grid_modis_seviri_14var")
procedure plot_contour_grid_modis_seviri_14var \
          (wks        :graphic, ivariable  :integer,\ ; INPUT
           minlat     :float,   maxlat     :float,  \ ; INPUT
           minlon     :float,   maxlon     :float,  \ ; INPUT
           lat        :float,   lon        :float,  \ ; INPUT
           data       :float,   times      :string)   ; INPUT

begin

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res                              = True
;  SET UP MAP PROJECTION AND LIMITED REGION
   res@mpFillOn                     = False
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
;  res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
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
   res@gsnStringFontHeightF         = 0.02
   res@gsnRightStringOrthogonalPosF = 0.02
   res@gsnLeftStringOrthogonalPosF  = 0.02
   res@sfXArray                     = lon
   res@sfYArray                     = lat
;  COLOR PLOT DEDIRED
   res@cnFillOn                     = True
   res@cnFillMode                   = "RasterFill"
   res@cnMissingValFillColor        = "White"
   res@cnConstFLabelOn              = False
   res@cnConstFEnableFill           = True

;  TURN OFF CONTOUR LINES
   res@cnLinesOn                    = False
;  TURN OFF CONTOUR LABELS
   res@cnLineLabelsOn               = False
;  SET UP COLOR MAP AND LABEL
   res@gsnSpreadColors              = False
   res@gsnSpreadColorStart          = 0
   res@gsnSpreadColorEnd            = 200
   res@cnInfoLabelOn                = True
   res@cnInfoLabelFontHeightF       = 0.01
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnConstFLabelFormat          = "#+^se"

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelStride                = 40
   res@lbLabelFontThicknessF        = 0.3
   res@lbBoxLinesOn                 = False

;  SETUP SATELLITE NAME
   if (ivariable .le. 8) then
      sate = "MODIS "
   else
      sate = "SEVIRI "
   end if

;  PLOT THE CONTOUR OVER THE CE MAP
   res@tiMainString                 = sate + times
   res@tiMainFontHeightF            = 0.02
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"

;  SPECIFY RESOURSES CHANGING WITH VARIOUS VARIABLES
   if (ivariable .eq. 2 .or. \
       ivariable .eq. 9) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 2.5
      res@cnLevelSpacingF           = 0.0125
      res@lbTitleString             = "Above Cloud Water Vapor (cm)"
   else if (ivariable .eq. 3 .or. \
            ivariable .eq. 10) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 50.0
      res@cnLevelSpacingF           = 0.25
      res@lbTitleString             = "Cloud Optical Thickness"
   else if (ivariable .eq. 4 .or. \
            ivariable .eq. 11) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 25.0
      res@cnLevelSpacingF           = 0.125
      res@lbTitleString             = "Cloud Effective Radius (~F33~m~F21~m)"
   else if (ivariable .eq. 5 .or. \
            ivariable .eq. 12) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 200.0
      res@cnLevelSpacingF           = 1.0
      res@lbTitleString             = "Cloud Water Path (g/m~S~2~N~)"
   else if (ivariable .eq. 6 .or. \
            ivariable .eq. 13) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 1000.0
      res@cnLevelSpacingF           = 5
      res@lbTitleString             = "Cloud Top Pressue (hPa)"
   else if (ivariable .eq. 7 .or. \
            ivariable .eq. 14) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 20000.0
      res@cnLevelSpacingF           = 100.0
      res@lbTitleString             = "Cloud Top Height (m)"
   else if (ivariable .eq. 8 .or. \
            ivariable .eq. 15) then
      res@cnMinLevelValF            = -100.0
      res@cnMaxLevelValF            = 0.0
      res@cnLevelSpacingF           = 0.5
      res@lbTitleString             = "Cloud Top Temperature (~F34~0~F21~C)"
   end if
   end if
   end if
   end if
   end if
   end if
   end if

   plot                             = gsn_csm_contour_map(wks, data, map, res)
   draw(plot)
;  frame(wks)
return
end
