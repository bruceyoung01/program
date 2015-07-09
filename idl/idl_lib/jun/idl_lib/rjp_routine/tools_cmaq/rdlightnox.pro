function rdlightnox, file=file,ilun=ilun,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm

if n_elements(ilun) eq 0 then openr,ilun,file,/xdr,/get
if n_elements(ilmm) eq 0 then ilmm = 72
if n_elements(ijmm) eq 0 then ijmm = 46
if n_elements(ikmm) eq 0 then ikmm = 20

lnox = fltarr(ilmm,ijmm,ikmm)

 readu, ilun, lnox

 return, lnox
end
