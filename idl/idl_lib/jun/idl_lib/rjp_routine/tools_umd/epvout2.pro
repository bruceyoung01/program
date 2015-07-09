function epvout2,absvor=absvor,t=t,press=press

aa = size(t) 
ikmm = aa(3) 

case n_elements(press) of 
0: begin & press = grid(ikmm=ikmm) & end 
else:
endcase 

;+
; NAME:
;   epvout
; PURPOSE:
;   Calculates potential vorticity from vorticity (relative or absolute) and 
;   temperature.

dv2 = reform(press(0,0,*)) 
zp = alog(1000./dv2)

x = absvor
pp = 2

;q = (g*absvor*theta/p)*[1/t*dt/dln(p0/p)+r/cp] (100 comes from mb)
  rcp = 2./7.

  q = (9.81/100.)*x/press*(t*(1000./press)^rcp)* $
      (deriv_array(t,pp,x=zp,bad=tbadval)/t+rcp)

  return,q
end
