 function fnorm, u, mu, sig

   ; n(u) = N/(sqrt(2pi)*sig) exp(-(u-mu)^2/2sig^2)


   f = 1/( sqrt(2.* !pi) * sig) * exp(-1. * (u - mu)^2 / (2. * sig^2))

 return, f

 end

;------------------------------------------------------------------------

 pro dist_normal, mean=mean, std=std

  if n_elements(mean) eq 0 then mean = 0.
  if n_elements(std)  eq 0 then std  = 2.

  inc = std*0.1

  vi  = mean - (std * 5.)
  vf  = mean + (std * 5.)

  v   = vi
  f   = 0.
  u   = 0.

  while (v lt vf) do begin
     f = [f,fnorm(v,mean,std)]     
     u = [u, v]
     v = v + inc   
  end  
  
  f = f[1:*]
  u = u[1:*]

  plot, u, f, color=1

 
 end
