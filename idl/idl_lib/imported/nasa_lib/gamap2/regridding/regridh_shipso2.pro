; $Id: regridh_shipso2.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_SHIPSO2
;
; PURPOSE:
;        Horizontally regrids emissions SOx from ship emissions
;        in [molec/cm2/s] from one CTM grid to another. 
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_SHIPSO2 [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing C3H8 and C2H6 to
;             be regridded.  If omitted, then REGRIDH_SHIPSO2 will
;             prompt the user to select a filename via a dialog box.
;
;        OUTFILENAME -> Name of output file containing the regridded
;             data.  If OUTFILENAME is not specified, then REGRIDH_SHIPSO2 
;             will ask the user to specify a file via a dialog box.
;
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.  If
;             OUTMODELNAME is not specified, REGRIDH_SHIPSO2 will 
;             use the same model name as the input grid.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "IJ-AVG-$".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =======================================================
;        CTM_GRID          (function)   CTM_TYPE     (function)
;        CTM_REGRIDH       (function)   CTM_RESEXT   (function)
;        CTM_MAKE_DATAINFO (function)   CTM_WRITEBPCH            
;        UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDH_SHIPSO2, INFILENAME='shipSOx.geos.2x25',  $
;                         OUTFILENAME='shipSOx.geos.4x5',  $
;                         OUTRESOLUTION=4
;
;             ; Regrids C3H8 and C2H6 data onto from the 4 x 5
;             ; GEOS-3 grid to the the 2 x 2.5 GEOS-3 grid.
;
; MODIFICATION HISTORY:
;        bmy, 08 Jan 2003: VERSION 1.00
;        bmy, 22 Dec 2003: VERSION 1.01
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_shipso2"
;-----------------------------------------------------------------------


pro RegridH_ShipSO2, InFileName=InFileName,     OutFileName=OutFileName,    $
                     OutModelName=OutModelName, OutResolution=OutResolution,$
                     DiagN=DiagN,               _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type,    CTM_Grid,                    $  
                    CTM_RegridH, CTM_ResExt, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( DiagN         ) eq 0 ) then DiagN         = 'SOX-SHIP'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 2

   ; Set first time flag
   FirstTime = 1L

   ;====================================================================
   ; Process data
   ;====================================================================

   ; Read data blocks into DATAINFO array of structures
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, _EXTRA=e

   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get the MODELINFO and DATAINFO structures for the input grid
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
      
      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Dereference the pointer to get the data
      InData  = *( Pointer )

      ; Free the memory pointed to by the pointer
      ;Ptr_Free, Pointer

      ;-------------------
      ; OUTPUT GRID
      ;-------------------

      ; If OUTMODELNAME isn't specified, use the same value as for INTYPE
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; MODELINFO, GRIDINFO structures, and surface areas for output grid
      OutType = CTM_Type( OutModelName, Resolution=OutResolution )
      OutGrid = CTM_Grid( OutType )
      
      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;-------------------
      ; REGRID DATA
      ;-------------------      

      ; Reuse mapping weights?
      US      = 1L - FirstTime

      ; Regrid the data
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid, $
                             /Per_Unit_Area, /Double, Use_Saved=US )
         
      ; Make a DATAINFO structure for this NEWDATA
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
                                   Dim=[OutGrid.IMX,           $
                                        OutGrid.JMX,           $
                                        DataInfo[D].Dim[2],    $
                                        DataInfo[D].Dim[3] ],  $
                                   First=DataInfo[D].First,    $
                                   /No_Global )
         
      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( FirstTime )                                         $             
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
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
      OutFileName = 'shipSOx.' + CTM_NamExt( OutTypeSav ) + $
                    '.'        + CTM_ResExt( OutTypeSav )
   endif

   ; Write to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end
