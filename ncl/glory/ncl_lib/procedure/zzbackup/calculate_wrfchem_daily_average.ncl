; $ID: calculate_wrfchem_daily_average.ncl V01 01/18/2012 17:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_wrfchem_daily_average IS USED TO CALCULATE THE DAILY 
;  AVERAGE PER DAY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir         (string) : DIRECTORY OF WRFCHEM DATA                  [---]
;  (2 ) filename    (string) : FILE NAME OF WRFCHEM DATA                  [---]
;  (3 ) nfiles      (integer): # OF FILE NAMES                            [---]
;  (4 ) bv1         (integer): BAD VALUE OF INTEGER                       [---]
;  (5 ) bv2         (float)  : BAD VALUE OF FLOAT                         [---]
;  (6 ) nday        (integer): # OF TOTAL DAYS OF WRFCHEM DATA            [---]
;  (7 ) date        (integer): INCLUDE YEAR, MONTH, DAY, HOUR             [---]
;  (8 ) wlat        (float)  : LATITUDE OF WRFCHEM DATA                   [---]
;  (9 ) wlon        (float)  : LONGITUDE OF WRFCHEM DATA                  [---]
;  (10) t2_daily    (float)  : DAILY AVERAGE 2M TEMPERATURE OF WRFCHEM DATA
;                                                                         [---]
;  (11) pm25_daily  (float)  : DAILY AVERAGE PM2.5 TEMPERATRUE OF WRFCHEM 
;                              DATA                                       [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/18/2012)
;******************************************************************************

undef("calculate_wrfchem_daily_average")
procedure calculate_wrfchem_daily_average(dir         :string, \ ; INPUT
                                          filename    :string, \ ; INPUT
                                          nfiles      :integer,\ ; INPUT
                                          bv1         :integer,\ ; INPUT
                                          bv2         :float,  \ ; INPUT
                                          nday        :integer,\ ; INPUT
                                          date        :integer,\ ; OUTPUT
                                          wlat        :float,  \ ; OUTPUT
                                          wlon        :float,  \ ; OUTPUT
                                          t2_daily    :float,  \ ; OUTPUT
                                          pm25_daily  :float)    ; OUTPUT

begin

;  READ OUT DATE OF WRFCHEM INTO AN ARRARY
   do i = 0, nfiles-1
    date(i, 0) = stringtoint(str_get_cols(filename(i), 11, 14))
    date(i, 1) = stringtoint(str_get_cols(filename(i), 16, 17))
    date(i, 2) = stringtoint(str_get_cols(filename(i), 19, 20))
    date(i, 3) = stringtoint(str_get_cols(filename(i), 22, 23))
   end do
;  SELECT THE WRFCHEM FILES WITH THE SAME HOUR
   do i = 0 , nday-1
    index    = ind(date(:, 2) .eq. i+1)
    nindex   = num(.not.ismissing(index))
    a        = addfiles(dir + filename(index), "r")
    ListSetType(a, "join")
    t2       = a[:]->T2(:, 0, :, :)
    pm25     = a[:]->PM2_5_DRY(:,0, :, :, :)
    wlat     = a[:]->XLAT(0, 0, :, :)
    wlon     = a[:]->XLONG(0, 0, :, :)
    pm25@lat2d = wlat
    pm25@lon2d = wlon
    t2@lat2d = wlat
    t2@lon2d = wlon
    t2_daily(i, :, :)      = dim_sum_n(t2, 0)/nindex
    pm25_daily(i, :, :, :) = dim_sum_n(pm25, 0)/nindex
    print("WORKING ON DAY : " + i)
   end do
   t2_daily@lat2d         = wlat
   t2_daily@lon2d         = wlon
   pm25_daily@lat2d       = wlat
   pm25_daily@lon2d       = wlon
return
end
