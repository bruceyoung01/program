; $Id: ctm_read_gmi.pro,v 1.1.1.1 2007/07/17 20:41:47 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_GMI
;
; PURPOSE:
;        Reads data blocks from a GMI netCDF file into GAMAP.
;        (This is an internal routine called from CTM_OPEN_FILE.)
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        CTM_READ_GMI, ILUN, FILENAME, FILEINFO, DATAINFO, [, Keywords ]
;
; INPUTS:
;        ILUN -> GAMAP file unit which will denote the GMI netCDF file.
;
;        FILENAME -> Name of the GMI netCDF grid file to be read.
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
;        ===============================================
;        CRG_Debug_Print   CRG_Get_Name   CRG_Get_Tau0       
;        CRG_Get_Tracer    CRG_Get_Data   CRG_Save_Data
;
;        External Subroutines Required:
;        ===============================================
;        CTM_GRID (function)   CTM_TYPE (function)
;        NCDF_GET (function)   TVMAP
;
; REQUIREMENTS:
;        Requires routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) Currently is hardwired to reading in data blocks 
;            from netCDF files created for the GMI comparison
;            study.  It is difficult to create a general netCDF
;            reader since there are many different ways to store
;            data w/ in a netCDF file.
;
; EXAMPLE:
;        ILUN     = 21
;        FILENAME = 'gmit4_maccm3_year_CO.nc'
;        CTM_READ_GMI, ILUN, FILENAME, FILEINFO, DATAINFO
;
;             ; Reads data from the netCDF file gmit4_maccm3_year_CO.nc
;             ; and stores it the FILEINFO and DATAINFO arrays of
;             ; structures.  If calling CTM_READ_GMI from CTM_OPEN_FILE,
;             ; then CTM_OPEN_FILE will append FILEINFO and DATAINFO
;             ; to the GAMAP common block.
; 
; MODIFICATION HISTORY:
;        bmy, 05 Nov 2003: GAMAP VERSION 2.01
;                          - initial version
;        bmy, 13 Feb 2004: GAMAP VERSION 2.01a
;                          - bug fix: now should get multiple months
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2003-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_read_gmi"
;-----------------------------------------------------------------------


pro CRG_Debug_Print, fId, InGrid
 
   ;====================================================================
   ; Internal routine CRG_DEBUG_PRINT compares coordinates computed
   ; from the MODEINFO and GRIDINFO structures vs. those read directly
   ; from the netCDF file.  A must for setting up new grids!
   ;====================================================================
 
   ; Model top pressure
   PTOP           = NCDF_Get( fId, 'pt' )
 
   ; Weird -- the MACCM3 model has PTOP=1000.0, 
   ; this screws up the ETA computation (bmy, 11/4/03)
   if ( Name eq 'MATCH' )      $
      then PTOP2 = 0.00468101  $
      else PTOP2 = PTOP
 
   ; Vertical coordinates for grid box edges
   Ap_E           = NCDF_Get( fId, 'ai' )
   Bp_E           = NCDF_Get( fId, 'bi' )
   Press_E        = ( Ap_E    * PTOP  ) + ( Bp_E  * PSurf )
   Eta_E          = ( Press_E - PTOP2 ) / ( PSurf - PTOP2 )
 
   ; Vertical coordinates for grid box centers
   Ap_C           = NCDF_Get( fId, 'am' )
   Bp_C           = NCDF_Get( fId, 'bm' )
   Press_C        = ( Ap_C    * PTOP  ) + ( Bp_C  * PSurf ) 
   Eta_C          = ( Press_C - PTOP2 ) / ( PSurf - PTOP2 )
   NV             = N_Elements( Press_C )
 
   ; Grid box longitude centers
   Lon_C          = NCDF_Get( fId, 'longitude_dim' )
   NL             = N_Elements( Lon_C )
   Lon_C          = Shift( Lon_C, NL/2L )
   Ind            = Where( Lon_C ge 180 )
   if ( Ind[0] ge 0 ) then Lon_C[Ind] = Lon_C[Ind] - 360.0
      
   ; Grid box longitude edges
   DLon           = Lon_C[3] - Lon_C[2]
   HalfLon        = DLon / 2.0 
   Lon_E          = FltArr( NL + 1L )
   Lon_E[0:NL-1L] = Lon_C[0:NL-1L] - HalfLon
   Lon_E[  NL   ] = Lon_C[  NL-1L] + HalfLon
      
   ; Grid box latitude centers
   Lat_C          = NCDF_Get( fId, 'latitude_dim' )
   NA             = N_Elements( Lat_C )
   if ( Lat_C[0    ] le -89.0 ) then Lat_C[0    ] = -89.0
   if ( Lat_C[NA-1L] ge  89.0 ) then Lat_C[NA-1L] =  89.0
 
   ; Grid box latitude edges
   DLat           = Lat_C[4] - Lat_C[3]
   HalfLat        = DLat / 2.0
   Lat_E          = FltArr( NA + 1L )
   Lat_E[0:NA-1L] = Lat_C[0:NA-1L] - HalfLat
   Lat_E[  NA   ] = Lat_C[  NA-1L] + HalfLat
   if ( Lat_E[0 ] lt -90.0 ) then Lat_E[0 ] = -90.0
   if ( Lat_E[NA] gt  90.0 ) then Lat_E[NA] =  90.0
 
   ; Test for halfpolar grid
   Dlat0          = Lat_E[1] - Lat_E[0]
   HalfPolar      = ( Dlat0 ne Dlat )
 
   ; Test if the first grid box is centered on -180 degrees (date line)
   Center180      = ( Lon_C[0] eq -180 )
 
   ; Print debug info
   print, '--'
   Print, 'PRESS_E     : ', Press_E
   print, 'INGRID.PEDGE: ', InGrid.PEdge
   print, '--'
   Print, 'PRESS_C     : ', Press_C
   print, 'INGRID.PMID : ', InGrid.PMid
   print, '--'
   Print, 'PRESS_F     : ', Press_F
   print, '--'
   print, 'LON_E       : ', Lon_E
   print, 'INGRID.XEDGE: ', InGrid.XEdge
   print, '--'
   print, 'LON_C       : ', Lon_C
   print, 'INGRID.XMID : ', InGrid.XMid
   print, '--'
   print, 'LAT_E       : ', Lat_E
   print, 'INGRID.YEDGE: ', InGrid.YEdge
   print, '--'
   print, 'LAT_C       : ', Lat_C
   print, 'INGRID.YMID : ', InGrid.YMid
   print, '--'
   print, ( Ap_E * PTOP ), Format='(4(f13.6,'',''))'
   print, '--'
   print, Bp_E,            Format='(4(f13.6,'',''))'
   print, 'PTOP        : ', PTOP
end
 
;------------------------------------------------------------------------------
 
pro CRG_Get_Name, fId, ModelName, Resolution
 
   ;====================================================================
   ; Internal routine GR_GET_NAME returns the model name and
   ; resolution of the data in a netCDF file from GMI
   ;====================================================================
 
   ; Read the METDATA_NAME field from the netCDF file
   vId = NCDF_VarId( fId, 'metdata_name' )
   if ( vId ge 0 ) then begin
      NCDF_VarGet, fId, vId, MetDataName, _EXTRA=e
   endif else begin
      Message, 'Could not find metdata_name in netCDF file!'
   endelse


   MetDataName = NCDF_Get( fId, 'metdata_name' )
   MetDataName = StrUpCase( StrTrim( MetDataName, 2 ) )
 
   ; Define name for CTM_TYPE
   if ( StrPos( MetDataName, 'DAO'   ) ge 0 ) then ModelName = 'GEOS_STRAT'
   if ( StrPos( MetDataName, 'GISS'  ) ge 0 ) then ModelName = 'GISS_II_PRIME'
   if ( StrPos( MetDataName, 'GMAO'  ) ge 0 ) then ModelName = 'GEOS_STRAT'
   if ( StrPos( MetDataName, 'MATCH' ) ge 0 ) then ModelName = 'MATCH'
 
   ; Define RESOLUTION for CTM_TYPE
   if ( StrPos( MetDataName, '4X5'   ) ge 0 ) then Resolution = 4
   if ( StrPos( MetDataName, '2X25'  ) ge 0 ) then Resolution = 2
end
 
;------------------------------------------------------------------------------
 
pro CRG_Get_Tau0, fId, InType, Tau0
 
   ;====================================================================
   ; Internal routine CRG_GET_TAU0 returns an array of TAU0 values
   ; (hours since 1 Jan 1985) for each data block in the netCDF file.
   ;====================================================================
 
   ; Read netCDF file header
   Header      = NCDF_Get( fId, 'hdr' )

   ; Get YYYYMMDD and HHMMSS values
   NYMD        = Reform( Header[1,*] ) 
   NHMS        = Reform( Header[2,*] )
   N_Mon       = N_Elements( NYMD )

   ; For years prior to 2000, convert e.g. "990101" to "19990101" 
   Ind         = Where( NYMD ge 800000L ) 
   if ( Ind[0] ge 0 ) then NYMD[Ind] = NYMD[Ind] + 19000000L
 
   ; For years 2000-, convert e.g. "101" to "20000101"
   Ind         = Where( NYMD lt 800000L )
   if ( Ind[0] ge 0 ) then NYMD[Ind] = NYMD[Ind] + 20000000L
   
   ; Define GISS or GEOS flags for NYMD2TAU
   GEOS     = ( InType.Family eq 'GEOS' )
   GISS     = 1L - GEOS 
  
   ; Create array for TAU0 -- with one extra element!
   Tau0        = FltArr( N_Mon + 1L )
 
   ; Compute TAU0 value from each NYMD, NHMS pair
   for T = 0L, N_Mon-1L do begin
      Tau0[T]  = Nymd2Tau( NYMD[T], NHMS[T], GISS=GISS, GEOS=GEOS )
   endfor
 
   ;====================================================================
   ; Now we have to add the TAU0 value for 1 month beyond the last
   ; value of NYMD.  This is necessary because GAMAP requires a
   ; starting and ending time for each diagnostic interval.  Therefore,
   ; there will one more TAU0 value than there are entries in the
   ; NYMD array.
   ;
   ; Use the astronomical Julian date routines JULDAY and CALDAT,
   ; since these handle the end-of-year, leap-year, and end-of-century
   ; transitions correctly.
   ;====================================================================
 
   ; Split TAU0 into structure w/ YYYY, MM, DD, hh, mm, ss tags 
   Result      = Tau2YYMMDD( Tau0[N_Mon-1L], GISS=GISS, GEOS=GEOS )
 
   ; Compute month & year 1 month after JD0
   Month1      = Result.Month + 1L
   Year1       = Result.Year
   if ( Month1 gt 12 ) then begin
      Month1   = 1L
      Year1    = Year1 + 1L
   endif
 
   ; Astronomical Julian Day 1 month later from the last TAU0 value
   JD1         = JulDay( Month1, Result.Day, Year1 )
  
   ; Convert JD1 back into YYYY, MM, DD
   CalDat, JD1, MM, DD, YYYY
  
   ; Convert YYYY, MM, DD into YYYYMMDD
   NewNYMD     = YYYY*10000L + MM*100L + DD
 
   ; Convert YYYYMMDD to TAU value and store in TAU0
   Tau0[N_Mon] = Nymd2Tau( NewNYMD, GISS=GISS, GEOS=GEOS )
end
 
;------------------------------------------------------------------------------
 
pro CRG_Get_Tracer, fId, VarName, Category, Tracer, TrcName
 
   ;====================================================================
   ; Internal routine CRG_GET_TRACER returns the tracer number and
   ; tracer name for a given tracer and category.
   ;====================================================================

   ; Get the tracer name.  For constituent data or noon data,
   ; we have to read the labels as a separate netCDF variable.
   ; VARNAME is already in uppercase.  
   case ( VarName ) of 
      'CONST' : Label = NCDF_Get( fId, 'const_labels' )
      'NOON'  : Label = NCDF_Get( fId, 'noon_labels'  )
      else    : Label = VarName
   endcase
      
   ; Strip off extra spaces
   Label = StrUpCase( StrTrim( Label, 2 ) )
 
   ; Truncate LABEL to 6 letters for compatibility w/ GAMAP
   case ( Label ) of
      'PSF'        : Label = 'PSURF'
      'KEL'        : Label = 'TMPU'
      'DRY_DEPOS'  : Label = 'DRYDEP'
      'WET_DEPOS'  : Label = 'WETDEP'
      'SURF_EMISS' : Label = 'SFCEMS'
      'METWATER'   : Label = 'METH2O'
      'MASS'       : Label = 'AIRMAS'
      'MCOR'       : Label = 'DXYP'
      else         : ; Nothing
   endcase

   ; Get the diagnostic offset for this category
   CTM_DiagInfo, Category, Offset=Offset

   ; Get the tracer number
   CTM_TracerInfo, Label, Index=Index

   ; If INDEX returns more than one tracer number, then only
   ; pull out the one which has the correct diagnostic offset
   Ind = Where( Index gt Offset and Index lt Offset+100L )
   if ( Ind[0] ge 0 ) then begin
      Tracer = Index[Ind] 
   endif else begin
      S = 'Could not find tracer number for variable ' + VarName
      Message, S
   endelse

   ; Return GAMAP-style tracer name
   TrcName = Label
end
 
;------------------------------------------------------------------------------
 
function CRG_Get_Data, fId, vId, InGrid, VarName, Unit, Data
 
   ;====================================================================
   ; Internal routine CRG_GET_DATA reads a data array from the netCDF
   ; file.  It shifts it to the GAMAP horizontal grid (starting from 
   ; the date line) and also crops extra dimensions.
   ;====================================================================
 
   ; Structure w/ info about this variable
   VarInfo = NCDF_VarInq( fId, vId )
      
   ; Variable name
   VarName = StrUpCase( StrTrim( VarInfo.Name, 2 ) )

   ;-------------------------- 
   ; Read netCDF variable
   ;-------------------------- 
   NCDF_VarGet, fId, vId, Data, _EXTRA=e

   ; Get size of data array
   SData = Size( Data, /Dim )

   ; Only consider global data arrays, since the lat/lon/alt
   ; indices will be defined by MODELINFO and GRIDINFO structures
   if ( N_Elements( SData ) lt 2 OR SData[0] ne InGrid.IMX ) then return, 0

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

   ; Crop extra dimensions
   Data  = Reform( Data )
   
   ; Shift DATA so that the first longitude is on the date line
   ; We assume that longitude is the 1st dimension
   case ( Size( Data, /N_Dim ) ) of
      1: Data = Shift( Data, InGrid.IMX/2L          )
      2: Data = Shift( Data, InGrid.IMX/2L, 0       )
      3: Data = Shift( Data, InGrid.IMX/2L, 0, 0    )
      4: Data = Shift( Data, InGrid.IMX/2L, 0, 0, 0 )
   endcase
 
   ; Replace GMI unit strings w/ GAMAP-like unit strings
   if ( N_Elements( Unit ) gt 0 ) then begin
      if ( Unit eq 'volume mixing ratio' ) then Unit = 'v/v'
      if ( Unit eq 'mb'                  ) then Unit = 'hPa'
      if ( Unit eq 'kg/m^2/pr_nc_period' ) then Unit = 'kg/m2/s'
   endif

   ; ### Debug -- print map (change level & time as necessary)
   ;if ( Debug ) then begin
   ;   TvMap, Data[*,*,0,01], InGrid.XMid, InGrid.YMid, $
   ;      /CBar, /Countries, /Coasts, /Sample, /Iso, /Grid, $
   ;      Div=4, CBUnit=Unit
   ;endif

   ; Return successfully
   return, 1
end
 
;------------------------------------------------------------------------------
 
pro CRG_Save_Data, fId,          Ilun,        FileName, VarName,    $
                   InType,       InGrid,      Unit,     Data,       $
                   DataInfo,     FileInfo,    FirstTime

   ;====================================================================
   ; Internal routine CRG_SAVE_DATA create GAMAP-style data blocks 
   ; which are then appended to the global GAMAP common block
   ;====================================================================

   ; Define GAMAP-style category string
   case ( InType.Name ) of 
      'GISS_II_PRIME' : Category = 'GMI-GISS'
      'GEOS_STRAT'    : Category = 'GMI-GMAO'
      'MATCH'         : Category = 'GMI-NCAR'
      else            : Message, 'Invalid model name for GMI data!'
   endcase
 
   ; Get TAU, tracer number, and tracer name
   CRG_Get_Tau0,   fId, InType,  Tau0
   CRG_Get_Tracer, fId, VarName, Category, Tracer, TrcName
 
   ;====================================================================
   ; Loop over all TAU0 values (note: there is one more TAU0 value
   ; than months represented in the file, since GAMAP needs to 
   ; specify the start and end time of each diagnostic interval
   ;====================================================================
   for T = 0, N_Elements( Tau0 ) - 2L  do begin
 
      ; Extract data for this month 
      case( Size( Data, /N_Dim ) ) of
 
         ; 2-D data block
         2: begin
            ThisData = Data
            ThisDim  = [ InGrid.IMX, InGrid.JMX, 0, 0 ]
         end

         ; 3-D data block
         3: begin
            ThisData = Data[*,*,T]
            ThisDim  = [ InGrid.IMX, InGrid.JMX, 0, 0 ]
         end
 
         ; 4-D data block
         4: begin
            ThisData = Data[*,*,*,T]
            ThisDim  = [ InGrid.IMX, InGrid.JMX, InGrid.LMX, 0 ]
         end
 
      endcase
 
      ; Create a DATAINFO structure for this data block,
      ; which will be appended to the GAMAP global common block
      Success  = CTM_Make_DataInfo( ThisData,              $
                                    ThisDataInfo,          $
                                    ThisFileInfo,          $
                                    ModelInfo=InType,      $
                                    GridInfo=InGrid,       $
                                    DiagN=Category,        $
                                    Tracer=Tracer,         $
                                    TrcName=TrcName,       $
                                    Tau0=Tau0[T],          $
                                    Tau1=Tau0[T+1],        $
                                    Unit=Unit,             $
                                    Dim=ThisDim,           $
                                    First=[1L, 1L, 1L],    $
                                    FileName=FileName,     $
                                    FileType=201,          $
                                    Format='GMI netCDF',   $
                                    Ilun=Ilun,             $
                                    /No_Global )
 
      ; Error check
      if ( not Success ) then begin
         S = 'Could not create datainfo structure for tracer ' + TrcName
         Message, S
      endif
      
      ; Add THISDATAINFO and THISFILEINFO structures to 
      ; the DATAINFO and FILEINFO arrays of structures
      if ( FirstTime ) then begin
         FileInfo  = ThisFileInfo
         DataInfo  = ThisDataInfo
         FirstTime = 0L
      endif else begin
         DataInfo  = [ DataInfo, ThisDataInfo ]
      endelse
        
      ; Undefine stuff 
      UnDefine, ThisDataInfo
      UnDefine, ThisFileInfo
      UnDefine, ThisData
      UnDefine, ThisDim
   endfor
end
 
;------------------------------------------------------------------------------
 
function CTM_Read_GMI, Ilun, FileName, FileInfo, DataInfo, _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, NCDF_Get
 
   ; Test if netCDF library ships w/ this version of IDL
   if ( not NCDF_Exists() ) then begin
      Message, 'netCDF is not supported in this IDL version!', /Continue
      return, -1
   endif

   ; Keywords
   Debug = Keyword_Set( Debug )

   ; Make sure ILUN is odd -- this will replicate 
   ; the behavior of GAMAP with binary files!
   if ( Ilun mod 2 eq 0 ) then Ilun = Ilun + 1

   ;====================================================================
   ; Open file and get information about the file
   ;====================================================================
 
   ; Assume approx surface pressure of 1000 hPa (GMI does!)
   PSurf     = 1000.0
 
   ; Open netCDF file
   fId       = NCDF_Open( FileName )
 
   ; Get Modelname and resolution
   CRG_Get_Name, fId, ModelName, Resolution
 
   ; Approximate pressures at grid box centers
   Press_F   = NCDF_Get( fId, 'sigma_dim' )
   NV        = N_Elements( Press_F )
 
   ; Create MODELINFO and GRIDINFO structures for GAMAP
   InType    = CTM_Type( ModelName, Resolution=Resolution, NLayers=NV )
   InGrid    = CTM_Grid( InType, PSurf=Psurf )  
 
   ;====================================================================
   ; Read data from the netCDF file and create GAMAP-style data blocks
   ; which will be appended to the global GAMAP common block
   ;====================================================================

   ; Get a structure w/ information about this variable
   VarInfo = NCDF_Inquire( fId )

   ; First time flag
   FirstTime = 1L

   ; Loop over all netCDF variables
   for vId = 0L, VarInfo.NVars-1L do begin

      ; Read 3-D or 4-D data blocks from the file
      Success = CRG_Get_Data( fId, vId, InGrid, VarName, Unit, Data )

      ; Save data block into GAMAP global common blocks
      if ( Success ) then begin
         
         ; Get THISDATAINFO and THISFILEINFO structures for this data block
         CRG_Save_Data, fId,          Ilun,        FileName, VarName,  $
                        InType,       InGrid,      Unit,     Data,     $
                        DataInfo,     FileInfo,    FirstTime

        ; Reset First-time flag
        FirstTime = 0L

      endif
      
      ; Undefine stuff
      UnDefine, VarName
      UnDefine, Unit
      UnDefine, Data
   endfor

   ;====================================================================
   ; Cleanup and quit
   ;====================================================================
 
   ; Close netCDF file
   NCDF_Close, fId
 
   ; Return w/ success status
   return, 1
end
 
