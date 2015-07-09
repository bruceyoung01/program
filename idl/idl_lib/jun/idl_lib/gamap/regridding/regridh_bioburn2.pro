; $Id: regridh_bioburn2.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_BIOBURN2
;
; PURPOSE:
;        Regrids 1 x 1 biomass burning emissions for various tracers
;        onto a CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_BIOBURN [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTFILENAME -> 
;
;        DIAGN -> 
;             
; OUTPUTS:
;        Writes binary punch files: 
;             bioburn.seasonal.{MODELNAME}.{RESOLUTION} OR
;             bioburn.interannual.{MODELNAME}.{RESOLUTION}.YEAR  
;
; SUBROUTINES:
;
;        External Subroutines Required:
;        =================================================
;        CTM_GRID   (function)   CTM_TYPE   (function)
;        CTM_REGRID (function)   CTM_NAMEXT (function)   
;        CTM_RESEXT (function)   CTM_WRITEBPCH
;        UNDEFINE
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        none
;
; EXAMPLE:
;        REGRIDH_BIOBURN, INFILENAME='biomass.seasonal.generic.1x1', $
;                         OUTMODELNAME='GEOS4'
;                         OUTRESOLUTION=2 $
;                         OUTFILENAME='biomass.seasonal.geos.2x25'GEOS_STRAT', 
;           
;             ; Regrids seasonal 1 x 1 biomass burning data 
;             ; onto the GEOS_4 2 x 2.5 grid.
;
; MODIFICATION HISTORY:
;        bmy, 08 Apr 2004: VERSION 1.00
;        bmy, 20 Oct 2005: VERSION 1.01
;                          - If units are per m3, m2, cm3, or cm2 then 
;                            set PER_UNIT_AREA flag in routine CTM_REGRIDH;
;-
; Copyright (C) 2004-2005, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridh_bioburn"
;-----------------------------------------------------------------------


pro RegridH_BioBurn2, InFileName=InFileName,       $
                      OutModelName=OutModelName,   $
                      OutResolution=OutResolution, $
                      OutFileName=OutFileName,     $
                      DiagN=DiagN,                 $
                      _EXTRA=e
  
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_RegridH, CTM_NamExt, CTM_ResExt

   ; Keywords
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
   if ( N_Elements( DiagN         ) eq 0 ) then DiagN         = 'BIOBSRCE'

   ; First-time flag
   First = 1L

   ;====================================================================
   ; Read data
   ;====================================================================

   ; Read all biomass burning data blocks
   CTM_Get_Data, DataInfo, DiagN, FileName=InfileName, _EXTRA=e

   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo )-1L do begin

      ; Print info
      Print, 'Now Processing ' + StrTrim( DataInfo[D].TracerName ) + $
       ' for TAU0: ' + StrTrim(String( DataInfo[D].Tau0,Format='(f14.2)' ),2)

      ; Get MODELINFO and GRIDINFO structures on INPUT GRID
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
      
      ; Default OUTMODELNAME
      if ( N_Elements( OutModelName ) ne 1 ) $
         then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures on OUTPUT GRID
      OutType = CTM_Type( OutModelName, Res=OutResolution )
      OutGrid = CTM_Grid( OutType )

      ; Save for use below
      OutType_Sav = OutType

      ; Get data on INPUT GRID
      Pointer = DataInfo[D].Data
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'
      InData = *( Pointer )
      Ptr_Free,  Pointer

      ; Flag to determine when to use saved mapping weights
      US = 1L - First

      ; Get unit string
      Unit = StrLowCase( StrTrim( DataInfo[D].Unit, 2 ) )

      ; If units are per m3, m2, cm3, or cm2 then set PER_UNIT_AREA
      ; flag in routine CTM_REGRIDH (bmy, 10/20/05)
      PUA = 0      
      if ( StrPos( Unit, 'm3' ) ge 0 ) then PUA = 1
      if ( StrPos( Unit, 'm2' ) ge 0 ) then PUA = 1

      ; Regrid data from OLDGRID to NEWGRID
      OutData = CTM_RegridH( InData,            InGrid,  OutGrid,      $
                             Per_Unit_Area=PUA, /Double, Use_Saved=US )

      ;==============================================================
      ; Make a DATAINFO structure for this NEWDATA, 
      ; append into an array of structures for disk write
      ;==============================================================
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
                                   /NO_GLOBAL )
 
      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( First )                                             $             
         then NewDataInfo = [ ThisDataInfo ]                   $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
      First = 0L

      ; Undefine variables for safety's sake
      UnDefine, InData
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, OutData
      UnDefine, OutType
      UnDefine, OutGrid
      UnDefine, ThisDataInfo

   endfor      

   ;====================================================================
   ; Write all data blocks to a binary punch file
   ;====================================================================
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'bioburn.seasonal.' + CTM_NamExt( OutType_Sav ) + $
                    '.'                 + CTM_ResExt( OutType_Sav ) 
   endif

   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

   ; Quit
   return
end
