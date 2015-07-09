function difkind,x

;+
; NAME:
;  difkind
; PURPOSE:
;  returns a vector of the DIFFERENT values contained in x
; CATEGORY:
;  misc
; CALLING SEQUENCE:
;      y = difkind(x)
; INPUTS:
;    x  - vector of numbers, some (many) of which are duplicates.
;         The duplicates are eliminated, and a vector of the
;         different values is returned.
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;  returns a vector of all the unique values in x
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; REQUIRED ROUTINES:
; MODIFICATION HISTORY:
;  idlv2 (lrl) 900618
;-

  xx = x(sort(x))
  sxx = xx - shift(xx,1)
  oo = where(sxx ne 0.0)
  if oo(0) ne -1 then begin
     xx = xx(oo)
  endif else begin
     xx = replicate(xx(0),1)
  endelse

   return,xx
end
