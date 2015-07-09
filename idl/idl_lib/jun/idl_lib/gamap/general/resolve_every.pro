; $Id: resolve_every.pro,v 1.1.1.1 2007/07/17 20:41:41 bmy Exp $
;-----------------------------------------------------------------------
; Copyright (c) 1995-1997, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;+
; NAME:
;	RESOLVE_EVERY
;
;
; PURPOSE:
;	Resolve (by compiling) all procedures and functions.
;	This is useful when preparing .sav files containing all the IDL
;	routines required for an application.
;
; CATEGORY:
;       General
;
; CALLING SEQUENCE:
;	RESOLVE_EVERY
;
; INPUTS:
;	None.
;
; KEYWORD PARAMETERS:
;	QUIET = if set, produce no messages.
; 	SKIP_ROUTINES = an optional string array containing the names
; 	    of routines to NOT resolve.  This is useful when a library
; 	    file containing the designated routines will be later included.
;
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;       None
;
; RESTRICTIONS:
;	Will not resolve procedures or functions that are called via
;	CALL_PROCEDURE, CALL_FUNCTION, or EXECUTE.  Only explicit calls
;	are resolved.
;
;	If an unresolved procedure or function is not in the IDL 
;	search path, an error occurs, and no additional routines
;	are resolved.
;
; PROCEDURE:
;	This routine iteratively determines the names of unresolved calls
;	to user-written or library procedures and functions, and then
;	compiles them.  The process stops when there are no unresolved
;	routines.
;
; EXAMPLE:
;	RESOLVE_EVERY.
;
; MODIFICATION HISTORY:
; 	Written by:
;	DMS, RSI, January, 1995.
;	DMS, RSI, April, 1997, Added SKIP_ROUTINES keyword.
;       mgs, Harvard, 21 Apr 1998: use findfile before trying to resolve
;                                  a routine
;       bmy, 28 May 2004: TOOLS VERSION 2.02 
;                          - Now use MFINDFILE which will call FILE_SEARCH
;                            for IDL 5.5+ or FINDFILE for IDL 5.4-
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1995-1997, RSI.
; Copyright (C) 1997-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine resolve_every"
;-----------------------------------------------------------------------

PRO resolve_every, QUIET = quiet, SKIP_ROUTINES = skip_routines

   FORWARD_FUNCTION MFindFile

   if n_elements(quiet) ne 0 then begin
      quiet_save=!quiet
      !quiet = quiet
   endif else quiet = 0

   if n_elements(skip_routines) gt 0 then skipr = strupcase(skip_routines)

   repeat begin
      cnt = 0
      a = ROUTINE_INFO(/UNRESOLVED)
      if n_elements(skip_routines) gt 0 then begin
         j = 0L
         for i=0, n_elements(a)-1 do if total(a(i) eq skipr) eq 0 then begin
            a[j] = a[i]
            j = j + 1
         endif
         if j gt 0 then a = a(0:j-1) else a = ''
      endif
      if strlen(a(0)) gt 0 then begin
         cnt = cnt + n_elements(a)
         print,'resolving routines: ',a
         for nn=0,n_elements(a)-1 do begin
            
           ; Now use MFINDFILE which will call FILE_SEARCH for 
           ; IDL 5.5+ or FINDFILE for IDL 5.4- (bmy, 5/28/04)
            thisone = Mfindfile(strlowcase(a(nn)))
            print,thisone
            if (thisone(0) eq '') then $
               print,'** Cannot find routine '+thisone+' ! **'  $
            else begin
               if quiet eq 0 then print,'Resolving procedure ', thisone
               resolve_routine, a(nn)
            endelse
         endfor
      endif
      
      a = ROUTINE_INFO(/FUNCTIONS, /UNRESOLVED)
      if n_elements(skip_routines) gt 0 then begin
         j = 0L
         for i=0, n_elements(a)-1 do if total(a(i) eq skipr) eq 0 then begin
            a[j] = a[i]
            j = j + 1
         endif
         if j gt 0 then a = a(0:j-1) else a = ''
      endif
      if strlen(a[0]) gt 0 then begin
         cnt = cnt + n_elements(a)
         for nn=0,n_elements(a)-1 do begin
            
           ; Now use MFINDFILE which will call FILE_SEARCH for 
           ; IDL 5.5+ or FINDFILE for IDL 5.4- (bmy, 5/28/04)
           thisone = MFindFile(strlowcase(a(nn))+'.pro')
           help,thisone

           if (thisone(0) eq '') then $
              print,'** Cannot find function '+a(nn)+' ! **'  $
           else begin
              if quiet eq 0 then print,'Resolving function: ', thisone(0)
              resolve_routine, thisone(0), /IS_FUNCTION
           endelse
        endfor
     endif
  endrep until cnt le 0
  
  if n_elements(quiet_save) ne 0 then !quiet = quiet_save
end
