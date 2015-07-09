;  $ID: select_viirs_site.ncl V01 01/16/2013 21:07 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_viirs_site SELECTS POINTS FROM VIIRS DATA BASED ON SITE 
;  LOCATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/16/2013)
;******************************************************************************

undef("select_viirs_site")
procedure select_viirs_site \
          (iday         :integer,  bv2              : float,   \ ; INPUT
           site_latitude: float,   site_longitude   : float,   \ ; INPUT
           year         : integer, month            : integer, \ ; INPUT
           day          : integer, hour             : integer, \ ; INPUT
           site_date    : integer, site_pm          : float,   \ ; INPUT
           vlat         : float,   vlon             : float,   \ ; INPUT
           maod         : float,   msza             : float,   \ ; INPUT
           select_aod   : float,   select_aodstd    : float,   \ ; OUTPUT
           select_sza   : float,   select_pm        : float)     ; OUTPUT

begin

  thre_lat  = 0.01
  thre_lon  = 0.01
  oned_vlat = ndtooned(vlat)
  oned_vlon = ndtooned(vlon)
  oned_maod = ndtooned(maod)
  oned_msza = ndtooned(msza)

; SELECT VIIRS PIXEL BASED ON SITE LOCATION
  index1    = ind(oned_vlat .gt. site_latitude-thre_lat  .and. \
                  oned_vlat .lt. site_latitude+thre_lat  .and. \
                  oned_vlon .gt. site_longitude-thre_lon .and. \
                  oned_vlon .lt. site_longitude+thre_lon)
; CALCULATE AVERAGE OF SELECTED VIIRS DATA
  if (.not.all(ismissing(index1))) then
   select_aod    = avg(oned_maod(index1))
   select_aodstd = stddev(oned_maod(index1))
   select_sza    = avg(oned_msza(index1))
  else
   select_aod    = bv2
   select_aodstd = bv2
   select_sza    = bv2
  end if
; SELECT SITE OBSERVED DATA BASED ON TIME
; NOTE : VIIRS TIME IS UTC TIME; OBSERVED IS LOCAL TIME.
; ATLANTA_TIME - UTC = -5:00
  index2    = ind(site_date(:, 0) .eq. year   .and. \
                  site_date(:, 1) .eq. month  .and. \
                  site_date(:, 2) .eq. day    .and. \
                  site_date(:, 3) .eq. hour-5)
; CALCULATE AVERAGE OF SELECTED SITE DATA
  if (.not. all(ismissing(index2))) then
   select_pm = site_pm(index2, 0)
  else
   select_pm = bv2
  end if
  delete([/index1, index2/])

return
end
