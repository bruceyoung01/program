;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTION : DECTOBIN                                                ;
; PURPOSE OF THIS PROGRAM :                                          ;
; CONVERT DECIMAL SYSTEM (LONG) TO BINARY FOR ONE NUMBER             ;
; BRUCE (11/20/2011 17:03)                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function dectobin_long(dec_num:long)
local dq, cmd
begin
;---Double quote character
  dq = str_get_dq()

;---UNIX command that converts decimal to binary
  cmd = "echo " + dq + "ibase=10;obase=2;" + \
         dq + dec_num + " | bc "

;---Execute UNIX command and return an integer
  return(tolong(systemfunc(cmd)))
end
