;  $ID: add_markers_to_map_plot_2dct.ncl V01 04/11/2013 09:06 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE add_markers_to_map_plot_2dct PLOTS MARKERS ON THE MAP PLOT WITH 
;  2-D COLOR TABLE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) lat      (float): LATITUDE OF POINTS.                          [degree]
;  (2 ) lon      (float): LONGITUDE OF POINTS.                         [degree]
;  (3 ) data1    (float): DATA FOR X-AXIS IN 2-D COLOR TABLE.             [---]
;  (4 ) data2    (float): DATA FOR Y-AXIS IN 2-D COLOR TABLE.             [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/11/2013)
;******************************************************************************
undef("add_markers_to_map_plot_2dct")
procedure add_markers_to_map_plot_2dct \
          (lat        :float,   lon         :float, \; INPUT
           data1      :float,   data2       :float)  ; INPUT

begin

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
   plres@gsMarkerIndex      = 6
   plres@gsMarkerSizeF      = 0.004
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
    else
     plres@gsMarkerColor       = 0
    end if
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
   end do
  end do

return
end
