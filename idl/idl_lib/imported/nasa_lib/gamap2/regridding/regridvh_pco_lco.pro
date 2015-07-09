; $Id: regridvh_pco_lco.pro,v 1.2 2008/02/12 21:59:25 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDVH_PCO_LCO
;
; PURPOSE:
;        Vertically and horizontally regrids zonal mean P(CO) and
;        L(CO) data obtained from a 2-D stratospheric model (Hans 
;        Schneider, Dylan Jones) onto CTM sigma levels
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDVH_PCO_LCO [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing input 
;             data to be regridded to the output grid specified 
;             by MODELNAME and RESOLUTION.  Default is "CO.P_L.data".
;
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.  
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =====================================================
;        CTM_TYPE   (function)   CTM_GRID          (function) 
;        ZSTAR      (function)   CTM_GET_DATABLOCK (function)
;        CTM_NAMEXT (function)   CTM_RESEXT        (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Requires a file containing surface pressures on the 
;            output CTM grid -- see /users/ctm/bmy/sup/data/regrid 
;            directory for examples.
;
; EXAMPLE:
;        REGRID_PCO_LCO, INFILENAME='CO.P_L.data', $
;                        OUTMODELNAME='GEOS1',     $
;                        OUTRESOLUTION=2
;
;             ; Regrids P(CO) and L(CO) data from its native grid
;             ; to the 2 x 2.5 GEOS-1 grid.  
;
; MODIFICATION HISTORY:
;        bmy, 29 Jun 2000: VERSION 1.00
;        bmy, 11 Aug 2000: VERSION 1.01
;                          - added OUTDIR keyword
;                          - FILENAME is now a keyword
;        bmy, 28 Mar 2001: VERSION 1.02
;                          - now use cubic spline interpolation
;                          - now use CTM_WRITEBPCH, CTM_NAMEXT, CTM_RESEXT
;                          - renamed keyword MODELNAME to OUTMODELNAME
;                          - renamed keyword RESOLUTION to OUTRESOLUTION
;                          - renamed keyword FILENAME to INFILENAME
;        bmy, 08 Jan 2003: VERSION 1.03
;                          - renamed to "regridvh_pco_lco.pro"l
;                          - now do linear interpolation in the vertical
;        bmy, 18 Dec 2003: VERSION 1.04
;                          - rewritten for GAMAP v2-01
;                          - Now looks for 
;                          - Now supports hybrid output grid
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
;        bmy, 28 Jan 2008: GAMAP VERSION 2.12
;                          - Bug fix: PSFILE instead of PSFILENAME
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
; or phs@io.as.harvard.edu with subject "IDL routine regridvh_pco_lco"
;-----------------------------------------------------------------------

; Plots a column for debug output 
pro RPL_PlotColumn, OldZMid, OldData, NewZMid, NewData, _EXTRA=e

   ; Plot original data
   plot, OldData, OldZMid, Color=1, _EXTRA=e
            
   ; Plot new data with symbols
   oplot, NewData, NewZMid, Color=2, Psym=-sym(2), _EXTRA=e
          
   ; Legend box
   Legend, Halign=0.90, Valign=0.90, Frame=1, Line=[0, 0], $
      LColor=[1, 2], Label=['Old', 'New'], Charsize=1.0
     
   return
end

;-----------------------------------------------------------------------------

pro RegridVH_PCO_LCO, InFileName=InFileName,       $
                      OutModelName=OutModelName,   $
                      OutResolution=OutResolution, $
                     _EXTRA=e
                                
   ; External functions
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,   ZStar,              $
                    CTM_NamExt, CTM_ResExt, CTM_Get_DataBlock,  $
                    Add_Separator
 
   ;====================================================================
   ; Keyword settings
   ;====================================================================
   if ( N_Elements( OutModelName  ) eq 0 ) then MModelName  = 'GEOS1'
   if ( N_Elements( OutResolution ) eq 0 ) then RResolution = 4
   if ( N_Elements( OutDir        ) eq 0 ) then OutDir      = './'

   ; Default INFILENAME
   if ( N_Elements( InFileName ) eq 0 ) then begin
      InFileName = '~bmy/archive/data/pco_lco_200203/raw/CO.P_L.data'
   endif
   
   ;====================================================================
   ; Define variables
   ;====================================================================

   ; Latitudes of INPUT DATA (36 latitudes)
   InYMid   = [ -87.50, -82.50, -77.50, -72.50, -67.50, -62.50, $
                -57.50, -52.50, -47.50, -42.50, -37.50, -32.50, $
                -27.50, -22.50, -17.50, -12.50,  -7.50,  -2.50, $
                  2.50,   7.50,  12.50,  17.50,  22.50,  27.50, $
                 32.50,  37.50,  42.50,  47.50,  52.50,  57.50, $
                 62.50,  67.50,  72.50,  77.50,  82.50,  87.50 ]
 
   ; Number of latitudes
   N_InYMid = N_Elements( InYMid )
 
   ; Pressure-centers of INPUT DATA (41 pressure centers)
   InPmid   = [ 878.400, 660.100, 496.000, 372.800,  280.100, $   
                 210.500, 158.200, 118.900,  89.330,   67.130, $  
                  50.450,  37.910,  28.490,  21.410,   16.090, $
                  12.090,   9.085,   6.827,   5.131,    3.855, $
                   2.897,   2.177,   1.636,   1.230,    0.924, $
                   0.694,   0.522,   0.392,   0.295,    0.221, $
                   0.166,   0.125,   0.094,   0.071,    0.053, $
                   0.040,   0.030,   0.023,   0.017,    0.013, $
                   0.010 ]
 
   ; Number of pressures
   N_InPMid = N_Elements( InPMid )

   ; Altitudes on input pressure grid
   InZmid   = ZStar( InPMid )
 
   ; MODELINFO and GRIDINFO on output CTM grid
   OutType  = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid  = CTM_Grid( OutType )

   ; Altitudes on output CTM grid
   ;OutZMid  = ZMid( ZEdge_Output )
   OutZMid  = OutGrid.ZMid

   ; Values for indexing each month
   Tau0     = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]

   ; Temporary data array
   Data     = DblArr( N_InYMid, N_InPMid )

   ; L(CO) and P(CO) on input grid
   InLCO    = DblArr( 12, N_InYMid, N_InPMid )
   InPCO    = DblArr( 12, N_InYMid, N_InPMid )

   ; L(CO) and P(CO) w/ vertical resolution of OUTPUT grid
   ; and horizontal resolution of INPUT grid
   TmpLCO   = DblArr( 12, N_InYMid, OutGrid.LMX ) 
   TmpPCO   = DblArr( 12, N_InYMid, OutGrid.LMX )
 
   ; L(CO) and P(CO) on OUTPUT grid
   OutPCO   = DblArr( 12, OutGrid.JMX, OutGrid.LMX )
   OutLCO   = DblArr( 12, OutGrid.JMX, OutGrid.LMX )

   ; File name for surface pressure
   PSFile   = 'ps-ptop.' + CTM_NamExt( OutType ) + $
              '.'        + CTM_ResExt( OutType )

   ; Look for PSFILENAME in the current directory, and 
   ; failing that, in the directories specified in !PATH
   PsFile   = File_Which( PsFile, /Include_Current_Dir )
   PsFile   = Expand_Path( PsFile )

   ; For zonal average surface pressure
   InPAvg   = FltArr( N_InYMid    )
   OutPAvg  = FltArr( OutGrid.JMX )

   ; For reading input data
   Name     = ''
   Line     = ''
   Time     = 0.0
   Loss_Ct  = 0L
   Prod_Ct  = 0L

   ; Vertical coordinates on output grid
   if ( OutType.Hybrid )               $
      then OutVertMid = OutGrid.EtaMid $
      else OutVertMid = OutGrid.SigMid  

   ;====================================================================  
   ; Read all data from the input file -- ASCII format
   ;====================================================================  
   print, 'Reading in data from ', StrTrim( InFileName )
 
   Open_File, InFileName, Ilun_IN, /Get_Lun
 
   while( not EOF( Ilun_IN ) ) do begin
 
      ; read data from file
      ReadF, Ilun_IN, Time
      ReadF, Ilun_IN, Name
      ReadF, Ilun_IN, Data, Format='(7e11.3)'
      ReadF, Ilun_IN, Line
 
      ; Convert NAME to uppercase
      Name = StrUpCase( StrTrim( Name, 2 ) )
 
      ; Print info to screen
      print, Name, Time
 
      ; Save the proper tracer and month
      case ( Name ) of
         
         ; CO Loss
         'L.CO' : begin
            InLCO[ Loss_Ct, *, * ] = Data
            Loss_Ct                = Loss_Ct + 1L
         end
 
         ; CO Prod
         'P.CO' : begin
            InPCO[ Prod_Ct, *, * ] = Data
            Prod_Ct                = Prod_Ct + 1L
         end
         
      endcase
 
   endwhile
 
   ; Close the input file
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
      ; Regrid P(CO)
      ;=================================================================

      ; echo some information out to the screen
      Print, 'P(CO): Processing Month ', T+1

      ; Loop over each latitude 
      for J = 0L, N_InYMid - 1L do begin
         
         ; INCOL is the column vector of PCO
         InCol   = Reform( InPCO[T,J,*] )
         
         ; Pressures and altitudes of each level on OUTPUT grid
         OutPrs  = ( OutVertMid * InPAvg[J] ) + OutType.PTOP
         OutZMid = ZStar( OutPrs )

         ; Do linear interpolation in the vertical
         OutCol  = InterPol( InCol, InZMid, OutZMid )

         ; Filter out negative numbers from the vertical regridding
         Ind = Where( OutCol lt 0.0 )
         if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

         ; Write into TMPPCO array
         TmpPCO[T,J,*] = Reform( OutCol )
      endfor
 

      ;=================================================================
      ; Regrid L(CO)
      ;=================================================================     
      Print, 'L(CO): Processing Month ', T+1
 
      ; Loop over each latitude 
      for J = 0L, N_InYMid - 1L do begin
 
         ; INCOL is the column vector of L(CO)
         InCol   = Reform( InLCO[T,J,*] )
         
         ; Pressures and altitudes of each level on OUTPUT grid
         OutPrs  = ( OutVertMid * InPAvg[J] ) + OutType.PTOP
         OutZMid = ZStar( OutPrs )

         ; Do linear interpolation in the vertical
         OutCol  = InterPol( InCol, InZMid, OutZMid )

         ; Filter out negative numbers from the vertical regridding
         Ind = Where( OutCol lt 0.0 )
         if ( Ind[0] ge 0 ) then OutCol[Ind] = 0D

         ; Write into OUTPCO array
         TmpLCO[T,J,*] = Reform( OutCol )

      endfor

      ;=================================================================
      ; Plot vertical profiles for testing purposes
      ;=================================================================
      Debug = 0
      if ( Debug ) then begin

         ; Loop over latitudes
         ;for J = 0L, N_InYMid - 1L do begin
         for J = 13L, 13L do begin

            ; P(CO)
            RPL_PlotColumn, InZMid,  InPCO[T,J,*],  $
                            OutZMid, TmpPCO[T,J,*], $
                            Title='P(CO)', XRange=[1e-17, 1e-14], /XStyle

            ; L(CO)
            RPL_PlotColumn, InZMid,  InLCO[T,J,*],  $
                            OutZMid, TmpLCO[T,J,*], $
                            Title='L(CO)', XRange=[1e-9, 1e-6], /XStyle

            ; Pause
            DumStr = ''
            Read, DumStr
         endfor
      endif

   endfor
    
   ;=====================================================================
   ; We also have to regrid horizontally from the 5 degree grid to
   ; the output CTM grid
   ;
   ; Do the cheap way -- use INTERPOL
   ;=====================================================================
   print

   for T = 0L, 11L do begin
      print, 'Horizontally regridding P(CO), L(CO), Month = ', T+1
 
      for L = 0L, OutGrid.LMX - 1L do begin 
         OutPCO[T,*,L] =  InterPol( TmpPCO[T,*,L], InYMid, OutGrid.YMID )
         OutLCO[T,*,L] =  InterPol( TmpLCO[T,*,L], InYMid, OutGrid.YMID )
      endfor
   endfor
         
   ;=====================================================================
   ; Create array of DATAINFO structures for P(CO) and L(CO)
   ;=====================================================================
   Flag = 1L

   ; Loop over months
   for T = 0L, 11L do begin
      
      ; Make individual DATAINFO structure for P(CO)
      Success = CTM_Make_DataInfo( Float( OutPCO[T,*,*] ),   $
                                   ThisPCODataInfo,          $
                                   PCOFileInfo,              $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN='PORL-L=$',         $
                                   Tracer=9,                 $
                                   TrcName='P(CO)',          $
                                   Tau0=Tau0[T],             $
                                   Tau1=Tau0[T+1],           $
                                   Unit='v/v/s',             $
                                   Dim=[1, OutGrid.JMX,      $
                                        OutGrid.LMX, 0],     $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global)


      ; Error check
      if ( not Success ) then begin
         S = 'Could not make DATAINFO structure for P(CO) for ' + $
            String( Tau0[T] )

         Message, S
      endif


      ; Make individual DATAINFO structure for L(CO)
      Success = CTM_Make_DataInfo( Float( OutLCO[T,*,*] ),   $
                                   ThisLCODataInfo,          $
                                   LCOFileInfo,              $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN='PORL-L=$',         $
                                   Tracer=10,                $
                                   TrcName='L(CO)',          $
                                   Tau0=Tau0[T],             $
                                   Tau1=Tau0[T+1],           $
                                   Unit='s-1',               $
                                   Dim=[1, OutGrid.JMX,      $
                                        OutGrid.LMX, 0],     $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global)

      ; Error check
      if ( not Success ) then begin
         S = 'Could not make DATAINFO structure for L(CO) for ' + $
            String( Tau0[T] )

         Message, S
      endif

      ; Create array of DATAINFO structures for P(CO)
      if ( Flag )                                            $
         then PCODataInfo = [ ThisPCODataInfo ]              $
         else PCODataInfo = [ PCODataInfo, ThisPCODataInfo ]

      ; Create array of DATAINFO structures for L(CO)
      if ( Flag )                                            $
         then LCODataInfo = [ ThisLCODataInfo ]              $
         else LCODataInfo = [ LCODataInfo, ThisLCODataInfo ]

      ; Reset flag
      Flag = 0L
   endfor

   ;=====================================================================
   ; Write P(CO) and L(CO) data to separate binary punch files 
   ;=====================================================================
   OutFileName1 = 'COprod.' + CTM_NamExt( OutType ) + $
                  '.'       + CTM_ResExt( OutType ) 

   OutFileName2 = 'COloss.' + CTM_NamExt( OutType ) + $
                  '.'       + CTM_ResExt( OutType )

   CTM_WriteBpch, PCODataInfo, PCOFileInfo, FileName=OutFileName1
   CTM_WriteBpch, LCODataInfo, LCOFileInfo, FileName=OutFileName2

   ; Quit
   return
                     
end                                   
 
