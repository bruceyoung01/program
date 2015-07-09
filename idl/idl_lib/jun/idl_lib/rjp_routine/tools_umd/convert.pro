pro convert,byymmdd=byymmdd,eyymmdd=eyymmdd,ddpbl=ddpbl,$
ddtke=ddtke,ddpsfuvt=ddpsfuvt,ddpsfcld=ddpsfcld,flag=flag,$
dddiff=dddiff,qq=qq,nexp=nexp,ddtrpps=ddtrpps

;byymmdd :String containing beginning date in YYMMDD format.
;eyymmdd :String containing ending date in YYMMDD format.
;ddpbl   :Directory *.pbl files are in 
;ddtke   :Directory *.tke files are in
;dddiff  ;Directory *.kh files are in
;ddpsfuvt ;Directory *.psfuvt(qq) files are in
;ddpsfcld ;Directory *.psfcld files are in
;ddtrpps ;Directory *.trpps files are in
;qq;      Set to 1 if specific humidity is in *.psfuvt data set.
;nexp:    Experiment 'e0054A', 'stratf','stratf26' or 'TRMM01' 
;flag     String variable of length 6. Set elements 0-5 to 1 if desire
; to convert a particular field
; 0: psfuvt
; 1: psfcld
; 2: pbl
; 3: diffusion 
; 4: tke
; 5: trpps  (available only for a few strat runs)  
;  e.g. to convert *.psfuvt only use flag = '100000' 

if n_elements(nexp) eq 0 then nexp = 'e0054A' 
if n_elements(qq) eq 0 then qq = 0 
if n_elements(ddpbl) eq 0 then ddpbl = '/data/eos3/allen/ctm/pbl/'
if n_elements(ddtke) eq 0 then ddtke = '/data/eos3/allen/ctm/tke/'
if n_elements(dddiff) eq 0 then dddiff = '/data/eos3/allen/ctm/diff/' 
if n_elements(ddpsfuvt) eq 0 then ddpsfuvt = '/data/eos3/allen/ctm/psfuvt/'
if n_elements(ddpsfcld) eq 0 then ddpsfcld = '/data/eos3/allen/ctm/psfcld/'
if n_elements(ddtrpps) eq 0 then ddtrpps = '/data/eos3/allen/ctm/trpps/' 

if n_elements(byymmdd) eq 0 then byymmdd = '910522' 
if n_elements(eyymmdd) eq 0 then eyymmdd = '910531' 

if n_elements(flag) eq 0 then flag = '11100'

s0 = strtrim(strmid(flag,0,1),2) 
s1 = strtrim(strmid(flag,1,1),2)  
s2 = strtrim(strmid(flag,2,1),2) 
s3 = strtrim(strmid(flag,3,1),2) 
s4 = strtrim(strmid(flag,4,1),2)  
s5 = strtrim(strmid(flag,5,1),2)  

case nexp of
'e0054A': begin & ikmm = 20 & pblfac = 2 & end
'stratf': begin & ikmm = 46 & pblfac = 1 & end
'stratf26': begin & ikmm = 26 & pblfac = 1 & end
'TRMM01': begin & ikmm = 70 & pblfac = 2 & end
else: print,'Please specify ikmm for experiment' 
endcase 

ddd = strmid(eyymmdd,4,2)
case ddd of 
'29': nobs = 32
'30': nobs = 36
'31': nobs = 40
else: nobs = 28
endcase 
hd = fltarr(3) & psf = fltarr(144,91) & u = fltarr(144,91,ikmm) & v = u & t = u 
qqq = u 
case s0 of 
'1': begin 

case 1 of 
((qq eq 0) and (nexp eq 'e0054A')): dsn = nexp+'.prg.b'+byymmdd+'.e'+eyymmdd+'.psfuvt'
(qq eq 0): dsn = nexp+'.b'+byymmdd+'.e'+eyymmdd+'.psfuvt'
((qq eq 1) and (nexp eq 'e0054A')): dsn = nexp+'.prg.b'+byymmdd+'.e'+eyymmdd+'.psfuvtqq'
else:    dsn = nexp+'.b'+byymmdd+'.e'+eyymmdd+'.psfuvtqq'
endcase 

openr,ilun,ddpsfuvt+dsn,/xdr,/get_lun
openw,lunout,ddpsfuvt+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   if (qq eq 1) then readu,ilun,hd,psf,hd,u,hd,v,hd,t,hd,qqq $
                else readu,ilun,hd,psf,hd,u,hd,v,hd,t
   print,hd,t(0,45,0) 
   writeu,lunout,hd,psf
   writeu,lunout,hd,u
   writeu,lunout,hd,v
   writeu,lunout,hd,t
   if (qq eq 1) then writeu,lunout,hd,qqq 
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

case s1 of
'1': begin
dsn = nexp+'.b'+byymmdd+'.e'+eyymmdd+'.psfcld'
openr,ilun,ddpsfcld+dsn,/xdr,/get_lun
openw,lunout,ddpsfcld+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,hd,psf,hd,u,hd,v
   print,hd 
   writeu,lunout,hd,psf
   aa = where(abs(u) lt 0.001) & u(aa) = 0. 
   aa = where(abs(v) lt 0.001) & v(aa) = 0. 
   writeu,lunout,hd,u
   writeu,lunout,hd,v
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase 

case s2 of
'1': begin
nexpz = nexp 
if (nexp eq 'stratf26') then nexpz = 'stratf' 
dsn = nexpz+'.b'+byymmdd+'.e'+eyymmdd+'.pbl'
openr,ilun,ddpbl+dsn,/xdr,/get_lun
openw,lunout,ddpbl+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs*pblfac do begin 
   readu,ilun,hd,psf
   print,hd
   writeu,lunout,hd,psf
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

case s3 of
'1': begin
dsn = nexp+'.b'+byymmdd+'.e'+eyymmdd+'.kh'
openr,ilun,dddiff+dsn,/xdr,/get_lun
openw,lunout,dddiff+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,hd,u
   print,hd
   writeu,lunout,hd,u  
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

case s4 of
'1': begin
dsn = nexp+'.b'+byymmdd+'.e'+eyymmdd+'.tke'
openr,ilun,ddtke+dsn,/xdr,/get_lun
openw,lunout,ddtke+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,hd,psf,hd,u
   print,hd
   writeu,lunout,hd,psf
   writeu,lunout,hd,u  
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

case s5 of
'1': begin
nexpz = nexp 
if (nexp eq 'stratf26') then nexpz = 'stratf' 
dsn = nexpz+'.b'+byymmdd+'.e'+eyymmdd+'.trpps'
dsn1 = dsn + '_xdr' 
openr,ilun,ddtrpps+dsn1,/xdr,/get_lun
openw,lunout,ddtrpps+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,hd,psf
   print,hd
   writeu,lunout,hd,psf
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

return 
end 
