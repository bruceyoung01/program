; $Id: bpch2hdf.pro,v 1.2 2004/06/03 17:58:06 bmy Exp $
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
;        =========================================
;        CTM_GET_DATA    TAU2YYMMDD    (function)  
;        UNDEFINE        REPLACE_TOKEN (function)
;        HDF_SETSD       GETMODELANDGRIDINFO
;
; REQUIREMENTS:
;        (1) References routines from GAMAP and TOOLS packages.
;        (2) You must use a version of IDL containing the HDF-SD routines.
;
; NOTES:
;        (1) BPCH2HDF assumes that each data block in the *.bpch file
;            is either 2-D (lon-lat) or 3-D (lon-lat-alt).  
;
;        (2) BPCH2HDF assumes that all data blocks in the *.bpch file
;            file adhere to same horizontal grid.  This will be true
;            for output files from the GEOS-CHEM model.
;
;        (3) BPCH2HDF will write a separate HDF file corresponding
;            to each time index in the *.bpch file.  This prevents
;            file sizes from getting large, especially if there is
;            a lot of diagnostic output in the *.bpch file.
;
;        (4) BPCH2HDF will replace the %DATE% token with the 
;            current YYYYMMDD value, and will replace the %TIME%
;            token with the current HHMMSS value.  Therefore, it
;            is recommended to insert these tokens into the string
;            passed via OUTFILE.  These tokens may be in either
;            uppercase or lowercase.
;
;        (4) BPCH2HDF will also write arrays containing the latitudes,
;            longitudes, sigma coordinates (for 3-D data blocks only!)
;            to the HDF file.
;
;        (5) BPCH2HDF will write arrays containing the latitudes,
;            longitudes to the netCDF file.  For 3-D data blocks,
;            the sigma centers and sigma edges will also be written 
;            to the file.
;
; EXAMPLE:
;        BPCH2HDF, 'myfile.bpch', 'myfile.%DATE%.%TIME%.hdf'
;
;            ; Will write the contents of "myfile.bpch" to
;            ; one or more HDF files "myfile.YYYYMMDD.HHMMSS.hdf"
;
; MODIFICATION HISTORY:
;        bmy, 22 May 2002: GAMAP VERSION 1.50
;        bmy, 22 Oct 2002: GAMAP VERSION 1.52
;                          - bug fix: now do not write vertical layer 
;                            dim info to HDF file for 2-D grids
;        bmy, 22 May 2003: GAMAP VERSION 1.53
;                          - Make sure LONGNAME is not a null string
;        bmy, 18 Sep 2003: - Call PTR_FREE to free the pointer memory
;        bmy, 03 Jun 2004: GAMAP VERSION 2.02
;                          - now pass extra keywords to CTM_GET_DATA
;                            via _EXTRA=e keyword
;
;-
; Copyright (C) 2002-2004 Bob Yantosca, Harvard University
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
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION Expand_Path, Tau2YYMMDD, Replace_Token, ChkStru

   ; Keyword settings
   if ( N_Elements( OutFile ) eq 0 ) $
      then OutFile = 'bpch2hdf_output.%DATE%.%TIME%.hdf'

   ; Make sure to substitute /users/ctm/bmy for ~bmy, etc...
   OutFile = Expand_Path( OutFile )

   ;====================================================================
   ; Read data from the *.bpch file
   ;====================================================================
   
   ; Make sure the HDF library is supported
   if ( HDF_Exists() eq 0 ) $
      then Message, 'HDF is not supported on this platform!'

   ; Read all data blocks
   CTM_Get_Data, DataInfo, File=InFile, _EXTRA=e
 
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

      ; IS_3D denotes if the grid has vertical layers
      Is_3D        = ChkStru( GridInfo, [ 'LMX' ] )

      ; Get LON and LAT fields
      F            = ThisDataInfo[0].First
      D            = ThisDataInfo[0].Dim
      Lon          = [ GridInfo.XMid[    F[0]-1L : F[0]+D[0]-2L    ] ]
      Lat          = [ GridInfo.YMid[    F[1]-1L : F[1]+D[1]-2L    ] ]

      ; Get SIGC and SIGE fields only for 3-D data blocks
      if ( Is_3D ) then begin
         SigC      = [ GridInfo.SigMid[        0 : GridInfo.LMX-1L ] ]
         SigE      = [ GridInfo.SigEdge[       0 : GridInfo.LMX    ] ]
      endif

      ; Open Output file
      fId          = HDF_SD_Start( ThisFile, /Create )
 
      ; Write LAT/LON/Sigma information to the file
      HDF_SetSd, fId, Lon, 'LON', Unit='Degrees', LongName='Longitude'
      HDF_SetSd, fId, Lat, 'LAT', Unit='Degrees', LongName='Latitude'

      ; Write SIGC and SIGE to file only for 3-D data blocks
      if ( Is_3D ) then begin
         HDF_SetSd, fId, SigC, 'SIGC', Unit='Sigma', LongName='Sigma Centers'
         HDF_SetSd, fId, SigE, 'SIGE', Unit='Sigma', LongName='Sigma Edges'
      endif

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
 
         ; Pointer to data
         Pointer = ThisDataInfo[D].Data 

         ; Data array
         Data   = *( Pointer )

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
 
         ; Make sure LONGNAME is not a null string
         if ( LongName eq '' ) then LongName = 'Unknown tracer name'

         ; Write the given data block to the HDF file
         HDF_SetSd, fId, Data, Name, $
            LongName=LongName, Unit=Unit, _EXTRA=e
 
         ; Undefine variables
         UnDefine, Data
         UnDefine, Name
         UnDefine, Tracer
         UnDefine, LongName
         UnDefine, Unit
 
         ; Free the pointer memory
         Ptr_Free, Pointer

      endfor
 
      ; Close HDF file
      HDF_SD_End, fId
 
      ; Undefine variables
      UnDefine, fId
      UnDefine, ThisFile
      UnDefine, ThisDataInfo
      UnDefine, Is_3D
 
   endfor
 
   ; Quit
   return
end
