; $Id: strbreak.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        STRBREAK
;
; PURPOSE:
;        Wrapper for routines STRSPLIT and STR_SEP.  
;        Needed for backwards compatibility for GAMAP users 
;        who are running versions of IDL prior to 5.2.
;
; CATEGORY:
;        IDL tools
;
; CALLING SEQUENCE:
;        Result = STRBREAK( STR, SEPARATOR, _EXTRA=e )
;
; INPUTS:
;        STR -> The string to be separated.  
;
;        SEPARATOR -> The separating character.
;
; KEYWORD PARAMETERS:
;        None
;           
; OUTPUTS:
;        RESULT = Array of sub-strings, separated by the character 
;             passed as SEPARATOR
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
;        (1)
;        Str    = 'Hello   , My     , Name    , is    ,  Slim ,   Shady  '
;        NewStr = StrBreak( Str, ',' )
;
;             ; Separates the string using the comma as the separator.
;
; MODIFICATION HISTORY:
;        bmy, 17 Jan 2002: TOOLS VERSION 1.50
;        bmy, 17 Jan 2003: TOOLS VERSION 1.52
;                          - now use CALL_FUNCTION to call both STRSPLIT 
;                            and STR_SEP functions for backwards compatibility
;        bmy, 14 Oct 2003: TOOLS VERSION 1.53
;                          - deleted obsolete code
;
;-
; Copyright (C) 2002-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine strbreak"
;-----------------------------------------------------------------------


function StrBreak, Str, Separator

   ;====================================================================
   ; Error check -- make sure arguments are passed
   ;====================================================================
   if ( N_Elements( Str       ) ne 1 ) then Message, 'STR not passed!'
   if ( N_Elements( Separator ) ne 1 ) then Message, 'SEPARATOR not passed!'

   ;====================================================================
   ; Call proper function depending on the IDL version being used
   ;====================================================================
   if ( !VERSION.RELEASE ge 5.3 ) then begin

      ; For IDL versions 5.3 and higher, STR_SEP is obsoleted,
      ; therefore we have to use STRSPLIT instead.
      Result = Call_Function( 'strsplit', Str, Separator, /Extract )

   endif else begin

      ; For IDL versions 5.2 and lower, we can use the
      ; STR_SEP command that ships w/ core IDL
      Result = Call_Function( 'str_sep', Str, Separator )

   endelse

   ; Return to calling program
   return, Result
end
