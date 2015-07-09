;+
; NAME:
;	alt2press
;
; PURPOSE:
;	Convert an array of (pressure-) altitudes (m) into an array of 
;       pressures (hPa) using the ICAO standard atmosphere definition
;
;       See <A HREF="http://www.pdas.com/coesa.htm">exact definition
;       here<\A>
;       
;       The 7 layers of the US standard atmosphere are:
;
;        h1   h2     dT/dh    h1,h2 geopotential alt in km
;         0   11     -6.5     dT/dh in K/km
;        11   20      0.0
;        20   32      1.0
;        32   47      2.8
;        47   51      0.0
;        51   71     -2.8   
;        71   84.852 -2.0
;	
; CATEGORY:
;	atmospheric physics, aviation
;
; CALLING SEQUENCE:
;	alt2press(palt)
;
; EXAMPLE:
;	print,alt2press([2000,3000,4000])
;          prints 794.952      701.086      616.402 (hPa)
; 
; INPUTS: 
;	palt	flt or fltarr: the pressure altitudes
;
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORD INPUT PARAMETERS:
;
; OUTPUTS
;	the ressure array (hPa)
;
; COMMON BLOCKS:
;
; SIDE EFFECTS: 
;
; RESTRICTIONS:
;	
; PROCEDURE:
;	
; MODIFICATION HISTORY:
;	first implementation Aug, 1998 by Dominik Brunner
;-
FUNCTION alt2press,palt
   
limits=[0,11,20,32,47,51,71.,84.852]*1000.   ; layer boundaries in m
lrs=[-6.5,9,1,2.8,9,-2.8,-2.0]/1000.         ; lapse rates in each layer (9 means 0)
iszero=[0,1,0,0,1,0,0]                       ; flag for isothermal layers

G=9.80665	; gravity const.
R=287.053	; gas const. for air
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
