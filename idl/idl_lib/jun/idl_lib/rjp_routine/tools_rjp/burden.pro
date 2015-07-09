function burden, file, ilmm=ilmm, ijmm=ijmm, ikmm=ikmm, ncon=ncon, $
 psf=psf, imon=imon

;+
; NAME:
;   burden
;
; PURPOSE:
;   return the gas conc burden 
;
;if n_elements(ilmm) eq 0 then ilmm = 72
;if n_elements(ijmm) eq 0 then ijmm = 46
;if n_elements(ikmm) eq 0 then ikmm = 20
;if n_elements(ncon) eq 0 then ncon = 52
;if n_elements(time) eq 0 then time = 122
;if n_elements(file) eq 0 then file = pickfile()
;-

if n_elements(ilmm) eq 0 then ilmm = 72
if n_elements(ijmm) eq 0 then ijmm = 46
if n_elements(ikmm) eq 0 then ikmm = 20
if n_elements(ncon) eq 0 then ncon = 52
if n_elements(imon) eq 0 then imon = 1
if n_elements(file) eq 0 then file = pickfile()

case imon of
1 : time = 122
2 : time = 28*4
4 : time = 30*4
6 : time = 30*4
else : time = 31*4
end

G0 = 9.80665

PRESS = FLTARR(ILMM,IJMM,IKMM) & TEMP = PRESS & AIRD = PRESS
HEADER = FLTARR(2)
CONC = FLTARR(ILMM,IJMM,IKMM,NCON)
OUT = FLTARR(TIME,NCON+1)

;OPENR,ILUN,FILE,/F77,/SWAP_ENDIAN,/GET_LUN
 OPENR,ILUN,FILE,/XDR,/GET_LUN
ico = spec('co',ncon=ncon) & io3 = spec('o3',ncon=ncon) & ioh = spec('oh',ncon=ncon)

for i=0, time-1 do begin

 READU, ILUN, HEADER, PRESS
 READU, ILUN, HEADER, TEMP
 READU, ILUN, HEADER, AIRD
 READU, ILUN, HEADER, CONC
 print, header

 dp = gridinv(ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,press=press,mass=mass,mcor=mcor,psf=psf)

; Z = 16.*alog10(1000./press)
; G = G0*(6356766./(6356766.+Z))^2

 for n=0, ncon-1 do begin
   out(i,n) = total(total(100.*(conc(*,*,*,n)/aird)*dp/G0,3)*mcor)/1.e9 ; in Tg
 end
   out(i,ncon) = total(mass)/1.e9

  print, i, out(i,ico), out(i,io3), out(i,ioh), total(mass)/1.e9
end

FREE_LUN, ILUN

OPENW,ILUN,'BURDEN.DAT', /GET
WRITEU,ILUN, FLOAT(TIME), FLOAT(NCON+1)
WRITEU,ILUN, OUT
FREE_LUN,ILUN

 gas  = ['NO','NO2','NO3','N2O5','HONO','HNO3','HO2NO2', $
        'O3','H2O2','CO','C2H6','C3H8','HCHO','CH3CHO', $
        'CH3O','CH3O2','CH3ONO2','CH3O2NO2','C2H5O2',     $
        'C2H5O2NO2','C3H7O2','CH3COCH3','CH3COCH2O2',  $
        'C2H4','C3H6','H2COO','CH3HCOO','CH3OOH','HOC2H4O2',$
        'HOC3H6O2','CH3CO3','CH3CO3NO2','CH3COCHO',     $
        'ISOP','ISOH','MACR','MVK','MV1','MV2','MAC1',  $
        'MAC2','MPAN','CH2CCH3CO3','ISNT','ISNI1','ISNI2', $
        'ISNIR','IPRX','OH','H2O','HO2','CH4','AIR']      

plotburden, out=out, imon=imon, gas=gas, graph='ps'

return, out
end
