function rayleigh,wl,ps=ps,idatm=idatm
;+
; ROUTINE:  rayleigh
;
; PURPOSE:  compute rayleigh optical depth at a give wavelength
;
; USEAGE:   result=rayleigh(wl,ps=ps,idatm=idatm)
;
; INPUT:    
;   wl     wavelength in microns
; 
; KEYWORD INPUT:
;   ps       surface pressure in mb
;   idatm    index of standard atmosphere
;            1=tropical
;            2=midlat summer
;            3=midlat winter
;            4=sub arctic summer
;            5=sub arctic winter
;            6=us62
;
; OUTPUT:   rayleigh optical depth
;
; DISCUSSION:
;
; LIMITATIONS:
;
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;  
; EXAMPLE:  
;
;   wl=[.414,.499,.609,.665,.860,.938]
;   print,rayleigh(wl,idatm=4)
;
;;  0.311728     0.144443    0.0640821    0.0448406    0.0158600    0.0111786
;
; AUTHOR:   Paul Ricchiazzi                        13 Apr 98
;           Institute for Computational Earth System Science
;           University of California, Santa Barbara
;           paul@icess.ucsb.edu
;
; REVISIONS:
;
;-
;

amu=1.66e-27                             ; atmoic mass unit (kg)
mair=28.91*amu                           ; molecular mass (kg)
k=1.38e-23                               ; bolztman constant (J/K)
g=9.806                                  ; m/s/s

 
p0=1013.     ; mb
t0=273.15    ; kelvin

if n_elements(idatm) eq 0 then idatm=0
if n_elements(ps) eq 0 then ps=p0

; pressure in mb
; altitude in km
; lapse rate in kelvin/km
;
; tau=sig*path
;              /
; where path=  | (p/t)(t0/p0) dz   (km)
;              /

if idatm eq 0 then begin
  h=.001*k*t0/(mair*g)          ; scale height in km
  ns=(ps/p0)                    ; surface number density in loshmidts
  path=h*ns
endif else begin
  atmosz,z,p,t,idatm=idatm
  zz=findrng(0,100,500)
  pp=(ps/max(p))*exp(interp(alog(p),z,zz))
  tt=interp(t,z,zz)
  path=integral(zz,(pp/p0)*(t0/tt))
endelse

return,path/(938.07*wl^4-10.8426*wl^2)

end


