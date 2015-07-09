; $ID: plot_contour_grid_seviri_9var.ncl V01 05/23/2015 14:48 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_grid_seviri_9var PLOTS CONTOUR WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks     (graphic)  : WORK STATION                                [---]
;  (2 ) minlat  (float)    : MINIMUM LATITUDE                            [deg]
;  (3 ) maxlat  (float)    : MAXIMUM LATITUDE                            [deg]
;  (4 ) minlon  (float)    : MINIMUM LONGITUDE                           [deg]
;  (5 ) maxlon  (float)    : MAXIMUM LONGITUDE                           [deg]
;  (6 ) data    (float)    : VARIABLE                                    [---]
;  (7 ) times   (character): TIME STEP OF PLOT                           [---]
;  (8 ) mpplot  (graphic)  : PRE-DEFINED MAP                             [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2015)
;******************************************************************************

undef("plot_contour_grid_seviri_9var")
procedure plot_contour_grid_seviri_9var \
          (wks        :graphic, ivariable  :integer,\ ; INPUT
           casemethod :string,                      \ ; INPUT
           minlat     :float,   maxlat     :float,  \ ; INPUT
           minlon     :float,   maxlon     :float,  \ ; INPUT
           lat        :float,   lon        :float,  \ ; INPUT
           data       :float,   times      :string)   ; INPUT

begin

;  ASSIGN LATITUDE AND LONGITUDE TO THE DATA
   data!0                           = "lat"
   data!1                           = "lon"
   data@lat                         = lat
   data@lon                         = lon
   lat@units                        ="degrees_north"
   lon@units                        ="degrees_east"

;  ADD LAND AND SEA MASK
;  b = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc", "r")
;  lsm_data = landsea_mask \
;             (b->LSMASK, data&lat,data&lon)
;  data     = mask(data, lsm_data .eq. 0, True)

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

;  PLOT THE CONTOUR OVER THE CE MAP
   res@tiMainString                 = casemethod + " " + times
   res@tiMainFontHeightF            = 0.02
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"

;  SPECIFY RESOURSES CHANGING WITH VARIOUS VARIABLES
   if (ivariable .eq. 2) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 5.0
      res@cnLevelSpacingF           = 0.025
      res@lbTitleString             = "Above Cloud Water Vapor (cm)"
   else if (ivariable .eq. 3) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 50.0
      res@cnLevelSpacingF           = 0.25
      res@lbTitleString             = "Cloud Optical Thickness 16"
   else if (ivariable .eq. 4) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 5.0
      res@cnLevelSpacingF           = 0.025
      res@lbTitleString             = "Cloud Optical Thickness 16 PCL"
   else if (ivariable .eq. 5) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 50.0
      res@cnLevelSpacingF           = 0.25
      res@lbTitleString             = "Cloud Effective Radius 16 (~F33~m~F21~m)"
   else if (ivariable .eq. 6) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 5.0
      res@cnLevelSpacingF           = 0.025
      res@lbTitleString             = "Cloud Effective Radius 16 PCL (~F33~m~F21~m)"
   else if (ivariable .eq. 7) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 200.0
      res@cnLevelSpacingF           = 1.0
      res@lbTitleString             = "Cloud Water Path 16 (g/m~S~2~N~)"
   else if (ivariable .eq. 8) then
      res@cnMinLevelValF            = 0.0
      res@cnMaxLevelValF            = 50.0
      res@cnLevelSpacingF           = 0.25
      res@lbTitleString             = "Cloud Water Path 16 PCL (g/m~S~2~N~)"
   else if (ivariable .eq. 9) then
      res@cnMinLevelValF            = -50.0
      res@cnMaxLevelValF            = 0.0
      res@cnLevelSpacingF           = 0.25
      res@lbTitleString             = "Cloud Top Temperature (~F34~0~F21~C)"
   else if (ivariable .eq.10) then
      res@cnMinLevelValF            = -50.0
      res@cnMaxLevelValF            = 0.0
      res@cnLevelSpacingF           = 0.25
      res@lbTitleString             = "Surface Temperature (K)"
   end if
   end if
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
