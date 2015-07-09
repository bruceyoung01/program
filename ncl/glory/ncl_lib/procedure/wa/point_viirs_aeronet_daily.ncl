; $ID: point_viirs_aeronet_daily V01 04/24/2012 10:45 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE point_viirs_aeronet_daily SELECTS NPP VIIRS EDR DATA DEPENDING 
;  ON THE AERONET SITES INFO, INCLUDING YEAR, MONTH, DAY, HOUR, LATITUDE, 
;  LONGITUDE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv2         (float)  :BAD VALUE FOR FLOAT                        [---]
;  (2 ) nitem       (integer):TOTAL # OF AERONET OBSERVATION ITEM        [---]
;  (3 ) sitem       (integer):SELECTED ITEM FROM AERONET OBSERVATION ITEM[---]
;  (4 ) start_year  (integer):START YEAR OF DATA                         [---]
;  (5 ) end_year    (integer):END YEAR OF DATA                           [---]
;  (6 ) start_month (integer):START MONTH OF DATA                        [---]
;  (7 ) end_month   (integer):END MONTH OF DATA                          [---]
;  (8 ) start_day   (integer):START DAY OF DATA                          [---]
;  (9 ) end_day     (integer):END DAY OF DATA                            [---]
;  (10) thre_lat    (float)  :THRESHOLD OF LATITUDE                      [---]
;  (11) thre_lon    (float)  :THRESHOLD OF LONGITUDE                     [---]
;  (12) vyear       (integer):YEAR OF VIIRS DATA                         [---]
;  (13) vmonth      (integer):MONTH OF VIIRS DATA                        [---]
;  (14) vday        (integer):DAY OF VIIRS DATA                          [---]
;  (15) vlat        (float)  :LATITUDE OF VIIRS DATA                     [deg]
;  (16) vlon        (float)  :LONGITUDE OF VIIRS DATA                    [deg]
;  (17) vaod        (float)  :AOD OF VIIRS DATA                          [---]
;  (18) date        (integer):DATE OF AERONET SITE, INCLUDING YEAR, 
;                             MONTH, DAY, AND HOUR                       [---]
;  (19) latitude    (float)  :LATITUDE OF AERONET SITE                   [deg]
;  (20) longitude   (float)  :LONGITUDE OF AERONET SITE                  [deg]
;  (21) aod_hourly  (float)  :AERONET HOURLY AVERAGE AOD                 [---]
;  (22) aod_hourly_aod(float):AERONET STANDARD DEVIATION HOURLY          [---]
;  (23) syear       (integer):YEAR OF SELECTED AERONET AND VIIRS DATA    [---]
;  (24) smonth      (integer):MONTH OF SELECTED AERONET AND VIIRS DATA   [---]
;  (25) sday        (integer):DAY OF SELECTED AERONET AND VIIRS DATA     [---]
;  (26) svaod       (float)  :SELECTED VIIRS AOD DATA DAILY AVERAGE      [---]
;  (27) svaod_std   (float)  :SELECTED VIIRS AOD DATA STANDARD DEVIATION [---]
;  (28) svaod_monthly(float) :SELECTED VIIRS AOD DATA MONTHLY AVERAGE    [---]
;  (29) saod_daily  (float)  :SELECTED AERONET AOD DATA DAILY AVERAGE    [---]
;  (30) saod_std    (float)  :SELECTED AERONET AOD DATA STANDARD AVERAGE [---]
;  (31) saod_monthly(float)  :SELECTED AERONET AOD DATA MONTHLY AVERAGE  [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/24/2012)
;******************************************************************************

undef("point_viirs_aeronet_daily")
procedure point_viirs_aeronet_daily \
                      (bv2        :float,   nitem     :integer, \ ; INPUT
                       start_year :integer, end_year  :integer, \ ; INPUT
                       start_month:integer, end_month :integer, \ ; INPUT
                       start_day  :integer, end_day   :integer, \ ; INPUT
                       thre_lat   :float,   thre_lon  :float,   \ ; INPUT
                       vyear      :integer, vmonth    :integer, \ ; INPUT
                       vday       :integer,                     \ ; INPUT
                       vlat       :float,  vlon       :float,   \ ; INPUT
                       vaod       :float,  year       :integer, \ ; INPUT
                       month      :integer,day        :integer, \ ; INPUT
                       latitude   :float,                       \ ; INPUT
                       longitude  :float,  aod_hourly :float,   \ ; INPUT
                       syear      :integer,smonth     :integer, \ ; OUTPUT
                       sday       :integer,                     \ ; OUTPUT
                       svaod      :float,  svaod_std  :float,   \ ; OUTPUT
                       svaod_monthly:float,saod_daily :float,   \ ; OUTPUT
                       saod_std   :float,  saod_monthly:float)    ; OUTPUT

begin
;  SELECT NPP VIIRS DATA DEPENDING ON AERONET SITE 
;  LATITUDE, AND LONGITUDE
   oned_vyear  = ndtooned(vyear)
   oned_vmonth = ndtooned(vmonth)
   oned_vday   = ndtooned(vday)
   oned_vlat   = ndtooned(vlat)
   oned_vlon   = ndtooned(vlon)
   oned_vaod   = ndtooned(vaod)
;  DEFINE MISSING VALUE
   index1   = ind(oned_vaod .eq. max(oned_vaod))
   if (.not.all(ismissing(index1))) then
    oned_vaod(index1) = 0.0
   end if
   delete(index1)

;  DEFINE THRESHOLD LATITUDE AND LONGITUDE
   index1      = ind(oned_vlat .ge. latitude  - thre_lat .and. \
                     oned_vlat .le. latitude  + thre_lat .and. \
                     oned_vlon .ge. longitude - thre_lon .and. \
                     oned_vlon .le. longitude + thre_lon)
   if(.not.all(ismissing(index1)))then
;  DO YEAR, MONTH, DAY, AND HOUR LOOP TO AVERAGE THE SELECTED DATA 
;  AROUND AERONET SITES
    ic   = 0
    do i = start_year, end_year
     do j = start_month, end_month
      do k = start_day, end_day
        print("# OF DAY : " + k)
        index2          = ind(oned_vyear(index1)  .eq. i .and. \
                              oned_vmonth(index1) .eq. j .and. \
                              oned_vday(index1)   .eq. k)
        index3          = ind(year  .eq. i .and. \
                              month .eq. j .and. \
                              day   .eq. k)
        if(.not.all(ismissing(index2)) .and. \
           .not.all(ismissing(index3)) .and. \
           .not.all(ismissing(oned_vaod(index2))) .and. \
           .not.all(ismissing(aod_hourly(index3, :))))then
         syear(ic)          = i
         smonth(ic)         = j
         sday(ic)           = k
         svaod(ic)          = avg(oned_vaod(index2))
         svaod_std(ic)      = stddev(oned_vaod(index2))
         saod_daily(ic, :)  = dim_avg_n(aod_hourly(index3, :), 0)
         saod_std(ic, :)    = dim_stddev_n(aod_hourly(index3, :), 0)
        end if
        delete([/index2, index3/])
         ic = ic + 1
      end do
     end do
    end do
   end if
   delete(index1)

;  CALCULATE MONTHLY AVERAGE FOR NPP VIIRS AND AERONET
   if (.not.all(ismissing(svaod))) then
    svaod_monthly = avg(svaod)
   end if
   do i = 0, nitem-1
    if (.not.all(ismissing(saod_daily(:, i)))) then
     saod_monthly(i)  = dim_avg_n(saod_daily(:, i), 0)
    end if
   end do

return
end
