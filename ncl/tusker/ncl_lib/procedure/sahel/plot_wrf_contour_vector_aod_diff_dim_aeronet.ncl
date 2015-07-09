;  $ID: plot_wrf_contour_vector_aod_diff_dim_aeronet.ncl V01 05/16/2012 15:00 
;  BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_vector_aod_diff_dim_aeronet PLOTS CONTOUR WITH VECTOR 
;  OVERLAIED AND AERONET AOD ON IT
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic): WORK STATION                               [---]
;  (2 ) minlat   (float)  : MINIMUM LATITUDE                           [deg]
;  (3 ) maxlat   (float)  : MAXIMUM LATITUDE                           [deg]
;  (4 ) minlon   (float)  : MINIMUM LONGITUDE                          [deg]
;  (5 ) maxlon   (float)  : MAXIMUM LONGITUDE                          [deg]
;  (6 ) lat      (float)  : AERONET SITE LATITUDE                      [deg]
;  (7 ) lon      (float)  : AERONET SITE LONGITUDE                     [deg]
;  (8 ) aaod     (float)  : AERONET SITE AOD                           [---]
;  (9 ) time     (string) : TIME                                       [---]
;  (10) u        (float)  : U WIND                                     [m/s]
;  (11) v        (float)  : V WIND                                     [m/s]
;  (12) data     (float)  : CONTOUR DATA                               [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/16/2012)
;  (2 ) MODIFIED FROM plot_wrf_contour_vector_aod_diff_dim.ncl. (04/03/2013)
;******************************************************************************

undef("plot_wrf_contour_vector_aod_diff_dim_aeronet")
procedure plot_wrf_contour_vector_aod_diff_dim_aeronet \
          (wks        :graphic,                    \ ; INPUT
           minlat     :float,   maxlat     :float, \ ; INPUT
           minlon     :float,   maxlon     :float, \ ; INPUT
           lat        :float,   lon        :float, \ ; INPUT
           aaod       :float,   time       :string,\ ; INPUT
           u          :float,   v          :float, \ ; INPUT
           data       :float)                      \ ; INPUT

begin

   map = new(1, graphic)
;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res                              = True

;  SET UP MAP PROJECTION AND LIMITED REGION
   res@mpFillOn                     = False
   res@mpProjection                 = "CylindricalEquidistant"
   res@mpCenterRotF                 = 0.0
   res@mpGridAndLimbOn              = True
   res@mpGridLatSpacingF            = 15.0
   res@mpGridLonSpacingF            = 15.0
   res@mpLimitMode                  = "latlon"
   res@mpMinLatF                    = minlat
   res@mpMaxLatF                    = maxlat
   res@mpMinLonF                    = minlon
   res@mpMaxLonF                    = maxlon
;  COLOR OF CONTINIENTAL OUTLINES
   res@mpOutlineOn                  = True
   res@mpGeophysicalLineColor       = "Black"
   res@mpNationalLineColor          = "Black"
   res@mpUSStateLineColor           = "Black"
   res@mpGridLineColor              = "Black"
   res@mpLimbLineColor              = "Black"
   res@mpPerimLineColor             = "Black"
   res@mpGeophysicalLineThicknessF  = 1.5
   res@mpGridLineThicknessF         = 1.0
   res@mpLimbLineThicknessF         = 1.0
   res@mpNationalLineThicknessF     = 1.0
   res@mpUSStateLineThicknessF      = 1.0
   res@mpGridLineDashPattern        = 2
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"

;  TURN ON MAP TICKNARKS
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   map  = gsn_csm_map(wks,res)

;  MAXIMIZE PLOT IN FRAME
   resc                             = True
   resc                             = res
   resc@gsnMaximize                 = True
;  THE DATA IS NOT GLOBAL
   resc@gsnAddCyclic                = False

;  SET UP THE FEATRUED TITLE
   resc@gsnLeftString               = "Aerosol Optical Depth"
   resc@gsnStringFontHeightF        = 0.02
   resc@gsnRightStringOrthogonalPosF= 0.02
   resc@gsnLeftStringOrthogonalPosF = 0.02

;  COLOR PLOT DEDIRED
   resc@cnFillOn                    = True
;  TURN OFF CONTOUR LINE
   resc@cnLinesOn                   = False
;  TURN OFF CONTOUR LABELS
   resc@cnLineLabelsOn              = False

;  SET UP COLOR MAP AND LABEL
   resc@gsnSpreadColors             = True
   resc@gsnSpreadColorStart         = 0
   resc@gsnSpreadColorEnd           = 200
   resc@cnInfoLabelOn               = False
   resc@cnInfoLabelPerimOn          = False
   resc@cnLevelSelectionMode        = "ManualLevels"
   resc@cnMinLevelValF              = 0.0
   resc@cnMaxLevelValF              = 1.0
   resc@cnLevelSpacingF             = 0.05

;  SET UP LABEL BAR
   resc@pmLabelBarOrthogonalPosF    = 0.085
   resc@pmLabelBarParallelPosF      = 0.5
   resc@pmLabelBarWidthF            = 0.6
   resc@pmLabelBarHeightF           = 0.068
   resc@lbLabelFontHeightF          = 0.013
   resc@lbLabelStride               = 2
   resc@lbBoxLinesOn                = False

;  SET UP COLOR BAR
   resc@tiMainFontHeightF           = 0.02
   resc@tiMainString                = "MODIS AOD (550 nm) Wind Monthly Average      " + time
   resc@lbTitleString               = "AOD (550nm)"
   resc@lbTitleFontHeightF          = 0.015
   resc@lbTitlePosition             = "Bottom"
;  SET UP VECTOR RESOURCES
   resvc                            = True
   resvc@vcRefMagnitudeF            = 10.0
   resvc@vcRefLengthF               = 0.08
   resvc@vcRefAnnoOrthogonalPosF    = -1.0
   resvc@vcRefAnnoArrowLineColor    = "black"
   resvc@vcRefAnnoArrowUseVecColor  = False
   resvc@vcGlyphStyle               = "CurlyVector"
   resvc@vcLineArrowColor           = "black"
   resvc@vcLineArrowThicknessF      = 1.5
   resvc@vcVectorDrawOrder          = "PostDraw"
   resvc@vcMinDistanceF             = 0.04
   resvc@gsnDraw                    = False
   resvc@gsnFrame                   = False
   data@units                       = " "
   plot1 = gsn_csm_vector_map_ce(wks, u, v, map, resvc)
   plot2 = gsn_csm_contour_map_ce(wks, data, map, resc)
   draw(plot1)
   draw(plot2)

; TURN ON MAP TICKNARKS
  gsn_define_colormap(wks,"WhAqGrYeOrReVi200")
; =============================================================================
; METHOD3 TO SPECIFY COLOR TABLE AND LABELS (BEST TO USE)
  nfactor  = 100
  maxlevel = 1.05
  minlevel = 0
  interval = 0.05
  maxclevel= 210
  minclevel= 0
  nlevel   = floattoint((maxlevel-minlevel)/interval) + 2
; # OF COLORS SHOULD BE LARGER THAN LABELS BY 1
  labels   = round(fspan(minlevel,  maxlevel,  nlevel)*nfactor, 2)/nfactor
  colors   = floattoint(fspan(minclevel, maxclevel, nlevel+1))
  ncolors  = dimsizes(colors)
  cinterval= (maxclevel-minclevel)/ncolors
; print(labels)
; print(colors)
  getvalues plot2
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True
  lbres@lbAutoManage       = False
  lbres@vpWidthF           = 0.08
  lbres@vpHeightF          = 0.6
  lbres@vpXF               = 0.91
  lbres@vpYF               = 0.87
  lbres@lbBoxMajorExtentF  = 1.0
  lbres@lbLabelStride      = 2
  lbres@lbMonoFillPattern  = True
  lbres@lbLabelFontHeightF = 0.02
  lbres@lbLabelAlignment   = "InteriorEdges"
  lbres@lbFillColors       = colors
  lbres@lbPerimOn          = False
  lbres@lbBoxLinesOn       = False
  lbres@lbTitleFontHeightF = 10.0
  lbres@lbTitleFontThicknessF = 1.0
  lbres@lbTitleString      = "AOD(550nm)"
  lbid = gsn_create_labelbar(wks,nlevel,labels*1.0,lbres)
  draw(lbid)

;  DO SITE LOOP
   nsite = dimsizes(lat)
   do is = 0, nsite-1
    if (.not.ismissing(aaod(is))) then
;   print(aaod(is))
     cres = True
     if(aaod(is).lt.minlevel)then
      aaod(is) = minlevel
     end if
     if(aaod(is).gt.maxlevel)then
      aaod(is) = maxlevel
     end if
     tpmcolor = cinterval*(toint((aaod(is)-minlevel)/(maxlevel-minlevel)*(nlevel))+1) + minclevel
;    print("color = " + tpmcolor)
     do j=0, nlevel
      if(tpmcolor.eq.colors(j))then
       scolor=colors(j)
      end if
      if(j.gt.0.and.tpmcolor.gt.colors(j).and.tpmcolor.lt.colors(j+1) .and. j .lt. nlevel)then
       scolor=colors(j)
      end if
      if(j .eq. nlevel .and. tpmcolor.ge.colors(nlevel))then
;     print(tpmcolor)
;     print("max" + colors(nlevel))
       scolor=colors(nlevel)
      end if
     end do
;    print("scolor = " + scolor)
     cres@gsMarkerColor       = scolor
     cres@gsMarkerIndex       = 16
     cres@gsMarkerSizeF       = 0.015
     cres@gsMarkerThicknessF  = 0.3
     cres@tfPolyDrawOrder     = "PreDraw"
     cresa                    = True
     cresa                    = cres
     cresa@gsMarkerColor      = 1
     cresa@gsMarkerIndex      = 16
     cresa@gsMarkerSizeF      = 0.022
     cresa@gsMarkerThicknessF = 0.3
     gsn_polymarker(wks, map, lon(is), lat(is), cresa)
     gsn_polymarker(wks, map, lon(is), lat(is), cres)
     delete(cres)
    end if
   end do
   frame(wks)

   delete([/res, resc, resvc/])

return
end
