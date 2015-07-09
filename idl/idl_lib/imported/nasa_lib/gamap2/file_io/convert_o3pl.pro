; $Id: convert_o3pl.pro,v 1.2 2008/04/02 15:19:01 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CONVERT_O3PL
;
; PURPOSE:
;        Converts single-tracer Ox rate files from their native
;        binary format to binary punch format 
;
; CATEGORY:
;        File & I/O, BPCH Format
;
; CALLING SEQUENCE:
;        CONVERT_O3PL [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INMODELNAME -> A string containing the name of the model
;             grid on which the input data resides.  Default is GEOS_STRAT.
;
;        INRESOLUTION -> Specifies the resolution of the model grid
;             on which the input data resides.  RESOLUTION can be 
;             either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default is 2.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        CTM_TYPE          (function)  
;        CTM_GRID          (function)
;        CTM_MAKE_DATAINFO (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Input file names are hardwired for now.
;
; EXAMPLE:
;        CONVERT_O3PL, INMODELNAME   ='GEOS1',                $
;                      INRESOLUTION  = 4,                     $
;
;             ; Regrids P(O3) and L(O3) data from 
;             ; GEOS-1 4 x 5 grid to GISS-II-PRIME 4 x 5 grid.
;
; MODIFICATION HISTORY:
;        bmy, 16 Jul 2002: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Now read input file as big-endian
;
;-
; Copyright (C) 2002-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine convert_o3pl"
;-----------------------------------------------------------------------


pro Convert_O3PL, InModelName=InModelName, InResolution=InResolution, $
                  Year=Year,               _EXTRA=e
 
   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, Little_Endian
 
   ; Clean up stuff from common blocks
   CTM_Cleanup

   ;====================================================================
   ; Keyword settings
   ;====================================================================
   if ( N_Elements( InModelName   ) ne 1 ) then InModelName   = 'GEOS1'
   if ( N_Elements( InResolution  ) ne 1 ) then InResolution  = 4
   if ( N_Elements( Year          ) ne 1 ) then Year          = 2001
   
 
   ;====================================================================
   ; Define variables
   ;====================================================================
 
   ; Are we on a little-endian machine?
   SE = Little_Endian()

   ; MODELINFO and GRIDINFO for old grid
   InType = CTM_Type( InModelName, Resolution=InResolution )
   InGrid = CTM_Grid( InType )
    
   ;====================================================================
   ; Define variables
   ;====================================================================

   ; Randall Martin's data
   ;InTmp = '/data/ctm/GEOS_MEAN/O3_PROD_LOSS/1996-97r2x25v4.26.aer/rate.%DATE%'
   ; Output file template
   ;OutTmp = '~/S/amf_4x5_bpch/rate.%DATE%'

   ; Arlene's data
   ;InTmp = '~/S/nd20_geos4/rate.%DATE%'
   
   ; Output file template
   ;OutTmp = '/data/ctm/GEOS_MEAN/O3_PROD_LOSS/2003.v6-01-05/rate.%DATE%'

   ; Fok's data
   InTmp = '/as/home/trop/fyl/testrun/runs/run.v5-05-03.4x5.HyerCO/rate.%DATE%'

   ; Output file
   OutTmp = '~/S/for_fyl/rate.%DATE%.bpch'

   ; Julian day of Jan 1
   ;Jan1 = JulDay( 1, 1, Year )
   Jan1 = JulDay( 8, 1, Year )

   ; Loop over one year
   ;for L = 0L, 181L do begin ;365-1L do begin
   ;for L = 181L, 365L do begin ;365-1L do begin
   for L=0L, 61L do begin

      ; Cleanup every time
      ctm_cleanup

      ;=================================================================
      ; Process date & time
      ;=================================================================

      ; Today's date info
      JDToday   = Jan1 + L
      CalDat, JDToday, M, D, Y
      DateToday = Y*10000L + M*100L + D
      TauToday  = Nymd2Tau( DateToday )

      ; Tomorrow's date info
      JDTomorrow = JDToday + 1
      CalDat, JDToday, M, D, Y
      DateTomorrow = Y*10000L + M*100L + D
      TauTomorrow  = Nymd2Tau( DateTomorrow )

      ; Replace date token w/ actual date
      ThisInputFile = Replace_Token( InTmp,  '%DATE%', DateToday )

      ; ### kludge
      ;ThisInputFile = InTMp

      ;=================================================================
      ; Read data from file
      ;=================================================================
      Print, 'Processing: ', StrTrim( ThisInputFile, 2 )

      ; Define variables
      N     = 0L
      YTau0 = 0D
      YTau1 = 0D
      InPO3 = DblArr( InGrid.IMX, InGrid.JMX, InType.NTrop )
      InLO3 = DblArr( InGrid.IMX, InGrid.JMX, InType.NTrop )
 
      ; Open input file (read as big-endian)
      Open_File, ThisInputFile, Ilun, /Get_Lun, /F77, Swap_Endian=SE

      ; Read Tau values
      ReadU, Ilun, YTau0, YTau1
 
      ; Read P(O3)
      ReadU, Ilun, N
      ReadU, Ilun, InPO3

      ; Read L(O3)
      ReadU, Ilun, N
      ReadU, Ilun, InLO3
   
      ; Close file
      Close,    Ilun
      Free_LUN, Ilun
     
      ;==============================================================
      ; Strip any NaN values (bmy, 2/18/04)
      ;==============================================================

      ; Remove NaN's in INPO3
      Ind = Where( not( Float( Finite( InPO3 ) ) ) )
      if ( Ind[0] ge 0 ) then InPO3[Ind] = 0e0

      ; Remove NaN's in INPO3
      Ind = Where( not( Float( Finite( InLO3 ) ) ) )
      if ( Ind[0] ge 0 ) then InLO3[Ind] = 0e0

      ;==============================================================
      ; Make DATAINFO structure for P(O3)
      ;==============================================================
      
      ; Make the DATAINFO structure
      Success = CTM_Make_DataInfo( Float( InPO3 ),            $
                                   ThisDataInfo,              $
                                   ThisFileInfo,              $
                                   ModelInfo=InType,          $
                                   GridInfo=InGrid,           $
                                   DiagN='PORL-L=$',          $
                                   Tracer=1L,                 $
                                   Tau0=TauToday,             $
                                   Tau1=TauTomorrow,          $
                                   Unit='kg/cm3/s',           $
                                   Dim=[InGrid.IMX,           $
                                        InGrid.JMX,           $
                                        InType.NTrop, 0],     $
                                   First=[1L, 1L, 1L] )
 
      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO for PO3!'

      ; Append to an array of structures
      NewDataInfo = ThisDataInfo 

      ; Reset the first time flag
      First = 0L

      ; Undefine stuff
      UnDefine, ThisDataInfo

      ;==============================================================
      ; Make a DATAINFO structure for L(O3)
      ;==============================================================

      ; Make a DATAINFO structure
      Success = CTM_Make_DataInfo( Float( InLO3 ),            $
                                   ThisDataInfo,              $
                                   ModelInfo=InType,          $
                                   GridInfo=InGrid,           $
                                   DiagN='PORL-L=$',          $
                                   Tracer=2L,                 $
                                   Tau0=TauToday,             $
                                   Tau1=TauTomorrow,          $
                                   Unit='cm3/s',              $
                                   Dim=[InGrid.IMX,           $
                                        InGrid.JMX,           $
                                        InType.NTrop, 0],     $
                                   First=[1L, 1L, 1L] )
   
      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO for LO3!'

      ; Append to array of structures
      NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Undefine stuff
      UnDefine, ThisDataInfo

      ;==============================================================
      ; Write to output file
      ;==============================================================

      ; Output file name
      OutFileName = Replace_Token( OutTmp, '%DATE%', DateToday )

      ;### Kludge
      ;Outfilename = outtmp

      ; Write to binary punch file
      CTM_WriteBpch, NewDataInfo, FileName=OutFileName
    
      ;==============================================================
      ; Undefine stuff
      ;==============================================================
      UnDefine, ThisInputFile
      UnDefine, N
      UnDefine, YTau0
      UnDefine, YTau1
      UnDefine, InLO3
      UnDefine, InPO3
      UnDefine, OutFileName
      UnDefine, NewDataInfo
      UnDefine, NYMD
      UnDefine, Date
      UnDefine, Y
      UnDefine, M
      UnDefine, D
      UnDefine, JDToday

next:
   endfor

quit:
end
 
