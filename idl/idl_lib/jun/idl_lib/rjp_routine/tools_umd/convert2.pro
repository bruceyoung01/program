;+
; NAME: convert
;   
; PURPOSE: I/O subroutine that reads in IEEE fields and writes out
;          DECNET fortran binary data sets. 
;   
; CALLING SEQUENCE:
;
; CAUTIONS
;   
; INPUT PARAMETERS (POSITIONAL):
;   
; INPUT PARAMETERS (KEYWORD) 
;   
; OUTPUTS
;
; OUTPUT PARAMETERS (KEYWORD)
;     
;       
; MODIFICATION HISTORY: 
 
;-
pro convert,byyyymmdd=byyyymmdd,eyyyymmdd=eyyyymmdd,ddpbl=ddpbl,$
ddtke=ddtke,ddpsfuvt=ddpsfuvt,ddpsfcld=ddpsfcld,flag=flag,$
dddiff=dddiff,qq=qq,nexp=nexp,ddtrpps=ddtrpps,pp=pp,y2k=y2k

;byyyymmdd :String containing beginning date in YYMMDD format.
;eyyyymmdd :String containing ending date in YYMMDD format.
;ddpbl   :Directory *.pbl files are in 
;ddtke   :Directory *.tke files are in
;dddiff  ;Directory *.kh files are in
;ddpsfuvt ;Directory *.psfuvt(qq) files are in
;ddpsfcld ;Directory *.psfcld files are in
;ddtrpps ;Directory *.trpps files are in
;qq;      Set to 1 if specific humidity is in *.psfuvt data set.
;pp;      Set to 1 if precon is in *.psfcld data set. 
;nexp:    Experiment 'e0054A', 'stratf','stratf26' or 'TRMM01' 
;flag     String variable of length 6. Set elements 0-5 to 1 if desire
;dsngrid: data set containing coordinates of A grid. 
; to convert a particular field
; 0: psfuvt
; 1: psfcld
; 2: pbl
; 3: diffusion 
; 4: tke
; 5: trpps  (available only for a few strat runs)  
;  e.g. to convert *.psfuvt only use flag = '100000' 

if n_elements(nexp) eq 0 then nexp = 'b271_sg48' 
if n_elements(qq) eq 0 then qq = 1 
if n_elements(pp) eq 0 then pp = 1 
if n_elements(ddpbl) eq 0 then ddpbl = '/data/eos3/allen/ctm/pbl/'
if n_elements(ddtke) eq 0 then ddtke = '/data/eos3/allen/ctm/tke/'
if n_elements(dddiff) eq 0 then dddiff = '/data/eos3/allen/ctm/diff/' 
if n_elements(ddpsfuvt) eq 0 then ddpsfuvt = '/data/eos3/allen/ctm/psfuvt/'
if n_elements(ddpsfcld) eq 0 then ddpsfcld = '/data/eos3/allen/ctm/psfcld/'
if n_elements(ddtrpps) eq 0 then ddtrpps = '/data/eos1/allen/ctm/trpps/' 

if n_elements(byyyymmdd) eq 0 then byyyymmdd = '970915' 
if n_elements(eyyyymmdd) eq 0 then eyyyymmdd = '970921' 
if n_elements(y2k) eq 0 then y2k = 0 
if n_elements(dsngrid) eq 0 then dsngrid = 'hgrid_14491.input_f77'

if n_elements(flag) eq 0 then flag = '11000'

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
'b271_sg_35sigp': begin & ikmm = 35 & pblfac = 2 & end 
'b270_ug_35sigp': begin & ikmm = 35 & pblfac = 2 & end 
'b271_w97Sr_sg_35sigp': begin & ikmm = 35 & pblfac = 2 & end 
'b271_w97Sr_ug_35sigp': begin & ikmm = 35 & pblfac = 2 & end 
'b271_w97Sr_ug': begin & ikmm = 35 & pblfac = 2 & end 
'b271_sg48': begin & ikmm = 48 & pblfac = 2 & end 
'b270_ug48': begin & ikmm = 48 & pblfac = 2 & end 
'b271_w97Sr': begin & ikmm = 48 & pblfac = 2 & end 
'b271_w97Sr_sg48': begin & ikmm = 48 & pblfac = 2 & end
'b271_w97ST': begin & ikmm = 48 & pblfac = 2 & end  
'b271_w97ST_sg48': begin & ikmm = 48 & pblfac = 2 & end
'b271_w97ST_sg': begin & ikmm = 48 & pblfac = 2 & end
'b271_w97Sp': begin & ikmm = 48 & pblfac = 2 & end  
'b271_w97Sp_sg48': begin & ikmm = 48 & pblfac = 2 & end
'b271_w97Sp_sg': begin & ikmm = 48 & pblfac = 2 & end
'b271_w97Sp_sg36': begin & ikmm = 36 & pblfac = 2 & end
else: print,'Please specify ikmm for experiment' 
endcase 

dexp = 1. 
if (y2k eq 1) then dymd = 1.d else dymd = 1.
if (y2k eq 1) then dhms = 1.d else dhms = 1.

ddd = strmid(eyyyymmdd,4,2)
case ddd of 
'29': nobs = 32
'30': nobs = 36
'31': nobs = 40
'28': nobs = 28
else: begin
      ddd = strmid(eyyyymmdd,6,2)
      case ddd of
      '29': nobs = 32
      '30': nobs = 36
      '31': nobs = 40
      '28': nobs = 28
      else: nobs = 28
      endcase
      end
endcase 
print,'nobs = ',nobs
psf = fltarr(144,91) & u = fltarr(144,91,ikmm) & v = u & t = u 
qqq = u 
case s0 of 
'1': begin 

case 1 of 
((qq eq 0) and (nexp eq 'e0054A')): dsn = nexp+'.prg.b'+byyyymmdd+'.e'+eyyyymmdd+'.psfuvt'
(qq eq 0): dsn = nexp+'.b'+byyyymmdd+'.e'+eyyyymmdd+'.psfuvt'
((qq eq 1) and (nexp eq 'e0054A')): dsn = nexp+'.prg.b'+byyyymmdd+'.e'+eyyyymmdd+'.psfuvtqq'
else:    dsn = nexp+'.b'+byyyymmdd+'.e'+eyyyymmdd+'.psfuvtqq'
endcase 

openr,ilun,ddpsfuvt+dsn,/xdr,/get_lun
openw,lunout,ddpsfuvt+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   if (qq eq 1) then readu,ilun,dexp,dymd,dhms,psf,dexp,dymd,dhms,u,dexp,dymd,dhms,v,dexp,dymd,dhms,t,dexp,dymd,dhms,qqq $
                else readu,ilun,dexp,dymd,dhms,psf,dexp,dymd,dhms,u,dexp,dymd,dhms,v,dexp,dymd,dhms,t
   print,dexp,dymd,dhms,t(0,45,0) 
   writeu,lunout,dexp,dymd,dhms,psf
   aa = where(abs(u) lt 1.e-30,count)
   if (count gt 0) then u(aa) = 0. 
   writeu,lunout,dexp,dymd,dhms,u
   aa = where(abs(v) lt 1.e-30,count)
   if (count gt 0) then v(aa) = 0. 
   writeu,lunout,dexp,dymd,dhms,v
   writeu,lunout,dexp,dymd,dhms,t
   if (qq eq 1) then writeu,lunout,dexp,dymd,dhms,qqq 
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

case s1 of
'1': begin
dsn = nexp+'.b'+byyyymmdd+'.e'+eyyyymmdd+'.psfcld'
if (pp eq 1) then dsn = dsn + 'p' 
openr,ilun,ddpsfcld+dsn,/xdr,/get_lun
openw,lunout,ddpsfcld+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,dexp,dymd,dhms,psf
   print,dexp,dymd,dhms
   writeu,lunout,dexp,dymd,dhms,psf

;  Read in and writeout convective precipitation. 
   if (pp eq 1) then readu,ilun,dexp,dymd,dhms,psf
   if (pp eq 1) then writeu,lunout,dexp,dymd,dhms,psf
   
   readu,ilun,dexp,dymd,dhms,u,dexp,dymd,dhms,v     
   aa = where(abs(u) lt 0.001) & u(aa) = 0. 
   aa = where(abs(v) lt 0.001) & v(aa) = 0. 
   writeu,lunout,dexp,dymd,dhms,u
   writeu,lunout,dexp,dymd,dhms,v
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
dsn = nexpz+'.b'+byyyymmdd+'.e'+eyyyymmdd+'.pbl'
openr,ilun,ddpbl+dsn,/xdr,/get_lun
openw,lunout,ddpbl+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs*pblfac do begin 
   readu,ilun,dexp,dymd,dhms,psf
   print,dexp,dymd,dhms
   writeu,lunout,dexp,dymd,dhms,psf
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

case s3 of
'1': begin
dsn = nexp+'.b'+byyyymmdd+'.e'+eyyyymmdd+'.kh'
openr,ilun,dddiff+dsn,/xdr,/get_lun
openw,lunout,dddiff+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,dexp,dymd,dhms,u
   print,dexp,dymd,dhms
   writeu,lunout,dexp,dymd,dhms,u  
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

case s4 of
'1': begin
dsn = nexp+'.b'+byyyymmdd+'.e'+eyyyymmdd+'.tke'
openr,ilun,ddtke+dsn,/xdr,/get_lun
openw,lunout,ddtke+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,dexp,dymd,dhms,psf,dexp,dymd,dhms,u
   print,dexp,dymd,dhms
   writeu,lunout,dexp,dymd,dhms,psf
   writeu,lunout,dexp,dymd,dhms,u  
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
dsn = nexpz+'.b'+byyyymmdd+'.e'+eyyyymmdd+'.trpps'
dsn1 = dsn + '_xdr' 
openr,ilun,ddtrpps+dsn1,/xdr,/get_lun
openw,lunout,ddtrpps+dsn+'_f77',/f77_unformatted,/get_lun

for iobs=0,nobs-1 do begin 
   readu,ilun,dexp,dymd,dhms,psf
   print,dexp,dymd,dhms
   writeu,lunout,dexp,dymd,dhms,psf
endfor
free_lun,ilun
free_lun,lunout 
end
else:
endcase

return 
end 
