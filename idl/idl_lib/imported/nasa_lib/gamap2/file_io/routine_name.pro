; $Id: routine_name.pro,v 1.1.1.1 2007/07/17 20:41:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ROUTINE_NAME  (function)
;
; PURPOSE:
;        return the name of the routine which calls this function.
;
; CATEGORY
;        File & I/O
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
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        From the command line:
;             PRINT, ROUTINE_NAME()
;        results in   $main$
;
;        Very useful in conjunction with USAGE.PRO:
;             USAGE, ROUTINE_NAME()
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
; or phs@io.as.harvard.edu with subject "IDL routine ";
;-----------------------------------------------------------------------


function routine_name,filename=filename,caller=caller

   ; extract the name of the current routine from the caller stack
   ; the first element will always be ROUTINE_NAME ;-)
   help,call=c

   caller = keyword_set(caller)
   i = 1 + caller
   if (i ge n_elements(c)) then return,'No caller for $MAIN$'

   thisroutine = StrBreak( strcompress( c(i) ), " " )

   if (n_elements(thisroutine) gt 1) then filename = thisroutine(1) $
   else filename = ''

   ; cut < and ( brackets from filename info
   len = strlen(filename)
   filename = strmid(filename,1,len-2)

   return,strlowcase(thisroutine(0))
end

