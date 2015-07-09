; $Id: regridh_cm2_s.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_CM2_S
;
; PURPOSE:
;        Horizontally Regrids a CTM quantity (such as emissions) in 
;        units of [molec/cm2/s] or [atoms C/cm2/s] to a new CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_CM2_S [, Keywords ]
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
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.  If not
;             passed, then the model name corresponding to the data
;             contained in INPUTFILE will be used as the default.
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
;
;-
; Copyright (C) 2004, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridh_bioburn"
;-----------------------------------------------------------------------


pro RegridH_Cm2_S, InFileName=InFileName,     OutFileName=OutFileName,     $
                   OutModelName=OutModelName, OutResolution=OutResolution, $
                   DiagN=DiagN,               EXTRA=e
  
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_RegridH, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
   if ( N_Elements( DiagN         ) eq 0 ) then DiagN         = 'IJ-AVG-$'

   ; First-time flag
   FirstTime = 1L

   ;====================================================================
   ; Read data
   ;====================================================================

   ; Read all data blocks
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, /Quiet, _EXTRA=e

   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo )-1L do begin

      ; Get MODELINFO and GRIDINFO structures on INPUT GRID
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
      
      ; Get default OUTMODELNAME (same as on INPUT GRID)
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures on OUTPUT GRID
      OutType = CTM_Type( OutModelName, Res=OutResolution )
      OutGrid = CTM_Grid( OutType )

      ; Get data on INPUT GRID
      Pointer = DataInfo[D].Data
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Data Pointer!'
      InData  = *( Pointer )

      ; Flag to determine when to use saved mapping weights
      US      = 1L - FirstTime

      ; Regrid data from OLDGRID to NEWGRID
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid,      $
                             /Per_Unit_Area, /Double, Use_Saved=US )

      ; Save dimensions
      Dim     = DataInfo[D].Dim

      ; Make a DATAINFO structure
      Success = CTM_Make_DataInfo( Float( OutData ),              $
                                   ThisDataInfo,                  $
                                   ThisFileInfo,                  $
                                   ModelInfo=OutType,             $
                                   GridInfo=OutGrid,              $
                                   DiagN=DataInfo[D].Category,    $
                                   Tracer=DataInfo[D].Tracer,     $
                                   Tau0=DataInfo[D].Tau0,         $
                                   Tau1=DataInfo[D].Tau1,         $
                                   Unit=DataInfo[D].Unit,         $
                                   Dim=[OutGrid.IMX, OutGrid.JMX, $
                                        Dim[2],      Dim[3] ],    $
                                   First=DataInfo[D].First,       $
                                   /NO_GLOBAL )
 
      ; Error check
      if ( not Success ) then Message, 'Could not create DATAINFO structure!'

      ; Append into NEWDATAINFO array of structures
      if ( FirstTime )                                            $           
         then NewDataInfo = [ ThisDataInfo ]                      $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
      FirstTime = 0L

      ; Undefine variables for safety's sake
      UnDefine, Dim
      UnDefine, InData
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, OutData
      UnDefine, OutType
      UnDefine, OutGrid
      UnDefine, ThisDataInfo

   endfor      

   ;====================================================================
   ; Write to disk and quit
   ;====================================================================

   ; Write to binary punch file format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

   ; Quit
   return
end
