; $Id: org_corr.pro,v 1.1.1.1 2003/10/22 18:09:41 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ORG_CORR
;
; PURPOSE:
;        Calculate reduced major axis.  Given two vectors X and Y, this
;        subroutine computes the Gradient and Y intercept of the line 
;        given by the reduced major axis.  The main advantage of this 
;        is that the best fit line of X and Y will be the same as the 
;        best fit line of Y and X.
;
; CATEGORY:
;        Line Fitting 
;
; CALLING SEQUENCE:
;        ORG_CORR, X, Y, R, NP, GRADIENT, INTERCEPT,            $
;                  GRADIENT_ERR, INTERCEPT_ERR [, VERBOSE=VERBOSE ]
;
; INPUTS:
;        X -> Vector containing X-axis values.
;
;        Y -> Vector containing Y-axis values.
;
;        R -> Correlation coefficient
; 
;        NP -> Number of elements of X and Y arrays to process. 
;             NP should be smaller than or equal to the number of
;             elements of X and Y.
;
; KEYWORD PARAMETERS:
;        /VERBOSE -> Set this switch to print the gradient,
;             intercept, and standard errors to the screen.   
;             The default is not to print these values.
;
; OUTPUTS:
;        GRADIENT -> Gradient of reduced major axis
;
;        INTERCEPT -> Y-Intercept of reduced major axis
;  
;        GRADIENT_ERR -> Standard error in gradient.
;
;        INTERCEPT_ERR -> Standard error in Y-intercept.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        SIGN (function)
;
; REQUIREMENTS:
;        References routines from the TOOLS package.
;
; NOTES:
;        (1) More details are in Hirsch and Gilroy, Water Res. Bull., 
;            20(5), Oct 1984.
;
;        (2) Standard errors also calculated according to Miller and 
;            Kahn, Statistical Analysis in the Geological Sciences,
;            1962, pp. 204-210.
;
;        (3) Computations are now performed in double precision.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;  pip, clh, bmy, 10 Oct 2002: TOOLS VERSION 1.52
;
;-
; Copyright (C) 2002, Paul Palmer, Colette Heald, 
; and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine org_corr"
;-----------------------------------------------------------------------


pro Org_Corr, X, Y, R, Np, Gradient, Intercept, $
              Gradient_Err, Intercept_Err, Verbose=Verbose
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION Sign

   ; Keyword Settings
   if ( N_Elements( X  ) eq 0 ) then Message, 'X not passed!'
   if ( N_Elements( Y  ) eq 0 ) then Message, 'Y not passed!'
   if ( N_Elements( R  ) eq 0 ) then Message, 'R not passed!'
   if ( N_Elements( Np ) eq 0 ) then Message, 'NP not passed!'
   
   ; Check to see if Np is greater than the size of X and Y
   if ( Np gt N_Elements( X ) ) then Message, 'NP is too large for X!'
   if ( Np gt N_Elements( Y ) ) then Message, 'NP is too large for Y!'

   ; Convert NP to double precision
   Dnp = Double( Np )

   ;====================================================================
   ; Compute gradient and gradient error
   ;====================================================================

   ; Sign of R (-1,0,+1)
   Fac  = Double( Sign( R ) )

   ; Compute average X, Y
   Xbar = Total( X[0:Np-1L] ) / Dnp
   Ybar = Total( Y[0:Np-1L] ) / Dnp
  
   ; Compute std devation of X and Y
   Sx = 0.0d0
   Sy = 0.0d0

   for I = 0L, Np-1L do begin
      Sx = Sx + ( X(I) - XBar )^2d0
      Sy = Sy + ( Y(I) - YBar )^2d0
   endfor

   Sx = Sqrt( Sx / Dnp )
   Sy = Sqrt( Sy / Dnp )
 
   ; Compute modified Y-axis
   YNew = Y

   for I = 0L, Np-1L Do Begin
      YNew(I) = YBar + ( Fac * ( Sy/Sx ) * ( X(I) - XBar ) )
   endfor
 
   ; Compute gradient and gradient error
   Gradient      = ( YNew[0] - YNew[Np-1L] ) / ( X[0] - X[Np-1L] )
   Gradient_Err  = ( Sy/Sx ) * Sqrt( ( 1d0 - R^2 ) / Dnp )

   ; Compute intercept and intercept error
   Intercept     = YBar + ( Fac * ( Sy/Sx ) * ( -XBar ) )
   Intercept_Err = Sy * Sqrt( ( 1d0 - R^2 ) / Dnp * ( 1 + Xbar^2/Sx^2 ) ) 
 
   ;====================================================================
   ; If /VERBOSE is set, then print values to screen
   ;====================================================================
   if ( Keyword_Set( Verbose ) ) then begin

      ; Gradient and error
      S = 'Gradient    : '                                        + $
          StrTrim( String( Gradient,      Format='(f20.5)' ), 2 ) + $
          ' +/- '                                                 + $
          StrTrim( String( Gradient_Err,  Format='(f20.5)' ), 2 )

      Message, S, /Info

      ; Intercept and error
      S = 'Y-Intercept : '                                        + $
          StrTrim( String( Intercept,     Format='(f20.5)' ), 2 ) + $
          ' +/- '                                                 + $
          StrTrim( String( Intercept_Err, Format='(f20.5)' ), 2 )

      Message, S, /Info

   endif
end
 
 
