;+
;NAME:
;      shiftpsfuvt.pro
;PURPOSE:
;      Read in mass flux and detrainment from GEOS-STRAT
;      Shift in vertical.
;      kshift should equal 1 or -13   
;
;KEYWORD PARAMETERS
;      iread 0: open, read, and close
;            1: open and read 
;            2: read only
;            3: read and close 
;
;- 
pro shiftpsfuvt,dd=dd,byymmdd=byymmdd,eyymmdd=eyymmdd,ikmm1=ikmm1,f77=f77,$
 kshift=kshift,nexp=nexp,ikmm2=ikmm2  

if n_elements(nexp) eq 0 then nexp = 'stratf' 
if n_elements(byymmdd) eq 0 then byymmdd = '971108' 
if n_elements(eyymmdd) eq 0 then eyymmdd = '971114' 
if n_elements(dd) eq 0 then dd = ''
if n_elements(ikmm1) eq 0 then ikmm1 = 46 
if n_elements(ikmm2) eq 0 then ikmm2 = ikmm1 
if n_elements(f77) eq 0 then f77 = 0
if n_elements(kshift) eq 0 then kshift = 1 

ddd = strmid(eyymmdd,4,2)
case ddd of 
'29': nobs = 32
'30': nobs = 36
'31': nobs = 40
else: nobs = 28
endcase 

case f77 of 
0: begin 
      dsn = nexp+'.b'+byymmdd+'.e'+eyymmdd+'.psfuvtqq'
      openr,ilun,dd+dsn,/xdr,/get_lun
      openw,lunout,dd+dsn+'f77_s',/f77_unformatted,/get_lun
   end
else: begin 
      dsn = nexp+'.b'+byymmdd+'.e'+eyymmdd+'.psfuvtqq_f77'
      openr,ilun,dd+dsn,/f77_unformatted,/get_lun
      openw,lunout,dd+dsn+'_s',/f77_unformatted,/get_lun
   end
endcase 

for iobs=0,nobs-1 do begin 
   case iobs of
   0: iread = 1 
   nobs-1: iread = 3 
   else: iread = 2 
   endcase 
   u = rdpsfuvt(dd=dd,dsn=dsn,hd=hd,psf=psf,v=v,t=t,sh=sh,qq=1,iread=iread,$
    ilun=ilun,ikmm=ikmm1,f77=f77) 
   print,hd 
   
   writeu,lunout,hd,psf
   writeu,lunout,hd,u(*,*,0:ikmm2-1) 
   writeu,lunout,hd,v(*,*,0:ikmm2-1)  
   writeu,lunout,hd,t(*,*,0:ikmm2-1) 
   writeu,lunout,hd,sh(*,*,0:ikmm2-1)  

endfor 

free_lun,lunout 
return
end 
