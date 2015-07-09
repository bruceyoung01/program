;  $ID: convert_utc_to_local.ncl V01 02/27/2013 14:01 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE convert_utc_to_local CONVERTS UTC TIME TO LOCAL TIME.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/27/2013)
;*******************************************************************************
undef("convert_utc_to_local")
procedure convert_utc_to_local \
         (utc_pm     :float,         utc_pm_std      :float,   \; INPUT
          local_pm   :float,         local_pm_std    :float)    ; OUTPUT

begin
;  CONVERT THE UTC TIME ARRAY TO LOCAL TIME ARRAY
;  NOTE: ATLANTA LOCAL TIME IS LESS THAN 5:00 OF UTC TIME.
   do i = 0, 23
    if (i .lt. 5) then
     local_pm(24-5+i)     = utc_pm(i)
     local_pm_std(24-5+i) = utc_pm_std(i)
    else
     local_pm(i-5)      = utc_pm(i)
     local_pm_std(i-5)  = utc_pm_std(i)
    end if
   end do
return
end
