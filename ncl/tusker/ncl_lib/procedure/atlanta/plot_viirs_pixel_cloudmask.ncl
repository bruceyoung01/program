;  $ID: plot_viirs_pixel_cloudmask.ncl V01 01/17/2013 15:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_pixel_cloudmask PLOTS VIIRS PIXEL DATA DIRECTLY AS 
;  CONTOUR WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/17/2013)
;******************************************************************************

undef("plot_viirs_pixel_cloudmask")
procedure plot_viirs_pixel_cloudmask \
          (wks       : graphic,  date      :string,  \ ; INPUT
           lat       :float,     lon       :float,   \ ; INPUT
           maod      :float)                           ; INPUT

begin
   res                      = True
   res@gsnAddCyclic         = False
   res@sfXArray             = lon
   res@sfYArray             = lat
   
;---This resource not needed in V6.1.0
   res@gsnSpreadColors      = True  
   res@gsnMaximize          = True
   res@gsnPaperOrientation  = "portrait"
     
   res@cnFillOn             = True  
   res@cnLinesOn            = False
   res@cnLineLabelsOn       = False
  ;res@cnFillMode           = "CellFill"
   res@cnFillMode           = "RasterFill"
   res@cnFillColors         = (/"Black", "White", "White"/)
   
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF       = 0.5
   res@cnMaxLevelValF       = 1.0
   res@cnLevelSpacingF      = 0.5

   res@lbOrientation        = "vertical"
   res@lbLabelFontHeightF   = 0.016
   res@lbTitleString        = " "
   res@lbTitleFontHeightF   = 0.015
   res@lbLabelAlignment     = "BoxCenters"
   res@lbLabelStrings       = (/"Cloud", "Clear", ""/)
   res@pmLabelBarWidthF     = 0.1

   res@mpProjection         = "CylindricalEquidistant"
   res@mpCenterRotF         = 0.0
   res@mpGridAndLimbOn      = True
   res@mpLimitMode          = "latlon"
   res@mpMinLatF            =  33.0
   res@mpMaxLatF            =  34.5
   res@mpMinLonF            = -85.1
   res@mpMaxLonF            = -83.5
   res@mpGridLatSpacingF    = 0.2
   res@mpGridLonSpacingF    = 0.2
;  COLOR OF CONTINIENTAL OUTLINES
   res@mpOutlineOn                  = True
   res@mpGeophysicalLineColor       = "Black"
   res@mpNationalLineColor          = "Black"
   res@mpUSStateLineColor           = "green"
   res@mpCountyLineColor            = "cyan"
   res@mpGridLineColor              = "Black"
   res@mpLimbLineColor              = "Black"
   res@mpPerimLineColor             = "Black"
   res@mpGeophysicalLineThicknessF  = 3.0
   res@mpGridLineThicknessF         = 1.5
   res@mpLimbLineThicknessF         = 2.0
   res@mpNationalLineThicknessF     = 3.0
   res@mpUSStateLineThicknessF      = 3.0
   res@mpCountyLineThicknessF       = 1.5
   res@mpGridLineDashPattern        = 2
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
   res@mpFillOn                     = False
   res@mpOutlineOn                  = True
   res@mpOutlineBoundarySets        = "AllBoundaries"
   res@mpDataSetName                = "Earth..4"
   res@mpDataBaseVersion            = "MediumRes"
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@tiMainString                 = "VIIRS Cloud Mask  " + date
   plot = gsn_csm_contour_map_ce(wks, maod, res)
end
