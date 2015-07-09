;+
; NAME:
;	alt2temp
;
; PURPOSE:
;	Calculate temperature (Kelvin) at a given altitude (m) assuming
;	ICAO standard atmosphere conditions
;	
; CATEGORY:
;	FUNCTION
;
; CALLING SEQUENCE:
;	alt2temp(altitudes)
;
; EXAMPLE:
;	altpress([1000,3000,7000])
;
; INPUTS: 
;	altitudes	flt or fltarr: the altitude(s)
;
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORD INPUT PARAMETERS:
;
; OUTPUTS
;	the temperature(s)
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
;	first implementation Feb, 15 1998 by Dominik Brunner
;-

FUNCTION alt2temp,altitudes

limit=11000.	; altitude of tropopause
lr=-0.0065	; lapse rate in troposphere
TB1=288.15	; ground temp.
TB2=216.65	; temp at 11 km

strat=altitudes GT 11000
res=strat*TB2+(1-strat)*(TB1+lr*altitudes)

return,res

end
