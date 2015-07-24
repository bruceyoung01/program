;  $ID: plot_contour_grid_modis_mod04.ncl V01 01/17/2013 15:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_contoue_grid_modis_mod04 PLOTS MODIS MOD04/MYD04 REGRIDDED DATA 
;  DIRECTLY AS CONTOUR WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks           (graphic):WORK STATION                             [   ]
;  (2 ) title        (a string):TITLE FOR THE PLOT                       [   ]
;  (3 ) minlat         (scalar):MINIMUM LATITUDE OF THE STUDY REGION     [   ]
;  (4 ) maxlat         (scalar):MAXIMUM LATITUDE OF THE STUDY REGION     [   ]
;  (5 ) minlon         (scalar):MINIMUM LONGITUDE OF THE STUDY REGION    [   ]
;  (6 ) maxlon         (scalar):MAXIMUM LONGITUDE OF THE STUDY REGION    [   ]
;  (7 ) mlat              (2-D):LATITUDE CORRESPONDING TO mdata          [   ]
;  (8 ) mlon              (2-D):LONGITUDE CORRESPONDING TO mdata         [   ]
;  (9 ) mdata             (2-D):MODIS MOD04/MYD04 DATA                   [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/17/2013)
;******************************************************************************

undef("plot_contour_modis_modis_mod04")
procedure plot_contour_modis_modis_mod04 \
          (wks       :graphic,   title     :string,  \;INPUT
           minlat    :float,     maxlat    :float,   \;INPUT
           minlon    :float,     maxlon    :float,   \;INPUT
           mlat      :float,     mlon      :float,   \;INPUT
           mdata     :float)                          ;INPUT

begin

;  ASSIGN LATITUDE AND LONGITUDE TO THE DATA
   data!0                           = "lat"
   data!1                           = "lon"
   data&lat                         = mlat
   data&lon                         = mlon
   data&lat@units                   ="degrees_north"
   data&lon@units                   ="degrees_east"

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
;  res@cnFillMode                   = "CellFill"
;  res@cnFillMode                   = "RasterFill"
   res@trGridType                   = "TriangularMesh"
;  res@cnMissingValFillColor        = "White"
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnMinLevelValF               = 0.0
   res@cnMaxLevelValF               = 1.0
   res@cnLevelSpacingF              = 0.005
   res@lbLabelStride                = 40

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@pmLabelBarOrthogonalPosF     = 0.15
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelFontThicknessF        = 0.3
   res@lbBoxLinesOn                 = False
;  res@lbTitleString                = "Effective Optical Depth Best Ocean"
   res@lbTitleString                = "Angstrom Exponent Ocean (0.55/0.86 ~F33~m~F21~m)"
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"

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
   draw(plot)
end
