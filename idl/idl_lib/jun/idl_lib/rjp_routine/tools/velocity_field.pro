; $Id: velocity_field.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-----------------------------------------------------------------------
;+             
; NAME:              
;        VELOCITY_FIELD          
;             
; PURPOSE:             
;        Overplots a 2-D velocity field atop a map or plot window.
;                            
; CATEGORY:             
;        Plotting, two-dimensional.             
;             
; CALLING SEQUENCE:             
;        VELOCITY_FIELD, U, V, X, Y [, keywords ]              
;             
; INPUTS:             
;        U -> The X component of the two-dimensional field.               
;             U must be a two-dimensional array.             
;             
;        V -> The Y component of the two dimensional field.  V must have    
;             the same dimensions as U.  The vector at point (i,j) has a    
;             magnitude of:             
;             
;                       [ U(i,j)^2 + V(i,j)^2 ]^0.5             
;             
;             and a direction of:             
;             
;                       ATAN2( V(i,j), U(i,j) ).             
;             
;        X -> Abcissae values.  X must be a vector with a length 
;             equal to the first dimension of U and V.
;
;        Y -> Ordinate values.  Y must be a vector with a length 
;             equal to the second dimension of U and V.
;             
; KEYWORD PARAMETERS:
;        MISSING -> Missing data high-cutoff value.  Vectors with a 
;             magnitude greater than MISSING are ignored.             
;
;        /DOTS -> If set, will place a dot at each missing data point.  
;             Otherwise, will draw nothing for missing data points.  
;             /DOTS only has effect if MISSING is specified.
;                          
;        X_STEP -> The X-extent of a cell in data coordinates.  If
;             X_STEP is not specified, then a VELOCITY_FIELD will
;             compute it as:
; 
;                X_STEP = ( Max(X) - Min(X) ) / ( N_Elements(X) - 1 )
;  
;             Where X is the array of abscissae as described above.
;
;        Y_STEP -> The X-extent of a cell in data coordinates.  If
;             X_STEP is not specified, then a VELOCITY_FIELD will
;             compute it as:
; 
;                Y_STEP = ( Max(Y) - Min(Y) ) / ( N_Elements(Y) - 1 )
;  
;             Where X is the array of ordinates as described above.
;      
;        COLOR -> Specifies the color of the arrows.  Default is black.
; 
;        HSIZE -> The length of the lines used to draw the arrowhead.
;             If HSIZE is positive, then the arrow head will be the
;             same regardless of the length of each vector.  (Default
;             size is !D.X_SIZE / 100).  If HSIZE is negative, then
;             the arrowhead will be 1/HSIZEth of the total arrow
;             length.
; 
;        LEGENDLEN -> Specify an arrow of a given length in DATA
;             coordinates displayed as a legend in the calling
;             routine.  Default is LONGEST. 
;
;        LEGENDNORM -> Returns to the calling program the length of
;             LEGENDLEN in NORMAL coordinates.  This is needed in
;             order to plot a legend arrow in the calling program.
;
;        LEGENDMAG -> Returns to the calling program the magnitude of
;             the vector of size LEGENDLEN.  Default is LONGEST.
;
;        _EXTRA=e -> Picks up all other keywords for PLOT, PLOTS, etc.
;
; OUTPUTS:             
;        None.             
;             
;
; SUBROUTINES:
;        Internal Subroutines:
;        =====================
;        VF_MAGNITUDE (function)
;
; NOTES:
;        (1) You need to call MAP_SET or PLOT first, to establish the
;            coordinate system.  VELOCITY_FIELD can only overplot
;            vectors atop of an existing map or plot window.
;           
;        (2) If you are calling VELOCITY_FIELD to overplot vectors
;            atop a world map, then in the calling program you must
;            make sure that the longitude values contained in the X
;            vector are in the range 0 - 360. 
;
;        (3) If you do not explicitly specify Y_STEP, and your grid
;            has half-size boxes at the poles, then the value of
;            Y_STEP computed by VELOCITY_FIELD might be different from
;            the actual latitude interval.
;
;        (4) VELOCITY_FIELD assumes that U, V, X, and Y are on a
;            regularly-spaced grid (e.g. longitude & latitude). 
; 
;        (5) Need to fix the drawing of the arrow heads at a later
;            date.  
; 
; RESTRICTIONS:             
;        None.
;
; CALLING SEQUENCE:             
;        VELOCITY_FIELD, U, V, X, Y, Thick=3, HSize=0.1
;
;             ; produces a velocity field plot with an arrow
;             ; thickness of 3 and a arrow head size of 10% of
;             ; the arrow body size.
;           
; MODIFICATION HISTORY:             
;        DMS, RSI, Oct., 1983.             
;        For Sun, DMS, RSI, April, 1989.             
;        Added TITLE, Oct, 1990.             
;        Added POSITION, NOERASE, COLOR, Feb 91, RES.             
;        August, 1993.  Vince Patrick, Adv. Visualization Lab, U. of Maryland, 
;                fixed errors in math.             
;        August, 1993. DMS, Added _EXTRA keyword inheritance.             
;
;        bmy, 03 Dec 1999: GAMAP VERSION 1.44
;                          - renamed to VELOCITY_FIELD
;                          - added ARRLEN, HSIZE, HANGLE, THICK keywords
;                          - cleaned up some things
;        bmy, 26 May 2000: GAMAP VERSION 1.45
;                          - updated comments, minor cleanup
;   bey, bmy, 24 Jul 2000: GAMAP VERSION 1.46
;                          - several bug fixes
;                          - added internal routine MAGNITUDE
;                          - added X_STEP, Y_STEP, MAXMAG keywords
;   sjg, bmy, 01 Aug 2000: - added error check on index array GOOD
;                          - now compare magnitudes to abs( MISSING )
;                          - now error check for MAXLEN: prevent div by 0
;                          - updated comments
;        bmy, 23 Jul 2002: GAMAP VERSION 1.51
;                          - now use IDL ARROW procedure to draw arrows
;                          - HSIZE is now defaulted to device coordinates
;                          - removed HANGLE keyword -- it's obsolete
;                          - now specify legend vector w/ LEGENDLEN
;                          - renamed ARRLEN to LEGENDNORM
;
;-             
; Copyright (C) 1999, 2000, 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine velocity_field"
;-----------------------------------------------------------------------    

function VF_Magnitude, U, V

   ;====================================================================
   ; Internal function MAGNITUDE computes the magnitude of a vector
   ; given its U and V components.
   ;====================================================================
   Result = Sqrt( U^2 + V^2 )

   return, Result
end

;-----------------------------------------------------------------------------

pro Velocity_Field, U, V, X, Y,                                 $
                    Missing=Missing,       Dots=Dots,           $
                    Color=Color,           Thick=TThick,        $
                    HSize=HSize,           X_Step=X_Step,       $
                    Y_Step=Y_Step,         LegendLen=LegendLen, $
                    LegendNorm=LegendNorm, LegendMag=LegendMag, $
                    _EXTRA=e

   ;====================================================================
   ; Error checking / Parameters
   ;====================================================================

   ; Size of U, V, X, Y arrays
   Su = Size( U, /Dim )
   Sv = Size( V, /Dim )
   Sx = Size( X, /Dim )
   Sy = Size( Y, /Dim )

   ; U must be a 2-D array
   if ( N_Elements( Su ) ne 2 ) then begin
      Message, 'U must be a 2-D array!', /Continue
      return
   endif

   ; V must be a 2-D array
   if ( N_Elements( Sv ) ne 2 ) then begin
      Message, 'U must be a 2-D array!', /Continue
      return
   endif

   ; X must be a 1-D vector
   if ( N_Elements( Sx ) ne 1 ) then begin
      Message, 'X must be a 1-D vector!', /Continue
      return
   endif

   ; Y must be a 1-D vector
   if ( N_Elements( Sy ) ne 1 ) then begin
      Message, 'Y must be a 1-D vector!', /Continue
      return
   endif

   ; Make Sx and Sy scalars for convenience
   Sx = Sx[0]
   Sy = Sy[0]

   ; Make sure U and V have the same # of columns and rows
   if ( ( Su[0] ne Sv[0] ) OR ( Su[1] ne Sv[1] ) ) then begin
      Message, 'U and V are not compatible with each other!', /Continue
      return
   endif

   ; If X is passed, make sure it has the same dimensions as U and V
   if ( Sx ne Su[0] ) then begin
      Message, 'X does not have the same longitude dimension as U and V!', $
         /Continue
      return
   endif

   ; If Y is passed, make sure it has the same dimensions as U and V
   if ( Sy ne Sv[1] ) then begin
      Message, 'Y does not have the same latitude dimension as U and V!', $
         /Continue
      return
   endif

   ;====================================================================
   ; Error checking / Keywords
   ;====================================================================
   if ( N_Elements( Missing ) eq 0 ) then Missing = 1.0e30   
   if ( N_Elements( Color   ) eq 0 ) then Color   = 1
   if ( N_Elements( TThick  ) eq 0 ) then TThick  = 2
   if ( N_Elements( HSize   ) eq 0 ) then HSize   = !D.X_SIZE / 100

   Dots = Keyword_Set( Dots )

   ;====================================================================
   ; MAG   = array of vector magnitudes at each point
   ; NBAD  = # of missing points (
   ;
   ; GOOD  = index of "good" points, where MAG <= MISSING
   ; BAD   = index of "bad"  points, where MAG >  MISSING
   ;
   ; UGOOD = Elements of U where MAG <= MISSING
   ; VGOOD = Elements of V where MAG <= MISSING
   ;
   ; If /DOTS is set, then dots instead of vectors will be
   ; plotted for the "bad" points, where MAG > MISSING.
   ;
   ; If MISSING is not passed, then all points are "good".
   ;====================================================================
   Mag  = VF_Magnitude( U, V )
   NBad = 0                     

   if ( N_Elements( Missing ) gt 0 ) then begin             
      Good = Where( Mag lt Abs( Missing ) )              
      if ( Dots ) then Bad = Where( Mag gt Abs( Missing ), NBad )             

   endif else begin             
      Good = LIndGen( N_Elements( Mag ) )             

   endelse             
   
   ; Exit if there are no "good" points left (bmy, 8/1/00)
   if ( Good[0] lt 0 ) then begin
      Message, 'No good points left -- check the value of MISSING!'
   endif

   ; "Good" data points
   UGood = U[Good]             
   VGood = V[Good]             

   ; MAG is now the magnitudes of the "good" data points
   Mag = VF_Magnitude( UGood, VGood )
   
   ;====================================================================
   ; X_STEP = X-extent of each grid box in data space (e.g. degrees lon) 
   ; Y_STEP = Y-extent of each grid box in data space (e.g. degrees lat)
   ;
   ; If X_STEP and Y_STEP are not passed as keywords, then 
   ; compute them from the X and Y array intervals below.
   ;====================================================================
   if ( N_Elements( X_Step ) eq 0 ) then begin
      X0     = Min( X, Max=X1 )
      X_Step = ( X1 - X0 ) / Float( Sx - 1 )
   endif

   if ( N_Elements( Y_Step ) eq 0 ) then begin
      Y0     = Min( Y, Max=Y1 )
      Y_Step = ( Y1 - Y0 ) / Float( Sy - 1 )     
   endif

   ;====================================================================
   ; Normalize UGOOD and VGOOD to the longest dimension of a grid box
   ;====================================================================
   MaxLen1 = Max( Abs( UGood ) / X_Step )  
   MaxLen2 = Max( Abs( VGood ) / Y_Step )

   ; MAXLEN is the largest value of (U/X) or (V/Y)
   ; e.g., winds divided by grid box dimension
   MaxLen  = Max( [ MaxLen1, MaxLen2 ] )

   ; Error check MAXLEN -- Prevent divide by zero and NaN values
   if ( MaxLen lt 1e-30 ) then begin
      Message, 'Division by zero error -- MAXLEN = 0!'
   endif

   ; SINA is UGOOD normalized to MAXLEN
   ; COSA is VGOOD normalized to MAXLEN
   SinA    = ( UGood / MaxLen )             
   CosA    = ( VGood / MaxLen )    

   ; NORMMAG are the magnitudes of the normalized vectors
   NormMag = VF_Magnitude( SinA, CosA )
 
   ;====================================================================
   ; For each of the "good" points, plot a vector
   ;====================================================================
   for I = 0L, N_Elements( Good ) - 1L do begin 

      ; Compute X-coords of start & end for each arrow 
      ; Get the X-coords from the GOOD array
      X0 = X[ Good[I] mod Su[0] ]  
      X1 = X0 + SinA[I]             

      ; Compute Y-coords of start & end for each arrow
      ; Get the Y-coords from the GOOD array
      Y0 = Y[ Good[I] / Sx ]             
      Y1 = Y0 + CosA[I]             

      ; Draw the arrows w/ the IDL ARROW routine
      Arrow, X0, Y0, X1, Y1, /Data, Color=Color, HSize=HSize, _EXTRA=e
      
   endfor             

   ;====================================================================
   ; If /DOTS is set, then plot a dot at each "bad" data point
   ;====================================================================
   if ( Dots ) then begin
      
      ; Loop over the bad data points
      for I = 0L, N_Elements( Bad ) - 1L do begin 

         ; Get X and Y coordinages for each "bad" data point
         X0 = X[ Bad[I] mod Sv[1] ]  
         Y0 = Y[ Bad[I] / Sy ]     
      
         ; Plot the dot (PSYM=3)
         PlotS, X0, Y0, Color=Color, Thick=Thick, PSym=3
      endfor
   endif

   ;====================================================================      
   ; Convert LEGENDLEN from data to normal coordinates, and return
   ; as LEGENDNORM.  Also return the magnitude of the vector as $
   ; LEGENDMAG.  This will allow the calling program to plot an
   ; arrow of the given size as a plot legend. (bmy, 7/23/02)
   ;====================================================================

   ; Set LEGENDLEN depending on if it is explicitly passed or not
   if ( N_Elements( LegendLen ) eq 1 ) then begin

      ; Set LEGENDMAG equal to LEGENDLEN
      LegendMag  = LegendLen

      ; Normalize LEGENDLEN to MAXLEN.  We don't want to
      ; exceed the length of a grid box on the plot.
      TmpLen     = LegendLen / MaxLen

   endif else begin

      ; LONGEST is longest normalized vector.  This should 
      ; be equal to one of the two grid box dimensions.
      Ind1       = Where( NormMag eq Max( NormMag ) )
      TmpLen     = NormMag[Ind1]

      ; LEGENDMAG is the value of the data corresponding to LONGEST
      Ind2       = Where( Mag eq Max( Mag ) )
      LegendMag  = Mag[Ind2]

   endelse

   ; Convert LEGENDLEN from DATA to NORMAL coords
   XX         = [ 0, TmpLen ]
   YY         = [ 0, 0      ]
   Result     = Convert_Coord( XX, YY, /Data, /To_Normal )
   X_Tmp      = Result[ 0, * ]
   LegendNorm = X_Tmp[1] - X_Tmp[0]

   return
end             
