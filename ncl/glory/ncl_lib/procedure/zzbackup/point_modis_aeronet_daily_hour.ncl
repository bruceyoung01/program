; $ID: point_modis_aeronet_daily_hour V01 04/24/2012 10:45 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE point_modis_aeronet_daily_hour SELECTS MODIS AOD DATA 
;  DEPENDING ON THE AERONET SITES INFO, INCLUDING YEAR, MONTH, DAY, HOUR, 
;  LATITUDE, LONGITUDE. SELECTED AERONET DATA BASED ON THE TIME OF MODIS 
;  GRANULE OBSERVATION WITHIN ONE HOUR.
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
;  (12) thre_dis    (float)  :THRESHOLD OF DISTANCE                      [---]
;  (13) vyear       (integer):YEAR OF MODIS DATA                         [---]
;  (14) vmonth      (integer):MONTH OF MODIS DATA                        [---]
;  (15) vday        (integer):DAY OF MODIS DATA                          [---]
;  (16) vhour       (integer):HOUR OF MODIS DATA                         [---]
;  (17) vlat        (float)  :LATITUDE OF MODIS DATA                     [deg]
;  (18) vlon        (float)  :LONGITUDE OF MODIS DATA                    [deg]
;  (19) vaod        (float)  :AOD OF MODIS DATA                          [---]
;  (20) vaod_qf     (integer):AOD OF MODIS DATA QUALITY FLAG             [---]
;  (21) date        (integer):DATE OF AERONET SITE, INCLUDING YEAR, 
;                             MONTH, DAY, AND HOUR                       [---]
;  (22) latitude    (float)  :LATITUDE OF AERONET SITE                   [deg]
;  (23) longitude   (float)  :LONGITUDE OF AERONET SITE                  [deg]
;  (24) aod_hourly  (float)  :AERONET HOURLY AVERAGE AOD                 [---]
;  (25) aod_hourly_aod(float):AERONET STANDARD DEVIATION HOURLY          [---]
;  (26) syear       (integer):YEAR OF SELECTED AERONET AND MODIS DATA    [---]
;  (27) smonth      (integer):MONTH OF SELECTED AERONET AND MODIS DATA   [---]
;  (28) sday        (integer):DAY OF SELECTED AERONET AND MODIS DATA     [---]
;  (29) svaod       (float)  :SELECTED MODIS AOD DATA DAILY AVERAGE      [---]
;  (30) svaod_std   (float)  :SELECTED MODIS AOD DATA STANDARD DEVIATION [---]
;  (31) svaod_monthly(float) :SELECTED MODIS AOD DATA MONTHLY AVERAGE    [---]
;  (32) saod_daily  (float)  :SELECTED AERONET AOD DATA DAILY AVERAGE    [---]
;  (33) saod_std    (float)  :SELECTED AERONET AOD DATA STANDARD AVERAGE [---]
;  (34) saod_monthly(float)  :SELECTED AERONET AOD DATA MONTHLY AVERAGE  [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/24/2012)
;  (2 ) MODIFIED FROM point_MODIS_aeronet_daily.ncl (05/02/2012)
;******************************************************************************

undef("point_modis_aeronet_daily_hour")
procedure point_modis_aeronet_daily_hour \
                      (bv2        :float,   nitem     :integer, \ ; INPUT
                       sitem      :integer,                     \ ; INPUT
                       start_year :integer, end_year  :integer, \ ; INPUT
                       start_month:integer, end_month :integer, \ ; INPUT
                       start_day  :integer, end_day   :integer, \ ; INPUT
                       thre_lat   :float,   thre_lon  :float,   \ ; INPUT
                       thre_dis   :float,                       \ ; INPUT
                       vyear      :integer, vmonth    :integer, \ ; INPUT
                       vday       :integer, vhour     :integer, \ ; INPUT
                       vlat       :float,   vlon      :float,   \ ; INPUT
                       vaod       :float,   vaod_qf   :integer, \ ; INPUT
                       date       :integer,                     \ ; INPUT
                       latitude   :float,   longitude :float,   \ ; INPUT
                       aod_hourly :float,   aod_hourly_std:float,\; INPUT
                       syear      :integer, smonth    :integer, \ ; OUTPUT
                       sday       :integer,                     \ ; OUTPUT
                       svaod      :float,   svaod_std :float,   \ ; OUTPUT
                       svaod_monthly:float, saod_daily:float,   \ ; OUTPUT
                       saod_std   :float,   saod_monthly:float)   ; OUTPUT

begin
;  SELECT MODIS DATA DEPENDING ON AERONET SITE 
;  LATITUDE, AND LONGITUDE
   oned_vyear  = ndtooned(vyear)
   oned_vmonth = ndtooned(vmonth)
   oned_vday   = ndtooned(vday)
   oned_vhour  = ndtooned(vhour)
   oned_vlat   = ndtooned(vlat)
   oned_vlon   = ndtooned(vlon)
   oned_vaod   = ndtooned(vaod)
   oned_vaod_qf= ndtooned(vaod_qf)
;  DIMENSION SIZE
   ndoned_vaod   = dimsizes(oned_vaod)
   oned_latitude = new(ndoned_vaod, float, bv2)
   oned_longitude= new(ndoned_vaod, float, bv2)
   oned_latitude = latitude
   oned_longitude= longitude

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
;  DEFINE THRESHOLD DISTANCE
   if(.not.all(ismissing(index1)))then
    dis = gc_latlon(oned_latitude(index1), oned_longitude(index1), \
                    oned_vlat(index1), oned_vlon(index1), 2, 4)
    index0  = ind(dis .le. thre_dis)
    if(.not.all(ismissing(index0)))then

;  DO YEAR, MONTH, DAY, AND HOUR LOOP TO AVERAGE THE SELECTED DATA 
;  AROUND AERONET SITES
    ic   = 0
    do i = start_year, end_year
     do j = start_month, end_month
      do k = start_day, end_day
        print("# OF DAY : " + k)
        index2           = ind(oned_vyear(index1(index0))  .eq. i .and. \
                               oned_vmonth(index1(index0)) .eq. j .and. \
                               oned_vday(index1(index0))   .eq. k)
;  FIND THE HOUR WHEN oned_aod NOT MISSING
        if(.not.all(ismissing(index2)))then
         index4          = ind(.not.ismissing(oned_vaod(index2)))
         boned_vaod_qf   = ndectobin(oned_vaod_qf(index2))
         ihour           = oned_vhour(index4(0))
         index3          = ind(date(:,0) .eq. i .and. \
                               date(:,1) .eq. j .and. \
                               date(:,2) .eq. k .and. \
                               date(:,3) .eq. ihour)
         if(.not.all(ismissing(index3)) .and. \
            .not.all(ismissing(oned_vaod(index2))))then
          if(.not.all(ismissing(aod_hourly(index3, sitem))))then
;  MODIS AOD QUALITY FLAG, THE VALUE OF bit
;  0:NOT USEFUL
;  1:USEFUL
           low           = "0"
           high          = "1"
           bit           = str_get_cols(boned_vaod_qf, -1, -1)
           index5        = ind(bit .eq. high)
           if(.not.all(ismissing(index5)))then
            syear(ic)          = i
            smonth(ic)         = j
            sday(ic)           = k
            svaod(ic)          = avg(oned_vaod(index2(index5)))
            svaod_std(ic)      = stddev(oned_vaod(index2(index5)))
            saod_daily(ic, sitem) = avg(aod_hourly(index3, sitem))
            saod_std(ic, sitem)   = aod_hourly_std(index3(0), sitem)
            print("# OF SELECTED PIXEL : " + dimsizes(index2(index5)))
            print("SELECTED HOUR FROM MODIS   : " + ihour)
            print("SELECTED HOUR FROM AERONET : " + date(index3, 3))
            print("# OF SELECTED AERONET HOUR : " + dimsizes(index3))
           end if
           delete([/index5, bit/])
          end if
         end if
         delete([/index3, index4, boned_vaod_qf/])
        end if
        delete(index2)
        ic = ic + 1
      end do
     end do
    end do
    end if
    delete(index0)
   end if
   delete(index1)
;  CALCULATE MONTHLY AVERAGE FOR MODIS AND AERONET
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
