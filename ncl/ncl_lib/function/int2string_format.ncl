;********************************************************************
; $ID int2string_format.ncl V01 09/30/2013 15:55 BRUCE EXP$
;====================================================================
;  FUNCTION int2string IS USED TO CONVERT SHORT INTEGER TO STRING.
;
;  NOTES:
;====================================================================
;  (1 ): ORIGINALLY WRITTEN BY BRUCE. (11/20/2011)
;********************************************************************

undef("int2string_format")
function int2string_format \
        (sint       :numeric,       logic      :logical, \; INPUT
         total      :integer,       point      :integer)  ; INPUT

begin
   sign    = "+"
   ftotal  = int2flt(total)
   stotal  = flt2string(ftotal)
   fpoint  = int2flt(point)
   spoint  = flt2string(fpoint)

;  ADD SIGN ("+" OR "-") BEFORE THE INTEGER
   if (logic) then
      format  = "%" + sign + stotal + "." + spoint + "i"
   else
;  WITHOUT SIGN ("+" OR "-") BEFORE THE INTEGER
      format  = "%" + stotal + "." + spoint + "i"
   end if
   sstr = sprinti(format, sint)
   return(sstr)

end
