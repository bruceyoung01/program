function sgn,x

;+
; NAME:
;   sgn
; PURPOSE:
;   returns sign of argument
; CATEGORY:
;   math
; CALLING SEQUENCE:
;   x = sgn(y)
; INPUTS:
;   y = variable whose sign is to be determined
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;   returns -1 if x<0, +1 if x>=0
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; REQUIRED ROUTINES:
; MODIFICATION HISTORY:
;   idlv2 (lrl) 900620
;-

   xx = x*0
   sx = size(x)
   if sx(0) eq 0 then oo = (x ne 0) -1 else $
   oo = where(x ne 0)
   if oo(0) ne -1 then xx(oo) = x(oo)/abs(x(oo))
   if sx(0) eq 0 then oo = (x eq 0) -1 else $
   oo = where(x eq 0)
   if oo(0) ne -1 then xx(oo) = 1

   return,xx

end
