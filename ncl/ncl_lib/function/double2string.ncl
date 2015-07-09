;********************************************************************
; $ID double2string.ncl V01 04/13/2014 11:49 BRUCE EXP$
   function double2string(sdouble:numeric)
;====================================================================
;  FUNCTION double2string IS USED TO CONVERT DOUBLE FLOAT TO STRING.
;
;  VARIABLES:
;  ==================================================================
;  (1 ) sdouble (DOUBLE FLOAT) : INPUT DOUBLE FLOAT.
;
;  NOTES:
;====================================================================
;  (1 ): ORIGINALLY WRITTEN BY BRUCE. (04/13/2014)
;********************************************************************

begin

   sstr = flt2string(doubletofloat(sdouble))
   return(sstr)
end
