; $Id: ctm_read_eosgr.pro,v 1.4 2004/06/03 17:58:08 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_EOSGR
;
; PURPOSE:
;        Reads data blocks from a HDF-EOS Grid file into GAMAP.
;        (This is an internal routine which is called by CTM_OPEN_FILE.)
;        
; CATEGORY:
;        GAMAP
;
; CALLING SEQUENCE:
;        CTM_READ_EOSGR, ILUN, FILENAME, FILEINFO, DATAINFO, [, Keywords ]
;
; INPUTS:
;        ILUN -> GAMAP file unit which will denote the HDF-EOS file.
;
;        FILENAME -> Name of the HDF-EOS grid file to be read.
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
;        _EXTRA=e -> Picks up any extra keywords
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        =====================================================
;        CRE_Get_DimInfo   CRE_Get_TracerInfo   CRE_Save_Data
;
;        External Subroutines Required:
;        =====================================================
;        CTM_GRID          (function)   CTM_TYPE (function)
;        CTM_MAKE_DATAINFO (function)   STRRIGHT (function)
;
; REQUIREMENTS:
;        Requires routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) Currently is set up to read HDF-EOS files containing
;            GMAO met data files.  You must have all possible met
;            field names listed in your "tracerinfo.dat" file or 
;            else you will get an "Invalid Selection" error.
;                
; EXAMPLE:
;        ILUN     = 21
;        FILENAME = 'a_llk_03.tsyn2d_mis_x.t20030801'
;        CTM_READ_EOSGR, ILUN, FILENAME, FILEINFO, DATAINFO
;
;             ; Reads data from HDF-EOS file a_llk_03.tsyn2d_mis_x.t20030801
;             ; and stores it the FILEINFO and DATAINFO arrays of
;             ; structures.  If calling CTM_READ_GMI from CTM_OPEN_FILE,
;             ; then CTM_OPEN_FILE will append FILEINFO and DATAINFO
;             ; to the GAMAP common block.
;
; MODIFICATION HISTORY:
;        bmy, 12 Nov 2003: GAMAP VERSION 2.01
;                          - initial version
;        bmy, 19 Feb 2004: GAMAP VERSION 2.01a
;                          - added c402_rp_02 to the assim list
;                          - bug fix: use DEFAULT keyword for SELECT_MODEL
;        bmy, 09 Mar 2004: GAMAP VERSION 2.02
;                          - now test for "GEOS3", "GEOS4" strings in
;                            the file name to determine model type
;                          - now undefine variables after use
;                          - now make sure that data block begins at the
;                            date line and has longitude values in the
;                            range [-180,180] degrees.
;                          - always ensure that L=1 is the surface level
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
; with subject "IDL routine ctm_read_eosgr"
;-----------------------------------------------------------------------

 
pro CRE_Get_DimInfo, gId,      Info, FileName, ModelInfo, $
                     GridInfo, Tau0, LMX,      DimFlip

   ;====================================================================
   ; Internal routine CRE_GET_DIMINFO attempts to get the spatial
   ; and temporal grid dimensions from the HDF-EOS grid structure. 
   ; It returns the MODELINFO and GRIDINFO structures, which define
   ; the spatial grid, plus an array of TAU0 values.
   ;====================================================================

   ; Initialize
   ModelName = ''
   XDim      = -1L
   YDim      = -1L
   ZDim      = -1L
   Time      = -1L
   LMX       = 0L
   DimFlip   = [ 0L, 0L, 0L ]

   ;------------
   ; Get X dim
   ;------------
   if ( StrPos( Info.Field_Names, 'XDim' ) ge 0 ) then begin

      ; Read XDIM
      Success = EOS_GD_ReadField( gId, 'XDim', XDim )
      IMX     = N_Elements( XDim )

      ; Shift the longitudes so that we start at the date 
      ; line -- this is the std GAMAP convention (bmy, 3/9/04)
      if ( XDim[0] eq 0.0 ) then begin
         DimFlip[0] = IMX/2L
         XDim       = Shift( XDim, DimFlip[0] )
      endif

      ; Also make sure XDIM is between -180 and 180 (bmy, 3/9/04)
      if ( Max( XDim ) gt 180.0 ) then begin
         Ind = Where( XDim ge 180.0 )
         if ( Ind[0] ge 0 ) then XDim[Ind] = XDim[Ind] - 360.0 
      endif
      
   endif

   ;------------
   ; Get Y dim
   ;------------
   if ( StrPos( Info.Field_Names, 'YDim' ) ge 0 ) then begin
      Success = EOS_GD_ReadField( gId, 'YDim', YDim )
      JMX     = N_Elements( YDim )
   endif

   ;------------
   ; Get Z dim
   ;------------   
   if ( StrPos( Info.Field_Names, 'ZDim' ) ge 0 ) then begin

      ; First look for "ZDim" field
      Success = EOS_GD_ReadField( gId, 'ZDim', ZDim )
      LMX     = N_Elements( ZDim )
      No_Vert = 0

   endif else if ( StrPos( Info.Field_Names, 'Height' ) ge 0 ) then begin

      ; If not successful , then look for "Height" field
      Success = EOS_GD_ReadField( gId, 'Height', ZDim )
      LMX     = N_Elements( ZDim )
      No_Vert = 0

   endif else begin

      ; If not successful, then the grid is 2-D
      No_Vert = 1

   endelse

   ;------------
   ; Flip Z dim
   ;------------
   if ( LMX gt 0 ) then begin

      ; Find the location of the max value of ZDIM
      Ind = Where( ZDim eq Max( ZDim ) )

      ; If ZDIM is in hPa, then the max value should be located at the 
      ; surface (i.e. ZDIM[0]).  If this is not the case, then we must
      ; flip ZDIM vertically.  Set FLIP_DIM accordingly. (bmy, 3/9/04)
      if ( Ind[0] ne 0 ) then begin
         DimFlip[2] = 3 
         ZDim       = Reverse( Temporary( ZDim ) )
      endif
   endif

   ;------------
   ; Get T dims
   ;------------   
   if ( StrPos( Info.Field_Names, 'Time' ) ge 0 ) then begin
      Success = EOS_GD_ReadField( gId, 'Time', Time )
      TMX     = N_Elements( Time ) 
   endif
   
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

   ; Look for assimilation string to determine model name
   if ( StrPos( FileName, 'GEOS3'      ) ge 0 ) then ModelName = 'GEOS3'
   if ( StrPos( FileName, 'a_llk_01'   ) ge 0 ) then ModelName = 'GEOS3'
   if ( StrPos( FileName, 'a_llk_02'   ) ge 0 ) then ModelName = 'GEOS3'
   if ( StrPos( FileName, 'a_llk_03'   ) ge 0 ) then ModelName = 'GEOS4'
   if ( StrPos( FileName, 'a_flk_03'   ) ge 0 ) then ModelName = 'GEOS3'
   if ( StrPos( FileName, 'a_llk_04'   ) ge 0 ) then ModelName = 'GEOS4'
   if ( StrPos( FileName, 'a_flk_04'   ) ge 0 ) then ModelName = 'GEOS4'
   if ( StrPos( FileName, 'c402_rp_02' ) ge 0 ) then ModelName = 'GEOS4'
   if ( StrPos( FileName, 'GEOS4'      ) ge 0 ) then ModelName = 'GEOS4'

   ; If we can't find the modelname, then ask the user
   if ( ModelName eq '' ) $
      then ModelName = Select_Model( Default='GEOS3 4x5 (48L)' )

   ; Define MODELINFO and GRIDINFO structures
   ModelInfo = CTM_Type( ModelName, Res=[ DI, DJ ]      )
   GridInfo  = CTM_Grid( ModelInfo, No_Vertical=No_Vert )

   ; Date and time
   NYMD = Long( StrRight( FileName, 8 ) )
   NHMS = Long( ( Time / 1440d0 ) * 240000L )

   ; TAU values
   Tau0 = DblArr( TMX )
   for T = 0L, TMX-1L do begin
      Tau0[T] = NYMD2Tau( NYMD, NHMS[T], /Geos )
   endfor

end

;------------------------------------------------------------------------------

pro CRE_Get_TracerInfo, Field,   Name2D,   Tracer2D, Unit2D,   $
                        Name3D,  Tracer3D, Unit3D,   Category, $
                        TrcName, Tracer,   Unit

   ;====================================================================
   ; Internal function CRE_GET_TRACERINFO returns the category, name,
   ; tracer number, and unit for a field contained in the HDF-EOS file.
   ;====================================================================

   ; Test tracer name against known 2-D and 3-D tracer names
   Ind2D = Where( Name2D eq Field )
   Ind3D = Where( Name3D eq Field )

   if ( Ind2D[0] ge 0 ) then begin

      ; Tracer is 2-D
      Category = 'GMAO-2D'
      Tracer   = Tracer2D[Ind2D]
      TrcName  = Name2D[Ind2D]
      Unit     = Unit2D[Ind2D]
      
   endif else if ( Ind3D[0] ge 0 ) then begin
         
      ; Tracer is 3-D
      Category = 'GMAO-3D$'
      Tracer   = Tracer3D[Ind3D]
      TrcName  = Name3D[Ind3D]
      Unit     = Unit3D[Ind3D]
      
   endif else begin
      
      ; Could not locate tracer; stop w/ err msg
      S = 'Could not find information for ' + Field
      Message, S
      
   endelse
end

;------------------------------------------------------------------------------

pro CRE_Save_Data, gId,       Info,     Ilun,     $
                   ModelInfo, GridInfo, Tau0,     $
                   Name2D,    Tracer2D, Unit2D,   $
                   Name3D,    Tracer3D, Unit3D,   $
                   FileName,  LMX,      DimFlip,  $
                   FileInfo,  DataInfo          
              
   ;====================================================================
   ; Internal function CRE_SAVE_DATA creates GAMAP-style data blocks 
   ; and returns the THISDATAINFO structure to the main program.
   ;
   ; NOTE: Assumes global-size data blocks (which is what routine
   ;       BPCH2NC generates).
   ;====================================================================

   ; First-time flag
   FirstTime = 1L

   ; Define Lon, Lat dims for convenience
   IMX       = GridInfo.IMX
   JMX       = GridInfo.JMX

   ; Get the names of each data field
   Fields    = StrBreak( Info.Field_Names, ',' )

   ;------------------
   ; Loop over fields
   ;------------------
   for N = 0L, N_Elements( Fields )-1L do begin

      ; Skip over dimension fields
      if ( Fields[N] eq 'XDim'   ) then goto, Next_N
      if ( Fields[N] eq 'YDim'   ) then goto, Next_N
      if ( Fields[N] eq 'ZDim'   ) then goto, Next_N
      if ( Fields[N] eq 'Height' ) then goto, Next_N
      if ( Fields[N] eq 'Time'   ) then goto, Next_N

      ; Get category, name, and tracer number for this field
      CRE_Get_TracerInfo, Fields[N], Name2D,   Tracer2D, Unit2D,   $
                          Name3D,    Tracer3D, Unit3D,   Category, $
                          TrcName,   Tracer,   Unit

      ; Read data block from the HDF-EOS file 
      Success = EOS_GD_ReadField( gId, Fields[N], Data )

      ; Error check
      if ( Success ne 0 ) then begin
         S = 'Could not read ' + Fields[N] + ' from disk!'
         Message, S
      endif

      ; Strip extraneous dimensions
      Data = Reform( Data )

      ;-----------------
      ; Loop over times
      ;-----------------
      for T = 0L, N_Elements( Tau0 )-1L do begin

         ; Size of the DATA array
         SData = Size( Data, /Dim )
         
         ; Get DIM vector for CTM_MAKE_DATAINFO
         case ( N_Elements( SData ) ) of 

            ;------------------
            ; 2-D spatial data 
            ;------------------
            3: begin
               ThisData = Data[*,*,T]
               ThisDim  = [ IMX, JMX, 0, 0 ]

               ; Flip data block in longitude so that it 
               ; starts at the date line (bmy, 3/9/04)
               if ( DimFlip[0] gt 0 ) then begin
                  ThisData = Shift( Temporary( ThisData ), DimFlip[0], 0L )  
               endif
            end

            ;------------------
            ; 3-D spatial data
            ;------------------
            4: begin
               ThisData = Data[*,*,*,T]
               ThisDim  = [ IMX, JMX, LMX, 0 ]

               ; Flip data block in longitude so that it 
               ; starts at the date line (bmy, 3/9/04)            
               if ( DimFlip[0] gt 0 ) then begin
                  ThisData = Shift( Temporary( ThisData ), DimFlip[0], 0L, 0L )
               endif

               ; Flip data block in altitude so that L=1
               ; is the surface level (bmy, 3/9/04)
               if ( DimFlip[2] gt 0 ) then begin
                  ThisData = Reverse( Temporary( ThisData ), DimFlip[2] )
               endif
            end
           
         endcase
       
         ; Create THISFILEINFO and THISDATAINFO structures
         Success  = CTM_Make_DataInfo( Float( ThisData ),     $
                                       ThisDataInfo,          $
                                       ThisFileInfo,          $
                                       ModelInfo=ModelInfo,   $
                                       GridInfo=GridInfo,     $
                                       DiagN=Category,        $
                                       Tracer=Tracer,         $
                                       TrcName=TrcName,       $
                                       Tau0=Tau0[T],          $
                                       Tau1=Tau0[T],          $
                                       Unit=Unit,             $
                                       Dim=ThisDim,           $
                                       First=[1L, 1L, 1L],    $
                                       Filename=FileName,     $
                                       FileType=301,          $
                                       Format='HDF-EOS GRID', $
                                       Ilun=Ilun,             $
                                       /No_Global )
      
         ; Error check
         if ( not Success ) then begin
            S = 'Could not create datainfo structure for tracer ' + TrcName
            Message, S
         endif

         ; Append THISFILEINFO and THISDATAINFO into the
         ; FILEINFO and DATAINFO arrays of structures
         if ( FirstTime ) then begin
            FileInfo = ThisFileInfo
            DataInfo = ThisDataInfo
            FirstTime = 0L
         endif else begin
            DataInfo  = [ DataInfo, ThisDataInfo ]
         endelse
                  
         ; Undefine stuff
         UnDefine, ThisDim
         UnDefine, ThisData
         UnDefine, ThisDataInfo
         UnDefine, ThisFileInfo

      endfor

      ; Undefine more stuff
      UnDefine, Data
      UnDefine, SData
      UnDefine, Success

Next_N:
   endfor

   ; Return to main program
   return 
end
 
;-----------------------------------------------------------------------------
 
function CTM_Read_EOSGR, Ilun, FileName, FileInfo, DataInfo, _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, Sort_Stru

   ; Test if netCDF library ships w/ this version of IDL
   if ( not EOS_Exists() ) then begin
      Message, 'HDF-EOS is not supported in this IDL version!', /Continue
      return, -1
   endif

   ; Keywords
   if ( N_Elements( Ilun     ) ne 1 ) then Message, 'ILUN not passed!'
   if ( N_Elements( FileName ) ne 1 ) then Message, 'FILENAME not passed!'

   ; Make sure ILUN is odd -- this will replicate 
   ; the behavior of GAMAP with binary files!
   if ( Ilun mod 2 eq 0 ) then Ilun = Ilun + 1

   ; First-time flag
   FirstTime = 1L

   ;====================================================================
   ; Get a list of 2-D and 3-D tracers
   ;====================================================================

   ; First look for the 2-D field names listed in the setup files
   CTM_TracerInfo, /All, Name=Name, Index=Tracer, Unit=Unit
   CTM_DiagInfo,  'GMAO-2D', Offset=Offset, Spacing=Spacing
   Ind      = Where( Tracer ge Offset AND Tracer le Offset+Spacing )
   Tracer2D = Tracer[Ind] 
   Name2D   = Name[Ind]
   Unit2D   = Unit[Ind]
   
   ; Now look for the 3-D field names listed in the setup files
   CTM_DiagInfo,  'GMAO-3D$', Offset=Offset, Spacing=Spacing, Unit=Unit
   Ind      = Where( Tracer ge Offset AND Tracer le Offset+Spacing )
   Tracer3D = Tracer[Ind]
   Name3D   = Name[Ind]
   Unit3D   = Unit[Ind]

   ;====================================================================
   ; Open file and get information about the file
   ;====================================================================
   fId = EOS_GD_Open( FileName, /Read )

   ; Get information about all of the grids in the file
   GD_Info = EOS_GD_InqGrid( FileName, GridList )
 
   ; Loop over the number of grids in the file
   for N = 0L, N_Elements( GridList )-1L do begin

      ; Name of the EOS grid
      GridName = StrTrim( GridList[N], 2 )

      ;-----------------------
      ; Attach to EOS grid
      ;-----------------------
      gId = EOS_GD_Attach( fId, GridName )

      ; Error check
      if ( gId lt 0 ) then begin
         S = 'Could not attach to grid name ' + GridName
         Message, S
      endif

      ;-----------------------
      ; Get info about grid
      ;-----------------------
      Success = EOS_GD_Query( FileName, GridName, Info ) 

      ; EOS_GD_QUERY returns 1 if successful, 0 otherwise
      if ( Success ne 1 ) then begin
         S = 'Could not query the HDF-EOS grid ' + GridName
         Message, S
      endif

      ;-----------------------
      ; Get space & time dims
      ;-----------------------
      CRE_Get_DimInfo, gId,      Info, FileName, ModelInfo, $
                       GridInfo, Tau0, LMX,      Flip_Dim

      ;-----------------------
      ; Store data into GAMAP
      ;-----------------------
      CRE_Save_Data, gId,          Info,        Ilun,      $
                     ModelInfo,    GridInfo,    Tau0,      $
                     Name2D,       Tracer2D,    Unit2D,    $
                     Name3D,       Tracer3D,    Unit3D,    $
                     FileName,     LMX,         Flip_Dim,  $
                     ThisFileInfo, ThisDataInfo
      
      ; If there are more than one HDF-EOS grids in this file,
      ; we have to concatenate the FILEINFO and DATAINFO arrays
      if ( FirstTime ) then begin
         FileInfo  = ThisFileInfo
         DataInfo  = ThisDataInfo
         FirstTime = 0L
      endif else begin
         FileInfo  = [ FileInfo, ThisFileInfo ]
         DataInfo  = [ DataInfo, ThisDataInfo ]
      endelse

      ;-----------------------
      ; Detach from EOS grid
      ;-----------------------
      Success = EOS_GD_Detach( gId )

      ; EOS_GD_DETACH returns 0 if successful, -1 otherwise
      if ( Success ne 0 ) then begin
         S = 'Could not detach from grid name ' + GridName
         Message, S
      endif

      ; Undefine stuff
      UnDefine, gId
      UnDefine, GridName
      UnDefine, Info
      UnDefine, ThisFileInfo
      UnDefine, ThisDataInfo

   endfor
 
   ;====================================================================
   ; Cleanup and quit
   ;====================================================================

   ; Undefine stuff
   UnDefine, GD_Info
   UnDefine, Name2D
   UnDefine, Tracer2D
   UnDefine, Unit2D
   UnDefine, Name3D
   UnDefine, Tracer3D
   UnDefine, Unit3D
 
   ; Close HDF-EOS file
   Success = EOS_GD_Close( fId )

   ; EOS_GD_CLOSE returns 0 if successful, -1 otherwise
   if ( Success ne 0 ) then begin
      S = 'Could not close HDF-EOS file ' + FileName
      Message, S
   endif

   ; Return NEWDATAINFO to calling program
   return, -1
end
 
