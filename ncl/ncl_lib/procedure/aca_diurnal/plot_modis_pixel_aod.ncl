;  $ID: plot_modis_pixel_aod.ncl V01 01/17/2013 15:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_modis_pixel_aod PLOTS MODIS PIXEL DATA DIRECTLY AS CONTOUR WITH
;  RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/17/2013)
;******************************************************************************

undef("plot_modis_pixel_aod")
procedure plot_modis_pixel_aod \
          (wks       :graphic,   date      :string,  \;INPUT
           minlat    :float,     maxlat    :float,   \;INPUT
           minlon    :float,     maxlon    :float,   \;INPUT
           mlat      :float,     mlon      :float,   \;INPUT
           maod      :float)                          ;INPUT

begin

;  opt                              = True
;  opt@PrintStat                    = True
;  statb                            = stat_dispersion(maod, opt)
   res                              = True
   res@gsnAddCyclic                 = False
   res@sfXArray                     = mlon
   res@sfYArray                     = mlat

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
  ;res@cnFillMode                   = "CellFill"
   res@cnFillMode                   = "RasterFill"
   res@trGridType                   = "TriangularMesh"
   res@cnMissingValFillColor        = "White"
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnMinLevelValF               = 0.0
   res@cnMaxLevelValF               = 1.0
   res@cnLevelSpacingF              = 0.005

;  SET UP LABEL BAR
   res@pmLabelBarWidthF             = 0.45
   res@pmLabelBarHeightF            = 0.07
   res@lbLabelFontHeightF           = 0.015
   res@lbLabelStride                = 40
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
   res@mpGridLatSpacingF            = 10.0
   res@mpGridLonSpacingF            = 10.0
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
   res@vpHeightF                    = 0.65
   res@vpXF                         = 0.15
   res@vpYF                         = 0.85
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   res@tiMainString                 = "MODIS " + date
   res@tiMainFontHeightF            = 0.02
   plot = gsn_csm_contour_map_ce(wks, maod, res)
   draw(plot)
end
