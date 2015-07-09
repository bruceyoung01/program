; $Id: regridv_porl.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDV_PORL
;
; PURPOSE:
;        Regrids production/loss or other data in [molec/cm3/s]
;        from one vertical CTM grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDV_PORL [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If INFILENAME is not specified, then REGRIDV_PORL
;             will prompt the user to select a file via a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  If OUTFILENAME is not specified, then REGRIDV_PORL
;             will prompt the user to select a file via a dialog box.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  Default is "GEOS3".
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "PORL-L=$".
;
;        /TROP_ONLY -> Set this switch to only save regridded data
;             from the surface to the highest tropopause level
;             (e.g. MODELINFO.NTROP as returned from CTM_TYPE).
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =======================================================
;        CTM_GRID          (function)   CTM_TYPE          (function)
;        CTM_BOXSIZE       (function)   CTM_REGRID        (function)
;        CTM_NAMEXT        (function)   CTM_RESEXT        (function)
;        CTM_GET_DATABLOCK (function)   CTM_MAKE_DATAINFO (function)
;        REGRID_COLUMN     (function)   CTM_WRITEBPCH              
;        CTM_GET_DATA                   GETMODELANDGRIDINFO        
;        UNDEFINE   
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDV_PORL, INFILENAME='data.geos3.4x5',  $
;                      OUTFILENAME="data.geos4.4x5', $
;                      OUTMODELNAME='GEOS4'
;
;             ; Regrids data in molec/cm3 from GEOS-3 vertical
;             ; resolution to GEOS_4 vertical resolution.
;
; MODIFICATION HISTORY:
;        bmy, 01 Nov 2002: VERSION 1.01
;        bmy, 19 Dec 2003: VERSION 1.02
;                          - rewritten for GAMAP v2-01
;                          - now looks for sfc pressure in ~/IDL/regrid/PSURF/
;                          - now supports hybrid grids
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
;
;-
; Copyright (C) 2002-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridv_porl"
;-----------------------------------------------------------------------

pro RegridV_PorL, InFileName=InFileName,     OutFileName=OutFileName, $
                  OutModelName=OutModelName, Trop_Only=Trop_Only,     $
                  DiagN=DiagN,               _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type,          CTM_Grid,      CTM_BoxSize,       $
                    CTM_NamExt,        CTM_ResExt,    CTM_Get_DataBlock, $
                    CTM_Make_DataInfo, Regrid_Column, ZStar
       
   ; Keyword Settings
   Trop = Keyword_Set( Trop_Only )
   if ( N_Elements( DiagN        ) ne 1 ) then DiagN        = 'PORL-L=$'
   if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = 'GEOS3'
  
   ; Time values for each month
   Tau       = [    0D,  744D, 1416D, 2160D, 2880D, 3624D, $
                 4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
    
   ; First time flag
   FirstTime = 1L

   ;====================================================================
   ; Process data
   ;====================================================================

   ; Read data into the DATAINFO array of structures
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, /Quiet, _EXTRA=e

   ; Loop over all data blocks in DATAINFO
   for D = 0L, N_Elements( DataInfo ) - 1L do begin
      
      ;------------------
      ; INPUT GRID
      ;------------------

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Box volumes [cm3]
      InVol = CTM_BoxSize( InGrid, /GEOS, /Volume, /cm3 )
      InVol = InVol[*,*,0:DataInfo[D].Dim[2]-1L]

      ; Vertical edge coordinates on INPUT GRID
      if ( InType.Hybrid )                                        $ 
         then InVertEdge = InGrid.EtaEdge[ 0:DataInfo[D].Dim[2] ] $
         else InVertEdge = InGrid.SigEdge[ 0:DataInfo[D].Dim[2] ] 

      ; Copy the pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Get INPUT DATA array
      InData  = *( Pointer )
      
      ; Free the pointer heap memory
      ;Ptr_Free, Pointer

      ;------------------
      ; OUTPUT GRID
      ;------------------

      ; Get MODELINFO and GRIDINFO structures
      OutType  = CTM_Type( OutModelName, Resolution=InType.Resolution )
      OutGrid  = CTM_Grid( OutType )

      ; Maximum level to save on OUTPUT grid
      if ( Trop )                 $   
         then LMX = OutType.NTROP $
         else LMX = OutGrid.LMX

      ; Box volumes [cm3] 
      OutVol  = CTM_BoxSize( OutGrid, /GEOS, /Volume, /cm3 )
      OutVol  = OutVol[*,*,0:LMX-1]

      ; Vertical edge coordinates on OUTPUT GRID
      if ( OutType.Hybrid )                          $
         then OutVertEdge = OutGrid.EtaEdge[ 0:LMX ] $
         else OutVertEdge = OutGrid.SigEdge[ 0:LMX ] 

      ; Save for future use
      OutTypeSav = OutType

      ; OUTPUT data array
      OutData = FltArr( DataInfo[D].Dim[0], DataInfo[D].Dim[1], LMX )

      ;------------------
      ; SURFACE PRESSURE
      ;------------------

      ; Get current month index
      Result  = Tau2YYMMDD( DataInfo[D].Tau0 )
      MonInd  = Result.Month - 1L

      ; Surface pressure filename
      PsFile  = 'ps-ptop.' + CTM_NamExt( InType ) + $
                '.'        + CTM_ResExt( InType )
    
      ; Look for PSFILE in the current directory, and 
      ; failing that, in the directories specified in !PATH
      PsFile = File_Which( PsFile, /Include_Current_Dir )
      PsFile = Expand_Path( PsFile )

      ; Read this month's surface pressure data
      Success = CTM_Get_DataBlock( PSurf, 'PS-PTOP', $
                                   FileName=PSFile,  $
                                   Tracer=1L,        $
                                   Tau0=Tau[MonInd], $
                                   /Quiet, /NoPrint )

      ; Error check
      if ( not Success ) then Message, 'Could not read PS data!'

      ;--------------------
      ; USE COLUMN SUMS?
      ;-------------------
      
      ; Decide whether to suppress column sum or not -- if we are going
      ; from a high grid to a low grid, then column sum doesn't make sence
      if ( InType.Name  eq 'GEOS3'    AND $
           OutType.Name eq 'GEOS1' ) then begin
         No_Check = 1                     

      endif else if ( InType.Name  eq 'GEOS3'        AND $
                      OutType.Name eq 'GEOS_STRAT' ) then begin
         No_Check = 1                     

      endif else if( InType.Name  eq 'GEOS4'   AND $
                     OutType.Name eq 'GEOS1' ) then begin 
         No_Check = 1                                            

      endif else if ( InType.Name  eq 'GEOS_STRAT' AND $
                      OutType.Name eq 'GEOS1'    ) then begin
         No_Check = 1                                            
   
      endif else begin
         No_Check = 0
         
      endelse

      ; Turn off checking if we are just saving the troposphere
      if ( Trop_Only ) then No_Check = 0L

      ;=================================================================
      ; Regrid data vertically, column by column
      ;=================================================================
      for J = 0L, InGrid.JMX-1L do begin
      for I = 0L, InGrid.IMX-1L do begin

         ; Compute pressure edges for this column
         InPEdge  = ( InVertEdge  * Psurf[I,J] ) + InType.PTOP
         OutPEdge = ( OutVertEdge * Psurf[I,J] ) + OutType.PTOP
           
         ; Save the current column of old OH data into OLDCOL
         ; Convert from [molec/cm3/s] to [molec/s]
         InCol = Reform( InData[I,J,*] * InVol[I,J,*] )
            
         ; Regrid vertically -- preserve column mass
         OutCol = Regrid_Column( InCol, InPEdge, OutPEdge, $
                                 No_Check=No_Check, _EXTRA=e )
         
         ; Convert regridded data from [molec/s] to [molec/cm3/s] 
         OutData[I,J,*] = Reform( OutCol / OutVol[I,J,*] )
           
         ; Undefine variables for safety's sake
         UnDefine, InCol
         UnDefine, OutCol
         UnDefine, InPEdge
         UnDefine, OutPEdge
               
      endfor
      endfor

      ;=================================================================
      ; Store new data blocks
      ;=================================================================

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
                                   ;Unit=DataInfo[D].Unit,         $
                                   Unit = 'molec/cm3/s',          $
                                   Dim=[DataInfo[D].Dim[0],       $
                                        DataInfo[D].Dim[1],       $
                                        LMX, $
                                        DataInfo[D].Dim[3] ],     $ 
                                   First=DataInfo[D].First,       $
                                   /No_Global )
 
      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO structure!'

      ; Append into NEWDATAINFO array of structures
      if ( FirstTime )                                            $
         then NewDataInfo = ThisDataInfo                          $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset FIRSTTIME
      FirstTime = 0L

      ; Undefine variables for safety's sake
      UnDefine, ThisDataInfo
      UnDefine, InType
      UnDefine, OutType
      UnDefine, InGrid
      UnDefine, OutGrid
      UnDefine, InData
      UnDefine, OutData
      UnDefine, InVertEdge
      UnDefine, OutVertEdge
      UnDefine, InVol
      UnDefine, OutVol
      UnDefine, PSurf
      UnDefine, PSFile
   endfor   
 
   ;====================================================================
   ; Write all data blocks to a binary punch file
   ;====================================================================
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'REGRIDV_PORL.' + CTM_NamExt( OutTypeSav ) + $
                    '.'             + CTM_ResExt( OutTypeSav ) 
   endif

   ; Write to binary punch file
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end
