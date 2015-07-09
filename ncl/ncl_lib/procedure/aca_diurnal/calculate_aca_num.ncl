;  $ID: calculate_aca_num.ncl V01 06/24/2015 13:30 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_aca_num.ncl CALCULATES THE TOTAL NUMBER FOR NON MISSING
;  VARIABLES
;
;  VARIABLES:
;  ============================================================================
;  (1 ) data1   (2-D):DATA1 TO CALCULATE NUMBER                           [   ]
;  (2 ) data2   (2-D):DATA2 TO CALCULATE NUMBER                           [   ]
;  (3 ) data3   (1-D):NUMBER OF DATA1                                     [   ]
;  (4 ) data4   (1-D):NUMBER OF DATA2                                     [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/24/2015)
;******************************************************************************
undef("calculate_aca_num")
procedure calculate_aca_num \
          (data1    :numeric,  data2   :numeric, \;INPUT
           data3    :integer,  data4   :integer)  ;OUTPUT

begin

;  GET DIMENSION INFO FROM data1
   ndim = dimsizes(data1)
   nday = ndim(0)

;  DO DAY LOOP TO CALCULATE THE NON-MISSING VALUES IN EACH DAY
   do i = 0, nday-1
      data3(i) = num(.not.ismissing(data1(i, :)))
      data4(i) = num(.not.ismissing(data2(i, :)))
   end do

return
end
