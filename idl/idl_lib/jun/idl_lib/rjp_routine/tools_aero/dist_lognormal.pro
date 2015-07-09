;------------------------------------------------------------------------

 function flognorm, u, mu, sig

   ; n(u) = N/(sqrt(2pi)*mu*ln(sig)) exp(-(u-mu)^2/2sig^2)


   f = 1/( sqrt(2.* !pi) * alog(sig)) * exp(-1. * (alog(u) - alog(mu))^2 / (2. * alog(sig)^2))

 return, f

 end

;------------------------------------------------------------------------

 pro dist_lognormal, mean=mean, std=std

  if n_elements(mean) eq 0 then mean = 1.
  if n_elements(std)  eq 0 then std  = 2.


  vi  = 0.001
  vf  = 10.

  inc = 0.5E-2

  v   = vi
  f   = 0.
  u   = 0.

  while (v lt vf) do begin
     f = [f,flognorm(v,mean,std)]     
     u = [u, v]
     v = v + inc   
  end  
  
  f = f[1:*]
  u = u[1:*]

  plot, u, f, color=1, /xlog

 
 end
