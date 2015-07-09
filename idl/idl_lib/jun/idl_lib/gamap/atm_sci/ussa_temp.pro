; $Id: ussa_temp.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        USSA_TEMP (function)
;
; PURPOSE:
;        Return the temperature for a given altitude corresponding
;        to the US Standard Atmosphere
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = USSA_TEMP( ALTITUDE )
;
; INPUTS:
;        ALTITUDE -> a floating point value, variable or vector
;            for which temperatures shall be returned. Altitude must lie
;            in the range of 0-50 km.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        RESULT -> A temperature value or vector [in K]
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The function evaluates a 6th order polynomial which had
;        been fitted to USSA data from 0-50 km. Accuracy is on the
;        order of 2 K below 8 km, and 5 K from 8-50 km. Note that
;        this is less than the actual variation in atmospheric 
;        temperatures.
;
;        USSA_TEMP was designed to assign a temperature value to 
;        CTM grid boxes in order to allow conversion from mixing 
;        ratios to concentrations and vice versa.
;
; EXAMPLE:
;        PRINT, USSA_TEMP( [ 0, 10, 20, 30 ] )
;          288.283  226.094  216.860  229.344
;
;             ; Returns the temperature [K] at 0, 10, 20, 30 km
;             ; corresponding to the US Standard Atmosphere
;
; MODIFICATION HISTORY:
;        mgs, 16 May 1998: VERSION 1.00
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
; or phs@io.as.harvard.edu with subject "IDL routine ussa_temp"
;-----------------------------------------------------------------------


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
 
