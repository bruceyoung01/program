;-------------------------------------------------------------
;+
; NAME:
;        ISALGEBRAIC (function)
;
; PURPOSE:
;        Locates the position of algebraic characters in a string
;        (e.g. locations that are EITHER digits '.' OR +/- signs).
;
; CATEGORY:
;        String Utilities
;
; CALLING SEQUENCE:
;        Result = ISALGEBRAIC( S [, Keywords ] )
;
; INPUTS:
;        S -> The string to be tested.  
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        Result -> The value of the function.  RESULT is an index array
;            (integer) that contains as many elements as S has 
;            characters.  If S is a single character, then RESULT will 
;            be scalar. Where RESULT = 1, the corresponding characters 
;            in S are algebraic.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        print, ISALGEBRAIC( '-100;+100' )
;            ; prints 1 1 1 1 0 1 1 1 1 
;
; MODIFICATION HISTORY:
;        bmy, 17 Nov 1998: VERSION 1.00
;        mgs, 17 Nov 1998: - removed INVERT keyword. It's simply 1-isalgebraic
;                          - added test for '.'
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
; with subject "IDL routine isdigit"
;-------------------------------------------------------------


function IsAlgebraic, S
 
   ; Byte representation of CHAR...take the first character only
   B = Byte( S )
   
   ; Initialize the result array
   Res = IntArr( N_Elements( B ) )

   ; Check to see if B corresponds to a digit
   Ind = where( ( B ge ( Byte( '0' ) )[0]   AND $
                  B le ( Byte( '9' ) )[0] ) OR  $
                ( B eq ( Byte( '+' ) )[0]   OR  $   
                  B eq ( Byte( '-' ) )[0]   OR  $
                  B eq ( Byte( '.' ) )[0] ) ) 

   ; For each element of B that is a digit
   ; set the corresponding element of RES = 1
   if ( Ind(0) ge 0 ) then Res[Ind] = 1

   ; Return the RESULT array 
   ; (or just the first element if S is one character)
   if ( N_Elements( Res ) gt 1 ) then return, Res else return, Res[0]

end
