; $ID: pixel_to_grid_degree_1day_mod14.ncl V01 07/31/2012 15:27 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE pixel_to_grid_degree_1day_mod14 GRIDS MODIS PIXEL DATA INTO GRIDED 
;  DATA WITH THE SAME DEGREE INTERVAL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/08/2012)
;  (2 ) MODIFIED FROM pixel_to_grid_degree_1day.ncl. (10/08/2012)
;******************************************************************************

undef("pixel_to_grid_degree_1day_mod14")
procedure pixel_to_grid_degree_1day_mod14 \
         (lat_interval:float,   lon_interval:float,   \ ; INPUT
          minlat      :float,   maxlat      :float,   \ ; INPUT
          minlon      :float,   maxlon      :float,   \ ; INPUT
          nlat        :integer, nlon        :integer, \ ; INPUT
          lat         :float,   lon         :float,   \ ; INPUT
          pixel_data  :float,                         \ ; INPUT
          grid_lat    :float,   grid_lon    :float,   \ ; OUTPUT
          grid_data   :float)                           ; OUTPUT

begin

;  GET GRIDED LATITUDE, LONGITUDE
   do i = 0, nlat - 1
    do j = 0, nlon - 1
     grid_lat(i, j) = minlat + lat_interval*i
     grid_lon(i, j) = minlon + lon_interval*j
    end do
   end do

;  AVERAGE THE AOD INTO GRID BOX
   ndimlat  = dimsizes(lat)
   do i = 0, nlat - 1
    do j = 0, nlon - 1
     index1= ind(lat .ge. grid_lat(i, j) - lat_interval/2.0   \
           .and. lat .le. grid_lat(i, j) + lat_interval/2.0   \
           .and. lon .ge. grid_lon(i, j) - lon_interval/2.0   \
           .and. lon .le. grid_lon(i, j) + lon_interval/2.0)
     if (all(ismissing(index1))) then
      grid_data(i, j) = 0.0
     else if (.not. all(ismissing(index1)))
      grid_data(i, j) = avg(pixel_data(index1))
     end if
     end if
     delete([/index1/])
    end do
   end do


end
