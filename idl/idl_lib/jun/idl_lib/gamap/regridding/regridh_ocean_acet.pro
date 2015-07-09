; $Id: regridh_ocean_acet.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_OCEAN_ACET
;
; PURPOSE:
;        Regrids ocean production & loss for tagged CO.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_OCEAN_ACET [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If INFILENAME is not specified, then REGRIDH_OCEAN_ACET
;             will prompt the user to select a file via a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  Default is "acetone.geos.{RESOLUTION}".
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             then REGRIDH_OCEAN_ACET will use the same model name as the
;             input grid.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "EMISACET".
; 
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =====================================================
;        CTM_GRID    (function)   CTM_TYPE          (function)
;        CTM_REGRIDH (function)   CTM_MAKE_DATAINFO (function)
;        CTM_RESEXT  (function)   CTM_WRITEBPCH
;        UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDH_OCEAN_ACET, INFILENAME='acetone.geos.2x25', $
;                            OUTFILENAME='acetone.geos.1x1'
;                            OUTRESOLUTION=1,                $
;           
;             ; Regrids 2 x 2.5 ocean acetone data to the 1x1 grid.
;
; MODIFICATION HISTORY:
;        bmy, 15 Jun 2003: VERSION 1.00
;        bmy, 23 Dec 2003: VERSION 1.01
;                          - rewritten for GAMAP v2-01
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_ocean_acet"
;-----------------------------------------------------------------------


pro RegridH_Ocean_Acet, InFileName=InFileName,       $
                        OutFileName=OutFileName,     $
                        OutModelName=OutModelName,   $
                        OutResolution=OutResolution, $
                        DiagN=DiagN,                 $
                        _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid,   CTM_Type,         CTM_RegridH, $
                    CTM_ResExt, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'EMISACET'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; First time flag
   FirstTime = 1L

   ;====================================================================
   ; Process Data
   ;====================================================================

   ; Read all data blocks
   CTM_Get_Data, DataInfo, DiagN, File=InFileName, _EXTRA=e
   
   ; Loop over all data blocks
   for D = 0L, N_Elements( DataInfo )-1L do begin

      ;--------------------
      ; INPUT GRID
      ;--------------------

      ; Get input grid and type
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Get input data [Tg]
      InData  = *( DataInfo[D].Data )

      ;--------------------
      ; OUTPUT GRID
      ;--------------------
      
      ; If OUTFILENAME isn't passed, use same value as for INTYPE
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Output grid
      OutType = CTM_Type( OutModelName, Resolution=OutResolution )
      OutGrid = CTM_Grid( OutType, /No_Vertical )

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;--------------------
      ; REGRID DATA
      ;--------------------

      ; Otherwise regrid the data in units of [kg CO/box/yr]
      OutData = CTM_RegridH( InData,  InGrid, OutGrid,  $
                             /Double, Use_Saved=1L-FirstTime )

      ;--------------------
      ; SAVE DATA BLOCKS
      ;--------------------

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
                                   Dim=[OutGrid.IMX,           $
                                        OutGrid.JMX, 0, 0],    $
                                   First=DataInfo[D].First,    $
                                   /No_Global )
      
      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO structure!'

      ; Save into NEWDATAINFO array of structure
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset first time flag
      FirstTime = 0L

      ; Undefine stuff for safety's sake
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
      OutFileName = 'acetone.geos.' + CTM_ResExt( OutTypeSav )
   endif

   ; Save to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end
