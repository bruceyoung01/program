;  $ID: plot_viirs_pixel_rad_epa_liu_kml.ncl V01 01/17/2013 15:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_pixel_rad_epa_liu_kml PLOTS VIIRS PIXEL DATA DIRECTLY AS 
;  CONTOUR WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2013)
;******************************************************************************

undef("plot_viirs_pixel_rad_epa_liu_kml")
procedure plot_viirs_pixel_rad_epa_liu_kml \
          (wks       :graphic,   date      :string,  \ ; INPUT
           nsite     :integer,                       \ ; INPUT
           minlat    :float,     maxlat    :float,   \ ; INPUT
           minlon    :float,     maxlon    :float,   \ ; INPUT
           slat      :float,     slon      :float,   \ ; INPUT
           sza       :float,     moonphase :float,   \ ; INPUT
           lza       :float,                         \ ; INPUT
           srel      :float,     maod      :float,   \ ; INPUT
           plot      :graphic)                         ; OUTPUT

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
   res@cnMaxLevelValF       = 0.1
   res@cnLevelSpacingF      = 0.01

   res@lbLabelBarOn         = True
   res@lbAutoManage         = False
   res@lbOrientation        = "horizontal"
   res@lbLabelFontHeightF   = 0.004
   res@lbTitlePosition      = "Bottom"
   res@lbTitleString        = "~F33~m~F21~Wcm~S~-2~N~str~S~-1~N~"
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

; TURN ON MAP TICKNARKS
  gsn_define_colormap(wks,"BlGrYeOrReVi200")
  maxlevel = 32
  minlevel = 2
  linterval= 2
  maxclevel= 184
  minclevel= 4
  cinterval= 12
  nlevel   = (maxclevel-minclevel)/cinterval+1
; # OF COLORS SHOULD BE LARGER THAN LABELS BY 1
  labels   = ispan(minlevel,  maxlevel,  linterval)
  colors   = ispan(minclevel, maxclevel, cinterval)
  print(labels)
  print(colors)
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues


  lbres                    = True          ; labelbar only resources
  lbres@lbLabelBarOn       = False
  lbres@lbAutoManage       = False         ; Necessary to control sizes
  lbres@vpWidthF           = 0.08          ; labelbar width
  lbres@vpHeightF          = 0.6           ; labelbar height
  lbres@vpXF               = 0.91          ; the location of left edge
  lbres@vpYF               = 0.87          ; the location of top edge
  lbres@lbBoxMajorExtentF  = 1.0           ; puts space between color boxes
  lbres@lbLabelStride      = 2
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.02         ; font height. default is small
  lbres@lbLabelAlignment   = "InteriorEdges"
  lbres@lbFillColors       = colors
  lbres@lbPerimOn          = False
  lbres@lbBoxLinesOn       = False
  lbres@lbTitleFontHeightF = 15.0
  lbres@lbTitleFontThicknessF = 1.0
  lbres@lbTitleString      = "(~F33~m~F21~g/m~S~3~N~)"
  lbid = gsn_create_labelbar(wks,nlevel,labels*1.0,lbres)
  draw(lbid)

;  DO SITE LOOP
   do is = 0, nsite-1
    if (.not.ismissing(srel(is))) then
    print(srel(is))
     cres = True
     if(srel(is).lt.minlevel)then
      srel(is) = minlevel
     end if
     if(srel(is).gt.maxlevel)then
      srel(is) = maxlevel
     end if
     tpmcolor = cinterval*toint((srel(is)-minlevel)/(maxlevel-minlevel)*(nlevel-1)) + minclevel
     print("color = " + tpmcolor)
     do j=0, nlevel-1
      if(tpmcolor.eq.colors(j))then
       scolor=colors(j)
      end if
      if(j.gt.0.and.tpmcolor.gt.colors(j).and.tpmcolor.lt.colors(j+1) .and. j .lt. nlevel-1)then
       scolor=colors(j)
      end if
      if(j .eq. nlevel-1 .and. tpmcolor.ge.colors(nlevel-1))then
print(tpmcolor)
print("max" + colors(nlevel-1))

       scolor=colors(nlevel-1)
      end if
     end do
     print("scolor = " + scolor)
     cres@gsMarkerColor = scolor
     if (is .lt. nsite-1) then
      cres@gsMarkerIndex      = 16
      cres@gsMarkerSizeF      = 0.025
      cres@gsMarkerThicknessF = 0.3
     else
      cres@gsMarkerIndex      = 12
      cres@gsMarkerSizeF      = 0.025
      cres@gsMarkerThicknessF = 5
     end if
     cres@tfPolyDrawOrder     = "PreDraw"
     gsn_polymarker(wks, plot, slon(is), slat(is), cres)
     delete(cres)
    else if (ismissing(srel(is))) then
     cres                     = True
     cres@gsMarkerColor       = "White"
     if (is .lt. nsite-1) then
      cres@gsMarkerIndex      = 16
      cres@gsMarkerSizeF      = 0.025
      cres@gsMarkerThicknessF = 0.3
     else
      cres@gsMarkerIndex      = 12
      cres@gsMarkerSizeF      = 0.025
      cres@gsMarkerThicknessF = 5
     end if
     cres@tfPolyDrawOrder     = "PreDraw"
     gsn_polymarker(wks, plot, slon(is), slat(is), cres)
     delete(cres)
    end if
    end if
   end do
  frame(wks)

end
