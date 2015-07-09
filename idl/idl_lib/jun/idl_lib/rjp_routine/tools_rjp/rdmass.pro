pro rdmass, file, time=time, gas=gas, jm1=jm1, tser=tser, burden=burden

if n_elements(file) eq 0 then  file = pickfile()
if n_elements(time) eq 0 then return
if n_elements(time) eq 0 then time = 30*4
if n_elements(jm1) eq 0 then jm1 = 46
if n_elements(gas) eq 0 then gas = 'O3'

; 0 : dry deposition
; 1 : emission
; 2 : grid scale transport
; 3 : chemistry
; 4 : convection
  ispec = spec(gas,ncon=52)

  openr,il,file,/xdr,/get
  
  burden = fltarr(time) & dat = fltarr(52)
  data = fltarr(jm1,52,5)
  tser = fltarr(time,jm1,5)
  
  for it = 0, time-1 do begin
   readu,il,dat,data
   tser(it,*,*) = data(*,ispec,*)
   burden(it) = dat(ispec)
   print, it
  end
  
  free_lun,il
  
  !p.charsize=1.5
 ;!p.position = [0.1,0.1,0.9,0.9]
  !p.multi = [0,1,4]
  
  plot, total(tser(*,*,0),2), line=0, title='Dry Depo.'
;  plot, total(tser(*,*,1),2), line=0,title=
  plot, total(tser(*,*,2),2), line=0,title='Grid scale transport'
  plot, total(tser(*,*,3),2), line=0,title='Chemistry'
  plot, total(tser(*,*,4),2), line=0,title='Convection'
  
  dB = burden(time-1)-burden(0)
  dTd = total(tser(time-1,*,0))
  dTe = total(tser(time-1,*,1))
  dTg = total(tser(time-1,*,2))
  dTc = total(tser(time-1,*,3))
  dTcv = dB - (dTg+dTe+dTc+dTd)

  print, dB,dTe,dTc,dTg,dTd,dTcv,burden(time-1)

; openw,jjl,file+gas ,/get
;  writeu,jjl,tser(*,*,2)
; free_lun,jjl
    
end

  



