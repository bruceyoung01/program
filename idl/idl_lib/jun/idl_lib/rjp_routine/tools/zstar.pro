;-------------------------------------------------------------
; $Id: zstar.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $
;+
; NAME:
;        ZSTAR  (function)
;
; PURPOSE:
;        Computes pressure-altitudes from pressures.
;
; CATEGORY:
;        Atmospheric sciences
;
; CALLING SEQUENCE:
;        RESULT = ZSTAR( PRESS )
;
; INPUTS:
;        PRESS -> The input pressure value, in mb.
;             PRESS can be either a scalar or a vector.
;             
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT contains the output pressure-altitudes.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Pressure-altitude is defined as:
;
;            Z* = 16 * log10[ 1000 / P(mb) ]
;
;        which, by the Laws of Logarithms, is equivalent to
;
;            Z* = 48 - ( 16 * log10[ P(mb) ] ).
;
; EXAMPLE:
;        print, zstar( [ 900, 700, 500 ] )
;            0.732121      2.47843      4.81648
;
; MODIFICATION HISTORY:
;        bmy, 21 Jun 1999: VERSION 1.00
;
;-
; Copyright (C) 1999, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine zstar"
;-------------------------------------------------------------


function ZStar, Press
 
   ; Error checking
   if ( N_Elements( Press ) eq 0 ) then begin
      Message, 'Must supply PRESS!', /Continue
      return, -1
   endif

   ; Return pressure-altitudes
   return, 48.0 - ( 16.0 * ALog10( Press ) )
 
end
