; $Id$
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_COARDS
;
; PURPOSE:
;        Reads data blocks from a COARDS-compliant netCDF file (such
;        as created by routine BPCH2COARDS) into GAMAP.  CTM_READ_COARDS 
;        is is an internal routine which is called by CTM_OPEN_FILE.
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
;        GAMAP
;
; CALLING SEQUENCE:
;        CTM_READ_COARDS, [, Keywords ]
;
; INPUTS:
;        ILUN -> GAMAP file unit which will denote the netCDF file.
;
;        FILENAME -> Name of the netCDF grid file to be read.
; 
;        FILEINFO -> Array of FILEINFO structures which will be
;             returned to CTM_OPEN_FILE.  CTM_OPEN_FILE will 
;             append FILEINFO to the GAMAP global common block.
;
;        DATAINFO -> Array of DATAINFO structures (each element 
;             specifies a GAMAP data block) which will be returned
;             to CTM_OPEN_FILE.  CTM_OPEN_FILE will append FILEINFO 
;             to the GAMAP global common block.        
;
; KEYWORD PARAMETERS:
;        _EXTRA=e -> Picks up extra keywords
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        ====================================================
;        CRC_Get_DimInfo        CRC_Get_IndexVars   
;        CRC_Read_Global_Atts   CRC_Get_Tracer
;        CRC_Get_Data           CRC_Save_Data
;
;        External Subroutines Required:
;        ====================================================
;        CTM_GRID          (function)   CTM_TYPE (function)
;        CTM_MAKE_DATAINFO (function)   STRRIGHT (function)
;        STRREPL           (function)
;
; REQUIREMENTS:
;        Requires routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) Assumes that data blocks have the following dimensions:
;            (a) longitude, latitude, time  
;            (b) longitude, latitude, levels, time
;
;        (2) Assumes that times are given in GMT.
;
;        (3) If information about each tracer in the COARDS-compliant
;            netCDF file is stored in the GAMAP "tracerinfo.dat" file, 
;            then CTM_READ_COARDS will be able to read the file without 
;            having to ask the user to supply a GAMAP category and
;            tracer name.  
;       
; EXAMPLE:
;        ILUN     = 21
;        FILENAME = 'coards.20010101.nc'
;        CTM_READ_COARDS, ILUN, FILENAME, FILEINFO, DATAINFO
;
;             ; Reads data from the COARDS-compliant netCDF file 
;             ; coards.20010101.nc and stores it the FILEINFO and 
;             ; DATAINFO arrays of structures.  If you are calling 
;             ; CTM_READ_COARDS from CTM_OPEN_FILE, then CTM_OPEN_FILE 
;             ; will append FILEINFO and DATAINFO to the GAMAP global
;             ; common block.
;
; MODIFICATION HISTORY:
;        bmy, 21 Mar 2005: GAMAP VERSION 2.03
;
;-
; Copyright (C) 2005, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_read_coards"
;-----------------------------------------------------------------------


pro CRC_Get_DimInfo, fId, Info, NameLon,  DimLon, $
                                NameLat,  DimLat, $
                                NameLev,  DimLev, $
                                NameTime, DimTime

   ;====================================================================
   ; Internal routine CRC_GET_DIMINFO returns the dimension names
   ; and sizes from the COARDS netCDF file.  We will assume that there
   ; are dimensions for longitude, latitude, levels, and time, which
   ; is true of most COARDS-compliant netCDF files. (bmy, 3/21/05)
   ;
   ; NOTES:
   ;====================================================================

   ; Dimension names
   NameLon  = ''
   NameLat  = ''
   NameLev  = ''
   NameTime = ''

   ; Dimension sizes
   DimLon   = 0L
   DimLat   = 0L
   DimLev   = 0L
   DimTime  = 0L

   ; Loop over dimension names
   for dId = 0L, Info.NDims-1L do begin
   
      ; Get information about each dimension
      NCDF_DimInq, fId, dId, Name, Size

      ; Examine dimension names
      case ( StrLowCase( StrTrim( Name, 2 ) ) ) of 

         ;--------------------------
         ; Various longitude names
         ;--------------------------

         'lon': begin
            NameLon = Name
            DimLon  = Size
         end

         'longitude': begin
            NameLon = Name
            DimLon  = Size
         end

         'x': begin
            NameLon = Name
            DimLon  = Size
         end

         ;--------------------------
         ; Various latitude names
         ;--------------------------

         'lat': begin
            NameLat = Name
            DimLat  = Size
         end

         'latitude': begin
            NameLat = Name
            DimLat  = Size
         end

         'y': begin
            NameLat = Name
            DimLat  = Size
         end

         ;--------------------------
         ; Various level names
         ;--------------------------

         'lev': begin
            NameLev = Name
            DimLev  = Size
         end

         'level': begin
            NameLev = Name
            DimLev  = Size
         end

         'z': begin
            NameLev = Name
            DimLev  = Size
         end

         ;--------------------------
         ; Various time names
         ;--------------------------

         'time': begin
            NameTime = Name
            DimTime  = Size
         end

         't': begin
            NameTime = Name
            DimTime  = Size
         end

         else: ; Otherwise skip

      endcase     
   endfor
end

;------------------------------------------------------------------------------

pro CRC_Get_IndexVars, fID, Info, NameLon,  DimLon,  Lon,  $
                                  NameLat,  DimLat,  Lat,  $
                                  NameLev,  DimLev,  Lev,  $
                                  NameTime, DimTime, Time, $
                                  LonShift, LatRev

   ;====================================================================
   ; Internal routine CRC_GET_INDEXVARS returns the index variables
   ; (lon, lat, lev, time) from the COARDS netCDF file. (bmy, 3/21/05)
   ;
   ; The COARDS standard requires that index variables have the same
   ; name as their corresponding dimension.  Therefore all we have to
   ; do is to loop through each variable and see if its name matches
   ; one of the file dimensions. 
   ;
   ; The COARDS specification also states that one must explicitly
   ; include the "units" attribute for the time variable, which will
   ; define the zero point from which forward time is reckoned.  We 
   ; will use this to convert time data to TAU values (hours since
   ; 00 GMT on 1/1/1985).
   ;
   ; For GAMAP the first longitude must be on the date line, so the 
   ; LONSHIFT flags denotes if we have to shift the latitudes before 
   ; reading into the GAMAP common block.  GAMAP also assumes that 
   ; latitudes go from S -> N.  Therefore set the LONSHIFT and LATREV
   ; flags if we have to reorder longitude & latitudes.
   ;
   ; NOTES:
   ;====================================================================
   
   ; Initialize
   Lon      = -1L
   LonShift = -1L
   Lat      = -1L
   LatRev   = -1L
   Lev      = -1L
   Time     = -1L 

   ; Loop over variables
   for vId = 0L, Info.NVars-1L do begin
      
      ; Structure w/ info about this variable
      VarInfo = NCDF_VarInq( fId, vId )

      ; Get LEV variable 
      if ( VarInfo.Name eq NameLev ) then NCDF_VarGet, fId, vId, Lev
      
      ;-----------------------------------------------------------------
      ; Special handling for LON: If degrees EAST then we need 
      ; to put longitude in the range of [-180,180] for GAMAP
      ;-----------------------------------------------------------------
      if ( VarInfo.Name eq NameLon ) then begin

         ; Get LON data
         NCDF_VarGet, fId, vId, Lon
                
         ; Do we have to shift the grid?
         if ( Lon[0] eq 0.0 ) then LonShift = DimLon / 2L

         ; Convert [0,360] to the range of [-180,180]
         Ind = Where( Lon gt 180.0 )
         if ( Ind[0] ge 0 ) then Lon[Ind] = Lon[Ind] - 360.0

         ; Represent 180 as -180
         if ( Lon[0] gt 0 ) then Lon[0] = -Lon[0]
      endif

      ;-----------------------------------------------------------------
      ; Special handling for LAT data: Make sure LAT goes from S -> N
      ;-----------------------------------------------------------------
      if ( VarInfo.Name eq NameLat ) then begin

         ; Get LAT data
         NCDF_VarGet, fId, vId, Lat

         ; If latitudes go from N -> S we need to reverse them
         if ( Lat[1] - Lat[0] lt 0 ) then LatRev = 1L

         ; Reverse latitudes
         if ( LatRev ) then Lat = Reverse( Lat )

      endif

      ;-----------------------------------------------------------------
      ; Special handling for TIME: Make sure that it is a TAU value 
      ; (i.e. consecutive hours since 00:00 GMT on 01/01/1985)
      ;
      ; NOTE: For now assume TIME is specified as GMT.  
      ;-----------------------------------------------------------------
      if ( VarInfo.Name eq NameTime ) then begin

         ; Get the TIME data
         NCDF_VarGet, fId, vId, Time

         ; COARDS requires a UNITS string for the TIME variable 
         NCDF_AttGet, fId, vId, 'units', Units
         Units    = String( Units )
         
         ; Extract information from the UNITS string
         R        = StrBreak( Units, ' ' )
         UnitStr  = StrLowCase( R[0] )
         DateStr  = R[2]
         HourStr  = R[3]
     
         ; Convert TIME into hours if necessary
         case ( UnitStr ) of
            'seconds' : Time = Time / 3600.0
            'minutes' : Time = Time / 60.0
            'days'    : Time = Time * 24.0
            else      : ; nothing
         endcase

         ; Convert starting date of data epoch to YYYYMMDD format
         R        = Long( StrBreak( DateStr, '-' ) )
         NYMD0    = Long( R[0]*10000L + R[1]*100L + R[2] )
         
         ; Convert starting time of data epoch to HHMMSS format
         R        = Long( StrBreak( HourStr, ':' ) )
         NHMS0    = Long( R[0]*10000L + R[1]*100L + R[2] )

         ; Compute TAU value at start of data epoch
         EpochTau = Nymd2Tau( NYMD0, NHMS0, /No_Y2K )

         ; Add TAU value at start of data epoch to TIME
         ; TIME is now a TAU value from 1985/01/01
         for T = 0L, DimTime-1L do begin
            Time[T] = Time[T] + EpochTau
         endfor

      endif
      
      ; Undefine the structure
      UnDefine, VarInfo

   endfor

end

;------------------------------------------------------------------------------

pro CRC_Read_Global_Atts, fId, Info, DimLon,     DimLat,    DimLev, $
                                     Lon,        Lat,       Lev,    $
                                     Delta_Time, ModelInfo, GridInfo

   ;====================================================================
   ; Internal routine CRC_READ_GLOBAL_ATTS reads information from
   ; the global attributes of the netCDF file.  This information is 
   ; used to define the start & end time, as well as the model grid.
   ; (bmy, 3/21/05)
   ;
   ; For GEOS-CHEM or other model files created by BPCH2COARDS, then
   ; it will read model information from global attributes.  For COARDS
   ; files from other sources it will assume a generic grid.  This 
   ; should be good enough for most applications.
   ;
   ; NOTES:
   ;====================================================================

   ; Initialize
   Delta_Time = -1L

   ; Loop thru # of global attributes
   for N = 0L, Info.NGAtts-1L do begin

      ; Get name of the Nth global attribute
      AttName = StrTrim( NCDF_AttName( fId, /Global, N  ), 2 )
     
      ; Extract attribute info into IDL variables
      case ( StrLowCase( AttName ) ) of
         'model'      : NCDF_AttGet, fId, /Global, AttName, Model
         'delta_lon'  : NCDF_AttGet, fId, /Global, AttName, DI
         'delta_lat'  : NCDF_AttGet, fId, /Global, AttName, DJ
         'delta_time' : NCDF_AttGet, fId, /Global, AttName, Delta_Time
         'nlayers'    : NCDF_AttGet, fId, /Global, AttName, NLayers
         else         : ; Nothing
      endcase
   endfor
  
   ;====================================================================
   ; Attempt to obtain information about the grid or starting/ending
   ; times in alternate ways if global attributes aren't defined
   ;====================================================================

   ; Convert MODEL from BYTE to STRING
   if ( N_Elements( Model ) gt 0 ) then begin
      Model = StrUpCase( StrTrim( Model, 2 ) )
   endif else begin
      Model = 'generic'
   endelse

   ; Use lon & lat dimensions if we can't find DI & DJ tags
   if ( N_Elements( DI ) eq 0 ) then DI = Abs( Lon[3] - Lon[2] )
   if ( N_Elements( DJ ) eq 0 ) then DJ = Abs( Lat[3] - Lat[2] )

   ; If NLAYERS is undefined, then look to the MODEL string
   if ( N_Elements( NLayers ) eq 0 ) then begin
      if ( StrPos( Model, '_30L' ) ge 0 ) then NLayers = 30
   endif

   ; If there is no LEVEL information then set NLAYERS=0
   if ( Lev eq -1L ) then NLayers = 0

   ; Define MODELINFO and GRIDINFO structures
   if ( NLayers gt 0 ) then begin

      ;---------------------------------
      ; Grid has vertical structure
      ;---------------------------------

      ; Define MODELINFO
      if ( Model eq 'generic' ) then begin
         ModelInfo = CTM_Type( Model, Res=[DI,DJ], NLay=NLayers, /Center180 )
      endif else begin
         ModelInfo = CTM_Type( Model, Res=[DI,DJ], NLay=NLayers )
      endelse

      ; Define GRIDINFO
      GridInfo = CTM_Grid( ModelInfo )

   endif else begin
      
      ;---------------------------------
      ; Grid has no vertical structure
      ;---------------------------------

      ; Define MODELINFO
      if ( Model eq 'generic' ) then begin
         ModelInfo = CTM_Type( Model, Res=[DI,DJ], /Center180 )
      endif else begin
         ModelInfo = CTM_Type( Model, Res=[DI,DJ]  )
      endelse

      ; Define 2-D GRIDINFO
      GridInfo = CTM_Grid( ModelInfo, /No_Vertical )
   endelse

   ; Flags for defining the starting epoch for NYMD2TAU
   Is_GEOS = ( ModelInfo.Family eq 'GEOS' OR ModelInfo.Family eq 'MOPITT' )
   Is_GISS = 1L - Is_GEOS

end

;------------------------------------------------------------------------------

pro CRC_Get_Tracer, VarName, Category, TrcName, Tracer
 
   ;====================================================================
   ; Internal routine CRC_GET_TRACER splits the variable name into
   ; a GAMAP category and tracer name.  It also returns the GAMAP
   ; tracer number corresponding to the category & tracer name (as 
   ; defined by the input files "diaginfo.dat" and "tracerinfo.dat").
   ; (bmy, 3/21/05)
   ;
   ; For COARDS netCDF files which were created from other sources
   ; then the GAMAP category and tracername will not be contained 
   ; within the variable name.  In that case ask the user to supply
   ; a GAMAP category and variable name.
   ;
   ; NOTES:
   ;====================================================================

   ; Initialize
   Category = ''
   TrcName  = ''

   ; If the file was created by BPCH2COARDS, then look 
   ; for the "__" separating CATEGORY from TRACERNAME
   Ind  = StrPos( VarName, '__' )

   ; If we find "__" ...
   if ( Ind[0] ge 0 ) then begin

      ;-----------------------------------------------------------------
      ; CATEGORY and TRACERNAME are part of the netCDF variable name
      ;-----------------------------------------------------------------
   
      ; Split GAMAP diagnostic category and tracer name from VARNAME
      if ( Ind[0] ge 0 ) then begin
         Category = StrMid( VarName, 0, Ind )
         TrcName  = StrMid( VarName, Ind[0]+2, StrLen( VarName ) -Ind[0]+2 )
      endif

      ; Replace '=S' with '=$' in GAMAP category name
      if ( StrRight( Category, 2 ) eq '=S' ) $
         then StrPut, Category, '=$', StrLen( Category )-2L 
   
      ; Replace '_S' with '-$' in GAMAP category name
      if ( StrRight( Category, 2 ) eq '_S' ) $
         then StrPut, Category, '-$', StrLen( Category )-2L 
   
      ; Replace '-S' with '-$' in GAMAP category name
      if ( StrRight( Category, 2 ) eq '-S' ) $
         then StrPut, Category, '-$', StrLen( Category )-2L 

      ; Also replace the '_' with '-' in GAMAP category name
      Category = StrRepl( Category, '_', '-' )

      ; Reset certain fields which contain '=$' instead of '-$'
      ; (add more fields if necessary)
      case ( Category ) of
         'CHEM-L-$' : Category = 'CHEM-L=$'
         'PORL-L-$' : Category = 'PORL-L=$'
         'ARSL-L-$' : Category = 'ARSL-L=$'
         'PNOY-L-$' : Category = 'PNOY-L=$'
         'PL-SUL-$' : Category = 'PL-SUL=$'
         'PL-BC-$'  : Category = 'PL-BC=$'
         'PL-OC-$'  : Category = 'PL-OC=$'
         'BXHT-L-$' : Category = 'BXHT-L=$'
         'AIRD-L-$' : Category = 'AIRD-L=$'
         else       :           ; Nothing
      endcase

   endif else begin

      ;-----------------------------------------------------------------
      ; CATEGORY and TRACERNAME aren't part of the netCDF variable name
      ;-----------------------------------------------------------------
      
      ; First assume that the category name is "COARDS-$"
      Category = 'COARDS-$'

      ; Get all tracer names in "tracerinfo.dat"
      CTM_TracerInfo, /All, Name=AllTracerNames

      ; Locate this tracer's name in the list of all tracer names
      Ind = Where( AllTracerNames eq StrUpCase( VarName ) )
      if ( Ind[0] ge 0 ) then TrcName = AllTracerNames[Ind] 

      ; Otherwise ask user to supply a CATEGORY and NAME
      if ( TrcName eq '' ) then begin

         ; Ask user to supply GAMAP category 
         Prompt   = 'CATEGORY for variable ' + VarName + '? : '
         Read, Category, Prompt=Prompt, Format='(a)'
         
         ; Ask user to supply GAMAP tracer name
         Prompt   = 'TRACER NAME for variable ' + VarName + '? : '
         Read, TrcName, Prompt=Prompt, Format='(a)'

         ; Strip out any quotes that the user may have entered
         Category = StrTrim( StrRepl( Category, "'", " " ), 2 )
         Category = StrTrim( StrRepl( Category, "`", " " ), 2 )
         Category = StrTrim( StrRepl( Category, '"', " " ), 2 )
         TrcName  = StrTrim( StrRepl( TrcName,  "'", " " ), 2 )
         TrcName  = StrTrim( StrRepl( TrcName,  "`", " " ), 2 )
         TrcName  = StrTrim( StrRepl( TrcName,  '"', " " ), 2 )

      endif

   endelse

   ; Get the GAMAP diagnostic offset (from "diaginfo.dat")
   CTM_DiagInfo, Category, Offset=Offset, Spacing=Spacing

   ; Get all tracer numbers corresponding to TRCNAME
   CTM_TracerInfo, TrcName, Index=TrcIndex

   ; Find the matching tracer number for this diagnostic category
   Ind    = Where( TrcIndex gt Offset and TrcIndex lt Offset+Spacing )
   Tracer = TrcIndex[Ind]

   ; If for some reason there are more than 2 matching tracer
   ; number (e.g. for regular Ox and Tagged Ox), just take the 1st
   Tracer = Tracer[0]

end
 
;------------------------------------------------------------------------------

pro CRC_Get_Data, fId, vId, VarInfo, Data, LongName, Unit

   ;====================================================================
   ; Internal routine CRC_GET_DATA reads a variable from a netCDF file.
   ; It returns the variable name, data array, long tracer name and
   ; unit string to the main program. (bmy, 3/21/05)
   ;
   ; NOTES:
   ;====================================================================

   ; Read netCDF variable
   NCDF_VarGet, fId, vId, Data, _EXTRA=e

   ; Read variable attributes
   for N = 0L, VarInfo.NAtts-1L do begin
         
      ; Attribute name
      AttName = NCDF_AttName( fId, vId, N )

      ; Search by attribute name
      case ( StrLowCase( AttName ) ) of

         'long_name' : begin
            NCDF_AttGet, fId, vId, AttName, LongName
            LongName = StrTrim( LongName, 2 )
         end

         'units' : begin
            NCDF_AttGet, fId, vId, AttName, Unit
            Unit = StrTrim( Unit, 2 )
         end

         'unit' : begin
            NCDF_AttGet, fId, vId, AttName, Unit
            Unit = StrTrim( Unit, 2 )
         end

         else : ; Nothing
      endcase
   endfor

   ; Rename units: special cases
   if ( Unit eq 'mb' ) then Unit = 'hPa'
end

;------------------------------------------------------------------------------

pro CRC_Save_Data, InType,       InGrid,      Time,      Delta_Time,  $
                   DimLon,       DimLat,      DimLev,    DimTime,     $
                   FileName,     Ilun,        VarName,   LongName,    $
                   Unit,         Data,        LonShift,  LatRev,      $
                   ThisFileInfo, ThisDataInfo

   ;====================================================================
   ; Internal function CRC_SAVE_DATA creates GAMAP-style data blocks 
   ; and returns the THISDATAINFO structure to the main program.
   ; (bmy, 3/21/05)
   ;
   ; We assume global-size data blocks.  Also the longitudes and 
   ; latitudes will be shifted in order to correspond with the 
   ; GAMAP MODELINFO structure.
   ;
   ; NOTES:
   ;====================================================================

   ; Split netCDF variable name into CATEGORY and TRACERNAME
   CRC_Get_Tracer, VarName, Category, TrcName, Tracer

   ; Strip extraneous dimensions
   Data  = Reform( Data )
   
   ; Size of the DATA array
   SData = Size( Data, /Dim )

   ; Find the time dimension
   Ind   = Where( SData eq DimTime )

   ; Is this data block a 3-D data block?
   Is_3D = ( Ind[0] eq 3 )

   ; Make sure data blocks are equal to the dimension sizes
   if ( Is_3D ) then begin
      if ( SData[0] ne DimLon  ) then Message, 'Invalid LON dimension!'
      if ( SData[1] ne DimLat  ) then Message, 'Invalid LAT dimension!'
      if ( SData[2] ne DimLev  ) then Message, 'Invalid LEV dimension!'
      if ( SData[3] ne DimTime ) then Message, 'Invalid TIME dimension!'
   endif else begin
      if ( SData[0] ne DimLon  ) then Message, 'Invalid LON dimension!'
      if ( SData[1] ne DimLat  ) then Message, 'Invalid LAT dimension!'
      if ( SData[2] ne DimTime ) then Message, 'Invalid TIME dimension!'
   endelse

   ;--------------------------------------------------------------------
   ; Create a DATAINFO structure in the global GAMAP common block for 
   ; each individual time that is specified in the DATA array
   ;--------------------------------------------------------------------

   ; Get the dimension array for CTM_GET_DATABLOCK
   if ( Is_3D )                                      $
      then Dim = [ DimLon, DimLat, DimLev, DimTime ] $
      else Dim = [ DimLon, DimLat,         DimTime ]  

   ; First-time flag
   FirstTime = 1L

   ; Loop through each time
   for T = 0L, DimTime-1L do begin

      ; Save one time in DATA
      if ( Is_3D ) then begin

         ;----------------
         ; 3-D data block
         ;----------------

         ; Shift longitudes if necessary
         if ( LonShift gt 0 )                                   $
            then Field = Shift( Data[*,*,*,T], LonShift, 0, 0 ) $
            else Field = Data[*,*,*,T] 

         ; Reverse latitudes if necessary
         if ( LatRev gt 0 ) then Field = Reverse( Field, 2 ) 

      endif else begin

         ;----------------
         ; 2-D data block
         ;----------------

         ; Shift longitudes if necessary
         if ( LonShift gt 0 )                              $ 
            then Field = Shift( Data[*,*,T], LonShift, 0 ) $
            else Field = Data[*,*,T] 

         ; Reverse latitudes if necessary
         if ( LatRev gt 0 ) then Field = Reverse( Field, 2 ) 

      endelse

      ; Create a DATAINFO structure for thisi data block,
      ; which will be appended to the GAMAP global common block
      Success  = CTM_Make_DataInfo( Float( Field ),          $
                                    OneDataInfo,             $
                                    OneFileInfo,             $
                                    ModelInfo=InType,        $
                                    GridInfo=InGrid,         $
                                    DiagN=Category,          $
                                    Tracer=Tracer,           $
                                    TrcName=TrcName,         $
                                    Tau0=Time[T],            $
                                    Tau1=Time[T]+Delta_Time, $
                                    Unit=Unit,               $
                                    Dim=Dim,                 $
                                    First=[1L, 1L, 1L],      $
                                    FileName=FileName,       $
                                    FileType=203,            $
                                    Format='COARDS netCDF',  $
                                    Ilun=Ilun,               $
                                    /No_Global )

      ; Error check
      if ( not Success ) then begin            
         S = 'Could not create DATAINFO structure for tracer ' + TrcName
         Message, S
      endif

      ; Save THISFILEINFO for return
      ThisFileInfo = OneFileInfo

      ; Save THISDATAINFO for return
      if ( FirstTime ) then begin
         ThisDataInfo = OneDataInfo
         FirstTime    = 0L
      endif else begin
         ThisDataInfo = [ ThisDataInfo, OneDataInfo ]
      endelse
   
      ; Undefine stuff
      UnDefine, Field
   
   endfor

   ; Undefine stuff 
   UnDefine, Dim
   
   ; Return to main program
   return 
end
 
;------------------------------------------------------------------------------
 
function CTM_Read_COARDS, Ilun, FileName, FileInfo, DataInfo, _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_Make_DataInfo, $
                    Nymd2Tau, StrRight, StrRepl

   ; Keywords
   Debug = Keyword_Set( Debug )
 
   ; Error if FILENAME isn't passed (maybe later we'll
   ; open a DIALOG_PICKFILE box to get the filename)
   if ( N_Elements( FileName ) ne 1 ) then Message, 'FILENAME not passed!'

   ; Make sure ILUN is odd -- this will replicate 
   ; the behavior of GAMAP with binary files!
   if ( Ilun mod 2 eq 0 ) then Ilun = Ilun + 1

   ;====================================================================
   ; Open netCDF file: Get dimensions and index variables
   ;====================================================================
 
   ; Test if netCDF library ships w/ this version of IDL
   if ( not NCDF_Exists() ) then begin
      Message, 'netCDF is not supported in this IDL version!', /Continue
      return, -1
   endif
 
   ; Open netCDF file
   fId  = NCDF_Open( FileName )
 
   ; Get a structure w/ the number of dimensions & variables
   Info = NCDF_Inquire( fId )

   ; Get the dimensions from the COARDS netCDF file
   CRC_Get_DimInfo,      fId, Info, NameLon,    DimLon,          $
                                    NameLat,    DimLat,          $
                                    NameLev,    DimLev,          $
                                    NameTime,   DimTime

   ; Get the index variables (lon, lat, lev, time) from the file
   ; Also get flags for shifting longitude & latitude if necessary
   CRC_Get_IndexVars,    fId, Info, NameLon,    DimLon,  Lon,    $
                                    NameLat,    DimLat,  Lat,    $
                                    NameLev,    DimLev,  Lev,    $
                                    NameTime,   DimTime, Time,   $
                                    LonShift,   LatRev 

   ; Get MODELINFO and GRIDINFO structures from global attributes
   CRC_Read_Global_Atts, fId, Info, DimLon,     DimLat,  DimLev, $   
                                    Lon,        Lat,     Lev,    $
                                    Delta_Time, InType,  InGrid


   ; If DELTA_TIME is undefined, compute it from 2 successive time values
   if ( Delta_Time lt 0 ) then Delta_Time = Time[1] - Time[0]

   ;====================================================================
   ; Loop over all variables and save to DATAINFO & FILEINFO structures
   ;====================================================================

   ; First time flag
   FirstTime = 1L

   ; Loop over all netCDF variables
   for vId = 0L, Info.NVars-1L do begin

      ; Get structure w/ info about this variable
      VarInfo = NCDF_VarInq( fId, vId )

      ; Variable name
      VarName = VarInfo.Name

      ; Skip over index arrays: LON, LAT, LEV, TIME
      if ( VarName eq NameLon  ) then goto, Next
      if ( VarName eq NameLat  ) then goto, Next
      if ( VarName eq NameLev  ) then goto, Next
      if ( VarName eq NameTime ) then goto, Next

      ; Read data from a variable
      CRC_Get_Data, fId, vId, VarInfo, Data, LongName, Unit

      ; Get GAMAP-style THISFILEINFO and THISDATAINFO structures
      CRC_Save_Data, InType,       InGrid,      Time,      Delta_Time,  $
                     DimLon,       DimLat,      DimLev,    DimTime,     $
                     FileName,     Ilun,        VarName,   LongName,    $
                     Unit,         Data,        LonShift,  LatRev,      $
                     ThisFileInfo, ThisDataInfo

      ; Append THISFILEINFO and THISDATAINFO into the
      ; FILEINFO and DATAINFO arrays of structures
      if ( FirstTime ) then begin
         FileInfo  = ThisFileInfo
         DataInfo  = ThisDataInfo        
         FirstTime = 0L
      endif else begin
         DataInfo  = [ DataInfo, ThisDataInfo ]
      endelse

      ; Undefine stuff
      UnDefine, Data
      UnDefine, LongName
      UnDefine, Unit
Next: 
      UnDefine, VarName
      UnDefine, VarInfo

   endfor

   ;====================================================================
   ; Cleanup and quit
   ;====================================================================
 
   ; Close netCDF file
   NCDF_Close, fId

   ; Return NEWDATAINFO to calling program
   return, 1
end
 
