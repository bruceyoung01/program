;  $ID: select_viirs_epa_liu_hourly_pixel_point_number.ncl V01 
;  02/06/2013 22:13 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_viirs_epa_liu_hourly_pixel_point_number SELECTS POINTS FROM 
;  VIIRS DATA BASED ON EPA SITE LOCATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/06/2013)
;  (2 ) MODIFIED FROM select_viirs_site.ncl. (02/06/2013)
;  (3 ) MODIFIED FROM select_viirs_epa_hourly_pixel.ncl. (03/13/2013)
;  (4 ) MODIFIED FROM select_viirs_epa_liu_hourly_pixel.ncl BY ADDING THE 
;       HIGHEST LIGHT NEAR THE SITE.
;******************************************************************************

undef("select_viirs_epa_liu_hourly_pixel_point_number")
procedure select_viirs_epa_liu_hourly_pixel_point_number \
          (iday         : integer, bv1              : integer, \ ; INPUT
           bv2          : float,                               \ ; INPUT
           isite        : integer, site_id          : string,  \ ; INPUT
           site_name    : string,  site_geo         : float,   \ ; INPUT
           year         : integer, month            : integer, \ ; INPUT
           day          : integer, hour             : integer, \ ; INPUT
           site_date    : integer, site_pm          : float,   \ ; INPUT
           llat         : float,   llon             : float,   \ ; INPUT
           ldate        : integer, lpm              : float,   \ ; INPUT
           vlat         : float,   vlon             : float,   \ ; INPUT
           mrad         : float,   msza             : float,   \ ; INPUT
           msaa         : float,   mmp              : float,   \ ; INPUT
           mlza         : float,   mlaa             : float,   \ ; INPUT
           site_latitude: float,   site_longitude   : float,   \ ; OUTPUT
           point_lat    : float,   point_lon        : float,   \ ; OUTPUT
           pointn_lat   : float,   pointn_lon       : float,   \ ; OUTPUT
           select_date  : integer,                             \ ; OUTPUT
           select_rad   : float,   select_radstd    : float,   \ ; OUTPUT
           select_sza   : float,   select_saa       : float,   \ ; OUTPUT
           select_mp    : float,   select_lza       : float,   \ ; OUTPUT
           select_laa   : float,   select_pm        : float,   \ ; OUTPUT
           pointn_rad   : float)                                 ; OUTPUT

begin
   thre_lat  = 0.02
   thre_lon  = 0.02
   oned_vlat = ndtooned(vlat)
   oned_vlon = ndtooned(vlon)
   oned_mrad = ndtooned(mrad)
   oned_msza = ndtooned(msza)
   oned_msaa = ndtooned(msaa)
   oned_mmp  = ndtooned(mmp)
   oned_mlza = ndtooned(mlza)
   oned_mlaa = ndtooned(mlaa)

;  FIND EXACT LATITUDE AND LONGITUDE OF THE SITE
   index0         = ind(site_name(:, 0) .eq. site_id)
   if (.not.all(ismissing(index0))) then
    site_latitude  = site_geo(index0(0), 0)
    site_longitude = site_geo(index0(0), 1)
   else if (all(ismissing(index0))) then
    site_latitude  = llat
    site_longitude = llon
   end if
   end if

;  FIND THE INDEX OF PIXEL WHICH INVOLVES SITE
   ji  = getind_latlon2d(vlat, vlon, site_latitude, site_longitude)
   ji0 = ji(0, 0)
   ji1 = ji(0, 1)
   print("ji = " + ji)
   if (.not.any(ismissing(ji))) then

;==============================================================================
;  POINT SELECTION RULES:
;  FOR INSTANCE, A(I, J) POINT
;  MOVE TO WEST BY 1 PIXEL => A(I+1, J)
;  MOVE TO SOUTH BY 1 PIXEL => A(I, J+1)
;==============================================================================
;  FOR A POINT
      if (isite .eq. 0) then
         ji0       = ji0 + 1
         ji1       = ji1
         point_lat = vlat(ji0, ji1)
         point_lon = vlon(ji0, ji1)
;  FOR B POINT
      else if (isite .eq. 1) then
         ji0       = ji0 + 1
         ji1       = ji1
         point_lat = vlat(ji0, ji1)
         point_lon = vlon(ji0, ji1)
;  FOR C POINT
      else if (isite .eq. 2) then
         ji0       = ji0 + 1
         ji1       = ji1
         point_lat = vlat(ji0, ji1)
         point_lon = vlon(ji0, ji1)
;  FOR D POINT
      else if (isite .eq. 3) then
         ji0       = ji0 + 1
         ji1       = ji1
         ji0a      = ji0 + 3
         ji1a      = ji1 + 3
         point_lat = vlat(ji0a, ji1a)
         point_lon = vlon(ji0a, ji1a)
         nji       = (ji0a - ji0 + 1) * (ji1a - ji1 + 1) - 1
;printVarSummary(pointn_lat)
;print(nji)
;print("ji0  = " + ji0  + "ji1  = " + ji1 + \
;      "ji0a = " + ji0a + "ji1a = " + ji1a)
         pointn_lat(0:nji)= ndtooned(vlat(ji0:ji0a, ji1a:ji1))
         pointn_lon(0:nji)= ndtooned(vlon(ji0:ji0a, ji1a:ji1))
         pointn_rad(0:nji)= ndtooned(mrad(ji0:ji0a, ji1a:ji1))
;print("pointn_lat = " + pointn_lat(0:nji))
;print("pointn_lon = " + pointn_lon(0:nji))
;print("pointn_rad = " + pointn_rad(0:nji))
;  FOR E POINT
      else if (isite .eq. 4) then
         ji0       = ji0 - 1
         ji1       = ji1 - 2
         ji0a      = ji0 - 3
         ji1a      = ji1 + 3
         point_lat = vlat(ji0a, ji1a)
         point_lon = vlon(ji0a, ji1a)
         nji       = (ji0 - ji0a + 1) * (ji1a - ji1 + 1) - 1
;printVarSummary(pointn_lat)
;print(nji)
;print("ji0  = " + ji0  + "ji1  = " + ji1 + \
;      "ji0a = " + ji0a + "ji1a = " + ji1a)
         pointn_lat(0:nji)= ndtooned(vlat(ji0:ji0a, ji1a:ji1))
         pointn_lon(0:nji)= ndtooned(vlon(ji0:ji0a, ji1a:ji1))
         pointn_rad(0:nji)= ndtooned(mrad(ji0:ji0a, ji1a:ji1))
;print("pointn_lat = " + pointn_lat(0:nji))
;print("pointn_lon = " + pointn_lon(0:nji))
;print("pointn_rad = " + pointn_rad(0:nji))
;  FOR L POINT
      else if (isite .eq. 5) then
         ji0       = ji0
         ji1       = ji1
         ji0a      = ji0 + 3
         ji1a      = ji1 + 3
         point_lat = vlat(ji0a, ji1a)
         point_lon = vlon(ji0a, ji1a)
         nji       = (ji0a - ji0 + 1) * (ji1a - ji1 + 1) - 1
;printVarSummary(pointn_lat)
;print(nji)
;print("ji0  = " + ji0  + "ji1  = " + ji1 + \
;      "ji0a = " + ji0a + "ji1a = " + ji1a)
         pointn_lat(0:nji)= ndtooned(vlat(ji0:ji0a, ji1a:ji1))
         pointn_lon(0:nji)= ndtooned(vlon(ji0:ji0a, ji1a:ji1))
         pointn_rad(0:nji)= ndtooned(mrad(ji0:ji0a, ji1a:ji1))
;print("pointn_lat = " + pointn_lat(0:nji))
;print("pointn_lon = " + pointn_lon(0:nji))
;print("pointn_rad = " + pointn_rad(0:nji))
      end if
      end if
      end if
      end if
      end if
      end if
   else
      point_lat = site_latitude
      point_lon = site_longitude
   end if

;print("point latlon = " + point_lat + "   " + point_lon)
;print("site  latlon = " + site_latitude  + "   " +  site_longitude)
;  SELECT VIIRS PIXEL BASED ON SITE LOCATION
   index1    = ind(oned_vlat .gt. site_latitude -thre_lat .and. \
                   oned_vlat .lt. site_latitude +thre_lat .and. \
                   oned_vlon .gt. site_longitude-thre_lon .and. \
                   oned_vlon .lt. site_longitude+thre_lon .and. \
                   oned_mrad .ge. 0.0)
   if (.not.all(ismissing(index1))) then
    nindex1 = dimsizes(index1)
    if (nindex1 .ge. 25) then
     select_rad    = avg(oned_mrad(index1(0:24)))
     select_radstd = stddev(oned_mrad(index1(0:24)))
     select_sza    = avg(oned_msza(index1(0:24)))
     select_saa    = avg(oned_msaa(index1(0:24)))
     select_mp     = avg(oned_mmp(index1(0:24)))
     select_lza    = avg(oned_mlza(index1(0:24)))
     select_laa    = avg(oned_mlaa(index1(0:24)))
    else
     select_rad    = avg(oned_mrad(index1(0:nindex1-1)))
     select_radstd = stddev(oned_mrad(index1(0:nindex1-1)))
     select_sza    = avg(oned_msza(index1(0:nindex1-1)))
     select_saa    = avg(oned_msaa(index1(0:nindex1-1)))
     select_mp     = avg(oned_mmp(index1(0:nindex1-1)))
     select_lza    = avg(oned_mlza(index1(0:nindex1-1)))
     select_laa    = avg(oned_mlaa(index1(0:nindex1-1)))
    end if
   else
    select_rad    = bv2
    select_radstd = bv2
    select_sza    = bv2
    select_saa    = bv2
    select_mp     = bv2
    select_lza    = bv2
    select_laa    = bv2
   end if

;==============================================================================
;  SELECT SITE OBSERVED DATA BASED ON TIME
;  NOTE : VIIRS TIME IS UTC TIME; EPA IS ALSO UTC TIME.
;==============================================================================
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
;   site_pm(index_all(iindex_alla), 0) = bv2
    select_pm(iindex_allb)   = site_pm(index_all(iindex_allb), 0);/cos(select_sza)
   else if (all(ismissing(index_all))) then
    select_date = (/year, month, day, hour/)
    select_pm   = bv2
   end if
   end if
   end if
   delete([/index2, index3, index4, index5, index_all/])

;==============================================================================
;  SELECT LIU SITE OBSERVED DATA BASED ON TIME---PART 1
;  NOTE : VIIRS TIME IS UTC TIME
;  LIU'S TIME (LOCAL TIME) HAS BEEN COVNERT TO UTC TIME.
;==============================================================================

   if (isite .eq. 5) then
   index2    = ind(ldate(:, 0) .eq. year   .and. \
                   ldate(:, 1) .eq. month  .and. \
                   ldate(:, 2) .eq. day    .and. \
                   ldate(:, 3) .eq. hour-1)
   index3    = ind(ldate(:, 0) .eq. year   .and. \
                   ldate(:, 1) .eq. month  .and. \
                   ldate(:, 2) .eq. day    .and. \
                   ldate(:, 3) .eq. hour)
   index4    = ind(ldate(:, 0) .eq. year   .and. \
                   ldate(:, 1) .eq. month  .and. \
                   ldate(:, 2) .eq. day    .and. \
                   ldate(:, 3) .eq. hour+1)
   index5    = ind(ldate(:, 0) .eq. year   .and. \
                   ldate(:, 1) .eq. month  .and. \
                   ldate(:, 2) .eq. day    .and. \
                   ldate(:, 3) .eq. hour+2)
   index_all = (/index2, index3, index4, index5/)
;  CALCULATE AVERAGE OF SELECTED SITE DATA
   if (.not.any(ismissing(index_all))) then
    select_date = ldate(index3, :)
    select_pm   = (/lpm(index2, 0), lpm(index3, 0), \
                    lpm(index4, 0), lpm(index5, 0)/);/cos(select_sza)
   else if (     any(ismissing(index_all))   .and. \
            .not.all(ismissing(index_all))) then
    iindex_alla = ind(ismissing(index_all))
    iindex_allb = ind(.not.ismissing(index_all))
    select_date = ldate(index_all(iindex_allb(0)), :)
;   site_pm(index_all(iindex_alla), 0) = bv2
    select_pm(iindex_allb)   = lpm(index_all(iindex_allb), 0);/cos(select_sza)
   else if (all(ismissing(index_all))) then
    select_date = (/year, month, day, hour/)
    select_pm   = bv2
   end if
   end if
   end if
   delete([/index2, index3, index4, index5, index_all/])
   end if
   delete(index1)
print(year + "-" + month + "-" + day + "_" + hour + "==" + site_id)
;print("lat : " + site_latitude)
;print("lon : " + site_longitude)
;print("rad : " + select_rad)
;print("pm  : " + select_pm)
return
end
