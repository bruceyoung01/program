; $Id: ussa_temp.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        USSA_TEMP (function)
;
; PURPOSE:
;        return the temperature for a given altitude corresponding
;        to the US Standard Atmosphere
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        temp = USSA_TEMP(altitude)
;
; INPUTS:
;        ALTITUDE -> a floating point value, variable or vector
;            for which temperatures shall be returned. Altitude must lie
;            in the range of 0-50 km.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;            A temperature value or vector [in K]
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;            The function evaluates a 6th order polynomial which had
;            been fitted to USSA data from 0-50 km. Accuracy is on the
;            order of 2 K below 8 km, and 5 K from 8-50 km. Note that
;            this is less than the actual variation in atmospheric 
;            temperatures.
;
;            USSA_TEMP was designed to assign a temperature value to 
;            CTM grid boxes in order to allow conversion from mixing 
;            ratios to concentrations and vice versa.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 16 May 1998: VERSION 1.00
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
; with subject "IDL routine ussa_temp"
;-------------------------------------------------------------


function ussa_temp,altitude
 
    on_error,2
 
 
    ; fit coefficients for 6 deg polynomial
    coeff = [  2.88283E+02,-5.20534E+00,-6.75992E-01, 8.75339E-02, $
              -3.62036E-03, 6.57752E-05,-4.43960E-07  ]
 
 
    ; test validity of argument
    ind = where(altitude gt 50)
    if ind(0) ge 0 then $
       print,'** USSA_TEMP: altitude > 50 km produces bad results!'
 
 
    ; evaluate function
    y = poly(altitude,coeff)
 
    return,y
 
end
 
