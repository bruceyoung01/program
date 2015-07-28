;  $ID: plot_contour_grid_aca_modis_caliop_pl.ncl V01 07/27/2015 21:23 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_contour_grid_aca_modis_caliop_pl.ncl READS MODIS MOD04/MYD04 
;  AND MODIS MOD06_L2/MYD06_L2 REGRIDDED DATA GENERATED FROM 
;  write_modis_caliop_aca/write_modis_caliop_aca.ncl AND PLOTS THE DATA AS 
;  CONTOUR WITH RASTERFILL WITH THE CALIPSO GROUND TRACK.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks           (graphic):WORK STATION                             [   ]
;  (2 ) title        (a string):TITLE FOR THE PLOT                       [   ]
;  (3 ) case              (1-D):CASE NAMES                               [   ]
;  (4 ) minlat         (scalar):MINIMUM LATITUDE OF THE STUDY REGION     [DEG]
;  (5 ) maxlat         (scalar):MAXIMUM LATITUDE OF THE STUDY REGION     [DEG]
;  (6 ) minlon         (scalar):MINIMUM LONGITUDE OF THE STUDY REGION    [DEG]
;  (7 ) maxlon         (scalar):MAXIMUM LONGITUDE OF THE STUDY REGION    [DEG]
;  (8 ) clat            (float):CALIPSO GROUND TRACK LATITUDE            [DEG]
;  (9 ) clon            (float):CALIPSO GROUND TRACK LONGITUDE           [DEG]
;  (10) mlat              (1-D):LATITUDE CORRESPONDING TO mdata          [DEG]
;  (11) mlon              (1-D):LONGITUDE CORRESPONDING TO mdata         [DEG]
;  (12) mdata             (2-D):MODIS MOD04/MYD04 DATA                   [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/17/2013)
;  (2 ) ADDING CALIPSO GROUND TRACK. (07/27/2015)
;******************************************************************************

undef("plot_contour_grid_aca_modis_caliop_pl")
procedure plot_contour_grid_aca_modis_caliop_pl \
          (wks       :graphic,   title     :string,  \;INPUT
           case      :string,                        \;INPUT
           minlat    :float,     maxlat    :float,   \;INPUT
           minlon    :float,     maxlon    :float,   \;INPUT
           clat      :float,     clon      :float,   \;INPUT
           mlat      :float,     mlon      :float,   \;INPUT
           mdata     :float)                          ;INPUT

begin

;  ASSIGN LATITUDE AND LONGITUDE TO THE DATA
   mdata!0                          = "lat"
   mdata!1                          = "lon"
   mdata&lat                        = mlat
   mdata&lon                        = mlon
   mdata&lat@units                  ="degrees_north"
   mdata&lon@units                  ="degrees_east"

;  opt                              = True
;  opt@PrintStat                    = True
;  statb                            = stat_dispersion(maod, opt)
   res                              = True
   res@gsnAddCyclic                 = False

;---This resource not needed in V6.1.0
;  SET UP COLOR MAP AND LABEL
   res@gsnSpreadColors              = False
   res@gsnSpreadColorStart          = 0
   res@gsnSpreadColorEnd            = 200
   res@gsnMaximize                  = True
;  res@gsnPaperOrientation          = "portrait"
   res@cnFillOn                     = True
   res@cnLinesOn                    = False
   res@cnLineLabelsOn               = False
   res@cnConstFEnableFill           = True
   res@cnConstFLabelFontHeightF     = 0
;  res@cnFillMode                   = "CellFill"
   res@cnFillMode                   = "RasterFill"
;  res@trGridType                   = "TriangularMesh"
   res@cnMissingValFillColor        = "White"
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnMinLevelValF               = 0.0
   res@cnMaxLevelValF               = 2.0
   res@cnLevelSpacingF              = 1.0
   res@lbLabelStride                = 1
   res@lbLabelStrings               = case

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@pmLabelBarOrthogonalPosF     = 0.15
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelFontThicknessF        = 0.3
   res@lbBoxLinesOn                 = False
   res@lbTitleString                = "ACA Cases"
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"
   res@lbLabelAlignment             = "BoxCenters"

   res@mpProjection                 = "CylindricalEquidistant"
   res@mpCenterRotF                 = 0.0
   res@mpGridAndLimbOn              = True
   res@mpLimitMode                  = "latlon"
   res@mpMinLatF                    = minlat
   res@mpMaxLatF                    = maxlat
   res@mpMinLonF                    = minlon
   res@mpMaxLonF                    = maxlon
   res@mpGridLatSpacingF            = 5.0
   res@mpGridLonSpacingF            = 5.0
;  COLOR OF CONTINIENTAL OUTLINES
   res@mpOutlineOn                  = True
   res@mpGeophysicalLineColor       = "Black"
   res@mpNationalLineColor          = "Black"
   res@mpUSStateLineColor           = "green"
   res@mpCountyLineColor            = "cyan"
   res@mpGridLineColor              = "Black"
   res@mpLimbLineColor              = "Black"
   res@mpPerimLineColor             = "Black"
   res@mpGeophysicalLineThicknessF  = 1.0
   res@mpGridLineThicknessF         = 1.0
   res@mpLimbLineThicknessF         = 1.0
   res@mpNationalLineThicknessF     = 1.0
   res@mpUSStateLineThicknessF      = 1.0
   res@mpCountyLineThicknessF       = 1.0
   res@mpGridLineDashPattern        = 2
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
   res@mpFillOn                     = False
   res@mpOutlineOn                  = True
   res@mpOutlineBoundarySets        = "AllBoundaries"
   res@mpDataSetName                = "Earth..4"
   res@mpDataBaseVersion            = "MediumRes"
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"

; SET UP THE POSITION
   res@vpWidthF                     = 0.7
   res@vpHeightF                    = 0.25
   res@vpXF                         = 0.15
   res@vpYF                         = 0.85
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   res@tiMainString                 = "MODIS " + title
   res@tiMainFontHeightF            = 0.02
   plot = gsn_csm_contour_map_ce(wks, mdata, res)

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
end
