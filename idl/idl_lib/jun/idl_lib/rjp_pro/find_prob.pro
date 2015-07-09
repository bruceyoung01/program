function find_prob, val

 if n_elements(val) eq 0 then stop

 tol = 1.e-5
  x  = 0.

 high = 4.  ; upper boundary
 low  = 0.  ; lower boundary

; while loop
 back:

  prb = qromb('f_gauss', -x, x)
  err = prb - val
  if abs(err) lt tol then goto, jump
  if x lt 0. then message, 'x should not be less than zero'

  if err gt 0. then begin
     high = x  ; reset upper boundary
     x    = (x + low)*0.5 
  end else begin
     low  = x  ; reset low boundary
     x    = (x + high) * 0.5
  end

  goto, back

 jump: return, x

end

