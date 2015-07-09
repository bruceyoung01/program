; $Id: regridh_stratjv.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_STRATJV
;
; PURPOSE:
;        Horizontally regrids 2-D stratospheric J-Value files 
;        from one CTM grid to another CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_STRATJV [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;       Default: ~bmy/archive/data/stratjv_200203/2x25_geos/stratjv.geos3.2x25
;
;        OUTFILENAME -> Name of output file containing the regridded
;             data.  Default is "stratjv.{MODELNAME}.{RESOLUTION}.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             REGRIDV_DUST will use the same model name as the
;             input grid.
;
;        DIAGN -> Diagnostic category of data block that you want
;             to regrid.  Default is "JV-MAP-$".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===========================================================
;        CTM_TYPE          (function)   CTM_GRID          (function)
;        CTM_NAMEXT        (function)   CTM_RESEXT        (function)
;        CTM_GET_DATABLOCK (function)   CTM_MAKE_DATAINFO (function)
;        GETMODELANDGRIDINFO            CTM_WRITEBPCH 
;        UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) 2-D Stratospheric J-Values are needed for the simple chemistry 
;            mechanism in the stratosphere.  They are originally obtained 
;            by running the GEOS model with SLOW-J and then archiving 
;            the J-Values with the ND22 diagnostic.  These can then be
;            regridded to other vertical resolutions via REGRIDV_STRATJV.
;
; EXAMPLE:
;        REGRIDV_STRATJV, INFILENAME='stratjv.geos3.4x5'
;                         OUTFILENAME='stratjv.geos3.2x25'
;                         OUTRESOLUTION=2
;
;             ; Regrids GEOS-3 4x5 J-value data to 2x2.5 resolution.
;
; MODIFICATION HISTORY:
;        bmy, 13 Jan 2003: VERSION 1.00
;        bmy, 22 Dec 2003: VERSION 1.01
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_stratjv"
;-----------------------------------------------------------------------


pro RegridH_StratJV, InFileName=InFileName,     OutFileName=OutFileName, $
                     OutModelName=OutModelName, OutResolution=OutResolution, $
                     DiagN=DiagN,               _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_NamExt, CTM_ResExt, CTM_Make_DataInfo, $
                    CTM_Type,   CTM_Grid,   CTM_Get_DataBlock

   ; Keywords
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'JV-MAP-$'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; Default INFILENAME
   if ( N_Elements( InFileName ) ne 1 ) then begin
     InFileName='~bmy/archive/data/stratjv_200203/2x25_geos/stratjv.geos3.2x25'
   endif

   ; First time flag
   FirstTime = 1L

   ;====================================================================
   ; Process data
   ;====================================================================

   ; Read all J-value data blocks in file
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, _EXTRA=e

   ; Loop over all data blocks in DATAINFO
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get input grid parameters
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Pointer to the INPUT DATA
      Pointer = DataInfo[D].Data 

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Get INPUT data
      InData  = *( Pointer )
      InData  = Reform( InData )

      ; Free the heap memory
      Ptr_Free, Pointer

      ;-------------------
      ; OUTPUT GRID
      ;-------------------

      ; If OUTMODELNAME is not passed, then use same value as for INTYPE
      if ( N_Elements( OutModelName ) eq 0 ) then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=OutResolution )
      OutGrid = CTM_Grid( OutType )

      ; Data array for OUTPUT grid
      OutData = FltArr( OutGrid.JMX, DataInfo[D].Dim[2] )

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;-------------------
      ; REGRID DATA
      ;-------------------

      ; Interpolate to the new latitudinal resolution
      for L = 0L, InGrid.LMX-1L do begin
         OutData[*,L] = InterPol( InData[*,L], InGrid.YMid, OutGrid.YMid )
      endfor

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
                                   Dim=[ DataInfo[D].Dim[0],   $
                                         OutGrid.JMX,          $
                                         DataInfo[D].Dim[2],   $
                                         DataInfo[D].Dim[3] ], $
                                   First=DataInfo[D].First,    $
                                   /No_Global )

      ; Save into NEWDATAINFO array of structures
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset FIRSTTIME
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
      OutFileName = 'stratjv.' + CTM_NamExt( OutTypeSav ) + $
                    '.'        + CTM_ResExt( OutTypeSav ) 
   endif

   ; Save to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                               
 
    
 
