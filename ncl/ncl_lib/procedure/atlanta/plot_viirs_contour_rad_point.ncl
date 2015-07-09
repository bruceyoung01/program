;  $ID: plot_viirs_contour_rad_point.ncl V01 02/04/2013 15:46 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_contour_rad_point PLOTS VIIRS GRIDDED DATA DIRECTLY AS 
;  CONTOUR WITH RASTERFILL, AND OVERLAID WITH EPA PM OBSERVATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/04/2013)
;******************************************************************************

undef("plot_viirs_contour_rad_point")
procedure plot_viirs_contour_rad_point \
          (wks       :graphic,    date      :string,  \; INPUT
           nsite     :integer,                        \; INPUT
           minlat    :float,      maxlat    :float,   \; INPUT
           minlon    :float,      maxlon    :float,   \; INPUT
           slat      :float,      slon      :float,   \; INPUT
           sza       :float,      moonphase :float,   \; INPUT
           lza       :float,      maod      :float)    ; INPUT

begin
   gsn_define_colormap(wks, "gsdtol")
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

   res@lbAutoManage         = False
   res@lbOrientation        = "horizontal"
   res@lbLabelFontHeightF   = 0.004
   res@lbTitlePosition      = "Bottom"
   res@lbTitleString        = "Wm~S~-2~N~str~S~-1~N~~F33~m~F21~m~S~-1~N~"
   res@lbTitleFontHeightF   = 0.004
   res@pmLabelBarWidthF     = 0.15
   res@pmLabelBarHeightF    = 0.02

   res@mpProjection         = "CylindricalEquidistant"
   res@mpCenterRotF         = 0.0
   res@mpGridAndLimbOn      = True
   res@mpLimitMode          = "latlon"
   res@mpMinLatF            = minlat
   res@mpMaxLatF            = maxlat
   res@mpMinLonF            = minlon
   res@mpMaxLonF            = maxlon
   res@mpGridLatSpacingF    = 5.0
   res@mpGridLonSpacingF    = 5.0
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
   res@mpGridLineDashPattern        = 2
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
   res@mpFillOn                     = False
   res@mpOutlineOn                  = True
;  res@mpOutlineBoundarySets        = "AllBoundaries"
;  res@mpDataSetName                = "Earth..4"
;  res@mpDataBaseVersion            = "MediumRes"
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@tiMainString                 = date + " MP: " + sprintf("%-7.2f", moonphase) + \
                                      " LZA: " + sprintf("%-7.2f", lza) + \
                                      " VZA: " + sprintf("%-7.2f", sza)
   res@tiMainFontHeightF            = 0.004
   res@vpXF                         = 0.1
   res@vpYF                         = 0.8
   res@vpWidthF                     = 0.15
   res@vpHeightF                    = 0.2
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   plot = gsn_csm_contour_map_ce(wks, maod, res)
   draw(plot)

   cres                    = True
   cres@gsMarkerColor      = "Red"
   cres@gsMarkerIndex      = 16
   cres@gsMarkerSizeF      = 0.015
   cres@gsMarkerThicknessF = 0.3
   cres@tfPolyDrawOrder    = "PreDraw"
;  DO SITE LOOP
   do is = 0, nsite-1
      gsn_polymarker(wks, plot, slon(is), slat(is), cres)
   end do
  frame(wks)

end
