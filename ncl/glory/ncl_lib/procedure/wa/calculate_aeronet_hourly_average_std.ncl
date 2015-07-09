; $ID: calculate_aeronet_hourly_average.ncl V01 01/09/2012 10:07 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_aeronet_hourly_average IS USED TO CALCULATE THE HOURLY 
;  AVERAGE OF AERONET DATA DEPENDING ON THE OBSERVATION WITHIN THE SAME HOUR.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv2         (integer): BAD VALUE OF FLOAT                     [---]
;  (2 ) start_year  (integer): START YEAR OF DATA                     [---]
;  (3 ) end_year    (integer): END YEAR OF DATA                       [---]
;  (4 ) start_month (integer): START MONTH OF DATA                    [---]
;  (5 ) end_month   (integer): END MONTH OF DATA                      [---]
;  (6 ) start_day   (integer): START DAY OF DATA                      [---]
;  (7 ) end_day     (integer): END DAY OF DATA                        [---]
;  (8 ) start_hour  (integer): START HOUR OF DATA                     [---]
;  (9 ) end_hour    (integer): END HOUR OF DATA                       [---]
;  (10) year        (integer): AERONET OBSERVATION YEAR               [---]
;  (11) month       (integer): AERONET OBSERVATION MONTH              [---]
;  (12) day         (integer): AERONET OBSERVATION DAY                [---]
;  (13) hour        (integer): AEROENT OBSERVATION HOUR               [---]
;  (14) aod_raw     (float)  : TOTAL AERONET AOD PER SITE             [---]
;  (15) date        (integer): ARRAY INCLUDING YEAR, MONTH, DAY, AND HOUR
;  (16) aod_hourly  (float)  : CALCULATED AERONET HOURLY AOD          [---]
;  (17) aod_hourly_std(float): CALCULATED AERONET HOURLY STANDARD DEVIATION
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/09/2012)
;  (2 ) ADD TO CALCULATE STANDARD DEVIATION aod_hourly_std. (05/03/2012)
;******************************************************************************

undef("calculate_aeronet_hourly_average_std")
procedure calculate_aeronet_hourly_average_std\
         (bv2        :float,                       \ ; INPUT
          start_year :integer, end_year  :integer, \ ; INPUT
          start_month:integer, end_month :integer, \ ; INPUT
          start_day  :integer, end_day   :integer, \ ; INPUT
          start_hour :integer, end_hour  :integer, \ ; INPUT
          nitem      :integer, year      :integer, \ ; INPUT
          month      :integer, day       :integer, \ ; INPUT
          hour       :integer, aod_raw   :float,   \ ; INPUT
          date       :integer, aod_hourly:float,   \ ; OUTPUT
          aod_hourly_std :float)                     ; OUTPUT


begin
;  DO YEAR, MONTH, DAY, AND HOUR LOOP
   ic = 0
   do i = start_year, end_year
    do j = start_month, end_month
     do k = start_day, end_day
      do l = start_hour, end_hour
       index1 = ind(year  .eq. i .and. \
                    month .eq. j .and. \
                    day   .eq. k .and. \
                    hour  .eq. l)
       date(ic, 0)        = i
       date(ic, 1)        = j
       date(ic, 2)        = k
       date(ic, 3)        = l
       do m = 0, nitem-1
        if(.not.all(ismissing(index1)) .and. \
           .not.all(ismissing(aod_raw(index1, m))))then
         aod_hourly(ic, m)     = avg(aod_raw(index1, m))
         aod_hourly_std(ic, m) = stddev(aod_raw(index1, m))
        else
         aod_hourly(ic, m)     = bv2
         aod_hourly_std(ic, m) = bv2
        end if
       end do
       ic = ic + 1
       delete(index1)
      end do
     end do
    end do
   end do

return
end
