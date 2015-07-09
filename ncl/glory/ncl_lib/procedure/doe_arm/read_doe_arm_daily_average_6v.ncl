; $ID: read_doe_arm_daily_average_6v.ncl V01 04/06/2012 11:15 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE read_doe_arm_daily_average_6v READ DOE ARM DATA AND CALCULATE 
;  DAILY AVERAGE FOR 6 VARIABLES.
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

undef("read_doe_arm_daily_average_6v")
procedure read_doe_arm_daily_average_6v(dir       :string, fname  :string, \ ;INPUT
                                        nfname    :integer,                \ ;INPUT
                                        data_daily:float)


begin

;  READ VARIABLE FROM ARM DATA AND CALCULATE AVERAGE
   do i = 0, nfname-1
    a                = addfile(dir + fname(i), "r")
;  DETERMINE THE CATEGORY OF DATA
    dtype            = str_get_cols(fname(i), 0, 10)
;  CORRECTED ABSORPTION COEFFICIENT AT 1um AND 10um FOR 
;  GREEN, BLUE, AND RED
    if (dtype .eq. "sgpaosC1.a1") then
     acg1            = a->Ba_G_Dry_1um_PSAP3W_1
     acg10           = a->Ba_G_Dry_10um_PSAP3W_1
     acb1            = a->Ba_B_Dry_1um_PSAP3W_1
     acb10           = a->Ba_B_Dry_10um_PSAP3W_1
     acr1            = a->Ba_R_Dry_1um_PSAP3W_1
     acr10           = a->Ba_R_Dry_10um_PSAP3W_1
     if (.not. all(ismissing(acg1)) .and. \
         .not. all(ismissing(acg10)) .and. \
         .not. all(ismissing(acb1)) .and. \
         .not. all(ismissing(acb10)) .and. \
         .not. all(ismissing(acr1)) .and. \
         .not. all(ismissing(acr10))) then
      data_daily(3, i)= avg(acg1)
      data_daily(4, i)= avg(acg10)
      data_daily(5, i)= avg(acb1)
      data_daily(6, i)= avg(acb10)
      data_daily(7, i)= avg(acr1)
      data_daily(8, i)= avg(acr10)
      data_daily(0, i)= stringtofloat(str_get_cols(fname(i), 12, 15))
      data_daily(1, i)= stringtofloat(str_get_cols(fname(i), 16, 17))
      data_daily(2, i)= stringtofloat(str_get_cols(fname(i), 18, 19))
     end if
     delete([/acg1, acg10, acb1, acb10, acr1, acr10/])
    end if
   end do 

return
end
