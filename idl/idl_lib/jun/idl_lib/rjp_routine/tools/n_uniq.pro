;-------------------------------------------------------------
;+
; NAME:
;        N_UNIQ (function)
;
; PURPOSE:
;        Returns the number of unique elements in an array.
;
; CATEGORY:
;        Array tools
;
; CALLING SEQUENCE:
;        Result = N_UNIQ( Arr )
;
; INPUTS:
;        ARR -> The array to be searched for unique values.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        Returns the number of unique values in ARR as the value
;        of the function
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
; EXAMPLE:
;        print, N_Uniq( [10, 20, 30] )
;            ; prints 3
;
;        print, N_Uniq( [10,10] )
;            ; prints 1
;
; MODIFICATION HISTORY:
;        bmy, 17 Nov 1998: VERSION 1.00
;        mgs, 17 Nov 1998: - little streamlining
;        mgs, 16 Mar 1999: - don't print out warning for empty argument
;                            and return 0 instead of -1
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
; with subject "IDL routine n_uniq"
;-------------------------------------------------------------


function N_Uniq, Arr
 
   ; Error checking
   if ( N_Elements( Arr ) eq 0 ) then begin
;     Message, 'ARR must be specified!', /Continue
      return, 0 
   endif
   
   ; Compute number of unique values
   ; Use UNIQ with SORT
   Ind = N_Elements( Uniq( Arr, Sort( Arr ) ) )
 
   return, Ind
end
