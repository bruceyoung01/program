function rdrestart,hd=hd,iskip=iskip,ikmm=ikmm,ncon=ncon,dd=dd,dsn=dsn,f77=f77,$
 ilmm=ilmm,ijmm=ijmm

if n_elements(dd) eq 0 then dd = ''
if n_elements(dsn) eq 0 then dsn = 'e100.rsxx6'
if n_elements(iskip) eq 0 then iskip = 0 
if n_elements(ikmm) eq 0 then ikmm = 20
if n_elements(ncon) eq 0 then ncon = 1 
if n_elements(f77) eq 0 then f77 = 0
if n_elements(ilmm) eq 0 then ilmm = 144
if n_elements(ijmm) eq 0 then ijmm = 91  

hd = fltarr(50) & field = fltarr(ilmm,ijmm,ikmm,ncon)

case f77 of
0: openr,ilun,dd+dsn,/xdr,/get_lun 
else: openr,ilun,dd+dsn,/f77_unformatted,/get_lun 
endcase 

for i=0,iskip do readu,ilun,hd,field
free_lun,ilun

return,field
end 
