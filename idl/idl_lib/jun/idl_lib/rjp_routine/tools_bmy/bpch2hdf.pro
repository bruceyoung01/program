; $Id$
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH2HDF
;
; PURPOSE:
;        Reads data from a binary punch file and saves it in HDF-SD 
;        (Hierarchical Data Format, Scientific Dataset) format.
;
; CATEGORY:
;        File I/O
;
; CALLING SEQUENCE:
;        BPCH2HDF, INFILE, OUTFILE [, Keywords ]
;
; INPUTS:
;        INFILE -> Name of the binary punch file to read.  If
;             INFILE is not passed, the user will be prompted
;             to supply a file name via a dialog box.
;
;        OUTFILE -> Name of the HDF file to be written.  It is
;             recommended to insert the tokens %DATE% and %TIME%
;             into OUTFILE, since BPCH2HDF will write a separate
;             HDF file for each time index in the *.bpch file.
;             The tokens %DATE% and %TIME% will be overwritten 
;             with the current values of YYYYMMDD and HHMMSS.
;             Default is "bpch2hdf_output.%DATE%.%TIME%.hdf".
;
; KEYWORD PARAMETERS:
;        _EXTRA=e -> Picks up additional keywords for HDF_SETSD
;
; OUTPUTS:
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        TAU2YYMMDD    (function)  
;        REPLACE_TOKEN (function)
;        HDF_SETSD     
;
; REQUIREMENTS:
;        (1) References routines from GAMAP and TOOLS packages.
;        (2) You must use a version of IDL containing the HDF-SD routines.
;
; NOTES:
;        (1) BPCH2HDF assumes that all data blocks in the *.bpch file
;            file adhere to same grid.  This will be true for output
;            files from the GEOS-CHEM model.
;
;        (2) BPCH2HDF will write a separate HDF file corresponding
;            to each time index in the *.bpch file.  This prevents
;            file sizes from getting large, especially if there is
;            a lot of diagnostic output in the *.bpch file.
;
;        (3) BPCH2HDF will replace the %DATE% token with the 
;            current YYYYMMDD value, and will replace the %TIME%
;            token with the current HHMMSS value.  Therefore, it
;            is recommended to insert these tokens into the string
;            passed via OUTFILE.
;
;        (4) BPCH2HDF will also write arrays containing the latitudes,
;            longitudes, sigma centers, and sigma edges 
;
; EXAMPLE:
;        BPCH2HDF, 'myfile.bpch', 'myfile.%DATE%_%TIME%.hdf'
;
;            ; Will write the contents of "myfile.bpch" to
;            ; one or more HDF files "myfile.YYYYMMDD.HHMMSS.hdf"
;
; MODIFICATION HISTORY:
;        bmy, 18 Apr 2002: GAMAP VERSION 1.50
;
;-
; Copyright (C) 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine bpch2hdf"
;-----------------------------------------------------------------------


pro Bpch2Hdf, InFile, OutFile, _EXTRA=e
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION Expand_Path, Tau2YYMMDD, Replace_Token

   if ( N_Elements( OutFile ) eq 0 ) $
      then OutFile = 'bpch2hdf_output.%DATE%.%TIME%.hdf'

   ; Make sure to substitute /users/ctm/bmy for ~bmy, etc...
   OutFile = Expand_Path( OutFile )

   ;====================================================================
   ; Read data from the *.bpch file
   ;====================================================================

   ; Read all data blocks
   CTM_Get_Data, DataInfo, File=InFile
 
   ; Find the number of timesteps TAU0 in the *.bpch file
   Tau0 = DataInfo[*].Tau0
   Tau0 = Tau0[ Uniq( Tau0 ) ]
 
   ;====================================================================
   ; Write a new HDF file for each separate time in the *.bpch file
   ;====================================================================
   for T = 0L, N_Elements( Tau0 ) - 1L do begin
 
      ; Convert TAU to YYYYMMDD and HHMMSS
      Result       = Tau2YYMMDD( Tau0[T], /NFormat )
      NymdStr      = String( Result[0], '(i8.8)' )
      NhmsStr      = String( Result[1], '(i6.6)' )
      
      ; Insert YYYYMMDD and HHMMSS into 
      ThisFile     = Replace_Token( OutFile,  '%DATE%', NymdStr )
      ThisFile     = Replace_Token( ThisFile, '%TIME%', NhmsStr )
 
      ; THISDATAINFO holds data blocks for time TAU0
      Ind          = Where( DataInfo[*].Tau0 eq Tau0[T] )
      ThisDataInfo = DataInfo[Ind]
 
      ; Get MODELINFO and GRIDINFO structures, assume that
      ; all data blocks in the punch file are on the same grid
      ; (which is 99.999999999% true for most cases)
      GetModelAndGridInfo, ThisDataInfo[0], ModelInfo, GridInfo
 
      ; write lon/lat/alt/time info here      
      F            = ThisDataInfo[0].First
      D            = ThisDataInfo[0].Dim
      Lon          = [ GridInfo.XMid[    F[0]-1L : F[0]+D[0]-2L    ] ]
      Lat          = [ GridInfo.YMid[    F[1]-1L : F[1]+D[1]-2L    ] ]
      SigC         = [ GridInfo.SigMid[        0 : GridInfo.LMX-1L ] ]
      SigE         = [ GridInfo.SigEdge[       0 : GridInfo.LMX    ] ]
 
      ; Open Output file
      fId          = HDF_SD_Start( ThisFile, /Create )
 
      ; Write LAT/LON/Sigma information to the file
      HDF_SetSd, fId, Lon,  'LON',  Unit='Degrees', LongName='Longitude'
      HDF_SetSd, fId, Lat,  'LAT',  Unit='Degrees', LongName='Latitude'
      HDF_SetSd, fId, SigC, 'SIGC', Unit='Sigma',   LongName='Sigma Centers'
      HDF_SetSd, fId, SigE, 'SIGE', Unit='Sigma',   LongName='Sigma Edges'
 
      ; Undefine variables
      UnDefine, Result
      UnDefine, NymdStr
      UnDefine, NhmsStr
      UnDefine, Ind
      UnDefine, ModelInfo
      UnDefine, GridInfo
      UnDefine, F
      UnDefine, D
      UnDefine, Lon
      UnDefine, Lat
      UnDefine, SigC
      UnDefine, SigE
 
      ;=================================================================
      ; For the given time, write out all tracers to the HDF file
      ;=================================================================
      for D = 0L, N_Elements( ThisDataInfo ) - 1L do begin
 
         ; Data array
         Data   = *( ThisDataInfo[D].Data )

         ; Tracer name (actually CATEGORY::TRACERNAME)
         Name   = StrTrim( ThisDataInfo[D].Category,   2 ) + '::' + $
                  StrTrim( ThisDataInfo[D].TracerName, 2 )
 
         ; Long tracer number (offset applied!)
         Tracer = ThisDataInfo[D].Tracer 
         
         ; Get the long descriptive tracer name
         CTM_TracerInfo, Tracer, FullName=LongName
 
         ; Unit string
         Unit   = StrTrim( ThisDataInfo[D].Unit, 2 )
 
         ; If the unit string is blank, read it from "tracerinfo.dat"
         if ( StrLen( Unit ) eq 0 ) $
            then CTM_TracerInfo, Tracer, Unit=Unit
 
         ; Write the given data block to the HDF file
         HDF_SetSd, fId, Data, Name, $
            LongName=LongName, Unit=Unit, _EXTRA=e
 
         ; Undefine variables
         UnDefine, Data
         UnDefine, Name
         UnDefine, Tracer
         UnDefine, LongName
         UnDefine, Unit
 
      endfor
 
      ; Close HDF file
      HDF_SD_End, fId
 
      ; Undefine variables
      UnDefine, fId
      UnDefine, ThisFile
      UnDefine, ThisDataInfo
 
   endfor
 
   ; Quit
   return
end
