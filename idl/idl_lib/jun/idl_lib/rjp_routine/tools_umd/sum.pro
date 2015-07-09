function  sum,array,dimension

;+
; NAME:
;   sum
; PURPOSE:
;   Total up an array over one of its dimensions.
; CATEGORY:
;   array math
; CALLING SEQUENCE:
;   result = sum(array, dimension)
; INPUTS:
;   array     = Input array.  May be any type except string or structure.
;   dimension = Dimension to do total over.
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;   The result is an array with all the dimensions of the input array except 
;   for the dimension specified, each element of which is the total of the 
;   corresponding vector in the input array. 
;
;   For example, if A is an array with dimensions of (3,4,5), then the
;   command B = SUM(A,1) is equivalent to
;
;			B = FLTARR(3,5)
;			FOR J = 0,4 DO BEGIN
;				FOR I = 0,2 DO BEGIN
;					B(I,J) = TOTAL( A(I,*,J) )
;				ENDFOR
;			ENDFOR
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;   Dimension specified must be valid for the array passed; otherwise the
;   input array is returned as the output array. Type cannot be string or
;   structure.
; PROCEDURE:
; REQUIRED ROUTINES:
; MODIFICATION HISTORY: 
;	William Thompson	Applied Research Corporation
;	July, 1986		8201 Corporate Drive
;				Landover, MD  20785
;      mod for idl v2 lr lait 910206
;      lr lait 910507 got it working right!
;   nash 931027 complete rewrite to speed up code (30% faster), fixed error in
;               old code that used fix instead of long in the last else block.
;   $Header$
;-

; *****must have two dimensions only
  if  (n_params(0) lt 2)  then  begin
    message,/cont, $
      'Function SUM must be called with two parameters: ARRAY, DIMENSION'
    return,array
  endif

  s = size(array)
  ndim = s(0)

; *****check number of dimensions
  if  (ndim eq 0)  then  begin
    message,/cont, $
      'Variable (ARRAY) must be an array.'
    return,array
  endif

; *****check for range of dimension
  if  ((dimension ge ndim) or (dimension lt 0))  then  begin
    message,/cont, $
      'Dimension out of range in variable ARRAY.'
    return,array
  endif

; *****check for type of variable
  stype = s(ndim+1)
  if  (stype gt 6)  then  begin
    message,/cont, $
      'Variable (ARRAY) cannot be of type string or structure'
    return,array
  endif

; *****trivial case of 1 dimension: just return total
  if  (ndim eq 1)  then  return,total(array)

; *****set up output array
  f = make_array(type=(stype > 4), $
    dimension=s(where(make_array(ndim,/int,/index) ne dimension)+1))

; *****calculate product of dimension lower than, equal to, and higher
; *****than DIMENSION 
  numlo = 1l
  for  i = 1,dimension  do  numlo = numlo*s(i)
  numeq = s(dimension+1)
  numhi = 1l
  for  i = dimension+2,ndim  do  numhi = numhi*s(i)
  s = 0

; *****total of points in other indices is smaller than in the target index
  if  ((numlo*numhi) lt numeq)  then  begin
    numloeq = numlo*numeq
    xeq = numlo*make_array(numeq,/long,/index)
    i = 0l
    for  hi = 0,numhi-1  do  begin
      x = xeq+hi*numloeq
      for  lo = 0,numlo-1  do  begin
        f(i) = total(array(lo+x))
        i = i+1l
      endfor
    endfor

; *****total of points in other indices is largerl than in the target index
  endif  else  begin
    xneq = make_array(numlo*numhi,/long,/index)
    xneq = xneq+(numlo*(numeq-1))*(xneq/numlo)
    for  l = 0,numeq-1  do  f = f+array(numlo*l+xneq)
  endelse

  return,f
end
