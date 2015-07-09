; $Id: regridh_porl.pro,v 1.2 2003/12/23 20:07:26 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_PORL
;
; PURPOSE:
;        Horizontally regrids production/loss or other data 
;        in [molec/cm3/s] from one CTM grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_PORL [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If omitted, then REGRIDH_PORL will prompt the user to
;             select a filename with a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  If OUTFILENAME is not specified, then REGRIDH_PORL
;             will prompt the user to select a file via a dialog box.
;
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.  If not
;             specified, then OUTMODELNAME will be set to the same
;             value as the grid stored in INFILENAME.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        DIAGN -> Diagnostic category of data block that you want
;             to regrid.  Default is "PORL-L=$".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================================
;        CTM_GRID    (function)   CTM_TYPE    (function)
;        CTM_NAMEXT  (function)   CTM_RESEXT  (function)   
;        CTM_REGRIDH (function)   CTM_GET_DATA             
;        CTM_WRITEBPCH            GETMODELANDGRIDINFO      
;        UNDEFINE   
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDH_PORL, INFILENAME='data.geos3.4x5', $
;                      OUTFILENAME="data.geoss.4x5'
;                      OUTRESOLUTION=2,             $
;
;             ; Regrids data in molec/cm3 from GEOS-3 vertical
;             ; resolution from 4x5 to 2 x 2.5 GEOs-3 resolution.
;
; MODIFICATION HISTORY:
;        bmy, 01 Nov 2002: VERSION 1.01
;        bmy, 19 Sep 2003: VERSION 1.02
;                          - now call PTR_FREE to free pointer memory
;        bmy, 19 Dec 2003: VERSION 1.03
;                          - rewritten for GAMAP v2-01
;                          - added DIAGN keyword
;                
;-
; Copyright (C) 2002, 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regrid_porl"
;-----------------------------------------------------------------------

pro RegridH_PorL, InFileName=InFileName,     OutFileName=OutFileName,     $
                  OutModelName=OutModelName, OutResolution=OutResolution, $
                  DiagN=DiagN,               _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,   CTM_RegridH,      $
                    CTM_NamExt, CTM_ResExt, CTM_Make_DataInfo

   ; Keyword Settings
   if ( N_Elements( DiagN         ) eq 0 ) then DiagN         = 'CHEM-L=$'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; First time flag
   FirstTime = 1L

   ;====================================================================
   ; Process the data!
   ;====================================================================

   ; Read data blocks into the DATAINFO array of structures
   CTM_Get_Data, DataInfo, FileName=InFileName, _EXTRA=e

   ; Loop over all data blocks
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ; Echo info to screen
      S = 'Now processing ' + StrTrim( DataInfo[D].TracerName, 2 )
      Message, S, /Info

      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
      
      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Dereference pointer to get the data
      InData  = *( Pointer )

      ; Free the pointer heap memory
      Ptr_Free, Pointer

      ;-------------------
      ; OUTPUT GRID
      ;-------------------

      ; If OUTMODELNAME is not passed, then use the same value as for INTYPE
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Resolution=OutResolution )
      OutGrid = CTM_Grid( OutType )

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;-------------------
      ; REGRID THE DATA
      ;-------------------

      ; Reuse saved mapping weights?
      US = 1L - FirstTime
      
      ; Regrid INDATA [molec/cm3/s] to OUTPUT GRID
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid,      $
                             /Per_Unit_Area, /Double, Use_Saved=US )
          
      ;-------------------
      ; SAVE DATA BLOCKS
      ;-------------------    

      ; Make a DATAINFO structure for each data block 
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
                                   Dim=[OutGrid.IMX,              $
                                        OutGrid.JMX,              $
                                        DataInfo[D].Dim[2],       $
                                        DataInfo[D].Dim[3] ],     $ 
                                   First=DataInfo[D].First,       $
                                   /No_Global )
 
      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO structure!'

      ; Save into NEWDATAINFO array of structures
      if ( FirstTime )                                            $
         then NewDataInfo = ThisDataInfo                          $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset first time flag
      FirstTime = 0L

      ; Undefine variables for safety's sake
      UnDefine, ThisDataInfo
      UnDefine, InData
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, OutData
      UnDefine, OutType
      UnDefine, OutGrid
   endfor   
 
   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Write as binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end
