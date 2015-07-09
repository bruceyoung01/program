; $ID: point_wrfchem_aeronet_daily_pm.ncl V01 01/10/2012 14:32 
;      BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE point_wrfchem_aeronet_daily_pm SELECTS THE SPECIFIC POINTS FROM 
;  WRFCHEM OUTPUT DEPENDING ON TIME (DAY) AND LOCATION AND .
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wdir      (string)  : WRFCHEM OUTPUT FILE DIRECTORY              [---]
;  (2 ) sname     (string)  : WRFCHEM FILE NAME                          [---]
;  (3 ) iselect   (string)  : # OF SELECTED HOURS EACH SITE              [---]
;  (4 ) date      (integer) : ARRAY INCLUDING YEAR, MONTH, DAY, AND HOUR [---]
;  (5 ) nhour     (integer) : # OF HOURS PER DAY (24)                    [---]
;  (6 ) longitude (float)   : AERONET SITE LONGITUDE                     [deg]
;  (7 ) latitude  (float)   : AERONET SITE LATITUDE                      [deg]
;  (8 ) nhourly   (integer) : PRE-DEFINED # OF HOURS PER AERONET SITE    [---]
;  (9 ) aod_hourly(float)   : TOTAL DAILY AOD DATA PER SITE              [---]
;  (10) nfiles    (integer) : # OF ALL THE WRFCHEM OUTPUT FILES          [---]
;  (11) saod_daily(float)   : SELECTED AERONET SITE AOD DATA             [---]
;  (12) swdata_dailya(float): SELECTED WRFCHEM OUTPUT DATA               [ug/m3]
;  (13) swdata_dailyb(float): SELECTED WRFCHEM OUTPUT DATA               [ug/m3]
;  (14) swdata_daily (float): INTERPOLATED WRFCHEM OUTPUT DATA           [ug/m3]
;  (15) saod_daily_std(float): STANDARD DEVIATION OF AERONET             [---]
;  (16) swdata_daily_stda(float): STANDARD DEVIATION OF WRFCHEM          [ug/m3]
;  (17) swdata_daily_stdb(float): STANDARD DEVIATION OF WRFCHEM          [ug/m3]
;  (18) swdata_daily_std (float): STANDARD DEVIATION OF WRFCHEM          [ug/m3]
;  (19) saod_monthly(float): AEROENT SITES AOD DATA MONTHLY AVERAGE      [---]
;  (20) swdata_monthlya  (float): MONTHLY AVERAGE OF SELECTED WRFCHEM    [ug/m3]
;  (21) swdata_monthlyb  (float): MONTHLY AVERAGE OF SELECTED WRFCHEM    [ug/m3]
;  (22) swdata_monthly   (float): MONTHLY AVERAGE OF INTERPOLATED WRFCHEM[ug/m3]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/10/2012)
;  (2 ) MODIFY FOR DAILY AVERAGE BY BRUCE. (02/20/2012)
;  (3 ) ADD TO CALCULATE STANDARD DEVIATION BY BRUCE. (02/21/2012)
;  (4 ) ADD TO CALCULATE MONTHLY AVERAGE BY BRUCE. (03/11/2012)
;  (5 ) ADD TO CALCULATE TWO AODS OF WRFCHEM BY BRUCE. (04/20/2012)
;  (6 ) ADD TO INTERPOLATE WRFCHEM WAVELENGTH AOD EQUAL TO AERONET AOD 
;       BY BRUCE (04/20/2012)
;  (7 ) MODIFIED FROM point_wrfchem_aeronet_daily_interpolate.ncl. (05/06/2013)
;******************************************************************************

undef("point_wrfchem_aeronet_daily_pm")
procedure point_wrfchem_aeronet_daily_pm \
         (wdir              :string,  wdir2          :string,  \ ; INPUT
          sname             :string,  bv2            :float,   \ ; INPUT
          iselect           :integer, date           :integer, \ ; INPUT
          nhour             :integer, nitem          :integer, \ ; INPUT
          factor            :float,                            \ ; INPUT
          longitude         :float,   latitude       :float,   \ ; INPUT
          nhourly           :integer, aod_hourly     :float,   \ ; INPUT
          nfiles            :integer,                          \ ; INPUT
          saod_daily        :float,swdata_dailya     :float,   \ ; OUTPUT
          swdata_dailyb     :float,swdata_daily      :float,   \ ; OUTPUT
          saod_daily_std    :float,swdata_daily_stda :float,   \ ; OUTPUT
          swdata_daily_stdb :float,swdata_daily_std  :float,   \ ; OUTPUT
          saod_monthly      :float,swdata_monthlya   :float,   \ ; OUTPUT
          swdata_monthlyb   :float,swdata_monthly    :float)     ; OUTPUT


begin
;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

   tem        = addfile(wdir + sname(0) + ".nc", "r")
   var        = tem->PM2_5_DRY(0, :, :, :)
   dimpm25    = dimsizes(var)
   nlevel     = dimpm25(0)
   nlat       = dimpm25(1)
   nlon       = dimpm25(2)
   csmoke     = new((/nfiles, nlat, nlon/), float, bv2)
   cdust      = new((/nfiles, nlat, nlon/), float, bv2)
   cpm25      = new((/nfiles, nlat, nlon/), float, bv2)
   wyear      = new(nfiles, integer)
   wmonth     = new(nfiles, integer)
   wday       = new(nfiles, integer)
   whour      = new(nfiles, integer)

;  READ WRFCHEM OUTPUT
   do i = 0, nfiles-1
   smoke      = new((/nlevel, nlat, nlon/), float, bv2)
   dust       = new((/nlevel, nlat, nlon/), float, bv2)
   lpm25      = new((/nlevel, nlat, nlon/), float, bv2)
   wza        = new((/nlevel, nlat, nlon/), float, bv2)
   a          = addfile(wdir + sname(i) + ".nc", "r")
   b          = addfile(wdir2+ sname(i) + ".nc", "r")
   wtime      = a->Times(0, :)
   wlat       = a->XLAT(0, :, :)
   wlon       = a->XLONG(0, :, :)
   pm251      = a->PM2_5_DRY(0, :, :, :)
   pm251b     = b->DUST_1(0, :, :, :)
   pm252b     = b->DUST_2(0, :, :, :)
   pm253b     = b->DUST_3(0, :, :, :)
   pm254b     = b->DUST_4(0, :, :, :)
   pm255b     = b->DUST_5(0, :, :, :)
   aird       = a->ALT(0, :, :, :)
   wz         = getvar(a, "z", 0)

;  ORIGINALLY DUST UNIT IN nc FILE IS ug/kg-dryair
;  aird IS INVERSED DRY AIR DENSITY, WHOSE UNIT IS m3/kg
;  HERE WE USE DRY AIR DENSITY TO CONVERT ug/kg-dryair TO ug/m3
   smoke      = pm251
   dust       = (pm251b + pm252b + pm253b + pm254b + pm255b)*aird
   pm25       = (pm251b + pm252b + pm253b + pm254b + pm255b)*aird + pm251
;  CONVERT THE UNIT FROM ug TO mg
   factor      = 10^-3
   smoke       = smoke*factor
   dust        = dust*factor
   pm25        = pm25*factor
;  CALCULATE THE COLUMN PM2.5 CONCENTRATION
   do j = 0, nlevel-1
    if (j .eq. 0) then
     wza(j, :, :) = wz(0, :, :)
    end if
    if (j .gt. 0) then
     wza(j, :, :) = wz(j, :, :)-wz(j-1, :, :)
    end if
   end do
   smoke       = smoke*wza
   dust        = smoke*wza
   pm25        = pm25*wza
   csmoke(i, :, :) = dim_sum_n(smoke, 0)
   cdust(i, :, :)  = dim_sum_n(dust,  0)
   cpm25(i, :, :)  = dim_sum_n(pm25,  0)
   wyear(i)  = stringtoint(str_get_cols(charactertostring(wtime), 0, 3))
   wmonth(i) = stringtoint(str_get_cols(charactertostring(wtime), 5, 6))
   wday(i)   = stringtoint(str_get_cols(charactertostring(wtime), 8, 9))
   whour(i)  = stringtoint(str_get_cols(charactertostring(wtime), 11, 12))
   end do
   csmoke@lat2d= wlat
   csmoke@lon2d= wlon
   cdust@lat2d = wlat
   cdust@lon2d = wlon
   cpm25@lat2d = wlat
   cpm25@lon2d = wlon

;  wtime(0) IS # OF WRFCHEM FILES
;  wtime(1) IS # OF TIME STRING
   nday       = floattoint(nfiles/nhour)
   nhourly_true = num(.not.ismissing(date(:, 0)))

   swsmoke    = new(nfiles, float)
   swdust     = new(nfiles, float)
   swpm25     = new(nfiles, float)
   saod       = new((/nfiles, nitem/),  float)
   swyear     = new(nfiles, integer)
   swmonth    = new(nfiles, integer)
   swday      = new(nfiles, integer)
   swhour     = new(nfiles, integer)

;  DO LOOP TO SELECT WRFCHEM DATA POINT DEPENDING ON AERONET SITES
   do ihour = 0, nhourly_true-1
    index1 = ind(wyear  .eq. date(ihour, 0) .and. \
                 wmonth .eq. date(ihour, 1) .and. \
                 wday   .eq. date(ihour, 2) .and. \
                 whour  .eq. date(ihour, 3))
    if (.not.all(ismissing(index1))) then
     oned_wlat  = ndtooned(wlat)
     oned_wlon  = ndtooned(wlon)
     oned_smoke = ndtooned(csmoke(index1(0), :, :))
     oned_dust  = ndtooned(cdust (index1(0), :, :))
     oned_pm25  = ndtooned(cpm25 (index1(0), :, :))
     index2 = ind(oned_wlat   .ge. latitude  - 0.5 .and. \
                  oned_wlat   .le. latitude  + 0.5 .and. \
                  oned_wlon   .ge. longitude - 0.5 .and. \
                  oned_wlon   .le. longitude + 0.5 .and. \
                  oned_smoke  .gt. 0.0             .and. \
                  oned_dust   .gt. 0.0             .and. \
                  oned_pm25   .gt. 0.0)
     if (.not.all(ismissing(index2))) then
      swsmoke(iselect) = avg(oned_smoke(index2))
      swdust(iselect)  = avg(oned_dust(index2))
      swpm25(iselect)  = avg(oned_pm25(index2))
      saod(iselect, :) = aod_hourly(ihour, :)
      swyear(iselect)  = wyear(index1(0))
      swmonth(iselect) = wmonth(index1(0))
      swday(iselect)   = wday(index1(0))
      swhour(iselect)  = whour(index1(0))
     end if
      iselect = iselect + 1
      delete([/index2/])
    else
     print("No data in the time : " + \
           date(ihour, 0) + "-" + date(ihour, 1) + "-" + \
           date(ihour, 2) + "-" + date(ihour, 3))
    end if
    delete([/index1/])
   end do     ; END OF IHOUR LOOP
   delete([/wyear, wmonth, wday, whour/])

   swdataa = swsmoke
   swdatab = swdust
   swdata  = swdataa + swdatab

;  DO NDAY LOOP TO CALCULATE DAILY AVERAGE FOR WRFCHEM
   do imonth = 0, 0
    do iday = 0, nday-1
     index = ind(swmonth .eq. imonth+2 .and. swday .eq. iday+1)
     if (.not.all(ismissing(index))          .and. \
         .not.all(ismissing(swdataa(index))) .and. \
         .not.all(ismissing(swdatab(index))) .and. \
         .not.all(ismissing(swdata(index)))) then
      swdata_dailya(iday)     = avg(swdataa(index))
      swdata_daily_stda(iday) = stddev(swdataa(index))
      swdata_dailyb(iday)     = avg(swdatab(index))
      swdata_daily_stdb(iday) = stddev(swdatab(index))
      swdata_daily(iday)      = avg(swdata(index))
      swdata_daily_std(iday)  = stddev(swdata(index))
     end if
     do j = 0, nitem-1
      if (.not.all(ismissing(index)) .and.\
          .not.all(ismissing(saod(index, j)))) then
       saod_daily(iday, j)= avg(saod(index, j))
       saod_daily_std(iday,j) = stddev(saod(index, j))
      end if
     end do
     delete(index)
    end do
   end do
;  CALCULATE MONTHLY AVERAGE OF AERONET AND SELECTED WRFCHEM DATA
   do j = 0, nitem-1
    if (.not.all(ismissing(saod_daily(:, j)))) then
     saod_monthly(j)   = avg(saod_daily(:, j))
    end if
   end do
   if (.not.all(ismissing(swdata_dailya)) .and. \
       .not.all(ismissing(swdata_dailyb)) .and. \
       .not.all(ismissing(swdata_daily))) then
    swdata_monthlya = avg(swdata_dailya)
    swdata_monthlyb = avg(swdata_dailyb)
    swdata_monthly  = avg(swdata_daily)
   end if
   delete([/swdust, swsmoke, swpm25, saod, swyear, swmonth, swday, swhour/])
;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "point_wrfchem_aeronet_daily_pm.ncl", 0)

return
end
