;  $ID: select_viirs_point_hourly_pixel_polyline.ncl V01 02/06/2013 22:13 
;       BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_viirs_point_hourly_pixel_polyline SELECTS POINTS FROM VIIRS 
;  DATA BASED ON SITE LOCATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/06/2013)
;  (2 ) MODIFIED FROM select_viirs_site.ncl. (02/06/2013)
;******************************************************************************

undef("select_viirs_point_hourly_pixel_polyline")
procedure select_viirs_point_hourly_pixel_polyline \
          (iday         : integer, bv2              : float,   \ ; INPUT
           site_latitude: float,   site_longitude   : float,   \ ; INPUT
           vlat         : float,   vlon             : float,   \ ; INPUT
           maod         : float,   msza             : float,   \ ; INPUT
           mmp          : float,   mlza             : float,   \ ; INPUT
           mlatn        : float,   mlonn            : float,   \ ; OUTPUT
           mlatl        : float,   mlonl            : float,   \ ; OUTPUT
           select_aod   : float,   select_aodstd    : float,   \ ; OUTPUT
           select_sza   : float,   select_mp        : float,   \ ; OUTPUT
           select_lza   : float,   maodn            : float,   \ ; OUTPUT
           maodl        : float)                                 ; OUTPUT

begin

;  SELECT VIIRS PIXEL BASED ON SITE LOCATION
   index1 = getind_latlon2d(vlat, vlon, site_latitude, site_longitude)

   if (.not.all(ismissing(index1))) then
      select_aod    = avg(maod(index1(0, 0), index1(0, 1)))
      select_aodstd = stddev(maod(index1(0, 0), index1(0, 1)))
      select_sza    = avg(msza(index1(0, 0), index1(0, 1)))
      select_mp     = avg(mmp(index1(0, 0), index1(0, 1)))
      select_lza    = avg(mlza(index1(0, 0), index1(0, 1)))
   else
      select_aod    = bv2
      select_aodstd = bv2
      select_sza    = bv2
      select_mp     = bv2
      select_lza    = bv2
   end if
   delete([/index1/])

;  SELECT THE MIDDLE PIXEL OF THE GRANULE
   ndim  = dimsizes(vlat)
   sindl = ndim(0)/2
   mlatl = vlat(sindl, :)
   mlonl = vlon(sindl, :)
   mradl = maod(sindl, :)
   sindn = ndim(1)/2
   mlatn = vlat(:, sindn)
   mlonn = vlon(:, sindn)
   mradn = maod(:, sindn)
return
end
