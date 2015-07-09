; $ID: dectobin_nd.ncl V01 05/05/2012 20:45 BRUCE EXP$
;
;******************************************************************************
;  FUNCTION dectoint_nd CONVERTS DECIMAL TO BINARY.
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

function dectobin_nd(dec_num:integer) 

local dq, cmd 

begin 
;  Double quote character 
   dq = str_get_dq() 

;  CONVERT N-D TO 1-D
   oned_dec_num  = ndtooned(dec_num)
   noned_dec_num = dimsizes(oned_dec_num)
   c             = new((/noned_dec_num/), string)
;  UNIX command that converts decimal to binary 
   do i = 0, noned_dec_num-1
    cmd = "echo " + dq + "ibase=10;obase=2;" + dq + oned_dec_num(i) + " | bc " 
;  Execute UNIX command and return an integer
   c(i) = tostring(sprinti("%0.16i", tolong(systemfunc(cmd))))
   end do
   return(c)
end
