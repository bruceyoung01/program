function rd3dctm_dec, file,ilun=ilun,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon,press=press, $
         temp=temp,aird=aird,hdr=hdr

if n_elements(file) eq 0 then return, 0
if n_elements(ilun) eq 0 then openr,ilun,file,/f77,/swap_endian,/get_lun
if n_elements(ilmm) eq 0 then ilmm = 72
if n_elements(ijmm) eq 0 then ijmm = 46
if n_elements(ikmm) eq 0 then ikmm = 20
if n_elements(ncon) eq 0 then ncon = 25

hdr = fltarr(2) & press = fltarr(ilmm,ijmm,ikmm) & temp = press & aird = press
conc = fltarr(ilmm,ijmm,ikmm,ncon) & dat = press

 readu, ilun, hdr
 readu, ilun, press
 readu, ilun, temp
 readu, ilun, aird
 for i = 0, ncon-1 do begin
  readu, ilun, dat
  conc(*,*,*,i) = dat
 end
 print, hdr,max(press),max(temp),max(aird)

 return, conc
end
