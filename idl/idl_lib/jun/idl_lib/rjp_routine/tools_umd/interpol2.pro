; $Id: interpol.pro,v 1.1 1993/04/02 19:43:31 idl Exp $

FUNCTION INTERPOL2, V, X, U
;+
; NAME:
;	INTERPOL
;
; PURPOSE:
;	Linearly interpolate vectors with a regular or irregular grid.
;
; CATEGORY:
;	E1 - Interpolation
;
; CALLING SEQUENCE:
;	Result = INTERPOL(V, N) 	;For regular grids.
;
;	Result = INTERPOL(V, X, U)	;For irregular grids.
;
; INPUTS:
;	V:	The input vector can be any type except string.
;
;	For regular grids:
;	N:	The number of points in the result when both input and
;		output grids are regular.  The output grid absicissa values
;		equal FLOAT(i)/N_ELEMENTS(V), for i = 0, n-1.
;
;	Irregular grids:
;	X:	The absicissae values for V.  This vecotr must have same # of
;		elements as V.  The values MUST be monotonically ascending 
;		or descending.
;
;	U:	The absicissae values for the result.  The result will have 
;		the same number of elements as U.  U does not need to be 
;		monotonic.
;	
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	INTERPOL returns a floating-point vector of N points determined
;	by linearly interpolating the input vector.
;
;	If the input vector is double or complex, the result is double 
;	or complex.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Result(i) = V(x) + (x - FIX(x)) * (V(x+1) - V(x))
;
;	where 	x = i*(m-1)/(N-1) for regular grids.
;		m = # of elements in V, i=0 to N-1.
;
;	For irregular grids, x = U(i).
;		m = number of points of input vector.
;
; MODIFICATION HISTORY:
;	Written, DMS, October, 1982.
;	Modified, Rob at NCAR, February, 1991.  Made larger arrays possible 
;		and correct by using long indexes into the array instead of
;		integers.
;-
; 
	on_error,2              ;Return to caller if an error occurs
	m = N_elements(v)	;# of input pnts
	if N_params(0) eq 2 then begin	;Regular?
		r = findgen(x)*(m-1)/(x-1>1) ;Grid points in V
		rl = long(r)		;Cvt to integer
		dif = v(1:*)-v		;V(i+1)-v(i)
		return, V(rl) + (r-rl)*dif(rl) ;interpolate
		endif
;
	if n_elements(x) ne m then $ 
		stop,'INTERPOL - V and X must have same # of elements'
	n= n_elements(u)	;# of output points
	m2=m-2			;last subs in v and x
	r= fltarr(n)+V(0)	;floating, dbl or cmplx result

	if x(1) - x(0) ge 0 then s1 = 1 else s1=-1 ;Incr or Decr X
;
	ix = 0L			;current point
	for i=0L,n-1 do begin	;point loop
		d = s1 * (u(i)-x(ix))	;difference
		if d eq 0. then r(i)=v(ix) else begin  ;at point
		  if d gt 0 then while (s1*(u(i)-x(ix+1)) gt 0) and $
			(ix lt m2) do ix=ix+1 else $
			while (s1*(u(i)-x(ix)) lt 0) and (ix gt 0) do $
			  ix=ix-1
		  r(i) = v(ix) + (u(i)-x(ix))*(v(ix+1)-v(ix))/(x(ix+1)-x(ix))
		  endelse
	endfor
	
      if s1 eq 1 then begin
	aa = where(u lt x(0),count)
	if (count gt 0) then r(aa) = v(0) 
	
	;Find out where the output heights 
	aa = where(u gt x(m-1),count)
	if (count gt 0) then r(aa) = v(m-1) 
      
      endif else begin

	aa = where(u gt x(0),count)
	if (count gt 0) then r(aa) = v(0) 
	
	;Find out where the output heights 
	aa = where(u lt x(m-1),count)
	if (count gt 0) then r(aa) = v(m-1) 
      end

	return,r
end

