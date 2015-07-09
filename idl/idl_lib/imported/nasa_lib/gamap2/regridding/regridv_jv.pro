; $Id: regridv_jv.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDV_JV
;
; PURPOSE:
;        Vertically regrids J-values from one CTM grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDV_JV, [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing input data to be
;             regridded to the output grid specified by MODELNAME
;             and RESOLUTION.
;
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        OUTFILENAME -> Name of file containing regridded output
;             data.  Written in binary punch format.
;
;        /TROP_ONLY -> Set this switch to only save data below
;             the tropopause.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =======================================================
;        CTM_TYPE     (function)   CTM_GRID           (function)
;        CTM_NAMEXT   (function)   CTM_RESEXT         (function)
;        ZSTAR        (function)   CTM_GET_DATABLOCK  (function)
;        CTM_GET_DATA              CTM_MAKE_DATAINFO  (function)
;        CTM_WRITEBPCH             GETMODELANDGRIDINFO  
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDV_JV, INFILENAME='JH2O2.geos3.4x5',  $
;                    OUTFILENAME='JH2O2.geos4.4x5', $
;                    OUTMODELNAME='GEOS4'
;
;             ; Regrids GEOS-3 stratospheric J-value data at 4 x 5
;             ; resolution from GEOS-3 to GEOS-4 vertical resolution.
;
; MODIFICATION HISTORY:
;        bmy, 11 Aug 2000: VERSION 1.01
;        bmy, 22 Dec 2003: VERSION 1.02
;                          - renamed to "regridv_jv"
;                          - now looks for sfc pressure in ~/IDL/regrid/PSURF
;                          - now updated for GAMAP v2-01
;                          - added /TROP_ONLY keyword
;                          - updated comments
;        bmy, 07 Jul 2005: VERSION 1.03
;                          - Now pass /QUIET keyword to CTM_GET_DATA
;                          - Now pass /NOPRINT keyword to CTM_GET_DATABLOCK
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
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
; or phs@io.as.harvard.edu with subject "IDL routine regridv_jv"
;-----------------------------------------------------------------------

pro RegridV_JV, InFileName=InFileName,   OutModelName=OutModelName,  $
                OutFileName=OutFileName, Trop_Only=Trop_Only,        $
                _Extra=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_NamExt, CTM_ResExt, $
                    ZStar, CTM_Get_DataBlock, CTM_Make_DataInfo 

   ; Keyword Settings
   Trop_Only = Keyword_Set( Trop_Only )
   if ( N_Elements( InFileName   ) ne 1 ) then InFileName   = 'JH2O2.geos.4x5'
   if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = 'GEOS3'

   ; Time values for each month
   Tau        = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                  4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
      
   ; First time flag
   FirstTime  = 1L
   
   ;====================================================================
   ; Process data
   ;====================================================================

   ; Read all J-value data blocks from the file
   CTM_Get_Data, DataInfo, 'JV-MAP-$', FileName=InFileName, /Quiet
    
   ; Loop over each data block
   for D = 0L, N_Elements( DataInfo ) - 1L do begin
 
      ; Make sure data is 3-D before regridding vertically
      if ( DataInfo[D].Dim[2] le 1 ) then Message, 'DATA is not 3-D!'

      ;-----------------
      ; INPUT GRID
      ;-----------------

      ; Get MODELINFO and GRIDINFO structures for INPUT GRID
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Vertical coordinates on input grid
      if ( InType.Hybrid )                                         $
         then InVertMid = InGrid.EtaMid[ 0:DataInfo[D].Dim[2]-1L ] $
         else InVertMid = InGrid.SigMid[ 0:DataInfo[D].Dim[2]-1L ] 

      ; Make a copy of the pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid pointer!'

      ; Dereference the pointer to get the data
      InData  = *( Pointer )

      ; Free the associated pointer heap memory
      Ptr_Free, Pointer

      ;-----------------
      ; OUTPUT GRID
      ;-----------------
      OutType = CTM_Type( OutModelName, Res=InType.Resolution )
      OutGrid = CTM_Grid( OutType )
      
      ; Maximum level to save on OUTPUT grid
      if ( Trop_Only )            $   
         then LMX = OutType.NTROP $
         else LMX = OutGrid.LMX 

      ; Vertical coordinates 
      if ( OutType.Hybrid )                           $
         then OutVertMid = OutGrid.EtaMid[ 0:LMX-1L ] $
         else OutVertMid = OutGrid.SigMid[ 0:LMX-1L ] 

      ; Save for future use
      OutTypeSav = OutType

      ; Output data array (only up to tropopause)
      OutData = FltArr( OutGrid.IMX, OutGrid.JMX, OutType.NTROP )

      ;------------------
      ; SURFACE PRESSURE
      ;------------------

      ; Get current month index
      Result  = Tau2YYMMDD( DataInfo[D].Tau0 )
      MonInd  = Result.Month - 1L

      ; Surface pressure file name
      PsFileName = 'ps-ptop.' + CTM_NamExt( InType ) + $
                   '.'        + CTM_ResExt( InType )

      ; Look for PSFILENAME in the current directory, and 
      ; failing that, in the directories specified in !PATH
      PsFileName = File_Which( PsFileName, /Include_Current_Dir )
      PsFileName = Expand_Path( PsFileName )
    
      ; Read this month's surface pressure data
      Success = CTM_Get_DataBlock( PSurf, 'PS-PTOP',    $
                                   FileName=PSFileName, $
                                   Tracer=1L,           $
                                   Tau0=Tau[MonInd],    $
                                   /Quiet, /NoPrint )

      if ( not Success ) then Message, 'Could not find surface pressure!'
      
      ;==================================================================
      ; Regrid J-values by vertical interpolation
      ;==================================================================
      for J = 0L, OutGrid.JMX - 1L do begin
      for I = 0L, OutGrid.IMX - 1L do begin

         ; Pressures at each sigma level
         InP    = ( ( Psurf[I,J] - InType.PTOP  ) * InVertMid  ) + InType.PTOP
         OutP   = ( ( PSurf[I,J] - OutType.PTOP ) * OutVertMid ) + OutType.PTOP
 
         ; Convert to pressure-altitude
         InZ    = ZStar( InP )
         OutZ   = ZStar( OutP )

         ; Do a quickie interpolation
         OutCol = InterPol(  InData[I,J,*], InZ, OutZ )
 
         ; Save in the OUTDATA array, make sure no negatives
         OutData[I,J,*] = OutCol > 0.0
 
         ; Undefine stuff
         UnDefine, InP
         UnDefine, OutP
         UnDefine, InZ
         UnDefine, OutZ
         UnDefine, InCol
         UnDefine, OutCol
      endfor
      endfor
 
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
                                         LMX, 0L ],            $
                                   First=[1L, 1L, 1L],         $
                                   /No_Global ) 
 
      ; Store all data blocks in the NEWDATAINFO array of structures
      if ( FirstTime )                                   $
         then NewDataInfo = [ ThisDataInfo ]             $
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
      UnDefine, InVertMid
      UnDefine, OutVertMid
      UnDefine, PSFileName
      UnDefine, PSurf
   endfor
 
   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName  ) ne 1 ) then begin
      OutFileName = 'JH2O2.' + CTM_NamExt( OutTypeSav ) + $
                    '.'      + CTM_ResExt( OutTypeSav ) 
   endif

   ; Save to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName
 
end                               
 
    
 
