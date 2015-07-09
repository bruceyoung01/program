; $Id: isprint.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        ISPRINT (function)
;
; PURPOSE:
;        IDL analog to the 'isprint' routine in C.  Returns 1 if
;        a character is a printable character (including space).
;
; CATEGORY:
;        String Utilities
;
; CALLING SEkQUENCE:
;        Result = ISPRINT( S )
;
; INPUTS:
;        S -> The string to be tested.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        Result -> The value of the function.  RESULT is an index array
;                  that contains as many elements as S has characters. 
;                  If S is a single character, then RESULT will be scalar.
;                  Where RESULT = 1, the corresponding characters in S
;                  are printable.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;
; NOTES:
;        Printing characters can be seen on the screen (these exclude
;        control characters).
;
; EXAMPLE:
;        print, isprint( '!X3d ' )
;            ; prints, 1 1 1 1 0
;
;        print, isprint( string( 9B ) )  ; horizontal tab
;            ; prints 0
;
; MODIFICATION HISTORY:
;        bmy, 01 Jun 1998: VERSION 1.00
;        bmy, 02 Jun 1998  - now use BYTE function in where statement
;                            instead of hardwired constants
;        bmy, 02 Jun 1998: VERSION 1.10
;                          - now uses ISGRAPH
;
;-
; Copyright (C) 1998, Bob Yantosca and Martin Schultz,
; Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or mgs@io.harvard.edu with subject "IDL routine isprint"
;-------------------------------------------------------------


function IsPrint, S 

   ; Pass external functions
   FORWARD_FUNCTION IsGraph

   ; Error checking
   on_error, 2

   ; First locate all the graphics characters
   Res = IsGraph( S ) 
   
   ; Now look for spaces
   B = byte( S )
   Ind = where( B eq ( byte( ' ' ) )[0] ) 

   ; If any spaces are found, then update the RES array
   if ( Ind(0) gt 0 ) then Res[Ind] = 1

   ; return the RES array
   return, Res

end
