;  $ID: grid_lat_lon.ncl V01 04/11/2013 10:29 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE grid_lat_lon DEPENDS ON RANGE OF LATITUDE AND LONGITUDE, AND 
;  INTEGERVAL TO GET GRIDDED LATITUDE AND LONGITUDE BOX.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/11/2013)
;******************************************************************************
undef("grid_lat_lon")
procedure grid_lat_lon \
          (minlat       :float,   maxlat       :float,   \; INPUT
           minlon       :float,   maxlon       :float,   \; INPUT
           lat_interval :float,   lon_interval :float,   \; INPUT
           grid_lat     :float,   grid_lon     :float,   \; OUTPUT
           grid_lat2d   :float,   grid_lon2d   :float)    ; OUTPUT


begin

;  CALCULATE GRID SIZE DEPENDING ON GRID INTERVAL AND REGION LIMIT
   nlat           = floattoint((maxlat-minlat)/lat_interval) + 1
   nlon           = floattoint((maxlon-minlon)/lon_interval) + 1
   grid_lat       = fspan(minlat, maxlat, nlat)
   grid_lon       = fspan(minlon, maxlon, nlon)
   grid_lat@units = "degrees_north"
   grid_lon@units = "degrees_east"
;  CONVERT LATITUDE AND LONGITUDE TO 2D
   do i = 0, nlat-1
    do j = 0, nlon-1
     grid_lat2d(i, j) = grid_lat(i)
     grid_lon2d(i, j) = grid_lon(j)
    end do 
   end do
   copy_VarAtts(grid_lat, grid_lat2d)
   copy_VarAtts(grid_lon, grid_lon2d)

return
end
