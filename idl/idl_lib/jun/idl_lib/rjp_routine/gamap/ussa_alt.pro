; $Id: ussa_alt.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        USSA_ALT (function)
;
; PURPOSE:
;        return the altitude for a given pressure corresponding
;        to the US Standard Atmosphere.  
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        Alt = USSA_ALT( Pressure )
;
; INPUTS:
;        Pressure -> a floating point value, variable or vector
;            for which temperatures shall be returned.  Pressure must
;            correspond to an altitude of less than 100 km.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;            An altitude value or vector [in km]
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;      Computes approx. altitudes (logp fit to US Standard Atmosphere)
;      tested vs. interpolated values, 5th degree polynomial gives good 
;      results (ca. 1% for 0-100 km, ca. 0.5% below 30 km)
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        bmy, 17 Jun 1998: VERSION 1.00
;               (removed section of code from CTM_GRID.PRO by mgs)
;
;-
; Copyright (C) 1998, 1999, Bob Yantosca and Martin Schultz, 
; Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or mgs@io.harvard.edu with subject "IDL routine ussa_alt"
;-------------------------------------------------------------


function USSA_Alt, Pressure
 
   ; Pass External Function
   FORWARD_FUNCTION USSA_Press

   ; Return to calling program if error
   On_Error,2

   ; Test validity of argument (3e-4 mb corresponds to 100 km)
   Ind = where( Pressure le 3e-4 )
   if ( Ind(0) ge 0 ) then $
      print,'** USSA_PRESS: pressure <  3.0e-4 mb produces bad results!'

   ; Fit coefficients for 5th deg polynomial
   A = [ 48.0926, -17.5703, 0.278656, 0.485718, -0.0493698, -0.0283890 ]

   ; Evaluate the polynomial and return
   Y = poly( alog10( Pressure ), A )
    
   return, Y
 
end
 
