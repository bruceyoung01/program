; $ID: calculate_aeronet_hourly_average.ncl V01 01/09/2012 10:07 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_aeronet_hourly_average IS USED TO CALCULATE THE HOURLY 
;  AVERAGE OF AERONET DATA DEPENDING ON THE OBSERVATION WITHIN THE SAME HOUR.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) nlines     (integer) : # OF TOTAL OBSERVATIONS PER SITES      [---]
;  (2 ) year       (integer) : AERONET OBSERVATION YEAR               [---]
;  (3 ) month      (integer) : AERONET OBSERVATION MONTH              [---]
;  (4 ) day        (integer) : AERONET OBSERVATION DAY                [---]
;  (5 ) hour       (integer) : AEROENT OBSERVATION HOUR               [---]
;  (6 ) aod_raw    (float)   : TOTAL AERONET AOD PER SITE             [---]
;  (7 ) date       (integer) : ARRAY INCLUDING YEAR, MONTH, DAY, AND HOUR
;  (8 ) aod_hourly (float)   : CALCULATED AERONET HOURLY AOD          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/09/2012)
;******************************************************************************

undef("calculate_aeronet_hourly_average")
procedure calculate_aeronet_hourly_average\
         (nlines :integer, year       :integer, \ ; INPUT
          month  :integer, day        :integer, \ ; INPUT
          hour   :integer, aod_raw    :float,   \ ; INPUT
          date   :integer, aod_hourly :float)     ; OUTPUT


begin
;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

;  DO NLINES LOOP (# OF OBSERVATION TIMES PER FILE)
   ndim    = dimsizes(aod_raw)
   nitem   = ndim(1)
   aod_sum = new(nitem, float)
   aod_sum = 0.0
   i = 0
   j = 0
   do ilines = 0, nlines-1
;  JUDGE IF THIS IS THE FIRST LINE DATA OF THE SAME HOUR
    if( i .eq. 0 ) then
     do k = 0, nitem-1
      aod_sum(k) = aod_raw(ilines, k)
     end do
     i = i + 1
;  FOR THE REST OF THE DATA
    else
;  JUDGE IF THIS LINE AND NEXT LINE ARE IN THE SAME HOUR,
;  IF THEY ARE, CALCULATE THE AVERAGE
     if( year(ilines)  .eq. year(ilines-1)  .and. \
         month(ilines) .eq. month(ilines-1) .and. \
         day(ilines)   .eq. day(ilines-1)   .and. \
         hour(ilines)  .eq. hour(ilines-1)) then
      do k = 0, nitem-1
       aod_sum(k) = aod_sum(k) + aod_raw(ilines, k)
      end do
      i = i + 1
;  IF THEY ARE NOT IN THE SAME HOUR, INITIATE THE AVERAGE VARIABLES
      else
;  CALCULATE THE HOURLY AVERAGE OF AERONET DATA
        date(j, 0) = year(ilines-1)
        date(j, 1) = month(ilines-1)
        date(j, 2) = day(ilines-1)
        date(j, 3) = hour(ilines-1)
       do k = 0, nitem-1
        aod_hourly(j, k) = aod_sum(k)/i
        aod_sum(k)       = aod_raw(ilines, k)
       end do
       i = 0
       j = j + 1
     end if
    end if
   end do
;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "calculate_aeronet_hourly_average.ncl", 0)

return
end
