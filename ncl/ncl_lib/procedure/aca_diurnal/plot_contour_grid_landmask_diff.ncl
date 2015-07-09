; $ID: plot_contour_gridlandmask_diff.ncl V01 05/23/2015 14:48 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_grid_landmask_diff PLOTS CONTOUR WITH 
;  RASTERFILL AND WITH BACKGROUND MAP OVERLAYING ON IT, AND WITH LAND AND SEA 
;  MASK.
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

undef("plot_contour_grid_landmask_diff")
procedure plot_contour_grid_landmask_diff \
          (wks        :graphic,                     \ ; INPUT
           minlat     :float,   maxlat     :float,  \ ; INPUT
           minlon     :float,   maxlon     :float,  \ ; INPUT
           lat        :float,   lon        :float,  \ ; INPUT
           data       :float,   times      :string)   ; INPUT

begin

;  ASSIGN LATITUDE AND LONGITUDE TO THE DATA
   data!0                           = "lat"
   data!1                           = "lon"
   data&lat                         = lat
   data&lon                         = lon
   data&lat@units                   ="degrees_north"
   data&lon@units                   ="degrees_east"

;  ADD LAND AND SEA MASK
   b = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc", "r")
   lsm_data = landsea_mask \
              (b->LSMASK, data&lat,data&lon)
   data     = mask(data, lsm_data .eq. 0, True)

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
;  COLOR PLOT DEDIRED
   res@cnFillOn                     = True
   res@cnFillMode                   = "RasterFill"
   res@cnMissingValFillColor        = "White"

;  TURN OFF CONTOUR LINES
   res@cnLinesOn                    = False
;  TURN OFF CONTOUR LABELS
   res@cnLineLabelsOn               = False
;  SET UP COLOR MAP AND LABEL
   res@gsnSpreadColors              = False
   res@gsnSpreadColorStart          = 0
   res@gsnSpreadColorEnd            = 201
   res@cnInfoLabelOn                = True
   res@cnInfoLabelFontHeightF       = 0.01
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnConstFLabelFormat          = "#+^se"
   res@cnMinLevelValF               = -0.5
   res@cnMaxLevelValF               = 0.5
   res@cnLevelSpacingF              = 0.005

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelStride                = 40
   res@lbLabelFontThicknessF        = 0.3
   res@lbBoxLinesOn                 = False

;  PLOT THE CONTOUR OVER THE CE MAP
;  METHOD2
;  res@tiMainString                 = times + "  [~F34~e~F21~(n)]  ACA"
;  METHOD3
   res@tiMainString                 = times + "  {n/~F34~e~F21~[available(n)]}  ACA"
   res@tiMainFontHeightF            = 0.02
   res@lbTitleString                = "(Aqua-Terra) Cloud Fraction"
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"
   plot                             = gsn_csm_contour_map(wks, data, map, res)
   draw(plot)
;  frame(wks)
   delete(res)
return
end
