; $Id: regridv_o3pl.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDV_O3PL
;
; PURPOSE:
;        Vertically regrids files containing GEOS-CHEM P(O3) and L(O3).
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRID_O3PL [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If INFILENAME is not specified, then REGRIDV_O3PL
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
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===========================================================
;        CTM_TYPE          (function)   CTM_GRID          (function)
;        CTM_GET_DATABLOCK (function)   CTM_MAKE_DATAINFO (function)
;        TAU2YYMMDD        (function)   ZSTAR             (function)
;        REPLACE_TOKEN     (function)   GETMODELANDGRIDINFO 
;        UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDV_O3PL, INFILENAME='~/geoss/rate.971130', $
;                      OUTFILENAME='~/geos3/rate.971130', $ 
;                      OUTMODELNAME='GEOS3'
;
;             ; Regrids P(O3) and L(O3) data from GEOS-STRAT 
;             ; 4 x 5 grid to GEOS-3 4 x 5 grid.
;
; MODIFICATION HISTORY:
;        bmy, 27 Mar 2001: VERSION 1.00
;        bmy, 23 Dec 2003: VERSION 1.01
;                          - renamed to "regridv_o3pl.pro"
;                          - rewritten for GAMAP v2-01
;                          - now looks for sfc pressure in ~/IDL/regrid/PSURF
;        bmy, 24 Feb 2004: VERSION 1.02
;                          - now convert P(Ox) to kg/s and L(Ox) 1/s for
;                            regridding -- then convert back after regridding
;                          - now use REGRID_COLUMN to regrid P(Ox) in kg/s
;                          - now use INTERPOL to regrid L(Ox) in 1/s
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
;
;-
; Copyright (C) 2001-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridv_o3pl"
;-----------------------------------------------------------------------


pro RegridV_O3PL, InFileName=InFileName,     OutFileName=OutFileName, $
                  OutModelName=OutModelName, DiagN=DiagN,             $
                  New_Nymd=New_Nymd,         _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Type,     CTM_Grid,  CTM_Get_DataBlock, $
                    Tau2YYMMDD,   ZStar,     CTM_Make_DataInfo, $
                    Replace_Token
 
   ; Keywords
   if ( N_Elements( DiagN        ) ne 1 ) then DiagN        = 'PORL-L=$'
   if ( N_Elements( OutFileName  ) ne 1 ) then OutFileName  = 'rate.%DATE%'
   if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = 'GEOS3'
  
   ; Time indices for output punch file
   Tau       = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                 4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
       
   ; First-time flag
   FirstTime = 1L

   ;====================================================================
   ; Process data
   ;====================================================================

   ; Read data blocks into DATAINFO array of structures
   CTM_Get_Data, DataInfo, DiagN, File=InFileName, /Quiet, _EXTRA=e

   ; Loop over data blocks
   for D = 0L, N_Elements( DataInfo )-1L do begin

      ; Save time for future use
      Tau0Today = DataInfo[D].Tau0

      ;%%% KLUDGE FOR OX SPINUP
      InTau   = DataInfo[D].Tau0
      InNymd  = ( Tau2YYMMDD( InTau, /NFormat ) )[0]
      OutNYMD = InNymd - 10000L 
      OutTau0 = NYMD2Tau( OutNymd )

      InTau   = DataInfo[D].Tau1
      InNymd  = ( Tau2YYMMDD( InTau, /NFormat ) )[0]
      OutNYMD = InNymd - 10000L
      OutTau1 = NYMD2Tau( OutNYMD )

      UnDefine, InTau
      UnDefine, InNYMD

      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Vertical edge and center coords on INPUT GRID
      if ( InType.Hybrid ) then begin
         InVertEdge = InGrid.EtaEdge[ 0L:DataInfo[D].Dim[2]    ] 
         InVertMid  = InGrid.EtaMid [ 0L:DataInfo[D].Dim[2]-1L ] 
      endif else begin
         InVertEdge = InGrid.SigEdge[ 0L:DataInfo[D].Dim[2]    ] 
         InVertMid  = InGrid.SigMid [ 0L:DataInfo[D].Dim[2]-1L ] 
      endelse

      ; Pointer to the INPUT DATA
      Pointer = DataInfo[D].Data 

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Get INPUT data
      InData  = *( Pointer )

      ; Free the heap memory
      Ptr_Free, Pointer

      ; Strip out NaN's or infinities
      BadPts = Where( not Float( Finite( InData ) ) )
      if ( BadPts[0] ge 0 ) then InData[BadPts] = 0e0

      ;-------------------
      ; OUTPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=InType.Resolution )
      OutGrid = CTM_Grid( OutType )

      ; We only need to save data in the troposphere
      LMX = OutType.NTrop

      ; Vertical edge and center coordinates on OUTPUT GRID
      if ( OutType.Hybrid ) then begin
         OutVertEdge = OutGrid.EtaEdge[ 0L:LMX    ] 
         OutVertMid  = OutGrid.EtaMid [ 0L:LMX-1L ]
      endif else begin
         OutVertEdge = OutGrid.SigEdge[ 0L:LMX    ] 
         OutVertEdge = OutGrid.SigMid [ 0L:LMX-1L ] 
      endelse

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ; Output data array 
      OutData = FltArr( OutGrid.IMX, OutGrid.JMX, LMX )
      
      ;-------------------
      ; VOLUMES (approx)
      ;-------------------

      ; Get volumes [cm3] on first timestep only
      if ( FirstTime ) then begin
         InVol  = CTM_BoxSize( InGrid,  /GEOS, /Volume, /Cm3 )
         OutVol = CTM_BoxSize( OutGrid, /GEOS, /Volume, /Cm3 )

         ; Cut down to tropospheric size
         InVol  = InVol[*,*,0:InType.NTrop-1L]
         OutVol = OutVol[*,*,0:OutType.NTrop-1L]
      endif

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

      ;-------------------
      ; REGRID DATA
      ;-------------------
 
      ; Loop over latitudes
      for J = 0L, InGrid.JMX-1L do begin
      for I = 0L, InGrid.IMX-1L do begin
                     
         if ( DataInfo[D].Tracer mod 100L eq 1 ) then begin

            ;---------------------
            ; P(Ox) in [kg/cm3/s]
            ;---------------------

            ; Convert from [kg/cm3/s] to [kg/s]
            InCol = Reform( InData[I,J,*] * InVol[I,J,*] )

            ; Pressures on INPUT and OUTPUT grids
            InPMid  = ( InVertMid  * PSurf[I,J] ) + InType.PTOP
            OutPMid = ( OutVertMid * Psurf[I,J] ) + OutType.PTOP

            ; Regrid P(Ox) in [kg/s]
            ;--------------------------------------------------------
            ; Prior to 6/12/07:
            ; Use INTERPOL
            ;OutCol = Regrid_Column( InCol, InPEdge, OutPEdge )
            ;--------------------------------------------------------
            OutCol = InterPol( InCol, InPMid, OutPMid )
            
            ; Filter out negatives
            Ind = Where( OutCol lt 0.0 )
            if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

            ; Convert from [kg/s] back to [kg/cm3/s]
            OutCol = OutCol / OutVol[I,J,*]

            ; Undefine stuff
            UnDefine, InPEdge
            UnDefine, OutPEdge

         endif else begin

            ;---------------------
            ; L(Ox) in [1/cm3/s]
            ;---------------------

            ; Convert from [1/cm3/s] to [1/s]
            InCol = Reform( InData[I,J,*] * InVol[I,J,*] )

            ; Pressures on INPUT and OUTPUT grids
            InPMid  = ( InVertMid  * PSurf[I,J] ) + InType.PTOP
            OutPMid = ( OutVertMid * Psurf[I,J] ) + OutType.PTOP

            ; Altitudes on INPUT and OUTPUT grids
            InZMid  = ZStar( InPMid )
            OutZMid = ZStar( OutPMid )
            
            ; Regrid L(Ox) in [1/s]
            OutCol  = InterPol( InCol, InZMid, OutZMid )

            ;### Debug
            ;multipanel, 2
            ;plot,  Incol,  InZMid, Color=1,  Psym=-Sym(2)
            ;oplot, OutCol, OutZMid, Color=4, PSym=-Sym(2)
            
            ; FILTER out negatives
            Ind = Where( OutCol lt 0.0 )
            if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

            ; Convert from [1/s] back to [1/cm3/s]
            OutCol = OutCol / OutVol[I,J,*]

            ;### Debug
            ;plot,  InData[I,J,*],  InZMid,  Color=1,  Psym=-Sym(2)
            ;oplot, OutCol,         OutZMid, Color=4, PSym=-Sym(2)
            ;pause

            ; Undefine stuff
            UnDefine, InPMid
            UnDefine, OutPMid
            UnDefine, InZMid
            UnDefine, OutZMid
            
         endelse
         
         ; Save into OUTDATA
         OutData[I,J,*] = Reform( OutCol )

         ; Undefine stuff
         UnDefine, InCol
         UnDefine, OutCol

      endfor
      endfor

      ;-------------------
      ; SAVE DATA BLOCKS
      ;-------------------

      ; Make a DATAINFO structure 
      Success = CTM_Make_DataInfo( Float( OutData ),           $
                                   ThisDataInfo,               $
                                   ThisFileInfo,               $
                                   ModelInfo=OutType,          $
                                   GridInfo=OutGrid,           $
                                   DiagN=DataInfo[D].Category, $
                                   Tracer=DataInfo[D].Tracer,  $
                                   ;%%% OX SPINUP -- KLUDGE
                                   ;%%%Tau0=DataInfo[D].Tau0,      $
                                   ;%%%Tau1=DataInfo[D].Tau1,      $
                                   Tau0=OutTau0,               $
                                   Tau1=OutTau1,               $
                                   Unit=DataInfo[D].Unit,      $
                                   Dim=[ OutGrid.IMX,          $
                                         OutGrid.JMX,          $ 
                                         LMX,                  $
                                         DataInfo[D].Dim[3] ], $
                                   First=DataInfo[D].First,    $
                                   /No_Global )

      ; Error check
      if ( not Success ) then Message, 'Could not create DATAINFO structure!'

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
      UnDefine, OutType
      UnDefine, OutGrid
      UnDefine, OutData
      UnDefine, PSurf
      UnDefine, ThisDataInfo      
   endfor

   ;====================================================================
   ; Save data to disk
   ;====================================================================   
   
   ; Replace %DATE% token with the actual date
   ;if ( N_Elements( New_Nymd ) gt 0 ) then begin
   ;   OutFileName = Replace_Token( OutTmp, '%DATE%', New_Nymd )
   ;endif

   ; Write to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                  
 
