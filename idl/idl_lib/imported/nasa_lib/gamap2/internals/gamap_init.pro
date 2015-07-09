; $Id: gamap_init.pro,v 1.1.1.1 2007/07/17 20:41:47 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GAMAP_INIT
;
; PURPOSE:
;        Initialize global common block for Global Atmospheric Model 
;        (output) Analysis Package (GAMAP).  This routine is called
;        automatically when gamap_cmn.pro is included in a file 
;        ( @gamap_cmn.pro ), but it executes only once.  User 
;        preferences are read from the file gamap.defaults in the 
;        current directory or the directory where gamap_init.pro 
;        resides.
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        GAMAP_INIT
;
; INPUTS:
;        none
;
; KEYWORD PARAMETERS:
;        DEBUG -> set a (new) debug level (0 or 1). 
;
; OUTPUTS:
;        none
;
; SUBROUTINES:
;        Uses FILE_EXIST, EXTRACT_PATH, and OPEN_FILE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        If you change the definition of the common block
;        in gamap_cmn.pro, make sure to accomodate these changes
;        in GAMAP_INIT.
;
; EXAMPLE:
;        GAMAP_INIT
;
; MODIFICATION HISTORY:
;        mgs, 14 Aug 1998: VERSION 1.00
;        mgs, 21 Sep 1998: - changed gamap.cmn to gamap_cmn.pro
;        mgs, 05 Oct 1998: - type assignment fix to DEBUG when read
;        mgs, 08 Oct 1998: - now runs through after CTM_CLEANUP and does
;                            not delete global pointers if valid.
;                          - added DEBUG keyword
;        mgs, 21 Jan 1999: - added postscript options
;        bmy, 19 Feb 1999: - added GIF_FILENAME
;        bmy, 22 Feb 1999: VERSION 1.01
;                          - added more animation options
;                          - changed POSTSCRIPT to DO_POSTSCRIPT
;                          - default path now amalthea
;        mgs, 23 Mar 1999: - slight change in defaults
;        bmy, 19 Jan 2000: GAMAP VERSION 1.44
;                          - replaced the deprecated STR_SEP function
;                            with STRSPLIT for IDL 5.3+
;                          - Now STRTRIM each token so that the case
;                            statement will find matches
;                          - cosmetic changes, updated comments
;        bmy, 13 Mar 2001: GAMAP VERSION 1.47
;                          - now supports MacOS operating system
;        bmy, 07 Jun 2001: - removed obsolete code prior to 3/13/01
;        bmy, 17 Jan 2002: GAMAP VERSION 1.50
;                          - now call STRBREAK wrapper routine from
;                            the TOOLS subdirectory for backwards
;                            compatiblity for string-splitting;
;                          - use FORWARD_FUNCTION to declare STRBREAK
;        bmy, 10 Dec 2002: GAMAP VERSION 1.52
;                          - added options for BMP, JPEG, PNG, TIFF output
;                          - added internal function TRIMTOK 
;        bmy, 13 Nov 2003: GAMAP VERSION 2.01
;                          - re-added option for MPEG animation
;                          - removed CREATEANIMATION, this was only
;                            ever used for XINTERANIMATE (obsolete)
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Now use the IDL FILE_WHICH routine to
;                            locate the gamap.defaults file
;
;-
; Copyright (C) 1998-2007, Martin Schultz, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine gamap_init"
;-----------------------------------------------------------------------


function TrimTok, Token, U=U
   
   ;====================================================================
   ; Internal function TRIMTOK strips white space from a token
   ; and if /U is set, also converts it to uppercase (bmy, 12/10/02)
   ;====================================================================

   ; Strip token
   Token = StrTrim( Token, 2 )

   ; Convert to uppercase if necessary
   if ( Keyword_Set( U ) ) then Token = StrUpCase( Token )

   ; Return
   return, Token
end

;------------------------------------------------------------------------------

pro gamap_init,debug=newdebug
 
   ; External functions
   FORWARD_FUNCTION StrBreak
   
   ; include global common block definition
   @gamap_cmn.pro                   

   on_error,2

   ; new default debug value (-1 will leave unchanged)
   if (n_elements(newdebug) eq 0) then newdebug = -1

 
   ; return if variables are already defined
   ; and DEBUG has a valid state (allows redefinitions after cleanup)
   if (n_elements(DefaultModel) gt 0    AND $
       n_elements(DefaultPath) gt 0     AND $
       n_elements(pGlobalFileInfo) gt 0 AND $
       n_elements(pGlobalDataInfo) gt 0 AND $
       n_elements(DEBUG) gt 0) then  $
      if (DEBUG ge 0) then return
 
 
   ; set default values
   DefaultModel        = 'GEOS1'
   CreatePostscript    = '*QUERY'
   AddTimeStamp        = '*QUERY'
   DefaultPSFilename   = 'idl.ps'
   CreateBMP           = '*QUERY'
   DefaultBMPFileName  = '*QUERY' 
   CreateGIF           = '*QUERY'
   DefaultGIFFileName  = '*QUERY' 
   CreateJPEG          = '*QUERY'
   DefaultJPEGFileName = '*QUERY' 
   CreatePNG           = '*QUERY'
   DefaultPNGFileName  = '*QUERY' 
   CreateTIFF          = '*QUERY' 
   DefaultTIFFFileName = '*QUERY'
   CreateMPEG          = '*QUERY'  ; (bmy, 11/13/03) 
   DefaultMPEGFileName = '*QUERY'  ; (bmy, 11/13/03)

   ; Need to use the proper path name format for
   ; the different operating systems (bmy, 3/13/01)
   case ( StrUpCase( !VERSION.OS_FAMILY ) ) of
      'UNIX'    : DefaultPath = '*pch*'
      'WINDOWS' : DefaultPath = 'C:\IDL\*pch*'
      'MACOS'   : DefaultPath = 'hd:IDL 5.3:*pch*'
      else      : Message, '*** Operating system not supported! ***'
   endcase

   if (not ptr_valid(pGlobalFileInfo)) then pGlobalFileInfo = ptr_new()
   if (not ptr_valid(pGlobalDataInfo)) then pGlobalDataInfo = ptr_new()
   Debug = 0
 
 
   ;------------------------------------------------------------------------
   ; Prior to 7/13/07:
   ; Now use the FILE_WHICH command (bmy, 7/13/07)
   ;; try to read file gamap.defaults in local directory
   ;; or directory of this routine
   ;if (not file_exist('gamap.defaults',full=full)) then begin
   ;   ; get filepath of this routine
   ;   dum = Routine_name( FileName=ProFileName )
   ;   if ( File_Exist( ProFileName, path=!PATH, full=full) ) then begin
   ;      TestName = Extract_Path( Full ) + 'gamap.defaults'
   ;      if (not File_Exist( TestName, Full=Full)) then return
   ;   endif
   ;endif
   ;------------------------------------------------------------------------
   
   ; Use the FILE_WHICH routine of IDL to first look for "gamap.defaults"
   ; in the current directory.  If not found there, then FILE_WHICH will
   ; look in the directories specified in the !PATH variable. (bmy, 7/13/07)
   FileName = File_Which( 'gamap.defaults', /Include_Current_Dir )
   Full     = Expand_Path( FileName )

   ; Echo info
   Message, 'Reading ' + Full, /Info

   open_file,full,ilun,/NO_PICKFILE
 
   if (ilun lt 0) then $
      message,'*** Cannot open gamap.defaults file ! ***'
 
   
    ; read default information from file
   Message, 'Reading gamap.defaults ...', /Info
   while (not eof(ilun)) do begin
      s = ''
      readf,ilun,s
      s = strtrim(s,2)
      if (s eq '') then s = '#'
      if (strmid(s,0,1) ne '#') then begin

         ; Now call STRBREAK routine to do the string-splitting 
         ; for all versions of IDL (bmy, 1/17/02)
         Tok = StrBreak( S, '=' )

         if (n_elements(tok) ne 2) then begin
            print,'Syntax error in token definition !'
            print,s
            goto,fileread_error
         endif 

         ; Careful -- we have to trim the strings here, or for some reason
         ; the CASE statement won't find any matches... (bmy, 1/20/2000)
         ; Added BMP, JPEG, PNG, TIFF options, removed MPEG (bmy, 12/10/02)
         ; Re-added MPEG options (bmy, 11/13/03)
         case ( TrimTok( Tok[0], /U ) ) of
            'MODELNAME'        : DefaultModel        = TrimTok( Tok[1], /U )
            'FILEMASK'         : DefaultPath         = TrimTok( Tok[1]     )
            'DO_POSTSCRIPT'    : CreatePostscript    = TrimTok( Tok[1], /U )
            'TIMESTAMP'        : AddTimeStamp        = TrimTok( Tok[1]     )
            'PS_FILENAME'      : DefaultPSFilename   = TrimTok( Tok[1]     )
            'DO_BMP'           : CreateBMP           = TrimTok( Tok[1], /U )
            'BMP_FILENAME'     : DefaultBMPFileName  = TrimTok( Tok[1]     )
            'DO_GIF'           : CreateGIF           = TrimTok( Tok[1], /U )
            'GIF_FILENAME'     : DefaultGIFFileName  = TrimTok( Tok[1]     )
            'DO_JPEG'          : CreateJPEG          = TrimTok( Tok[1], /U )
            'JPEG_FILENAME'    : DefaultJPEGFileName = TrimTok( Tok[1]     )
            'DO_MPEG'          : CreateMPEG          = TrimTok( Tok[1], /U )
            'MPEG_FILENAME'    : DefaultMPEGFileName = TrimTok( Tok[1]     )
            'DO_PNG'           : CreatePNG           = TrimTok( Tok[1], /U )
            'PNG_FILENAME'     : DefaultPNGFileName  = TrimTok( Tok[1]     )
            'DO_TIFF'          : CreateTIFF          = TrimTok( Tok[1], /U )
            'TIFF_FILENAME'    : DefaultTIFFFileName = TrimTok( Tok[1]     ) 
            'DO_ANIMATE'       : ; Now obsolete (bmy, 11/13/03)
            'DO_XINTERANIMATE' : ; Now obsolete (bmy, 11/13/03)
            'DEBUG'            : Debug               = Fix( Tok[1] )
            else               : print,'Invalid token : ',Tok[0]
         endcase
         
      endif
   endwhile
 
 
   free_lun,ilun

   ; set new DEBUG value
   if (newdebug ge 0) then DEBUG = newdebug
    
   return
 
 
fileread_error:
 
   print,'*** Error reading file gamap.defaults : ',!ERR, !ERR_STRING
   free_lun,ilun
 
   return
end
 
