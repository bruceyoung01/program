; $ID: plot_contour_grid_landmask_seviri_pl.ncl V01 06/25/2015 17:31 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_grid_landmask_seviri_pl PLOTS CONTOUR WITH 
;  RASTERFILL AND WITH LAND AND SEA MASK, ALSO INCLUDING CALIPSO GROUND TRACK.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks          (graphic):WORK STATION                                [---]
;  (2 ) minlat         (float):MINIMUM LATITUDE                            [DEG]
;  (3 ) maxlat         (float):MAXIMUM LATITUDE                            [DEG]
;  (4 ) minlon         (float):MINIMUM LONGITUDE                           [DEG]
;  (5 ) maxlon         (float):MAXIMUM LONGITUDE                           [DEG]
;  (6 ) clat           (float):CALIPSO GROUND TRACK LATITUDE               [DEG]
;  (7 ) clon           (float):CALIPSO GROUND TRACK LONGITUDE              [DEG]
;  (8 ) element     (a string):VARIABLE IN SEVIRI DATA                     [   ]
;  (9 ) data           (float):VARIABLE                                    [---]
;  (10) times      (character):TIME STEP OF PLOT                           [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/25/2015)
;******************************************************************************

undef("plot_contour_grid_landmask_seviri_pl")
procedure plot_contour_grid_landmask_seviri_pl \
          (wks          :graphic,                      \ ; INPUT
           minlat       :float,   maxlat     :float,   \ ; INPUT
           minlon       :float,   maxlon     :float,   \ ; INPUT
           clat         :float,   clon       :float,   \ ; INPUT
           element      :string,                       \ ; INPUT
           data         :numeric, times      :string)    ; INPUT

begin


;  ADD LAND AND SEA MASK
;  b = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc", "r")
;  lsm_data = landsea_mask \
;             (b->LSMASK, data&lat, data&lon)
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
;  COLOR PLOT DEDIRED
   res@cnFillOn                     = True
   res@cnFillMode                   = "RasterFill"
;  res@trGridType                   = "TriangularMesh"
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

;  CHECK FOR DIFFERENT PARAMETERS
   if (element .eq. "acwv") then
      parameter = "Above Cloud Water Vapor (cm)"
      vmin      = 0.0
      vmax      = 100
      vspacing  = 0.5
      lbstride  = 50
   else if (element .eq. "cot16") then
      parameter = "Cloud Optical Thickness 16"
      vmin      = 0
      vmax      = 100
      vspacing  = 0.5
      lbstride  = 50
   end if
   end if

   res@cnMinLevelValF               = vmin
   res@cnMaxLevelValF               = vmax
   res@cnLevelSpacingF              = vspacing
   res@lbLabelStride                = lbstride
   res@lbTitleString                = parameter
   res@tiMainString                 = "SEVIRI " + times

   plot = gsn_csm_contour_map(wks, data, map, res)

;  ADD POLYLINE TO THE CONTOUR PLOT
   plres                  = True
   plres@gsLineColor      = "maroon1"
   plres@gsLineThicknessF = 10.0
   if (.not.all(ismissing(clat)) .and. \
       .not.all(ismissing(clon))) then
      ndim_clat = dimsizes(clat)
      nctrack   = ndim_clat(1)
      dum       = new((/nctrack/), graphic)
;  DO TRACK LOOP TO PLOT TRACK ONE BY ONE
      do ictrack = 0, nctrack-1
         if (.not.all(ismissing(clat(:, ictrack))) .and. \
             .not.all(ismissing(clon(:, ictrack)))) then
            dum(ictrack) = gsn_add_polyline(wks, plot, clon(:, ictrack), clat(:, ictrack), plres)
         end if
      end do
   end if
   draw(plot)
;  frame(wks)
return
end
