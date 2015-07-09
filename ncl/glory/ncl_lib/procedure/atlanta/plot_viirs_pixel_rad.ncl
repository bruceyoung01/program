;  $ID: plot_viirs_pixel_rad.ncl V01 01/17/2013 15:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_pixel_rad PLOTS VIIRS PIXEL DATA DIRECTLY AS CONTOUR WITH
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

undef("plot_viirs_pixel_rad")
procedure plot_viirs_pixel_rad \
          (wks       : graphic,  date      :string,  \ ; INPUT
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
   res@lbTitleString        = "Wm~S~-2~N~str~S~-1~N~~F33~m~F21~m~S~-1~N~"
   res@lbTitleFontHeightF   = 0.015
   res@pmLabelBarWidthF     = 0.1

   res@mpProjection         = "CylindricalEquidistant"
   res@mpCenterRotF         = 0.0
   res@mpGridAndLimbOn      = True
   res@mpLimitMode          = "latlon"
   res@mpMinLatF            =  33.0
   res@mpMaxLatF            =  34.5
   res@mpMinLonF            = -85.5
   res@mpMaxLonF            = -83.5
   res@mpGridLatSpacingF    = 0.2
   res@mpGridLonSpacingF    = 0.2
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
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
   res@mpFillOn                     = False
   res@mpOutlineOn                  = True
   res@mpOutlineBoundarySets        = "AllBoundaries"
   res@mpDataSetName                = "Earth..4"
   res@mpDataBaseVersion            = "MediumRes"
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@tiMainString                 = "VIIRS DNB (700 nm)  " + date
   plot = gsn_csm_contour_map_ce(wks, maod, res)
end
