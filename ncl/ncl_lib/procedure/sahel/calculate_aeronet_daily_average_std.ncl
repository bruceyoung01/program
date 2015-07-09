; $ID: calculate_aeronet_daily_average_std.ncl V01 01/13/2012 09:34 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_aeronet_daily_average_std IS USED TO CALCULATE THE DAILY 
;  AVERAGE OF AERONET DATA DEPENDING ON THE OBSERVATION WITHIN THE SAME DAY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) start_year  (integer): START YEAR OF DATA                          [---]
;  (2 ) end_year    (integer): END YEAR OF DATA                            [---]
;  (3 ) start_month (integer): START MONTH OF DATA                         [---]
;  (4 ) end_month   (integer): END MONTH OF DATA                           [---]
;  (5 ) start_day   (integer): START DAY OF DATA                           [---]
;  (6 ) end_day     (integer): END DAY OF DATA                             [---]
;  (7 ) nlines     (integer) : # OF TOTAL OBSERVATIONS PER SITES           [---]
;  (8 ) year       (integer) : AERONET OBSERVATION YEAR                    [---]
;  (9 ) month      (integer) : AERONET OBSERVATION MONTH                   [---]
;  (10) day        (integer) : AERONET OBSERVATION DAY                     [---]
;  (11) aod_raw    (float)   : TOTAL AERONET AOD PER SITE (nlines, nitem)  [---]
;  (12) date       (integer) : ARRAY INCLUDING YEAR, MONTH, AND DAY (ndaily, 3)
;  (13) aod_daily  (float)   : CALCULATED AERONET DAILY AOD (ndaily, nitem)[---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;******************************************************************************

undef("calculate_aeronet_daily_average_std")
procedure calculate_aeronet_daily_average_std\
         (start_year :integer, end_year : integer, \ ; INPUT
          start_month:integer, end_month: integer, \ ; INPUT
          start_day  :integer, end_day  : integer, \ ; INPUT
          nlines     :integer, year     :integer,  \ ; INPUT
          month      :integer, day      :integer,  \ ; INPUT
          aod_raw    :float,   bv2      :float,    \ ; INPUT
          date       :integer, aod_daily:float,    \ ; OUTPUT
          aod_daily_std:float)                       ; OUTPUT

begin

;  DO NLINES LOOP (# OF OBSERVATION TIMES PER FILE)
   ndim    = dimsizes(aod_raw)
   nitem   = ndim(1)
   m       = 0
   do i = start_year, end_year
    do j = start_month, end_month
     do k = start_day, end_day
      index = ind(year  .eq. i .and. \
                  month .eq. j .and. \
                  day   .eq. k)
      if(.not.all(ismissing(index)))then
       date(m, 0) = i
       date(m, 1) = j
       date(m, 2) = k
       do l = 0, nitem-1
        if(.not.all(ismissing(aod_raw(index, l))))then
         aod_daily(m, l)     = avg(aod_raw(index, l))
         aod_daily_std(m, l) = stddev(aod_raw(index, l))
        else
         aod_daily(m, l)     = bv2
         aod_daily_std(m, l) = bv2
        end if
       end do
      end if
      m = m + 1
      delete(index)
     end do
    end do
   end do

return
end
