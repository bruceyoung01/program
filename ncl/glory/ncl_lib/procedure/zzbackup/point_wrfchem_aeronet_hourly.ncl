; $ID: point_wrfchem_aeronet_hourly.ncl V01 01/10/2012 14:32 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE point_wrfchem_aeronet_hourly IS USED TO SELECT THE SPECIFIC 
;  POINTS FROM WRFCHEM OUTPUT DEPENDING ON TIME (HOUR) AND LOCATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wdir      (string) : WRFCHEM OUTPUT FILE DIRECTORY             [---]
;  (2 ) sfile     (string) : WRFCHEM FILE NAME                         [---]
;  (3 ) iselect   (string) : # OF SELECTED HOURS EACH SITE             [---]
;  (4 ) date      (integer): ARRAY INCLUDING YEAR, MONTH, DAY, AND HOUR[---]
;  (5 ) nhour     (integer): # OF HOURS PER DAY (24)                   [---]
;  (6 ) longitude (float)  : AERONET SITE LONGITUDE                    [deg]
;  (7 ) latitude  (float)  : AERONET SITE LATITUDE                     [deg]
;  (8 ) nhourly   (integer): PRE-DEFINED # OF HOURS PER AERONET SITE   [---]
;  (9 ) aod_hourly(float)  : TOTAL HOURLY AOD DATA PER SITE            [---]
;  (10) nfiles    (integer): # OF ALL THE WRFCHEM OUTPUT FILES         [---]
;  (11) saod      (float)  : SELECTED AERONET SITE AOD DATA            [---]
;  (12) swdata    (float)  : SELECTED WRFCHEM OUTPUT DATA              [ug/m3]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/10/2012)
;******************************************************************************

undef("point_wrfchem_aeronet_hourly")
procedure point_wrfchem_aeronet_hourly \
                               (wdir      :string,  sfile     :string,  \ ; INPUT
                                iselect   :integer, date      :integer, \ ; INPUT
                                nhour     :integer                    , \ ; INPUT
                                longitude :float,   latitude  :float,   \ ; INPUT
                                nhourly   :integer, aod_hourly:float,   \ ; INPUT
                                nfiles    :integer,                     \ ; OUTPUT
                                saod      :float,   swdata    :float)     ; OUTPUT

begin
;  READ WRFCHEM OUTPUT

   files = systemfunc("ls " + wdir + sfile)
   a     = addfiles(files, "r")
   ListSetType(a, "join")

   wtime      = a[:]->Times(:,0,:)
   pm25       = a[:]->TAUAER3(:, 0, :, :, :)
   pm25@lat2d = a[:]->XLAT(:, 0, :, :)
   pm25@lon2d = a[:]->XLONG(:, 0, :, :)
   wlat       = a[:]->XLAT(:, 0, :, :)
   wlon       = a[:]->XLONG(:, 0, :, :)
   pm25_all   = dim_sum_n(pm25, 1)
;  wtime(0) IS # OF WRFCHEM FILES
;  wtime(1) IS # OF TIME STRING
   ncount     = dimsizes(wtime)
   nfiles     = ncount(0)
   nday       = floattoint(nfiles/nhour)
   dim        = dimsizes(wlat)
   nlat       = dim(1)
   nlon       = dim(2)
   nhourly_true = num(.not.ismissing(date(:, 0)))

;  SPECIFY YEAR, MONTH, DAY, AND HOUR FROM WRFCHEM FILENAME
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
            pm25_all(ifile, i, j) .gt. 0.0) then
         swdata(iselect)  = pm25_all(ifile, i, j)
         saod(iselect, :) = aod_hourly(ihour, :)
        end if
       end do ; END OF J LOOP
      end do  ; END OF I LOOP
     iselect = iselect + 1
     end if
    end do    ; END OF IFILE LOOP
   end do     ; END OF IHOUR LOOP
   delete([/wyear, wmonth, wday, whour/])
return
end
