;+
;PROGRAM:
;        gridinv.pro
;PURPOSE:
;        Define transport grid for GEOSI-DAS 20 tropospheric model
;COMMON BLOCKS:  
      
;DATE:
;        4 October 1994 (mcor and mass made 2 and 3-d) 
; 
;-
function gridinv,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,sigma=sigma,sgint=sgint,$
ht=ht,prslay=prslay,mass=mass,mcor=mcor,latcen=latcen,loncen=loncen,$
latedge=latedge,pint=pint,he=he,ptop=ptop,press=press,dy=dy,psf=psf 
 
if n_elements(ilmm) eq 0 then ilmm = 144 
if n_elements(ijmm) eq 0 then ijmm =  91 
if n_elements(ikmm) eq 0 then ikmm =  20 
if n_elements(press) eq 0 then return, 0

prslay = fltarr(ilmm,ijmm,ikmm+1)  

case ikmm of 
20: begin 
       pint = 10. 
       ptop = pint 
       sigma = [.993936,.971301,.929925,.874137,.807833,.734480,.657114,$
        .578390,.500500,.424750,.352000,.283750,.222750,.172150,$
        .132200,.10050,.073000,.049750,.029000,.009500] 

       sgint=[1.000000,0.987871,0.954730,0.905120,0.843153,0.772512,0.696448,$
        0.617779,0.539000,0.462000,0.387500,0.316500,0.251000,0.194500,$
        0.149800,0.114600,0.085500,0.060500,0.039000,0.019000,0.00000] 

       ;Press and prslay are calculated ASSUMING psf = 1000! 
       ;Formula is sigma=(press-pint) /(psf-pint)
       ;           sgint=(prslay-pint)/(psf-pint)
       sigma = reverse(sigma)
       sgint = reverse(sgint)
       
       psf = (press(*,*,ikmm-1)-pint)/sigma(ikmm-1) + pint

;       for ik=0,ikmm-1 do press(0,0,ik) = sigma(ik)*(psf(*,*)-pint) + pint
       for ik=0,ikmm do  prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint) + pint 

   end
70: begin
       pint = 0.01 
       ptop = pint 
       sgint=[0.00000    ,6.01635e-06,1.37082e-05,2.29524e-05,3.40184e-05,$
              4.80209e-05,6.59413e-05,8.86501e-05,0.000117785,0.000155016,$
              0.000202404,0.000262483,0.000338348,0.000433766,0.000553297,$
              0.000702439,0.000887780,0.00111801 ,0.00140307 ,0.00175490 ,$
              0.00218774 ,0.00271855 ,0.00336739 ,0.00415795 ,0.00511809 ,$
              0.00628039 ,0.00768288 ,0.00936969 ,0.0113918  ,0.0138081  ,$
              0.0166858  ,0.0201020  ,0.0241439  ,0.0289104  ,0.0345100  ,$
              0.0410763  ,0.0487200  ,0.0575737  ,0.0678111  ,0.0796365  ,$
              0.0932521  ,0.108878   ,0.126755   ,0.147130   ,0.170300   ,$
              0.196550   ,0.226250   ,0.259550   ,0.296280   ,0.336070   ,$
              0.378450   ,0.423030   ,0.469400   ,0.517035   ,0.565419   ,$
              0.613850   ,0.661599   ,0.707896   ,0.751944   ,0.792970   ,$
              0.830300   ,0.863570   ,0.892744   ,0.917900   ,0.939230   ,$
              0.957000   ,0.971500   ,0.982900   ,0.991400   ,0.997095   ,$
              1.00000]
;        sgint = reverse(sgint) 
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
     end
46: begin
       pint = 1.0 
       ptop = pint  
       sgint=[.000,9.4e-5,2.39e-4,4.49e-4,7.37e-4,1.121e-3,$
        1.616e-3,2.24e-3,3.011e-3,3.948e-3,5.072e-3,6.402e-3,7.96e-3,$
        9.7670e-3,1.1848e-2,1.4223e-2,1.6919e-2,$
        1.9958e-2,2.3367e-2,2.7422e-2,3.2162e-2,3.7692e-2,4.4128e-2,$
        5.1896e-2,6.1252e-2,7.2493e-2,8.5972e-2,0.102098,0.121347,$
        0.144267,0.171495,0.202593,0.237954,0.2780,0.325,0.38,0.44,$
        0.503,0.57,0.639,0.710,0.780,0.845,0.90512,0.95473,0.98787,1.]     
        sgint = reverse(sgint) 
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
     end
26: begin
       pint = 1.0 
       ptop = pint  
       sgint=[.000,      1.9958e-2, 3.7692e-2, 5.1896e-2, 6.1252e-2,$
              7.2493e-2, 8.5972e-2, 0.102098,  0.121347,  0.144267,$
	      0.171495,  0.202593,  0.237954,  0.2780,    0.325,$
	      0.38,      0.44,      0.503,     0.57,      0.639,$
	      0.710,     0.780,     0.845,     0.90512,   0.95473,$
	      0.98787,   1.]     
        sgint = reverse(sgint) 
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
     end
else:
endcase

ht = -8. * alog(press*0.001)    
he = -8. * alog(prslay*.001) 

dp = shift(prslay,0,0,-1) - prslay
dp = dp(*,*,0:ikmm-1) 

latcen=-90.+findgen(ijmm)*180./(ijmm-1) & loncen= -180.+findgen(ilmm)*360./ilmm 
dy = 180. / (ijmm-1) 
latedge = (-90.+dy*0.5)+findgen(ijmm-1)*180. / (ijmm-1)  

mcor =  fltarr(ilmm,ijmm)      
a = 6.371220e6     
dtr = !pi /180.
fac = 1.  

;note scaling by fac 
for i=0,ilmm-1 do mcor(i,0)=-2.*!pi*a*a*fac*$
(cos(latedge(0)*dtr+!pi*0.5)-1.) / ilmm 

for i=0,ilmm-1 do mcor(i,1:ijmm-2) =        -2.*!pi*a*a*fac*$
(cos(latedge(1:ijmm-2)*dtr+!pi*0.5)-cos(latedge(0:ijmm-3)*dtr+!pi*0.5)) / ilmm 

for i=0,ilmm-1 do mcor(i,ijmm-1)=-2.*!pi*a*a*fac*(-1.-cos(latedge(ijmm-2)*dtr+!pi*0.5))/ilmm 

g = 9.80665 & mass=fltarr(ilmm,ijmm,ikmm) 

for k=0,ikmm-1 do begin
for j=0,ijmm-1 do begin
   mass(0,j,k) = 100.*mcor(*,j)*dp(*,j,k)/g
endfor
endfor 

return, dp
end 
