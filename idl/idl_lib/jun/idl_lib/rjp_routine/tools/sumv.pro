; $Id: sumv.pro,v 1.50 2002/05/24 14:10:17 bmy v150 $
;-------------------------------------------------------------
;+
; NAME:
;        SUMV
;
; PURPOSE:
;        Takes data on one vertical grid, translates it to 
;        another vertical grid, and sums it.  The total
;        column sum will be preserved.
;
; CATEGORY:
;        Regridding / Summing
;
; CALLING SEQUENCE:
;        Result = SUMV( DATA, POLD [, PNEW [, KEYWORDS ] ] )
;
; INPUTS:
;        DATA -> the 1-D vertical column of data to be regridded
;
;        POLD (optional) -> The pressure centers (in mb) corresponding
;             to each element of DATA.   POLD is superseded by the 
;             ZEDGE_OLD keyword, which contains pressure-altitude
;             edges that will be used to define the input grid.
;
;        PNEW (optional) -> The pressure centers (in mb) that 
;             defines the grid onto which DATA will be placed.
;             PNEW is superseded by the ZEDGE keyword, which 
;             contains pressure-altitude edges that will be
;             used to define the output grid.;        
;
; KEYWORD PARAMETERS:
;        BOXHEIGHT -> The height of each of the vertical boxes of
;             the old grid.  This is needed to make sure that
;             quantities such as kg/m3 are regridded properly.  If
;             BOXHEIGHT is not specified, then each box will be
;             assumed to be of height 1.0.  
;
;        PSURF -> Vector containing [ PSURFACE(old), PSURFACE(new) ]
;             for the old and new grids.  If PSURF is passed as a
;             scalar, then the same surface pressure will be used
;             for both old and new grids.  Default is [ 1000.0, 1000.0 ].
;
;        ZEDGE_OLD -> Contains pressure-altitude edges (see Note #1 below) 
;             which define the input grid.  ZEDGE_OLD may be specified
;             instead of POLD.
;
;        ZEDGE_NEW -> Contains pressure-altitude edges (see Note #1 below) 
;             which define the output grid.  Regridded data will be 
;             returned at the center point between successive
;             pressure-altitude edges.
;
;        MIN_VALID -> the minimum valid data value that shall be accepted.
;             Values lower than MIN_VALID will be assigned a value of 
;             MIN_VALID. Default is 0. (since this routine will be mostly
;             used to regrid concentration data which shouldn't become
;             negative).
;
;        MAX_VALID -> the maximum valid data value that shall be accepted.
;             (see MIN_VALID). Default for MAX_VALID is 9.99E30.
;
;        /VERBOSE -> If set, will print totals before and after summing,
;             for testing/debugging purposes.
;
; OUTPUTS:
;        RESULT contains the regridded, summed data.
;
; SUBROUTINES:
;        References routines from the TOOLS package.
;
; REQUIREMENTS:
;        External Subroutines Required:
;        ==============================
;        PEDGE (function)    
;        ZMID  (function)
;        ZSTAR (function)
;
; NOTES:
;        (1) Pressure is converted to pressure-altitude units, which
;            are defined as:
;
;                 Z* = 16 * log10[ 1000 / P(mb) ]
;
;            which, by the laws of logarithms, is equivalent to:
;
;                 Z* = 48 - ( 16 * log10[ P(mb) ] ).
;
;        (2) SUMV only processes one column at a time.  One must loop 
;            over the surface grid boxes to process the entire globe.
;
;        (3) Re-verified that tracer is preserved. (bmy, 2/22/01)
;
; EXAMPLE:
;        POLD    = [ 900, 700, 500, 300 ]
;        PNEW    = [ 800, 400 ]
;        DATA    = FINDGEN( N_ELEMENTS( POLD ) ) + 1
;        NEWDATA = SUMV( DATA, POLD, PNEW )
;        print, NEWDATA
;            2.0000000       2.0000000
; 
;            ; Sums the data array from a grid with centers at 900,
;            ; 700, 500, and 300 mb to a grid with centers at
;            ; 800 and 400 mb.  Note that the total column sum in
;            ; both cases (which equals 4.0) is preserved.
;
; MODIFICATION HISTORY:
;        bmy, 01 Jul 1999: VERSION 1.00
;        bmy, 25 Jan 2001: TOOLS VERSION 1.47
;                          - add ZEDGE_OLD keyword
;                          - renamed ZEDGE to ZEDGE_NEW
;                          - compute the boxheights on the new grid
;                            given the boxheights on the old grid
;                          - print totals if /VERBOSE is set
;        bmy, 22 Feb 2001: - substantial rewrite -- now loop over the
;                            vertical layers on the new grid first
;
;-
; Copyright (C) 1999, 2001, 
; Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine sumv"
;-------------------------------------------------------------


function SumV, Data, POld, PNew,                           $
               PSurf=PSurf,          BoxHeight=BoxHeight,  $
               ZEdge_Old=ZEdge_Old,  ZEdge_New=ZEdge_New,  $
               Min_Valid=Min_Valid,  Max_Valid=Max_Valid,  $
               Verbose=Verbose,      _EXTRA=e
            
   ;====================================================================
   ; Error Checking / Keyword Settings
   ;====================================================================    
   FORWARD_FUNCTION PEdge, ZMid, ZStar
 
   ; Missing DATA vector
   if ( N_Elements( Data ) eq 0 ) then begin
      Message, 'Must supply the DATA vector!!', /Continue
      return, -1.0
   endif
 
   ; Missing POLD vector AND missing ZEDGE_OLD keyword!
   if ( N_Elements( POld ) eq 0 ) then begin

      ; if ZEDGE_OLD isn't supplied, then one must supply POLD (bmy, 1/11/01)
      if ( N_Elements( ZEdge_OLD ) eq 0 ) then begin
         Message, 'Must supply either POLD or ZEDGE_OLD!', /Continue
         return, -1.0
      endif
   endif
 
   ; Missing PNEW structure AND Missing ZEDGE_NEW keyword!
   if ( N_Elements( PNew ) eq 0 ) then begin
      if ( N_Elements( ZEdge_NEW ) eq 0 ) then begin
         Message, 'Must supply either PNEW or ZEDGE_NEW!!', /Continue
         return, -1.0 
      endif
   endif
      
   ; Missing BOXHEIGHT vector -- assume that the box heights
   ; do not matter, so set them all to 1.0
   if ( N_Elements( BoxHeight ) eq 0 ) then begin
      Message, 'Assuming unit box heights!!',  /Continue      
      N_Levels  = N_Elements( Zedge_Old ) > N_Elements( P_Old )
      BoxHeight = FltArr( N_Levels ) + 1.0
   endif
  
   if ( N_Elements( Min_Valid ) ne 1 ) then Min_Valid = 0.0
   if ( N_Elements( Max_Valid ) ne 1 ) then Max_Valid = 9.99E30
   if ( N_Elements( PSurf     ) eq 0 ) then PSurf     = [ 1000.0, 1000.0 ]
   if ( N_Elements( PSurf     ) eq 1 ) then PSurf     = [ PSurf,  PSurf  ]
 
   ;====================================================================
   ; OLDZMID  = Pressure-altitude centers of old grid
   ; OLDZEDGE = Pressure-altitude edges   of old grid
   ;====================================================================
   if ( N_Elements( POld ) gt 0 ) then begin
      OldZMid  = ZStar( POld                    )
      OldZEdge = ZStar( PEdge( POld, PSurf[0] ) ) 
   endif

   ; Now can take OLDZEDGE from the ZEDGE_OLD keyword (bmy, 1/11/01)
   if ( N_Elements( ZEdge_Old ) gt 0 ) then begin
      OldZEdge = ZEdge_Old
      OldZMid  = ZMid( ZEdge_Old )
   endif

   ;====================================================================
   ; If pressure-altitudes are passed via the ZEDGE keyword, then
   ; use them to define the output grid.  Make sure ZEDGE starts with 0.
   ;
   ; Otherwise, compute the pressure-altitudes corresponding 
   ; to the Sigma Centers and Sigma Edges of the new grid.  
   ;====================================================================
   if ( N_Elements( ZEdge_New ) gt 0 ) then begin
      NewZEdge = Double( ZEdge_New )
      NewZMid  = ZMid( NewZEdge )
 
   endif else begin
      NewZMid  = ZStar( PNew                 )
      NewZEdge = ZStar( PEdge( PNew, PSurf ) )
 
   endelse

   ;====================================================================
   ; Loop over each of the new vertical layers.  Find the 
   ;
   ; Use the pressure-altitudes to compute the fraction of each 
   ; original box that lies within each new output box.  Multiply the
   ; data in each original box by that fraction and sum together.
   ;
   ; NOTE: This is now a more robust algorithm.  The extra looping
   ;       might cause it to take longer, but the regridding will
   ;       be done correctly.
   ;====================================================================
   NewLevels = N_Elements( NewZMid )
   NewBxHt   = DblArr( NewLevels )
   NewData   = DblArr( NewLevels )
 
   ; Loop over vertical layers on new grid
   for N = 0L, N_Elements( NewZMid ) - 1L do begin

      ; Get bottom and top edges of the new grid
      NewBotEdge = NewZEdge[N]
      NewTopEdge = NewZEdge[N+1]

      ; Loop over vertical layers on old grid
      for J = 0L, N_Elements( Data ) - 1L do begin

         ; Parameters for old grid
         FData      = Double( Data[J]        )  
         FBoxHt     = Double( BoxHeight[J]   )
         OldBotEdge = Double( OldZEdge[J]    )
         OldTopEdge = Double( OldZEdge[J+1]  )

         ; Take care of MIN_VALID and MAX_VALID
         if ( FData lt Min_Valid ) then FData = Min_Valid
         if ( FData gt Max_Valid ) then FData = Max_Valid

         ;=============================================================
         ; Case #0: Old box is above new box entirely -- skip
         ;=============================================================
         if ( OldBotEdge gt NewTopEdge ) then goto, NextJ

         ;=============================================================
         ; Case #1: Old box is entirely contained in new box
         ;=============================================================
         if ( OldBotEdge ge NewBotEdge   AND $
              OldBotEdge le NewTopEdge   AND $
              OldTopEdge gt NewBotEdge   AND $ 
              OldTopEdge lt NewTopEdge ) then begin  

            NewData[N] = NewData[N] + ( FData * FBoxHt )
            NewBxHt[N] = NewBxHt[N] + FBoxHt

            goto, NextJ
         endif

         ;=============================================================
         ; Case #2: New Box is contained entirely in old box
         ;=============================================================
         if ( NewBotEdge ge OldBotEdge   AND  $
              NewBotEdge le OldTopEdge   AND  $
              NewTopEdge gt OldBotEdge   AND  $
              NewTopEdge lt OldTopEdge ) then begin

            Frac       = ( NewTopEdge - NewBotEdge ) / $
                         ( OldTopEdge - OldBotEdge )

            NewData[N] = NewData[N] + ( FData * FBoxHt * Frac )
            NewBxHt[N] = NewBxHt[N] + ( FBoxHt * Frac         )

            goto, NextN
         endif

         ;=============================================================
         ; Case #3: Top of old box is in new box
         ;=============================================================
         if ( OldBotEdge le NewBotEdge   AND $
              OldBotEdge le NewTopEdge   AND $
              OldTopEdge gt NewBotEdge   AND $
              OldTopEdge lt NewTopEdge ) then begin
 
            Frac       = ( OldTopEdge - NewBotEdge ) / $
                         ( OldTopEdge - OldBotEdge ) 

            NewData[N] = NewData[N] + ( FData * FBoxHt * Frac )
            NewBxHt[N] = NewBxHt[N] + ( FBoxHt * Frac )

            goto, NextJ
         endif

         ;=============================================================
         ; Case #4: Bottom of old box is in new box
         ;=============================================================
         if ( OldBotEdge ge NewBotEdge   AND $
              OldBotEdge le NewTopEdge   AND $
              OldTopEdge gt NewBotEdge   AND $
              OldTopEdge gt NewTopEdge ) then begin

            Frac       = ( NewTopEdge - OldBotEdge ) / $
                         ( OldTopEdge - OldBotEdge ) 
            
            NewData[N] = NewData[N] + ( FData * FBoxHt * Frac )
            NewBxHt[N] = NewBxHt[N] + ( FBoxHt * Frac )

            goto, NextJ
         endif
    
NextJ:
      endfor

NextN:
   endfor
   
   ;====================================================================
   ; Return NEWDATA to calling program
   ;====================================================================
Quit:
   
   ; Print totals if /VERBOSE is set
   if ( Keyword_Set( Verbose ) ) then begin
      S1 = 'Total(OLD): ' + $
         StrTrim( String( Total( BoxHeight * Data ), Format='(e13.6)' ), 2 )
      
      S2 = 'Total(NEW): ' + $
         StrTrim( String( Total( NewData ), Format='(e13.6)' ), 2 )

      Message, S1, /Info
      Message, S2, /Info
   endif

   ; Divide by the new boxheights -- avoid divide by zero errors
   Ind = Where( NewBxHt gt 0 )
   if ( Ind[0] ge 0 ) then NewData[Ind] = NewData[Ind] / NewBxHt[Ind]

   ; Return Newdata
   return, NewData
 
end
