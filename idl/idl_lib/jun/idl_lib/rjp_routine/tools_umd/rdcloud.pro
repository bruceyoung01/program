;+
;NAME:
;      rdcloud.pro
;PURPOSE:
;      Read in mass flux and detrainment from GEOS-DAS  
;
;KEYWORD PARAMETERS
;      iread 0: open, read, and close
;            1: open and read 
;            2: read only
;            3: read and close 
;
;- 
function rdcloud,dd=dd,dsn=dsn,iskip=iskip,date=date,hd=hd,psf=psf,det=det,$
 iread=iread,ilun=ilun,ikmm=ikmm,f77=f77,fdshift=fdshift

if n_elements(dd) eq 0 then dd = ''
if n_elements(dsn) eq 0 then dsn = 'e0054A.b900701.e900707.psfcld'
if n_elements(iskip) eq 0 then iskip = 0 
if n_elements(ikmm) eq 0 then ikmm = 20 
if n_elements(iread) eq 0 then iread = 0 
if n_elements(f77) eq 0 then f77 = 0
if n_elements(fdshift) eq 0 then fdshift = 0 

ilmm = 144 & ijmm = 91 
hd = fltarr(3) & psf = fltarr(ilmm,ijmm) & mflux = fltarr(ilmm,ijmm,ikmm)
det = mflux 

case f77 of 
0:    if (iread lt 2) then openr,ilun,dd+dsn,/xdr,/get_lun
else: if (iread lt 2) then openr,ilun,dd+dsn,/f77_unformatted,/get_lun
endcase
      
for i=0,iskip do begin
   readu,ilun,hd,psf
   readu,ilun,hd,mflux
   readu,ilun,hd,det 
endfor 
if ((iread eq 0) or (iread eq 3)) then free_lun,ilun

;Shift to return 0 to 357.5E instead of -180 to ..
case fdshift of
0: 
else: begin 
      psf = shift(psf,ilmm/2,0) 
      mflux = shift(mflux,ilmm/2,0,0) 
      det = shift(det,ilmm/2,0,0) 
      end
endcase 

date = hd(1) + hd(2) / 240000. 

return,mflux
end 
