;+
;NAME:
;      rdpbl.pro
;PURPOSE:
;      Read in pbl depth from GEOS-DAS  
;
;KEYWORD PARAMETERS
;      iread 0: open, read, and close
;            1: open and read 
;            2: read only
;            3: read and close 
;
;- 
function rdpbl,dd=dd,dsn=dsn,iskip=iskip,date=date,hd=hd,iread=iread,ilun=ilun,$
 f77=f77,fdshift=fdshift 

if n_elements(dd) eq 0 then dd = ''
if n_elements(dsn) eq 0 then dsn = 'e0054A.b931208.e931214.pbl'
if n_elements(iskip) eq 0 then iskip = 0 
if n_elements(iread) eq 0 then iread = 0
if n_elements(f77) eq 0 then f77 = 0  
if n_elements(fdshift) eq 0 then fdshift = 0 

ilmm = 144 & ijmm = 91 
hd = fltarr(3) & pbl = fltarr(ilmm,ijmm) 

case f77 of 
1:    if (iread lt 2) then openr,ilun,dd+dsn,/f77_unformatted,/get_lun
else:  if (iread lt 2) then openr,ilun,dd+dsn,/xdr,/get_lun
endcase

for i=0,iskip do readu,ilun,hd,pbl 
if ((iread eq 0) or (iread eq 3)) then free_lun,ilun

;If desired, shift to return 0 to 357.5E instead of -180 to ..
case fdshift of
0: 
else: pbl = shift(pbl,ilmm/2,0) 
endcase

date = hd(1) + hd(2) / 240000. 

return,pbl
end 
