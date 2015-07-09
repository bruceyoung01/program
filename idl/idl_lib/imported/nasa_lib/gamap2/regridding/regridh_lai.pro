; $Id: regridh_lai.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_LAI
;
; PURPOSE:
;        Regrids Leaf Area Indices and Olson Land Types from a 
;        0.5 x 0.5 grid onto a CTM grid of equal or coarser 
;        horizontal resolution.
;        
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_LAI [, Keywords ]
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
; OUTPUTS:
;        Writes files:
;             vegtype.global
;             lai{MONTHNUM}.global
;  
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================================
;        CTM_TYPE   (function)   CTM_GRID (function)
;        CTM_RESEXT (function)   CTM_GETWEIGHT
;
;        Internal Subroutines:
;        ==============================
;        RL_GETWEIGHT
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Filenames are hardwired -- change as necessary
;        (2) Regridding can take a while, especially at 1x1 resolution.
;
; EXAMPLE: 
;        REGRIDH_LAI, MODELNAME='GEOS1', RES=2, OUTDIR='~/scratch/bmy/'
; 
;             ; Regrids 1 x 1 NOx fertilizer data onto the GEOS-1
;             ; 2 x 2.5 resolution grid.  The output file will be
;             ; written to the '~/scratch/bmy/' directory.
;
; MODIFICATION HISTORY:
;        bmy, 04 Aug 2000: VERSION 1.00
;                          - adapted from old FORTRAN code
;        bmy, 15 Jan 2003: VERSION 1.01
;                          - renamed to "regridh_lai.pro"
;                          - renamed MODELNAME to OUTMODELNAME
;                          - renamed RESOLUTION to OUTRESOLUTION
;        bmy, 18 Jun 2004: VERSION 1.02
;                          - Bug fix: TMPAREA array needs to be
;                            defined with N_TYPE, not N_MON
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_lai"
;-----------------------------------------------------------------------


pro RegridH_LAI, OutModelName=OutModelName, OutResolution=OutResolution, $
                 OutDir=OutDir,             _EXTRA=e
 
   ;===================================================================
   ; Initialization
   ;===================================================================
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_NamExt, CTM_ResExt

   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS1'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
   if ( N_Elements( OutDir        ) eq 0 ) then OutDir        = './'

   ; Trim excess spaces from OUTDIR
   OutDir = StrTrim( OutDir, 2 )

   ; Make sure the last character of OUTDIR is a slash
   if ( StrMid( OutDir, StrLen( OutDir ) - 1, 1 ) ne '/' ) $
      then OutDir = OutDir + '/'

   ;===================================================================
   ; Define variables
   ;===================================================================
   
   ; MODELINFO, GRIDINFO structures & surface areas -- old grid
   InType  = CTM_Type( 'generic', Resolution=0.5, HalfPolar=0, Center180=0 )
   InGrid  = CTM_Grid( InType, /No_Vertical)
   InArea  = CTM_BoxSize( InGrid, /GEOS, /Cm2 )
   
   ; MODELINFO & GRIDINFO structures & surface areas -- new grid
   OutType  = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid  = CTM_Grid( OutType, /No_Vertical )
   OutArea  = CTM_BoxSize( OutGrid, /GEOS, /cm2 )

   ; N_MON  is the number of months
   ; N_TYPE is the maximum number of land types per grid box
   N_Mon    = 12
   N_Type   = 16

   ; IREG is the number of land types in each "coarse" grid box
   IReg     = IntArr( OutGrid.IMX, OutGrid.JMX )

   ; Land type arrays
   InOLT    = IntArr( InGrid.IMX, InGrid.JMX         )
   OutOLT   = IntArr( OutGrid.IMX, OutGrid.JMX, N_Type )
   FrcOLT   = IntArr( OutGrid.IMX, OutGrid.JMX, N_Type )

   ; LAI arrays
   InLAI    = FltArr( InGrid.IMX,  InGrid.JMX,  N_Mon         )
   OutLAI   = FltArr( OutGrid.IMX, OutGrid.JMX, N_Mon, N_Type )

   ; Input file names -- change as necessary
   OLTFile  = '~bmy/archive/data/leaf_area_index_200202/05x05_gen/owe14d.0.5'
   LAIFile  = '~bmy/archive/data/leaf_area_index_200202/05x05_gen/lai_all.dat'
   
   ; Misc variables
   TmpArea  = FltArr( N_Type )
   TmpLAI   = FltArr( N_Mon )
   I        = 0L
   J        = 0L

   ;===================================================================
   ; Get the mapping weight array from OLDGRID to NEWGRID
   ;===================================================================
   Message, 'Getting mapping weights (this can take a while) ...', /Info
   CTM_GetWeight, InGrid, OutGrid, Weight, XX_Ind, YY_Ind

   ;===================================================================
   ; Read the Olson land types from the file "owe14d.0.5"
   ;
   ; The Olson land types are as follows (starting from zero
   ; ------------------------------------------------------------------
   ;  0 Water              25 Deciduous           50 Desert
   ;  1 Urban              26 Deciduous           51 Desert
   ;  2 Shrub              27 Conifer             52 Steppe
   ;  3 ---                28 Dwarf forest        53 Tundra
   ;  4 ---                29 Trop. broadleaf     54 rainforest
   ;  5 ---                30 Agricultural        55 mixed wood/open
   ;  6 Trop. evergreen    31 Agricultural        56 mixed wood/open
   ;  7 ---                32 Dec. woodland       57 mixed wood/open
   ;  8 Desert             33 Trop. rainforest    58 mixed wood/open
   ;  9 ---                34 ---                 59 mixed wood/open
   ; 10 ---                35 ---                 60 conifers
   ; 11 ---                36 Rice paddies        61 conifers
   ; 12 ---                37 agric               62 conifers
   ; 13 ---                38 agric               63 Wooded tundra
   ; 14 ---                39 agric.              64 Moor
   ; 15 ---                40 shrub/grass         65 coastal
   ; 16 Scrub              41 shrub/grass         66 coastal
   ; 17 Ice                42 shrub/grass         67 coastal
   ; 18 ---                43 shrub/grass         68 coastal
   ; 19 ---                44 shrub/grass         69 desert
   ; 20 Conifer            45 wetland             70 ice
   ; 21 Conifer            46 scrub               71 salt flats
   ; 22 Conifer            47 scrub               72 wetland
   ; 23 Conifer/Deciduous  48 scrub               73 water
   ; 24 Deciduous/Conifer  49 scrub
   ;===================================================================
   Message, 'Reading Olson Land Types ... ', /Info

   Open_File, OLTFile, Ilun, /Get_LUN
   
   ReadF, Ilun, InOLT, Format='(20i4)'
   
   Close,    Ilun
   Free_Lun, Ilun

   ; We have to reverse the rows of OLDOLT, since the Olson
   ; Landtype file starts at the North Pole and goes southward
   InOLT = Reverse( InOLT, 2 )

   ; Find & print unique landtypes
   Ind     = Uniq( InOLT, Sort( InOLT ) )
   UniqOLT = InOLT[Ind]

   Message, 'Olson Land Types found: ', /Continue 
   Print, UniqOLT, Format='(20i3)'

   ;===================================================================
   ; Read in 0.5 x 0.5 Leaf Area Indices from the "lai_all.dat" file
   ;===================================================================
   Message, 'Reading Leaf Area Indices ...', /Info
   
   Open_File, LAIFile, Ilun, /Get_LUN

   ; Skip first header line
   Dumstr = ''
   ReadF, Ilun, Dumstr, Format='(a)'

   ; Read 12 months of LAI data for each point
   ; Convert (I,J) from FORTRAN to IDL notation
   while ( not EOF( Ilun ) ) do begin
      ReadF, Ilun, I, J, TmpLAI, Format='(i3,1x,i3,1x,12f5.1)'

      for N = 0L, N_Mon - 1L do begin
         InLAI[ I-1, J-1, N ] = TmpLAI[N]
      endfor
   endwhile

   Close,    Ilun
   Free_Lun, Ilun

   ;===================================================================
   ; Read in 0.5 x 0.5 Leaf Area Indices from the "lai_all.dat" file
   ;
   ; NOTE: Program logic is a little jumpy, this was taken from
   ;       an old FORTRAN code.  It works, though. (bmy, 8/2/00)
   ;===================================================================
   Message, 'Regridding data (this can take a while) ... ', /Info

   ; Loop over the "coarse" grid boxes
   for J = 0L, OutGrid.JMX - 1L do begin
   for I = 0L, OutGrid.IMX - 1L do begin

      ; Zero some variables
      TmpArea[*] = 0.0
      SumArea    = 0.0
      IReg[I,J]  = 0

      ; II and JJ are the number of "fine" grid boxes per coarse box
      for JJ = 0L, N_Elements( YY_Ind[I, J, *] ) - 1L do begin
      for II = 0L, N_Elements( XX_Ind[I, J, *] ) - 1L do begin

         ; XX and YY are the actual "fine" grid box lon/lat indices
         XX = XX_Ind[I, J, II] 
         YY = YY_Ind[I, J, JJ]

         ; Skip over "fine" grid boxes that don't fit into
         ; the "coarse" grid box -- just in case!
         if ( Weight[I,J,II,JJ] eq 0.0 ) then goto, Next
 
         ; AREA is the surface area of the portion of each "fine" 
         ; grid box that fits into the "coarse" grid box. 
         Area = InArea[XX,YY] * Weight[I,J,II,JJ]

         ; SUMAREA is a running total of AREA
         SumArea = SumArea + Area

         ;==============================================================
         ; Loop over the land types in "coarse" grid box (I,J)
         ;
         ; If the Kth land type has been previously defined, then 
         ; multiply the LAI value (on the "fine" grid) for each 
         ; month by the corresponding mapping weight
         ;==============================================================
         for K = 0L, IReg[I,J] - 1L do begin

            ; We have found a previously existing land type
            ; in the "coarse" box
            if ( OutOLT[I,J,K] eq InOLT[XX,YY] ) then begin

               ; Archive the surface area occupied by the 
               ; Kth land type for the "fine" grid box (II,JJ)
               TmpArea[K] = TmpArea[K] + Area

               ; Mapping from "fine" grid to "coarse" grid
               ; NEWLAI has units of [cm2 leaf]
               for M = 0L, N_Mon - 1L do begin
                  OutLAI[I,J,M,K] = OutLAI[I,J,M,K] + $
                                    ( InLAI[XX,YY,M] * Area )
               endfor

               ; Go to the next "fine" grid box (II,JJ)
               goto, Next
            endif

         endfor

         ;==============================================================
         ; If the Kth land type has NOT been previously defined,
         ; then increment IREG[I,J] and multiply the LAI value
         ; for each month by its corresponding mapping weight
         ;==============================================================

         ; Increment the number of landtypes in the "coarse" box
         IReg[I,J] = IReg[I,J] + 1

         ; Error check 
         if ( IReg[I,J] gt N_Type ) then begin
            S = 'More than 15 land types in grid box: (' + $
               String( I, Format='(i4)' ) + ',' + $
               String( J, Format='(i4)' )
            
            Message, S, /Continue
            return
         endif
        
         ; Land type index (convert to IDL notation)
         K = IReg[I,J] - 1L

         ; Save land type K in NEWOLT
         OutOLT[I,J,K] = InOLT[XX,YY]
               
         ; Archive the surface area occupied by the 
         ; Kth land type for the "fine" grid box (II,JJ)
         TmpArea[K] = Area

         ; Mapping from "fine" grid to "coarse" grid
         ; NEWLAI has units of [cm2 leaf]
         for M = 0L, N_Mon - 1L do begin
            OutLAI[I,J,M,K] = InLAI[XX,YY,M] * Area 
         endfor

      ; Go to next "fine" grid box!
Next:
      endfor
      endfor

      ;=================================================================
      ; At this point, all of the "fine" grid boxes that comprise a 
      ; "coarse" grid box have been looped over.  Do the following:
      ; 
      ; (a) Compute the fraction of the "coarse" grid box occupied  
      ;     by each landtype.  Express as a fraction per mil.
      ;
      ; (b) Divide the LAI for each month and landtype by TEMP, 
      ;     which is the 4 x 5 surface area in cm^2.  Store in OUTLAI.  
      ;     Recall that  LAI is defined as (cm^2 leaf area / 
      ;     cm^2 surface area). 
      ;     Therefore, OUTLAI are the LAI's per month and landtype for
      ;     the current 4 x 5 box (I,J) 
      ;=================================================================

      ; ITOTAL = total of land surface area
      ITotal = 0L

      ; IMAX = the land type that has the most leaf coverage
      IMax   = 0L
      
      ; Loop over each landtype K
      for K = 0L, IReg[I, J] - 1L do begin

         ; Fraction of grid box occupied by the Kth land type
         ; FRCOLT is expressed as a fraction per mil
         Frac          = Round( ( TmpArea[K] / SumArea ) * 1000.0 )
         FrcOLT[I,J,K] = Frac
         
         ; Convert NEWLAI to [cm2 leaf/cm2 surface area] 
         ; for month M and landtype K
         for M = 0L, N_Mon - 1L do begin
            OutLAI[I,J,M,K] = OutLAI[I,J,M,K] / TmpArea[K]
         endfor

         ; IMAX is the landtype with the greatest surface coverage
         if ( FrcOLT[I,J,IMax] lt Frac ) then IMax = K
         ITotal = ITotal + Frac
      endfor
         
      ; Make sure everything adds up to 1000
      if ( ITotal ne 1000L ) then begin
         FrcOLT[I,J,IMax] = FrcOLT[I,J,IMax] + ( 1000L - ITotal )
      endif

   endfor
   endfor
     
   ;====================================================================
   ; Write the fractions of each land type to the "vegtype.global" file
   ;====================================================================
   Message, 'Writing file "vegtype.global" ...', /Info

   OutFileName = OutDir + 'vegtype.global'

   Open_File, OutFileName, Ilun, /Get_LUN, /Write

   for J = 0L, OutGrid.JMX - 1L do begin
   for I = 0L, OutGrid.IMX - 1L do begin
      N = IReg[I,J]
      
      PrintF, Ilun, Format='(20i4)', $
         I+1, J+1, N, Reform( OutOLT[I,J,0:N-1] ), Reform( FrcOLT[I,J,0:N-1] )
   endfor
   endfor

   Close,    Ilun
   Free_LUN, Ilun

   ;====================================================================
   ; Write the monthly LAI files to disk
   ;====================================================================
   Message, 'Writing files "lai**.global" ...', /Info

   for M = 0L, N_Mon-1L do begin
     
      ; Open this month's file for output
      OutFileName = OutDir + 'lai' + $
                    String( M+1, Format='(i2.2)' ) + '.global'

      Open_File, OutFileName, Ilun, /Get_LUN, /Write

      ; Loop over "coarse" grid boxes
      for J = 0L, OutGrid.JMX - 1L do begin
      for I = 0L, OutGrid.IMX - 1L do begin

         ; Loop over all landtypes in the "coarse" grid box
         for K = 0L, IReg[I,J] - 1L do begin

            ; print out LAI values above a threshold value
            if ( OutLAI[I,J,M,K] ge 0.05 ) then begin
               PrintF, Ilun, Format='(3I3,20F5.1)', $
                  I+1, J+1, IReg[I,J], OutLAI[I,J,M,0:IReg[I,J]-1L]
               goto, Next2
            endif
         endfor

Next2:
      endfor
      endfor

      Close,    Ilun
      Free_LUN, Ilun
   endfor

   ; Quit
   return
end
