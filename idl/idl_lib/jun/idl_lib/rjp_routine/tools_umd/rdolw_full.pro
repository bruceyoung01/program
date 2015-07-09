function rdolw_full,date=date,dsn=dsn,dd=dd,hd=hd,psf=psf,iskip=iskip,$
ca_frc=ca_frc,random=random 

if n_elements(random) eq 0 then random = 0
if (random eq 1) then ss = 'r' else ss = 'm' 
if n_elements(dsn) eq 0 then dsn = 'e0054A.b910101.e910107.cl'+ss+'olw'
if n_elements(dd) eq 0 then dd = '/optical/mt/allen/max_overlap/'
if n_elements(iskip) eq 0 then iskip = 0 

openr,ilun,dd+dsn,/xdr,/get_lun

ilmm = 144 & ijmm = 91 & ikmm = 20 
hd = fltarr(3) & psf = fltarr(ilmm,ijmm) & fd = fltarr(ilmm,ijmm,ikmm)
cld_frc = psf & ca_frc=psf 

for i=0,iskip do readu,ilun,hd,psf,hd,fd

;Shift to return 0 to 357.5E instead of -180 to ..
psf = shift(psf,ilmm/2,0) 
fd = shift(fd,ilmm/2,0,0) 

case random of 
1: ca_frc(*,*) = 0. 
else: begin
         for ij=0,ijmm-1 do begin
         for il=0,ilmm-1 do begin
            ca_frc(il,ij) = max(reform(fd(il,ij,*)))
         endfor
         endfor 
       end
endcase 
date = hd(1) + hd(2) / 240000. 
free_lun,ilun

return,fd
end 
