; $Id: bpch2gmi.pro,v 1.5 2008/01/16 19:04:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH2GMI
;
; PURPOSE:
;        Reads data from a binary punch file and saves it in
;        netCDF (network Common Data Format) format.  The data
;        will be shifted so that the first longitude is 0 degrees
;        (i.e. the prime meridian) in order to conform with the
;        GMI (Global Model Initiative) model grid definition.
;
; CATEGORY:
;        File & I/O, BPCH Format, Scientific Data Formats
;
; CALLING SEQUENCE:
;        BPCH2GMI, INFILE, OUTFILE [, Keywords ]
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
;        DIAGN -> A diagnostic category name (e.g. "IJ-AVG-$") or
;             array of names which will restrict the data block 
;             selection.  If DIAGN is omitted, then all data blocks 
;             within INFILE will be saved in netCDF format to OUTFILE.
; 
;        /VERBOSE -> If set, will print the names of each tracer
;             as it is being written to the netCDF file.
;
;        _EXTRA=e -> Picks up additional keywords for netCDF routines
;
; OUTPUTS:
;
; SUBROUTINES:
;        Internal Subroutines:
;        ============================================
;        B2G_Valid_VarName (function)
;        B2G_SetNcDim      (function)
;        B2G_GetNcDim      (function)
;
;        External Subroutines Required:
;        ============================================
;        CTM_GET_DATA        TAU2YYMMDD    (function)  
;        UNDEFINE            REPLACE_TOKEN (function)
;        STRREPL (function)  GETMODELANDGRIDINFO
;    
; REQUIREMENTS:
;        (1) References routines from GAMAP and TOOLS packages.
;        (2) You must use a version of IDL containing the NCDF routines.
;
; NOTES:
;        (1) BPCH2GMI assumes that each data block in the *.bpch file
;            is either 2-D (lon-lat) or 3-D (lon-lat-alt). 
;
;        (2) BPCH2GMI assumes that the number type of each data block
;            in the *.bpch file is REAL*4 (a.k.a. FLOAT). 
;
;        (3) BPCH2GMI assumes that all data blocks in the *.bpch file
;            file adhere to same horizontal grid.  This will always
;            be true for output files from the GEOS-CHEM model.
;
;        (4) BPCH2GMI will write a separate NC file corresponding
;            to each time index in the *.bpch file.  This prevents
;            file sizes from getting large, especially if there is
;            a lot of diagnostic output in the *.bpch file.
;
;        (5) BPCH2GMI will replace the %DATE% token with the 
;            current YYYYMMDD value, and will replace the %TIME%
;            token with the current HHMMSS value.  Therefore, it
;            is recommended to insert these tokens into the string
;            passed via OUTFILE.  The tokens %DATE% and %TIME% tokens 
;            may also be passed in lowercase (e.g,  %date%, %time% ).  
;
;        (6) BPCH2GMI will write arrays containing the latitudes,
;            longitudes to the netCDF file.  For 3-D data blocks,
;            the sigma centers will also be written to the file.  
;            Date and time are stored as global attributes.
;
;        (7) The netCDF library has apparently been updated in 
;            IDL 6.0+.  The result is that variable names containing
;            characters such as '$', '=', and ':' may now cause an
;            error in NCDF_VARDEF.  Therefore, we now pre-screen 
;            tracer names with function NCDF_VALID_NAME.
;           
; EXAMPLE:
;        BPCH2GMI, 'myfile.bpch', 'myfile.%DATE%.%TIME%.nc'
;
;            ; Will write the contents of "myfile.bpch" to one
;            ; or more netCDF files "myfile.YYYYMMDD.HHMMSS.nc"
;
; MODIFICATION HISTORY:
;  bmy & phs, 20 Aug 2007: GAMAP VERSION 2.10
;                          - Based on BPCH2NC
;        bmy, 19 Dec 2007: GAMAP VERSION 2.12
;                          - Now save sigma edges & centers or
;                            eta edges & centers to the file.
;                          - Extra error trap, if there is only one
;                            level in the file then set IS_3D=0.
;
;-
; Copyright (C) 2002-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine bpch2gmi"
;-----------------------------------------------------------------------


function B2G_SetNcDim, fId, S, Dim

   ;====================================================================
   ; Function B2G_SetNcDim takes in a vector containing all of the 
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


function B2G_GetNcDim, N, Dim, NC_Dim

   ;====================================================================
   ; Function B2G_GetNcDim matches the corresponding netCDF dimension
   ; with a given data dimension. (bmy, 4/22/02)
   ;====================================================================
  
   ; Find where the number 
   Ind = Where( Dim eq N )
   if ( Ind[0] lt 0 ) then Message, 'Could not match dimension!'
   
   ; Return the corresponding netCDF dimension
   return, NC_Dim[ Ind ]

end

;-----------------------------------------------------------------------------

pro Bpch2GMI, InFile, OutFile, Verbose=Verbose, DiagN=DiagN, _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION Tau2YYMMDD, Replace_Token, $
                    ChkStru,    StrRepl,  NCDF_Valid_Name

   ; Keywords
   Verbose = Keyword_Set( Verbose )

   if ( N_Elements( OutFile ) eq 0 ) $
      then OutFile = 'bpch2nc_output.%DATE%.%TIME%.nc'

   ; Make sure to substitute /users/ctm/bmy for ~bmy, etc...
   OutFile = Expand_Path( OutFile )

   ; Format strings for use below
   F1 = '(''Defined tracer '',i5, '' = '', a)'
   F2 = '(''Saving tracer  '',i5, '' = '', a)'

   ;====================================================================
   ; Read data from the *.bpch file
   ;====================================================================
   
   ; Make sure the NC library is supported
   if ( not NCDF_Exists() ) then begin
      Message, 'netCDF is not supported in this IDL version!', /Continue
      return
   endif

   ; Read all data blocks
   if ( N_Elements( DiagN ) gt 0 )                               $
      then CTM_Get_Data, DataInfo, DiagN, File=InFile, _EXTRA=e  $
      else CTM_Get_Data, DataInfo,        File=InFile, _EXTRA=e
 
   ; Find the unique TAU0 timestamps in the bpch file
   Tau0 = DataInfo[*].Tau0
   Tau0 = Tau0[ Uniq( Tau0, Sort( Tau0 ) ) ]

   ; Find the unique TAU1 timestamps in the bpch file
   Tau1 = DataInfo[*].Tau1
   Tau1 = Tau1[ Uniq( Tau1, Sort( Tau1 ) ) ]

   ;====================================================================
   ; Write a new NC file for each separate time in the *.bpch file
   ;====================================================================
   for T = 0L, N_Elements( Tau0 ) - 1L do begin

      ; THISDATAINFO is an array of data blocks for time TAU0
      Ind           = Where( DataInfo[*].Tau0 eq Tau0[T] )
      ThisDataInfo  = DataInfo[Ind]

      ; Get MODELINFO and GRIDINFO structures, assume that
      ; all data blocks in the punch file are on the same grid
      ; (which is 99.999999999% true for most cases)
      GetModelAndGridInfo, ThisDataInfo[0], ModelInfo, GridInfo

      ; GEOS or GISS model family?
      IsGEOS        = ( ModelInfo.Family eq 'GEOS'   OR $
                        ModelInfo.Family eq 'GCAP'   OR $
                        ModelInfo.Family eq 'MOPITT' )
      IsGISS        = 1L - IsGEOS

      ; Is it a hybrid grid
      IsHybrid      = ( ModelInfo.Hybrid eq 1 )
 
      ; Convert TAU0 and TAU1 to YYYYMMDD and HHMMSS
      DateTime0     = Tau2YYMMDD( Tau0[T], /NFormat, GEOS=IsGEOS, GISS=IsGISS )
      DateTime1     = Tau2YYMMDD( Tau1[T], /NFormat, GEOS=IsGEOS, GISS=IsGISS )
      
      ; Insert YYYYMMDD and HHMMSS into 
      NymdStr       = String( DateTime0[0], Format='(i8.8)' )
      NhmsStr       = String( DateTime0[1], Format='(i6.6)' )
      ThisFile      = Replace_Token( OutFile,  '%DATE%', NymdStr )
      ThisFile      = Replace_Token( ThisFile, '%TIME%', NhmsStr )
 
      ; Error check
      if ( N_Elements( ThisDataInfo ) eq 0 ) then begin
         S = 'Could not find data blocks for time ' + String( Tau0 )
         Message, S
      endif

      ; IS_3D denotes if the grid has vertical layers
      Is_3D         = ChkStru( GridInfo, [ 'LMX' ] )

      ; Extra trap!  Reset IS_3D if there is only 1 level
      if ( Is_3D AND GridInfo.LMX eq 1 ) then Is_3D = 0
      
      ; write lon/lat/alt/time info here      
      F             = ThisDataInfo[0].First
      D             = ThisDataInfo[0].Dim
      Lon           = [ GridInfo.XMid[ F[0]-1L : F[0]+D[0]-2L ] ]
      Lat           = [ GridInfo.YMid[ F[1]-1L : F[1]+D[1]-2L ] ]
 
      ; Get X dims of all data blocks (only take unique dims)
      XDim          = ThisDataInfo[*].Dim[0]
      XDim          = XDim[ Uniq( XDim, Sort( XDim ) ) ]

      ; Get Y dims of all data blocks (only take unique dims)
      YDim          = ThisDataInfo[*].Dim[1]
      YDim          = YDim[ Uniq( YDim, Sort( YDim ) ) ]

      ; For 3-D grids only...
      if ( Is_3D ) then begin

         ; Get centers & edges for hybrid or pure-sigma grids
         if ( IsHybrid ) then begin
            EtaC  = [ GridInfo.EtaMid[  0:GridInfo.LMX-1L ] ]
            EtaE  = [ GridInfo.EtaEdge[ 0:GridInfo.LMX    ] ]
         endif else begin
            SigC  = [ GridInfo.SigMid[  0:GridInfo.LMX-1L ] ] 
            SigE  = [ GridInfo.SigEdge[ 0:GridInfo.LMX    ] ] 
         endelse
         
         ; Get Z dims of all data blocks (only take unique dims)
         ZDim       = ThisDataInfo[*].Dim[2] 
         ZDim       = ZDim[ Uniq( ZDim, Sort( ZDim ) ) ]

         ; If the whole file has data blocks w/ just one
         ; vertical level, then turn off IS_3D (bmy, 12/20/07)
         if ( Max( ZDim ) eq 1 ) then Is_3D = 0

         ; Also add an extra dimension: the max dim +1 
         ; (this will be used for the sigma/edges
         ZDim       = [ ZDim, Max( ZDim )+1L ] 

      endif

      ;%%% SHIFT XDIM SO THAT IT STARTS AT THE PRIME MERIDIAN %%%
      Lon = Shift( Lon, D[0]/2L ) 

      ;%%% PUT XDIM IN RANGE 0-360 %%%
      Ind  = Where( Lon lt 0 )
      if ( Ind[0] ge 0 ) then Lon[Ind] = Lon[Ind] + 360.0

      ;=================================================================
      ; Define netCDF dimensions & attributes for lon, lat, vertical
      ;=================================================================

      ; Open netCDF file for ouptut
      fId     = NCDF_Create( ThisFile, /Clobber )

      ; Write netCDF dimensions to the file, return dimension arrays
      NC_XDim = B2G_SetNcDim( fId, 'Lon-', XDim )
      NC_YDim = B2G_SetNcDim( fId, 'Lat-', YDim )
 
      ; Define Global Attributes
      TitleStr = 'NetCDF file created by BPCH2GMI (GAMAP v2-12+)'
      NCDF_AttPut, fId, /Global, 'Title',      TitleStr
      NCDF_AttPut, fId, /Global, 'Model',      ModelInfo.Name
      NCDF_AttPut, fId, /Global, 'Delta_Lon',  ModelInfo.Resolution[0]
      NCDF_AttPut, fId, /Global, 'Delta_Lat',  ModelInfo.Resolution[1]

      ; If we only have 1 level of data, then adjust NLayers attribute
      if ( Is_3D )                                                      $
         then NCDF_AttPut, fId, /Global, 'NLayers',  ModelInfo.NLayers  $
         else NCDF_AttPut, fId, /Global, 'NLayers',  1L                 

      NCDF_AttPut, fId, /Global, 'Start_Date', DateTime0[0]
      NCDF_AttPut, fId, /Global, 'Start_Time', DateTime0[1] 
      NCDF_AttPut, fId, /Global, 'End_Date',   DateTime1[0] 
      NCDF_AttPut, fId, /Global, 'End_Time',   DateTime1[1] 

      ; Define longitude
      vLon = NCDF_VarDef( fId, 'LON', NC_XDim, /Float  )
      NCDF_AttPut, fId, vLon, 'long_name', 'Longitude'
      NCDF_AttPut, fId, vLon, 'unit',      'Degrees'

      ; Print name if /VERBOSE is set
      if ( Verbose ) then Print, vLon, 'LON', Format=F1

      ; Define latitude
      vLat = NCDF_VarDef( fId, 'LAT', NC_YDim, /Float  )
      NCDF_AttPut, fId, vLat, 'long_name', 'Latitude'
      NCDF_AttPut, fId, vLat, 'unit',      'Degrees'

      ; Print name if /VERBOSE is set
      if ( Verbose ) then Print, vLat, 'LAT', Format=F1

      ; Write sigma centers to netCDF file (3-D grids)
      ; (only write up to the max # of vertical levels)
      if ( Is_3D ) then begin
         
         ; Define all altitude dimensions w/in netCDF file
         NC_ZDim     = B2G_SetNcDim( fId, 'Alt-', ZDim )

         ;----------------------------------
         ; SIGMA or ETA Edges
         ;----------------------------------

         ; Find dimension of SIGMA or ETA edge array
         if ( IsHybrid )                                $
            then Tmp = Max( Zdim ) < N_Elements( EtaE ) $
            else Tmp = Max( Zdim ) < N_Elements( SigE )

         ; TMP_NC_ZDIME returns the netCDF dimension 
         ; corresponding to # of SIGMA or ETA edges
         Tmp_NC_ZdimE = B2G_GetNcDim( Tmp, ZDim, NC_ZDim )

         ; Cut vertical coords down to size 
         if ( IsHybrid )                 $
            then EtaE = EtaE[ 0:Tmp-1L ] $
            else SigE = SigE[ 0:Tmp-1L ]

         ;-----------------------------------
         ; SIGMA or ETA Centers
         ;-----------------------------------

         ; There is one less element in the SIGMA/ETA centers array
         Tmp          = Tmp - 1L

         ; TMP_NC_ZDIM returns the netCDF dimension 
         ; corresponding to # of sigma or eta centers
         Tmp_NC_ZdimC = B2G_GetNcDim( Tmp, ZDim, NC_ZDim )

         ; Cut vertical coords down to size
         if ( IsHybrid )                 $
            then EtaC = EtaC[ 0:Tmp-1L ] $
            else SigC = SigC[ 0:Tmp-1L ]

         if ( ModelInfo.Hybrid ) then begin

            ;--------------------------------
            ; Define netCDF ETA attributes
            ;--------------------------------

            ; ETA centers
            vEtaC = NCDF_VarDef( fId, 'ETAC', Tmp_NC_ZDimC, /Float  )
            NCDF_AttPut, fId, vEtaC, 'long_name', 'Eta Centers'
            NCDF_AttPut, fId, vEtaC, 'unit',      'Eta'

            ; Print name if /VERBOSE is set
            if ( Verbose ) then Print, vEtaC, 'ETAC', Format=F1

            ; ETA edges 
            vEtaE = NCDF_VarDef( fId, 'ETAE', Tmp_NC_ZDimE, /Float  )
            NCDF_AttPut, fId, vEtaE, 'long_name', 'Eta Edges'
            NCDF_AttPut, fId, vEtaE, 'unit',      'Eta'

            ; Print name if /VERBOSE is set
            if ( Verbose ) then Print, vEta, 'ETAE', Format=F1

         endif else begin

            ;--------------------------------
            ; Define netCDF SIGMA attributes
            ;--------------------------------

            ; SIGMA centers
            vSigC = NCDF_VarDef( fId, 'SIGC', Tmp_NC_ZDimC, /Float  )
            NCDF_AttPut, fId, vSigC, 'long_name', 'Sigma Centers'
            NCDF_AttPut, fId, vSigC, 'unit',      'Sigma'

            ; Print name if /VERBOSE is set
            if ( Verbose ) then Print, vSigC, 'SIGC', Format=F1

            ; SIGMA edges 
            vSigE = NCDF_VarDef( fId, 'SIGE', Tmp_NC_ZDimE, /Float  )
            NCDF_AttPut, fId, vSigE, 'long_name', 'Sigma Edges'
            NCDF_AttPut, fId, vSigE, 'unit',      'Sigma'

            ; Print name if /VERBOSE is set
            if ( Verbose ) then Print, vSig, 'SIGC', Format=F1

         endelse

      endif

      ; Undefine variables
      UnDefine, Result
      UnDefine, Ind
      UnDefine, ModelInfo
      UnDefine, GridInfo
      UnDefine, F
      UnDefine, D
      UnDefine, Tmp
      UnDefine, Tmp2
      UnDefine, IsGISS
      UnDefine, IsGEOS
      
      ;=================================================================
      ; Define netCDF variables for BPCH file data blocks
      ;=================================================================
      
      ; Array to save vID's and tracer names
      vId_Save  = LonArr( N_Elements( ThisDataInfo ) )
      Name_Save = StrArr( N_Elements( ThisDataInfo ) )
      
      ; Loop over all BPCH datablocks for this TAU0 value
      for D = 0L, N_Elements( ThisDataInfo ) - 1L do begin

         ; Define tracer name as CATEGORY__TRACERNAME
         Name = StrTrim( ThisDataInfo[D].Category,   2 ) + '__' + $
                StrTrim( ThisDataInfo[D].TracerName, 2 )

         ; Strip out bad characters for netCDF variable names
         ; or else the code may crash (bmy, 10/20/03)
         Name = NCDF_Valid_Name( Name )

         ; Save NAME for future use
         Name_Save[D] = Name

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
         NC_Dims = [ B2G_GetNcDim( Dims[0], XDim, NC_XDim ), $
                     B2G_GetNcDim( Dims[1], YDim, NC_YDim ) ]

         ; For 3-D grids, append vertical dim information
         if ( Is_3D ) then begin
            Nc_Dims = [ Nc_Dims, B2G_GetNcDim( Dims[2], ZDim, NC_ZDim ) ]
         endif
        
         ; Bug fix: LONGNAME cannot be a null string (bmy, 5/22/03)
         if ( LongName eq '' ) then LongName = 'Unknown Tracer Name'

         ; Define a netCDF variable (bpch data is FLOAT)
         vId = NCDF_VarDef( fId, Name, NC_Dims, /Float  )

         ; Print name if /VERBOSE is set
         if ( Verbose ) then print, vId, Name, Format=F1

         ; Error check
         if ( vId lt 0 ) then Message, 'Could not define variable!'

         ; Save vId in array
         vId_Save[D] = vId
   
         ; Save attributes to netCDF file
         NCDF_AttPut, fId, vId, 'long_name', LongName
         NCDF_AttPut, fId, vId, 'unit',      Unit

         ; Undefine variables
         UnDefine, Name
         UnDefine, Tracer
         UnDefine, LongName
         UnDefine, Unit
         UnDefine, Dims
         UnDefine, NC_Dims
         UnDefine, vId
         
      endfor
 
      ;=================================================================
      ; Now save the data into all netCDF variables
      ;=================================================================

      ; Exit from netCDF definition mode
      NCDF_Control, fId, /EnDef
     
      ;-------------------
      ; Coordinates
      ;-------------------

      ; Save longitude data
      NCDF_VarPut, fId, vLon, Lon

      ; Print name if /VERBOSE is set
      if ( Verbose ) then Print, vLon, 'LON', Format=F2

      ; Save latitude data
      NCDF_VarPut, fId, vLat, Lat

      ; Print name if /VERBOSE is set
      if ( Verbose ) then Print, vLat, 'LAT', Format=F2

      ; Save sigma coordinates
      if ( Is_3D ) then begin
         
         ; Now is correct for hybrid grids (bmy, 3/29/04)
         if ( IsHybrid ) then begin

            ; ETA centers
            NCDF_VarPut, fId, vEtaC, EtaC
            if ( Verbose ) then print, vEtaC, 'ETAC', Format=F2

            ; ETA edges
            NCDF_VarPut, fId, vEtaE, EtaE
            if ( Verbose ) then print, vEtaE, 'ETAE', Format=F2

         endif else begin

            ; SIGMA centers
            NCDF_VarPut, fId, vSigC, SigC
            if ( Verbose ) then print, vSigC, 'SIGC', Format=F2

            ; SIGMA edges
            NCDF_VarPut, fId, vSigE, SigE
            if ( Verbose ) then print, vSigE, 'SIGE', Format=F2

         endelse

         ; Print name if /VERBOSE is set

      endif
      
      ;-------------------
      ; BPCH data blocks
      ;-------------------

      ; Loop over all BPCH file datablocks for this TAU0 value
      for D = 0L, N_Elements( ThisDataInfo ) - 1L do begin

         ; Pointer to the data
         Pointer = ThisDataInfo[D].Data 

         ; Error check
         if ( not Ptr_Valid( Pointer ) ) then begin
            S = 'Invalid pointer for ' + Name_Save[D]
            Message, S
         endif

         ; Dereference the pointer to get the data
         Data = *( Pointer )

         ;%%% SHIFT XDIM SO THAT IT STARTS AT THE PRIME MERIDIAN %%%
         if ( ThisDataInfo[D].Dim[2] eq 1 )                            $
            then Data = Shift( Data, ThisDataInfo[D].Dim[0]/2L, 0    ) $
            else Data = Shift( Data, ThisDataInfo[D].Dim[0]/2L, 0, 0 )

         ; Print name if /VERBOSE is set
         if ( Verbose ) then Print, vId_Save[D], Name_Save[D], Format=F2

         ; Write the data
         NCDF_VarPut, fId, vId_Save[D], Data

         ; Undefine stuff
         UnDefine, Data

      endfor

      ; Close netCDF file
      NCDF_Close, fId

      ; Undefine variables
      UnDefine, fId
      UnDefine, ThisFile
      UnDefine, ThisDataInfo
      UnDefine, Is_3D
      UnDefine, vId_Save
      UnDefine, Lon
      UnDefine, Lat
      UnDefine, SigC
      UnDefine, EtaC

   endfor
 
   ; Quit
   return
end
