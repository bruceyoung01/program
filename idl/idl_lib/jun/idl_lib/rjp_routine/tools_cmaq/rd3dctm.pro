function rd3dctm, file,ilun=ilun,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon,press=press, $
         temp=temp,aird=aird,hdr=hdr

if n_elements(file) eq 0 then return, 0
if n_elements(ilun) eq 0 then openr,ilun,file,/xdr,/get_lun
if n_elements(ilmm) eq 0 then ilmm = 72
if n_elements(ijmm) eq 0 then ijmm = 46
if n_elements(ikmm) eq 0 then ikmm = 20
if n_elements(ncon) eq 0 then return, 0

hdr = fltarr(2) & press = fltarr(ilmm,ijmm,ikmm) & temp = press & aird = press
conc = fltarr(ilmm,ijmm,ikmm,ncon)

 readu, ilun, hdr, press
 readu, ilun, hdr, temp
 readu, ilun, hdr, aird
 readu, ilun, hdr, conc
 print, hdr,max(press),max(temp),max(aird)

 return, conc

end
