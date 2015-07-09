;+
;PROGRAM:
;        fd4d_fdmovie.pro
;PURPOSE:
;        Extract lon, lat, 2 lev, time array from lon,lat,ht,time array
;        for movie making. 
;      
;DATE:
;        22 October 1996  
;USAGE NOTES:
;        Output after extracting every-other point
;        Output after shifting in longitude 
;        Output after converting to ppb. 
;        
; 
;KEYWORD PARAMETERS 
; ik:         INPUT:  Array containing the two desired levels.
; nobs:       INPUT:  Array containing desired observations
; iskip:      INPUT:  number of observations to skip from first tape
; dsn:        INPUT:  desired data sets. 
; date:      OUTPUT: Array containing dates of observations. 
;
;-
function fd4d_fdmovie,ik=ik,nobs=nobs,dd=dd,dsn=dsn,iskip=iskip,date=date,$
 ncon=ncon,scon=scon  

if n_elements(dd) eq 0 then dd = '/local/data/allen/'
if n_elements(dsn) eq 0 then dsn = ['e731.dat145']
if n_elements(ncon) eq 0 then ncon = 4
if n_elements(scon) eq 0 then scon = 'co' 

ntapes = size(dsn) & ntapes = ntapes(1)
if n_elements(iskip) eq 0 then iskip = 0  
if n_elements(ik) eq 0 then ik = [0,10] & ik0 = ik(0) & ik1 = ik(1) 

if n_elements(nobs) eq 0 then begin & nobs = lonarr(ntapes) & nobs(*) = 16 & end 

nobs_tot = long(total(nobs))  

ilmm = 72 & ijmm = 46 
fd = fltarr(ilmm,ijmm,2,nobs_tot) & date = fltarr(nobs_tot) 

low = 0 ; Input 144 by 91 --> Output 72 by 46 
avg = 0 ; Input fields are not monthly average fields. 

;Skip over undesired observations! 
iobs = -1 
for itape=0,ntapes-1 do begin 
for i=0,nobs(itape)-1 do begin
   iobs = iobs + 1 
   case i of 
   0: iread = 1 
   nobs(itape)-1: iread = 3
   else: iread = 2
   endcase 
   if (itape eq 0) then iskip2=iskip else iskip2 = 0 
   field = rd4d(hd=hd,psf=psf,iskip=iskip2,dsn=dsn(itape),avg=avg,low=low,dd=dd,$
    iread=iread,ilun=ilun,ncon=ncon)  ;field is 4-d CO array. 
   fd3d = total(field,4)    ;fd3d is 3-d CO array. 
   fd3d = shift(fd3d,36,0,0) 
   fd(0,0,0,iobs) = fd3d(*,*,ik0)
   fd(0,0,1,iobs) = fd3d(*,*,ik1)  
   date(iobs) = hd(5) 
endfor
endfor 

case scon of 
'co': begin
         print,'CO: convert to ppb'
         fd = fd * 1.e9    
      end
'rn222': begin
         print,'rn222: convert to pCi/SCM'
         fd = fd * 1.538
         end
else:
endcase 

return,fd
end 


 
