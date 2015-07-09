; $Id: regridh_resp.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_RESP
;
; PURPOSE:
;        Horizontally regrids heterogeneous respiration data (used for 
;        acetone emissions) from one CTM grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_RESP, [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If INFILENAME is not specified, then REGRIDH_RESP
;             will prompt the user to select a file via a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  Default is "resp.geos.{RESOLUTION}".
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             then REGRIDH_RESP will use the same model name as the
;             input grid.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "HET-RESP".
;
; OUTPUTS:
;
; SUBROUTINES:
;        External Subroutines Required:
;        ======================================================
;        CTM_TYPE          (function)   CTM_GRID    (function)
;        CTM_RESEXT        (function)   CTM_REGRIDH (function)   
;        CTM_MAKE_DATAINFO (function)   CTM_GET_DATA
;        CTM_WRITEBPCH                  UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Assumes het-resp data has units [g C/m2/month].
;
;
; EXAMPLE:
;        REGRIDH_RESP, INFILENAME='resp.geos.2x25', $
;                      OUTFILENAME='resp.geos.4x5', $
;                      OUTRESOLUTION=2
;
;             ; Regrids heterogeneous respiration data from the
;             ; 2 x 2.5 GEOS grid (surface only) to the 4 x 5 grid.
;
; MODIFICATION HISTORY:
;        bmy, 11 Aug 2000: VERSION 1.01
;        bmy, 22 Dec 2003: VERSION 1.02
;                          - rewritten for GAMAP v2-01
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_resp"
;-----------------------------------------------------------------------


pro RegridH_Resp, InFileName=InFileName,     OutResolution=OutResolution, $
                  OutModelName=OutModelName, OutFileName=OutFileName,     $
                  DiagN=DiagN,               _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid,   CTM_Type,                      $
                    CTM_ResExt, CTM_RegridH, CTM_Make_DataInfo

   ; Keyword Settings
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'HET-RESP'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 2

   ; Set first time flag
   FirstTime = 1L
   
   ;====================================================================
   ; Process the data
   ;====================================================================

   ; Read data and store into DATAINFO array of structures
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, _EXTRA=e
    
   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ;-------------------
      ; INPUT GRID
      ;-------------------
   
      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
 
      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check Pointer
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Get INPUT data [g C/m2/month]
      InData  = *( Pointer )

      ; Free the associated pointer heap memory
      Ptr_Free, Pointer      
      
      ;-------------------
      ; OUTPUT GRID
      ;-------------------      

      ; If OUTMODELNAME is not passed, then use the same grid as for INTYPE
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=OutResolution )
      OutGrid = CTM_Grid( OutType )

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;-------------------
      ; REGRID DATA
      ;-------------------

      ; Reuse saved mapping weights
      US = 1L - FirstTime
      
      ; Regrid data [g C/m2/month]
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid, $
                             /Per_Unit_Area, /Double, Use_Saved=US )
      
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
                                   /No_Global ) 
 
      ; Save into NEWDATAINFO array of structures
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset first time flag
      FirstTime = 0L

      ; Undefine data
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
      OutFileName = 'resp.geos.' + CTM_ResExt( OutTypeSav )
   endif

   ; Save as binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName
 
end                               
 
    
 
