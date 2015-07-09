; $ID: dectobin_1d.ncl V01 05/05/2012 20:45 BRUCE EXP$
;
;******************************************************************************
;  FUNCTION dectoint_1d CONVERTS DECIMAL TO BINARY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dec_num   (integer) : DECIMAL NUMBER TO BE CONVERTED TO BINARY.  [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY Mary. (NOT CLEAR)
;  (2 ) MODIFIED BY BRUCE. (05/05/2012)
;  (3 ) DEFINE THE # OF DIGITS BEGORE USE. (04/22/2013)
;******************************************************************************

function dectobin_1d(dec_num:integer) 
local dq, cmd 
begin 
;---Double quote character 
  dq = str_get_dq() 
;---UNIX command that converts decimal to binary 
  cmd = "echo " + dq + "ibase=10;obase=2;" + dq + dec_num + " | bc " 
;---Execute UNIX command and return an integer 
  return(tostring(sprinti("%0.16i", tolong(systemfunc(cmd)))))
end
