; $Id: ussa_press.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        USSA_PRESS (function)
;
; PURPOSE:
;        Return the pressure for a given altitude corresponding
;        to the US Standard Atmosphere
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = USSA_PRESS( ALTITUDE )
;
; INPUTS:
;        ALTITUDE -> a floating point value, variable or vector
;            for which temperatures shall be returned. 
;            Altitude must lie in the range of 0-50 km.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> A pressure value or vector [in mbar]
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The function evaluates a 5th order polynomial which had
;        been fitted to USSA data from 0-100 km. Accuracy is on the
;        order of 0.5% below 30 km, and 1% above. 
;
; EXAMPLE:
;        PRINT, USSA_PRESS( [ 0, 10, 20, 30 ] )
;          998.965   264.659   55.2812   11.9484
;
;            ; Returns pressures corresponding to 0, 10, 20,
;            ; and 30 km, as based on the US Std Atmosphere
;
; MODIFICATION HISTORY:
;        mgs, 23 May 1998: VERSION 1.00
;            (designed from USSA_TEMP.PRO)
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine ussa_press"
;-------------------------------------------------------------


function ussa_press, altitude
 
    on_error,2
 
 
    ; fit coefficients for 6 deg polynomial
    coeff = [   2.99955e+00,-4.61994e-02,-1.55620e-03, 4.57018e-05,  $
                -5.14580e-07, 1.94170e-09 ]
 
 
    ; test validity of argument
    ind = where(altitude gt 100)
    if ind(0) ge 0 then $
       print,'** USSA_PRESS: altitude > 100 km produces bad results!'
 
 
    ; evaluate function
    y = 10^(poly(altitude,coeff))
 
    return,y
 
end
 
