; $Id: regridh_nh3.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_NH3
;
; PURPOSE:
;        Horizontally regrids NH3 emissions (anthro, biofuel, or 
;        natural source) from one CTM grid to another.  Can also
;        be used to regrid other data which have units of kg.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_NH3 [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If INFILENAME is not specified, then REGRIDH_RESTART
;             will prompt the user to select a file via a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  If OUTFILENAME is not specified, then REGRIDH_RESTART
;             will prompt the user to select a file via a dialog box.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             then REGRIDH_NH3 will use the same model name as the
;             input grid.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================================
;        CTM_GRID    (function)   CTM_TYPE (function)
;        CTM_REGRIDH (function)   GETMODELANDGRIDINFO
;        CTM_RESEXT  (function)   CTM_GET_DATA
;        CTM_WRITEBPCH            UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Assumes that input data is either [kg NH3/box] or [kg N/box].
;
; EXAMPLE:
;        (1)
;        REGRIDH_NH3, INFILENAME='NH3_anthsrce.geos.2x25', $
;                     OUTFILENAME='NH3_anthsrce.geos.1x1', $
;                     OUTRESOLUTION=1
;           
;             ; Regrids 2 x 2.5 NH3 anthropogenic emissions 
;             ; to the 1 x 1 GEOS grid.
;
; MODIFICATION HISTORY:
;        bmy, 28 Mar 2003: VERSION 1.01
;        bmy, 22 Dec 2003: VERSION 1.02
;                          - rewritten for GAMAP v2-01
;                          - now call PTR_FREE to free pointer memory
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2000-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridh_nh3"
;-----------------------------------------------------------------------


pro RegridH_NH3, InFileName=InFileName,     OutFileName=OutFileName,     $
                 OutModelName=OutModelName, OutResolution=OutResolution, $
                 _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_ResExt, $
                    CTM_RegridH, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; First-time flag
   FirstTime = 1L

   ;====================================================================
   ; Process the data
   ;====================================================================

   ; Read the data
   CTM_Get_Data, DataInfo, FileName=InFileName, _EXTRA=e

   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ;-------------------
      ; INPUT GRID
      ;-------------------     

      ; Get corresponding MODELINFO and DATAINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check   
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Dereference the pointer to get the data [kg NH3/box/yr]
      InData  = *( Pointer )

      ; Free the pointer heap memory
      ;Ptr_Free, Pointer

      ;-------------------
      ; OUTPUT GRID
      ;-------------------
      
      ; If OUTMODELNAME is not passed, use the same value as for INTYPE
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name
      
      ; MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Resolution=OutResolution )
      OutGrid = CTM_Grid( OutType )

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;-------------------
      ; REGRID DATA
      ;-------------------

      ; Reuse saved mapping weights?
      US      = 1L - FirstTime
      
      ; Otherwise regrid the data in units of [kg/box/yr]
      OutData = CTM_RegridH( InData,  InGrid, OutGrid,  $
                             /Double, Use_Saved=US )

      ;-------------------
      ; SAVE DATA BLOCKS
      ;-------------------

      ; Make DATAINFO structure 
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
                                   /No_Global)
      
      ; Save into NEWDATAINFO array of strucures
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
      OutFileName = 'NH3_anthsrce.geos.' + CTM_ResExt( OutTypeSav )
   endif

   ; Save to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end
