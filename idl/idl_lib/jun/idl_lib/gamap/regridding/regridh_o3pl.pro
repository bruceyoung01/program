; $Id: regridh_o3pl.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_O3PL
;
; PURPOSE:
;        Horizontally regrids files containing GEOS-CHEM P(O3) and L(O3).
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_O3PL [, Keywords ]
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
;             will be regridded.  If omitted then OUTMODELNAME will
;             be determined automatically from INFILENAME.
;
;        OUTRESOLUTION -> Resolution of the model grid onto which
;             the data will be regridded.  Default is 4.
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
;        REGRIDH_O3PL, INFILENAME='~/2x25/rate.20010101', $
;                      OUTFILENAME='~/4x5/rate.20010101', $ 
;                      OUTRESOLUTION=4
;
;             ; Regrids P(O3) and L(O3) data from 2x2.5 to 4x5
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
; or phs@io.as.harvard.edu with subject "IDL routine regridv_o3pl"
;-----------------------------------------------------------------------


pro RegridH_O3PL, InFileName=InFileName,     OutFileName=OutFileName,     $
                  OutModelName=OutModelName, OutResolution=OutResolution, $
                  DiagN=DiagN,               _EXTRA=e

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

      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Pointer to the INPUT DATA
      Pointer = DataInfo[D].Data 

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Get INPUT data
      InData  = *( Pointer )

      ; Strip out NaN's or infinities
      BadPts = Where( not Float( Finite( InData ) ) )
      if ( BadPts[0] ge 0 ) then InData[BadPts] = 0e0

      ;-------------------
      ; OUTPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=OutResolution )
      OutGrid = CTM_Grid( OutType )
      
      ; Save for later use
      OutTypeSav = OutType

      ;-------------------
      ; REGRID DATA
      ;-------------------

      ; Regrid the data
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid, $
                             /Per_Unit_Area, /Double, _EXTRA=e )
     
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
   
   ; Convert TAU0 to YYYY/MM/DD
   Nymd        = Tau2YYMMDD( Tau0Today, /Nformat )
   NymdStr     = String( Nymd[0], Format='(i8)' )

   ; Replace %DATE% token with the actual date
   OutFileName = Replace_Token( OutFileName, '%DATE%', NymdStr )

   ; Write to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                  
 
