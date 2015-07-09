function quantile, x, probs, type=type

if n_elements(x)     eq 0 then return, -1
if n_elements(probs) eq 0 then probs = [0.,0.25,0.5,0.75,1.]
if n_elements(type)  eq 0 then type = 7
if max(probs) gt 1. or min(probs) lt 0. then $
message, 'probs outside [0,1]'


n  = N_elements(X)
np = n_elements(probs)

if type eq 7 then begin
   index = (n - 1.) * probs
   lo = floor(index)
   hi = ceil(index)
   da = x[sort(x)]
   h  = index - lo
   qs = da[lo]
   qs = (1. - h) * qs + h * da[hi]
end else begin
   if type le 3 then begin
      if type eq 3 then nppm = n*probs-0.5 else nppm = n*probs
      j = floor(nppm)

      case type of
        1 : h = ifelse(nppm gt j, 1., 0.)
        2 : h = ifelse(nppm gt j, 1., 0.5)
        3 : h = ifelse(((nppm eq j) and (j mod 2) eq 0), 0., 1.)
      end

   end else begin
      case type of
        4 : a = 0.
        5 : a = 0.5
        6 : a = 0.
        7 : a = 1.
        8 : a = 1./3.
        9 : a = 3./8.
      end
      if type eq 4 then b = 1. else b = a

      test = machar(/double)
      fuzz = 4. * test.eps
      nppm = a + probs * (n + 1. - a - b)
      j    = floor(nppm+fuzz)
      h    = nppm - j
      h    = ifelse(abs(h) lt fuzz, 0., h)
   end

   da = x[sort(x)]
   da = [x[0],x[0],x,x[n-1],x[n-1]]
   qs = ifelse(h eq 0., da[j+1], $
               ifelse(h eq 1., da[j+2], (1.-h)*da[j+1] + h*da[j+2]))

end

;snp = strtrim(np,2)
;print, fix(probs*100L), format='('+snp+'(I12,"%"))'
;print, qs, format='('+snp+'G12.6)'

return, qs

end