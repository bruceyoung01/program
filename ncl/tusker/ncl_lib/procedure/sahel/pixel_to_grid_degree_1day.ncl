; $ID: pixel_to_grid_degree_1day.ncl V01 07/31/2012 15:27 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE pixel_to_grid_degree_1day GRIDS MODIS PIXEL DATA INTO GRIDED 
;  DATA WITH THE SAME DEGREE INTERVAL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/08/2012)
;******************************************************************************

undef("pixel_to_grid_degree_1day")
procedure pixel_to_grid_degree_1day \
         (lat_interval:float,   lon_interval:float,   \ ; INPUT
          minlat      :float,   maxlat      :float,   \ ; INPUT
          minlon      :float,   maxlon      :float,   \ ; INPUT
          nlat        :integer, nlon        :integer, \ ; INPUT
          lat         :float,   lon         :float,   \ ; INPUT
          aod_qf      :integer, aod         :float,   \ ; INPUT
          grid_lat    :float,   grid_lon    :float,   \ ; OUTPUT
          grid_aod    :float)                           ; OUTPUT


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
   oned_lat = ndtooned(lat)
   oned_lon = ndtooned(lon)
   do i = 0, nlat - 1
    do j = 0, nlon - 1
     index1= ind(oned_lat .ge. grid_lat(i, j) - lat_interval/2.0   \
           .and. oned_lat .le. grid_lat(i, j) + lat_interval/2.0   \
           .and. oned_lon .ge. grid_lon(i, j) - lon_interval/2.0   \
           .and. oned_lon .le. grid_lon(i, j) + lon_interval/2.0)
     if (.not.any(ismissing(index1))) then
      index2 = ind_resolve(index1, (/ndimlat(0), ndimlat(1)/))
      if (any(ismissing(index2))) then
       grid_aod(i, j) = 0.0
      else
       if (.not.all(ismissing(aod(index2(:, 0), index2(:, 1)))))
        grid_aod(i, j) = avg(aod(index2(:, 0), index2(:, 1)))
       end if
      end if
      delete([/index2/])
     end if
     delete([/index1/])
    end do
   end do

return
end
