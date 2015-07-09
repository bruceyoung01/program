; $Id: regridh_jo1d.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_JO1D
;
; PURPOSE:
;        Regrids JO1D data (used for acetone emissions) 
;        from one CTM grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_JO1D, [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the input file containing JO1D data
;             to be regridded.  If INFILENAME is not specified, then 
;             REGRIDH_JO1D will prompt the user to select a file via 
;             a dialog box.
;
;        OUTFILENAME -> Name of the binary punch file which
;             will contain regridded data.  Default is 
;             "JO1D.{MODELNAME}.{RESOLUTION}"
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             then REGRIDH_RESTART will use the same model name as the
;             input grid.
;
;        OUTRESOLUTION -> Specifies the resolution of the output
;             model grid onto which the data will be regridded.
;             OUTRESOLUTION can be either a 2 element vector with 
;             [ DI, DJ ] or a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 
;             1=1x1, 0.5=0.5x0.5).  Default for all models is 4x5.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ========================================================
;        CTM_TYPE          (function)   CTM_GRID       (function)
;        CTM_NAMEXT        (function)   CTM_RESEXT     (function)
;        CTM_MAKE_DATAINFO (function)   INTERPOLATE_2D (function)
;        CTM_GET_DATA                   GETMODELANDGRIDINFO
;        UNDEFINE       
; 
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDH_JOID, INFILENAME='JO1D.geos.4x5',   $
;                      OUTFILENAME='JO1D.geos.2x25', $
;                      OUTRESOLUTION=2
;
;             ; Regrids JO1D data from 4 x 5 to 2 x 2.5 resolution.
;
; MODIFICATION HISTORY:
;        bmy, 11 Aug 2000: VERSION 1.01
;        bmy, 23 Dec 2003: VERSION 1.02
;                          - updated for GAMAP v2-01
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_jo1d"
;-----------------------------------------------------------------------


pro RegridH_JO1D, InFileName=InFileName,     OutResolution=OutResolution, $
                  OutModelName=OutModelName, OutFileName=OutFileName,     $
                  DiagN=DiagN,               _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_NamExt, CTM_ResExt, InterPolate_2D

   ; Keyword Settings
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'JV-MAP-$'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 2
     
   ; Set first time flag
   FirstTime = 1L
   
   ;====================================================================
   ; Regrid the data 
   ;====================================================================

   ; Read all J-value data blocks from the file
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, _EXTRA=e
    
   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ;------------------
      ; INPUT GRID
      ;------------------

      ; Get the input MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
 
      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Get INPUT data
      InData = *( Pointer )

      ; Free the pointer heap memory
      Ptr_Free, Pointer

      ;------------------
      ; OUTPUT GRID
      ;------------------

      ; If OUTMODELNAME isn't specified, then use same value as INTYPE  
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=OutResolution  )
      OutGrid = CTM_Grid( OutType )

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;------------------
      ; REGRID DATA
      ;------------------

      ; Output data array (it's 2-D)
      OutData = Interpolate_2D( InData,       InGrid.Xmid,  InGrid.Ymid,  $
                                OutGrid.XMid, OutGrid.YMid, /Double )

      ;------------------
      ; SAVE DATA BLOCKS
      ;------------------
      
      ; Make a DATAINFO structure for each month of OH data
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
 
      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO structure!'

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
      OutFileName = 'JO1D.' + CTM_NamExt( OutTypeSav ) + $
                    '.'     + CTM_ResExt( OutTypeSav ) 
   endif

   ; Write new bpch file
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                               
 
    
 
