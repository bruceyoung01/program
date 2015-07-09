; $ID: doe_arm_monthly_average_6v.ncl V01 04/06/2012 15:05 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE doe_arm_monthly_average_6v CALCULATE THE MONTHLY AVERAGE OF ARM 
;  DATA FROM DAILY AVERAGE FOR MULTIYEAR.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) data_daily   (float): DAILY AVERAGE OF DOE ARM DATA, INCLUDING
;                             YEAR, MONTH, AND DAY                      [---]
;  (2 ) data_monthly (float): MONTHLY AVERAGE OF DOE ARM DATA, INCLUDING
;                             YEAR, MONTH                               [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/06/2012)
;  (2 ) MODIFIED FROM doe_arm_monthly_average_1v.ncl. (04/07/2012)
;******************************************************************************

undef("doe_arm_monthly_average_6v")
procedure doe_arm_monthly_average_6v(data_daily   :float,  \ ;INPUT
                                     data_monthly :float)    ;OUTPUT


begin

;  DO YEAR AND MONTH LOOP TO CALCULATE MONTHLY AVERAGE
   k    = 0
;  FOR AEROSOL ABSORPTION COEFFICIENT
   do i = 2007, 2011
;  FOR ALL THE LONG-TERM
;  do i = 1993, 2012
    do j = 1, 12
     year  = ndtooned(data_daily(0, :))
     month = ndtooned(data_daily(1, :))
     data3 = ndtooned(data_daily(3, :))
     data4 = ndtooned(data_daily(4, :))
     data5 = ndtooned(data_daily(5, :))
     data6 = ndtooned(data_daily(6, :))
     data7 = ndtooned(data_daily(7, :))
     data8 = ndtooned(data_daily(8, :))
     index = ind(year .eq. i .and. \
                 month .eq. j)
     if (.not.all(ismissing(index)) .and. \
         .not.all(ismissing(data3(index))) .and. \
         .not.all(ismissing(data4(index))) .and. \
         .not.all(ismissing(data5(index))) .and. \
         .not.all(ismissing(data6(index))) .and. \
         .not.all(ismissing(data7(index))) .and. \
         .not.all(ismissing(data8(index)))) then
      data_monthly(0, k) = year(index(0))
      data_monthly(1, k) = month(index(0))
      data_monthly(2, k) = avg(data3(index))
      data_monthly(3, k) = avg(data4(index))
      data_monthly(4, k) = avg(data5(index))
      data_monthly(5, k) = avg(data6(index))
      data_monthly(6, k) = avg(data7(index))
      data_monthly(7, k) = avg(data8(index))
     end if
     k = k + 1
     delete(index)
    end do
   end do

return
end
