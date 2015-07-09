; $Id: usage.pro,v 1.1.1.1 2007/07/17 20:41:24 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        USAGE
;
; PURPOSE:
;        Display help information on any routine in the IDL path
;        that has a (more or less) standard header.
;
; CATEGORY:
;        Documentation
;
; CALLING SEQUENCE:
;        USAGE, ROUTINENAME
;
; INPUTS:
;        ROUTINENAME -> (string) name of the routine for which help 
;             information shall be provided.  Tip: to get help for the 
;             current routine use function ROUTINE_NAME().
;
; KEYWORD PARAMETERS:
;        /PRINTALL -> prints complete header information. Normally, only 
;             "user relevant" information is displayed.
;
; OUTPUTS:
;        Prints usage information on the screen.
;
; SUBROUTINES:
;        External Subroutines Referenced:
;        ================================
;        DATATYPE   (function)
;        FILE_EXIST (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        This routine is meant to replace /HELP constructs etc.
;
; EXAMPLES:
;        (1)
;        IF ( N_PARAMS() NE 2 ) THEN BEGIN
;           PRINT,'Invalid number of arguments!'
;            USAGE, routine_name()
;        ENDIF
;
;             ; Put this error check IF block at the top of
;             ; an IDL routine to display the doc header
;             ; info if the wrong # of arguments are passed
;
;        (2)
;        USAGE, 'MY_ROUTINE', /PRINTALL
;
;             ; Print complete doc header information from
;             ; the IDL routine "my_routine.pro". 
;
; MODIFICATION HISTORY:
;        mgs, 27 Mar 1998: VERSION 1.00
;        mgs, 16 Jun 1998: - replaced close by free_lun
;        bmy, 09 May 2002: TOOLS VERSION 1.50
;                          - test RNAME to see if it's a string
;                          - updated comments
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commedrcially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine usage"
;-----------------------------------------------------------------------


pro usage,rname,printall=printall
 
   ; extract header information from current routine and print it
   ; restrict to CALLING_SEQUENCE, INPUTS, KEYWORDS, OUTPUTS and
   ; EXAMPLE(s)
   ; This requires that the routine name is identical with the
   ; filename (lowercase) and that the file contains a standard 
   ; header (i.e. mgs standard).

   ; External functions
   FORWARD_FUNCTION DataType, File_Exist
   
   ON_ERROR,2                   ; return to caller
 
   ; routine name must be provided!
   if (n_params() eq 0) then Message,'RNAME not passed!'
 
   ; Check to see if RNAME is a string (bmy, 5/9/02)
   if ( DataType( RName, /Name ) ne 'STRING' ) $
      then Message, 'RNAME must be a string!'
 
    ; check if pro file exists
   rfile = rname + '.pro'
   if (not(file_exist(rfile,path=!PATH,full=full))) then $
      message,'pro USAGE: Cannot find program file for '+rname+' !'

   ; open file and read in header (read until line is ";-" or EOF)
   ilun = -1
   ON_IOERROR,badfile
 
   openr,ilun,full,/get_lun
 
   line = ''
   if (keyword_set(PRINTALL)) then printit = 1 else printit = 0
   
   print,strupcase(rname),':'
   print
 
   while (not (eof(ilun) OR line eq ';-') ) do begin 
      readf,ilun,line
 
      ; determine whether to switch printing on or off
      teststr = strupcase(line)
      if (strpos(teststr,'CALLING SEQUENCE:') ge 0  OR $
          strpos(teststr,'EXAMPLE') ge 0) then printit = 1
      if (strpos(teststr,'SUBROUTINES:') ge 0  OR $
          strpos(teststr,'MODIFICATION HISTORY:') ge 0) then $
         if (not keyword_set(PRINTALL)) then printit = 0
 
      ; output header line if requested
      if (printit) then print,line
   endwhile
 
   free_lun,ilun
 
   return
 
badfile:
   if (ilun ge 0) then free_lun,ilun
   print,!error,' ',!err_string
   message,'pro USAGE: File error in '+rfile+' !'
 
end
 
