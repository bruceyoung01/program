; $Id: isgraph.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ISGRAPH (function)
;
; PURPOSE:
;        IDL analog to the 'isgraph' routine in C.  Locates all
;        graphics characters in a string.
;
; CATEGORY:
;        Strings
;
; CALLING SEQUENCE:
;        RESULT = ISGRAPH( S ) 
;
; INPUTS:
;        S  -> The string to be tested.  
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> The value of the function.  RESULT is an index array
;                  that contains as many elements as S has characters. 
;                  If S is a single character, then RESULT will be scalar.
;                  Where RESULT = 1, the corresponding characters in S
;                  are graphics characters.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;
; NOTES:
;        Graphics characters are printing characters (i.e. they can be
;        seen on the screen or on a printout) but EXCLUDE the 
;        space ( ' ' ) character.
;
; EXAMPLE:
;        print, isgraph( 'ABCD !#~%' )
;          1 1 1 1 0 1 1 1 1
;
;        print, isgraph( string( 9B ) )  ; horizontal tab
;          0
;
; MODIFICATION HISTORY:
;        bmy, 01 Jun 1998: VERSION 1.00
;        bmy, 02 Jun 1998  - now use BYTE function in where statement
;                            instead of hardwired constants
;        bmy, 02 Jun 1998  VERSION 1.10
;                          - now can analyze an entire string
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
; or phs@io.as.harvard.edu with subject "IDL routine isgraph"
;-----------------------------------------------------------------------


function IsGraph, S
 
   ; Error checking
   on_error, 2

   ; Byte representation of CHAR
   B = byte( S )

   ; Initialize the result array
   NB  = n_elements( B )
   Res = intarr( NB )
   
   ; ASCII Graphics Characters (i.e. the printing characters 
   ; as defined in ISPRINT excluding space) extend from
   ; the '!' character to the '~' character
   Ind = where( B ge ( byte( '!' ) )[0] and $
                B le ( byte( '~' ) )[0] )

   ; For each element of B that is a graphics character
   ; set the corresponding element of RES = 1.
   if ( Ind(0) ge 0 ) then Res[Ind] = 1

   ; Return the RESULT array 
   ; (or just the first element if S is one character)
   if ( NB gt 1 ) then return, Res else return, Res[0]
end

