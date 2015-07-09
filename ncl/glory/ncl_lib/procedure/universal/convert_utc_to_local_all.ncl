;  $ID: convert_utc_to_local_all.ncl V01 03/13/2013 10:34 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM convert_utc_to_local_all.ncl CONVERT UTC DATE AND TIME TO LOCAL 
;  DATE AND TIME.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) utc_year    (integer)  : year of UTC TIME.                      [---]
;  (2 ) utc_month   (integer)  : month of UTC TIME.                     [---]
;  (3 ) utc_day     (integer)  : day of UTC TIME.                       [---]
;  (4 ) utc_hour    (integer)  : hour of UTC TIME.                      [---]
;  (5 ) time_lag    (integer)  : hour difference between LOCAL TIME AND 
;                                UTC TIME. time_lag = LOCAL_TIME-UTC_TIME
;                                                                       [---]
;  (6 ) local_year  (integer)  : year of LOCAL TIME.                    [---]
;  (7 ) local_month (integer)  : month of LOCAL TIME.                   [---]
;  (8 ) local_day   (integer)  : day of LOCAL TIME.                     [---]
;  (9 ) local_hour  (integer)  : hour of LOCAL TIME.                    [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/13/2013)
;******************************************************************************
undef("convert_utc_to_local_all")
procedure convert_utc_to_local_all \
          (utc_year         :integer,  utc_month      :integer,  \; INPUT
           utc_day          :integer,  utc_hour       :integer,  \; INPUT
           time_lag         :integer,                            \; INPUT
           local_year       :integer,  local_month    :integer,  \; OUTPUT
           local_day        :integer,  local_hour     :integer)   ; OUTPUT

begin
;  CONVERT GREGORIAN DATE TO JULIAN DAY
   index = ind(utc_hour .eq. 24)
   if (all(ismissing(index))) then
    jul  = greg2jul(utc_year, utc_month, utc_day, utc_hour)
   else
    utc_hour = utc_hour - 1
    jul  = greg2jul(utc_year, utc_month, utc_day, utc_hour)
    jul(index) = jul(index) + 1
   end if
   jul  = jul + (time_lag-1)/24.
   greg = jul2greg(jul)
   local_year  = greg(:, 0)
   local_month = greg(:, 1)
   local_day   = greg(:, 2)
   local_hour  = greg(:, 3)
   delete([/index/])
return
end
