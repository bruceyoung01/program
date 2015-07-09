 Function strgen, Index, two=two

 strarr = strtrim(indgen(index)+1,2)

 If Keyword_set(two) then begin
  For I = 0, N_elements(strarr)-1 do $
    If strlen(strarr[I]) eq 1 then strarr[I] = '0'+strarr[I]
 endif

 return, strarr
 End
