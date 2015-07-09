; $Id: airdens.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        AIRDENS (function)
;
; PURPOSE:
;        Compute air mass density for a given pressure and 
;        temperature. If the temperature is not provided, a
;        temperature is estimated using the US Standard atmosphere.
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        idens = AIRDENS(p [,T])
;
; INPUTS:
;        P  -> pressure in hPa (mbar)
;
;        T  -> temperature in K
;
; KEYWORD PARAMETERS:
;        HELP -> print help information
;
; OUTPUTS:
;        The air mass density in molec/cm^3. The result type will 
;        match the type and array dimensions of p unless p is a 
;        scalar and T an array.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===========================================
;        USSA_ALT (function)   USSA_TEMP (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLES:
;        (1) 
;        PRINT, AIRDENS( 1013.25, 273.15 )
;           2.69000e+19
; 
;             ; Prints air density at std temperature & pressure
;
;        (2)
;        P = FINDGEN(5)*100+500
;        PRINT,AIRDENS(P,T)     ; T undefined !
;           1.44840e+19  1.67414e+19  1.89029e+19  2.10104e+19  2.30998e+19
;        PRINT, T
;           250.334      259.894      268.538      276.117      282.534
;
;             ; Prints air density w/ undefined temperature
;             ; Temperature profile from the US Std atmosphere
;             ; will be returned.
;
;        (3)
;        PRINT,AIRDENS(800.,T)  ; T from previous calculation
;           2.31744e+19  2.23218e+19  2.16033e+19  2.10104e+19  2.05332e+19
;
;             ; Use T from previous example and print
;             ; air density at 800 hPa
;
; MODIFICATION HISTORY:
;        mgs, 12 Nov 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.as.harvard.edu with subject "IDL routine airdens";
;-----------------------------------------------------------------------


function AirDens, P, T, Help=Help
 
   if (n_params() lt 1 OR keyword_set(help)) then begin
      print,' FUNCTION AIRDENS : compute air mass density'
      print
      print,' usage : dens = airdens(p,T)'
      print,'   p : pressure in hPa (mbar)'
      print,'   T : temperature in K'
      print,' If no temperature is provided, airdens will print a warning'
      print,' and use the US standard atmosphere to estimate a temperature.'
      return,0
   endif

   ; create result depending on dimensions of p,T
   result = make_array(size=size([p]),value=-999.)
   if (n_elements(p) eq 1 AND n_elements(T) gt 1) then  $
      result = make_array(size=size(T),value=-999.)

   ; get default temperatures from US standard atmosphere 
   if (n_elements(T) eq 0) then begin
      message,'No temperatures given. Will use US standard atmosphere ..', $
         /INFO
      T = ussa_temp( ussa_alt( p ) )
      if (n_elements(T) eq 1) then print,'computed T = ',T
   endif

    ; compute dens only for valid values of p and T 
   okind = where( T gt 0. AND p gt 0.)
   result[okind] = 2.69e19 * (273.15/T[okind]) * (p[okind]/1013.25)
 
    ; convert vector to scalar if only on element 
   if (n_elements(result) eq 1) then result = result[0]
 
   return,result
 
end
