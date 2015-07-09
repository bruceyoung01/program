; $Id: regridh_bioburn.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_BIOBURN
;
; PURPOSE:
;        Regrids 1 x 1 biomass burning emissions for various tracers
;        onto a CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_BIOBURN [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTDIR -> Name of the directory where the output file will
;             be written.  Default is './'.  
;
;        /COPY -> Use this switch to write the original 1 x 1
;             biomass burning data to a binary punch file without
;             regridding.  
;
;        /SEASONAL -> Use this switch to process seasonal biomass
;             burning files (instead of interannual variability
;             files).
;
;        YEAR -> 4-digit year number for which to regrid data 
;             for interannual variability biomass burning.  YEAR
;             is ignored if SEASONAL=0.  Default is 1996.
;             
; OUTPUTS:
;        Writes binary punch files: 
;             bioburn.seasonal.{MODELNAME}.{RESOLUTION} OR
;             bioburn.interannual.{MODELNAME}.{RESOLUTION}.YEAR  
;
; SUBROUTINES:
;        Internal Subroutines:
;        =================================================
;        RBB_GetWeight     RBB_GetTracerInfo (function)
;        RBB_ReadData
;
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
;        (1) The path names for the files containing 1 x 1 data are
;            hardwired -- change as necessary!
;
;        (2) Now assumes 13 biomass burning tracers -- change this
;            number as necessary.
;
;        (3) REGRID_BIOBURN now will produce output for a whole
;            year in one file.  This is most convenient.
;
;        (4) Sometimes you might have to close all files and call
;            "ctm_cleanup.pro" in between calls to this routine.
;
; EXAMPLE:
;        REGRIDH_BIOBURN, OUTMODELNAME='GEOS_STRAT', OUTRESOLUTION=4, $
;                         /SEASONAL, WEIGHTFILE="weights_gen1x1_geos4x5.dat"
;           
;             ; Regrids seasonal 1 x 1 biomass burning data from February
;             ; for CO (tracer #2) onto the 4 x 5 GEOS-STRAT grid, using
;             ; mapping weights stored in "weights_gen1x1_geos4x5.dat".
;
; MODIFICATION HISTORY:
;        bmy, 09 Jun 2000: VERSION 1.00
;        bmy, 14 Jul 2000: VERSION 1.01
;                          - adapted for 9 biomass burning tracers
;        bmy, 24 Jul 2000: - added OUTDIR keyword
;        bmy, 13 Feb 2001: VERSION 1.02
;                          - added ALK4, CH4, CH3I as biomass 
;                            burning tracers
;        bmy, 15 Feb 2001: VERSION 1.03
;                          - now use pre-saved mapping weights, 
;                            for computational expediency
;                          - now no longer use
;                          - added /SEASONAL keyword to regrid
;                            seasonal climatological biomass burning
;                            instead of interannual variability BB.
;        bmy, 28 Jun 2001: VERSION 1.04
;                          - added COPY keyword, to just write a 1x1
;                            binary punch file w/o regridding
;        bmy, 02 Jul 2001: VERSION 1.05
;                          - YEAR is now 4 digits
;                          - now uses 1985 TAU values for seasonal
;                            BB emissions and TAU values corresponding
;                            to YEAR for interannual BB emissions
;        bmy, 21 Sep 2001: VERSION 1.06
;                          - modified to handle Randall's year 2000
;                            files for interannual variability
;                          - renamed MODELNAME to OUTMODELNAME and
;                            RESOLUTION to OUTRESOLUTION
;        bmy, 24 Sep 2001: VERSION 1.07
;                          - now created TINFO array of structures
;                            w/ information about each biomass tracer
;                          - also save TOTB (CTM tracer #33) as g/cm2 
;        bmy, 11 Feb 2002: VERSION 1.08
;                          - now regrid all months of 2000
;        bmy, 14 Nov 2002: VERSION 1.09
;                          - renamed to REGRIDH_BIOBURN
;                          - removed WEIGHTFILE keyword
;        bmy, 23 Dec 2003: VERSION 1.10
;                          - updated for GAMAP v2-01
;
;-
; Copyright (C) 2000-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridh_bioburn"
;-----------------------------------------------------------------------


function RBB_ReadData, InFileName, InGrid
   
   ;====================================================================
   ; Internal function RBB_READDATA reads the 1 x 1 biomass burning
   ; data from disk in ASCII format and returns it to the main program
   ;====================================================================

   ; Echo filename to screen
   S = 'Reading ' + StrTrim( InFileName, 2 )
   Message, S, /Info
   
   ; Array to hold 1 x 1 biomass burning data
   InData = DblArr( InGrid.IMX, InGrid.JMX )

   ; Open ASCII file containing biomass burning data for CO
   Open_File, InFileName, 1
 
   ; Read data from each monthly file
   ReadF, 1, InData, Format='(360e16.7)' 
 
   ; Close ASCII file
   Close, 1

   ; Return DATA to calling program
   return, InData
end

;-----------------------------------------------------------------------------

function RBB_GetTracerInfo

   ;====================================================================
   ; Internal function RBB_GetTracerInfo returns an array of
   ; structures with information about each biomass tracer.
   ;====================================================================

   ; Structure template
   Template = { CTM_Number : 0L,  $
                Number     : 0L,  $
                Name       : '',  $
                MolWt      : 0D,  $
                XNumol     : 0D,  $
                Unit       : '',  $
                PrtUnit    : '' }

   ; Make an array of structures
   T = Replicate( Template, 13 )

   ;====================================================================
   ; There are 13 biomass burning species:
   ;
   ;     Tracer      Biomass Burning #   CTM Tracer #   # of Carbons
   ;                 (for rvm files)
   ;     ------------------------------------------------------------
   ;       NO   (NOx)        1                 1             -
   ;       CO                2                 4             1
   ;       ALK4             10                 5             4
   ;       ACET              5                 9             3
   ;       MEK               6                10             4
   ;       ALD2              8                11             3
   ;       PRPE (C3H6)       4                18             3 
   ;       C3H8              7                19             3
   ;       CH2O              9                20             1
   ;       C2H6              3                21             2
   ;       Total biomass    13                33             1
   ;       CH4              11                55             1
   ;       CH3I             12                71             1
   ;====================================================================

   ; NOx
   T[0].CTM_Number  = 1
   T[0].Number      = 1
   T[0].Name        = 'NO'
   T[0].MolWt       = 14d-3
   T[0].Xnumol      = 6.022d23 / T[0].MolWt
   T[0].Unit        = 'molec/cm2'
   T[0].PrtUnit     = '[Tg N]' 

   ; CO
   T[1].CTM_Number  = 4
   T[1].Number      = 2
   T[1].Name        = 'CO'
   T[1].MolWt       = 28d-3
   T[1].Xnumol      = 6.022d23 / T[1].MolWt
   T[1].Unit        = 'molec/cm2'
   T[1].PrtUnit     = '[Tg]' 

   ; ALK4
   T[2].CTM_Number  = 5
   T[2].Number      = 10
   T[2].Name        = 'ALK4'
   T[2].MolWt       = 12d-3
   T[2].Xnumol      = 6.022d23 / T[2].MolWt
   T[2].Unit        = 'molec C/cm2'
   T[2].PrtUnit     = '[Tg C]' 

   ; ACET
   T[3].CTM_Number  = 9
   T[3].Number      = 5
   T[3].Name        = 'ACET'
   T[3].MolWt       = 58d-3
   T[3].Xnumol      = 6.022d23 / T[3].MolWt
   T[3].Unit        = 'molec/cm2'
   T[3].PrtUnit     = '[Tg] '

   ; MEK
   T[4].CTM_Number  = 10
   T[4].Number      = 6
   T[4].Name        = 'MEK'
   T[4].MolWt       = 12d-3
   T[4].Xnumol      = 6.022d23 / T[4].MolWt
   T[4].Unit        = 'molec C/cm2'
   T[4].PrtUnit     = '[Tg C]' 

   ; ALD2
   T[5].CTM_Number  = 11
   T[5].Number      = 8
   T[5].Name        = 'ALD2'
   T[5].MolWt       = 12d-3
   T[5].Xnumol      = 6.022d23 / T[5].MolWt
   T[5].Unit        = 'molec C/cm2'
   T[5].PrtUnit     = '[Tg C]' 

   ; PRPE (C3H6)
   T[6].CTM_Number  = 18
   T[6].Number      = 4
   T[6].Name        = 'PRPE'
   T[6].MolWt       = 12d-3
   T[6].Xnumol      = 6.022d23 / T[6].MolWt
   T[6].Unit        = 'molec C/cm2'
   T[6].PrtUnit     = '[Tg C]'

   ; C3H8
   T[7].CTM_Number  = 19
   T[7].Number      = 7
   T[7].Name        = 'C3H8'
   T[7].MolWt       = 44d-3
   T[7].Xnumol      = 6.022d23 / T[7].MolWt
   T[7].Unit        = 'molec/cm2'
   T[7].PrtUnit     = '[Tg]'

   ; CH2O
   T[8].CTM_Number  = 20
   T[8].Number      = 9
   T[8].Name        = 'CH2O'
   T[8].MolWt       = 30d-3
   T[8].Xnumol      = 6.022d23 / T[8].MolWt
   T[8].Unit        = 'molec/cm2'
   T[8].PrtUnit     = '[Tg]'

   ; C2H6
   T[9].CTM_Number  = 21
   T[9].Number      = 3
   T[9].Name        = 'C2H6'
   T[9].MolWt       = 30d-3
   T[9].Xnumol      = 6.022d23 / T[9].MolWt
   T[9].Unit        = 'molec/cm2'
   T[9].PrtUnit     = '[Tg]'

   ; TOTB
   T[10].CTM_Number = 33
   T[10].Number     = 13 
   T[10].Name       = 'TOTB'
   T[10].MolWt      = 1d-3
   T[10].Xnumol     = 6.022d23 / T[10].MolWt 
   T[10].Unit       = 'g/cm2'
   T[10].PrtUnit    = '[Tg]'

   ; CH4
   T[11].CTM_Number = 55
   T[11].Number     = 11
   T[11].Name       = 'CH4'
   T[11].MolWt      = 16d-3
   T[11].Xnumol     = 6.022d23 / T[11].MolWt
   T[11].Unit       = 'molec/cm2'
   T[11].PrtUnit    = '[Tg]'

   ; CH3I
   T[12].CTM_Number = 71
   T[12].Number     = 12
   T[12].Name       = 'CH3I'
   T[12].MolWt      = 142d-3
   T[12].Xnumol     = 6.022d23 / T[12].MolWt
   T[12].Unit       = 'molec/cm2'
   T[12].PrtUnit    = '[Tg]'

   ; Return to calling program
   return, T

end

;-----------------------------------------------------------------------------

pro RegridH_BioBurn, OutModelName=OutModelName, OutResolution=OutResolution, $
                     OutDir=OutDir,             Year=Year,                   $
                     Seasonal=Seasonal,         Copy=Copy,                   $
                     _EXTRA=e
  
   ; Close all open files, for safety's sake
   Close, /All

   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,   CTM_BoxSize, $
                    CTM_Regrid, CTM_NamExt, CTM_ResExt

   Copy     = Keyword_Set( Copy     )
   Seasonal = Keyword_Set( Seasonal )
   if ( N_Elements( Year          ) eq 0 ) then Year          = 1996
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS1'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
   if ( N_Elements( OutDir        ) eq 0 ) then OutDir        = './'
   
   ; Trim excess spaces from OUTDIR
   OutDir = StrTrim( OutDir, 2 )

   ; Make sure the last character of OUTDIR is a slash
   if ( StrMid( OutDir, StrLen( OutDir ) - 1, 1 ) ne '/' ) $
      then OutDir = OutDir + '/'

   ;====================================================================
   ; Define other variables
   ;====================================================================

   ; Return a structure w/ information about each biomass burning tracer
   TInfo = RBB_GetTracerInfo()

   ; Define the path name for each of the ASCII files that 
   ; contain 1 x 1 biomass burning data -- change if necessary!
   if ( Seasonal )                               $
      then FilePath = '~bmy/archive/data/biomass_200110/raw/climat/'     $
      else FilePath = '~bmy/archive/data/biomass_200110/raw/interannual/'

   ; Input datafile suffix
   Suffix = 'mmcm2mon'

   ; Array of month names
   MonthName = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
                 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ]

   ; MODELINFO, GRIDINFO structures, and surface areas for old grid
   InType = CTM_Type( 'generic', res=[1, 1], HalfPolar=0, Center180=0 )
   InGrid = CTM_Grid( InType, /No_Vertical )

   ; MODELINFO, GRIDINFO structures, and surface areas for new grid
   OutType = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )
 
   ; TAU = time values (hours) for indexing each month
   Tau    = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
              4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
  
   ; If we are copying 1 x 1 data to a binary punch file, then
   ; make sure to use the proper MODELINFO and GRIDINFO structures
   if ( Copy ) then begin
      OutType = InType
      OutGrid = InGrid
   endif

   ;====================================================================
   ; Regrid all biomass burning tracers for this month
   ;====================================================================

   ; Set first time flag
   First = 1L

   ; Pick starting and ending month index based on the year
   if ( Seasonal ) then begin

      ; For seasonal -- we always have 12 months
      Month0 = 1L
      Month1 = 12L

   endif else begin

      ; For Interannual -- these are based on TOMS data, so 
      ; some years have missing months
      case ( Year ) of
         1996: begin
            YearStr = '96' 
            Month0  = 8L
            Month1  = 12L
         end

         2000: begin
            YearStr = '910'
            Month0  = 1L
            Month1  = 12L
         end

         else: begin
            YearStr = StrTrim( String( Year mod 100L ), 2 )
            Month0  = 1L
            Month1  = 12L
         end
      
      endcase
   endelse

   ;====================================================================
   ; Loop over months -- T is the month index
   ;====================================================================
   for T = Month0 - 1L, Month1 - 1L do begin

      ; For Seasonal biomass burning data, use 1985
      ; For interannual variablity, use current TAU (assume GEOS epoch)
      if ( Seasonal ) then begin
         ThisTau0 = Tau[T]
         ThisTau1 = Tau[T+1]
      endif else begin
         ThisTau0 = Nymd2Tau( Year * 10000L + (T+1)*100L + 1, /GEOS )
         ThisTau1 = Nymd2Tau( Year * 10000L + (T+1)*100L + 1, /GEOS )
      endelse

      ;=================================================================
      ; Loop over tracers -- N is the tracer index
      ;=================================================================
      for N = 0L, N_Elements( TInfo ) - 1L do begin

         ; Choose file name for either seasonal or interannual variability
         if ( Seasonal ) then begin
            File = FilePath + MonthName[T]                             + $
                   '.'      + StrTrim( String( TInfo[N].Number ), 2 )  + $
                   '.'      + Suffix
         endif else begin
            File = FilePath + MonthName[T] + YearStr                   + $
                   '.'      + StrTrim( String( TInfo[N].Number ), 2 )  + $
                   '.'      + Suffix
         endelse

         ; Print filename for this month
         ; Read biomass burning data on the 1 x 1 grid
         InData = RBB_ReadData( File, InGrid )

         ; Convert from Av*g/cm2 to g/cm2; for total biomass (tracer #33)
         if ( TInfo[N].Number eq 13 ) then begin
            InData = InData / 6.022d23
         endif

         ;==============================================================
         ; Copy or regrid?
         ;==============================================================
         if ( Copy ) then begin

            ; Skip regridding if this is already 1 x 1 data
            OutData = InData

         endif else begin
            
            ; Flag to determine when to use saved mapping weights
            US = 1L - First

            ; Regrid data from OLDGRID to NEWGRID
            OutData = CTM_RegridH( InData,         InGrid,  OutGrid,      $
                                   /Per_Unit_Area, /Double, Use_Saved=US )

         endelse

         ;==============================================================
         ; Make a DATAINFO structure for this NEWDATA, 
         ; append into an array of structures for disk write
         ;==============================================================
         Success = CTM_Make_DataInfo( Float( OutData ),          $
                                      ThisDataInfo,              $
                                      ThisFileInfo,              $
                                      ModelInfo=OutType,         $
                                      GridInfo=OutGrid,          $
                                      DiagN='BIOBSRCE',          $
                                      Tracer=TInfo[N].CTM_Number,$
                                      Tau0=ThisTau0,             $
                                      Tau1=ThisTau1,             $
                                      Unit=TInfo[N].Unit,        $
                                      Dim=[OutGrid.IMX,          $
                                           OutGrid.JMX, 0, 0],   $
                                      First=[1L, 1L, 1L] )
 
         ; NEWDATAINFO is an array of DATAINFO Structures
         ; Append THISDATAINFO onto the NEWDATAINFO array
         if ( First )                                            $             
            then NewDataInfo = [ ThisDataInfo ]                  $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

         ; Reset the first time flag
         First = 0L

         ; Undefine variables for safety's sake
         UnDefine, InData
         UnDefine, OutData
         UnDefine, ThisDataInfo

      endfor  ; N
   endfor     ; T
 
   ;====================================================================
   ; Write all data blocks to a binary punch file
   ;====================================================================
   if ( Seasonal ) then begin
      OutFileName = OutDir + 'bioburn.seasonal.' + CTM_NamExt( OutType ) + $
                             '.'                 + CTM_ResExt( OutType ) 
   endif else begin
      OutFileName = OutDir + $
                    'bioburn.interannual.' + CTM_NamExt( OutType ) + $
                    '.'                    + CTM_ResExt( OutType ) + $
                    '.'                    + StrTrim( String( Year ), 2 ) 
   endelse

   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

   ; Quit
   return
end
