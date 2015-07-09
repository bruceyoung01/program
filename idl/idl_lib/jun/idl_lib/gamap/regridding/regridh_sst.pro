; $Id: regridh_sst.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_SST
;
; PURPOSE:
;        Horizontally regrids SST data from one CTM grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_SST, [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If omitted, then REGRIDH_SST will prompt the user to
;             select a filename with a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.   If omitted, then REGRIDH_SST will prompt the
;             user to select a filename with a dialog box.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  Default is "SST.{MODELNAME}.{RESOLUTION}".
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "GMAO-2D".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ====================================================
;        CTM_TYPE          (function)   CTM_GRID   (function)
;        CTM_NAMEXT        (function)   CTM_RESEXT (function)
;        CTM_MAKE_DATAINFO (function)   CTM_WRITEBPCH 
;        GETMODELANDGRIDINFO            UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRID_SST, INFILENAME='SST.geos.2x25', $
;                    OUTFILENAME='SST.geos.1x1', $
;                    OUTRESOLUTION=1
;
;             ; Regrids SST data from 2 x 2.5 to 1x1 horizontal grid.
;
; MODIFICATION HISTORY:
;        bmy, 28 Mar 2003: VERSION 1.01
;        bmy, 22 Dec 2003: VERSION 1.02
;                          - rewritten for GAMAP v2-01
;                          - now call PTR_FREE to free pointer memory
;                          - added DIAGN keyword
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_sst"
;-----------------------------------------------------------------------


pro RegridH_SST, InFileName=InFileName,   OutModelName=OutModelName,   $
                 OutFileName=OutFileName, OutResolution=OutResolution, $
                 DiagN=DiagN,             Tracer=Tracer,               $
                 _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type

   ; Keyword Settings
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'GMAO-2D'
   if ( N_Elements( Tracer        ) ne 1 ) then Tracer        = 69
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; Values for indexing each month
   Tau       = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                 4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
      
   ; Set first time flag
   FirstTime = 1L
   
   ;====================================================================
   ; Regrid the data vertically!
   ;====================================================================

   ; Read all SST data into DATAINFO array of structures
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, Tracer=Tracer, /Quiet
    
   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ;-------------------
      ; INPUT GRID
      ;-------------------      
      
      ; Get corresponding MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
 
      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Dereference the pointer to get the data
      InData  = *( Pointer )

      ; Error check Pointer
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Free the pointer heap memory
      Ptr_Free, Pointer

      ;-------------------
      ; OUTPUT GRID
      ;-------------------      

      ; If OUTMODELNAME is not passed, then use the same grid as for INTYPE
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=OutResolution )
      OutGrid = CTM_Grid( OutType )

      ; Output data array
      OutData = FltArr( OutGrid.IMX, OutGrid.JMX, DataInfo[D].Dim[2] )

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;-------------------
      ; REGRID DATA
      ;-------------------  

      ; Interpolate from the old grid to the new grid
      for L = 0L, DataInfo[D].Dim[2]-1L do begin
         OutData[*,*,L] = Interpolate_2D( InData[*,*,L],              $
                                          InGrid.Xmid,  InGrid.Ymid,  $
                                          OutGrid.XMid, OutGrid.YMid, $
                                          /Double )
      endfor
      
      ;-------------------
      ; SAVE DATA BLOCKS
      ;-------------------  

      ; Make a DATAINFO structure
      Success = CTM_Make_DataInfo( Float( OutData ),           $
                                   ThisDataInfo,               $
                                   ThisFileInfo,               $
                                   ModelInfo=OutType,          $
                                   GridInfo=OutGrid,           $
                                   DiagN=DataInfo[D].Category, $
                                   Tracer=DataInfo[D].Tracer,  $
                                   Tau0=DataInfo[D].Tau0,      $
                                   Tau1=DataInfo[D].Tau1,      $
                                   Unit=DataInfo[D].Unit,      $
                                   Dim=[ OutGrid.IMX,          $
                                         OutGrid.JMX,          $
                                         DataInfo[D].Dim[2],   $
                                         DataInfo[D].Dim[3] ], $
                                   First=DataInfo[D].First,    $
                                   /No_Global ) 
 
      ; Save into the NEWDATAINFO array of structures
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset first time flag
      FirstTime = 0L

      ; Undefine stuff
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, InData
      UnDefine, OutType
      UnDefine, OutGrid
      UnDefine, OutData
      UnDefine, ThisDataInfo
   endfor
   
   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'SST.' + CTM_NamExt( OutTypeSav ) + $
                    '.'    + CTM_ResExt( OutTypeSav )
   endif

   ; Save as binary punch file
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                               
 
    
 
