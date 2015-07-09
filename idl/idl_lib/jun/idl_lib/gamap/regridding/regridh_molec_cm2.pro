; $Id: regridh_molec_cm2.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_MOLEC_CM2
;
; PURPOSE:
;        Regrids 1 x 1 data (e.g. emissions) in units of [molec/cm2/s] 
;        onto a CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_MOLEC_CM2 [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> A string containing the name of the binary 
;             punch (bpch) file with the data to be regridded.
;
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTFILENAME -> Name of the directory where the output file will
;             be written.  Default is 'merge_nobiofuels.geos.{resolution}'.  
;
;        DIAGN -> GAMAP diagnostic category name of the data blocks
;             to be regridded.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================================
;        CTM_GRID    (function)   CTM_TYPE   (function)
;        CTM_BOXSIZE (function)   CTM_REGRID (function)
;        CTM_RESEXT  (function)   CTM_MAKE_DATAINFO (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Can also be used to regrid other quantities that are
;        per unit area (e.g. kg/m2/s, molec/cm3/s, etc).
;
; EXAMPLE:
;        REGRIDH_MOLEC_CM2, INFILENAME="merge_nobiofuels.generic.1x1",$
;                           OUTFILENAME="merge_nobiofuels.geos.1x1",  $
;                           OUTMODELNAME='GEOS3',                     $
;                           OUTRESOLUTION=1 
;           
;             ; Regrids 1 x 1 fossil fuel emissions on the
;             ; GENERIC 1x1 grid to the GEOS 1x1 grid.
;
; MODIFICATION HISTORY:
;        bmy, 28 Jun 2006: VERSION 1.00
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2006-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridh_molec_cm2"
;-----------------------------------------------------------------------


pro RegridH_Molec_Cm2, InFileName=InFileName,       $
                       OutModelName=OutModelName,   $
                       OutResolution=OutResolution, $
                       OutFileName=OutFileName,     $
                       DiagN=DiagN,                 $
                       _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External Functions
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,         CTM_RegridH, $
                    CTM_ResExt, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS1'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; Output grid
   OutType   = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid   = CTM_Grid( OutType )

   ; First time flag
   FirstTime = 1L
      
   ;====================================================================
   ; Read and regrid data
   ;====================================================================

   ; Read data blocks
   if ( N_Elements( DiagN ) eq 0 )                                          $
      then CTM_Get_Data, DataInfo,        File=InFileName, /Quiet, _EXTRA=e $
      else CTM_Get_Data, DataInfo, DiagN, File=InFileName, /Quiet, _EXTRA=e

   ; Loop over all data blocks
   for D = 0L, N_Elements( DataInfo )-1L do begin

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Get data value
      InData  = *( DataInfo[D].Data )

      ; Use saved mapping weights in regridding?
      US      = 1L - FirstTime

      ; Regrid the data
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid,     $
                             /Per_Unit_Area, /Double, Use_Saved=US)
 
      ; Make a DATAINFO structure for the regridded data
      Success = CTM_Make_DataInfo( Float( OutData ),               $
                                   ThisDataInfo,                   $
                                   ThisFileInfo,                   $
                                   ModelInfo=OutType,              $
                                   GridInfo=OutGrid,               $
                                   DiagN=DataInfo[D].Category,     $
                                   Tracer=DataInfo[D].Tracer,      $
                                   Tau0=DataInfo[D].Tau0,          $
                                   Tau1=DataInfo[D].Tau1,          $
                                   Unit=DataInfo[D].Unit,          $
                                   Dim=[ OutGrid.IMX,              $
                                         OutGrid.JMX,              $
                                         DataInfo[D].Dim[2], 0 ],  $
                                   First=DataInfo[D].First,        $
                                   /No_Global )

      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( FirstTime )                                             $      
         then NewDataInfo = [ ThisDataInfo              ]          $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
      FirstTime = 0L

      ; Undefine variables for safety's sake
      UnDefine, ThisDataInfo
      UnDefine, InData
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, OutData
   endfor

   ;====================================================================
   ; Cleanup and quit
   ;====================================================================

   ; Write to bpch file
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName, _EXTRA=e

end
