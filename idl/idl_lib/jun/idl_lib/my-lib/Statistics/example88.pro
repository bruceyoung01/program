
 ; simulate the data with AR2 model
  phi1 = 0.9
  phi2 = -0.6
  mu = 0
  stde = 1.
  
 ; number of time steps
 t = 0
 nt = 100     ; number of time steps
 x = fltarr(nt)
 xf = fltarr(nt)  ; forecast value
 t = indgen(nt)
 
 ; generate nt white noise
 ; with mean of 0 and standard devation of 1.
 seed = 1.526
 e = randomn (seed,  nt, /normal)   

 for i = 2, nt-1 do begin
  x[i] = phi1 * x[i-1] + phi2 * x[i-2] + e[i]
 
  ; make a first here after 90 steps
  ; , make white noise = 0
  if (i gt 85 ) then begin
   xf[i] = phi1 * xf[i-1] + phi2 * xf[i-2]
  endif else begin
   xf[i] = x[i] 
  endelse 
 endfor

 Device, Decomposed=0
 set_plot, 'x'
 !p.background = 255
 plot, t[80:nt-1], x[80:nt-1], xtitle = 't', $
       ytitle = 'x', color=0
 oplot, t[80:nt-1], xf[80:nt-1], linestyle=3, color=4
; oplot, t[2:nt-1], xf[2:nt-1]-x[2:nt-1], color=0, linestyle=4
 img = tvrd()
 write_png, 'fig88_forecast.png', img
 end 
  
