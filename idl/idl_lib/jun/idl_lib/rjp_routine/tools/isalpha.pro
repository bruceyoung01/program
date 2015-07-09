; $Id: isalpha.pro,v 1.1.1.1 2003/10/22 18:09:41 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        ISALPHA (function)
;
; PURPOSE:
;        IDL analog to the 'isalpha' routine in C.  Locates the
;        positions of alphabetic characters ( A...Z, a...z ).
;
; CATEGORY:
;        String Utilities
;
; CALLING SEQUENCE:
;        Result = ISALPHA( S )
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
;                  are alphabetic.
;        
; SUBROUTINES:
;        ISUPPER (function)
;        ISLOWER (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        print, isalpha( 'ABcd0123' )
;            ; prints, 1 1 1 1 0 0 0 0
;
;        print, isalpha( '#' )
;            ; prints 0
;
; MODIFICATION HISTORY:
;        bmy, 29 May 1998: VERSION 1.00
;        bmy, 01 Jun 1998: - now returns 0 for condition FALSE
;                          - fixed bug that allowed byte values from
;                            91-96 to be treated as letters
;        bmy, 02 Jun 1998  - now use BYTE function in where statement
;                            instead of hardwired constants
;        bmy, 02 Jun 1998  VERSION 1.10
;                          - now uses ISUPPER and ISLOWER 
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
; with subject "IDL routine isalpha"
;-------------------------------------------------------------


function IsAlpha, S
 
   ; Pass external functions
   FORWARD_FUNCTION IsUpper, IsLower

   ; Error checking
   on_error, 2

   ; Use functions ISUPPER and ISLOWER to test for
   ; either uppercase or lowercase alphabetic characters
   return, IsUpper( S ) + IsLower( S )
 
end
