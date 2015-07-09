; $Id: regridvh_stratoh.pro,v 1.2 2008/02/12 21:59:25 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDVH_STRATOH
;
; PURPOSE:
;        Vertically and horizontally regrids 2-D stratospheric OH
;        fields (for the simplified stratospheric chemistry loss) 
;        from native resolution onto a CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDV_STRATOH [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing input data to be
;             regridded.  Default is 
;             '~bmy/archive/data/stratOH_200203/raw/OH.2d.model.data'
;
;        OUTFILENAME -> Name of file containing regridded output
;             data.  Default is "stratoh.{MODELNAME}.{RESOLUTION}"
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
;        ================================================
;        CTM_TYPE   (function)  CTM_GRID      (function)
;        CTM_NAMEXT (function)  CTM_RESEXT    (function)
;        ZSTAR      (function)  ZMID          (function)
;        ZEDGE      (function)  ADD_SEPARATOR (function)
;
; 
; REQUIREMENTS:
;        None
;
; NOTES:
;        Stratospheric OH data was obtained from Hans Schneider 
;        and Dylan Jones.
;
; EXAMPLE:
;        REGRIDVH_STRATOH, INFILENAME='OH.2d.model.data', $
;                          OUTMODELNAME='GEOS4',          $
;                          OUTRESOLUTION=2
;
;             ; Regrids original stratospheric OH data to the 
;             ; 2 x 2.5 GEOS-4 grid (with 55 layers)
;              
; MODIFICATION HISTORY:
;        bmy, 30 Jun 2000: VERSION 1.00
;        bmy, 02 Aug 2000: VERSION 1.01
;                          - FILENAME is now a keyword
;        bmy, 18 Dec 2003: VERSION 1.02
;                          - renamed to REGRIDVH_STRATOH
;                          - rewritten for GAMAP v2-01
;                          - Now supports hybrid output grids
;        bmy, 15 Feb 2007: VERSION 1.03
;                          - Bug fix for PS file name
;                          - Suppress verbose printing
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
;        bmy, 28 Jan 2008: GAMAP VERSION 2.12
;                          - Bug fix: don't hardwire path for PS file
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
; or phs@io.as.harvard.edu with subject "IDL routine regridv_stratoh"
;-----------------------------------------------------------------------


pro RegridVH_StratOH, InFileName=InFileName,     OutFileName=OutFileName,     $
                      OutModelName=OutModelName, OutResolution=OutResolution, $
                      _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_NamExt, CTM_ResExt, $
                    ZStar,    ZMid,     ZEdge
    
   ; Keywords
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
   if ( N_Elements( OutDir        ) eq 0 ) then OutDir      = './'
     
   ; Make sure that OUTDIR ends with a slash
   OutDir = Add_Separator( OutDir )

   ; Default INFILENAME
   if ( N_Elements( InFileName ) ne 1 ) then begin
      InFileName = '~bmy/archive/data/stratOH_200203/raw/OH.2d.model.data'
   endif

   ;====================================================================
   ; Input grid information
   ;====================================================================

   ; Input data has 36 latitudes (cf Hans Schneider)
   InYMid = [ -87.50, -82.50, -77.50, -72.50, -67.50, -62.50, -57.50, $
              -52.50, -47.50, -42.50, -37.50, -32.50, -27.50, -22.50, $
              -17.50, -12.50,  -7.50,  -2.50,   2.50,   7.50,  12.50, $
               17.50,  22.50,  27.50,  32.50,  37.50,  42.50,  47.50, $
               52.50,  57.50,  62.50,  67.50,  72.50,  77.50,  82.50, $
               87.50 ]
 
   ; Input data has 22 pressure-altitude levels.
   ; Each level is 2-km high. (cf Hans Schneider)
   InZMid  = FIndGen( 22 ) * 2.0 + 1
   InZEdge = FIndGen( 23 ) * 2.0 
   
   ; Altitude at top of data level [km]
   InZTop  = InZEdge[22]

   ;====================================================================  
   ; Output grid information
   ;====================================================================  

   ; Model and grid structures
   OutType = CTM_Type( OutModelName, Res=OutResolution )
   OutGrid = CTM_Grid( OutType )

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'stratOH.' + CTM_NamExt( OutType ) + $
                    '.'        + CTM_ResExt( OutType )
   endif

   ; File w/ met field pressures on output grid
   PSFile = 'ps-ptop.' + CTM_NamExt( OutType ) + $
            '.'        + CTM_ResExt( OutType )

   ; Look for PSFILENAME in the current directory, and 
   ; failing that, in the directories specified in !PATH
   PsFile = File_Which( PsFile, /Include_Current_Dir )
   PsFile = Expand_Path( PsFile )

   ; Values for indexing each month
   Tau0     = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]

   ;===================================================================  
   ; Read monthly mean OH data [molec/cm3] from the input file
   ;===================================================================  

   ; Define variables
   Data = FltArr( 36, 22     )
   InOH = FltArr( 36, 22, 12 )
   Ct   = 0L
   Line = ''

   ; Open file
   Open_File, InFileName, Ilun_IN, /Get_Lun
   
   ; Read data
   while( not EOF( Ilun_IN ) ) do begin
      ReadF, Ilun_IN, Line
      ReadF, Ilun_IN, Data, Format='(5e14.4)'
 
      InOH[*,*,Ct] = Data
      Ct           = Ct + 1L
   endwhile

   ; Close file
   Close,    Ilun_IN
   Free_LUN, Ilun_IN
 
   ;===================================================================
   ; Regrid OH
   ;===================================================================
   S     = Size( InOH, /Dim )
   TmpOH = DblArr( S[0], OutGrid.LMX, S[2] )

   ; Loop over months
   for T = 0, 11 do begin
      print, 'OH: Vertically Regridding Month: ', T+1

      ;=================================================================
      ; Get surface pressure on output grid
      ;=================================================================
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
      TempPAvg = FltArr( OutGrid.JMX )
      for J = 0, OutGrid.JMX - 1L do begin
         TempPAvg[J] = Total( PS_PTOP[*,J] ) / Float( OutGrid.IMX )
      endfor

      ; Interpolate from CTM resolution to 5 x 5 grid
      InPAvg = InterPol( TempPAvg, OutGrid.YMid, InYMid )

      ;=================================================================
      ; Regrid data
      ;=================================================================

      ; Get SIGMID or ETAMID depending on if it's a hybrid grid
      if ( OutType.Hybrid )               $
         then OutVertMid = OutGrid.EtaMid $
         else OutVertMid = OutGrid.SigMid
      
      ; Loop over latitudes 
      for J = 0L, 35L do begin

         ; Pressures and altitudes of each level on OUTPUT grid
         OutPrs       = ( OutVertMid * InPAvg[J] ) + OutType.PTOP
         OutZMid      = ZStar( OutPrs )
 
         ; Linearly interpolate to output grid in vertical
         InCol        = Reform( InOH[J,*,T] )
         OutCol       = InterPol( InCol, InZMid, OutZMid )
        
         ; For grids like GEOS-3 that go up to 80 km, copy the
         ; highest data level to all other levels above INZTOP
         Ind          = Where( OutZMid gt InZTop )
         if ( Ind[0] ge 0 ) then OutCol[Ind] = InCol[21]

	 ; Copy the regridded data back into the TMPOH array
         TmpOH[J,*,T] = OutCol
 
         ;--------------------------------------------------------------
         ;### Debug output...uncomment if necessary
         ;if ( T eq 0 ) then begin
         ;   plot,  TmpOH[J,*,T], OutZMid, Color=1, Psym=-Sym(3)
         ;   Oplot, InOH[J,*,T],  InZMid,  Color=2, Psym=-Sym(2)
         ;
         ;   Legend, Halign=0.90, Valign=0.90, Frame=1, Line=[0, 0], $
         ;      LColor=[2, 1], Label=['Old', 'New'], Charsize=1.0
         ;
         ;   pause
         ;endif
         ;---------------------------------------------------------------
      endfor
   endfor
 
   ; filter out negative numbers
   TmpOH = TmpOH > 0.0
 
   ;====================================================================
   ; We also have to regrid horizontally from the 5 degree grid to
   ; the CTM output grid.   Do it the cheap way -- use interpol
   ;====================================================================
   OutOH = FltArr( OutGrid.JMX, OutGrid.LMX )

   print
   
   ; First time flag
   FirstTime = 1L

   ; Loop over months
   for T = 0, 11 do begin
      print, 'OH: Horizontally regridding Month = ', T+1
 
      for L = 0L, OutGrid.LMX-1 do begin
         OutOH[*,L] = InterPol( TmpOH[*,L,T], InYMid, OutGrid.YMid )
      endfor
 
      ; filter out negative numbers
      OutOH = OutOH > 0.0
 
      ; Make a DATAINFO structure for this month of OH data
      Success = CTM_Make_DataInfo( Float( OutOH[*,*] ),      $
                                   ThisDataInfo,             $
                                   ThisFileInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN='CHEM-L=$',         $
                                   Tracer=1L,                $
                                   Tau0=Tau0[T],             $
                                   Tau1=Tau0[T+1],           $
                                   Unit='molec/cm3',         $
                                   Dim=[1, OutGrid.JMX,      $
                                           OutGrid.LMX, 0],  $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global )

      ; Error check
      if ( not Success ) then begin
         S = 'Could not make DATAINFO structure for OH for ' + $
            String( Tau0[T] )
         Message, S
      endif

      ; Append into NEWDATAINFO
      if ( FirstTime ) $
         then NewDataInfo = [ ThisDataInfo ] $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset first-time flag
      FirstTime = 0L

   endfor

   ;=====================================================================
   ; Write output to a binary punch file and quit
   ;=====================================================================
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                               
 
    
 
