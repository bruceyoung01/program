;  $ID: convert_local_to_utc_all.ncl V01 03/13/2013 10:34 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM convert_local_to_utc_all.ncl CONVERT LOCAL DATE AND TIME TO UTC 
;  DATE AND TIME.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) local_year    (integer)  : year of LOCAL TIME.                  [---]
;  (2 ) local_month   (integer)  : month of LOCAL TIME.                 [---]
;  (3 ) local_day     (integer)  : day of LOCAL TIME.                   [---]
;  (4 ) local_hour    (integer)  : hour of LOCAL TIME.                  [---]
;  (5 ) time_lag    (integer)  : hour difference between LOCAL TIME AND 
;                                UTC TIME. time_lag = LOCAL_TIME-UTC_TIME
;                                                                       [---]
;  (6 ) utc_year  (integer)    : year of UTC TIME.                      [---]
;  (7 ) utc_month (integer)    : month of UTC TIME.                     [---]
;  (8 ) utc_day   (integer)    : day of UTC TIME.                       [---]
;  (9 ) utc_hour  (integer)    : hour of UTC TIME.                      [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/13/2013)
;******************************************************************************
undef("convert_local_to_utc_all")
procedure convert_local_to_utc_all \
          (local_year       :integer,  local_month    :integer,  \; INPUT
           local_day        :integer,  local_hour     :integer,  \; INPUT
           time_lag         :integer,                            \; INPUT
           utc_year         :integer,  utc_month      :integer,  \; OUTPUT
           utc_day          :integer,  utc_hour       :integer)   ; OUTPUT

begin
;  CONVERT GREGORIAN DATE TO JULIAN DAY
   index = ind(local_hour .eq. 24)
   if (all(ismissing(index))) then
    jul  = greg2jul(local_year, local_month, local_day, local_hour)
   else
    local_hour = local_hour - 1
    jul  = greg2jul(local_year, local_month, local_day, local_hour)
    jul(index) = jul(index) + 1
   end if
   jul  = jul - (time_lag-1)/24.
   greg = jul2greg(jul)
   utc_year  = greg(:, 0)
   utc_month = greg(:, 1)
   utc_day   = greg(:, 2)
   utc_hour  = greg(:, 3)
   delete([/index/])
return
end
