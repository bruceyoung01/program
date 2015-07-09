; $ID: doe_arm_monthly_average_6v_multiyear.ncl V01 04/06/2012 17:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE doe_arm_monthly_average_6v_multiyear CALCULATE THE MONTHLY 
;  AVERAGE OF ARM DATA FROM DAILY AVERAGE OF SIX VARIABLES FOR MULTIYEAR.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) data_daily   (float): DAILY AVERAGE OF DOE ARM DATA             [---]
;  (2 ) ydata_monthly(float): MONTHLY AVERAGE OF MULTIYEAR OF DOE ARM 
;                             DATA, INCLUDING YEAR, MONTH               [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/06/2012)
;  (2 ) MODIFIED FROM doe_arm_monthly_average_1v.ncl. (04/06/2012)
;  (3 ) MODIFIED FROM doe_arm_monthly_average_1v_multiyear.ncl. (04/07/2012)
;******************************************************************************

undef("doe_arm_monthly_average_6v_multiyear")
procedure doe_arm_monthly_average_6v_multiyear(data_daily   :float,  \ ;INPUT
                                               ydata_monthly:float)    ;OUTPUT


begin

;  DO YEAR AND MONTH LOOP TO CALCULATE MONTHLY AVERAGE
   k    = 0
   do j = 1, 12
    month = ndtooned(data_daily(1, :))
    data3 = ndtooned(data_daily(3, :))
    data4 = ndtooned(data_daily(4, :))
    data5 = ndtooned(data_daily(5, :))
    data6 = ndtooned(data_daily(6, :))
    data7 = ndtooned(data_daily(7, :))
    data8 = ndtooned(data_daily(8, :))
    index = ind(month .eq. j)
    if (.not.all(ismissing(index)) .and. \
        .not.all(ismissing(data3(index))) .and. \
        .not.all(ismissing(data4(index))) .and. \
        .not.all(ismissing(data5(index))) .and. \
        .not.all(ismissing(data6(index))) .and. \
        .not.all(ismissing(data7(index))) .and. \
        .not.all(ismissing(data8(index)))) then
     ydata_monthly(0, k) = month(index(0))
     ydata_monthly(1, k) = avg(data3(index))
     ydata_monthly(2, k) = avg(data4(index))
     ydata_monthly(3, k) = avg(data5(index))
     ydata_monthly(4, k) = avg(data6(index))
     ydata_monthly(5, k) = avg(data7(index))
     ydata_monthly(6, k) = avg(data8(index))
    end if
    k = k + 1
    delete(index)
   end do
return
end
