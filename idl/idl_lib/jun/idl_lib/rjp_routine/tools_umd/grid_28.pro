;+
;PROGRAM:
;        grid.pro
;PURPOSE:
;        Define transport grid for 28 layer sigma/p CTM. 
;COMMON BLOCKS:  
      
;DATE:
;        4 October 1994 (mcor and mass made 2 and 3-d) 
; 
;-
function grid_28,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,sigma=sigma,sgint=sgint,$
ht=ht,prslay=prslay,mass=mass,mcor=mcor,latcen=latcen,loncen=loncen,dp=dp,$
latedge=latedge,pint=pint,he=he,ptop=ptop,psf=psf,dy=dy 
 
if n_elements(ilmm) eq 0 then ilmm = 144 
if n_elements(ijmm) eq 0 then ijmm =  91 
if n_elements(psf) eq 0 then begin psf = fltarr(ilmm,ijmm) & psf(*,*) = 1000. & end 
 
kstrat = 17 
ktrop = 11
ikmm = ktrop+kstrat
prslay0 = [1000.,850.,700.,600.,500.,400.,300.,250.,200., $ 
             175.,150.,130.,107.108,93.3640,82.9442,$
             71.4818,64.9339,50.0355,43.0581,23.2245,19.9857,$
             10.7799,9.27653,5.00358,4.30579,2.32246,1.99856,$
             1.07800,0.430576]
ptop = prslay0(ikmm) 
pint = prslay0(ktrop) 
	     
press0 = fltarr(ikmm) & sigma = fltarr(ikmm) & sgint = fltarr(ikmm+1) 	    
       
for ik=0,ikmm-1 do begin	  
   press0(ik) = 1000.*(prslay0(ik+1)*prslay0(ik)*1.e-6)^0.5 
endfor 
for ik=0,ktrop-1 do begin	  
   sigma(ik) = (press0(ik)-pint)/(prslay0(0)-pint)
endfor 
for ik=0,ktrop do begin	  
   sgint(ik) = (prslay0(ik)-pint)/(prslay0(0)-pint) 
endfor 

for ik=ktrop,ikmm-1 do begin
   sigma(ik) = (press0(ik)-pint)/(pint-ptop)
   sgint(ik) = (prslay0(ik)-pint)/(pint-ptop)
endfor  

ik=ikmm   
sgint(ik) = (prslay0(ik)-pint)/(pint-ptop)	       

press = fltarr(ilmm,ijmm,ikmm) & prslay = fltarr(ilmm,ijmm,ikmm+1) 
for ik=0,ktrop-1 do begin
   press(0,0,ik) = sigma(ik)*(psf-pint)+pint
   prslay(0,0,ik) = sgint(ik)*(psf-pint)+pint 
endfor 
for ik=ktrop,ikmm-1 do begin
   press(*,*,ik) = press0(ik)
   prslay(*,*,ik) = prslay0(ik)
endfor
ik = ikmm
prslay(*,*,ik) = prslay0(ik) 

ht = -8. * alog(press*0.001)    
he = -8. * alog(prslay*.001) 

dp = prslay - shift(prslay,-1) 
dp = dp(*,*,0:ikmm-1) 

latcen=-90.+findgen(ijmm)*180./(ijmm-1) & loncen=findgen(ilmm)*360./ilmm 
dy = 180. / (ijmm-1) 
latedge = (-90.+dy*0.5)+findgen(ijmm-1)*180. / (ijmm-1)  

mcor =  fltarr(ilmm,ijmm)      
a = 6.371220e6     
dtr = !pi /180.
fac = 1.e-15  

;note scaling by fac 
for i=0,ilmm-1 do mcor(i,0)=-2.*!pi*a*a*fac*$
(cos(latedge(0)*dtr+!pi*0.5)-1.) / ilmm 

for i=0,ilmm-1 do mcor(i,1:ijmm-2) =        -2.*!pi*a*a*fac*$
(cos(latedge(1:ijmm-2)*dtr+!pi*0.5)-cos(latedge(0:ijmm-3)*dtr+!pi*0.5)) / ilmm 

for i=0,ilmm-1 do mcor(i,ijmm-1)=-2.*!pi*a*a*fac*(-1.-cos(latedge(ijmm-2)*dtr+!pi*0.5))/ilmm 

g = 9.8 & mass=fltarr(ilmm,ijmm,ikmm) 
for k=0,ikmm-1 do begin
for j=0,ijmm-1 do begin
   mass(0,j,k) = 100.*mcor(*,j)*dp(*,j,k)/g
endfor
endfor 

return,press  
end 
