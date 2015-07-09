; $Id: make_na_met.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MAKE_NA_MET
;
; PURPOSE:
;        Driver program for CREATE_NESTED_MET.  Hardwired to 
;        the North-America nested-grid of Qinbin Li.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        MAKE_NA_MET
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        MONYR -> Specifies the month & year (e.g. '2001/06/' )
;
;        FMASK -> File mask (default is '*') 
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        MFINDFILE         (function)
;        EXTRACT_FILENAME  (function)
;        CREATE_NESTED_MET
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        For simplicity, input & output dirs, and X and Y
;        ranges have been hardwired.  Change as necessary.
;
; EXAMPLE:
;        MAKE_NA_MET
;
; MODIFICATION HISTORY:
;        bmy, 10 Apr 2003: VERSION 1.00
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2003-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine make_na_met"
;-----------------------------------------------------------------------


pro Make_NA_Met, MonYr=MonYr, FMask=FMask
 
   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; External functions
   FORWARD_FUNCTION MFindFile, Extract_FileName

   ; Keywords
   if ( N_Elements( MonYr ) eq 0 ) then MonYr = ''
   if ( N_Elements( FMask ) eq 0 ) then FMask = '*'

   ; Input and output directories (end w/ slash)
   InDir  = '/data/GEOS_1x1_global/' + StrTrim( MonYr, 2 )
   TmpDir = '~/IDL/regrid/TEMP/'
   OutDir = '~/IDL/regrid/TEMPna/' 
 
   ; Lon and lat ranges to trim
   XRange = [ -140, -40 ]
   YRange = [   10,  60 ]
 
   ;====================================================================
   ; Process files
   ;====================================================================

   ; Get list of each met field file
   InList = MFindFile( InDir + FMask + '.1x1.gz' )

   if ( N_Elements( InList ) le 0 OR InList[0] eq '' ) $
      then Message, 'No input files found!'

   ; Loop over files
   for N = 0L, N_Elements( InList ) - 1L do begin
      
      ; Filenames for zipped & unzipped files (w/o path)
      FileNameGz = Extract_FileName( InList[N] ) 
      FileName   = StrMid( FileNameGz, 0, StrLen( FileNameGz )-3 )
    
      ; Full path name of input file
      InFile  = StrTrim( InDir  + FileNameGz, 2 )

      ; Full path name of temp file
      TmpFile = StrTrim( TmpDir + FileName, 2 )

      ; Full path name of output file
      OutFile = StrTrim( OutDir + FileName, 2 )

      ; GZCAT command
      Cmd = 'gzcat ' + InFile + ' > ' + TmpFile
      Spawn, Cmd      

      ; Echo info
      print, '--------------------------------------------------------'
      print, 'Input  File : ', TmpFile
      print, 'Output File : ', OutFile
 
      ; Call CREATE_NESTED_MET to trim the files
      Create_Nested_Met, InFile=TmpFile,  InModel='GEOS3', InRes=1,      $
                         OutFile=OutFile, XRange=XRange,   YRange=YRange

      ; Remove TMPFILE
      Cmd = 'rm ' + TmpFile
      Spawn, Cmd

   endfor
end
