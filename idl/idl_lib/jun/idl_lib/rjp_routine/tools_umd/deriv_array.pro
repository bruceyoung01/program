function deriv_array,y,dims,x=x,bad=bad

;+
;NAME:
;	deriv_array
;PURPOSE:
;	Numerical Differentiation of an array using 3 point Lagrangian
;       interpolation contained in deriv.
;CATEGORY:
;	numanalysis
;CALLING SEQUENCE:
;	Dy=deriv_array(y,dims)
;       Dy=deriv_array(y,dims,x=x)
;INPUTS:
;	Y = Variable to be differentiated (ARRAY).
;       dims = dimension to be differentiated
;OPTIONAL INPUTS:
;KEYWORDS:
;	X = Variable to differentiate with respect to (VECTOR).  If omitted,
;	        assume unit spacing for Y, i.e. X(i) = i.
;       bad = bad data flag
;OUTPUTS:
;	Function result = derivative.
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;	ONLY FOR ARRAYS UP TO 3 DIMENSIONS.
;PROCEDURE:
;REQUIRED PROCEDURES:
;	DERIV, DERIV_B
;REVISION HISTORY:
;	Written, PAN 10/21/91
;       $Header: /devel/vendor/idl/local/userlib/deriv_array.pro,v 1.1 1992/10/01 11:00:08 lrlait Exp $
;-

ss=size(y)
ndims=ss(0)
yx=y-y

if n_elements(x) eq 0 then begin
  case ndims of
     1: begin
          yx=deriv_b(y,bad=bad)
        end
     2: begin
          case dims of
            0: for i=0,ss(2)-1 do yx(0,i)=deriv_b(y(*,i),bad=bad)
            1: for i=0,ss(1)-1 do yx(i,0)=deriv_b(y(i,*),bad=bad)
          endcase
        end
     3: begin
          case dims of
            0: for i=0,ss(3)-1 do for j=0,ss(2)-1 do yx(0,j,i)=deriv_b(y(*,j,i),bad=bad)
            1: for i=0,ss(3)-1 do for j=0,ss(1)-1 do yx(j,0,i)=deriv_b(y(j,*,i),bad=bad)
            2: for i=0,ss(2)-1 do for j=0,ss(1)-1 do yx(j,i,0)=deriv_b(y(j,i,*),bad=bad)
          endcase
        end
  ELSE: begin
  	  print,'  deriv_array: 1 TO 3-D ARRAYS ONLY'
          return,-1
        end
  endcase
endif else begin
  if n_elements(x) ne ss(dims+1) then begin
     print,'  deriv_array: x array and y dimensions differ'
  endif
  case ndims of
     1: begin
          yx=deriv_b(x,y,bad=bad)
        end
     2: begin
          case dims of
            0: for i=0,ss(2)-1 do yx(0,i)=deriv_b(x,y(*,i),bad=bad)
            1: for i=0,ss(1)-1 do yx(i,0)=deriv_b(x,y(i,*),bad=bad)
          endcase
        end
     3: begin
          case dims of
            0: for i=0,ss(3)-1 do for j=0,ss(2)-1 do yx(0,j,i)=deriv_b(x,y(*,j,i),bad=bad)
            1: for i=0,ss(3)-1 do for j=0,ss(1)-1 do yx(j,0,i)=deriv_b(x,y(j,*,i),bad=bad)
            2: for i=0,ss(2)-1 do for j=0,ss(1)-1 do yx(j,i,0)=deriv_b(x,y(j,i,*),bad=bad)
          endcase
        end
  ELSE: begin
  	  print,'  deriv_array: 1 TO 3-D ARRAYS ONLY'
          return,-1
        end
  endcase
endelse

return,yx
end
