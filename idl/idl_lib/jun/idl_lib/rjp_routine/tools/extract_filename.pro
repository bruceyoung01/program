; $Id: extract_filename.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        EXTRACT_FILENAME
;
; PURPOSE:
;        extract the file filename from a full qualified filename
;
; CATEGORY:
;        file handling
;
; CALLING SEQUENCE:
;        filename=EXTRACT_FILENAME(FULLANME [,keywords])
;
; INPUTS:
;        FULLNAME --> a fully qualified filename containing path information.
;
; KEYWORD PARAMETERS:
;        FILEPATH --> a named variable that returns the path of the
;           file. This can be used if both, the filename and the name
;           of the file will be used. Otherwise it is recommended to
;           use EXTRACT_PATH instead.
;
; OUTPUTS:
;        A string containing the filename to be analyzed.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        See also EXTRACT_PATH
;
; EXAMPLE:
;        print,extract_filename('~mgs/IDL/tools/extract_filename.pro')
;
;             will print  'extract_filename.pro'
;
;        print,extract_filename('example.dat',filepath=filepath)
;
;             will print  'example.dat', and filepath will contain ''
;
;
; MODIFICATION HISTORY:
;        mgs, 18 Nov 1997: VERSION 1.00
;        mgs, 21 Jan 1999: - added extra check for use of '/' path 
;                            specifiers in Windows OS;
;        bmy, 19 Jan 2000: TOOLS VERSION 1.44
;                          - replaced obsolete RSTRPOS( ) command with
;                            STRPOS( /REVERSE_SEARCH ) for IDL 5.3+
;                          - updated comments, few cosmetic changes
;        bmy, 13 Mar 2001: TOOLS VERSION 1.47
;                          - Add support for MacOS operating system
;        bmy, 17 Jan 2002: TOOLS VERSION 1.50
;                          - now call RSEARCH for backwards compatibility
;                            with versions of IDL prior to v. 5.2
;                          - use FORWARD_FUNCTION to declare RSEARCH
;
;-
; Copyright (C) 1997, 1999, 2000, 2001, 2002
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine extract_filename"
;-------------------------------------------------------------


function extract_filename,fullname,filepath=thisfilepath

   ; External functions
   FORWARD_FUNCTION RSearch

   ; determine path delimiter
   ; Case statement now supports Windows, MacOS, Unix/Linux (bmy, 3/13/01)
   case ( StrUpCase( StrTrim( !VERSION.OS_FAMILY, 2 ) ) ) of
      'UNIX'    : sdel = '/' 
      'WINDOWS' : sdel = '\'
      'MACOS'   : sdel = ':'
      else      : Message,  '*** Operating system not supported! ***'
   endcase

   filename = ''
   thisfilepath = ''

retry:
   ; look for last occurence of sdel and split string fullname
   ;--------------------------------------------------------------------
   ; Prior to 1/17/02
   ;; For IDL 5.3 and higher, need to use STRPOS( /REVERSE_SEARCH )
   ;p = StrPos( FullName, SDel, /Reverse_Search )
   ;--------------------------------------------------------------------
   ; Now call wrapper routine RSEARCH, which will call either RSTRPOS
   ; STRPOS( /REVERSE_SEARCH ), depending on the IDL version (bmy, 1/17/02)
   p = RSearch( FullName, SDel )


   ; extra Windows test: if p=-1 but fullname contains '/', retry
   if (p lt 0 AND strpos(fullname,'/') ge 0) then begin
      sdel = '/'
      goto,retry
   endif


   if (p ge 0) then begin
      thisfilepath = strmid(fullname,0,p+1)
      filename = strmid(fullname,p+1,strlen(fullname)-1)
   endif else $
      filename = fullname

   
   return,filename

end

