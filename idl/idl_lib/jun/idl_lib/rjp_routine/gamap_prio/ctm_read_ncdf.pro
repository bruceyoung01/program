; $Id: ctm_read_ncdf.pro,v 1.2 2004/03/26 17:02:25 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_NCDF
;
; PURPOSE:
;        Reads data blocks from a netCDF file created by routine
;        BPCH2NC into GAMAP.  (This is an internal routine which is
;        called by CTM_OPEN_FILE.)
;
; CATEGORY:
;        GAMAP
;
; CALLING SEQUENCE:
;        CTM_READ_NCDF, [, Keywords ]
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
;        CRN_Get_DimInfo       CRN_Get_Time   CRG_Get_Tracer     
;        CRG_Read_Global_Atts  CRG_Get_Data   CRG_Save_Data
;
;        External Subroutines Required:
;        ====================================================
;        CTM_GRID          (function)   CTM_TYPE (function)
;        CTM_MAKE_DATAINFO (function)   STRRIGHT (function)
;
; REQUIREMENTS:
;        Requires routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) Currently assumes that the netCDF file was written
;            by GAMAP routine BPCH2NC.
;
; EXAMPLE:
;        ILUN     = 21
;        FILENAME = 'geos.20010101.nc'
;        CTM_READ_NCDF, ILUN, FILENAME, FILEINFO, DATAINFO
;
;             ; Reads data from the netCDF file geos.20010101.nc
;             ; and stores it the FILEINFO and DATAINFO arrays of
;             ; structures.  If calling CTM_READ_GMI from CTM_OPEN_FILE,
;             ; then CTM_OPEN_FILE will append FILEINFO and DATAINFO
;             ; to the GAMAP common block.
;
; MODIFICATION HISTORY:
;        bmy, 05 Nov 2003: GAMAP VERSION 2.01
;                          - initial version
;        bmy, 26 Mar 2004: GAMAP VERSION 2.02
;                          - bug fix: now correctly separates "__"
;                            in netCDF tracer names with STRPOS
;
;-
; Copyright (C) 2003-2004, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_read_ncdf"
;-----------------------------------------------------------------------

 
pro CRN_Get_DimInfo, fId, DI, DJ, NLayers, Model

   ;====================================================================
   ; Internal routine CRN_GET_DIMINFO attempts to get the horizontal
   ; and vertical grid dimensions if they have not already been saved
   ; to the file as netCDF global attributes.  
   ;
   ; This is necessary for netCDF files written w/ the older version 
   ; of BPCH2NC (i.e. prior to GAMAP version 2-01).  Also returns the
   ; model name based on the data block dimensions.
   ;====================================================================

   ; Look for the Ox mixing ratio data block (which is 3-D)
   vId = NCDF_VarId( fId, 'IJ-AVG-S__Ox' )

   ; Use alternate name for files written w/ older BPCH2NC
   if ( vId lt 0 ) then vId = NCDF_VarId( fId, 'IJ-AVG-$::Ox' )

   if ( vId ge 0 ) then begin
         
      ; Data block exists, so read it
      NCDF_VarGet, fId, vId, Data

      ; Get dimensions
      SData   = Size( Data, /Dim )
      IMX     = SData[0]
      JMX     = SData[1]
      NLayers = SData[2]

      ; Undefine variables
      UnDefine, Data
      UnDefine, SData

      ; Get DI from the longitude dimension
      case ( IMX ) of 
         360: DI = 1.0
         288: DI = 1.25
         144: DI = 2.5
          72: DI = 5.0
          36: DI = 10.0
       endcase
         
       ; Get DJ from the latitude dimensions
       case ( JMX ) of 
          181: DJ = 1.0
          180: DJ = 1.0
           91: DJ = 2.0
           90: DJ = 2.0
           46: DJ = 4.0
           45: DJ = 4.0
           23: DJ = 8.0
       endcase

   endif else begin

      ; Ask user for dimensions since we can't determine them
      Print, '% Could not determine data dimensions!'
      Read,  '% Please enter DLon, DLat, NLayers ==>', DI, DJ, NLayers

   endelse

   ; Define model name based on the # of layers
   case ( NLayers ) of
      48   : Model = 'GEOS3'
      30   : Model = 'GEOS3_30L'
      26   : Model = 'GEOS_STRAT'
      20   : Model = 'GEOS1'

      ; Otherwise ask user to supply modelname
      else : begin
         Print, '% Could not determine MODELNAME!'
         Read,  '% Please enter MODELNAME ==>', Model
      end
   endcase
end

;------------------------------------------------------------------------------
  
pro CRN_Get_Time, Nymd0, Nymd1
 
   ;====================================================================
   ; Internal routine CRG_GET_TIME is called to compute the ending
   ; date and time of the netCDF file, if this information cannot be
   ; determined from the global attributes.  We do the cheap thing and
   ; assume that the ending date/time is 1 month after the starting
   ; date/time.  Assume HHMMSS = 000000 (as for monthly mean data).
   ;
   ; This is necessary for netCDF files written w/ the older version 
   ; of BPCH2NC (i.e. prior to GAMAP version 2-01).  
   ;====================================================================
 
   ; Split NYMD0 into year, month, day components
   Year0     = ( Nymd0 / 10000L             )
   Month0    = ( Nymd0 - ( Year0 * 10000L ) ) / 100L
   Day0      = ( Nymd0 - ( Year0 * 10000L ) - ( Month0 * 100L ) )

   ; Compute year, month and day 1 month after NYMD0
   Year1     = Year0
   Month1    = Month0 + 1L
   Day1      = Day0

   ; Adjust for the new year if necessary
   if ( Month1 gt 12 ) then begin
      Month1 = 1L
      Year1  = Year1 + 1L
   endif
 
   ; Astronomical Julian Day 1 month later from the last TAU0 value
   JD1       = JulDay( Month1, Day1, Year1 )
  
   ; Convert JD1 back into YYYY, MM, DD
   CalDat, JD1, Month1, Day1, Year1
  
   ; Convert YYYY, MM, DD into YYYYMMDD
   Nymd1     = ( Year1 * 10000L ) + ( Month1 * 100L ) + Day1 
 
end

;------------------------------------------------------------------------------

pro CRN_Get_Tracer, VarName, Category, TrcName, Tracer
 
   ;====================================================================
   ; Internal routine CRG_GET_TRACER splits the variable name into
   ; a GAMAP category and tracer name.  It also returns the GAMAP
   ; tracer number corresponding to the category & tracer name (as 
   ; defined by the input files "diaginfo.dat" and "tracerinfo.dat").
   ;====================================================================
 
   ;------------------------------------------------------
   ; Prior to 3/24/04:
   ;; Assume '__' separates CATEGORY from TRACERNAME
   ;Result = StrBreak( VarName, '__' )
   ;------------------------------------------------------
 
   ; Assume "__" separates CATEGORY from TRACERNAME
   Ind = StrPos( VarName, '__' )

   if ( Ind[0] ge 0 ) then begin

      ; ; GAMAP diagnostic category and tracer name
      Category = StrMid( VarName, 0, Ind )
      TrcName  = StrMid( VarName, Ind[0]+2, StrLen( VarName) -Ind[0]+2 )

   endif else begin

      ; For older files, assume '::' separates CATEGORY from TRACERNAME
      ;------------------------------------------------------------------
      ; Prior to 3/24/04:
      ;if ( N_Elements( Result ) eq 1 ) $
      ;   then Result = StrBreak( VarName, '::' )
      ;------------------------------------------------------------------
      Result = StrBreak( VarName, '::' )

      ; GAMAP diagnostic category and tracer name
      Category = Result[0]
      TrcName  = Result[1]

   endelse

   ; Replace '=S' with '=$' in GAMAP category name
   if ( StrRight( Category, 2 ) eq '=S' ) $
      then StrPut, Category, '=$', StrLen( Category )-2L 

   ; Replace '_S' with '-$' in GAMAP category name
   if ( StrRight( Category, 2 ) eq '_S' ) $
      then StrPut, Category, '=$', StrLen( Category )-2L 

   ; Replace '-S' with '-$' in GAMAP category name
   if ( StrRight( Category, 2 ) eq '-S' ) $
      then StrPut, Category, '-$', StrLen( Category )-2L 

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

pro CRN_Read_Global_Atts, fId, ModelInfo, GridInfo, Tau0, Tau1

   ;====================================================================
   ; Internal routine CRN_READ_GLOBAL_ATTS reads information from
   ; the global attributes of the netCDF file.  This information is 
   ; used to define the start & end time, as well as the model grid.
   ;
   ; For netCDF files written with the older version of BPCH2NC (i.e.
   ; prior to GAMAP v2-01), attempt to fill in the missing information.
   ;====================================================================

   ; Get a structure w/ information about this variable
   Result = NCDF_Inquire( fId )

   ; Loop thru # of global attributes
   for N = 0L, Result.NGAtts-1L do begin

      ; Get name of the Nth global attribute
      AttName = StrTrim( NCDF_AttName( fId, /Global, N  ), 2 )

      ; Extract attribute info into IDL variables
      case ( StrUpCase( AttName ) ) of

         ; Global attributes saved by BPCH2NC (GAMAP v2-01 and higher)
         'TITLE'      : NCDF_AttGet, fId, /Global, AttName, Title
         'MODEL'      : NCDF_AttGet, fId, /Global, AttName, Model
         'DELTA_LON'  : NCDF_AttGet, fId, /Global, AttName, DI
         'DELTA_LAT'  : NCDF_AttGet, fId, /Global, AttName, DJ
         'NLAYERS'    : NCDF_AttGet, fId, /Global, AttName, NLayers
         'START_DATE' : NCDF_AttGet, fId, /Global, AttName, Nymd0
         'START_TIME' : NCDF_AttGet, fId, /Global, AttName, Nhms0
         'END_DATE'   : NCDF_AttGet, fId, /Global, AttName, Nymd1
         'END_TIME'   : NCDF_AttGet, fId, /Global, AttName, Nhms1

         ; Global attributes saved by BPCH2NC (prior to GAMAP v2-01)
         'DATE'       : NCDF_AttGet, fId, /Global, AttName, Nymd0
         'TIME'       : NCDF_AttGet, fId, /Global, AttName, Nhms0

         else         : ; Nothing
      endcase

   endfor
   
   ;====================================================================
   ; Attempt to obtain information about the grid or starting/ending
   ; times in alternate ways if global attributes aren't defined
   ;====================================================================

   ; Convert TITLE from BYTE to STRING
   if ( N_Elements( Title ) gt 0 ) $
      then Title = StrUpCase( StrTrim( Title, 2 ) )

   ; Convert MODEL from BYTE to STRING
   if ( N_Elements( Model ) gt 0 ) $
      then Model = StrUpCase( StrTrim( Model, 2 ) )

   ; Get dimensions if we can't find global attributes
   if ( N_Elements( DI      ) eq 0   OR $
        N_Elements( DJ      ) eq 0   OR $
        N_Elements( NLayers ) eq 0 ) then begin

      ; Get horizontal & vertical dimensions
      CRN_Get_DimInfo, fId, DI, DJ, NLayers, TmpModel

      ; Replace Model name if it isn't defined
      if ( N_Elements( Model ) eq 0 ) $
         then Model = StrUpCase( StrTrim( TmpModel, 2 ) )
   endif

   ; Get ending date/time if we can't find global attributes
   if ( N_Elements( Nymd1 ) eq 0   OR $
        N_Elements( Nhms1 ) eq 0 ) then begin

      ; Assume NYMD1 is exactly 1 month after NYMD0
      CRN_Get_Time, Nymd0, Nymd1

      ; Assume NHMS1 is the same as NHMS0
      Nhms1 = Nhms0
   endif
   
   ;====================================================================
   ; Create grid and timing information from the grid structures
   ;====================================================================

   ; Create ModelInfo and GridInfo structures
   ModelInfo = CTM_Type( Model, Res=[DI,DJ], NLayers=NLayers )
   GridInfo  = CTM_Grid( ModelInfo )

   ; Flags for defining the starting epoch for NYMD2TAU
   Is_GEOS   = ( ModelInfo.Family eq 'GEOS' OR ModelInfo.Family eq 'MOPITT' )
   Is_GISS   = 1L - Is_GEOS

   ; Get start & end times
   Tau0      = Nymd2Tau( Nymd0, Nhms0, GEOS=Is_GEOS, GISS=Is_GISS )
   Tau1      = Nymd2Tau( Nymd1, Nhms1, GEOS=Is_GEOS, GISS=Is_GISS )
   
   ; Make sure TAU0 and TAU1 are scalars
   Tau0      = Tau0[0]
   Tau1      = Tau1[0]

end

;------------------------------------------------------------------------------

pro CRN_Get_Data, fId, vId, VarName, Data, LongName, Unit

   ;====================================================================
   ; Internal routine CRN_GET_DATA reads a variable from a netCDF file.
   ; It returns the variable name, data array, long tracer name and
   ; unit string to the main program.
   ;====================================================================

   ; Structure w/ info about this variable
   VarInfo = NCDF_VarInq( fId, vId )
      
   ; Variable name
   VarName = VarInfo.Name
   
   ;--------------------------
   ; Read netCDF variable
   ;-------------------------- 
   NCDF_VarGet, fId, vId, Data, _EXTRA=e

   ;--------------------------
   ; Read variable attributes
   ;--------------------------  
   for N = 0L, VarInfo.NAtts-1L do begin
         
      ; Attribute name
      AttName = NCDF_AttName( fId, vId, N )

      ; Search by attribute name
      case ( StrUpCase( AttName ) ) of

         'LONG_NAME' : begin
            NCDF_AttGet, fId, vId, AttName, LongName
            LongName = StrTrim( LongName, 2 )
         end

         'UNIT' : begin
            NCDF_AttGet, fId, vId, AttName, Unit
            Unit = StrTrim( Unit, 2 )
         end

         'UNITS' : begin
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

pro CRN_Save_Data, InType,   InGrid, Tau0,         Tau1,        $
                   FileName, Ilun,   VarName,      LongName,    $
                   Unit,     Data,   ThisFileInfo, ThisDataInfo
 
   ;====================================================================
   ; Internal function CRG_SAVE_DATA creates GAMAP-style data blocks 
   ; and returns the THISDATAINFO structure to the main program.
   ;
   ; NOTE: Assumes global-size data blocks (which is what routine
   ;       BPCH2NC generates).
   ;====================================================================

   ; Split netCDF variable name into CATEGORY and TRACERNAME
   CRN_Get_Tracer, VarName, Category, TrcName, Tracer
  
   ; Strip extraneous dimensions
   Data = Reform( Data )
   
   ; Size of the DATA array
   SData = Size( Data, /Dim )

   ; Get DIM vector for CTM_MAKE_DATAINFO
   case ( N_Elements( SData ) ) of 
      2: Dim  = [ SData[0], SData[1], 0,        0 ] 
      3: Dim  = [ SData[0], SData[1], SData[2], 0 ]
   endcase
 
   ; Create a DATAINFO structure for thisi data block,
   ; which will be appended to the GAMAP global common block
   Success  = CTM_Make_DataInfo( Float( Data ),           $
                                 ThisDataInfo,            $
                                 ThisFileInfo,            $
                                 ModelInfo=InType,        $
                                 GridInfo=InGrid,         $
                                 DiagN=Category,          $
                                 Tracer=Tracer,           $
                                 TrcName=TrcName,         $
                                 Tau0=Tau0,               $
                                 Tau1=Tau0,               $
                                 Unit=Unit,               $
                                 Dim=Dim,                 $
                                 First=[1L, 1L, 1L],      $
                                 FileName=FileName,       $
                                 FileType=202,            $
                                 Format='BPCH2NC netCDF', $
                                 Ilun=Ilun,               $
                                 /No_Global )
 
   ; Error check
   if ( not Success ) then begin
      S = 'Could not create datainfo structure for tracer ' + TrcName
      Message, S
   endif
      
   ; Undefine stuff for safety's sake
   UnDefine, Dim

   ; Return to main program
   return 
end
 
;------------------------------------------------------------------------------
 
function CTM_Read_NCDF, Ilun, FileName, FileInfo, DataInfo, _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_Make_DataInfo

   ; Keywords
   Debug = Keyword_Set( Debug )
 
   ; Error if FILENAME isn't passed (maybe later we'll
   ; open a DIALOG_PICKFILE box to get the filename)
   if ( N_Elements( FileName ) ne 1 ) then Message, 'FILENAME not passed!'

   ; Make sure ILUN is odd -- this will replicate 
   ; the behavior of GAMAP with binary files!
   if ( Ilun mod 2 eq 0 ) then Ilun = Ilun + 1

   ;====================================================================
   ; Open file and get information about the file
   ;====================================================================
 
   ; Test if netCDF library ships w/ this version of IDL
   if ( not NCDF_Exists() ) then begin
      Message, 'netCDF is not supported in this IDL version!', /Continue
      return, -1
   endif
 
   ; Open netCDF file
   fId = NCDF_Open( FileName )
 
   ;====================================================================
   ; Read data from the netCDF file and create GAMAP-style data blocks
   ; which will be appended to the global GAMAP common block
   ;====================================================================

   ; Get information from global attributes
   CRN_Read_Global_Atts, fId, InType, InGrid, Tau0, Tau1

   ; Get a structure w/ information about this variable
   VarInfo = NCDF_Inquire( fId )

   ; First time flag
   FirstTime = 1L

   ; Loop over all netCDF variables
   for vId = 0L, VarInfo.NVars-1L do begin

      ; Read data from a variable
      CRN_Get_Data, fId, vId, Name, Data, LongName, Unit

      ; Skip over index arrays: LON, LAT, SIGMA
      if ( Name eq 'LON'  ) then goto, Next
      if ( Name eq 'LAT'  ) then goto, Next
      if ( Name eq 'SIGC' ) then goto, Next

      ; Create GAMAP-style data blocks and return
      ; the THISFILEINFO and THISDATAINFO structures
      CRN_Save_Data, InType,   InGrid, Tau0,         Tau1,        $
                     FileName, Ilun,   Name,         LongName,    $
                     Unit,     Data,   ThisFileInfo, ThisDataInfo

      ; Append THISFILEINFO and THISDATAINFO into the
      ; FILEINFO and DATAINFO arrays of structures
      if ( FirstTime ) then begin
         FileInfo  = ThisFileInfo
         DataInfo  = ThisDataInfo        
         FirstTime = 0L
      endif else begin
         DataInfo  = [ DataInfo, ThisDataInfo ]
      endelse

Next:
      ; Undefine stuff
      UnDefine, Data
      UnDefine, Name
      UnDefine, LongName
      UnDefine, Unit
      UnDefine, ThisDataInfo
      UnDefine, ThisFileInfo
   endfor

   ;====================================================================
   ; Cleanup and quit
   ;====================================================================
 
   ; Close netCDF file
   NCDF_Close, fId

   ; Return NEWDATAINFO to calling program
   return, 1
end
 
