;+
; NAME: sigma_sigma
;   
; PURPOSE: Input array on sigma levels is interpolated onto sigma
;          levels. 
; CATEGORY:
;   
; CALLING SEQUENCE:
;   
; INPUTS: fd1       3-d array on sigma1 
;         psf       surface pressure 
;         sigma1    input sigma levels. 
;         sigma2    output sigma levels 
;         ptop1     pressure at top of model (input) 
;         ptop2     pressure at top of model (output) 
;         
; OPTIONAL INPUT PARAMETERS:
;   
; KEYWORD PARAMETERS:
;   
; OUTPUTS:  fd2    3-d array on sigma2  
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
function sigma_sigma,fd1,psf=psf,sigma1=sigma1,ptop1=ptop1,sigma2=sigma2,ptop2=ptop2,$
 extrap=extrap,pint1=pint1,pint2=pint2 

if n_elements(extrap) eq 0 then extrap = 0 
if n_elements(ptop1) eq 0 then ptop1 = 10.  
if n_elements(ptop2) eq 0 then ptop2 = .01
if n_elements(pint1) eq 0 then pint1 = ptop1
if n_elements(pint2) eq 0 then pint2 = ptop2

;Determine dimensions of input field. 
a=size(fd1) & ilmm1=a(1) & ijmm1= a(2) & ikmm1=a(3) 

;Use GEOS-1 DAS sigma levels for default. 
if n_elements(sigma1) eq 0 then $
 sigma1 = [.993936,.971301,.929925,.874137,.807833,.734480,.657114,$
         .578390,.500500,.424750,.352000,.283750,.222750,.172150,$
         .132200,.10050,.073000,.049750,.029000,.009500] 
aa = where(sigma1 ge 0.,ktrop1) & kstrat1 = ikmm1 - ktrop1

case n_elements(sigma2) of 
0: begin 
      ikmm2 = 70 
      press2 = grid(ikmm=ikmm2,sigma=sigma2) & press2 = reform(press2(0,0,*)) 
      kstrat2 = 0 & ktrop2 = ikmm2 
   end 
else: begin
         nnn = size(sigma2) 
	 ikmm2 = nnn(1) 
	 aa = where(sigma2 ge 0.,ktrop2) & kstrat2 = ikmm2 - ktrop2 
	 press2 = fltarr(ikmm2) 
         for ik=0,ktrop2-1 do press2(ik) =     pint2 + sigma2(ik)*(1000-pint2)
         for ik=ktrop2,ikmm2-1 do press2(ik) = pint2 + sigma2(ik)*(pint2-ptop2) 
      end 
endcase

if n_elements(psf) eq 0 then begin
   psf = fltarr(ilmm1,ijmm1) 
   psf(*,*) = 1000. 
end  

ht1 = fltarr(ilmm1,ijmm1,ikmm1)
for k=0,ktrop1-1 do     ht1(0,0,k) = -7.*alog((pint1+sigma1(k)*(psf(*,*)-pint1))*0.001)
for k=ktrop1,ikmm1-1 do ht1(*,*,k) = -7.*alog((pint1+sigma1(k)*(pint1   -ptop1))*0.001) 

ht2 = fltarr(ilmm1,ijmm1,ikmm2)
for k=0,ktrop2-1 do     ht2(0,0,k) = -7.*alog((pint2+sigma2(k)*(psf(*,*)-pint2))*0.001)
for k=ktrop2,ikmm2-1 do ht2(*,*,k) = -7.*alog((pint2+sigma2(k)*(pint2   -ptop2))*0.001) 

fd2=fltarr(ilmm1,ijmm1,ikmm2) 
for j=0,ijmm1-1 do begin
for i=0,ilmm1-1 do begin
   fdin =  reform(fd1(i,j,*))
   htin =  reform(ht1(i,j,*))  
   htout=  reform(ht2(i,j,*)) 
   fdout = interpol(fdin,htin,htout)   
   for k=0,ikmm2-1 do fd2(i,j,k) = fdout(k) 
   endfor
endfor 

;Set below zero values to value in lowest layer. 
v = where(press2 gt 750,ncount) 
for iz=ncount-1,0,-1 do begin 
   dd = fd2(*,*,iz) & ee = fd2(*,*,0)  
   vv = where(dd lt 0.,count) 
   if (count ne 0) then dd(vv) = ee(vv) 
   fd2(0,0,iz) = dd 
endfor 

;Set below zero values to value in lowest layer. 
ikk = where(press2 lt ptop1,ncount) & ikk = ikk(0) 

if ((extrap eq 0) and (ncount gt 0)) then for ik=ikk,ikmm2-1 do fd2(0,0,ik) = fd1(*,*,ikmm1-1) 
 

return,fd2 
end  
   
