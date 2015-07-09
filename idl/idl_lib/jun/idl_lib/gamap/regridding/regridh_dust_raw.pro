; $Id: regridh_dust_raw.pro,v 1.2 2008/04/02 15:19:04 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRID_DUST
;
; PURPOSE:
;        Regrids 2.5 x 2.5 mineral dust concentrations 
;        onto a CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRID_DUST [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        MONTH -> Month of year for which to process data.
;             Default is 1 (January).
;
;        MODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        RESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTDIR -> Name of the directory where the output file will
;             be written.  Default is './'.  
;
; OUTPUTS:
;        Writes binary punch file:
;             dust.{MODELNAME}.{RESOLUTION}
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================================
;        CTM_GRID      (function)   CTM_TYPE   (function)
;        CTM_BOXSIZE   (function)   CTM_REGRID (function)
;        CTM_NAMEXT    (function)   CTM_RESEXT (function)
;        CTM_WRITEBPCH  
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) The path names for the files containing dust data are
;            hardwired -- change as necessary!
;
;        (2) Even though photolysis rates are only needed in the 
;            troposphere, we need to save the mineral dust for all
;            levels of the model.  Scattering by mineral dust is
;            used to compute the actinic flux, and therefore we need
;            to account for this all the way to the atmosphere top.
;
;        (3) The regridding process can take a very long time to
;            complete.  If you are regridding, it is recommended to
;            process one month at a time, and then to concatenate
;            the binary punch files using GAMAP.
;
; EXAMPLE:
;        REGRID_DUST, MODELNAME='GEOS_STRAT', RESOLUTION=4
;           
;             ; Regrids dust data from 2 x 2.5 native resolution
;             ; to 4 x 5 resolution for the GEOS-STRAT grid
;
; MODIFICATION HISTORY:
;        bmy, 09 Jun 2000: VERSION 1.00
;        rvm, 18 Jun 2000: VERSION 1.01
;        bmy, 07 Jul 2000: VERSION 1.10
;                          - added OUTDIR keyword
;                          - save regridded data one month at a time
;                            since regridding takes so long 
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Now read input files as big-endian
;                
;-
; Copyright (C) 2000-2008, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regrid_dust"
;-----------------------------------------------------------------------

pro Regrid_Dust, Month=Month,   ModelName=ModelName, $
                 OutDir=OutDir, Resolution=Resolution 
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,   CTM_BoxSize, $
                    CTM_Regrid, CTM_NamExt, CTM_ResExt

   if ( N_Elements( Month      ) ne 1 ) then Month      = 1
   if ( N_Elements( ModelName  ) ne 1 ) then ModelName  = 'GEOS1'
   if ( N_Elements( OutDir     ) ne 1 ) then OutDir     = './'
   if ( N_Elements( Resolution ) eq 0 ) then Resolution = 2

   ; Make sure the last character of OUTDIR is a slash
   if ( StrMid( OutDir, StrLen( OutDir ) - 1, 1 ) ne '/' ) $
      then OutDir = OutDir + '/'

   ;====================================================================
   ; Define MODELINFO and GRIDINFO structures for the dust grid
   ; Define MODELINFO and GRIDINFO structures for the CTM grid
   ; Compute grid box surface areas for old & new grids
   ;====================================================================
   OldType = CTM_Type( ModelName, Resolution=[2.5, 2.0] )
   OldGrid = CTM_Grid( OldType )
   OldVol  = CTM_BoxSize( OldGrid, /GEOS_Radius, /Volume, /m3 )
   
   NewType = CTM_Type( ModelName, Resolution=Resolution )
   NewGrid = CTM_Grid( NewType )
   NewVol  = CTM_BoxSize( NewGrid, /GEOS_Radius, /Volume, /m3 )

   ; Set a logical flag if we are regridding
   Regrid = ( NewType.Resolution[1] gt OldType.Resolution[1] )

   ;====================================================================
   ; Define the path name for each of the REAL*4 files that 
   ; contain dust data -- change if necessary!
   ;====================================================================
   case ( NewType.Name ) of
      'GEOS1' : begin
         FilePath = '~rvm/sup/northern_africa/from_Ginoux/dust.conc.v2p.mth.90'
      end

      'GEOS_STRAT' : begin
         FilePath = '~rvm/sup/northern_africa/from_Ginoux/dust.conc.v2p.mth.96'
      end
         
      'GEOS2' : begin
         FilePath = '~rvm/sup/northern_africa/from_Ginoux/dust.conc.v2p.mth.96'
      end

      'GEOS3' : begin
         FilePath = '~rvm/sup/northern_africa/from_Ginoux/dust.conc.v2p.mth.96'
      end
   endcase
      
   ; Append the month number to the file name
   MonthStr = [ '01', '02', '03', '04', '05', '06', $
                '07', '08', '09', '10', '11', '12' ]

   FileList = FilePath + MonthStr
   
   ;====================================================================
   ; Declare some variables & arrays
   ;====================================================================

   ; There are 7 optical dust tracers
   NameList   = 'Mineral Dust Opt Depth (' + $
                ['.009um', '.081um', '.23um', $
                 '.67um', '1.5um',  '2.5um', '4.0um' ] + ')'

   ; N_DUST = number of dust types
   N_Dust     = N_Elements( NameList )
   TracerList = LIndGen( N_Dust ) + 1L
   
   ; OLDDATA, NEWDATA = arrays to hold old & new dust data
   ; NOTE: NEWDATA only is defined in the troposphere 
   OldData = FltArr( OldGrid.IMX, OldGrid.JMX, OldGrid.LMX, N_Dust )
   NewData = FltArr( NewGrid.IMX, NewGrid.JMX, NewGrid.LMX, N_Dust )
 
   ; TAU = time values (hours) for indexing each month
   Tau = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
           4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
 
   ; Summing variables
   Sum_Old     = 0D
   Sum_New     = 0D
   Sum_Old_Cum = 0D
   Sum_New_Cum = 0D
 
   ;====================================================================
   ; If we are reading a 2 x 2.5 file, we don't have to regrid, so save
   ; output to a single binary punch file containing all 12 months.
   ;
   ; If we are regridding to 4 x 5, then this will take a long time,
   ; so just process one month at a time and then concatenate the
   ; files later on.
   ;====================================================================
   F1 = '(''Month: '', i2, ''  Tracer: '', i2, ''  Level: '', i2, ''  Sum Old Grid [kg] '', e13.6)'
   F2 = '(''Month: '', i2, ''  Tracer: '', i2, ''  Level: '', i2, ''  Sum New Grid [kg] '', e13.6)'

   ; MONTH0, MONTH1 are the beginning & ending month indices
   if ( Regrid ) then begin
      Month0 = Month - 1L
      Month1 = Month - 1L
   endif else begin
      Month0 = 0L
      Month1 = 11L
   endelse

   ; First time flag
   Flag = 0L

   ; Loop over months
   for T = Month0, Month1 do begin
      
      ; Open REAL*4 file containing dust data 
      Open_File, FileList[T], Ilun_IN, $
                 /Get_LUN, /F77_Unformatted, Swap_Endian=Little_Endian()
 
      ; Read data from each monthly file
      ; Data has units of [kg/m3]
      ReadU, Ilun_IN, OldData 
 
      ; Close dust file
      Close,    Ilun_IN
      Free_LUN, Ilun_IN

      ;=================================================================
      ; For 4 x 5 grids, we need to regrid the original 2 x 2.5 data
      ; Units are kg/m3
      ;=================================================================
      if ( Regrid ) then begin

         ; Loop over tracers (N) and levels (L)
         for N = 0L, N_Dust      - 1L do begin
         for L = 0L, NewGrid.LMX - 1L do begin

            ; Regrid only if conc > 0
            Temp = Total( OldData(*,*,L,N) )  

            if ( Temp eq 0 ) then begin
               NewData[*,*,L,N] = 0.0

            endif else begin

               ; Convert OldData from kg/m3 -> kg
               OldData[*,*,L,N] = OldData[*,*,L,N] * OldVol[*,*,L]

               ; Regrid from 2 x 2.5 to 4 x 5, for 20 levels
               ; TMPDATA will have REAL*8 precision
               TmpData = CTM_Regrid( OldData[*,*,L,N], $
                                     OldGrid,          $
                                     NewGrid,          $
                                     /No_Normalize,    $
                                     /Double,          $
                                     /Quiet )

               ; Compute sums of data for both old & new grids in kg
               Sum_Old = Total( OldData[*,*,L,N] )  
               Sum_New = Total( TmpData )
 
               ; Print old & new sums in kg
               print, T+1, TracerList[N], L+1, Sum_Old, Format=F1
               print, T+1, TracerList[N], L+1, Sum_New, Format=F2
               print
   
               ; Compute cumulative sums for both old & new grids in kg/m
               Sum_Old_Cum = Sum_Old_Cum + Sum_Old
               Sum_New_Cum = Sum_New_Cum + Sum_New

               ; Convert NewArea from kg -> kg/m3
               ; Also make sure NEWDATA is a float array
               NewData[*,*,L,N] = Float( TmpData / NewVol[*,*,L] )
            endelse
         endfor
         endfor

      endif $

      ;=================================================================
      ; For 2 x 2.5 grids, just copy the OLDDATA into NEWDATA 
      ; so that we can translate it into binary punch file format
      ;=================================================================
      else begin
         NewData = OldData

      endelse
 
      ;=================================================================
      ; Make a DATAINFO structure for each data block and 
      ;=================================================================
      for N = 0L, N_Dust - 1L do begin

         Success = CTM_Make_DataInfo( NewData[*,*,*,N],              $
                                      ThisDataInfo,                  $
                                      ThisFileInfo,                  $
                                      ModelInfo=NewType,             $
                                      GridInfo=NewGrid,              $
                                      DiagN='MDUST-$',               $
                                      Tracer=TracerList[N],          $
                                      TrcName=NameList[N],           $
                                      Tau0=Tau[T],                   $
                                      Tau1=Tau[T+1],                 $
                                      Unit='kg/m3',                  $
                                      Dim=[NewGrid.IMX, NewGrid.JMX, $
                                           NewGrid.LMX, 0],          $
                                      First=[1L, 1L, 1L] )
 

         ; NEWDATAINFO is an array of DATAINFO Structures
         ; Append THISDATAINFO onto the NEWDATAINFO array
         if ( Flag eq 0L )                                   $                
            then NewDataInfo = [ ThisDataInfo ]              $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

         ; Reset FLAG to a nonzero value 
         Flag = 1L
      endfor
   endfor
 
   ;====================================================================
   ; Write all data blocks to a binary punch file
   ;====================================================================
   OutFileName = OutDir + 'dust.' + CTM_NamExt( NewType ) + $
                          '.'     + CTM_ResExt( NewType )

   ; Append the month string to the filename if we are just doing
   ; one month at a time -- regridding to 4 x 5
   if ( Regrid ) $
      then OutFileName = OutFileName + '.' + MonthStr[Month0]

   ; Write to binary punch file
   CTM_WriteBpch, NewDataInfo, FileName=OutFileName
   
   ;====================================================================
   ; Also print cumulative totals
   ;====================================================================
   if ( Regrid ) then begin
      print
      print, 'Cumulative Totals: '
      print, '============================================================'
      print, Sum_Old_Cum, Format='( ''Old Grid [Tg CO]: '', e13.6)' 
      print, Sum_New_Cum, Format='( ''New Grid [Tg CO]: '', e13.6)' 
   endif

   ; Quit
   return
end
