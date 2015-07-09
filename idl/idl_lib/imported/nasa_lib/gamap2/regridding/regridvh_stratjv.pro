; $Id: regridvh_stratjv.pro,v 1.1.1.1 2007/07/17 20:41:31 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDVH_STRATJV
;
; PURPOSE:
;        Vertically regrids 2-D stratospheric J-Value data
;        from one CTM grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDVH_STRATJV [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             Default is "stratjv.{MODELNAME}.{RESOLUTION}".
;
;        OUTFILENAME -> Name of output file containing the regridded
;             data.  Default is "stratjv.{MODELNAME}.{RESOLUTION}"
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  Default is "GEOS3".
;
;        OUTRESOLUTION -> Horizontal resolution of the model grid onto 
;             which the data will be regridded.  Default=4 (which
;             indicates a 4x5 grid).
;             
;        DIAGN -> Diagnostic category of data block that you want
;             to regrid.  Default is "JV-MAP-$".
;
; OUTPUTS:
;        Writes output to the "stratjv.{MODELNAME}.{RESOLUTION}" file.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==========================================================
;        CTM_TYPE          (function)  CTM_GRID          (function)
;        CTM_NAMEXT        (function)  CTM_RESEXT        (function)
;        CTM_GET_DATABLOCK (function)  CTM_MAKE_DATAINFO (function)
;        ZSTAR             (function)  GET_GCAP_PRESSURE (function)
;        UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        2-D Stratospheric J-Values are needed for the simple chemistry 
;        mechanism in the stratosphere.  They are originally obtained 
;        by running the GEOS model with SLOW-J and then archiving 
;        the J-Values with the ND22 diagnostic.  These can then be
;        regridded to other vertical resolutions via REGRID_STRATJV.
;
; EXAMPLE:
;        REGRIDVH_STRATJV, INFILENAME='stratjv.geoss.4x5'
;                          OUTMODELNAME='GEOS3',      $
;                          OUTRESOLUTION=4 
;                          OUTFILENAME='stratjv.geos3.4x5'
;                         
;             ; Regrids the 4 x 4 GEOS-STRAT 2-D stratospheric 
;             ; J-value field to the GEOS-3 grid.
;
; MODIFICATION HISTORY:
;        bmy, 06 Aug 2004: VERSION 1.01
;        bmy, 15 Feb 2007: VERSION 1.02
;                          - Suppress verbose output
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
;
;-
; Copyright (C) 2004-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridvh_stratjv"
;-----------------------------------------------------------------------

pro RegridVH_StratJV, InFileName=InFileName,     OutFileName=OutFileName,     $
                      OutModelName=OutModelName, OutResolution=OutResolution, $
                      DiagN=DiagN,               _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_NamExt, CTM_ResExt,        CTM_Type, $
                    CTM_Grid,   Get_GCAP_Pressure, ZStar

   ; Keywords
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'JV-MAP-$'
   if ( N_Elements( OutModelName  ) ne 1 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
  
   ; Values for indexing each month
   Tau       = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                 4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]

   ; First time flag
   FirstTime = 1L

   ; Get MODELINFO and GRIDINFO structures for OUTPUT grid
   OutType = CTM_Type( OutModelName, Res=OutResolution )
   OutGrid = CTM_Grid( OutType )

   ;====================================================================
   ; Process data
   ;====================================================================

   ; Read data into DATAINFO structure
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, /Quiet, _EXTRA=e

   ; Loop over data blocks
   for D = 0L, N_Elements( DataInfo )-1L do begin

      ;=================================================================
      ; Regrid vertically
      ;=================================================================

      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Vertical center coordinates
      if ( InType.Hybrid )              $
         then InVertMid = InGrid.EtaMid $
         else InVertMid = InGrid.SigMid

      ; Pointer to the INPUT DATA
      Pointer = DataInfo[D].Data 

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Get INPUT data and remove extraneous dimensions
      InData  = *( Pointer )
      InData  = Reform( InData )

      ; Free the pointer heap memory
      Ptr_Free, Pointer

      ;-------------------
      ; TEMPORARY GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      TmpType = CTM_Type( OutModelName, Res=InType.Resolution )
      TmpGrid = CTM_Grid( TmpType )

      ; Vertical center coordinates
      if ( TmpType.Hybrid )               $
         then TmpVertMid = TmpGrid.EtaMid $
         else TmpVertMid = TmpGrid.SigMid 

      ;-------------------
      ; SURFACE PRESSURE
      ;-------------------

      ; Surface pressure filename
      PsFileName = 'ps-ptop.' + CTM_NamExt( InType ) + $
                   '.'        + CTM_ResExt( InType )

      ; Look for PSFILENAME in the current directory, and 
      ; failing that, in the directories specified in !PATH
      PsFileName = File_Which( PsFileName, /Include_Current_Dir )
      PsFileName = Expand_Path( PsFileName )

      ; Get current month index
      Result  = Tau2YYMMDD( DataInfo[D].Tau0 )
      MonInd  = Result.Month - 1L
    
      ; Read this month's surface pressure data
      Success = CTM_Get_DataBlock( PSurf, 'PS-PTOP',    $
                                   FileName=PSFileName, $
                                   Tracer=1L,           $
                                   Tau0=Tau[MonInd],    $
                                   /Quiet, /NoPrint )
   
      ; Error check
      if ( not Success ) then Message, 'Could not read PSURF data!'

      ; Compute zonal average surface pressure array
      PAvg = Fltarr( InGrid.JMX )
      for J = 0L, InGrid.JMX-1L do begin
         PAvg[J] = Total( PSurf[*,J] ) / Float( InGrid.IMX )
      endfor

      ;-------------------
      ; REGRID VERTICAL
      ;-------------------

      ; Output data array 
      TmpData = FltArr( InGrid.JMX, TmpGrid.LMX )

      ; Loop over latitudes
      for J = 0L, InGrid.JMX-1L do begin
            
         ; Pressures on INPUT and OUTPUT grid
         InPrs  = ( InVertMid  * PAvg[J]  ) + InType.PTOP

         ; Get pressure on OUTPUT grid
         if ( TmpType.NAME eq 'GCAP' )                           $
            then TmpPrs = Get_GCAP_Pressure( PAvg[J], /Centers ) $
            else TmpPrs = ( TmpVertMid * PAvg[J] ) + TmpType.PTOP 
            
         ; Altitudes on INPUT and OUTPUT grids
         InZMid  = ZStar( InPrs  )
         TmpZMid = ZStar( TmpPrs )            

         ; Column of data on the INPUT grid
         InCol   = InData[J,*]

         ; Interpolate to new vertical resolution
         TmpCol  = InterPol( InCol, InZMid, TmpZMid )

         ; Filter out negative numbers from the vertical regridding
         Ind = Where( TmpCol lt 0.0 )
         if ( Ind[0] ge 0 ) then TmpCol[Ind] = 0D

         ; Save into the new data array
         TmpData[J,*] = TmpCol

      endfor

      ;=================================================================
      ; Regrid horizontally
      ;=================================================================

      ; Output data array
      OutData = FltArr( OutGrid.JMX, OutGrid.LMX )

      ; Interpolate horizontally
      for L = 0L, OutGrid.LMX -1L do begin
         OutData[*,L] = InterPol( TmpData[*,L], InGrid.YMid, OutGrid.YMid )
      endfor

      ; Reset negatives to zero
      Ind =  Where( OutData lt 0.0 )
      if ( Ind[0] ge 0 ) then OutData[Ind] = 0.0


      ;=================================================================
      ; Save data blocks
      ;=================================================================

      ; Make a DATAINFO structure 
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
                                         OutGrid.LMX,          $
                                         DataInfo[D].Dim[3] ], $
                                   First=DataInfo[D].First,    $
                                   /No_Global )

      ; Append into NEWDATAINFO array of structures
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset FIRSTTIME
      FirstTime = 0L

      ; Undefine stuff
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, InData
      UnDefine, TmpType
      UnDefine, TmpGrid
      UnDefine, TmpData
      UnDefine, OutData
      UnDefine, PSurf
      UnDefine, PAvg
      UnDefine, ThisDataInfo      
   endfor

   ;====================================================================
   ; Save data to disk
   ;====================================================================   

   ; Output file name
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'stratjv.' + CTM_NamExt( OutType ) + $
                    '.'        + CTM_ResExt( OutType ) 
   endif

   ; Write to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                               
 
    
 
