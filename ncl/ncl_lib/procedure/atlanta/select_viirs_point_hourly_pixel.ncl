;  $ID: select_viirs_point_hourly_pixel.ncl V01 02/06/2013 22:13 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_viirs_point_hourly_pixel SELECTS POINTS FROM VIIRS DATA BASED 
;  ON SITE LOCATION.
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

undef("select_viirs_point_hourly_pixel")
procedure select_viirs_point_hourly_pixel \
          (iday         : integer, bv2              : float,   \ ; INPUT
           site_latitude: float,   site_longitude   : float,   \ ; INPUT
           vlat         : float,   vlon             : float,   \ ; INPUT
           maod         : float,   msza             : float,   \ ; INPUT
           mmp          : float,   mlza             : float,   \ ; INPUT
           select_aod   : float,   select_aodstd    : float,   \ ; OUTPUT
           select_sza   : float,   select_mp        : float,   \ ; OUTPUT
           select_lza   : float)                                 ; OUTPUT

begin

; SELECT VIIRS PIXEL BASED ON SITE LOCATION
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
return
end
