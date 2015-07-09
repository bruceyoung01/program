; $Id: ussa_press.pro,v 1.1.1.1 2003/10/22 18:06:03 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        USSA_PRESS (function)
;
; PURPOSE:
;        return the pressure for a given altitude corresponding
;        to the US Standard Atmosphere
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        temp = USSA_PRESS(altitude)
;
; INPUTS:
;        ALTITUDE -> a floating point value, variable or vector
;            for which temperatures shall be returned. Altitude must lie
;            in the range of 0-50 km.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;            A pressure value or vector [in mbar]
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;            The function evaluates a 5th order polynomial which had
;            been fitted to USSA data from 0-100 km. Accuracy is on the
;            order of 0.5% below 30 km, and 1% above. 
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 23 May 1998: VERSION 1.00
;            (designed from USSA_TEMP.PRO)
;
;-
; Copyright (C) 1998, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine ussa_press"
;-------------------------------------------------------------


function ussa_press,altitude
 
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
 
