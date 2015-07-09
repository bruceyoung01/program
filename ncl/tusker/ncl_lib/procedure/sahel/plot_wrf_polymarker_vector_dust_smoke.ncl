; $ID: plot_wrf_polymarker_vector_dust_smoke.ncl V01 04/16/2013 10:49 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_wrf_polymarker_vector_dust_smoke PLOTS POLYMARKER WITH 
;  VECTOR OVERLAIED ON IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic): WORK STATION                               [---]
;  (2 ) minlat   (float)  : MINIMUM LATITUDE                           [deg]
;  (3 ) maxlat   (float)  : MAXIMUM LATITUDE                           [deg]
;  (4 ) minlon   (float)  : MINIMUM LONGITUDE                          [deg]
;  (5 ) maxlon   (float)  : MAXIMUM LONGITUDE                          [deg]
;  (6 ) time     (string) : TIME                                       [---]
;  (7 ) u        (float)  : U WIND                                     [m/s]
;  (8 ) v        (float)  : V WIND                                     [m/s]
;  (9 ) data     (float)  : CONTOUR DATA                               [---]
;  (10) plot     (graphic): PLOT                                       [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/16/2013)
;******************************************************************************

undef("plot_wrf_polymarker_vector_dust_smoke")
procedure plot_wrf_polymarker_vector_dust_smoke \
          (wks        :graphic, bv2        :float, \ ; INPUT
           minlat     :float,   maxlat     :float, \ ; INPUT
           minlon     :float,   maxlon     :float, \ ; INPUT
           time       :string,                     \ ; INPUT
           lat        :float,   lon        :float, \ ; INPUT
           u          :float,   v          :float, \ ; INPUT
           data1      :float,   data2      :float)   ; INPUT

begin

   dataa       = new((/dimsizes(data1)/), float, bv2)
   dataa       = 0.0
   dataa@lat2d = lat
   dataa@lon2d = lon

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res                              = True

;  SET UP MAP PROJECTION AND LIMITED REGION
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
   res@mpFillOn                     = False
   res@mpOutlineOn                  = True
   res@mpGeophysicalLineColor       = "white"
   res@mpNationalLineColor          = "white"
   res@mpUSStateLineColor           = "white"
   res@mpGridLineColor              = "white"
   res@mpLimbLineColor              = "white"
   res@mpPerimLineColor             = "white"
   res@mpGeophysicalLineThicknessF  = 3.0
   res@mpGridLineThicknessF         = 1.5
   res@mpLimbLineThicknessF         = 2.0
   res@mpNationalLineThicknessF     = 3.0
   res@mpUSStateLineThicknessF      = 2.0
   res@mpGridLineDashPattern        = 2
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"

;  TURN ON MAP TICKNARKS
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   map  = gsn_csm_map(wks,res)

;  MAXIMIZE PLOT IN FRAME
   res@gsnMaximize                  = True
;  THE DATA IS NOT GLOBAL
   res@gsnAddCyclic                 = False
;  SET UP THE FEATRUED TITLE
   res@gsnLeftString                = "PM2.5 Mass Concentration"
   res@gsnStringFontHeightF         = 0.02
   res@gsnRightStringOrthogonalPosF = 0.02
   res@gsnLeftStringOrthogonalPosF  = 0.02

;  COLOR PLOT DEDIRED
   res@cnFillOn                     = True
;  TURN OFF CONTOUR LINES
   res@cnLinesOn                    = False
;  TURN OFF CONTOUR LABELS
   res@cnLineLabelsOn               = False

;  SET UP COLOR MAP AND LABEL
   res@gsnSpreadColors              = True
   res@gsnSpreadColorStart          = 0
   res@gsnSpreadColorEnd            = 200
   res@cnInfoLabelOn                = False
   res@cnInfoLabelPerimOn           = False
   res@cnLevelSelectionMode         = "ManualLevels"
   res@cnMinLevelValF               = 2.0
   res@cnMaxLevelValF               = 98.0
   res@cnLevelSpacingF              = 2.0

;  SET UP LABEL BAR
   res@pmLabelBarOrthogonalPosF     = 0.085
   res@pmLabelBarParallelPosF       = 0.5
   res@pmLabelBarWidthF             = 0.6
   res@pmLabelBarHeightF            = 0.068
   res@lbLabelFontHeightF           = 0.013
   res@lbLabelStride                = 4
   res@lbBoxLinesOn                 = False

;  SET UP COLOR BAR
   res@tiMainFontHeightF            = 0.02
   res@tiMainString                 = "WRF-Chem Smoke+Dust surface " + time
   res@lbTitleString                = " "
   res@lbTitleFontHeightF           = 0.015
   res@lbTitlePosition              = "Bottom"
;  SET UP VECTOR RESOURCES
   resvc                            = True
   resvc                            = res
   resvc@gsnScalarContour           = True
   resvc@vcRefMagnitudeF            = 10.0
   resvc@vcRefLengthF               = 0.05
   resvc@vcRefAnnoOrthogonalPosF    = -1.0
   resvc@vcRefAnnoArrowLineColor    = "black"
   resvc@vcRefAnnoArrowUseVecColor  = False
   resvc@vcGlyphStyle               = "CurlyVector"
   resvc@vcLineArrowColor           = "white"
   resvc@vcLineArrowThicknessF      = 2.0
   resvc@vcVectorDrawOrder          = "PostDraw"
   resvc@vcMinDistanceF             = 0.03
   dataa@units                      = "~F33~m~F21~g/m~S~3~N~"
   plot = gsn_csm_vector_scalar_map_ce(wks, u, v, dataa, resvc)

;  DRAW POLYGON ON THE PLOT
   minx = 0.0
   maxx = 10.0 
   nx   = 21
   x    = fspan(minx, maxx, nx)
   miny = 0.0
   maxy = 200.0
   ny   = 11
   y    = fspan(miny, maxy, ny)

;  DO VERTICAL AND HORIZONTAL LOOP
   oned_data1 = ndtooned(data1)
   oned_data2 = ndtooned(data2)
   oned_lat   = ndtooned(lat)
   oned_lon   = ndtooned(lon)

;  IGNORE LARGE RATIO WITH SMALL PM2.5
;  index0       = ind(oned_data1 .lt. 2.0 .and. \
;                     oned_data2 .gt. 0.2)
;  if (.not.all(ismissing(index0))) then
;   oned_data1(index0) = oned_data1@_FillValue
;   oned_data2(index0) = oned_data2@_FillValue
;  end if

   plres                    = True
   plres@gsMarkerIndex      = 1
   plres@gsMarkerSizeF      = 0.005
   plres@gsMarkerThicknessF = 10
   plres@tfPolyDrawOrder    = "PreDraw"

   do j = 0, ny-2
    do i = 0, nx-2
    if (.not.all(ismissing(oned_data1)) .and. \
        .not.all(ismissing(oned_data2))) then
     if (i .eq. nx-2 .and. j .gt. 0 .and. j .lt. ny-2) then
      index1 = ind(oned_data1 .gt. x(i) .and. \
                   oned_data2 .ge. y(j) .and. \
                   oned_data2 .lt. y(j+1))
     end if
     if (i .eq. nx-2 .and. j .eq. ny-2) then
       index1 = ind(oned_data1 .gt. x(i)   .and. \
                    oned_data2 .gt. y(j))
     end if
     if (i .eq. nx-2 .and. j .eq. 0) then
       index1 = ind(oned_data1 .gt. x(i)   .and. \
                    oned_data2 .gt. y(j)   .and. \
                    oned_data2 .lt. y(j+1))
     end if
     if (i .eq. 0 .and. j .eq. ny-2) then
       index1 = ind(oned_data1 .gt. x(i)   .and. \
                    oned_data1 .lt. x(i+1) .and. \
                    oned_data2 .gt. y(j))
     end if
     if (i .gt. 0 .and. i .lt. nx-2 .and. j .eq. ny-2) then
       index1 = ind(oned_data1 .ge. x(i)   .and. \
                    oned_data1 .lt. x(i+1) .and. \
                    oned_data2 .gt. y(j))
     end if
     if (i .ge. 0 .and. i .lt. nx-2) then
      if (j .ge. 0 .and. j .lt. ny-2) then
      index1 = ind(oned_data1 .ge. x(i)   .and. \
                   oned_data1 .lt. x(i+1) .and. \
                   oned_data2 .ge. y(j)   .and. \
                   oned_data2 .lt. y(j+1))
      end if
     end if
     color = j*(nx-1) + i + 2
     plres@gsMarkerColor       = color
     if (.not.all(ismissing(index1))) then
      nindex1 = dimsizes(index1)
      do k = 0, nindex1-1
       if (.not.ismissing(oned_lon(index1(k)) .and. \
           .not.ismissing(oned_lat(index1(k))))) then
        gsn_polymarker(wks, plot, oned_lon(index1(k)), oned_lat(index1(k)), plres)
       end if
      end do
     end if
     delete([/index1/])
    else
     print("Both Dust And Smoke Are Missing !!!")
    end if
   end do
  end do
  draw(plot)
  frame(wks)
  delete(res)
  delete(resvc)

return
end
