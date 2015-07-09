pro convertuv,dd=dd,byymmdd=byymmdd,eyymmdd=eyymmdd

if n_elements(dd) eq 0 then dd = '/local/data/'
if n_elements(byymmdd) eq 0 then byymmdd = '910522' 
if n_elements(eyymmdd) eq 0 then eyymmdd = '910531' 

ddd = strmid(eyymmdd,4,2)
case ddd of 
'29': nobs = 32
'30': nobs = 36
'31': nobs = 40
else: nobs = 28
endcase 
hd = fltarr(3) & psf = fltarr(144,91) & u = fltarr(144,91,20) & v = u & t = u 

dsn = 'e0054A.prg.b'+byymmdd+'.e'+eyymmdd+'.psfuvt'
openr,ilun,dd+dsn,/xdr,/get_lun
openw,lunout,dd+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,hd,psf,hd,u,hd,v,hd,t
   print,hd,t(0,45,0) 
   writeu,lunout,hd,psf
   writeu,lunout,hd,u
   writeu,lunout,hd,v
   writeu,lunout,hd,t
endfor
free_lun,ilun
free_lun,lunout 

return 
end 
