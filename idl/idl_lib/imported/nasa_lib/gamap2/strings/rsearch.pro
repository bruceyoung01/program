; $Id: rsearch.pro,v 1.1.1.1 2007/07/17 20:41:48 bmy Exp $
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
;        Strings
;
; CALLING SEQUENCE:
;        RESULT = RSEARCH( STR, PATTERN )
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
;        RESULT -> Character index where PATTERN is found in STR
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
;        STR = "This is a test: Hello!"
;        PRINT, RSEARCH( STR, 'test:' )
;          10
;             ; Location where PATTERN is found in STR
;
; MODIFICATION HISTORY:
;        bmy, 17 Jan 2002: TOOLS VERSION 1.50
;        bmy, 14 Apr 2005: TOOLS VERSION 2.04
;                          - Now uses CALL_FUNCTION to call STRPOS
;                            and RSTRPOS so as to avoid bugs at
;                            compile-time 
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2002-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine rsearch"
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
      Result = Call_Function( 'strpos', Str,  Pattern, /Reverse_Search )

   endif else begin

      ; For IDL versions 5.2 and lower, we can use the
      ; RSTRPOS command that ships w/ core IDL
      Result = Call_Function( 'rstrpos', Str,  Pattern )

   endelse

   ; Return to calling program
   return, Result
end 
