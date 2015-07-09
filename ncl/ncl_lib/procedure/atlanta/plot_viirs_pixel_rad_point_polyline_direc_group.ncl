;  $ID: plot_viirs_pixel_rad_point_polyline_direc_group.ncl V01 01/17/2013 15:26 
;       BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_pixel_rad_point_polyline_direc_group PLOTS VIIRS PIXEL DATA 
;  DIRECTLY AS CONTOUR WITH RASTERFILL, ADD POINT AND POLYLINE WITH SCANNING 
;  DIRECTION.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2013)
;******************************************************************************

undef("plot_viirs_pixel_rad_point_polyline_direc_group")
procedure plot_viirs_pixel_rad_point_polyline_direc_group \
          (wks       :graphic,   date      :string,  \ ; INPUT
           nsite     :integer,                       \ ; INPUT
           minlat    :float,     maxlat    :float,   \ ; INPUT
           minlon    :float,     maxlon    :float,   \ ; INPUT
           slat      :float,     slon      :float,   \ ; INPUT
           mlatn     :float,     mlonn     :float,   \ ; INPUT
           mlatl     :float,     mlonl     :float,   \ ; INPUT
           sza       :float,     moonphase :float,   \ ; INPUT
           lza       :float,     maod      :float,   \ ; INPUT
           plot      :graphic)                         ; OUTPUT

begin

   gsn_define_colormap(wks, "gsdtol")
   res                      = True
   res@gsnAddCyclic         = False
   
;---This resource not needed in V6.1.0
   res@gsnSpreadColors              = True  
   res@gsnMaximize                  = True
   res@gsnPaperOrientation          = "portrait"
     
   res@cnFillOn                     = True  
   res@cnLinesOn                    = False
   res@cnLineLabelsOn               = False
  ;res@cnFillMode                   = "CellFill"
   res@cnFillMode                   = "RasterFill"
   
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnMinLevelValF               = 0.0
   res@cnMaxLevelValF               = 1.0
   res@cnLevelSpacingF              = 0.1

   res@lbAutoManage                 = False
   res@lbOrientation                = "horizontal"
   res@lbLabelFontHeightF           = 0.004
   res@lbTitlePosition              = "Bottom"
   res@lbTitleString                = "Radiance 700nm (Wm~S~-2~N~str~S~-1~N~~F33~m~F21~m~S~-1~N~)"
   res@lbTitleFontHeightF           = 0.004
   res@lbTopMarginF                 = 0.3
   res@pmLabelBarWidthF             = 0.15
   res@pmLabelBarHeightF            = 0.02
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
   res@mpGeophysicalLineThicknessF  = 3.0
   res@mpGridLineThicknessF         = 1.5
   res@mpLimbLineThicknessF         = 2.0
   res@mpNationalLineThicknessF     = 3.0
   res@mpUSStateLineThicknessF      = 1.5
   res@mpCountyLineThicknessF       = 1.5
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
;  draw(plot)


   cres                    = True
   cres@gsMarkerColor      = "Red"
   cres@gsMarkerIndex      = 16
   cres@gsMarkerSizeF      = 0.01
   cres@gsMarkerThicknessF = 4
   cres@tfPolyDrawOrder    = "PostDraw"
;  DO SITE LOOP
   do is = 0, nsite-1
      dum1 = gsn_add_polymarker(wks, plot, slon(is), slat(is), cres)
   end do

;  ADD POLYLINE ON THE MAP
   plres                   = True
   plres@gsLineColor       = "orange"
   plres@gsLineThicknessF  = 2.0
   dum2 = gsn_add_polyline(wks, plot, mlonl, mlatl, plres)
   dum3 = gsn_add_polyline(wks, plot, mlonn, mlatn, plres)

;  ADD SCANNING DIRECTION
   ndim = dimsizes(mlatl)
   sp   = ndim(0)/2
   cres@gsMarkerColor      = "orange"
   if (mlonl(0) .gt. mlonl(ndim(0)-1)) then
      cres@gsMarkerIndex      = 10
   else if (mlonl(0) .lt. mlonl(ndim(0)-1)) then
      cres@gsMarkerIndex      = 11
   end if
   end if
   dum4 = gsn_add_polymarker(wks, plot, mlonl(sp), mlatl(sp), cres)
   str1 = unique_string("dum1")
   str2 = unique_string("dum2")
   str3 = unique_string("dum3")
   str4 = unique_string("dum4")
   plot@$str1$ = dum1
   plot@$str2$ = dum2
   plot@$str3$ = dum3
   plot@$str4$ = dum4
;  draw(plot)
;  frame(wks)

end
