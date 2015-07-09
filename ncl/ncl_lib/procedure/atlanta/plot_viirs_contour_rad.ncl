;  $ID: plot_viirs_contour_rad.ncl V01 02/18/2014 23:34 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_contour_rad PLOTS VIIRS GRIDDED DATA DIRECTLY AS CONTOUR 
;  WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/18/2014)
;******************************************************************************

undef("plot_viirs_contour_rad")
procedure plot_viirs_contour_rad \
          (wks       :graphic,                      ; INPUT
           minlat    :float,      maxlat    :float, ; INPUT
           minlon    :float,      maxlon    :float, ; INPUT
           date      :string,     mrad      :float) ; INPUT

begin

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
   res@pmLabelBarWidthF     = 0.1

   res@mpProjection         = "CylindricalEquidistant"
   res@mpCenterRotF         = 0.0
   res@mpGridAndLimbOn      = True
   res@mpLimitMode          = "latlon"
   res@mpMinLatF            = minlat
   res@mpMaxLatF            = maxlat
   res@mpMinLonF            = minlon
   res@mpMaxLonF            = maxlon
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
   res@tiMainString                 = "VIIRS RADIANCE (700 nm)  " + date
   plot = gsn_csm_contour_map_ce(wks, mrad, res)
end
