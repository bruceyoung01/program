function rdconc, file,ilun=ilun,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon,press=press, $
         temp=temp,aird=aird,hdr=hdr

if n_elements(file) eq 0 then return, 0
if n_elements(ilun) eq 0 then openr,ilun,file,/get_lun
if n_elements(ilmm) eq 0 then ilmm = 72
if n_elements(ijmm) eq 0 then ijmm = 46
if n_elements(ikmm) eq 0 then ikmm = 20
if n_elements(ncon) eq 0 then ncon = 25

hdr = fltarr(2) & press = fltarr(ilmm,ijmm,ikmm) & temp = press & aird = press
conc = fltarr(ilmm,ijmm,ikmm,ncon) & data = press

; Previous data to read
; readu, ilun, hdr, press
; readu, ilun, hdr, temp
; readu, ilun, hdr, aird
; readu, ilun, hdr, conc
  readu, ilun, temp
  readu, ilun, press
  readu, ilun, aird
  readu, ilun, conc

  temp = reverse(temp,3)
  press= reverse(press,3)
  aird = reverse(aird,3)
  for ic = 0, ncon-1 do conc(*,*,*,ic) = reverse(conc(*,*,*,ic),3)*aird

 print, max(press),max(temp),max(aird)

 return, conc

end

function airmass, press=press
if n_elements(press) eq 0 then return, 0

ndim = size(press,/dim)
ilmm = ndim(0)
ijmm = ndim(1)
ikmm = ndim(2)

ptop = 10.
Mair = press
pressl = fltarr(ikmm+1)

for j = 0, ijmm-1 do begin
for i = 0, ilmm-1 do begin
pressl(0) = 10.
pressl(1:ikmm-1) = 0.5*(press(i,j,0:ikmm-2)+press(i,j,1:ikmm-1))
pressl(ikmm) = 2.*press(i,j,ikmm-1)-pressl(ikmm-1)
Mair(i,j,*)  = pressl(1:ikmm) - pressl(0:ikmm-1)
istrat = where(pressl lt 200.)
Mair(i,j,istrat) = 0.
endfor
endfor

area = sfcarea(ilmm=ilmm,ijmm=ijmm)

for k = 0, ikmm-1 do begin
Mair(*,*,k) = Mair(*,*,k)*100.*area*1.e-4/9.8   ; kg air
endfor

return, Mair
end


pro oh_lifetime, file, itime=itime

if n_elements(file) eq 0 then file = pickfile()
if n_elements(ilmm) eq 0 then ilmm = 72
if n_elements(ijmm) eq 0 then ijmm = 46
if n_elements(ikmm) eq 0 then ikmm = 20
if n_elements(ncon) eq 0 then ncon = 25
if n_elements(itime) eq 0 then return

hdr = fltarr(2) & press = fltarr(ilmm,ijmm,ikmm) & temp = press & aird = press
conc = fltarr(ilmm,ijmm,ikmm,ncon)
dat = fltarr(ilmm,ijmm,ikmm)

 Tmair = fltarr(ilmm,ijmm,ikmm) & meanOH = Tmair & Tloss = Tmair
 Tkdm = Tmair
 
 ioh  = spec('OH',ncon=25)
 dStY = 1./(3600.*24.*365.25)
 Tlife = 0.
 TmeanOH = 0.

 
; Calculate Ch3Ccl3 lifetime against OH oxidation according to Prather [1990]
; T = sum(dm)/sum(k*[OH]*dm),  <OH> = sum(k*[OH]*dm)/sum(k*dm)
 openw,jlun,'Tch3ccl3',/get_lun

 for i = 0, itime-1 do begin
 conc = rdconc(file,ilun=ilun,press=press,temp=temp,aird=aird)
;  conc = rd3dctm(file,ilun=ilun,press=press,temp=temp,aird=aird)
;  conc = rd3dctm_dec(file,ilun=ilun,press=press,temp=temp,aird=aird)
 
 OH = conc(*,*,*,ioh)

 k = 1.8e-12 * exp(-1550./temp)
; dm = aird 
 dm = airmass(press=press)
 Loss  = k * OH * dm
 kdm   = k * dm
 
 Tmair = Tmair + dm
 Tloss = Tloss + Loss
 Tkdm  = Tkdm + kdm
 
 life = total(dm)/total(Loss)*dStY  ; Year..

 meanOH = total(Loss)/total(kdm) 
 
 Tlife = Tlife + life
 TmeanOH = TmeanOH + meanOH
 
 print, meanOH/1.e5, life, i

 printf,jlun,life, meanOH, i+1, ' Month'
; printf,jlun,total(Tmair),total(Tloss),total(Tkdm)

 end
  print, Tlife/itime, TmeanOH/itime, ' Added mean lifetime'
  print, total(Tmair)/total(Tloss)*dStY, total(Tloss)/total(Tkdm)*1.e-5
  printf, jlun, total(Tmair)/total(Tloss)*dStY, total(Tloss)/total(Tkdm)*1.e-5


  free_lun,ilun
  free_lun,jlun
 
 end
