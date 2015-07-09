; $Id: numden.pro,v 1.1 2007/07/30 15:03:57 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        NUMDEN
;
; PURPOSE:
;        Calculates the number density of air for a given temperature 
;        and pressure.
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = NUMDEN( T, P, /DOUBLE )
;
; INPUTS:
;        T -> Temperature (or vector of temperatures) in K.
;
;        P -> Pressure (or vector of pressures) in hPa.  
;             Default is 1000 hPa.
;
; KEYWORD PARAMETERS:
;        /DOUBLE -> Set this switch to return the number density
;             in double precision.  Default is to return the number
;             density in single precision.
;
; OUTPUTS:
;        RESULT -> Number density of air in molec/cm3.  If T and 
;             P are vectors, then RESULT will be a vector of
;             number densities
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
; EXAMPLES:
;        (1)
;        PRINT, NUMDEN( 298.0, 1013.0 )
;          2.46206e+19
;
;             ; Prints the number density of air 
;             ; at 298K and 1013 hPa.
;         
;        (2)
;        PRINT, NUMDEN( 298.0, 1013.0, /DOUBLE )
;          2.4620635e+19
;
;             ; Prints the number density of air ; at 298K and 
;             ; 1013 hPa.  Computation is done in double precision.
;
;
; MODIFICATION HISTORY:
;        dbm, 30 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2007, Dylan Millet,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine numden"
;-----------------------------------------------------------------------


function NumDen, T, P, Double=Double
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Return to caller if error
   On_Error, 2
 
   ; Check that T is passed
   if ( N_Elements( T ) eq 0 ) then begin
      Message,  'Must supply T!', /Info
      return, -1
   endif
 
   ; Check if P is passed (if not set default)
   if ( N_Elements( P ) eq 0 ) then begin
      print, 'No pressure provided; using 1000 hPa'
      P = 1000d0
   endif

   ; Check that input temperature is in Kelvin 
   if ( min( T, /NaN ) lt 150. ) then begin 
      Message, 'T must be in Kelvin!', /Info
      return, -1
   endif
 
   ; Make sure T and P have the same # of elements
   if ( N_Elements( T ) ne N_Elements( P ) ) then begin
      Message, 'T and P must have the same number of elements!', /Info
      return, -1
   endif
 
   ;====================================================================
   ; Computation
   ;====================================================================

   ; Compute number density of air (in double precision)
   NAir = ( P / 10d0 ) / ( 8.314472d0 * T ) * 6.022d23 / 1000d0
   
   ; Return number density
   if ( Keyword_Set( Double ) )  $
      then return, NAir          $
      else return, Float( NAir )
 
end
	
