;+         
; PURPOSE: 
;   Interpolate constituent field onto specified theta level(s).  
;   
; CALLING SEQUENCE:  

;   
; KEYWORD PARAMETERS:  
;  theta = Theta level(s) to interpolate to               def: theta=800. 
;  ilev1 - IDL index of lowest model level to be used     def: ilev1 = 0 
;  ilev2 - IDL index of highest model level to be used    def: ilev2 = ikmm-1 
;
; 
; MODIFICATION HISTORY:  
;   Latest version 8 September 1994 
;-
;
;
;
function sigma_theta,fd1=fd1,theta2=theta2,psf=psf,kel=kel,theta1=theta1

aa = size(fd1) & ilmm = aa(1) & ijmm = aa(2) & ikmm1 = aa(3) 

if n_elements(psf) eq 0 then begin
   psf = fltarr(ilmm,ijmm) 
   psf(*,*) = 1000. 
end  
if n_elements(kel) eq 0 then begin
   kel = fltarr(ilmm,ijmm,ikmm1) 
   kel(*,*,*) = 273. 
end
press = grid(psf=psf,ikmm=ikmm1,sigma=sigma,pint=pint) 
theta1 = gettheta(kel=kel,psf=psf,press=press)  
 
if n_elements(theta2) eq 0 then theta2 = [800.]  
ikmm2 = size(theta2) & ikmm2 = ikmm2(1) 

fd2=fltarr(ilmm,ijmm,ikmm2) 
for j=0,ijmm-1 do begin
for i=0,ilmm-1 do begin
   fdin =  reform(fd1(i,j,*))
   thetain =  reform(theta1(i,j,*))  
   thetaout=  theta2
   fdout = interpol(fdin,thetain,thetaout)   
   for k=0,ikmm2-1 do fd2(i,j,k) = fdout(k) 
   endfor
endfor 
return,fd2  
end

