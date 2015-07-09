; $Id: bpch2ascii.pro,v 1.2 2004/06/03 17:58:06 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH2ASCII
;
; PURPOSE:
;        Translates data from GAMAP-readable binary punch file v. 2.0 
;        format to a simple ASCII file format
;       
; CATEGORY:
;        File I/O
;
; CALLING SEQUENCE:
;        BPCH2ASCII, INFILE, OUTFILE [ , Keywords ]
;
; INPUTS:
;        INFILE -> Name of the binary punch file to read.  If
;             INFILE is not passed, the user will be prompted
;             to supply a file name via a dialog box.
;
;        OUTFILE -> Name of the ASCII file to be written.  It is
;             recommended to insert the tokens %DATE% and %TIME%
;             into OUTFILE, since BPCH2ASCII will write a separate
;             netCDF file for each time index in the *.bpch file.
;             The tokens %DATE% and %TIME% will be overwritten 
;             with the current values of YYYYMMDD and HHMMSS.
;             Default is "bpch2nc_output.%DATE%.%TIME%.ascii".
;
; KEYWORD PARAMETERS:
;        /VERBOSE -> If set, then BPCH2ASCII will also echo the
;             header lines for each data block to the screen.
;
;        FORMAT -> String containing the numeric format for
;             for the data values.  Default is '(7(e13.6,1x))'
;
; OUTPUTS:
;         None
;
; SUBROUTINES:
;         External Subroutines Required:
;         =============================================
;         CTM_GET_DATA         TAU2YYMMDD    (function)
;         GETMODELANDGRIDINFO  REPLACE_TOKEN (function)
;         UNDEFINE
;
; REQUIREMENTS:
;         References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) BPCH2ASCII assumes that all data blocks in the *.bpch file
;            file adhere to same grid.  This will be true for output
;            files from the GEOS-CHEM model.
;
;        (2) BPCH2ASCII will write a separate ASCII file corresponding
;            to each time index in the *.bpch file.  This prevents
;            file sizes from getting large, especially if there is
;            a lot of diagnostic output in the *.bpch file.
;
;        (3) BPCH2NC will replace the %DATE% token with the 
;            current YYYYMMDD value, and will replace the %TIME%
;            token with the current HHMMSS value.  Therefore, it
;            is recommended to insert these tokens into the string
;            passed via OUTFILE.  The tokens %DATE% and %TIME% tokens 
;            may be either in uppercase or lowercase.
;
;        (4) The format of the ASCII file is:
;
;               Data block #1 header line
;               Data block #1 values (format specified by FORMAT keyword)
;               Data block #2 header line
;               Data block #2 values (format specified by FORMAT keyword)
;                ...
;
;             The header line will contain the units and size of
;             each data block.
;
;        (5) The data is written to the ASCII file in column-major 
;            order (i.e. the same way as in FORTRAN), so you can read 
;            the data into FORTRAN w/ the following code:
;
;                  READ( IUNIT, '(a)' ) HEADER
;                  READ( IUNIT, '(1p,7(e13.6,1x))' )
;            &       ((DATA(I,J), I=1,IMX), J=1,JMX)
;
;            where IMX and JMX are the dimensions of the data block.       
;     
;
; EXAMPLE:
;         BPCH2ASCII, 'myfile.bpch', 'myfile.%DATE%.%TIME%.ascii'
;        
;             ; Read data from binary punch file 'myfile.bpch'
;             ; and writes it to ASCII file 'myfile.bpch.ascii'.
;
;
; MODIFICATION HISTORY:
;        bmy, 22 May 2002: GAMAP VERSION 1.50
;        bmy, 28 May 2002: GAMAP VERSION 1.51
;                          - Added FORMAT keyword
;        bmy, 03 Jun 2004: GAMAP VERSION 2.02
;                          - now pass extra keywords to CTM_GET_DATA
;                            via _EXTRA=e keyword
;
;-
; Copyright (C) 2002-2004, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine bpch2ascii"
;-----------------------------------------------------------------------


pro Bpch2Ascii, InFile, OutFile, Verbose=Verbose, Format=Format, _EXTRA=e

   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION Tau2YYMMDD, Replace_Token
   
   DoPrint = Keyword_Set( Verbose )

   if ( N_Elements( OutFile ) ne 1 ) $
      then OutFile = 'bpch2ascii_output.%DATE%.%TIME%.ascii'

   if ( N_Elements( Format ) ne 1 ) then Format = '(7(e13.6,1x))'

   ; Make sure to substitute /users/ctm/bmy for ~bmy, etc...
   OutFile = Expand_Path( OutFile )

   ;====================================================================
   ; Read data from the binary punch file
   ;====================================================================

   ; Read all data blocks
   CTM_Get_Data, DataInfo, File=InFile, _EXTRA=e
 
   ; Find the number of timesteps TAU0 in the *.bpch file
   Tau0 = DataInfo[*].Tau0
   Tau0 = Tau0[ Uniq( Tau0 ) ]
 
   ;====================================================================
   ; Write a new ASCII file for each separate time in the *.bpch file
   ;====================================================================
   for T = 0L, N_Elements( Tau0 ) - 1L do begin
 
      ; Convert TAU to YYYYMMDD and HHMMSS
      DateTime      = Tau2YYMMDD( Tau0[T], /NFormat )
      NymdStr       = String( DateTime[0], '(i8.8)' )
      NhmsStr       = String( DateTime[1], '(i6.6)' )
      
      ; Insert YYYYMMDD and HHMMSS into 
      ThisFile      = Replace_Token( OutFile,  '%DATE%', NymdStr )
      ThisFile      = Replace_Token( ThisFile, '%TIME%', NhmsStr )
 
      ; THISDATAINFO holds data blocks for time TAU0
      Ind           = Where( DataInfo[*].Tau0 eq Tau0[T] )
      ThisDataInfo  = DataInfo[Ind]

      ; Get MODELINFO and GRIDINFO structures, assume that
      ; all data blocks in the punch file are on the same grid
      ; (which is 99.999999999% true for most cases)
      GetModelAndGridInfo, ThisDataInfo[0], ModelInfo, GridInfo

      ; Open a new ASCIIfile for this time
      Open_File, ThisFile, Ilun, /Get_Lun, /Write

      ; Loop over all data blocks
      for D = 0L, N_Elements( ThisDataInfo ) - 1L do begin
      
         ; Get data and other quantities
         Data  = *( ThisDataInfo[D].Data )
         Unit  = StrTrim( ThisDataInfo[D].Unit,       2 ) 
         TName = StrTrim( ThisDataInfo[D].Category,   2 ) + '::' + $
                 StrTrim( ThisDataInfo[D].TracerName, 2 )
      
         ; Get size of data block
         SData = Size( Data, /Dim )
         if ( N_Elements( SData ) eq 2 ) then SData = [ SData, 1 ]

         ; Create header line for each data block
         Hdr = StrTrim( TName, 2 ) + '  [' + Unit + ']  '                + $
               String( DateTime, Format='(i8.8,''/'',i6.6)' ) + '  '     + $
               StrTrim( String( ModelInfo.Resolution[1],                   $
                                Format='(f14.1)' ), 2 ) + 'x'            + $
               StrTrim( String( ModelInfo.Resolution[0],                   $
                                Format='(f14.1)' ), 2 ) + '  '           + $
               StrTrim( SData[0], 2 ) + 'x'                              + $
               StrTrim( SData[1], 2 ) + 'x'                              + $
               StrTrim( SData[2], 2 ) 
      
         ; Print to screen
         if ( DoPrint ) then Print, Hdr

         ; Write to file
         PrintF, Ilun, Hdr
         PrintF, Ilun, Data, Format=Format

         ; Undefine stuff 
         UnDefine, Data
         UnDefine, Unit
         UnDefine, TName
         UnDefine, Hdr
         UnDefine, SData

      endfor

      ; Undefine stuff 
      UnDefine, ModelInfo
      UnDefine, GridInfo
      UnDefine, DateTime
      UnDefine, NymdStr
      UnDefine, NhmsStr
      UnDefine, ThisFile
      UnDefine, ThisDataInfo
      
      ; Close ASCII file for this DATE/TIME combination
      Close,    Ilun
      Free_LUN, Ilun

   endfor

   ; Quit
   return
end
