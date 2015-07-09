function rayleigh_MOD,ZB,ZT,WL,Ts = Ts, T_bar = T_bar,method =method
;+
; ROUTINE:  rayleigh_OD
;
; PURPOSE:  compute rayleigh optical depth at a give layer and wavelength
;
; USEAGE:   result=rayleigh(ZB,ZT,WL,Ts = Ts,T_bar = T_bar)
;
; INPUT:    
;   ZB     altitude of layer botoom (km)
;   ZT     altitude of layer top (km)
;   WL     wavelength in microns
; 
; KEYWORD INPUT:
;   Ts       surface temperature in K
;   T_bar    mean air column temperature in K
;
; OUTPUT:   rayleigh optical depth 	1) in whole column
;					2) calculated by method I
;					3) calculated by method II
;
; DISCUSSION:
;
; LIMITATIONS:
;
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;  
; EXAMPLE:  
;
;   wl=[.414,.499,.609,.665,.860,.938]
;   print,rayleigh_MOD(zb,zt,wl,Ts = 288, T_bar = 255)
;
;;  0.311728     0.144443    0.0640821    0.0448406    0.0158600    0.0111786
;
; AUTHOR:   Xiaoguang Xu 			01/15/09
;           Department of Geosciences
;           University of Nebraska-Lincoln
;           xxu@huskers.unl.edu
;
; REVISIONS:
;
;-
;


mair=28.96D0	                         ; atmospheric molecular weight (kg/mol)
R=8.314472D0                             ; gas constant (J/K/mol)
g=9.806D0                                ; m/s/s
LR = 6.5D0				 ; lapse rate in kelvin/km	
 
p0=1013.25D0  		; mb
Ts0=288.15D0   		; kelvin
T_bar0 = 273.15D0	; kelvin

if n_elements(T_bar) eq 0 then T_bar = T_bar0
if n_elements(Ts) eq 0 then Ts=Ts0
;if (ZB gt ZT or ZB lt 0 or ZB lt 0) then begin
;   print,'Input parameters ZB or ZT is not right!'
;endif

; pressure in mb
; altitude in km
;
; tau=C(lambda)*path
;
; Method I:  where path= H*(exp(-z1/H)-exp(-z2/H)) (km)
;                          /
; Method II: where path=  | (p/t)(t0/p0) dz   (km)
;                         /

if n_elements(method) ne 0 then begin 
  ; Method I:
  H = R*T_bar/(mair*g)          ;  scale height in Km
  Path = H*(exp(-1*ZB/H)-exp(-1*ZT/H))
endif else begin
  ; Method II:
  dz = 5D-4  			; infinitesimal of z
  path = 0D0
  path_old = 0D0
  i = 1LL
  while (ZT gt ZB+dz*(i-1)) DO BEGIN
    z = ZB+dz*(i-1)
;    path_old = path + Ts*exp((-1*mair*g*z)/(R*Ts-LR*R*z))*dz/(Ts-LR*z)
    path = path + Ts*alt2press(z*1000.)*dz/P0/alt2temp(z*1000.)
;   print, i, path
    i = i+1LL
  endwhile
endelse

return,Path/(938.07*wl^4-10.8426*wl^2)

end

;+ Other functions 
; Calculate temperature (K) at given altitude (m) 
FUNCTION alt2temp,altitudes

limit=11000.    ; altitude of tropopause
lr=-0.0065      ; lapse rate in troposphere
TB1=288.15      ; ground temp.
TB2=216.65      ; temp at 11 km

strat=altitudes GT 11000
res=strat*TB2+(1-strat)*(TB1+lr*altitudes)

return,res

end

; Calculate pressure (hPa) at given altitude (m)
FUNCTION alt2press,palt

limits=[0,11,20,32,47,51,71.,84.852]*1000.   ; layer boundaries in m
lrs=[-6.5,9,1,2.8,9,-2.8,-2.0]/1000.         ; lapse rates in each layer (9 means 0)
iszero=[0,1,0,0,1,0,0]                       ; flag for isothermal layers

G=9.80665       ; gravity const.
R=287.053       ; gas const. for air
GMR=G/R         ; Hydrostatic constant

; calculate pressures at layer boundaries
pB=FltArr(8)
TB=FltArr(8)
pB[0]=1013.25 ; pressure at surface
TB[0]=288.15  ; Temperature at surface

; loop over layers and get pressures and temperatures at level tops
;print,TB[0],pB[0]
FOR i=0,6 DO BEGIN
   TB[i+1]=TB[i]+(1-iszero[i])*lrs[i]*(limits[i+1]-limits[i])
   pB[i+1]=(1-iszero[i])*pB[i]*exp(alog(TB[i]/TB[i+1])*GMR/lrs[i])+$
      iszero[i]*PB[i]*exp(-GMR*(limits[i+1]-limits[i])/TB[i])
;   print,TB[i+1],pB[i+1]
ENDFOR

; now calculate which layer each value belongs to
layer=IntArr(n_elements(palt))
FOR i=0L,n_elements(palt)-1 DO BEGIN
   index=WHERE( (limits-palt[i]) GT 0)
   layer[i]=index[0]-1
ENDFOR

; return the corresponding pressures
return,iszero[layer]*pB[layer]*exp(-GMR*(palt-limits[layer])/TB[layer])+$
   (1-iszero[layer])*pB[layer]*(TB[layer]/$
   (TB[layer]+lrs[layer]*(palt-limits[layer])))^(GMR/lrs[layer])

END
