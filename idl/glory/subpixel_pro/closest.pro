function closest, val, array, value=value, lower=lower, upper=upper, $
                  decide=decide

;+
; NAME: closest
;     
; PURPOSE:
;     Find the index of the array element closest to a given value.
;
; EXPLANATION:
;     The function will return the index of the element in an array
;     closest to a given input value. You can also choose to only look
;     for the closest lower value or closest upper value.
;
; CALLING SEQUENCE:
;     result = closest(val, array[,value = , /lower, /upper, decide = ])
;
; INPUT PARAMETERS:
;     val     - The value for which the closest array element needs to
;               be found (int/long/float/double)
;     array   - The input array (int/long/float/double)
;
; OPTIONAL KEYWORDS:
;     lower   - Set this keyword to only look for the closest lower
;               value
;     upper   - Set this keyword to only look for the closest upper
;               value
;     decide  - Set this keyword to decide between multiple closest
;               values if desired. 1 = the lowest value, 2 = the
;               highest value, 4 = the first value. Any sum of these
;               will do both.
;
; OPTIONAL OUTPUT PARAMETERS:
;     value   - Set this keyword to a named variable in which the
;               value of the closest array element will be stored
;
; NOTES:
;     Keywords lower and upper are exclusive - set only one of
;     them. If there is no lower or upper value in the array, the function
;     will give an error-message and return to caller.
;
; EXAMPLE:
;     Find the array-element closest to 4.2 in an array of 3-9 and
;     store the array-element value in variable 'val':
;     IDL> .comp closest
;     % Compiled module: CLOSEST.
;     IDL> idx = closest(4.2, 3+indgen(7), value=val)
;     IDL> print, idx, val
;           1           
;           4           
;
;     Now find the upper closest value:
;     IDL> idx = closest(4.2, 3+indgen(7), value=val, /upper)
;     IDL> print, idx, val
;           2
;           5
;
;     Value '5' is the closest upper value.
;     Now find the closest value in to 4.5 in array [3,4,5,4]
;     IDL> idx = closest(4.5, [3,4,5,4], value=val)
;     IDL> print, idx, val
;           1           2           3
;           4           5           4
;         
;     All 3 elements are equal distance from 4.5. 
;     To make the function return only the highest closest value:
;     IDL> idx = closest(4.5, [3,4,5,4], value=val, decide=2)
;     IDL> print, idx, val
;           2
;           5
;     5 is the highest closest value (note the difference with setting
;     /upper: it will only output 5 because there were 2 closest
;     values - if /upper is set, the function will ONLY look at higher
;     values.
;
;     To retrieve the lowest value, and only the first occurrence in
;     the array set decide to 4+1=5:
;     IDL> idx = closest(4.5, [3,4,5,4], value=val, decide=5)
;     IDL> print, idx, val
;           1
;           4
;     
; REVISION HISTORY
;     Written by C. van Breukelen, Dec 2005
;     --+ Made calculation of arrays with -NaN values possible, March 2006
;     --+ Only take zeroth element of 'val', April 2007
;-
   on_error, 2

   if N_params() LT 2 then begin; Sufficient parameters?
     message,'Syntax - result = closest(val, array[,value = , /lower, /upper])'
      return, -1
   endif

   val = val[0]
   difference = array - val
   idx_fin = where(finite(difference) eq 1)
   difference = difference[idx_fin]

;  Find the lower closest element   
   if keyword_set(lower) then begin
       idx_neg = where(difference le 0)
       if idx_neg[0] ne -1 then begin
           min_diff = max(difference[idx_neg], index)
           index = idx_neg[index]
       endif else index = -1
   endif

;  Find the upper closest element   
  if keyword_set(upper) then begin
       idx_pos = where(difference ge 0)
       if idx_pos[0] ne -1 then begin
           min_diff = min(difference[idx_pos], index)
           index = idx_pos[index]
       endif else index = -1
   endif
   
;  Find the closest element   
  if not keyword_set(lower) AND not keyword_set(upper) then begin
       min_diff = min(abs(difference))
       index = where(abs(difference) eq min_diff)
  endif

; Make decisions if multiple closest values
  if n_elements(index) gt 1 AND keyword_set(decide) then begin
      if decide eq 1 then index=index[where(array[index] eq min(array[index]))]
      if decide eq 2 then index=index[where(array[index] eq max(array[index]))]
      if decide eq 4 then index=index[0]
      if decide eq 5 then begin
         index=index[where(array[index] eq min(array[index]))]
         index=index[0]
      endif
      if decide eq 6 then begin
         index=index[where(array[index] eq max(array[index]))] 
         index=index[0]
      endif
  endif

  if index[0] ne -1 then begin
      index = idx_fin[index]
      if arg_present(value) then value = array[index]
  endif else value = 0

  return, index

end
