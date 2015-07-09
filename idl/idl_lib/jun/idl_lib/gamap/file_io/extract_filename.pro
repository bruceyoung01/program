; $Id: extract_filename.pro,v 1.1.1.1 2007/07/17 20:41:38 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EXTRACT_FILENAME
;
; PURPOSE:
;        Extract the filename from a fully qualified filepath
;
; CATEGORY:
;        File & I/O
;
; CALLING SEQUENCE:
;        FILENAME = EXTRACT_FILENAME( FULLNAME [ , Keywords ] ) 
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
;        External Subroutines Required:
;        ===============================
;        ADD_SEPARATOR (function)
;
; REQUIREMENTS:
;        Requires routines from the TOOLS package.
;
; NOTES:
;        See also EXTRACT_PATH
;
; EXAMPLE:
;        PRINT, EXTRACT_FILENAME( '~/IDL/tools/extract_filename.pro')
;           extract_filename.pro
;
;             ; Prints just the file name part of a longer path.
;
;        PRINT,EXTRACT_FILENAME( 'example.dat', filepath=filepath )
;             example.dat'
;             ; will print  'example.dat', and filepath will contain ''
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
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - now use ADD_SEPARATOR
;                          - updated comments
;
;-
; Copyright (C) 1997-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine extract_filename"
;-----------------------------------------------------------------------


function Extract_Filename, FullName, Filepath=ThisFilePath

   ; External functions
   FORWARD_FUNCTION Add_Separator, RSearch

  
   ; determine path delimiter
   ;------------------------------------------------------------------------
   ; Prior to 5/26/07:
   ; Now use ADD_SEPARATOR to return the separator character (bmy, 5/26/07)
   ;;Case statement now supports Windows, MacOS, Unix/Linux (bmy, 3/13/01)
   ;case ( StrUpCase( StrTrim( !VERSION.OS_FAMILY, 2 ) ) ) of
   ;   'UNIX'    : sdel = '/' 
   ;   'WINDOWS' : sdel = '\'
   ;   'MACOS'   : sdel = ':'
   ;   else      : Message,  '*** Operating system not supported! ***'
   ;endcase
   ;------------------------------------------------------------------------
   SDel = Add_Separator( '' )

   filename = ''
   thisfilepath = ''

retry:
   ; look for last occurence of sdel and split string fullname

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

