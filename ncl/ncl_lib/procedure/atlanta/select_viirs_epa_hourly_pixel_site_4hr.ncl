;  $ID: select_viirs_epa_hourly_pixel_site_4hr.ncl V01 02/06/2013 22:13 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_viirs_epa_hourly_pixel_site_4hr SELECTS POINTS FROM VIIRS 
;  DATA BASED ON EPA SITE LOCATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/06/2013)
;  (2 ) MODIFIED FROM select_viirs_site.ncl. (02/06/2013)
;  (3 ) MODIFIED FROM select_viirs_epa_hourly_pixel_site.ncl. (01/21/2014)
;******************************************************************************

undef("select_viirs_epa_hourly_pixel_site_4hr")
procedure select_viirs_epa_hourly_pixel_site_4hr \
          (iday         : integer, bv1              : integer, \ ; INPUT
           bv2          : float,   site_id          : string,  \ ; INPUT
           site_name    : string,  site_geo         : float,   \ ; INPUT
           year         : integer, month            : integer, \ ; INPUT
           day          : integer, hour             : integer, \ ; INPUT
           thre_lat     : float,   thre_lon         : float,   \ ; INPUT
           npixel       : integer,                             \ ; INPUT
           site_date    : integer, site_pm          : float,   \ ; INPUT
           vlat         : float,   vlon             : float,   \ ; INPUT
           maod         : float,   msza             : float,   \ ; INPUT
           msaa         : float,                               \ ; INPUT
           mmp          : float,   mlza             : float,   \ ; INPUT
           mlaa         : float,                               \ ; INPUT
           site_latitude: float,   site_longitude   : float,   \ ; OUTPUT
           select_date  : integer,                             \ ; OUTPUT
           select_aod   : float,   select_aodstd    : float,   \ ; OUTPUT
           select_sza   : float,   select_saa       : float,   \ ; OUTPUT
           select_mp    : float,   select_lza       : float,   \ ; OUTPUT
           select_laa   : float,   select_pm        : float)     ; OUTPUT

begin
   oned_vlat = ndtooned(vlat)
   oned_vlon = ndtooned(vlon)
   oned_maod = ndtooned(maod)
   oned_msza = ndtooned(msza)
   oned_msaa = ndtooned(msaa)
   oned_mmp  = ndtooned(mmp)
   oned_mlza = ndtooned(mlza)
   oned_mlaa = ndtooned(mlaa)

;  FIND EXACT LATITUDE AND LONGITUDE OF THE SITE
   index0         = ind(site_name(:, 0) .eq. site_id)
   if (.not.all(ismissing(index0))) then
;  FOR CALCULATING WITH BACKGROUND
;   site_latitude  =  33.76
;   site_longitude = -84.40
    site_latitude  = site_geo(index0(0), 0)
    site_longitude = site_geo(index0(0), 1)
   else if (all(ismissing(index0))) then
    site_latitude  =  33.76 ; 33.76(ctr) ; 33.545(bk)
    site_longitude = -84.40 ;-84.40(ctr) ;-84.078(bk)
   end if
   end if
   delete([/index0/])
; SELECT VIIRS PIXEL BASED ON SITE LOCATION
   index1    = ind(oned_vlat .gt. site_latitude -thre_lat .and. \
                   oned_vlat .lt. site_latitude +thre_lat .and. \
                   oned_vlon .gt. site_longitude-thre_lon .and. \
                   oned_vlon .lt. site_longitude+thre_lon .and. \
                   oned_maod .ge. 0.0)
; CALCULATE AVERAGE OF SELECTED VIIRS DATA
   if (.not.all(ismissing(index1))) then
    nindex1 = dimsizes(index1)
    print("ACTUAL SELECTED PIXEL # : " + nindex1)
    if (nindex1 .ge. npixel) then
     select_aod    = oned_maod(index1(0:npixel-1))
     select_aodstd = stddev(oned_maod(index1(0:npixel-1)))
     select_sza    = avg(oned_msza(index1(0:npixel-1)))
     select_saa    = avg(oned_msaa(index1(0:npixel-1)))
     select_mp     = avg(oned_mmp(index1(0:npixel-1)))
     select_lza    = avg(oned_mlza(index1(0:npixel-1)))
     select_laa    = avg(oned_mlaa(index1(0:npixel-1)))
    else
     select_aod(0:nindex1-1)  = oned_maod(index1(0:nindex1-1))
     select_aodstd            = stddev(oned_maod(index1(0:nindex1-1)))
     select_sza               = avg(oned_msza(index1(0:nindex1-1)))
     select_saa               = avg(oned_msaa(index1(0:nindex1-1)))
     select_mp                = avg(oned_mmp(index1(0:nindex1-1)))
     select_lza               = avg(oned_mlza(index1(0:nindex1-1)))
     select_laa               = avg(oned_mlaa(index1(0:nindex1-1)))
    end if
   else
    select_aod    = bv2
    select_aodstd = bv2
    select_sza    = bv2
    select_saa    = bv2
    select_mp     = bv2
    select_lza    = bv2
    select_laa    = bv2
   end if
;  SELECT SITE OBSERVED DATA BASED ON TIME
;  NOTE : VIIRS TIME IS UTC TIME; EPA IS ALSO UTC TIME.
   index2    = ind(site_date(:, 0) .eq. year   .and. \
                   site_date(:, 1) .eq. month  .and. \
                   site_date(:, 2) .eq. day    .and. \
                   site_date(:, 3) .eq. hour-1 .and. \
                   site_name(:, 0) .eq. site_id)
   index3    = ind(site_date(:, 0) .eq. year   .and. \
                   site_date(:, 1) .eq. month  .and. \
                   site_date(:, 2) .eq. day    .and. \
                   site_date(:, 3) .eq. hour   .and. \
                   site_name(:, 0) .eq. site_id)
   index4    = ind(site_date(:, 0) .eq. year   .and. \
                   site_date(:, 1) .eq. month  .and. \
                   site_date(:, 2) .eq. day    .and. \
                   site_date(:, 3) .eq. hour+1 .and. \
                   site_name(:, 0) .eq. site_id)
   index5    = ind(site_date(:, 0) .eq. year   .and. \
                   site_date(:, 1) .eq. month  .and. \
                   site_date(:, 2) .eq. day    .and. \
                   site_date(:, 3) .eq. hour+2 .and. \
                   site_name(:, 0) .eq. site_id)
   index_all = (/index2, index3, index4, index5/)
;  CALCULATE AVERAGE OF SELECTED SITE DATA
   if (.not.any(ismissing(index_all))) then
    select_date = site_date(index3, :)
    select_pm   = (/site_pm(index2, 0), site_pm(index3, 0), \
                    site_pm(index4, 0), site_pm(index5, 0)/);/cos(select_sza)
   else if (     any(ismissing(index_all))   .and. \
            .not.all(ismissing(index_all))) then
    iindex_alla = ind(ismissing(index_all))
    iindex_allb = ind(.not.ismissing(index_all))
    select_date = site_date(index_all(iindex_allb(0)), :)
    print(iindex_alla)
    print(index_all(iindex_alla))
;   site_pm(index_all(iindex_alla), 0) = bv2
    select_pm(iindex_allb)   = site_pm(index_all(iindex_allb), 0);/cos(select_sza)
   else if (all(ismissing(index_all))) then
    select_date = bv1
    select_pm   = bv2
   end if
   end if
   end if
   delete([/index1, index2, index3, index4, index5, index_all/])
print(year + "-" + month + "-" + day + "_" + hour + "==" + site_id)
;print("lat : " + site_latitude)
;print("lon : " + site_longitude)
;print("rad : " + select_aod)
;print("pm  : " + select_pm)
return
end
