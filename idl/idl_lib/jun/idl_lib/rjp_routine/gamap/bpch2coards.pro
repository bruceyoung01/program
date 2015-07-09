; $Id: bpch2coards.pro,v 1.1 2005/03/24 18:03:09 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH2COARDS
;
; PURPOSE:
;        Reads data from a binary punch file and saves it in a
;        COARDS-compliant netCDF (network Common Data Format) file.
;
;        NOTE: COARDS is a formatting standard for netCDF files which
;        is widely used in both the atmospheric & climate communities.
;        COARDS-compliant netCDF files can be read by GAMAP, GrADS and
;        other plotting packages.
;        
;        See http://ferret.wrc.noaa.gov/noaa_coop/coop_cdf_profile.html
;        for more information about the COARDS standard.
;
; CATEGORY:
;        File I/O
;
; CALLING SEQUENCE:
;        BPCH2COARDS, INFILE, OUTFILE [, Keywords ]
;
; INPUTS:
;        INFILE -> Name of the binary punch file to read.  If INFILE
;             is not passed, the user will be prompted to supply a 
;             file name via a dialog box.
;
;        OUTFILE -> Name of the netCDF file to be written.  It is
;             recommended to insert the tokens %DATE% (or %date%)
;             into OUTFILE, since BPCH2COARDS will write a separate
;             netCDF file for each unique YYYYMMDD value contained
;             within the *.bpch file.  If OUTFILE is not specified,
;             BPCH2COARDS will use the default file name 
;             "coards.%DATE%.nc".
;
; KEYWORD PARAMETERS:
;        DIAGN -> Array of diagnostic categories from the bpch file
;             to save to netCDF format.  If omitted, BPCH2COARDS will 
;             save all diagnostic categories.  
; 
;        /VERBOSE -> If set, will print the name of each tracer
;             as it is being written to the netCDF file.  Useful
;             for debugging purposes.
;
;        _EXTRA=e -> Picks up additional keywords for NCDF_SET
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
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
;        (1) BPCH2COARDS assumes that each data block in the *.bpch
;            file is either 2-D (lon-lat) or 3-D (lon-lat-alt). 
;
;        (2) BPCH2COARDS assumes that the number type of each data 
;            block in the *.bpch file is REAL*4 (a.k.a. FLOAT). 
;
;        (3) BPCH2COARDS assumes that all data blocks in the *.bpch
;            file adhere to same horizontal grid.  This will always
;            be true for output files from the GEOS-CHEM model.
;
;        (4) BPCH2COARDS will write a separate COARDS-compliant netCDF
;            file corresponding to each unique YYYYMMDD date.  This 
;            prevents the files from becoming too large to be read
;            with IDL.
;
;        (5) BPCH2COARDS will replace the %DATE% (or %date%) token with
;            the current YYYYMMDD value.  Therefore, it is recommended
;            to insert this token into the string passed via OUTFILE.
;
;        (6) BPCH2COARDS will write arrays containing the latitudes,
;            longitudes to the netCDF file.  For 3-D data blocks,
;            the eta or sigma centers will also be written to the
;            file.  Time will be written as TAU values (i.e. hours
;            since 00:00 GMT on 01-Jan-1985.
;
;        (7) The netCDF library has apparently been updated in 
;            IDL 6.0+.  The result is that variable names containing
;            characters such as '$', '=', and ':' may now cause an
;            error in NCDF_VARDEF.  Therefore, we now pre-screen 
;            tracer names with function NCDF_VALID_NAME.
;           
; EXAMPLE:
;        BPCH2COARDS, 'myfile.bpch', 'myfile.%DATE%.nc'
;
;            ; Will write the contents of "myfile.bpch" to one
;            ; or more COARDS-compliant netCDF files adhering
;            ; to the filename convention "myfile.YYYYMMDD.nc"
;
; MODIFICATION HISTORY:
;  rjp & bmy, 17 Mar 2005: GAMAP VERSION 2.03
;                          - Based on bpch2nc.pro
;  
;-
; Copyright (C) 2002-2005, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine bpch2coards"
;-----------------------------------------------------------------------


pro Bpch2COARDS, InFile, OutFile, Verbose=Verbose, DiagN=DiagN, Tracer=Tracer, $
                 _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION Tau2YYMMDD, Replace_Token, $
                    ChkStru,    StrRepl,  NCDF_Valid_Name

   ; Keywords
   Verbose = Keyword_Set( Verbose )

   ; Ouptut file name
   if ( N_Elements( OutFile ) eq 0 ) then OutFile = 'coards.%DATE%.nc'

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
   if ( N_Elements( DiagN ) gt 0 )                                       $
      then CTM_Get_Data, DataInfo, DiagN, File=InFile, Tracer=Tracer, /Quiet, _EXTRA=e  $
      else CTM_Get_Data, DataInfo,        File=InFile, /Quiet, _EXTRA=e
    
   ; Get unique starting YYYYMMDD, HHMMSS, TAU0 values from the bpch file
   Tau0    = DataInfo[*].Tau0
   Date    = Tau2YYMMDD( Tau0, /NFormat )
   N_Date  = N_Elements( Date )
   Date0   = Date[ 0         : N_Date/2L - 1L ]
   Hour0   = Date[ N_Date/2L : *              ]
   Date0_U = Date0[ Uniq( Date0, Sort( Date0 ) ) ]
   Hour0_U = Hour0[ Uniq( Hour0, Sort( Hour0 ) ) ] / 10000L
   Tau0_U  = Tau0[  Uniq( Tau0,  Sort( Tau0  ) ) ]
   
   ; Get unique ending YYYYMMDD, HHMMSS, TAU1 values from the bpch file
   Tau1    = DataInfo[*].Tau1
   Date    = Tau2YYMMDD( Tau1, /NFormat )
   N_Date  = N_Elements( Date )
   Date1   = Date[ 0         : N_Date/2L - 1L ]
   Hour1   = Date[ N_Date/2L : *              ]
   Date1_U = Date1[ Uniq( Date1, Sort( Date1 ) ) ]
   Hour1_U = Hour1[ Uniq( Hour1, Sort( Hour1 ) ) ] / 10000L
   ;Tau1_U  = Tau1[  Uniq( Tau1,  Sort( Tau1  ) ) ]

   ; Number of unique YYYYMMDD dates in the file
   D_Dim   = N_Elements( Date0_U ) 

   ; Number of unique HHMMSS times for each YYYYMMDD date
   T_Dim   = N_Elements( Hour0_U )

   ; Define templates for DELTA_TIME string
   DT_Str  = '0000-%MM%-%DD% %HH%:00:00'

   ; Define DELTA_TIME tag for COARDS [hours]
   if ( T_Dim gt 1 )                                      $
      then Delta_Time = ( Hour0_U[1] - Hour0_U[0] )       $
      else Delta_Time = ( Date1_U[0] - Date0_U[0] ) * 24L
   
   ; Define structure for REPLACE_TOKEN
   if ( Delta_Time lt 24 ) then begin
      Stru = { MM:'00', DD:'00', HH:String( Delta_Time, Format='(i2.2)' ) }
   endif else if ( Delta_Time ge 24 AND Delta_Time lt 744 ) then begin
      Stru = { MM:'00', DD:'01', HH:'00' }
   endif else begin
      Stru = { MM:'01', DD:'00', HH:'00' }
   endelse
  
   ; Replace tokens with actual time 
   DT_Str = Replace_Token( DT_Str, Stru )

   ;====================================================================
   ; Write a new NC file for each data block in the *.bpch file
   ; NOTE: Data for the same YYYYMMDD will be saved in the same file
   ;====================================================================
   for T = 0L, D_Dim-1L do begin

      ; THISDATAINFO is an array of data blocks for time TAU0
      Ind             = Where( Date0 eq Date0_U[T] )
      ThisDataInfo    = DataInfo[Ind]

      ; Error check
      if ( N_Elements( ThisDataInfo ) eq 0 ) then begin
         S = 'Could not find data blocks for time ' + String( DateU[T] )
         Message, S
      endif

      ; Get MODELINFO and GRIDINFO structures, assume that
      ; all data blocks in the punch file are on the same grid
      ; (which is 99.999999999% true for most cases)
      GetModelAndGridInfo, ThisDataInfo[0], ModelInfo, GridInfo

      ; Does data block come from GEOS-CHEM model family?
      IsGEOS          = ( ModelInfo.Family eq 'GEOS'   OR $
                          ModelInfo.Family eq 'MOPITT' )

      ; Does data block come from GISS model family?
      IsGISS          = 1L - IsGEOS

      ; Does the model use a hybrid sigma-pressure grid?
      IsHybrid        = ( ModelInfo.Hybrid eq 1 )

      ; Are any of the data blocks in the file 3-D? 
      ; If so, we'll need to save the vertical coordinate
      Ind             = Where( ThisDataInfo[*].Dim[2] gt 1 )
      Is_Any_3D       = ( Ind[0] ge 0 )

      ; Insert YYYYMMDD into output file name
      NymdStr         = String( Date0_U[T], Format='(i8.8)' ) 
      ThisFile        = Replace_Token( OutFile, '%DATE%', NymdStr )

      ; Write lon/lat/alt/time info here      
      F               = ThisDataInfo[0].First
      D               = ThisDataInfo[0].Dim
      Lon             = [ GridInfo.XMid[ F[0]-1L : F[0]+D[0]-2L ] ]
      Lat             = [ GridInfo.YMid[ F[1]-1L : F[1]+D[1]-2L ] ]

      ; Get X dims of all data blocks (only take unique dims)
      XDim            = ThisDataInfo[*].Dim[0]
      XDim            = XDim[ Uniq( XDim, Sort( XDim ) ) ]

      ; Get Y dims of all data blocks (only take unique dims)
      YDim            = ThisDataInfo[*].Dim[1]
      YDim            = YDim[ Uniq( YDim, Sort( YDim ) ) ]

      ; Get the surface area of each grid box in m2
      Area_m2         = CTM_Boxsize( GridInfo, /m2)

      ; If at least one data block for this date is 3-D
      ; then we must also define the vertical coordinate
      if ( Is_Any_3D ) then begin

         ; Get maximum altitude dimension
         ZDim         = ThisDataInfo[*].Dim[2] 
         ZDim         = Max( ZDim[ Uniq( ZDim, Sort( ZDim ) ) ] )

         ; Get ETA (hybrid) or SIGMA (non-hybrid) coordinates
         if ( IsHybrid )                             $
            then EtaC = GridInfo.EtaMid[ 0:ZDim-1L ] $
            else SigC = GridInfo.SigMid[ 0:ZDim-1L ]

      endif

      ;=================================================================
      ; Define netCDF variables for lon, lat, lev, time coordinates
      ;=================================================================

      ; Open netCDF file for ouptut
      fId = NCDF_Create( ThisFile, /Clobber )

      ;--------------------------
      ; Global Attributes
      ;--------------------------
      TitleStr = 'COARDS/netCDF file created by BPCH2COARDS (GAMAP v2-03+)'
      NCDF_AttPut, fId, /Global, 'Title',       TitleStr
      NCDF_AttPut, fId, /Global, 'Model',       ModelInfo.Name
      NCDF_AttPut, fId, /Global, 'Delta_Lon',   ModelInfo.Resolution[0]
      NCDF_AttPut, fId, /Global, 'Delta_Lat',   ModelInfo.Resolution[1]
      NCDF_AttPut, fId, /Global, 'NLayers',     ModelInfo.NLayers
      NCDF_AttPut, fId, /Global, 'Start_Date',  Date0_U[T]
      NCDF_AttPut, fId, /Global, 'Start_Time',  Hour0_U[T]
      NCDF_AttPut, fId, /Global, 'End_Date',    Date1_U[T]
      NCDF_AttPut, fId, /Global, 'End_Time',    Hour1_U[T]
      NCDF_AttPut, fId, /Global, 'Delta_Time',  Delta_Time
      NCDF_AttPut, fId, /Global, 'Conventions', 'COARDS'

      ;--------------------------
      ; Longitude Dimension
      ;--------------------------

      ; Define the longitude dimension 
      NC_XDim = NCDF_DimDef( fId, 'lon', XDim )

      ; Define the variable which will hold the longitudes
      vLon    = NCDF_VarDef( fId, 'lon', NC_XDim, /Float  )

      ; Save attributes for longitude variable
      NCDF_AttPut, fId, vLon, 'long_name', 'Longitude'
      NCDF_AttPut, fId, vLon, 'units',     'degrees_east'

      ; /VERBOSE output
      if ( Verbose ) then Print, vLon, 'lon', Format=F1

      ;--------------------------
      ; Latitude Dimension
      ;--------------------------
      
      ; Define the latitude dimension 
      NC_YDim = NCDF_DimDef( fId, 'lat', YDim )

      ; Define the variable which will hold the latitudes
      vLat    = NCDF_VarDef( fId, 'lat', NC_YDim, /Float  )

      ; Save attributes for latitude variable
      NCDF_AttPut, fId, vLat, 'long_name',  'Latitude'
      NCDF_AttPut, fId, vLat, 'units',      'degrees_north'

      ; /VERBOSE output
      if ( Verbose ) then Print, vLat, 'lat', Format=F1

      ;--------------------------
      ; Altitude Dimension
      ;--------------------------
      if ( Is_Any_3D ) then begin
         
         ; Define the altitude dimension
         NC_ZDim = NCDF_DimDef( fId, 'lev', ZDim )

         ; Define the variable which will hold altitudes
         vLev    = NCDF_VarDef( fId, 'lev', NC_ZDim, /Float  )
         
         if ( IsHybrid ) then begin

            ; Save attributes for ETA (hybrid) grid
            NCDF_AttPut, fId, vLev, 'long_name', 'Eta Centers'
            NCDF_AttPut, fId, vLev, 'units',     'sigma_level'

         endif else begin

            ; Save attributes for SIGMA (non-hybrid) grid
            NCDF_AttPut, fId, vLev, 'long_name', 'Sigma Centers'
            NCDF_AttPut, fId, vLev, 'units',     'sigma_level'

         endelse

         ; /VERBOSE output
         if ( Verbose ) then Print, vLev, 'lev', Format=F1

      endif

      ;--------------------------
      ; Time Dimension
      ;--------------------------

      ; Define the time dimension
      NC_TDim = NCDF_DimDef( fId, 'time', /UNLIMITED )

      ; Define the variable which will hold times
      vTim    = NCDF_VarDef( fId, 'time', NC_TDim, /Float  )

      ; Save attributes for time variable
      NCDF_AttPut, fId, vTim, 'long_name', 'Time'
      NCDF_AttPut, fId, vTim, 'units',     'hours since 1985-1-1 00:00:0.0'
      NCDF_AttPut, fId, vTim, 'delta_t',   DT_Str

      ; /VERBOSE output
      if ( Verbose ) then Print, vTim, 'time', Format=F1

      ;--------------------------
      ; Grid Area
      ;--------------------------
      ; Define as a netCDF variable (bpch data is FLOAT)
      NA_Dims = [ NC_XDim, NC_YDim ]
      vArea     = NCDF_VarDef( fId, 'Area', NA_Dims, /Float  )

      ; Save attributes to netCDF file
      NCDF_AttPut, fId, vArea, 'long_name', 'Surface Area'
      NCDF_AttPut, fId, vArea, 'units',     'm2'

      ; Undefine variables
      UnDefine, Stru
      UnDefine, Date
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
      Name_Old  = 'notValid'

      ; Loop over all BPCH datablocks for this TAU0 value
      for D = 0L, N_Elements( ThisDataInfo ) - 1L do begin

         ; Define tracer name as CATEGORY__TRACERNAME
;         Name            = StrTrim( ThisDataInfo[D].Category,   2 ) + $
;                           '__'                                     + $
;                           StrTrim( ThisDataInfo[D].TracerName, 2 )

; rjp change
         Name            =  StrTrim( ThisDataInfo[D].TracerName, 2 )

         ; Strip out bad characters for netCDF variable names
         ; or else the code may crash (bmy, 10/20/03)
         Name            = NCDF_Valid_Name( Name )

         ; Extra fix -- GrADS will interpret "-" as a minus sign
         ; so we need to replace this with an underscore (rjp, 3/18/05)
         Name            = StrRepl( Name, '-', '_' )

         ; Append variable name into list of previously saved variables
         Name_Save[D]    = Name

         ; Long tracer number (offset applied!)
         Tracer          = ThisDataInfo[D].Tracer 
         
         ; Get the long descriptive tracer name
         CTM_TracerInfo, Tracer, FullName=LongName
 
         ; Unit string
         Unit            = StrTrim( ThisDataInfo[D].Unit, 2 )

         ; If the unit string is blank, read it from "tracerinfo.dat"
         if ( StrLen( Unit ) eq 0 ) $
            then CTM_TracerInfo, Tracer, Unit=Unit

         ; Define dimensions for netCDF file
         if ( ThisDataInfo[D].Dim[2] gt 1L )                      $
            then NC_Dims = [ NC_XDim, NC_YDim, NC_ZDim, NC_TDim ] $
            else NC_Dims = [ NC_XDim, NC_YDim,          NC_TDim ]

         ; Bug fix: LONGNAME cannot be a null string (bmy, 5/22/03)
         if ( LongName eq '' ) then LongName = 'Unknown Tracer Name'

         ; Have we defined this variable before?
         Chk             = Where( Name eq Name_Old )

         if ( Chk[0] lt 0 ) then begin

            ;-----------------------------------------
            ; FIRST TIME WE DEFINE VARIABLE IN netCDF
            ;-----------------------------------------

            ; Define as a netCDF variable (bpch data is FLOAT)
            vId          = NCDF_VarDef( fId, Name, NC_Dims, /Float  )

            ; Save attributes to netCDF file
            NCDF_AttPut, fId, vId, 'long_name', LongName
            NCDF_AttPut, fId, vId, 'units',     Unit

            ; Append variable ID to list of defined variables
            vId_Save[D]  = vId

            ; Append variable name to list of defined variables
            Name_Old     = [ Name_Old, Name ]
            
         endif else begin

            ;-----------------------------------------
            ; WE HAVE DEFINED THIS VARIABLE ALREADY
            ; BUT IT IS A FOR DIFFERENT TIME OF DAY
            ;-----------------------------------------

            ; Locate this variable among list of defined variables
            Chk0         = Where( Name eq Name_Save )

            ; Append this variable name to the list of saved
            ; variables so that we can print it with /VERBOSE
            vId_Save[D]  = vId_Save[ Chk0[0] ]
   
         endelse

         ; /VERBOSE output
         if ( Verbose ) then print, vId_Save[D], Name, Format=F1

         ; Error check
         if ( vId_Save[D] lt 0 ) then Message, 'Could not define variable!'

         ; Undefine variables
         UnDefine, Name
         UnDefine, Tracer
         UnDefine, LongName
         UnDefine, Unit
         UnDefine, NC_Dims
         UnDefine, vId
         
      endfor
 
      ;=================================================================
      ; Now save the data into all netCDF variables
      ;=================================================================

      ; Exit from netCDF definition mode
      NCDF_Control, fId, /EnDef
     
      ;-------------------------
      ; Longitude (deg E)
      ;-------------------------

      ; Convert to degrees east if necessary
      Ind = Where( Lon lt 0.0 )
      if ( Ind[0] ge 0 ) then Lon[Ind] = Lon[Ind] + 360.0

      ; Save to netCDF file
      NCDF_VarPut, fId, vLon, Lon

      ; /VERBOSE output
      if ( Verbose ) then Print, vLon, 'lon', Format=F2

      ;--------------------------
      ; Latitude (deg N)
      ;--------------------------

      ; Save to netCDF file
      NCDF_VarPut, fId, vLat, Lat

      ; /VERBOSE output
      if ( Verbose ) then Print, vLat, 'lat', Format=F2

      ;---------------------------
      ; Altitude (ETA or SIGMA)
      ;---------------------------
      if ( Is_Any_3D ) then begin
         
         ; Save ETA (hybrid) or SIGMA (non-hybrid)
         if ( IsHybrid )                       $
            then NCDF_VarPut, fId, vLev, EtaC  $
            else NCDF_VarPut, fId, vLev, SigC

         ; /VERBOSE output
         if ( Verbose ) then print, vLev, 'lev', Format=F2

      endif

      ;---------------------------
      ; Time (hours from 1/1/1985)
      ;---------------------------

      ; Save to netCDF file 
      NCDF_VarPut, fId, vTim, Tau0_U

      ; /VERBOSE output
      if ( Verbose ) then Print, vTim, 'time', Format=F2

      ;--------------------------
      ; Grid Area
      ;--------------------------
      ; Save to netCDF file 
      NCDF_VarPut, fId, vArea, Area_m2

      ; /VERBOSE output
      if ( Verbose ) then Print, vArea, 'Area', Format=F2

      ;---------------------------
      ; BPCH data blocks
      ;---------------------------

      ; Find unique variable ID numbers
      vID_Uniq = vId_Save[ Uniq( vId_Save, Sort( vId_Save ) ) ]

      ; Loop over all unique variables in the bpch file
      for N = 0L, N_Elements( vID_Uniq )-1L do begin

         ; Index array of data blocks corresponding to this
         ; unique variable ID number
         pId   = Where( vId_Uniq[N] eq vId_Save )

         ; Number of times per YYYYMMDD for this unique variable ID #
         N_pId = N_Elements( pId )

         ; Loop over number of times per day
         for D = 0L, N_pId-1L do begin

            ; Define a pointer to data block
            Pointer = ThisDataInfo[ pID[D] ].Data 

            ; Error check
            if ( not Ptr_Valid( Pointer ) ) then begin
               S = 'Invalid pointer for ' + Name_Save[ pID[D] ]
               Message, S
            endif

            ; Dereference the pointer to get the data
            Data = *( Pointer )

            ; Get the actual # of dimensions of the data block
            SD   = Size( Data, /Dim   )
            ND   = Size( Data, /N_Dim )

            ; Create data array to save to the netCDF file
            if ( D eq 0L ) then begin
               case ( ND ) of 
                  2 : Field = FltArr( XDim, YDim,       N_pId )
                  3 : Field = FltArr( XDim, YDim, ZDim, N_pId )
               endcase
            endif

            ; Store data into array
            case ( ND ) of 
               3 : Field[ *, *, 0:SD[2]-1L, D ] = Data[*, *, 0:SD[2]-1L ]
               2 : Field[ *, *,             D ] = Data
            endcase
            
            ; Undefine stuff
            UnDefine, Data
            UnDefine, SD
            UnDefine, ND
            Ptr_Free, Pointer

         endfor

         ; /VERBOSE output
         if ( Verbose ) then Print, vId_Uniq[N], Name_Save[pID[0]], Format=F2

         ; Write the data to the netCDF file
         NCDF_VarPut, fId, vId_Uniq[N], Field

         ; Undefine variable
         UnDefine, Field

      endfor

      ; Close netCDF file
      NCDF_Close, fId

      ; Undefine variables
      UnDefine, fId
      UnDefine, ThisFile
      UnDefine, ThisDataInfo
      UnDefine, Is_Any_3D
      UnDefine, vId_Save
      UnDefine, Lon
      UnDefine, Lat
      UnDefine, SigC
      UnDefine, EtaC

   endfor
 
   ; Quit
   return
end
