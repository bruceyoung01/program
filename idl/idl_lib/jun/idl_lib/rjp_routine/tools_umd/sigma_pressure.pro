;+
; NAME: sigma_pressure
;   
; PURPOSE: Input array on sigma levels is interpolated onto pressure
;          levels. 
; CATEGORY:
;   
; CALLING SEQUENCE:
;   
; INPUTS: fd       3-d array of input values on sigma surfaces. 
;         psf      2-d array of surface pressure. 
;         sigma    1-d array of input sigma levels. 
;         ptop     pressure at top of model. 
;         press    1-d array of output pressures. 
; OPTIONAL INPUT PARAMETERS:
;   
; KEYWORD PARAMETERS:
;   
; OUTPUTS:  fdout    3-d array of output values on pressure surfaces. 
;          
;   
; OPTIONAL OUTPUT PARAMETERS:
;   
; COMMON BLOCKS:
;   
; SIDE EFFECTS:
;   
; RESTRICTIONS:
;   
; PROCEDURE:
;   
; REQUIRED ROUTINES:
;   
; MODIFICATION HISTORY:   Coding began  20 October 1993
;    $Header$
;-
function sigma_pressure,fd,psf=psf,sigma=sigma,press=press,ptop=ptop,$
 htin=htin,htout=htout 

if n_elements(ptop) eq 0 then ptop = 10.  

a=size(fd) & ilmm=a(1) & ijmm= a(2) & ikmm=a(3) 

if n_elements(sigma) eq 0 then $
 sigma = [.993936,.971301,.929925,.874137,.807833,.734480,.657114,$
         .578390,.500500,.424750,.352000,.283750,.222750,.172150,$
         .132200,.10050,.073000,.049750,.029000,.009500] 
         
if n_elements(psf) eq 0 then begin
   psf = fltarr(ilmm,ijmm) 
   psf(*,*) = 1000. 
end  
if n_elements(press) eq 0 then press = [1000.,850.,700.,500.,300.,200.] 
kout = size(press) & kout = kout(1) 

htin = fltarr(ilmm,ijmm,ikmm)
for k=0,ikmm-1 do htin(0,0,k) = -8.*alog((ptop+sigma(k)*(psf(*,*)-ptop))*0.001)

htout = -8.*alog(press(*)*0.001) 

fdout=fltarr(ilmm,ijmm,kout) 
for j=0,ijmm-1 do begin
for i=0,ilmm-1 do begin
   fdin1 = reform(fd(i,j,*))
   htin1 = reform(htin(i,j,*))  
   fdout1 = interpol(fdin1,htin1,htout) 
 
                     ;amax = max(fdin1,min=amin) 
                     ;Ensure monotonicity by brute force.  
                     ;   aa = where(fdout1 gt amax,count) 
                     ;   if (count gt 0) then fdout1(aa) = amax  
   
   for k=0,kout-1 do fdout(i,j,k) = fdout1(k)
endfor
endfor 

;Set below zero values to value in lowest layer. 
;v = where(press gt 750,ncount) 
;for iz=ncount-1,0,-1 do begin 
;   dd = fdout(*,*,iz) & ee = fd(*,*,0)  
;   vv = where(dd lt 0.,count) 
;   if (count ne 0) then dd(vv) = ee(vv) 
;   fdout(0,0,iz) = dd 
;endfor 

return,fdout 
end  
   
