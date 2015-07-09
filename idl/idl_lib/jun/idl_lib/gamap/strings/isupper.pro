; $Id: isupper.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ISUPPER (function)
;
; PURPOSE:
;        IDL analog to the 'isupper' routine in C.  Locates all 
;        uppercase alphabetic characters in a string.
;
; CATEGORY:
;        Strings
;
; CALLING SEQUENCE:
;        RESULT = ISUPPER( S )
;
; INPUTS:
;        S  -> The string to be tested
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> The value of the function.  RESULT is an index array
;                  that contains as many elements as S has characters. 
;                  If S is a single character, then RESULT will be scalar.
;                  Uppercase alphabetic characters in S are thus
;                  denoted by the condition ( RESULT eq 1 ).
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Assumes that the ASCII character set is the character set
;        installed on the system.  The byte values will be different
;        for other character sets such as EBSDIC.  
;
; NOTES:
;        None
;
; EXAMPLE:
;        PRINT, ISUPPER( 'ABCDEFg' )
;          1  1  1  1  1  1  0
;
;        PRINT, ISUPPER( 'a' )
;          0
;
; MODIFICATION HISTORY:
;        bmy, 01 Jun 1998: VERSION 1.00
;        bmy, 02 Jun 1998: VERSION 1.10
;                          - now can analyze entire strings
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
; or phs@io.as.harvard.edu with subject "IDL routine isupper"
;-----------------------------------------------------------------------


function IsUpper, S
 
   ; Error checking
   on_error, 2

   ; Byte representation of CHAR...take the first character
   B = byte( S )

   ; Initialize the result array
   NB  = n_elements( B )
   Res = intarr( NB )

   ; Locations of B that correspond to uppercase alphabetic characters
   Ind = where( B ge ( byte( 'A' ) )[0] and $
                B le ( byte( 'Z' ) )[0] )

   ; For each element of B that is a letter, set the
   ; corresponding element of RES = 1
   if ( Ind(0) ge 0 ) then Res[Ind] =  1 

   ; If 
   if ( NB gt 1 ) then return, Res else return, Res[0]

end
