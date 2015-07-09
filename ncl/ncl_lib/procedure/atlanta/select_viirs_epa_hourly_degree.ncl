;  $ID: select_viirs_epa_hourly_degree.ncl V01 02/06/2013 22:13 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_viirs_epa_hourly_degree SELECTS POINTS FROM VIIRS DATA BASED 
;  ON EPA SITE LOCATION.
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

undef("select_viirs_epa_hourly_degree")
procedure select_viirs_epa_hourly_degree \
          (iday         : integer, bv2              : float,   \ ; INPUT
           site_id      : string,                              \ ; INPUT
           site_name    : string,  site_geo         : float,   \ ; INPUT
           year         : integer, month            : integer, \ ; INPUT
           day          : integer, hour             : integer, \ ; INPUT
           site_date    : integer, site_pm          : float,   \ ; INPUT
           vlat         : float,   vlon             : float,   \ ; INPUT
           maod         : float,   msza             : float,   \ ; INPUT
           mmp          : float,   mlza             : float,   \ ; INPUT
           site_latitude: float,   site_longitude   : float,   \ ; OUTPUT
           select_aod   : float,   select_aodstd    : float,   \ ; OUTPUT
           select_sza   : float,   select_mp        : float,   \ ; OUTPUT
           select_lza   : float,   select_pm        : float)     ; OUTPUT

begin
  thre_lat  = 0.05
  thre_lon  = 0.05
  oned_vlat = ndtooned(vlat)
  oned_vlon = ndtooned(vlon)
  oned_maod = ndtooned(maod)
  oned_msza = ndtooned(msza)
  oned_mmp  = ndtooned(mmp)
  oned_mlza = ndtooned(mlza)

;  FIND EXACT LATITUDE AND LONGITUDE OF THE SITE
  index0         = ind(site_name(:, 0) .eq. site_id)
  if (.not.all(ismissing(index0))) then
   site_latitude  = site_geo(index0(0), 0)
   site_longitude = site_geo(index0(0), 1)
; SELECT VIIRS PIXEL BASED ON SITE LOCATION
   index1    = ind(oned_vlat .gt. site_latitude -thre_lat .and. \
                   oned_vlat .lt. site_latitude +thre_lat .and. \
                   oned_vlon .gt. site_longitude-thre_lon .and. \
                   oned_vlon .lt. site_longitude+thre_lon .and. \
                   oned_maod .ge. 0.0)
; CALCULATE AVERAGE OF SELECTED VIIRS DATA
   if (.not.all(ismissing(index1))) then
    select_aod    = avg(oned_maod(index1))
    select_aodstd = stddev(oned_maod(index1))
    select_sza    = avg(oned_msza(index1))
    select_mp     = avg(oned_mmp(index1))
    select_lza    = avg(oned_mlza(index1))
   else
    select_aod    = bv2
    select_aodstd = bv2
    select_sza    = bv2
    select_mp     = bv2
    select_lza    = bv2
   end if
;  SELECT SITE OBSERVED DATA BASED ON TIME
;  NOTE : VIIRS TIME IS UTC TIME; EPA IS ALSO UTC TIME.
   index2    = ind(site_date(:, 0) .eq. year   .and. \
                   site_date(:, 1) .eq. month  .and. \
                   site_date(:, 2) .eq. day    .and. \
                   site_date(:, 3) .eq. hour   .and. \
                   site_name(:, 0) .eq. site_id)
;  CALCULATE AVERAGE OF SELECTED SITE DATA
   if (.not. all(ismissing(index2))) then
    select_pm = avg(site_pm(index2, 0))
   else
    select_pm = bv2
   end if
   delete([/index1, index2/])
  end if
   delete([/index0/])
print(year + "-" + month + "-" + day + "-" + hour + "==" + site_id)
print("lat : " + site_latitude)
print("lon : " + site_longitude)
print("rad : " + select_aod)
print("pm  : " + select_pm)
return
end
