 if n_elements(a) eq 0 then begin
    a = randomn(seed, 100)
    a = a + 2.
 end

 sig = 1.1
 data = exp(a*sig)
 print, stddev(data), mean(data)
 check, data
; print, stddev(exp(data)), mean(exp(data))
 qqnorm, 10.*alog((data+10.)/10.)


 end

