; $Id: isalnum.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        ISALNUM (function)
;
; PURPOSE:
;        IDL analog to the 'isalnum' routine in C.  Locates 
;        alphanumeric characters ( A...Z, a...z, 0..9 ) in a string.
;
; CATEGORY:
;        String Utilities
;
; CALLING SEQUENCE:
;        Result = ISALNUM( S )
;
; INPUTS:
;        S  -> The string to be tested.  
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        Result -> The value of the function.  RESULT is an index array
;                  that contains as many elements as S has characters. 
;                  If S is a single character, then RESULT will be scalar.
;                  Where RESULT = 1, the corresponding characters in S
;                  are alphanumeric
;
; SUBROUTINES:
;        ISALPHA (function)
;        ISDIGIT (function)
;
; REQUIREMENTS:
;
; NOTES:
;        None
;
; EXAMPLE:
;        print, isalnum( 'ABCD0123#' )
;            ; prints, 1 1 1 1 1 1 1 1 0
;
;        print, isalnum( '#' )
;            ; prints 0
;
; MODIFICATION HISTORY:
;        bmy, 01 Jun 1998: VERSION 1.00
;        bmy, 02 Jun 1998  - now use BYTE function in where statement
;                            instead of hardwired constants
;        bmy, 02 Jun 1998  VERSION 1.10
;                          - now uses ISALPHA and ISDIGIT
;
;-
; Copyright (C) 1998, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine isalnum"
;-------------------------------------------------------------


function IsAlNum, S
 
   ; Pass external functions
   FORWARD_FUNCTION IsAlpha, IsDigit

   ; Error checking
   on_error, 2

   ; Use functions ISALPHA and ISDIGIT to test for
   ; either alphabetic or numeric characters
   return, IsAlpha( S ) + IsDigit( S )

end
