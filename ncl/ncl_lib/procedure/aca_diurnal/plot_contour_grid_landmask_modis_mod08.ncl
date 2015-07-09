; $ID: plot_contour_grid_landmask_modis_mod08.ncl V01 05/23/2015 14:48 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_grid_landmask_modis_mod08 PLOTS CONTOUR WITH 
;  RASTERFILL AND WITH LAND AND SEA MASK.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks          (graphic):WORK STATION                                [---]
;  (2 ) minlat         (float):MINIMUM LATITUDE                            [DEG]
;  (3 ) maxlat         (float):MAXIMUM LATITUDE                            [DEG]
;  (4 ) minlon         (float):MINIMUM LONGITUDE                           [DEG]
;  (5 ) maxlon         (float):MAXIMUM LONGITUDE                           [DEG]
;  (6 ) lat            (float):LATITUDE CORRESPONGDING TO AMSR-E DATA      [DEG]
;  (7 ) lon            (float):LONGITUDE CORRESPONGDING TO AMSR-E DATA     [DEG]
;  (8 ) day_or_night (integer):SWITCH FOR DAY OR NIGHT                     [   ]
;  (9 ) element      (integer):SWITCH FOR PARAMETERS                       [   ]
;  (10) data           (float):VARIABLE                                    [---]
;  (11) times      (character):TIME STEP OF PLOT                           [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2015)
;******************************************************************************

undef("plot_contour_grid_landmask_modis_mod08")
procedure plot_contour_grid_landmask_modis_mod08 \
          (wks          :graphic,                      \ ; INPUT
           minlat       :float,   maxlat     :float,   \ ; INPUT
           minlon       :float,   maxlon     :float,   \ ; INPUT
           lat          :float,   lon        :float,   \ ; INPUT
           data         :numeric, times      :string)    ; INPUT

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

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelFontThicknessF        = 0.3
   res@lbBoxLinesOn                 = False

;  PLOT THE CONTOUR OVER THE CE MAP
   res@tiMainFontHeightF            = 0.02
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"

   res@cnMinLevelValF               = 0.0
   res@cnMaxLevelValF               = 200.0
   res@cnLevelSpacingF              = 1.0
   res@lbLabelStride                = 50
   res@lbTitleString                = "Liquid Water Path" + "(g/m~S~2~N~)"
   res@tiMainString                 = "MODIS (Terra) " + times

   plot = gsn_csm_contour_map(wks, data, map, res)
   draw(plot)
   delete(res)
return
end
