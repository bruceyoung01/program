; $ID: doe_arm_monthly_average_1v.ncl V01 04/06/2012 15:05 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE doe_arm_monthly_average_1v CALCULATE THE MONTHLY AVERAGE OF ARM 
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
;******************************************************************************

undef("doe_arm_monthly_average_1v")
procedure doe_arm_monthly_average_1v(data_daily   :float,  \ ;INPUT
                                     data_monthly :float)    ;OUTPUT


begin

;  DO YEAR AND MONTH LOOP TO CALCULATE MONTHLY AVERAGE
   k    = 0
;  FOR ALL LONT-TERM
   do i = 1993, 2012
    do j = 1, 12
     year  = ndtooned(data_daily(0, :))
     month = ndtooned(data_daily(1, :))
     data  = ndtooned(data_daily(3, :))
     index = ind(year .eq. i .and. \
                 month .eq. j)
     if (.not.all(ismissing(index)) .and. \
         .not.all(ismissing(data(index)))) then
      data_monthly(0, k) = year(index(0))
      data_monthly(1, k) = month(index(0))
      data_monthly(2, k) = avg(data(index))
      data_monthly(3, k) = stddev(data(index))
     end if
     k = k + 1
     delete(index)
    end do
   end do

return
end
