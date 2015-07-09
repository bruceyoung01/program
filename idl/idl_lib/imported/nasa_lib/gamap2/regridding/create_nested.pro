; $Id: create_nested.pro,v 1.3 2008/02/12 21:59:24 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CREATE_NESTED
;
; PURPOSE:
;        Reads data from a file and trims it down horizontally to a 
;        "nested" CTM grid size.  Vertical resolution is not affected.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        CREATE_NESTED [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the input file containing data to be 
;             trimmed down to "nested" model grid resolution.  If 
;             omitted, a dialog box will prompt the user to supply
;             a filename.
;
;        OUTFILENAME -> Name of the file that will contain trimmed
;             data on the "nested" model grid.  OUTFILENAME will be
;             in binary punch resolution.  If omitted, a dialog box 
;             will prompt the user to supply a filename.
;
;        XRANGE -> A 2-element vector containing the minimum and
;             maximum box center longitudes which define the nested
;             model grid. Default is [-180,180].
;
;        YRANGE -> A 2-element vector containing the minimum and
;             maximum box center latitudes which define the nested
;             model grid. Default is [-180,180].
;
;        /CHINA -> Set this switch to create nested-grid met data
;             files for the CHINA region.  Setting this switch will
;             override the XRANGE and YRANGE keywords.
;
;        /NAMER -> Set this switch to create nested-grid met data
;             files for the NORTH AMERICA region.  Setting this switch 
;             will override the XRANGE and YRANGE keywords.
;
;        /EUROPE -> Set this switch to create nested-grid met data
;             files for the EUROPE region.  Setting this switch will
;             override the XRANGE and YRANGE keywords.
;             ### NOTE: Need to define the region as of 10/4/07 ###
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        ================================================
;        CN_GETRANGES
; 
;        External Subroutines Required:
;        ================================================
;        CTM_CLEANUP         CTM_GET_DATA
;        CTM_WRITEBPCH       CTM_MAKE_DATAINFO (function)
;        GETMODELANDGRIDINFO   
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Works for the following types of data blocks:
;            (a) 2-D "zonal-mean" (latitude-altitude)
;            (b) 2-D "horizontal" (longitude-latitude)
;            (c) 3-D "global"     (longitude-latitude-altitude)
;
; EXAMPLE:
;        (1)
;        CREATE_NESTED, INFILENAME='global_grid.bpch', $
;                       OUTFILENAME='nested_grid.bpch, $
;                       XRANGE=[ -150, -30 ],          $
;                       YRANGE=[   10,  70 ]
;
;             ; Trims data from "global_grid.bpch" to a nested grid 
;             ; from 150W to 30W and 10N to 70N (in this example,
;             ; this covers the US and parts of Canada and Mexico).
;
;        (2)
;        CREATE_NESTED, INFILENAME='global_grid.bpch', $
;                       OUTFILENAME='nested_grid.bpch, /CHINA
;
;             ; Trims data from "global_grid.bpch" to a nested grid 
;             ; for the default China nested grid (70-150E and 11S 
;             ; to 55 N).  The /CHINA keyword is a convenience to the
;             ; user.  It will set XRANGE and YRANGE automatically for
;             ; the China nested grid.
;
;
; MODIFICATION HISTORY:
;        bmy, 10 Jan 2003: VERSION 1.00
;        bmy, 25 Sep 2003: VERSION 1.01
;                          - now call PTR_FREE to free pointer heap memory
;        bmy, 16 Dec 2003: - now add THISFILEINFO in call to CTM_WRITEBPCH
;  bmy & phs, 04 Oct 2007: GAMAP VERSION 2.10
;                          - Added /CHINA, /NAMER, /EUROPE keywords
;                            which may be specified instead of XRANGE
;                            and YRANGE.  This is a user convenience.
;        phs, 28 Jan 2008: - Bug fix if model name is 'GEOS3_30L'
;                          - Free pointers not referenced at exist.
;
;-
; Copyright (C) 2003-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine create_nested"
;-----------------------------------------------------------------------


pro CN_GetRanges, ModelInfo, China, NAmer, Europe, XR, YR

   ;====================================================================
   ; Internal routine CN_GETRANGES returns the longitude and latitude
   ; ranges for the nested grid region for China, North America, and
   ; Europe (if /CHINA, /NAMER, or /EUROPE keywords are set).  
   ; Otherwise, it will exit without modifying the longitude and
   ; latitude ranges.  This is a similar algorithm to what is used in
   ; GAMAP internal routine CTM_READ_GMAO. (bmy, 10/4/07)
   ;====================================================================

   if ( China ) then begin

      ;-------------------------
      ; China nested grid
      ;-------------------------
      XR    = [  70, 150 ]
      YR    = [ -11,  55 ]

   endif else if ( NAmer ) then begin

      ;-------------------------
      ; N. America nested grid
      ;-------------------------

      ; GEOS-5 nested grid goes up to 70N
      if ( StrMid( ModelInfo.Name, 0, 5 ) eq 'GEOS3' ) then begin
         XR    = [ -140, -40 ]
         YR    = [   10,  60 ]
      endif else begin
         XR    = [ -140, -40 ]
         YR    = [   10,  70 ]
      endelse

   endif else if ( Europe ) then begin

      ;-------------------------
      ; Europe nested grid
      ;-------------------------
      XR    =  [ 1, 1 ]  ; define these later
      YR    =  [ 1, 1 ]

   endif
end

;------------------------------------------------------------------------------

pro Create_Nested, InFileName=InFileName, OutFileName=OutFileName, $
                   XRange=XRange,         YRange=YRange,           $
                   China=China,           NAmer=NAmer,             $
                   Europe=Europe,         _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Make_DataInfo
 
   ; Keyword Settings
   China  = Keyword_Set( China  ) 
   NAmer  = Keyword_Set( NAmer  )
   Europe = Keyword_Set( Europe )
   if ( N_Elements( XRange      ) eq 0 ) then XRange = [-180,180]
   if ( N_Elements( YRange      ) eq 0 ) then YRange = [ -90, 90]
   if ( N_Elements( OutFileName ) eq 0 ) $
      then OutFileName = InFileName + '.nested'

   ; First-time flag
   FirstTime = 1L
 
   ; Clear the global GAMAP common block
   CTM_CleanUp

 
   ;====================================================================
   ; Read data and trim it to the size of the nested grid
   ;====================================================================
 
   ; Read all data blocks from file
   CTM_Get_Data, DataInfo, FileName=InFileName, _EXTRA=e
 
   ; Loop over all data blocks
   for D = 0L, N_Elements( DataInfo ) - 1L do begin
   
      ; MODELINFO and GRIDINFO corresponding to each data block
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
 
      ; If any of /CHINA, /NAMER, or /EUROPE flags are set, then reset 
      ; XRANGE and YRANGE with pre-defined values as a convenience
      ; to the user.  Otherwise use default XRANGE and YRANGE.
      ; (bmy, 10/4/07)
      CN_GetRanges, InType, China, NAmer, Europe, XRange, YRange

      ; Get the index arrays in the X and Y dimensions
      IndX = Where( InGrid.XMid ge XRange[0] AND InGrid.XMid le XRange[1], Nx )
      IndY = Where( InGrid.YMid ge YRange[0] AND InGrid.YMid le YRange[1], Ny )
 
      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check pointer
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Dereference the pointer to get the data
      InData = *( Pointer )

      ; Strip extraneous dimensions
      InData = Reform( InData )

      ; Get the DIM vector for this data block
      InDim = DataInfo[D].Dim
      
      ; Find what kind of data this is
      Is_Lat_Alt     = ( InDim[0] eq 1 AND InDim[1] ne 1 AND InDim[2] ne 1 )
      Is_Lon_Lat     = ( InDim[0] ne 1 AND InDim[1] ne 1 AND InDim[2] eq 1 )
      Is_Lon_Lat_Alt = ( InDim[0] ne 1 AND InDim[2] ne 1 AND InDim[3] ne 1 ) 

      ; Trim the data to size accordingly
      if ( Is_Lat_Alt ) then begin

         ;----------------------
         ; 1-D lat-alt data   
         ;---------------------- 
         OutData  = InData[IndY,*]
         OutDim   = [ 1L, Ny,         InDim[2], 0L ]
         OutFirst = [ 1L, IndY[0]+1L, 1L           ] 
      
      endif else if ( Is_Lon_Lat ) then begin

         ;----------------------
         ; 2-D lon-lat data
         ;----------------------
         OutData  = InData[IndX,*]
         OutData  = OutData[*,IndY]
         OutDim   = [ Nx,         Ny,         0L, 0L ]
         OutFirst = [ IndX[0]+1L, IndY[0]+1L, 1L     ]

      endif else if ( Is_Lon_Lat_Alt ) then begin
         
         ;----------------------
         ; 3-D lon/lat/alt data
         ;----------------------
         OutData  = InData[IndX,*,*]
         OutData  = OutData[*,IndY,*]
         OutDim   = [ Nx,         Ny,         InDim[2], 0L ]
         OutFirst = [ IndX[0]+1L, IndY[0]+1L, 1L           ]
         
      endif
 
      ; Make a new DATAINFO structure for trimmed data block
      Success = CTM_Make_DataInfo( Float( OutData ),           $
                                   ThisDataInfo,               $
                                   ThisFileInfo,               $
                                   ModelInfo=InType,           $
                                   GridInfo=InGrid,            $
                                   DiagN=DataInfo[D].Category, $ 
                                   Tracer=DataInfo[D].Tracer,  $
                                   Tau0=DataInfo[D].Tau0,      $
                                   Tau1=DataInfo[D].Tau1,      $ 
                                   Unit=DataInfo[D].Unit,      $
                                   Dim=OutDim,                 $
                                   First=OutFirst,             $
                                   /No_Global )
      
      ; Error check
      if ( not Success ) then Message, 'Could not make data block!'
 
      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( FirstTime )                                         $
         then NewDataInfo = [ ThisDataInfo ]                   $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
 
      ; Reset the first time flag
      FirstTime = 0L

      ; Free the associated pointer heap memory
      Ptr_Free, Pointer

      ; Free unneeded pointer (phs,01/28/08)
      if ( D ne N_Elements( DataInfo ) -1L ) $
         then Ptr_Free, ThisFileInfo.GridInfo

      ; Undefine stuff for safety's sake
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, IndX
      UnDefine, IndY
      UnDefine, InData
      UnDefine, SData
      UnDefine, OutData
      UnDefine, OutDim
      UnDefine, OutFirst
      UnDefine, ThisDataInfo

   endfor
 
   ;====================================================================
   ; Save trimmed data to the output file
   ;====================================================================
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

   ; Cleanup pointers since we have a NO_GLOBAL datainfo (phs,01/28/08)
   for D=0, N_Elements( NewDataInfo )-1L do Ptr_Free, NewDataInfo[d].Data
   Ptr_Free, ThisFileInfo.Gridinfo
   
 
   ; Quit
   return
end
          
