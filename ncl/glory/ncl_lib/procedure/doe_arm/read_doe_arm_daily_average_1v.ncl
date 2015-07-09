; $ID: read_doe_arm_daily_average_1v.ncl V01 04/06/2012 11:15 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE read_doe_arm_daily_average_1v READ DOE ARM DATA AND CALCULATE 
;  DAILY AVERAGE FOR 1 VARIABLE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (string) : DIRECTORY OF ARM DATA                        [---]
;  (2 ) fname     (string) : FILE NAMES OF ARM DATA                       [---]
;  (3 ) nfname    (integer): # OF FILE NAMES OF ARM DATA                  [---]
;  (4 ) data_daily(float)  : DAILY AVERAGE OF ARM DATA, INCLUDING YEAR, 
;                            MONTH, AND DAY                               [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/06/2012)
;******************************************************************************

undef("read_doe_arm_daily_average_1v")
procedure read_doe_arm_daily_average_1v(dir       :string,  fname  :string, \ ;INPUT
                                        nfname    :integer,                 \ ;INPUT
                                        data_daily:float)


begin

;  READ VARIABLE FROM ARM DATA AND CALCULATE AVERAGE
   do i = 0, nfname-1
    a                = addfile(dir + fname(i), "r")
;  DETERMINE THE CATEGORY OF DATA
    dtype            = str_get_cols(fname(i), 0, 10)
;  AEROSOL ABSORPTION OPTICAL DEPTH AT 441nm TOTAL
    if (dtype .eq. "sgpcsphotal") then
     data            = a->AOTAbsp441_T
     index           = ind(data .gt. 0.0)
     if (.not.all(ismissing(index)) .and. \
         .not.all(ismissing(data(index)))) then
      data_daily(3, i)= avg(data(index))
      data_daily(0, i)= stringtofloat(str_get_cols(fname(i), 23, 26))
      data_daily(1, i)= stringtofloat(str_get_cols(fname(i), 27, 28))
      data_daily(2, i)= stringtofloat(str_get_cols(fname(i), 29, 30))
     end if
    end if
;  AOS NUMBER CONCENTRATION OF CCN
    if (dtype .eq. "sgpaosccnC1") then
     data            = a->N_CCN
     index           = ind(data .gt. 0.0)
     if (.not.all(ismissing(index)) .and.       \
         .not.all(ismissing(data(index))) .and. \
         avg(data(index)) .lt. 1000000) then
      data_daily(3, i)= avg(data(index))
      data_daily(0, i)= stringtofloat(str_get_cols(fname(i), 15, 18))
      data_daily(1, i)= stringtofloat(str_get_cols(fname(i), 19, 20))
      data_daily(2, i)= stringtofloat(str_get_cols(fname(i), 21, 22))
     end if
    end if
;  PARTICLE CONCENTRATION
    if (dtype .eq. "sgpaoscpcC1") then
     data            = a->concentration
     index           = ind(data .gt. 0.0)
     if (.not.all(ismissing(index)) .and. \
         .not.all(ismissing(data(index)))) then
      data_daily(3, i)= avg(data(index))
      data_daily(0, i)= stringtofloat(str_get_cols(fname(i), 15, 18))
      data_daily(1, i)= stringtofloat(str_get_cols(fname(i), 19, 20))
      data_daily(2, i)= stringtofloat(str_get_cols(fname(i), 21, 22))
     end if
    end if
    delete([/data, index/])
   end do 

return
end
