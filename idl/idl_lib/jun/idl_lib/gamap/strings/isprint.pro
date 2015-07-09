; $Id: isprint.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ISPRINT (function)
;
; PURPOSE:
;        IDL analog to the 'isprint' routine in C.  Returns 1 if
;        a character is a printable character (including space).
;
; CATEGORY:
;        Strings
;
; CALLING SEQUENCE:
;        RESULT = ISPRINT( S )
;
; INPUTS:
;        S -> The string to be tested.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> The value of the function.  RESULT is an index array
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
;          1 1 1 1 0
;
;        print, isprint( string( 9B ) )  ; horizontal tab
;          0
;
; MODIFICATION HISTORY:
;        bmy, 01 Jun 1998: VERSION 1.00
;        bmy, 02 Jun 1998  - now use BYTE function in where statement
;                            instead of hardwired constants
;        bmy, 02 Jun 1998: VERSION 1.10
;                          - now uses ISGRAPH
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
; or phs@io.as.harvard.edu with subject "IDL routine isprint"
;-----------------------------------------------------------------------


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
