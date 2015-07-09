; $ID: point_wrfchem_aeronet_daily_interpolate_factor.ncl V01 01/10/2012 14:32 
;      BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE point_wrfchem_aeronet_daily_interpolate_factor IS USED TO SELECT THE 
;  SPECIFIC POINTS FROM WRFCHEM OUTPUT DEPENDING ON TIME (DAY) AND LOCATION AND 
;  INTERPOLATE WRFCHEM WAVELENGTH AOD EQUAL TO AERONET AOD.
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
;  (10) factor    (float)   : FACTOR BETWEEN AERONET AND WRFCHEM         [---]
;  (11) nfiles    (integer) : # OF ALL THE WRFCHEM OUTPUT FILES          [---]
;  (12) saod_daily(float)   : SELECTED AERONET SITE AOD DATA             [---]
;  (13) swdata_daily1(float): SELECTED WRFCHEM OUTPUT DATA               [ug/m3]
;  (14) swdata_daily2(float): SELECTED WRFCHEM OUTPUT DATA               [ug/m3]
;  (15) swdata_daily (float): INTERPOLATED WRFCHEM OUTPUT DATA           [ug/m3]
;  (16) saod_daily_std(float): STANDARD DEVIATION OF AERONET             [---]
;  (17) swdata_daily_std1(float): STANDARD DEVIATION OF WRFCHEM          [ug/m3]
;  (18) swdata_daily_std2(float): STANDARD DEVIATION OF WRFCHEM          [ug/m3]
;  (19) swdata_daily_std (float): STANDARD DEVIATION OF WRFCHEM          [ug/m3]
;  (20) saod_monthly(float): AEROENT SITES AOD DATA MONTHLY AVERAGE      [---]
;  (21) swdata_monthly1  (float): MONTHLY AVERAGE OF SELECTED WRFCHEM    [ug/m3]
;  (22) swdata_monthly2  (float): MONTHLY AVERAGE OF SELECTED WRFCHEM    [ug/m3]
;  (23) swdata_monthly   (float): MONTHLY AVERAGE OF INTERPOLATED WRFCHEM[ug/m3]
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
;******************************************************************************

undef("point_wrfchem_aeronet_daily_interpolate_factor")
procedure point_wrfchem_aeronet_daily_interpolate_factor \
                (wdir              :string,  sfile          :string,  \ ; INPUT
                 iselect           :integer, date           :integer, \ ; INPUT
                 nhour             :integer, nitem          :integer, \ ; INPUT
                 longitude         :float,   latitude       :float,   \ ; INPUT
                 nhourly           :integer, aod_hourly     :float,   \ ; INPUT
                 factor            :float,   lambda1        :float,   \ ; INPUT
                 lambda2           :float,   lambda         :float,   \ ; INPUT
                 nfiles            :integer,                          \ ; OUTPUT
                 saod_daily        :float,swdata_daily1     :float,   \ ; OUTPUT
                 swdata_daily2     :float,swdata_daily      :float,   \ ; OUTPUT
                 saod_daily_std    :float,swdata_daily_std1 :float,   \ ; OUTPUT
                 swdata_daily_std2 :float,swdata_daily_std  :float,   \ ; OUTPUT
                 saod_monthly      :float,swdata_monthly1   :float,   \ ; OUTPUT
                 swdata_monthly2   :float,swdata_monthly    :float)     ; OUTPUT


begin
;  READ WRFCHEM OUTPUT
   files = systemfunc("ls " + wdir + sfile)
   a     = addfiles(files, "r")
   delete(files)
   ListSetType(a, "join")

   wtime      = a[:]->Times(:,0,:)
   pm251      = a[:]->TAUAER2(:, 0, :, :, :)
   pm251@lat2d= a[:]->XLAT(:, 0, :, :)
   pm251@lon2d= a[:]->XLONG(:, 0, :, :)
   pm252      = a[:]->TAUAER3(:, 0, :, :, :)
   pm252@lat2d= a[:]->XLAT(:, 0, :, :)
   pm252@lon2d= a[:]->XLONG(:, 0, :, :)
   wlat       = a[:]->XLAT(:, 0, :, :)
   wlon       = a[:]->XLONG(:, 0, :, :)
   pm251_all   = dim_sum_n(pm251, 1)*factor
   pm252_all   = dim_sum_n(pm252, 1)*factor
;  wtime(0) IS # OF WRFCHEM FILES
;  wtime(1) IS # OF TIME STRING
   ncount     = dimsizes(wtime)
   nfiles     = ncount(0)
   nday       = floattoint(nfiles/nhour)
   dim        = dimsizes(wlat)
   nlat       = dim(1)
   nlon       = dim(2)
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
   saod       = new((/nfiles, nitem/),  float)
   swyear     = new(nfiles, integer)
   swmonth    = new(nfiles, integer)
   swday      = new(nfiles, integer)
   swhour     = new(nfiles, integer)

;  DO LOOP TO SELECT WRFCHEM DATA POINT DEPENDING ON AERONET SITES
   do ihour = 0, nhourly_true-1
    do ifile = 0, nfiles-1
     if (wyear(ifile)  .eq. date(ihour, 0) .and. \
         wmonth(ifile) .eq. date(ihour, 1) .and. \
         wday(ifile)   .eq. date(ihour, 2) .and. \
         whour(ifile)  .eq. date(ihour, 3) .and. \
         .not.ismissing(date(ihour, 0))    .and. \
         .not.ismissing(date(ihour, 1))    .and. \
         .not.ismissing(date(ihour, 2))    .and. \
         .not.ismissing(date(ihour, 3))) then
      do i = 0, nlat-2
       do j = 0, nlon-2
        if (longitude .gt. wlon(ifile, i, j)     .and. \
            longitude .lt. wlon(ifile, i+1, j+1) .and. \
            latitude  .gt. wlat(ifile, i, j)     .and. \
            latitude  .lt. wlat(ifile, i+1, j+1) .and. \
            pm251_all(ifile, i, j) .gt. 0.0      .and. \
            pm252_all(ifile, i, j) .gt. 0.0) then
         swdata1(iselect) = pm251_all(ifile, i, j)
         swdata2(iselect) = pm252_all(ifile, i, j)
         saod(iselect, :) = aod_hourly(ihour, :)
         swyear(iselect)  = wyear(ifile)
         swmonth(iselect) = wmonth(ifile)
         swday(iselect)   = wday(ifile)
         swhour(iselect)  = whour(ifile)
        end if
       end do ; END OF J LOOP
      end do  ; END OF I LOOP
     iselect = iselect + 1
     end if
    end do    ; END OF IFILE LOOP
   end do     ; END OF IHOUR LOOP
   delete([/wyear, wmonth, wday, whour/])

;  INTERPOLATE WRFCHEM AOD TO THE WAVELENGTH WHICH IS EXACT EQUAL TO 
;  AERONET AOD
   alpha = log(swdata2/swdata1)/log(lambda2/lambda1)
   beta  = swdata1*lambda^alpha
   swdata= beta*lambda^(-alpha)

;  DO NDAY LOOP TO CALCULATE DAILY AVERAGE FOR WRFCHEM
   do imonth = 0, 0
    do iday = 0, nday-1
     index = ind(swmonth .eq. imonth+2 .and. swday .eq. iday+1)
     if (.not.all(ismissing(index))          .and. \
         .not.all(ismissing(swdata1(index))) .and. \
         .not.all(ismissing(swdata2(index))) .and. \
         .not.all(ismissing(swdata(index)))) then
      swdata_daily1(iday)     = avg(swdata1(index))
      swdata_daily_std1(iday) = stddev(swdata1(index))
      swdata_daily2(iday)     = avg(swdata2(index))
      swdata_daily_std2(iday) = stddev(swdata2(index))
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
   if (.not.all(ismissing(swdata_daily1)) .and. \
       .not.all(ismissing(swdata_daily2)) .and. \
       .not.all(ismissing(swdata_daily))) then
    swdata_monthly1 = avg(swdata_daily1)
    swdata_monthly2 = avg(swdata_daily2)
    swdata_monthly  = avg(swdata_daily)
   end if
   delete([/swdata1, swdata2, swdata, saod, swyear, swmonth, swday, swhour/])
return
end
