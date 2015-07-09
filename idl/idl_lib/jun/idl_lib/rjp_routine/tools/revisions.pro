; $Id: revisions.pro,v 1.3 2004/06/03 18:01:28 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        REVISIONS
;
; PURPOSE:
;        extract information about file modifications and create
;        REVISIONS file
;
; CATEGORY:
;        library tools
;
; CALLING SEQUENCE:
;        REVISIONS,dirname
;
; INPUTS:
;        DIRNAME -> directory name to be searched for *.pro files
;
; KEYWORD PARAMETERS:
;        none.
;
; OUTPUTS:
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        ADD_SEPARATOR (function)
;        STRDATE       (function)
;        STRRIGHT      (function)
;
; REQUIREMENTS:
;        The program files must have a standard header with tag
;        "MODIFICATION HISTORY" as last item. This must be followed
;        with a ;- line (!! NOT ;----- !!).
;
;        The REVISIONS file will be written in the directory DIRNAME,
;        thus the user must have write permission.
;
; NOTES:
;        All *.pro file in the given directory will be analyzed.
;
; EXAMPLE:
;        revisions,'~mgs/IDL/test3d'
;
; MODIFICATION HISTORY:
;        mgs, 16 Jun 1998: VERSION 1.00
;        mgs, 25 May 1999: - added caution for tag detection in this
;                            routine itself.
;        bmy, 24 Oct 2003: TOOLS VERSION 1.53
;                          - Bug fix: EXPAND_PATH strips the directory
;                            separator string from the end of DIRNAME
;                            in IDL 6.0+.  Add this back manually.
;                          - use MFINDFILE instead of FINDFILE to fix
;                            file listing bug in IDL 5.2-
;
;-
; Copyright (C) 1998, 2003, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine revisions"
;-------------------------------------------------------------


pro revisions,dirname
 
   ; extract header information from current routine and print it
   ; This requires that the routine name is identical with the
   ; filename (lowercase) and that the file contains a standard 
   ; header (i.e. mgs standard).
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ON_ERROR,2                   ; return to caller
    
   FORWARD_FUNCTION strdate, StrRight, Add_Separator, MFindFile
 
   ; get local directory as default
   if (n_params() eq 0) then cd,current=dirname
    
   ; Expand to full path name.  In IDL 6.0+, this will strip any
   ; trailing separator characters.  We'll add them back below.
   DirName = Expand_Path( DirName )

   ; Call ADD_SEPARATOR to add a separator string for all supported OS's
   if ( StrRight( DirName ) ne '/') then dirname = Add_Separator( DirName )

   ; Get file listing
   files = MFindFile( Dirname + '*.pro' )

   if (files[0] eq '') then begin
      print,'** REVISIONS: no IDL files in directory '+dirname+' !'
      return
   endif
 
   ; open REVISIONS file
   openw,olun,dirname+'REVISIONS',/get_lun
 
   printf,olun,'Modification history for all files in '+dirname
   printf,olun,'last updated : ',strdate()
 
 
   ; loop through program files
   for i = 0,n_elements(files)-1 do begin 
                                
      ; open file and read in header (read until line is ";-" or EOF)
      ilun = -1
      ON_IOERROR,badfile
 
      openr,ilun,files[i],/get_lun
 
      line = ''
      printit = 0               ; wait until we find MODIFICATION HISTORY
 
      ; log filename on screen and in outfile 
      print,strupcase(extract_filename(files[i]))
      printf,olun
      printf,olun,'==================='
      printf,olun,strupcase(extract_filename(files[i]))
      printf,olun,'==================='
 
      while (not (eof(ilun) OR strtrim(line,2) eq ';-') ) do begin 
         readf,ilun,line
 
         ; determine whether to switch printing on or off
         teststr = strupcase(line)
         sp = strpos(teststr,'MODIFICATION HISTORY')
         if (sp ge 0) then  $   ; extra care for self
            if (strmid(teststr,sp-1,1) ne '"') then begin
            printit = 1
            readf,ilun,line
         endif
 
         ; output line if requested
         if (printit) then begin
            ; eliminate leading comment symbol and blanks
            pline =strmid(line,3,255)
            if (pline ne '') then printf,olun,pline
         endif
      endwhile
 
      free_lun,ilun
next_file:
   endfor
   
 
   free_lun,olun 
 
 
   return
 
badfile:
   if (ilun ge 0) then free_lun,ilun
   print,'*** File error in '+files[i]+' !'
   print,'*** ',!error,' ',!err_string
   goto,next_file
 
end
 
