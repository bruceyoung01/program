;********************************************************************
; $ID int2string.ncl V01 11/20/2011 09:25 BRUCE EXP$
   function int2string(sint:numeric)
;====================================================================
;  FUNCTION int2string CONVERTS SHORT INTEGER TO STRING.
;
;  NOTES:
;====================================================================
;  (1 ): ORIGINALLY WRITTEN BY BRUCE. (11/20/2011)
;********************************************************************

begin

   sflt = int2flt(sint)
   sstr = flt2string(sflt)
   return(sstr)
end
