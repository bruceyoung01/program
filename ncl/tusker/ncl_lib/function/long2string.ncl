;********************************************************************
; $ID int2string.ncl V01 11/20/2011 09:25 BRUCE EXP$
   function long2string(slong:numeric)
;====================================================================
;  FUNCTION int2string IS USED TO CONVERT LONG INTEGER TO STRING.
;
;  NOTES:
;====================================================================
;  (1 ): ORIGINALLY WRITTEN BY BRUCE. (11/20/2011)
;********************************************************************

begin

   sflt = slong*1.0
   sstr = flt2string(sflt)
   return(sstr)
end
