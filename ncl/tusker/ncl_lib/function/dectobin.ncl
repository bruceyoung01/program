; $ID: dectobin.ncl V01 05/05/2012 20:45 BRUCE EXP$
;
;******************************************************************************
;  FUNCTION dectoint CONVERTS DECIMAL TO BINARY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dec_num   (integer) : DECIMAL NUMBER TO BE CONVERTED TO BINARY.  [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY Mary. (NOT CLEAR)
;  (2 ) MODIFIED BY BRUCE. (05/05/2012)
;******************************************************************************

function dectobin(dec_num:integer) 
local dq, cmd 
begin 
;---Double quote character 
  dq = str_get_dq() 
;---UNIX command that converts decimal to binary 
  cmd = "echo " + dq + "ibase=10;obase=2;" + dq + dec_num + " | bc " 
;---Execute UNIX command and return an integer 
  return(tostring(systemfunc(cmd))) 
end
