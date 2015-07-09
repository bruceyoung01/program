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
          (wks       : graphic,  date      :string,  \ ; INPUT
           minlat    :float,     maxlat    :float,   \ ; INPUT
           minlon    :float,     maxlon    :float,   \ ; INPUT
           maod      :float)                           ; INPUT

begin

   opt           = True
   opt@PrintStat = True
   statb         = stat_dispersion(maod, opt)
   res                      = True
   res@gsnAddCyclic         = False
   
;---This resource not needed in V6.1.0
   res@gsnSpreadColors      = True  
   res@gsnMaximize          = True
   res@gsnPaperOrientation  = "portrait"
     
   res@cnFillOn             = True  
   res@cnLinesOn            = False
   res@cnLineLabelsOn       = False
  ;res@cnFillMode           = "CellFill"
   res@cnFillMode           = "RasterFill"
   
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF       = 0.0
   res@cnMaxLevelValF       = 1.0
   res@cnLevelSpacingF      = 0.1

   res@lbOrientation        = "vertical"
   res@lbLabelFontHeightF   = 0.016
   res@lbTitleString        = " "
   res@lbTitleFontHeightF   = 0.015
   res@pmLabelBarWidthF     = 0.1

   res@mpProjection         = "CylindricalEquidistant"
   res@mpCenterRotF         = 0.0
   res@mpGridAndLimbOn      = True
   res@mpLimitMode          = "latlon"
   res@mpMinLatF            = minlat
   res@mpMaxLatF            = maxlat
   res@mpMinLonF            = minlon
   res@mpMaxLonF            = maxlon
   res@mpGridLatSpacingF    = 10.0
   res@mpGridLonSpacingF    = 10.0
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
   res@tiMainString                 = "MODIS AOD (500 nm)  " + date
   plot = gsn_csm_contour_map_ce(wks, maod, res)
end
