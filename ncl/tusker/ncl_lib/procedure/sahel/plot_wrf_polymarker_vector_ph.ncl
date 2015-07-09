; $ID: plot_wrf_polymarker_vector_ph.ncl V01 04/07/2012 21:05 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_wrf_polymarker_vector_ph IS TO PLOT WRFCHEM VERTICAL 
;  POLYMARKER AND WIND VECTOR DEPENDING ON SELECTED VERTICAL TRACK.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks    (graphic): WORK STATION                                   [---]
;  (2 ) in     (integer): TOTAL # OF SELECTED WRFCHEM GRIDS              [---]
;  (3 ) npts   (integer): # OF X AXIS LABELS                             [---]
;  (4 ) slatn  (float)  : SELECTED CALIPSO LATITUDE IN LIMITED REGION    [deg]
;  (5 ) aslonn1(float)  : SELECTED CALIPSO LONGITUDE IN LIMITED REGION   [deg]
;  (6 ) dateh  (string) : WRFCHEM DATE (FORMAT : YEAR-MONTH-DAY, 
;                         i.e. 2008-02-26)                               [---]
;  (7 ) timeh  (string) : WRFCHEM TIME (FORMAT : TIME, 01)               [---]
;  (8 ) sspm25h(float)  : NEW SELECTED WRFCHEM PM2.5 DATA                [um/m3]
;  (9 ) plot   (graphic): PM2.5 VERTICAL CONTOUR PLOT                    [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/09/2012)
;  (2 ) MODIFIED FROM HEIGHT TO PRESSURE FOR Y AXIS. (09/17/2012)
;  (3 ) MODIFIED FROM plot_wrf_contour_vector_ph.ncl. (04/07/2013)
;******************************************************************************

undef("plot_wrf_polymarker_vector_ph")
procedure plot_wrf_polymarker_vector_ph \
         (wks       :graphic,                    \ ; INPUT
          in        :integer,                    \ ; INPUT
          npts      :integer,slatn     :float,   \ ; INPUT
          aslonn1   :float,  pressure  :float,   \ ; INPUT
          dateh     :string, timeh     :string,  \ ; INPUT
          latlon    :float,  pres      :float,   \ ; INPUT
          u         :float,  w         :float,   \ ; INPUT
          ratio     :float,  sspm25h   :float,   \ ; INPUT
          plot      :graphic)                      ; OUTPUT

begin
  sspm25h1 = new((/dimsizes(sspm25h)/), float, sspm25h@_FillValue)
  sspm25h1 = 0.0;sspm25h@_FillValue
  sspm25h1!0   = "lev"
  sspm25h1&lev = pressure
  sspm25h!0    = "lev"
  sspm25h&lev  = pressure
; PLOT THE VERTICAL PROFILE OF WRFCHEM BASED ON CALIPSO
; SET UP RESOURCES
  cres                        = True
  cres@cnFillOn               = True
; TURN OFF CONTOUR LINES
  cres@cnLinesOn              = False
; TURN OFF CONTOUR LABELS
  cres@cnLineLabelsOn         = False
  cres@gsnSpreadColors        = True
  cres@tmXBMajorLengthF       = 0.005
  cres@tmYRMajorLengthF       = 0.005
  cres@tmYLMajorLengthF       = 0.005
  cres@tmYRMinorLengthF       = 0.002
  cres@tmYLMinorLengthF       = 0.002

; SET UP LABEL BAR
  cres@pmLabelBarWidthF       = 0.1
  cres@pmLabelBarHeightF      = 0.5
  cres@lbLabelFontHeightF     = 0.02
  cres@lbLabelStride          = 10
  cres@lbBoxLinesOn           = False
  cres@lbOrientation          = "Vertical"
  cres@lbLabelPosition        = "Right"

; SET UP THE POSITION OF THE CONTOUR PLOT
  cres@vpWidthF               = 0.6
  cres@vpHeightF              = 0.45
  cres@vpXF                   = 0.2
  cres@vpYF                   = 0.8
  cres@gsnDraw                = False
  cres@gsnFrame               = False

; SET UP AXIS LABEL FOR CONTOUR PLOT OF WRFCHEM
  cresn                       = True
  cresn                       = cres
  stride                      = floattoint(in/npts)+1
  cresn@tmXBMode              = "Explicit"
  cresn@tmXBValues            = fspan(0.,(in-2),npts)
  cresn@tmXBLabels            = sprintf("%5.2f", (slatn(0:(in-2):stride))) + "~C~" + \
                                sprintf("%5.2f", (aslonn1(0:(in-2):stride)))
  cresn@cnLevelSelectionMode  = "ManualLevels"
  cresn@cnMinLevelValF        = 0
  cresn@cnMaxLevelValF        = 50
  cresn@cnLevelSpacingF       = 25
  cresn@tiXAxisString         = "Latitude~C~Longitude"
  cresn@tiYAxisString         = "Altitude (hPa)"
  cresn@tiMainString          = "WRF-Chem    " + dateh + "_" + timeh

; SET UP VECTOR RESOURCES
  cresvn                          = True
  cresvn                          = cresn
  cresvn@vcRefMagnitudeF          = 5.0
  cresvn@vcRefLengthF             = 0.05
  cresvn@vcRefAnnoOrthogonalPosF  = -1.124
  cresvn@vcRefAnnoArrowLineColor  = "black"
  cresvn@vcRefAnnoArrowUseVecColor= False
  cresvn@vcGlyphStyle             = "LineArrow"
  cresvn@vcLineArrowColor         = "white"
  cresvn@vcLineArrowThicknessF    = 1.5
  cresvn@vcVectorDrawOrder        = "PostDraw"
  cresvn@vcMinDistanceF           = 0.04
  sspm25h@units                   = "~F33~m~F21~g/(m~S~3~N~)"
  sspm25h@description             = "Smoke and Dust Concentration Profile"
  plot = gsn_csm_pres_hgt_vector(wks, sspm25h1, u, w, cresvn)

;  DRAW POLYGON ON THE PLOT
   minx = 0.0
   maxx = 10.0
   nx   = 21
   x    = fspan(minx, maxx, nx)
   miny = 0.0
   maxy = 100.0
   ny   = 11
   y    = fspan(miny, maxy, ny)

;  DO VERTICAL AND HORIZONTAL LOOP
   oned_sspm25h = ndtooned(sspm25h)
   oned_ratio   = ndtooned(ratio)
   oned_latlon  = ndtooned(latlon)
   oned_pres    = ndtooned(pres)

;  IGNORE LARGE RATIO WITH SMALL PM2.5
;  index0       = ind(oned_sspm25h .lt. 2.0 .and. \
;                     oned_ratio   .gt. 0.2)
;  if (.not.all(ismissing(index0))) then
;   oned_sspm25h(index0) = oned_sspm25h@_FillValue
;   oned_ratio(index0)   = oned_ratio@_FillValue
;  end if

;  NORMALIZE oned_latlon TO X VALUE RANGE
   oned_latlon  = (oned_latlon-min(oned_latlon))/ \
                  (max(oned_latlon)-min(oned_latlon)) \
                  *(in-1)
   plres                    = True
   plres@gsMarkerIndex      = 6
   plres@gsMarkerSizeF      = 0.003
   plres@gsMarkerThicknessF = 10
   plres@tfPolyDrawOrder    = "PreDraw"

   do j = 0, ny-2
    do i = 0, nx-2
    if (.not.all(ismissing(oned_sspm25h)) .and. \
        .not.all(ismissing(oned_ratio))) then
     if (i .eq. nx-2 .and. j .gt. 0 .and. j .lt. ny-2) then
      index1 = ind(oned_sspm25h .gt. x(i) .and. \
                   oned_ratio   .ge. y(j) .and. \
                   oned_ratio   .lt. y(j+1))
     end if
     if (i .eq. nx-2 .and. j .eq. ny-2) then
       index1 = ind(oned_sspm25h .gt. x(i)   .and. \
                    oned_ratio   .gt. y(j))
     end if
     if (i .eq. nx-2 .and. j .eq. 0) then
       index1 = ind(oned_sspm25h .gt. x(i)   .and. \
                    oned_ratio   .gt. y(j)   .and. \
                    oned_ratio   .lt. y(j+1))
     end if
     if (i .eq. 0 .and. j .eq. ny-2) then
       index1 = ind(oned_sspm25h .gt. x(i)   .and. \
                    oned_sspm25h .lt. x(i+1) .and. \
                    oned_ratio   .gt. y(j))
     end if
     if (i .gt. 0 .and. i .lt. nx-2 .and. j .eq. ny-2) then
       index1 = ind(oned_sspm25h .ge. x(i)   .and. \
                    oned_sspm25h .lt. x(i+1) .and. \
                    oned_ratio   .gt. y(j))
     end if
     if (i .ge. 0 .and. i .lt. nx-2) then
      if (j .ge. 0 .and. j .lt. ny-2) then
      index1 = ind(oned_sspm25h .ge. x(i)   .and. \
                   oned_sspm25h .lt. x(i+1) .and. \
                   oned_ratio   .ge. y(j)   .and. \
                   oned_ratio   .lt. y(j+1))
      end if
     end if
     color = j*(nx-1) + i + 2
     plres@gsMarkerColor       = color
     if (.not.all(ismissing(index1))) then
      nindex1 = dimsizes(index1)
      do k = 0, nindex1-1
       if (.not.ismissing(oned_latlon(index1(k)) .and. \
           .not.ismissing(oned_pres(index1(k))))) then
        gsn_polymarker(wks, plot, oned_latlon(index1(k)), oned_pres(index1(k)), plres)
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
  delete(cresn)

return
end
