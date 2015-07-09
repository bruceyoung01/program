function deriv_b,x,y,bad=bad

;+
;NAME:
;       deriv_b
;PURPOSE:
;       Numerical Differentiation of a vector which does not differentiate
;       across bad value points.
;CATEGORY:
;       numanalysis
;CALLING SEQUENCE:
;       Dy=deriv_b(x,y)
;       Dy=deriv_b(x,y,bad=bad)
;INPUTS:
;       X = Variable to differentiate with respect to (VECTOR).  If omitted,
;               assume unit spacing for Y, i.e. X(i) = i.
;       Y = Variable to be differentiated (ARRAY).
;OPTIONAL INPUTS:
;KEYWORDS:
;       bad = bad data flag
;OUTPUTS:
;       Function result = derivative.
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;       ONLY FOR VECTORS.
;PROCEDURE:
;REQUIRED PROCEDURES:
;       DERIV
;REVISION HISTORY:
;       Written, PAN 10/21/91
;       $Header: /devel/vendor/idl/local/userlib/deriv_b.pro,v 1.1 1992/10/01 11:00:09 lrlait Exp $
;-

if n_elements(bad) eq 0 then begin
   case n_params(0) of
      1: dy=deriv(x)
      2: dy=deriv(x,y)
   endcase
endif else begin
   case n_params(0) of
      1: begin
           oo = where(x ne bad)
           if oo(0) ne -1 then begin
             dy=x-x+bad			; ** dy = the derivative
             xx=findgen(n_elements(x))	; ** xx = an ascending order vector
             dy(oo)=deriv(xx(oo),x(oo))
           endif else begin
             print,' '
             print,'All vector elements are bad: returning -1'
             print,' '
             return,-1
           endelse
         end
      2: begin
           oo=where(y ne bad)		; ** oo = the bad points
           if oo(0) ne -1 then begin
             dy=y-y+bad			; ** dy = the derivative
             dy(oo)=deriv( x(oo),y(oo))
           endif else begin
             print,' '
             print,'All vector elements are bad: returning -1'
             print,' '
             return,-1
           endelse
         end
   endcase
endelse

return,dy
end
