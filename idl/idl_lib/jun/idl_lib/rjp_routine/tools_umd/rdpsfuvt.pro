;+
;NAME:
;      rdcloud.pro
;PURPOSE:
;      Read in psf, u, v, and T and if desired SH from GEOS-DAS  
;
;KEYWORD PARAMETERS
;      iread 0: open, read, and close
;            1: open and read 
;            2: read only
;            3: read and close 
;
;- 
function rdpsfuvt,dd=dd,dsn=dsn,iskip=iskip,date=date,hd=hd,psf=psf,v=v,$
 iread=iread,ilun=ilun,ikmm=ikmm,f77=f77,fdshift=fdshift,t=t,qq=qq,sh=sh

if n_elements(dd) eq 0 then dd = ''
if n_elements(dsn) eq 0 then dsn = 'e0054A.prg.b910322.e910331.psfuvt'
if n_elements(iskip) eq 0 then iskip = 0 
if n_elements(ikmm) eq 0 then ikmm = 20 
if n_elements(iread) eq 0 then iread = 0 
if n_elements(f77) eq 0 then f77 = 0
if n_elements(fdshift) eq 0 then fdshift = 0
if n_elements(qq) eq 0 then qq = 0  

ilmm = 144 & ijmm = 91 
hd = fltarr(3) & psf = fltarr(ilmm,ijmm) & u = fltarr(ilmm,ijmm,ikmm)
v = u & t = u 
if (qq eq 1) then sh = u 

case f77 of 
0:    if (iread lt 2) then openr,ilun,dd+dsn,/xdr,/get_lun
else: if (iread lt 2) then openr,ilun,dd+dsn,/f77_unformatted,/get_lun
endcase
      
for i=0,iskip do begin
   readu,ilun,hd,psf
   readu,ilun,hd,u
   readu,ilun,hd,v 
   readu,ilun,hd,t
   if (qq eq 1) then readu,ilun,hd,sh  
endfor 
if ((iread eq 0) or (iread eq 3)) then free_lun,ilun

;Shift to return 0 to 357.5E instead of -180 to ..
case fdshift of
0: 
else: begin 
      psf = shift(psf,ilmm/2,0) 
      u = shift(u,ilmm/2,0,0) 
      v = shift(v,ilmm/2,0,0) 
      t = shift(t,ilmm/2,0,0)   
      if (qq eq 1) then sh = shift(sh,ilmm/2,0,0)     
      end
endcase 

date = hd(1) + hd(2) / 240000. 

return,u
end 
