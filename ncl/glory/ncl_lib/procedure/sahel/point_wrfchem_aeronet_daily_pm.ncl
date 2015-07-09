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
;  (2 ) sfile     (string)  : WRFCHEM FILE NAME                          [---]
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
          sfile             :string,                           \ ; INPUT
          iselect           :integer, date           :integer, \ ; INPUT
          nhour             :integer, nitem          :integer, \ ; INPUT
          factor            :float,                            \ ; INPUT
          longitude         :float,   latitude       :float,   \ ; INPUT
          nhourly           :integer, aod_hourly     :float,   \ ; INPUT
          nfiles            :integer,                          \ ; OUTPUT
          saod_daily        :float,swdata_dailya     :float,   \ ; OUTPUT
          swdata_dailyb     :float,swdata_daily      :float,   \ ; OUTPUT
          saod_daily_std    :float,swdata_daily_stda :float,   \ ; OUTPUT
          swdata_daily_stdb :float,swdata_daily_std  :float,   \ ; OUTPUT
          saod_monthly      :float,swdata_monthlya   :float,   \ ; OUTPUT
          swdata_monthlyb   :float,swdata_monthly    :float)     ; OUTPUT


begin
;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

;  READ WRFCHEM OUTPUT
   files = systemfunc("ls " + wdir + sfile)
   a     = addfiles(files + ".nc", "r")
   delete(files)
   ListSetType(a, "join")
   files2= systemfunc("ls " + wdir2+ sfile)
   b     = addfiles(files2 + ".nc", "r")
   delete(files2)
   ListSetType(b, "join")

   wtime      = a[:]->Times(:,0,:)
   wlat       = a[:]->XLAT(0, 0, :, :)
   wlon       = a[:]->XLONG(0, 0, :, :)
   pm251      = a[:]->PM2_5_DRY(:, 0, :, :, :)
   pm251b     = b[:]->DUST_1(:, 0, :, :, :)
   pm252b     = b[:]->DUST_2(:, 0, :, :, :)
   pm253b     = b[:]->DUST_3(:, 0, :, :, :)
   pm254b     = b[:]->DUST_4(:, 0, :, :, :)
;  pm251@lat2d= wlat
;  pm251@lon2d= wlon
;  pm252@lat2d= wlat
;  pm252@lon2d= wlon
;  pm251b@lat2d= wlat
;  pm251b@lon2d= wlon
;  pm252b@lat2d= wlat
;  pm252b@lon2d= wlon
   pm251_all  = dim_sum_n(pm251,  1)
   pm251_allb = dim_sum_n(pm251b, 1)
   pm252_allb = dim_sum_n(pm252b, 1)
   pm253_allb = dim_sum_n(pm253b, 1)
   pm254_allb = dim_sum_n(pm254b, 1)
;  wtime(0) IS # OF WRFCHEM FILES
;  wtime(1) IS # OF TIME STRING
   ncount     = dimsizes(wtime)
   nfiles     = ncount(0)
   nday       = floattoint(nfiles/nhour)
   dim        = dimsizes(wlat)
   nlat       = dim(0)
   nlon       = dim(1)
   nhourly_true = num(.not.ismissing(date(:, 0)))

;  EXTRACT YEAR, MONTH, DAY, AND HOUR FROM WRFCHEM FILENAME
   wyear      = new(nfiles, integer)
   wmonth     = new(nfiles, integer)
   wday       = new(nfiles, integer)
   whour      = new(nfiles, integer)
   do i = 0, nfiles-1
    wyear(i)  = stringtoint(str_get_cols(charactertostring(wtime(i, :)), 0, 3))
    wmonth(i) = stringtoint(str_get_cols(charactertostring(wtime(i, :)), 5, 6))
    wday(i)   = stringtoint(str_get_cols(charactertostring(wtime(i, :)), 8, 9))
    whour(i)  = stringtoint(str_get_cols(charactertostring(wtime(i, :)), 11, 12))
   end do

   swdata1    = new(nfiles, float)
   swdata2    = new(nfiles, float)
   swdata1b   = new(nfiles, float)
   swdata2b   = new(nfiles, float)
   swdata3b   = new(nfiles, float)
   swdata4b   = new(nfiles, float)
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
     oned_pm251 = ndtooned(pm251_all(index1(0), :, :))
     oned_pm251b= ndtooned(pm251_allb(index1(0), :, :))
     oned_pm252b= ndtooned(pm252_allb(index1(0), :, :))
     oned_pm253b= ndtooned(pm253_allb(index1(0), :, :))
     oned_pm254b= ndtooned(pm254_allb(index1(0), :, :))
     index2 = ind(oned_wlat   .ge. latitude  - 0.5 .and. \
                  oned_wlat   .le. latitude  + 0.5 .and. \
                  oned_wlon   .ge. longitude - 0.5 .and. \
                  oned_wlon   .le. longitude + 0.5 .and. \
                  oned_pm251  .gt. 0.0             .and. \
                  oned_pm251b .gt. 0.0             .and. \
                  oned_pm252b .gt. 0.0             .and. \
                  oned_pm253b .gt. 0.0             .and. \
                  oned_pm254b .gt. 0.0)
     if (.not.all(ismissing(index2))) then
      swdata1(iselect) = avg(oned_pm251(index2))
      swdata1b(iselect)= avg(oned_pm251b(index2))
      swdata2b(iselect)= avg(oned_pm252b(index2))
      swdata3b(iselect)= avg(oned_pm253b(index2))
      swdata4b(iselect)= avg(oned_pm254b(index2))
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

   swdataa = swdata1
   swdatab = swdata1b + swdata2b + swdata3b + swdata4b
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
   delete([/swdata1, swdata2, swdata, saod, swyear, swmonth, swday, swhour/])
;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "point_wrfchem_aeronet_daily_pm.ncl", 0)

return
end
