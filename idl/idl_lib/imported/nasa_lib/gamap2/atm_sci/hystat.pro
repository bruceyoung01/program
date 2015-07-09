; $Id: hystat.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        HYSTAT (function)
;
; PURPOSE:
;        Compute atmospheric pressures in hydrostatic equilibrium.
;        This function is adapted from the Harvard photochemical
;        point model (CHEM1D).
;
; CATEGORY:
;        Atmospheric Sciences 
;
; CALLING SEQUENCE:
;        pressure = HYSTAT,alt,temp,psurf,g0,rearth
;
; INPUTS:
;        ALT -> Altitude in km. This can be a single value or an array.
;
;        TEMP -> Temperatures corresponding to the altitudes in ALT
;
;        PSURF -> A surface pressure value in mbar. Default is 1013.25 mbar.
;
;        G0 -> acceleration du eto gravity in m/s2. Default is 9.80665 m/s2 .
;
;        REARTH -> Radius of the earth in km. Default is 6356.77 km.
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        ALT = FINDGEN(20)               ; create altitude array 0..19 km
;        TEMP = TEMP = 205.+(19-ALT)*4.  ; a semi-realistic temperature 
;                                        ; profile
;        PRESS = HYSTAT(ALT,TEMP)        ; compute pressures
;        PRINT, PRESS
;
;           1013.25   896.496   791.815   698.104   614.349   
;           539.613   473.041   413.843   361.298   314.745   
;           273.581   237.254   205.261   177.146   152.492   
;           130.924   112.098   95.7080   81.4736   69.1443
;
; MODIFICATION HISTORY:
;        mgs, 21 Aug 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments
;
;-
; Copyright (C) 1998-2007, Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine hystat"
;-----------------------------------------------------------------------


function hystat,alt,temp,psurf,g0,rearth
 
    ; calculate pressures for atmosphere in hydrostatic
    ; equilibrium
    ; NOTE: altitude is expected in km  
 

    if (n_params() lt 2) then begin
       print,'*** HYSTAT: Need at least ALTIUDES and TEMPERATURES!'
       return,-1L
    endif

    ; Reference accelartion due to gravity
    gref = 9.80665    ; m/s2

    ; Set defaults
    if (n_elements(psurf) eq 0) then psurf = 1013.25
    if (n_elements(g0) eq 0) then g0 = gref
    if (n_elements(rearth) eq 0) then rearth = 6356.77

 
    ; initialize pressure array 
    press = 0.*alt
 
 
    ; scale height = H = RT/GM
    ; R = gas constant, M=molar weight of air
 
    ; cstat0 = GM/R
    cstat0 = 3.416E-4*(g0/gref)
 
    cplog0 = 0.5*cstat0
 
    ; loop through altitudes
    for i = 0,n_elements(alt)-1 do begin
        ; cplog1 corrects g for increasing altitude
        cplog1 = 0.5*cstat0*(rearth/(rearth+alt(i)))^2
 
        ; dlogp is -dz/H
        if (i eq 0) then begin
           dlogp = (cplog0/temp(0)+cplog1/temp(0))*1.0E5*(-(alt(0)) )
           press(0) = psurf*exp(dlogp)
        endif else begin
           dlogp = (cplog0/temp(i-1)+cplog1/temp(i))*1.0E5*(alt(i-1)-alt(i))
           press(i) = press(i-1)*exp(dlogp)
        endelse
 
        cplog0 = cplog1
    endfor
 
    return,press
 
end
 
