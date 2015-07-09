; $Id: make_eur_met.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MAKE_EUR_MET
;
; PURPOSE:
;        Driver program for CREATE_NESTED_MET.  Hardwired to 
;        the European nested-grid of Isabelle Bey.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        MAKE_EUR_MET
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        None
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
;        MAKE_EUR_MET
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
; or phs@io.as.harvard.edu with subject "IDL routine make_eur_met"
;-----------------------------------------------------------------------


pro Make_EUR_Met
 
   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; External functions
   FORWARD_FUNCTION MFindFile, Extract_FileName

   ; Input and output directories (end w/ slash)
   ; change as necessary
   InDir  = Expand_Path( '~/S/GEOS_1x1/GEOS_3/'    )
   OutDir = Expand_Path( '~/S/GEOS_1x1/GEOS_3_EUR/' )
 
   ; Lon and lat ranges to trim
   XRange = [ -30, 50 ]
   YRange = [  30, 70 ]
 
   ;====================================================================
   ; Process files
   ;====================================================================

   ; Get list of each met field file
   InList = MFindFile( InDir + '*.1x1' )
   if ( N_Elements( InList ) le 0 ) then Message, 'No input files found!'

   ; Loop over files
   for N = 0L, N_Elements( InList ) - 1L do begin
      
      ; Input File
      InFile  = InList[N]     
 
      ; Output File
      OutFile = OutDir + Extract_FileName( InFile ) 
      
      ; Echo info
      print, '--------------------------------------------------------'
      print, 'Input  File : ', Infile
      print, 'Output File : ', OutFile
 
      ; Call CREATE_NESTED_MET to trim the files
      Create_Nested_Met, InFile=InFile,   InModel='GEOS3', InRes=1,      $
                         OutFile=OutFile, XRange=XRange,   YRange=YRange
 
   endfor
end
