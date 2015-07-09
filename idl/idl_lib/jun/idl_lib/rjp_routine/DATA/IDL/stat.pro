
function stat, data

; take vector of data to compute mean and std

 P = where(finite(data) eq 1)
 if P[0] eq -1 then return, {mean:'NaN', std:'NaN'}

 N = n_elements(P)

 CASE N of
   1  : return, {mean:Data[P[0]], std:'NaN'}
 else : return, {mean:mean(data, /nan), std:stddev(data,/NaN)}
 End

End
