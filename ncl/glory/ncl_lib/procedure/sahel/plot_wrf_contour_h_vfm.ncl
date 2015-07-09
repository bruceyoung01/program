; $ID: plot_wrf_contour_h_vfm.ncl V01 02/09/2012 10:43 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_wrf_contour_h_vfm IS TO PLOT WRFCHEM VERTICAL CONTOUR 
;  DEPENDING ON CALIPSO TRACK PATH.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks    (graphic): WORK STATION                                   [---]
;  (2 ) height (float)  : HEIGHT ARRAY FROM 0-15km WITH NEW # OF LEVELS  [km ]
;  (3 ) maxh   (float)  : MAXIMUM HEIGHT VALUE                           [km ]
;  (4 ) minh   (float)  : MINIMUM HEIGHT VALUE                           [km ]
;  (5 ) in     (integer): TOTAL # OF SELECTED WRFCHEM GRIDS              [---]
;  (6 ) npts   (integer): # OF X AXIS LABELS                             [---]
;  (7 ) slatn  (float)  : SELECTED CALIPSO LATITUDE IN LIMITED REGION    [deg]
;  (8 ) aslonn1(float)  : SELECTED CALIPSO LONGITUDE IN LIMITED REGION   [deg]
;  (9 ) dateh  (string) : CALIPSO DATE (FORMAT : YEAR-MONTH-DAY, 
;                         i.e. 2008-02-26)                               [---]
;  (10) timeh  (string) : CALIPSO TIME (FORMAT : TIME, 01)               [---]
;  (11) sspm25h(float)  : NEW SELECTED WRFCHEM PM2.5 DATA                [um/m3]
;  (12) sspth  (float)  : NEW SELECTED WRFCHEM TEMPERATURE               [C  ]
;  (13) plot2  (graphic): PM2.5 VERTICAL CONTOUR PLOT                    [---]
;  (14) plot3  (graphic): TEMPERATURE VERTICAL CONTOUR PLOT              [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/09/2012)
;******************************************************************************

undef("plot_wrf_contour_h_vfm")
procedure plot_wrf_contour_h_vfm \
         (wks       :graphic,                    \ ; INPUT
          height    :float,  maxh      :float,   \ ; INPUT
          minh      :float,  in        :integer, \ ; INPUT
          npts      :integer,slatn     :float,   \ ; INPUT
          aslonn1   :float,                      \ ; INPUT
          latlon    :float,  hgt       :float,   \ ; INPUT
          dateh     :string, timeh     :string,  \ ; INPUT
          sdusth    :float,  sspm25h   :float,   \ ; INPUT
          plot      :graphic  )                    ; OUTPUT

begin

;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

  gsn_define_colormap(wks,"color_map_2d_200")
  sdusth1 = new(dimsizes(sdusth), typeof(sdusth))
  sdusth1 = 0.0

; PLOT THE VERTICAL PROFILE OF WRFCHEM BASED ON CALIPSO
; SET UP RESOURCES
  cres                        = True
  cres@cnFillOn               = True
; TURN OFF CONTOUR LINES
  cres@cnLinesOn              = False
; TURN OFF CONTOUR LABELS
  cres@cnLineLabelsOn         = False
  cres@gsnSpreadColors        = True
  cres@sfYArray               = height
  cres@trYMaxF                = maxh
  cres@trYMinF                = minh
  cres@tmXBMajorLengthF       = 0.005
  cres@tmYRMajorLengthF       = 0.005
  cres@tmYLMajorLengthF       = 0.005
  cres@tmYRMinorLengthF       = 0.002
  cres@tmYLMinorLengthF       = 0.002

; SET UP LABEL BAR
  cres@pmLabelBarWidthF       = 0.05
  cres@pmLabelBarHeightF      = 0.3
  cres@lbLabelFontHeightF     = 0.01
  cres@lbLabelStride          = 2
  cres@lbBoxLinesOn           = False
  cres@lbOrientation          = "Vertical"
  cres@lbLabelPosition        = "Right"

; SET UP THE POSITION OF THE CONTOUR PLOT
  cres@vpWidthF               = 0.4
  cres@vpHeightF              = 0.25
  cres@vpXF                   = 0.3
  cres@vpYF                   = 0.7
  cres@gsnDraw                = False
  cres@gsnFrame               = False

; SET UP AXIS LABEL FOR CONTOUR PLOT OF WRFCHEM
  cresn                       = True
  cresn                       = cres
  stride                      = floattoint(in/npts)
  cresn@tmXBMode              = "Explicit"
  cresn@tmXBValues            = fspan(0.,(in-2),npts)
  cresn@tmXBLabels            = sprintf("%5.2f", (slatn(0:(in-2):stride))) + "~C~" + \
                                sprintf("%5.2f", (aslonn1(0:(in-2):stride)))
  cresn@cnLevelSelectionMode  = "ManualLevels"
  cresn@cnMinLevelValF        = 2.
  cresn@cnMaxLevelValF        = 40.
  cresn@cnLevelSpacingF       = 2.
  cresn@tiXAxisString         = "Latitude~C~Longitude"
  cresn@tiYAxisString         = "Altitude (km)"
  cresn@tiMainString          = "WRF-Chem    " + dateh + "_" + timeh
  sspm25h@units               = "~F33~m~F0~g/m~S~3~N~"
  sspm25h@description         = "Aerosol Concentration Profile"
  plot = gsn_csm_contour(wks, sdusth1, cresn)

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
   oned_sdusth  = ndtooned(sdusth)
   oned_latlon  = ndtooned(latlon)
   oned_hgt     = ndtooned(hgt)

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
   plres@gsMarkerThicknessF = 5
   plres@tfPolyDrawOrder    = "PreDraw"

   do j = 0, ny-2
    do i = 0, nx-2
    if (.not.all(ismissing(oned_sspm25h)) .and. \
        .not.all(ismissing(oned_sdusth))) then
     if (i .eq. nx-2 .and. j .gt. 0 .and. j .lt. ny-2) then
      index1 = ind(oned_sspm25h .gt. x(i) .and. \
                   oned_sdusth  .ge. y(j) .and. \
                   oned_sdusth  .lt. y(j+1))
     end if
     if (i .eq. nx-2 .and. j .eq. ny-2) then
       index1 = ind(oned_sspm25h .gt. x(i)   .and. \
                    oned_sdusth  .gt. y(j))
     end if
     if (i .eq. nx-2 .and. j .eq. 0) then
       index1 = ind(oned_sspm25h .gt. x(i)   .and. \
                    oned_sdusth  .gt. y(j)   .and. \
                    oned_sdusth  .lt. y(j+1))
     end if
     if (i .eq. 0 .and. j .eq. ny-2) then
       index1 = ind(oned_sspm25h .gt. x(i)   .and. \
                    oned_sspm25h .lt. x(i+1) .and. \
                    oned_sdusth  .gt. y(j))
     end if
     if (i .gt. 0 .and. i .lt. nx-2 .and. j .eq. ny-2) then
       index1 = ind(oned_sspm25h .ge. x(i)   .and. \
                    oned_sspm25h .lt. x(i+1) .and. \
                    oned_sdusth  .gt. y(j))
     end if
     if (i .ge. 0 .and. i .lt. nx-2) then
      if (j .ge. 0 .and. j .lt. ny-2) then
      index1 = ind(oned_sspm25h .ge. x(i)   .and. \
                   oned_sspm25h .lt. x(i+1) .and. \
                   oned_sdusth  .ge. y(j)   .and. \
                   oned_sdusth  .lt. y(j+1))
      end if
     end if
     color = j*(nx-1) + i + 2
     plres@gsMarkerColor       = color
     if (.not.all(ismissing(index1))) then 
      nindex1 = dimsizes(index1) 
      do k = 0, nindex1-1
       if (.not.ismissing(oned_latlon(index1(k)) .and. \
           .not.ismissing(oned_hgt(index1(k))))) then
        gsn_polymarker(wks, plot, oned_latlon(index1(k)), oned_hgt(index1(k)), plres)
       end if
      end do
     end if 
     delete([/index1/])
    else
     print("Either Dust Or Smoke Is Missing !!!")
    end if
   end do
  end do
  draw(plot)
  frame(wks)
  delete(cresn)

;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "plot_wrf_contour_h_vfm.ncl", 0)

return
end
