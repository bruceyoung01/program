; $ID: bintoint.ncl V01 11/25/2015 08:00 ZHIFENG YANG EXP$
;
;******************************************************************************
;  FUNCTION bintoint.ncl CONVERTS BINARY TO INTEGER.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bin_num   (string) : BINARY TO BE CONVERTED TO INTEGER            [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY Mary.
;  (2 ) MODIFIED BY ZHIFENG YANG. (05/05/2012)
;******************************************************************************

function bintoint(bin_num:string) 
local dq, cmd
begin
;---Double quote character
  dq = str_get_dq()
;---UNIX command that converts decimal to binary
  cmd = "echo " + dq + "obase=10;ibase=2;" + dq + bin_num + " | bc "
;---Execute UNIX command and return an integer
  return(toint(systemfunc(cmd)))
end
