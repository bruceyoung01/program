; $Id: ctm_regridh.pro,v 1.2 2004/06/03 17:58:08 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_REGRIDH
;
; PURPOSE:
;        Regrids data horizontally from one CTM grid to another, 
;        for both cases:
;             fine grid    -->  coarse grid  OR
;             coarse grid  -->  fine grid
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        NEWDATA = CTM_REGRIDH( DATA, OLDGRID, NEWGRID [ , Keywords ] )
;
; INPUTS:
;        DATA -> a 2-D or 3-D data field to be regridded.  DATA can be
;             either in single-precision or double-precision.  
;
;        OLDGRID, NEWGRID -> GRIDINFO structures (use "ctm_grid.pro" 
;             to create one) defining the old and new grids.
;
; KEYWORD PARAMETERS:
;        /DOUBLE -> If set, will return NEWDATA as a double-precision
;             array.  Default is to return NEWDATA as a floating-point
;             single-precision array.
;
;        /PER_UNIT_AREA -> Set this switch if the quantity you want to
;             regrid is per unit area or per unit volume (i.e. molec/cm2, 
;             molec/cm3, kg/m2, etc.).  CTM_REGRIDH will multiply by
;             the input grid's surface areas, so as to convert it to
;             an area-independent quantity for regridding.  After the 
;             regridding, CTM_REGRIDH will then divide the quantity
;             by the surface areas on the new grid.  
;
;        /USE_SAVED_WEIGHTS -> If set, will use the mapping weights
;             saved by a prior call to CTM_REGRIDH.  This is useful
;             if you are regridding 3-D data, thus CTM_REGRIDH can be
;             told only to compute the mapping weights for the first
;             level, thus saving processing time.
;
;        /VERBOSE -> If set, will echo informational messages to the
;             screen during the regridding process.  Totals on both
;             old and new grids will also be printed.
;
;        WFILE -> Name of the file with pre-saved mapping weights from
;             the old grid to the new grid (created by CTM_GETWEIGHT).
;             If WFILE is not specified, then CTM_REGRIDH will compute 
;             the mapping weights on the fly.  These weights will be
;             returned to the calling program via the WEIGHT keyword
;             for use on subsequent calls to CTM_REGRIDH.  
;
; OUTPUTS:
;        NEWDATA -> a 2-D or 3-D array containing the regridded data.
;
; SUBROUTINES:
;        Internal Subroutines Included:
;        =================================================
;        CRH_GETWEIGHT 
;
;        External Subroutines Required:
;        =================================================
;        CHKSTRU  (function)   CTM_BOXSIZE (function)   
;        CTM_GETWEIGHT         UNDEFINE
;       
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) CTM_REGRIDH now supersedes CTM_REGRID.  The old
;            CTM_REGRID program worked fine, but could only 
;            go from coarse grids to fine grids.
;
;        (2) Assumes that you are passing globally-sized arrays.
;            If you have less than global-sized data, then you 
;            must add that data to a globally sized array, and
;            then call CTM_REGRIDH.    
;
; EXAMPLE:
;        (1)
;
;        ; Define old grid
;        OLDTYPE    = CTM_TYPE( 'GENERIC',    RES=[1,1], $
;                                HALFPOLAR=0, CENTER180=0 )
;        OLDGRID    = CTM_GRID( OLDTYPE )
;
;        ; Define new grid
;        NEWTYPE    = CTM_TYPE( 'GEOS_STRAT', RES=4 )
;        NEWGRID    = CTM_GRID( NEWTYPE )
;
;        ; Regrid data
;        NEWDATA = CTM_REGweights_geos2x25_geos4x5.datRIDH( DATA, OLDGRID, NEWGRID, $
;                               /PER_UNIT_AREA, /VERBOSE )
;
;             ; Regrids a quantity such as fossil fuel emissions 
;             ; in [molec/cm2/s] from the generic 1 x 1 emissions
;             ; grid to GEOS-STRAT 4 x 5 resolution.  Message info 
;             ; will be echoed to the screen during the regridding.
;             ; The mapping weights from OLDGRID to NEWGRID will
;             ; be computed by CTM_REGRIDH and stored internally
;             ; for possible future use.  
;
;        (2)
;
;        ; Define old grid
;        OLDTYPE  = CTM_TYPE( 'GEOS_STRAT', RES=2 )
;        OLDGRID  = CTM_GRID( OLDTYPE )
;
;        ; Define new grid
;        NEWTYPE  = CTM_TYPE( 'GEOS_STRAT', RES=4 )
;        NEWGRID  = CTM_GRID( NEWTYPE )
;
;        ; Regrid first data array, read mapping weights from disk
;        NEWDATA1 = CTM_REGRIDH( DATA1, OLDGRID, NEWGRID, $
;                                WFILE='weights_generic1x1_geos4x5.dat' )
;
;        ; Regrid second data array, use weights from prior call
;        NEWDATA2 = CTM_REGRIDH( DATA2, OLDGRID, NEWGRID, $
;                               /USE_SAVED_WEIGHTS )
;
;             ; Regrids quantities such as air mass in [kg] from
;             ; 2 x 2.5 resolution to 4 x 5 resolution for the
;             ; GEOS-STRAT grid.  Since WFILE is specified,
;             ; will read the mapping weights between OLDGRID and 
;             ; from a file on disk instead of having to compute
;             ; them online.  These mapping weights will then be
;             ; saved internally for possible future use.
;             ;
;             ; Note that you can specify that you want to use the
;             ; pre-saved with the /USE_SAVED_WEIGHTS flag.  This 
;             ; prevents CTM_REGRIDH from having to re-read the 
;             ; mapping weights all over again -- a real timesaver.
;
; MODIFICATION HISTORY:
;        bmy, 13 Feb 2002: GAMAP VERSION 1.50
;                          - adapted from CTM_REGRID plus 
;                            other various existing codes
;        bmy, 16 Jan 2003: GAMAP VERSION 1.52
;                          - fixed a small bug which prevented flagging
;                            coarse --> fine regridding when going from
;                            1 x 1.25 to 1 x 1
;
;-
; Copyright (C) 2002-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_regridh"
;-----------------------------------------------------------------------

pro CRH_GetWeight, WeightFile, FineGrid, CoarseGrid, Weight, XX_Ind, YY_Ind

   ;===================================================================
   ; Internal Subroutine CRH_GETWEIGHT reads the pre-computed
   ; mapping weight factors from a file, if one is available.
   ;===================================================================

   ;------------------------------------------------------------------
   ; Prior to 5/26/04:
   ; Now figure out NPOINTS in a better way (bmy, 5/26/04)
   ;; Select grid size
   ;case ( CoarseGrid.IMX ) of
   ;   360  : N_Points =  3
   ;   288  : N_Points =  3
   ;   144  : N_Points =  6
   ;   72   : N_Points = 12
   ;   else : N_Points = 12
   ;endcase
   ;------------------------------------------------------------------

   ; Make space for # of small boxes that fit into the big box
   N_Points  = ( FineGrid.IMX / CoarseGrid.IMX ) + 2

   ; Define Output arrays 
   Weight = FltArr( CoarseGrid.IMX, CoarseGrid.JMX, N_Points, N_Points )
   XX_Ind = IntArr( CoarseGrid.IMX, CoarseGrid.JMX, N_Points           )
   YY_Ind = IntArr( CoarseGrid.IMX, CoarseGrid.JMX, N_Points           )

   ; Input arrays
   TmpArr    = IntArr( N_Points           )
   TmpWeight = FltArr( N_Points, N_Points )

   ; Open file w/ mapping weights
   Open_File, WeightFile, Ilun, /Get_LUN

   ; Read data from file...
   while ( not EOF( Ilun ) ) do begin
      
      ; Read "coarse" grid box indices to file
      ReadF, Ilun, I, J, Format='(2i4)'
         
      ; Read indices of "fine" boxes that comprise a "coarse" box
      ReadF, Ilun, TmpArr, Format='(3x,12i4)'         
      XX_Ind[I, J, *] = TmpArr
      
      ReadF, Ilun, TmpArr, Format='(3x,12i4)'
      YY_Ind[I, J, *] = TmpArr

      ; Read mapping weights
      ReadF, Ilun, TmpWeight, Format='(3x,12f6.2)' 
      Weight[I, J, *, *] = TmpWeight

   endwhile

   ; Close file 
   Close,    Ilun
   Free_LUN, Ilun

   ; Return to main program
   return
end

;------------------------------------------------------------------------------

function CTM_RegridH, Data, OldGrid, NewGrid,                               $
                      Double=Double,   Per_Unit_Area=Per_Unit_Area,         $
                      Verbose=Verbose, Use_Saved_Weights=Use_Saved_Weights, $
                      WFile=WFile,     _EXTRA=e
   
   ;====================================================================
   ; Common blocks
   ;====================================================================
   common SaveWeights, XX_Ind, YY_Ind, Weight

   ;====================================================================
   ; External Functions / Keyword Settings / Error checking
   ;====================================================================
   FORWARD_FUNCTION ChkStru, CTM_BoxSize

   ; Make sure inputs are passed
   if ( N_Elements( Data    ) eq 0 ) then Message, 'Must pass DATA array!'
   if ( N_Elements( OldGrid ) eq 0 ) then Message, 'Must pass OLDGRID!'
   if ( N_Elements( NewGrid ) eq 0 ) then Message, 'Must pass NEWGRID!'

   ; Keyword switches
   Double            = Keyword_Set( Double            )
   Per_Unit_Area     = Keyword_Set( Per_Unit_Area     )
   Use_Saved_Weights = Keyword_Set( Use_Saved_Weights )
   Verbose           = Keyword_Set( Verbose           )
   
   ; Check validity of OLDGRID
   if ( not ChkStru( OldGrid, [ 'IMX', 'JMX' ] ) ) $
      then Message, 'OLDGRID is not a valid GRIDINFO structure!'

   ; Check validity of NEWGRID
   if ( not ChkStru( NewGrid, [ 'IMX', 'JMX' ] ) ) $
      then Message, 'OLDGRID is not a valid GRIDINFO structure!'
  
   ; Dimensions of DATA array
   SData = Size( Data, /Dim )
   
   ; Error checks on size of DATA array
   if ( N_Elements( SData ) lt 2 ) then Message, 'DATA must be at least 2-D!'
   if ( N_Elements( SData ) gt 3 ) then Message, 'DATA cannot exceed 3-D!'

   ; Check that the horizontal size of DATA matches that 
   ; which is specified in the OLDGRID structure
   if ( SData[0] ne OldGrid.IMX ) then Message, 'DATA: improper lon dimension!'
   if ( SData[1] ne OldGrid.JMX ) then Message, 'DATA: improper lat dimension!'

   ; Number of vertical levels to regrid
   if ( N_Elements( SData ) eq 3 ) $
      then LMX = SData[2]          $
      else LMX = 1L 

   ; Make sure LMX does not exceed the maximum for this type of grid
   if ( ChkStru( OldGrid, 'LMX' ) )  $
      then if ( LMX gt OldGrid.LMX ) $
      then Message, 'DATA: improper vertical level dimension!'

   ; Define NEWDATA array for regridded data, either FLTARR or DBLARR
   NewData = DblArr( NewGrid.IMX, NewGrid.JMX, LMX ) 

   ; Add "fake" dimensions for 2-D arrays to facilitate looping
   if ( N_Elements( SData ) eq 2 ) then begin
      Data    = Reform( Data,    OldGrid.IMX, OldGrid.JMX, 1 )
      NewData = Reform( NewData, NewGrid.IMX, NewGrid.JMX, 1 )
   endif

   ;====================================================================
   ; Define variables
   ;====================================================================

   ; Compute grid box surface areas
   OldArea = CTM_BoxSize( OldGrid, /GEOS, /cm2 )
   NewArea = CTM_BoxSize( NewGrid, /GEOS, /cm2 )
 
   ; Summing variables
   Sum_Old = 0D
   Sum_New = 0D  

   ;====================================================================
   ; Determine if we are going from a fine grid to a coarse grid, 
   ; or from a coarse grid to a fine grid
   ;====================================================================
;------------------------------------------------------------------------------
; Prior to 1/16/03:
; Bug fix: now use DI, DJ instead of IMX, JMX to test if fine->coarse.
;   if ( NewGrid.IMX le OldGrid.IMX   OR $
;        NewGrid.JMX le OldGrid.JMX ) then begin
;
;      ; Here we are going from a fine grid to a coarse grid
;      FineGrid   = OldGrid
;      CoarseGrid = NewGrid
;
;      ; Set flag to indicate going from fine --> coarse
;      FromFineToCoarse = 1L
;
;      ; Echo informational message going from fine --> coarse
;      if ( Verbose ) then Message, 'Going from fine --> coarse...', /Info
;
;   endif else begin
;
;      ; Here we are going from a coarse grid to a fine grid
;      FineGrid   = NewGrid
;      CoarseGrid = OldGrid
;
;      ; Set flag to indicate NOT going from fine --> coarse
;      FromFineToCoarse = 0L
;
;      ; Echo informational message
;      if ( Verbose ) then Message, 'Going from coarse --> fine...', /Info
;
;   endelse
;------------------------------------------------------------------------------
   if ( ( OldGrid.DI gt NewGrid.DI )   OR $
        ( OldGrid.DJ gt NewGrid.DJ ) ) then begin
            
      ; Here we are going from a coarse grid to a fine grid
      FineGrid   = NewGrid
      CoarseGrid = OldGrid

      ; Set flag to indicate NOT going from fine --> coarse
      FromFineToCoarse = 0L

      ; Echo informational message
      if ( Verbose ) then Message, 'Going from coarse --> fine...', /Info

   endif else begin

      ; Here we are going from a fine grid to a coarse grid
      FineGrid   = OldGrid
      CoarseGrid = NewGrid

      ; Set flag to indicate going from fine --> coarse
      FromFineToCoarse = 1L

      ; Echo informational message going from fine --> coarse
      if ( Verbose ) then Message, 'Going from fine --> coarse...', /Info

   endelse

   ;====================================================================
   ; If WEIGHTFILE contains the name of a valid mapping weights file,
   ; then read data from this file.  Otherwise, compute the mapping
   ; weights online via internal subroutine CRH_GETWEIGHT.
   ;
   ; The WEIGHT, XX_IND, and YY_IND arrays will be stored in a common
   ; block for subsequent calls.  If you want to re-use these saved
   ; weights, then you can call CTM_REGRIDH with the /USE_SAVED_WEIGHTS
   ; keyword.  This will save lots of time.
   ;====================================================================
   if ( Use_Saved_Weights ) then begin

      ; We are using pre-saved weights -- echo info message
      if ( Verbose ) then begin
         S = 'Using saved weights from prior call to CTM_REGRIDH!'
         Message, S, /Info
      endif

      ; Make sure WEIGHT is defined
      if ( N_Elements( Weight ) eq 0 ) $
         then Message, 'Weights have not been pre-saved yet!'

      ; Make sure XX_IND is defined
      if ( N_Elements( XX_Ind ) eq 0 ) $
         then Message, 'Weights have not been pre-saved yet!'

      ; Make sure YY_IND is defined
      if ( N_Elements( YY_Ind ) eq 0 ) $
         then Message, 'Weights have not been pre-saved yet!'

      ; Make sure WEIGHT has the same dimensions as the given grid
      SW = Size( Weight, /Dim )

      if ( SW[0] ne CoarseGrid.IMX AND SW[1] ne CoarseGrid.JMX ) then begin
         S = 'The pre-saved weights are not consistent with OLDGRID, NEWGRID!'
         Message, S
      endif
      
      ; Undefine SW array 
      UnDefine, SW
      
   endif else begin

      ; If a valid WFILE is passed, read mapping weights from a file
      if ( N_Elements( WFile ) gt 0 ) then begin

         ; Display an info message
         if ( Verbose ) then begin
            S =  'Reading mapping weights from ' + StrTrim( WFile, 2 ) 
            Message, S, /Info
         endif

         ; Read pre-saved mapping weights from WFILE
         CRH_GetWeight, WFile, FineGrid, CoarseGrid, Weight, XX_Ind, YY_Ind 

      endif $ 

      ; If WFILE is not passed, compute mapping weights on the fly
      else begin
      
         ; Display an informational message
         if ( Verbose ) then begin
            S = 'Computing mapping weights on the fly...'
            Message, S, /Info
         endif

         ; Compute mapping weights online
         CTM_GetWeight, FineGrid, CoarseGrid, Weight, XX_Ind, YY_Ind 
      
      endelse

   endelse

   ;====================================================================
   ; Regrid the data!
   ;====================================================================
   if ( Verbose ) then Message, 'Regridding data...', /Info
   
   ; Loop over levels 
   for L = 0L, LMX - 1L do begin

      ; Copy DATA for this level only to TMPDATA and cast to DOUBLE
      TmpData = Double( Data[*,*,L] )

      ; Multiply by areas on old grid (if necessary) so that 
      ; the quantity being regridded will be area-dependent
      if ( Per_Unit_Area ) then TmpData = TmpData * OldArea

      ; Take level sum of area-independent quantity on old grid
      Sum_Old = Sum_Old + Total( TmpData )

      ;=================================================================
      ; Regrid from fine grid to coarse grid
      ;=================================================================
      if ( FromFineToCoarse ) then begin

         ; Loop over "coarse" surface boxes [I,J]
         for J = 0L, CoarseGrid.JMX - 1L do begin
         for I = 0L, CoarseGrid.IMX - 1L do begin

            ; Find number of boxes to loop over in X and
            ; Y dimensions -- where weights are nonzero
            Ind = Where( Weight[I, J, 0, *] gt 0, N_Y )
            Ind = Where( Weight[I, J, *, 0] gt 0, N_X )

            ; II and JJ are counters for the "fine" grid boxes 
            ; that fit into each "coarse" grid box
            for JJ = 0L, N_Y - 1L do begin
            for II = 0L, N_X - 1L do begin

               ; WEIGHT[I,J,II,JJ] is the fraction of each "fine"
               ; grid box [II,JJ] that fits into the "coarse" grid
               ; box [I,J].  WEIGHT[I,J,II,JJ] are always between 
               ; zero and one.  Skip to next iteration if zero.
               if ( Weight[I,J,II,JJ] eq 0 ) then goto, NextII0

               ; XX and YY are the actual "fine" grid box lon/lat indices
               XX = XX_Ind[I, J, II] 
               YY = YY_Ind[I, J, JJ]

               ; FRACDATA is the amount of data from of the "fine" 
               ; grid box (XX,YY) that fits into the "coarse" grid box (I,J),
               FracData = TmpData[XX,YY] * Weight[I,J,II,JJ]

               ; Add the data from the "fine" grid box
               ; into the "coarse" grid box 
               NewData[I,J,L] = NewData[I,J,L] + FracData

NextII0:
            endfor  ;II
            endfor  ;JJ

         endfor     ;I
         endfor     ;J
      
      endif $

      ;=================================================================
      ; Regrid from coarse grid to fine grid
      ;=================================================================
      else begin
         
         ; Loop over "coarse" surface boxes [I,J]
         for J = 0L, CoarseGrid.JMX - 1L do begin
         for I = 0L, CoarseGrid.IMX - 1L do begin

            ; Find number of boxes to loop over in X and
            ; Y dimensions -- where weights are nonzero
            Ind = Where( Weight[I, J, 0, *] gt 0, N_Y )
            Ind = Where( Weight[I, J, *, 0] gt 0, N_X )

            ; Compute sum of mapping weights over all boxes.  Note that
            ; this sum can be larger than one, therefore, when we compute
            ; FRACDATA below, we need to normalize by this sum.
            Sum_Area = 0D
            for JJ = 0L, N_Y - 1L do begin
            for II = 0L, N_X - 1L do begin
               Sum_Area = Sum_Area + Weight[I,J,II,JJ]
            endfor
            endfor
            
            ; II and JJ are counters for the "fine" grid boxes 
            ; that fit into each "coarse" grid box
            for JJ = 0L, N_Y - 1L do begin
            for II = 0L, N_X - 1L do begin

               ; WEIGHT[I,J,II,JJ] is the fraction of each "fine"
               ; grid box [II,JJ] that fits into the "coarse" grid
               ; box [I,J].  Skip if this fraction is zero.
               if ( Weight[I,J,II,JJ] eq 0 ) then goto, NextII1

               ; XX and YY are the actual "fine" grid box lon/lat indices
               XX = XX_Ind[I, J, II] 
               YY = YY_Ind[I, J, JJ]

               ; FRACDATA is the amount of data from of the "coarse" 
               ; grid box (I,J) that fits into the "fine" grid box (XX,YY),
               ; also normalized by the sum of the mapping weights
               FracData = TmpData[I,J] * Weight[I,J,II,JJ] / Sum_Area
                           
               ; Add the data from the "coarse" grid box
               ; into the "fine" grid box 
               NewData[XX,YY,L] = NewData[XX,YY,L] + FracData

NextII1:
            endfor  ;II
            endfor  ;JJ

         endfor  ;I
         endfor  ;J

      endelse

      ; Take level sum of area-independent quantity on new grid
      Sum_New = Sum_New + Total( NewData[*,*,L] )

      ; Divide by areas on the new grid, if necessary
      if ( Per_Unit_Area ) then NewData[*,*,L]= NewData[*,*,L] / NewArea

      ; Undefine TMPDATA for safety's sake
      UnDefine, TmpData
      
   endfor  ;L
      
   ;====================================================================
   ; Print sums on old & new grids, if /VERBOSE is set
   ;====================================================================
   if ( Verbose ) then begin
      F1 = '(''Sum Old (area-independent): '', e15.8)'
      F2 = '(''Sum New (area-independent): '', e15.8)'
        
      ; Print sums in kg for each level and tracer
      ; These should be identical, else there is a problem!!!
      print, Sum_Old, Format=F1            
      print, Sum_New, Format=F2
   endif
      
   ;====================================================================
   ; Cleanup and quit
   ;====================================================================

   ; Reform DATA and NEWDATA to eliminate the "fake" 3rd dimension,
   ; if necessary, before returning to the calling program
   Data    = Reform( Data    )
   NewData = Reform( NewData )

   ; Also cast back to single precision if DOUBLE=0
   if ( not Double ) then NewData = Float( NewData )

   ; Undefine variables for safety's sake
   UnDefine, FineGrid
   UnDefine, CoarseGrid

   ; Return to calling program
   return, NewData
end
