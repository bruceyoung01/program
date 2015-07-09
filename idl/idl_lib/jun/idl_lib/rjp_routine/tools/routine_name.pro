; $Id: routine_name.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ROUTINE_NAME  (function)
;
; PURPOSE:
;        return the name of the routine which calls this function.
;
; CATEGORY
;        Tools
;
; CALLING SEQUENCE:
;        rname = ROUTINE_NAME()
;
; INPUTS:
;        none
;
; KEYWORD PARAMETERS:
;        FILENAME -> returns the file in which the routine can be found
;
;        /CALLER -> returns information about the caller of the routine
;           instead of the routine itself
;
; OUTPUTS:
;        The name of the caller routine is returned in lowercase
;        characters (can be used to construct a filename by adding
;        ".pro")
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        From the command line:
;             print,routine_name()
;        results in   $main$
;
;        Very useful in conjunction with USAGE.PRO:
;             usage,routine_name()
;        displays help information on the current routine.
;
; MODIFICATION HISTORY:
;        mgs, 27 Mar 1998: VERSION 1.00
;        mgs, 22 Apr 1998: - added FILENAME and CALLER keywords
;        mgs, 14 Jan 1998: - needed fix for filename when working on PC:
;                            $MAIN$ allows no str_sep
;        bmy, 07 Aug 2002: TOOLS VERSION 1.51
;                          - Now use routine STRBREAK to split the line
;                            instead of STR_SEP.  STR_SEP has been removed
;                            from the IDL distribution in IDL 5.4+.
;
;-
; Copyright (C) 1998, 1999, 2002, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine routine_name"
;-----------------------------------------------------------------------


function routine_name,filename=filename,caller=caller

   ; extract the name of the current routine from the caller stack
   ; the first element will always be ROUTINE_NAME ;-)
   help,call=c

   caller = keyword_set(caller)
   i = 1 + caller
   if (i ge n_elements(c)) then return,'No caller for $MAIN$'

   ;--------------------------------------------------------------------
   ; Prior to 8/7/02: 
   ;thisroutine = str_sep(strcompress(c(i))," ")
   ;--------------------------------------------------------------------
   thisroutine = StrBreak( strcompress( c(i) ), " " )

   if (n_elements(thisroutine) gt 1) then filename = thisroutine(1) $
   else filename = ''

   ; cut < and ( brackets from filename info
   len = strlen(filename)
   filename = strmid(filename,1,len-2)

return,strlowcase(thisroutine(0))
end

