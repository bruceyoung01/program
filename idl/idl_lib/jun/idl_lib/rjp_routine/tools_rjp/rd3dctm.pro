function rd3dctm, file,ilun=ilun,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon,press=press, $
         temp=temp,aird=aird,hdr=hdr

if n_elements(file) eq 0 then return, 0
 cp  = strlen(file)
 tag = strmid(file,cp-3,3)
if n_elements(ilun) eq 0 then begin
 case tag of 
  'xdr' : openr,ilun,file,/xdr,/get_lun
  '77l' : openr,ilun,file,/f77,/get_lun
  '77b' : openr,ilun,file,/f77,/swap_endian,/get_lun
  'ads' : openr,ilun,file,/get_lun
   else : begin
        print, 'Type of binary is not matched'
        stop
        end
 endcase
endif
if n_elements(ilmm) eq 0 then ilmm = 72
if n_elements(ijmm) eq 0 then ijmm = 46
if n_elements(ikmm) eq 0 then ikmm = 20
if n_elements(ncon) eq 0 then begin
   print, 'please give me the number of species, rd3dctm'
   return, 0
endif

hdr = fltarr(2) & press = fltarr(ilmm,ijmm,ikmm) & temp = press & aird = press
conc = fltarr(ilmm,ijmm,ikmm,ncon) & data = press

;; Previous data to read
; readu, ilun, hdr, press
; readu, ilun, hdr, temp
; readu, ilun, hdr, aird
; readu, ilun, hdr, conc

; new data to read
 readu, ilun, hdr
 readu, ilun, press
 readu, ilun, temp
 readu, ilun, aird
 
 for ic = 0, ncon-1 do begin
  readu, ilun, data
  conc(*,*,*,ic) = data
 endfor

 print, hdr,max(press),max(temp),max(aird)

 return, conc

end
