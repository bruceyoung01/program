; $Id: regridvh_noy.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDVH_NOY
;
; PURPOSE:
;        Regrids zonal mean P(NOY), [NO3], [O3], [NO], and 
;        [NO2] data obtained from a 2-D stratospheric model 
;        (Hans Schneider, Dylan Jones) onto GEOS-Chem levels.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDVH_NOY [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.  
;             Default is '~bmy/archive/data/pnoy_200106/raw/PNOY.data'.
;
;        OUTFILENAME -> Name of output file containing the regridded
;             data.  Default is pnoy_nox_hno3.{MODELNAME}.{RESOLUTION}.
;             
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  Default is "GEOS3".
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        DIAGN -> Diagnostic category of data block that you want
;             to regrid.  Default is "PNOY-L=$".
;
; OUTPUTS:
;        None.
;
; SUBROUTINES:
;        Internal Subroutines:
;        ============================================================
;        RN_ERROR_CHECK    (function)   RN_PLOT_COLUMN    (function)
;
;        External Subroutines Required:
;        ============================================================
;        CTM_GRID          (function)   CTM_TYPE          (function)
;        CTM_NAMEXT        (function)   CTM_RESEXT        (function)
;        CTM_GET_DATABLOCK (function)   CTM_MAKE_DATAINFO (function)
;        ZSTAR             (function)   CTM_WRITEBPCH              
;        UNDEFINE   
;
; REQUIREMENTS:
;        References routines from both the GAMAP & TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDVH_NOY, INFILENAME='PNOY.data', $
;                      OUTMODELNAME='GEOS1',   $
;                      OUTRESOLUTION=2
;
;             ; Regrids P(NOy), HNO3, O3, NO, NO2 data from
;             ; its native grid to the 2 x 2.5 GEOS-1 grid.  
;
; MODIFICATION HISTORY:
;        bmy, 29 Jun 2000: VERSION 1.00
;        bmy, 11 Aug 2000: VERSION 1.01
;                          - added OUTDIR keyword
;                          - FILENAME is now a keyword
;        bmy, 04 Dec 2000: VERSION 1.02
;                          - bug fix: use 801 pts for GEOS-STRAT interpolation
;        bmy, 28 Mar 2001: VERSION 1.02
;                          - now use cubic spline interpolation
;                          - now use CTM_WRITEBPCH, CTM_NAMEXT, CTM_RESEXT
;                          - renamed keyword MODELNAME to OUTMODELNAME
;                          - renamed keyword RESOLUTION to OUTRESOLUTION
;                          - renamed keyword FILENAME to INFILENAME
;                          - updated comments
;        bmy, 19 Jun 2001: VERSION 1.03
;                          - bug fix: make sure output is [v/v/s] or [v/v]
;                          - now make sure concentrations aren't negative 
;                            after interpolating to CTM grid 
;        bmy, 08 Jan 2003: VERSION 1.04
;                          - renamed to "regridvh_noy.pro"
;                          - now use linear interpolation in vertical
;        bmy, 23 Dec 2003: VERSION 1.05
;                          - rewritten for GAMAP v2-01
;                          - looks for sfc pressure file in ./PSURF subdir
;                          - now supports output hybrid grid
;        bmy, 06 Aug 2004: VERSION 1.06
;                          - now calls GET_GCAP_PRESSURE to get the
;                            array of pressures (since it is a hybrid
;                            grid w/ a wacky PTOP of 150 hPa.)
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Now suppresses verbose output 
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
; or phs@io.as.harvard.edu with subject "IDL routine regridvh_noy"
;-----------------------------------------------------------------------

pro RN_ErrorCheck, Array, Name, Dim

   ;====================================================================
   ; Internal subroutine RN_ErrorCheck searches an array for
   ; negative numbers and resets them to zero, if necessary.
   ;====================================================================

   ; Output string
   S = '### Negative ' + StrTrim( Name, 2 ) + ': '

   ; Error check
   Bad = Where( Array lt 0e0, BadCt )

   if ( BadCt gt 0 ) then begin

      ; Loop over bad grid boxes
      for N = 0L, BadCt - 1L do begin

         ; Get 3-D array indices (IDL notation)
         Ind = Convert_Index( Bad[N], Dim )
         
         ; Echo grid box indices (add 1 for FORTRAN notation
         print, S, Array[ Bad[N] ], Ind+1, $
            Format='(a20,1x,e13.6,3i4,'' -- reset to zero!'')'

         ; Reset bad boxes to zero -- these are near the poles anyway 
         if ( Array[ Bad[N] ] lt 0 ) then Array[ Bad[N] ] = 0d0
      endfor
   endif

   ; Return to main program
   return
end

;-----------------------------------------------------------------------------

pro RN_PlotColumn, OldZMid, OldData, NewZMid, NewData, _EXTRA=e

   ;====================================================================
   ; Internal subroutine RN_PlotColumn plots a column 
   ; of data for debug purposes
   ;====================================================================

   ; Plot original data
   Plot, OldData, OldZMid, Color=1, yrange=[0, 66], _EXTRA=e
            
   ; Plot new data with symbols
   OPlot, NewData, NewZMid, Color=2, Psym=-sym(2), _EXTRA=e
          
   ; Legend box
   Legend, Halign=0.90, Valign=0.90, Frame=1, Line=[0, 0], $
      LColor=[1, 2], Label=['Old', 'New'], Charsize=1.0
     
   return
end

;-----------------------------------------------------------------------------

pro RegridVH_NOy, InFileName=InFileName,     OutFileName=OutFileName,     $
                  OutModelName=OutModelName, OutResolution=OutResolution, $
                  DiagN=DiagN,               _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_NamExt, CTM_ResExt, $
                    CTM_Get_DataBlock, CTM_Make_DataInfo, ZStar, $
                    Get_GCAP_Pressure

   ; Keywords
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'PNOY-L=$'
   if ( N_Elements( OutModelName  ) ne 1 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; Default INFILENAME
   if ( N_Elements( InFileName ) eq 0 ) $
      then InFileName = '~bmy/archive/data/pnoy_200106/raw/PNOY.data'

   ;====================================================================
   ; Define variables
   ;====================================================================

   ; Latitude centers on INPUT grid (36 latitudes)
   InYMid   = [ -87.50, -82.50, -77.50, -72.50, -67.50, -62.50, -57.50, $
                -52.50, -47.50, -42.50, -37.50, -32.50, -27.50, -22.50, $
                -17.50, -12.50,  -7.50,  -2.50,   2.50,   7.50,  12.50, $
                 17.50,  22.50,  27.50,  32.50,  37.50,  42.50,  47.50, $
                 52.50,  57.50,  62.50,  67.50,  72.50,  77.50,  82.50, $
                 87.50 ] 
 
   ; Number of latitudes on INPUT grid
   N_InYMid = N_Elements( InYMid )

   ; Pressure-centers on INPUT grid (41 pressure levels)
   InPMid   = [ 8.784E+02, 6.601E+02, 4.960E+02, 3.728E+02, 2.801E+02, $
                2.105E+02, 1.582E+02, 1.189E+02, 8.933E+01, 6.713E+01, $
                5.045E+01, 3.791E+01, 2.849E+01, 2.141E+01, 1.609E+01, $
                1.209E+01, 9.085E+00, 6.827E+00, 5.131E+00, 3.855E+00, $
                2.897E+00, 2.177E+00, 1.636E+00, 1.230E+00, 9.240E-01, $
                6.943E-01, 5.218E-01, 3.921E-01, 2.947E-01, 2.214E-01, $
                1.664E-01, 1.250E-01, 9.397E-02, 7.062E-02, 5.307E-02, $
                3.988E-02, 2.997E-02, 2.252E-02, 1.692E-02, 1.272E-02, $
                9.557E-03 ]
 
   ; Number of pressure centers on INPUT grid
   N_InPMid = N_Elements( InPMid )

   ; Altitudes on INPUT grid
   InZMid   = ZStar( InPmid )

   ; MODELINFO and GRIDINFO on OUTPUT grid
   OutType  = CTM_Type( OutModelName, Res=OutResolution )
   OutGrid  = CTM_Grid( OutType )
 
   ; Temporary data array
   Data     = DblArr( N_InYMid, N_InPMid )

   ; Quantities on INPUT grid
   InNOY    = DblArr( N_InYMid, N_InPMid, 12 )
   InHNO3   = DblArr( N_InYMid, N_InPMid, 12 )
   InO3     = DblArr( N_InYMid, N_InPMid, 12 )
   InNO     = DblArr( N_InYMid, N_InPMid, 12 )
   InNO2    = DblArr( N_InYMid, N_InPMid, 12 )
 
   ; Quantities with the vertical resolution of the OUTPUT grid
   ; and the horizontal resolution of the INPUT grid
   TmpNOY   = DblArr( N_InYMid, OutGrid.LMX, 12 )
   TmpHNO3  = DblArr( N_InYMid, OutGrid.LMX, 12 )
   TmpO3    = DblArr( N_InYMid, OutGrid.LMX, 12 )
   TmpNO    = DblArr( N_InYMid, OutGrid.LMX, 12 )
   TmpNO2   = DblArr( N_InYMid, OutGrid.LMX, 12 )

   ; Quantities on the OUTPUT grid
   OutNOY   = DblArr( OutGrid.JMX, OutGrid.LMX, 12 )
   OutHNO3  = DblArr( OutGrid.JMX, OutGrid.LMX, 12 )
   OutO3    = DblArr( OutGrid.JMX, OutGrid.LMX, 12 )
   OutNO    = DblArr( OutGrid.JMX, OutGrid.LMX, 12 )
   OutNO2   = DblArr( OutGrid.JMX, OutGrid.LMX, 12 )

   ; For error checking
   TmpDim = [ N_InYMid,    OutGrid.LMX, 12 ]
   OutDim = [ OutGrid.JMX, OutGrid.LMX, 12 ] 

   ; File name for surface pressure
   PSFile   = 'ps-ptop.' + CTM_NamExt( OutType ) + $
               '.'       + CTM_ResExt( OutType )

   ; Look for PSFILE in the current directory, and 
   ; failing that, in the directories specified in !PATH
   PsFile = File_Which( PsFile, /Include_Current_Dir )
   PsFile = Expand_Path( PsFile )

   ; For zonal average surface pressure
   InPAvg   = FltArr( N_InYMid    )
   OutPAvg  = FltArr( OutGrid.JMX )

   ; Values for indexing each month
   Tau0     = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]

   ; For reading the files
   NOY_Ct  = 0L
   HNO3_Ct = 0L
   O3_Ct   = 0L
   NO_Ct   = 0L
   NO2_Ct  = 0L   
 
   ; Vertical coordinate on output grid
   if ( OutType.Hybrid )               $
      then OutVertMid = OutGrid.EtaMid $
      else OutVertMid = OutGrid.SigMid

   ;====================================================================  
   ; Read all data from the input file -- ASCII format
   ;====================================================================  
   Name = ''
 
   Open_File, InFileName, Ilun_IN, /Get_Lun
 
   while( not EOF( Ilun_IN ) ) do begin
 
      ; read data from file
      ReadF, Ilun_IN, Name, Format='(a10)'
      ReadF, Ilun_IN, Data, Format='(7e11.3)'
 
      Name = StrUpCase( StrTrim( Name, 2 ) )
 
      ; Save the proper tracer and month
      case ( Name ) of
         
         'P.NOY' : begin
            InNOy[*,*,NOY_Ct]   = Data
            NOy_Ct              = NOY_Ct + 1L
         end
 
         'HNO3' : begin
            InHNO3[*,*,HNO3_Ct] = Data
            HNO3_Ct             = HNO3_Ct + 1L
         end
 
         'O3' : begin
            InO3[*,*,O3_ct]     = Data
            O3_Ct               = O3_Ct + 1L
         end
 
         'NO' : begin
            InNO[*,*,NO_Ct]     = Data
            NO_Ct               = NO_Ct + 1L
         end
 
         'NO2' : begin
            InNO2[*,*,NO2_Ct]   = Data
            NO2_Ct              = NO2_Ct + 1L
         end
      endcase
   endwhile

   ; Close file
   Close,    Ilun_IN
   Free_LUN, Ilun_IN 

   ;=====================================================================
   ; Vertically regrid data
   ;===================================================================== 
   for T = 0L, 11L do begin

      ; Read surface pressure on OUTPUT grid
      Success = CTM_Get_DataBlock( PS_PTOP, 'PS-PTOP', $
                                   File=PSFile,        $
                                   Tracer=1,           $
                                   Tau0=Tau0[T],       $
                                   /Quiet, /NoPrint )
 
      ; Error check
      if ( not Success ) then begin
         S = 'Could not find surface pressure for ' + String( Tau0 )
         Message, S
      endif

      ; Compute zonal average surface pressure for OUTPUT grid
      for J = 0, OutGrid.JMX - 1L do begin
         OutPAvg[J] = Total( PS_PTOP[*,J] ) / Float( OutGrid.IMX )
      endfor

      ; Interpolate from CTM resolution to 5 x 5 grid
      InPAvg = InterPol( OutPAvg, OutGrid.YMid, InYMid )

      ;=================================================================
      ; Regrid P(NOy)
      ;=================================================================
      for J = 0L, N_InYMid - 1L do begin
         
         ; INCOL is the column vector of NOy
         InCol   = Reform( InNOy[J,*,T] )
         
         ; Get pressure on OUTPUT grid
         if ( OutType.NAME eq 'GCAP' )                           $
            then OutPrs = Get_GCAP_Pressure( PAvg[J], /Centers ) $
            else OutPrs = ( OutVertMid * InPAvg[J] ) + OutType.PTOP 

         ; Get altitude on OUTPUT grid
         OutZMid = ZStar( OutPrs )

         ; Do linear interpolation in the vertical
         OutCol = InterPol( InCol, InZMid, OutZMid )

         ; Filter out negative numbers from the vertical regridding
         Ind = Where( OutCol lt 0.0 )
         if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

         ; Write into TMPNOY array
         TmpNOy[J,*,T] = Reform( OutCol )
      endfor

      ; Check TMPNOY for negatives
      RN_ErrorCheck, TmpNOy, 'TMPNOY', TmpDim

      ;=================================================================
      ; Regrid [HNO3]
      ;=================================================================
      for J = 0L, N_InYMid - 1L do begin
         
         ; INCOL is the column vector of HNO3
         InCol   = Reform( InHNO3[J,*,T] )
         
         ; Get pressure on OUTPUT grid
         if ( OutType.NAME eq 'GCAP' )                           $
            then OutPrs = Get_GCAP_Pressure( PAvg[J], /Centers ) $
            else OutPrs = ( OutVertMid * InPAvg[J] ) + OutType.PTOP 

         ; Get altitude on OUTPUT grid
         OutZMid = ZStar( OutPrs )

         ; Do linear interpolation in the vertical
         OutCol = InterPol( InCol, InZMid, OutZMid )

         ; Filter out negative numbers from the vertical regridding
         Ind = Where( OutCol lt 0.0 )
         if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

         ; Write into TMPHNO3 array
         TmpHNO3[J,*,T] = Reform( OutCol )
      endfor

      ; Check TMPHNO3 for negatives
      RN_ErrorCheck, TmpHNO3, 'TMPHNO3', TmpDim

      ;=================================================================
      ; Regrid [O3]
      ;=================================================================
      for J = 0L, N_InYMid - 1L do begin
         
         ; INCOL is the column vector of O3
         InCol   = Reform( InO3[J,*,T] )
         
         ; Get pressure on OUTPUT grid
         if ( OutType.NAME eq 'GCAP' )                           $
            then OutPrs = Get_GCAP_Pressure( PAvg[J], /Centers ) $
            else OutPrs = ( OutVertMid * InPAvg[J] ) + OutType.PTOP 

         ; Get altitude on OUTPUT grid
         OutZMid = ZStar( OutPrs )

         ; Do linear interpolation in the vertical
         OutCol = InterPol( InCol, InZMid, OutZMid )

         ; Filter out negative numbers from the vertical regridding
         Ind = Where( OutCol lt 0.0 )
         if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

         ; Write into TMPO3 array
         TmpO3[J,*,T] = Reform( OutCol )
      endfor

      ; Check TMPO3 for negatives
      RN_ErrorCheck, TmpO3, 'TMPO3', TmpDim

      ;=================================================================
      ; Regrid [NO]
      ;=================================================================
      for J = 0L, N_InYMid - 1L do begin
         
         ; INCOL is the column vector of NO
         InCol   = Reform( InNO[J,*,T] )
         
         ; Get pressure on OUTPUT grid
         if ( OutType.NAME eq 'GCAP' )                           $
            then OutPrs = Get_GCAP_Pressure( PAvg[J], /Centers ) $
            else OutPrs = ( OutVertMid * InPAvg[J] ) + OutType.PTOP 

         ; Get altitude on OUTPUT grid
         OutZMid = ZStar( OutPrs )

         ; Do linear interpolation in the vertical
         OutCol = InterPol( InCol, InZMid, OutZMid )

         ; Filter out negative numbers from the vertical regridding
         Ind = Where( OutCol lt 0.0 )
         if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

         ; Write into TMPNO array
         TmpNO[J,*,T] = Reform( OutCol )
      endfor

      ; Check TMPNO for negatives
      RN_ErrorCheck, TmpNO, 'TMPNO', TmpDim


      ;=================================================================
      ; Regrid [NO2]
      ;=================================================================
      for J = 0L, N_InYMid - 1L do begin
         
         ; INCOL is the column vector of NO2
         InCol   = Reform( InNO2[J,*,T] )
        
         ; Get pressure on OUTPUT grid
         if ( OutType.NAME eq 'GCAP' )                           $
            then OutPrs = Get_GCAP_Pressure( PAvg[J], /Centers ) $
            else OutPrs = ( OutVertMid * InPAvg[J] ) + OutType.PTOP 

         ; Get altitude on OUTPUT grid
         OutZMid = ZStar( OutPrs )

         ; Do linear interpolation in the vertical
         OutCol = InterPol( InCol, InZMid, OutZMid )

         ; Filter out negative numbers from the vertical regridding
         Ind = Where( OutCol lt 0.0 )
         if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

         ; Write into TMPNO2 array
         TmpNO2[J,*,T] = Reform( OutCol )
      endfor

      ; Check TMPNO2 for negatives
      RN_ErrorCheck, TmpNO2, 'TMPNO2', TmpDim

      ;=================================================================
      ; Plot vertical profiles for testing purposes
      ;=================================================================
      Debug = 0
      if ( Debug ) then begin
         multipanel, 5

         ; Loop over latitudes
         for J = 0L, N_InYMid - 1L do begin

            ; Get pressure on OUTPUT grid
            if ( OutType.NAME eq 'GCAP' )                           $
               then OutPrs = Get_GCAP_Pressure( PAvg[J], /Centers ) $
               else OutPrs = ( OutVertMid * InPAvg[J] ) + OutType.PTOP 
            
            ; Get altitude on OUTPUT grid
            OutZMid = ZStar( OutPrs )

            ; PNOy
            RN_PlotColumn, InZMid,  InNOy[J,*,T],  $
                           OutZMid, TmpNOy[J,*,T], Title='P(NOy)'

            ; HNO3
            RN_PlotColumn, InZMid,  InHNO3[J,*,T],  $
                           OutZMid, TmpHNO3[J,*,T], Title='HNO3'

            ; O3
            RN_PlotColumn, InZMid,  InO3[J,*,T],  $
                           OutZMid, TmpO3[J,*,T], Title='O3'

            ; NO
            RN_PlotColumn, InZMid,  InNO[J,*,T],  $
                           OutZMid, TmpNO[J,*,T], Title='NO'

            ; NO2
            RN_PlotColumn, InZMid,  InNO2[J,*,T],  $
                           OutZMid, TmpNO2[J,*,T], Title='NO2'

            ; Pause
            DumStr = ''
            Read, DumStr
         endfor
      endif

   endfor
 
   ;=====================================================================
   ; We also have to regrid horizontally from the 5 degree 
   ; grid to the output CTM grid -- use INTERPOL
   ;=====================================================================
   for T = 0L, 11L              do begin
   for L = 0L, OutGrid.LMX - 1L do begin 
      OutNOy [*,L,T] = InterPol( TmpNOy [*,L,T], InYMid, OutGrid.YMID )
      OutHNO3[*,L,T] = InterPol( TmpHNO3[*,L,T], InYMid, OutGrid.YMID )
      OutO3  [*,L,T] = InterPol( TmpO3  [*,L,T], InYMid, OutGrid.YMID )
      OutNO  [*,L,T] = InterPol( TmpNO  [*,L,T], InYMid, OutGrid.YMID )
      OutNO2 [*,L,T] = InterPol( TmpNO2 [*,L,T], InYMid, OutGrid.YMID )
   endfor
   endfor

   ; Check output arrays  for negatives
   RN_ErrorCheck, OutNOy,  'OUTNOY',  OutDim
   RN_ErrorCheck, OutHNO3, 'OUTHNO3', OutDim
   RN_ErrorCheck, OutO3,   'OUTO3',   OutDim
   RN_ErrorCheck, OutNO,   'OUTNO',   OutDim
   RN_ErrorCheck, OutNO2,  'OUTNO2',  OutDim

   ;=====================================================================
   ; Create array of DATAINFO structures for P(CO) and L(CO)
   ;=====================================================================
   FirstTime = 1L

   ; Loop over months
   for T = 0L, 11L do begin
      
      ;==================================================================
      ; Make individual DATAINFO structure for P(NOy)
      ;==================================================================
      Success = CTM_Make_DataInfo( Float( OutNOy[*,*,T] ),   $
                                   ThisDataInfo,             $
                                   ThisFileInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN=DiagN,              $
                                   Tracer=1L,                $
                                   TrcName='P(NOy)',         $
                                   Tau0=Tau0[T],             $
                                   Tau1=Tau0[T+1],           $
                                   Unit='v/v/s',             $
                                   Dim=[1, OutGrid.JMX,      $
                                        OutGrid.LMX, 0],     $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global)


      ; Error check
      if ( not Success ) then begin
         S = 'Could not make DATAINFO structure for P(NOy) for ' + $
            String( Tau0[T] )

         Message, S
      endif

      ; Create array of DATAINFO structures for P(NOy)
      if ( FirstTime )                                            $
         then NewDataInfo = [ ThisDataInfo ]                 $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset FirstTime
      FirstTime = 0L

      ;==================================================================
      ; Make individual DATAINFO structure for HNO3
      ;==================================================================
      Success = CTM_Make_DataInfo( Float( OutHNO3[*,*,T] ),  $
                                   ThisDataInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN=DiagN,              $
                                   Tracer=2L,                $
                                   TrcName='HNO3',           $
                                   Tau0=Tau0[T],             $
                                   Tau1=Tau0[T+1],           $
                                   Unit='v/v',               $
                                   Dim=[1, OutGrid.JMX,      $
                                        OutGrid.LMX, 0],     $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global)

      ; Error check
      if ( not Success ) then begin
         S = 'Could not make DATAINFO structure for HNO3 for ' + $
            String( Tau0[T] )

         Message, S
      endif

      ; Append into NEWDATAINFO
      NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ;==================================================================
      ; Make individual DATAINFO structure for O3
      ;==================================================================
      Success = CTM_Make_DataInfo( Float( OutO3[*,*,T] ),    $
                                   ThisDataInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN=DiagN,              $
                                   Tracer=3L,                $
                                   TrcName='O3',             $
                                   Tau0=Tau0[T],             $
                                   Tau1=Tau0[T+1],           $
                                   Unit='v/v',               $
                                   Dim=[1, OutGrid.JMX,      $
                                        OutGrid.LMX, 0],     $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global)

      ; Error check
      if ( not Success ) then begin
         S = 'Could not make DATAINFO structure for O3 for ' + $
            String( Tau0[T] )

         Message, S
      endif

      ; Append into NEWDATAINFO
      NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ;==================================================================
      ; Make individual DATAINFO structure for NO
      ;==================================================================
      Success = CTM_Make_DataInfo( Float( OutNO[*,*,T] ),    $
                                   ThisDataInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN=DiagN,              $
                                   Tracer=4L,                $
                                   TrcName='NO',             $
                                   Tau0=Tau0[T],             $
                                   Tau1=Tau0[T+1],           $
                                   Unit='v/v',               $
                                   Dim=[1, OutGrid.JMX,      $
                                        OutGrid.LMX, 0],     $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global)

      ; Error check
      if ( not Success ) then begin
         S = 'Could not make DATAINFO structure for NO for ' + $
            String( Tau0[T] )

         Message, S
      endif

      ; Append into NEWDATAINFO
      NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ;==================================================================
      ; Make individual DATAINFO structure for NO2
      ;==================================================================
      Success = CTM_Make_DataInfo( Float( OutNO2[*,*,T] ),   $
                                   ThisDataInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN=DiagN,              $
                                   Tracer=5L,                $
                                   TrcName='NO',             $
                                   Tau0=Tau0[T],             $
                                   Tau1=Tau0[T+1],           $
                                   Unit='v/v',               $
                                   Dim=[1, OutGrid.JMX,      $
                                        OutGrid.LMX, 0],     $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global)

      ; Error check
      if ( not Success ) then begin
         S = 'Could not make DATAINFO structure for NO2 for ' + $
            String( Tau0[T] )

         Message, S
      endif

      ; Append into NEWDATAINFO
      NewDataInfo = [ NewDataInfo, ThisDataInfo ]
   endfor

   ;=====================================================================
   ; Write data to disk
   ;=====================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'pnoy_nox_hno3.' + CTM_NamExt( OutType ) + $
                    '.'              + CTM_ResExt( OutType )
   endif

   ; Write to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                               
 
    
 
