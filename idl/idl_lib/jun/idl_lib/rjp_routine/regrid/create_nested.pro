; $Id: create_nested.pro,v 1.2 2003/12/23 20:07:03 bmy Exp $
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
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================================
;        CTM_CLEANUP         CTM_GET_DATA
;        CTM_WRITEBPCH       CTM_MAKE_DATAINFO (function)
;        GETMODELANDGRIDINFO   
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages
;
; NOTES:
;        (1) Works for the following types of data blocks:
;            (a) 2-D "zonal-mean" (latitude-altitude)
;            (b) 2-D "horizontal" (longitude-latitude)
;            (c) 3-D "global"     (longitude-latitude-altitude)
;
; EXAMPLE:
;        CREATE_NESTED, INFILENAME='global_grid.bpch', $
;                       OUTFILENAME='nested_grid.bpch, $
;                       XRANGE=[ -150, -30 ],          $
;                       YRANGE=[   10,  70 ]
;
;             ; Trims data from "global_grid.bpch" to a nested grid 
;             ; from 150W to 30W and 10N to 70N (in this example,
;             ; this covers the US and parts of Canada and Mexico).
;
; MODIFICATION HISTORY:
;        bmy, 10 Jan 2003: VERSION 1.00
;        bmy, 25 Sep 2003: VERSION 1.01
;                          - now call PTR_FREE to free pointer heap memory
;        bmy, 16 Dec 2003: - now add THISFILEINFO in call to CTM_WRITEBPCH
;
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine create_nested"
;-----------------------------------------------------------------------


pro Create_Nested, InFileName=InFileName, OutFileName=OutFileName, $
                   XRange=XRange,         YRange=YRange,           $
                   _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Make_DataInfo
 
   ; Keyword Settings
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
 
   ; Quit
   return
end
          
