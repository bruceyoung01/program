; $Id: regridh_jv.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_JV
;
; PURPOSE:
;        Horizontally interpolates J-values from one CTM grid to another.
;        Can also be used to interpolate other data quantities.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_JV, [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If INFILENAME is not specified, then REGRIDH_JV
;             will prompt the user to select a file via a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  If OUTFILENAME is not specified, then REGRIDH_JV
;             will prompt the user to select a file via a dialog box.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             then REGRIDH_JV will use the same model name as the
;             input grid.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
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
;        ==========================================================
;        CTM_TYPE           (function)   CTM_GRID       (function)
;        CTM_NAMEXT         (function)   CTM_RESEXT     (function)
;        CTM_MAKE_DATAINFO  (function)   INTERPOLATE_2D (function)
;        GETMODELANDGRIDINFO             UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDV_JV, INFILENAME='JH2O2.geos4.4x5', $
;                    OUTRESOLUTION='2'
;                    OUTFILENAME='JH2O2.geos4.2x25'
;
;             ; Regrids GEOS-4 stratospheric J-value data 
;             ; at 4 x 5 resolution to 2 x 2.5 resolution.
;
; MODIFICATION HISTORY:
;        bmy, 11 Aug 2000: VERSION 1.01
;        bmy, 22 Dec 2003: VERSION 1.02
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_jv"
;-----------------------------------------------------------------------


pro RegridH_JV, InFileName=InFileName,   OutModelName=OutModelName, $
                OutFileName=OutFileName, OutResolution=OutResolution, $
                DiagN=DiagN,             _Extra=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, InterPolate_2D

   ; Keyword Settings
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'JV-MAP-$'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
 
   ; Values for indexing each month
   Tau       = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                 4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
      
   ; Set first time flag
   FirstTime = 1L
   
   ;====================================================================
   ; Process the data!
   ;====================================================================

   ; Read all J-value data blocks from the file
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, /Quiet, _EXTRA=e
    
   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ;------------------
      ; INPUT GRID
      ;------------------

      ; Get corresponding MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
 
      ; Pointer to INPUT DATA
      Pointer = DataInfo[D].Data

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'
      
      ; Get INPUT DATA
      InData  = *( Pointer )
      
      ; Free the heap memory
      Ptr_Free, Pointer

      ;-------------------
      ; OUTPUT GRID 
      ;-------------------

      ; Use MODELNAME from INPUT GRID if not passed explicitly
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name
      
      ; Output grid parameters
      OutType = CTM_Type( OutModelName, Res=OutResolution  )
      OutGrid = CTM_Grid( OutType )

      ; Output data array (same # of levels as INDATA)
      OutData = FltArr( OutGrid.IMX, OutGrid.JMX, DataInfo[D].Dim[2] )      

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;------------------
      ; REGRID DATA!
      ;------------------      

      ; Interpolate from the old grid to the new grid
      for L = 0L, DataInfo[D].Dim[2]-1L do begin
         OutData[*,*,L] = Interpolate_2D( InData[*,*,L],              $
                                          InGrid.Xmid,  InGrid.Ymid,  $
                                          OutGrid.XMid, OutGrid.YMid, $
                                          /Double )
      endfor
      
      ;------------------
      ; SAVE DATA BLOCKS
      ;------------------      
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
 
      ; Store into the NEWDATAINFO array of structures
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset first time flag
      FirstTime = 0L

      ; Undefine data
      UnDefine, InData
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, OutData
      UnDefine, OutType
      UnDefine, OutGrid
      UnDefine, PSurf
   endfor
 
   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'JH2O2.' + CTM_NamExt( OutTypeSav ) + $
                    '.'      + CTM_ResExt( OutTypeSav ) 
   endif

   ; Save as binary punch file
   CTM_WriteBpch, NewDataInfo, ThisfileInfo, FileName=OutFileName

end                               
 
    
 
