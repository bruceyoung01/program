; $Id$
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH2NC
;
; PURPOSE:
;        Reads data from a binary punch file and saves it in
;        netCDF (network Common Data Format) format.
;
; CATEGORY:
;        File I/O
;
; CALLING SEQUENCE:
;        BPCH2NC, INFILE, OUTFILE [, Keywords ]
;
; INPUTS:
;        INFILE -> Name of the binary punch file to read.  If
;             INFILE is not passed, the user will be prompted
;             to supply a file name via a dialog box.
;
;        OUTFILE -> Name of the netCDF file to be written.  It is
;             recommended to insert the tokens %DATE% and %TIME%
;             into OUTFILE, since BPCH2NC will write a separate
;             netCDF file for each time index in the *.bpch file.
;             The tokens %DATE% and %TIME% will be overwritten 
;             with the current values of YYYYMMDD and HHMMSS.
;             Default is "bpch2nc_output.%DATE%.%TIME%.nc".
;
; KEYWORD PARAMETERS:
;        _EXTRA=e -> Picks up additional keywords for NCDF_SET
;
; OUTPUTS:
;
; SUBROUTINES:
;        Internal Subroutines:
;        ==============================
;        B2N_SetNcDim  (function)
;        B2N_GetNcDim  (function)
;
;        External Subroutines Required:
;        ==============================
;        TAU2YYMMDD    (function)  
;        REPLACE_TOKEN (function)
;        NCDF_SET     
;
; REQUIREMENTS:
;        (1) References routines from GAMAP and TOOLS packages.
;        (2) You must use a version of IDL containing the NCDF routines.
;
; NOTES:
;        (1) BPCH2NC assumes that all data blocks in the *.bpch file
;            file adhere to same grid.  This will be true for output
;            files from the GEOS-CHEM model.
;
;        (2) BPCH2NC will write a separate NC file corresponding
;            to each time index in the *.bpch file.  This prevents
;            file sizes from getting large, especially if there is
;            a lot of diagnostic output in the *.bpch file.
;
;        (3) BPCH2NC will replace the %DATE% token with the 
;            current YYYYMMDD value, and will replace the %TIME%
;            token with the current HHMMSS value.  Therefore, it
;            is recommended to insert these tokens into the string
;            passed via OUTFILE.  The tokens %DATE% and %TIME% tokens 
;            must be in uppercase.
;
;        (4) BPCH2NC will also write arrays containing the latitudes,
;            longitudes, sigma centers to the file. 
;
; EXAMPLE:
;        BPCH2NC, 'myfile.bpch', 'myfile.%DATE%.%TIME%.nc'
;
;            ; Will write the contents of "myfile.bpch" to
;            ; one or more NC files "myfile.YYYYMMDD.HHMMSS.nc"
;
; MODIFICATION HISTORY:
;        bmy, 19 Apr 2002: GAMAP VERSION 1.50
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
; with subject "IDL routine bpch2nc"
;-----------------------------------------------------------------------


function B2N_SetNcDim, fId, S, Dim

   ;====================================================================
   ; Function B2N_SetNcDim takes in a vector containing all of the 
   ; dimensions of the data blocks in the file, and returns the
   ; netCDF dimension indices.  Also calls NCDF_DIMDEF to define the
   ; dimension w/in the netCDF file. (bmy, 4/22/02)
   ;====================================================================

   ; Dimension array
   NC_Dim = LonArr( N_Elements( Dim ) )
   
   ; Set netCDF X-dimensions
   for N = 0L, N_Elements( Dim ) - 1L do begin
      S2        = S + String( N, Format='(i3.3)' )
      NC_Dim[N] = NCDF_DimDef( fId, S2, Dim[N] )
   endfor
      
   ; Return array of netCDF dimensions
   return, NC_Dim

end

;-----------------------------------------------------------------------------


function B2N_GetNcDim, N, Dim, NC_Dim

   ;====================================================================
   ; Function B2N_GetNcDim matches the corresponding netCDF dimension
   ; with a given data dimension. (bmy, 4/22/02)
   ;====================================================================
  
   ; Find where the number 
   Ind = Where( Dim eq N )
   if ( Ind[0] lt 0 ) then Message, 'Could not match dimension!'
   
   ; Return the corresponding netCDF dimension
   return, NC_Dim[ Ind ]

end

;-----------------------------------------------------------------------------

pro Bpch2Nc, InFile, OutFile, _EXTRA=e
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION Expand_Path, Tau2YYMMDD, Replace_Token

   if ( N_Elements( OutFile ) eq 0 ) $
      then OutFile = 'bpch2nc_output.%DATE%.%TIME%.nc'

   ; Make sure to substitute /users/ctm/bmy for ~bmy, etc...
   OutFile = Expand_Path( OutFile )

   ;====================================================================
   ; Read data from the *.bpch file
   ;====================================================================
   
   ; Make sure the NC library is supported
   if ( NCDF_Exists() eq 0 ) $
      then Message, 'netCDF is not supported on this platform!'

   ; Read all data blocks
   CTM_Get_Data, DataInfo, File=InFile
 
   ; Find the number of timesteps TAU0 in the *.bpch file
   Tau0 = DataInfo[*].Tau0
   Tau0 = Tau0[ Uniq( Tau0 ) ]
 
   ;====================================================================
   ; Write a new NC file for each separate time in the *.bpch file
   ;====================================================================
   for T = 0L, N_Elements( Tau0 ) - 1L do begin
 
      ; Convert TAU to YYYYMMDD and HHMMSS
      Result        = Tau2YYMMDD( Tau0[T], /NFormat )
      NymdStr       = String( Result[0], '(i8.8)' )
      NhmsStr       = String( Result[1], '(i6.6)' )
      
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
 
      ; write lon/lat/alt/time info here      
      F             = ThisDataInfo[0].First
      D             = ThisDataInfo[0].Dim
      Lon           = [ GridInfo.XMid[    F[0]-1L : F[0]+D[0]-2L    ] ]
      Lat           = [ GridInfo.YMid[    F[1]-1L : F[1]+D[1]-2L    ] ]
      SigC          = [ GridInfo.SigMid[        0 : GridInfo.LMX-1L ] ]
      ;SigE          = [ GridInfo.SigEdge[       0 : GridInfo.LMX    ] ]
 
      ; Get X, Y, Z Dimensions of all data blocks
      XDim          = ThisDataInfo[*].Dim[0]
      YDim          = ThisDataInfo[*].Dim[1]
      ZDim          = ThisDataInfo[*].Dim[2] 

      ; Only take unique dimensions
      XDim          = XDim[ Uniq( XDim, Sort( XDim ) ) ]
      YDim          = YDim[ Uniq( YDim, Sort( YDim ) ) ]
      ZDim          = ZDim[ Uniq( ZDim, Sort( ZDim ) ) ]

      ;=================================================================
      ; Write dimensions and index arrays to the netCDF file
      ;=================================================================

      ; Open netCDF file for ouptut
      fId           = NCDF_Create( ThisFile, /Clobber )

      ; Write netCDF dimensions to the file, return dimension arrays
      NC_XDim       = B2N_SetNcDim( fId, 'Lon-', XDim )
      NC_YDim       = B2N_SetNcDim( fId, 'Lat-', YDim )
      NC_ZDim       = B2N_SetNcDim( fId, 'Alt-', ZDim )
 
      ; End defintion mode before calling NCDF_SET
      NCDF_Control, fId, /Endef

      ; Write longitudes to netCDF file
      NCDF_Set, fId, Lon,  'LON',  NC_XDim, $
         Unit='Degrees', LongName='Longitude'
      
      ; Write latitudes to netCDF file
      NCDF_Set, fId, Lat,  'LAT',  NC_YDim, $
         Unit='Degrees', LongName='Latitude'

      ; Write sigma centers to netCDF file
      ; (only write up to the max # of vertical levels)
      Tmp  = Max( ZDim ) 
      Tmp2 = B2N_GetNcDim( Tmp, ZDim, NC_ZDim )
      SigC = SigC[ 0:Tmp-1L ]
      NCDF_Set, fId, SigC, 'SIGC', Tmp2, $
         Unit='Sigma',  LongName='Sigma Centers'

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
      ;UnDefine, SigE
      UnDefine, Tmp
      UnDefine, Tmp2

      ;=================================================================
      ; For the given time, write out all tracers to the NC file
      ;=================================================================
      for D = 0L, N_Elements( ThisDataInfo ) - 1L do begin
 
         ; Data array
         Data    = *( ThisDataInfo[D].Data )
        
         ; Tracer name (actually CATEGORY::TRACERNAME)
         Name    = StrTrim( ThisDataInfo[D].Category,   2 ) + '::' + $
                   StrTrim( ThisDataInfo[D].TracerName, 2 )
 
         ; Long tracer number (offset applied!)
         Tracer  = ThisDataInfo[D].Tracer 
         
         ; Get the long descriptive tracer name
         CTM_TracerInfo, Tracer, FullName=LongName
 
         ; Unit string
         Unit    = StrTrim( ThisDataInfo[D].Unit, 2 )
 
         ; If the unit string is blank, read it from "tracerinfo.dat"
         if ( StrLen( Unit ) eq 0 ) $
            then CTM_TracerInfo, Tracer, Unit=Unit
 
         ; Find the netCDF dimensions that correspond
         ; to the actual dimensions of the data block
         Dims    = ThisDataInfo[D].Dim
         NC_Dims = [ B2N_GetNcDim( Dims[0], XDim, NC_XDim ), $
                     B2N_GetNcDim( Dims[1], YDim, NC_YDim ), $
                     B2N_GetNcDim( Dims[2], ZDim, NC_ZDim ) ]

         ; Add a "fake" 3rd dimension for 2-d data 
         if ( Dims[2] eq 1 ) $
            then Data = Reform( Data, Dims[0], Dims[1], 1 )

         ; Write the given data block to the NC file
         NCDF_Set, fId, Data, Name, NC_Dims, $
            LongName=LongName, Unit=Unit, _EXTRA=e
 
         ; Undefine variables
         UnDefine, Data
         UnDefine, Name
         UnDefine, Tracer
         UnDefine, LongName
         UnDefine, Unit
         UnDefine, Dims
         UnDefine, NC_Dims
 
      endfor
 
      ; Close netCDF file
      NCDF_Close, fId
 
      ; Undefine variables
      UnDefine, fId
      UnDefine, ThisFile
      UnDefine, ThisDataInfo
 
   endfor
 
   ; Quit
   return
end
