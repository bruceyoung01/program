; $Id: add_template.pro,v 1.2 2008/04/22 20:40:09 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;       ADD_TEMPLATE
;
; PURPOSE:
;       Add a near standard IDL template to a given IDL routine file.
;   
; CATEGORY:
;       Documentation
;
; CALLING SEQUENCE:
;       ADD_TEMPLATE, FILE
;
; INPUTS:
;       FILE -> Input IDL routine file name.   
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       None
;
; COMMON BLOCKS:
;       None
;
; NOTES:
;       (1) Existing front end, up to the pro or function
;           statement, are replaced by the new template.
;
;       (2) Also see routine IDL2HTML, which converts the IDL
;           doc header text to HTML format.
;
; MODIFICATION HISTORY:
;       written by:
;          R. Sterner, about Sep 1989 at Sac Peak.  The exact date was
;               probably lost by this routine itself.
;       modified:
;          R. Sterner, 13 Dec, 1993 --- dropped spawn to copy files.
;          R. Sterner, 11 Mar, 1993 --- handled no help text case.
;          M. Schultz, 01 Aug, 1997 --- simplified version without
;               analyzing help text
;               Also, original file is left intact 
;               (i.e. modification date etc.)
;               and renamed file.backup if operation successfully.
;               OF COURSE the copyright note is changed as well 
;          mgs, 09 Oct 1998 : - added Id tag for RCS
;          bmy, 19 Jul 1999 : - changed name & email from mgs to bmy
;                               for convenience!  :-)
;          bmy, 27 Jul 1999 : - put RCS tag as the first line of
;                               the standard header
;          bmy, 06 Jul 2000 : - extended separator lines a bit
;          bmy, 11 Oct 2006 : TOOLS VERSION 2.05
;                             - Cosmetic chanes
;     bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                             - Now include 2 email addresses
;                             - Updated comments, cosmetic changes.
;                             - Same conditions apply
;           bmy, 22 Apr 2008: GAMAP VERSION 2.12
;                             - Updated email addresses
;
;-
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever. 
; Copyright (C) 1997-2007 (same conditions apply) Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine add_template"
;-----------------------------------------------------------------------
 
pro Add_Template, file
 
   ; on_error,2    ; return to caller
 
   Email  = 'yantosca@seas.harvard.edu'
   Email2 = 'plesager@seas.harvard.edu'

   p = strpos(file,'.pro')
   if ( p lt 0 ) then begin
      routinename = strupcase( file ) 
      file        = file + '.pro'
   endif else routinename = strupcase( strmid( file, 0, p ) )

   s     = systime()
   day   = strmid(s,8,2)
   if( strmid( day, 0, 1 ) eq ' ' ) then day = '0' + strmid( day, 1, 1 )
   month = strmid( s, 4,  3 )
   year  = strmid( s, 20, 4 )

   ; open file for reading
   openr, lun2, file, /get_lun
   txt = ''
   while not eof(lun2) do begin
      readf, lun2, txt
      txt2 = strlowcase(txt)
      if ( strpos( txt2, 'pro ' ) ge 0 OR $
           (strpos( txt2, 'function ' ) ge 0 ) ) then $
         goto,next

   endwhile
   print,' Error: not an IDL routine.'
   return
 
next:	
   ;   create template in temporary new file
   ;-------  Open file for processing  --------
   get_lun, lun
   openw,  lun, 'tmp.' + file

   printf, lun, '; $Id' + '$'  ; sep. necessary for RCSing this routine

   printf, lun, $
  ';-----------------------------------------------------------------------', $
      format='(a)'     
   printf, lun, ';+', format='(a)'
   printf, lun, '; NAME:', format='(a)'
   printf, lun, ';        ',routinename
   printf, lun, ';'
   printf, lun, '; PURPOSE:', format='(a)'
   printf, lun, ';'
   printf, lun, '; CATEGORY:', format='(a)'
   printf, lun, ';'
   printf, lun, '; CALLING SEQUENCE:', format='(a)'
   printf, lun, ';        ',routinename
   printf, lun, ';'
   printf, lun, '; INPUTS:', format='(a)'
   printf, lun, ';'
   printf, lun, '; KEYWORD PARAMETERS:', format='(a)'
   printf, lun, ';'
   printf, lun, '; OUTPUTS:', format='(a)'
   printf, lun, ';'
   printf, lun, '; SUBROUTINES:', format='(a)'
   printf, lun, ';'
   printf, lun, '; REQUIREMENTS:', format='(a)'
   printf, lun, ';'
  ;printf, lun, '; COMMON BLOCKS:', format='(a)'
  ;printf, lun, ';'
   printf, lun, '; NOTES:', format='(a)'
   printf, lun, ';'
   printf, lun, '; EXAMPLE:', format='(a)'
   printf, lun, ';'
   printf, lun, '; MODIFICATION HISTORY:', format='(a)'
   printf, lun, ';        bmy, ',day,' ',month,' ',year,': VERSION 1.00'
   printf, lun, ';'
   printf, lun, ';-', format='(a)'
   
   printf, lun,'; Copyright (C) '+year+', Bob Yantosca, Harvard University'
   printf, lun,   $
      '; This software is provided as is without any warranty whatsoever.'
   printf, lun,   $
      '; It may be freely used, copied or distributed for non-commercial'
   printf, lun,   $
      '; purposes.  This copyright notice must be kept with any copy of'
   printf, lun,   $
      '; this software. If this software shall be used commercially or'
   printf, lun,   $
      '; sold as part of a larger package, please contact the author.'
   printf, lun,'; Bugs and comments should be directed to ' +email
   printf, lun,'; or ' + email2 + ' with subject "IDL routine '+$
      strlowcase(routinename)+'"'
   
   printf, lun, $
  ';-----------------------------------------------------------------------', $
      format='(a)'   
   printf, lun
   printf, lun
   
   printf, lun, txt
   while not eof(lun2) do begin
      readf, lun2, txt
      if txt eq '' then txt = ' '
      printf, lun, txt, format='(a)'
   endwhile
   
   close, lun, lun2
   free_lun, lun, lun2
   ;print,file+' complete.'

   ; NOW move original routine to file+.backup and new version to file
   mv1 = 'mv '+file+' '+file+'.backup'
   mv2 = 'mv tmp.'+file+' '+file
   spawn,mv1
   spawn,mv2
   
   return
end
