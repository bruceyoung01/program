; $ID: doe_arm_monthly_average_1v_multiyear.ncl V01 04/06/2012 17:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE doe_arm_monthly_average_1v_multiyear CALCULATE THE MONTHLY 
;  AVERAGE OF ARM DATA FROM DAILY AVERAGE OF ONE VARIABLE FOR MULTIYEAR.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) data_daily   (float): DAILY AVERAGE OF DOE ARM DATA             [---]
;  (2 ) ydata_monthly(float): MONTHLY AVERAGE OF MULTIYEAR OF DOE ARM 
;                             DATA, INCLUDING YEAR, MONTH, AND STANDARD
;                             DEVIATION                                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/06/2012)
;  (2 ) MODIFIED FROM doe_arm_monthly_average_1v.ncl. (04/06/2012)
;******************************************************************************

undef("doe_arm_monthly_average_1v_multiyear")
procedure doe_arm_monthly_average_1v_multiyear(data_daily   :float,  \ ;INPUT
                                               ydata_monthly:float)    ;OUTPUT


begin

;  DO YEAR AND MONTH LOOP TO CALCULATE MONTHLY AVERAGE
   k    = 0
   do j = 1, 12
    month = ndtooned(data_daily(1, :))
    data  = ndtooned(data_daily(3, :))
    index = ind(month .eq. j)
    if (.not.all(ismissing(index)) .and. \
        .not.all(ismissing(data(index)))) then
     ydata_monthly(0, k) = month(index(0))
     ydata_monthly(1, k) = avg(data(index))
     ydata_monthly(2, k) = stddev(data(index))
    end if
    k = k + 1
    delete(index)
   end do
return
end
