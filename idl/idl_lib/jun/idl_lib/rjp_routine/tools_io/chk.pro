pro  chk,test_variable,badval=badval

;+
; NAME:
;  check
; PURPOSE:
;  Does a help of the variable, and if it is an array prints out the max 
;    and min.
; CATEGORY:
;  programming
; CALLING SEQUENCE:
;  check, test_variable
; INPUTS:
;  test_variable = The variable to be inspected.
; OUTPUTS:
; KEYWORD PARAMETERS:
;  badval
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
;-

; *****Get help for TEST_VARIABLE
  help,test_variable  
  s = size(test_variable)
  if  (s(s(0)+1) eq 8)  then  help,/str,test_variable

; *****Print out min and max if TEST_VARIABLE is an array
  if  ((s(0) gt 0) and (s(s(0)+1) lt 8))  then  begin
    if  (n_elements(badval) eq 0)  then  tmin = min(test_variable,max=tmax, /nan) $
    else  begin
      l = where(test_variable ne badval)
      if  (l(0) eq -1)  then  return
      tmin = min(test_variable(l),max=tmax, /nan)
    endelse
    print,'Min =',tmin,' Max = ',tmax
  endif

; *****That's all folks
  return
END
