; $Id: rsearch.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        RSEARCH
;
; PURPOSE:
;        Wrapper for routines STRPOS and RSTRPOS.  
;        Needed for backwards compatibility for GAMAP users 
;        who are running versions of IDL prior to 5.2.
;
; CATEGORY:
;        IDL tools
;
; CALLING SEQUENCE:
;        Result = RSEARCH( STR, PATTERN )
;
; INPUTS:
;        STR -> The string to be searched.  
;
;        PATTERN -> The pattern to search for in STR.
;
; KEYWORD PARAMETERS:
;        None
;           
; OUTPUTS:
;        RESULT = Character index where PATTERN is found in STR
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
;        (1) STR    = "This is a test: Hello!"
;            RESULT = RSEARCH( STR, 'test:' )
;            PRINT, RESULT
;
;            IDL Prints:
;                  10
; 
;             ; Location where PATTERN is found in STR
;
; MODIFICATION HISTORY:
;        bmy, 17 Jan 2002: TOOLS VERSION 1.50
;
;-
; Copyright (C) 2000, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine rsearch"
;-----------------------------------------------------------------------


function RSearch, Str, Pattern

   ;====================================================================
   ; Error check -- make sure arguments are passed
   ;====================================================================
   if ( N_Elements( Str     ) ne 1 ) then Message, 'STR not passed!'
   if ( N_Elements( Pattern ) ne 1 ) then Message, 'PATTERN not passed!'

   ;====================================================================
   ; Call proper function depending on the IDL version being used
   ;====================================================================
   if ( !VERSION.RELEASE ge 5.3 ) then begin

      ; For IDL versions 5.3 and higher, RSTRPOS is obsoleted,
      ; therefore we have to use STRPOS with /REVERSE_SEARCH.
      Result = StrPos( Str, Pattern, /Reverse_Search )

   endif else begin

      ; For IDL versions 5.2 and lower, we can use the
      ; RSTRPOS command that ships w/ core IDL
      Result = RStrPos( Str, Pattern )

   endelse

   ; Return to calling program
   return, Result
end 
