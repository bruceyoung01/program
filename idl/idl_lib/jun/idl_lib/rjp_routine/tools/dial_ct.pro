; $Id: dial_ct.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        DIAL_CT
;
; PURPOSE:
;        Produces DIAL LIDAR colortable of Ed Browell et al, at either
;        native resolution (26 colors) or extended resolution.
;        
; CATEGORY:
;        Color Table Manipulation
;
; CALLING SEQUENCE:
;        DIAL_CT, R, G, B [ , Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        NCOLORS -> The number of colors that you would like to be
;             included in the colortable.  If NCOLORS is greater than
;             27, then DIAL_CT will interpolate to produce a finer
;             gradation of colors.  
;
;        /NOLOAD -> If set, then DIAL_CT will just return R, G, B
;             to the calling program without loading the colortable.
;
; OUTPUTS:
;        R -> Returns to the calling program the red color
;             vector that defines the DIAL colortable.
;
;        G -> Returns to the calling program the green color
;             vector that defines the DIAL colortable.
;
;        B -> Returns to the calling program the blue color
;             vector that defines the DIAL colortable.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1 ) For contour plots, the native resolution of 27 colors
;             should be sufficient.
;
;        (2 ) For smoothed pixel plots, NCOLORS=100 or higher will
;             eliminate the streaking caused by TVIMAGE's smoothing
;             algorithm.
;
; EXAMPLES:
;
;        DIAL_CT, NCOLORS=120
;
;             ; Loads the DIAL colortable w/ 120 colors
;        
;        DIAL_CT, R, G, B, /NOLOAD
;
;             ; Returns the red, green, blue color vectors for the
;             ; DIAL colortable at native resolution (27 colors)
;
; MODIFICATION HISTORY:
;        bmy, 26 Sep 2002: TOOLS VERSION 1.51
;
;-
; Copyright (C) 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine dial_ct"
;-----------------------------------------------------------------------


pro Dial_Ct, R, G, B, NoLoad=NoLoad, NColors=NColors, _EXTRA=e
   
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Load colortable or not?
   Load = 1L - Keyword_Set( NoLoad )

   ; Blank out all colors to white at first (if necessary)
   if ( Load ) then begin
      R = FltArr( 255 ) + 255
      G = FltArr( 255 ) + 255
      B = FltArr( 255 ) + 255
      TvLct, R, G, B
   endif
 
   ;====================================================================
   ; Color vectors for DIAL LIDAR instrument colortable -- 26 colors
   ; (Courtesy Ed Browell)  
   ;====================================================================
 
   ; Red
   R = [ 255, 221, 187, 153, 119, 178, 133,  89,  44, $
           0, 191, 143,  95,  47,   0, 255, 255, 255, $
         255, 255, 255, 216, 178, 140, 102,   0 ]
 
   ; Green
   G = [ 140, 111,  82,  54,  25, 255, 204, 153, 102, $
          51, 255, 255, 255, 255, 255, 255, 207, 159, $
         111,  63,   0,   0,   0,   0,   0,   0 ]
 
   ; Blue
   B = [ 255, 255, 255, 255, 255, 255, 255, 255, 255, $
         255, 191, 143,  95,  47,   0,   0,   0,   0, $
           0,   0,   0,  15,  31,  47,  63,   0 ]
 
   ; Original Number of colors
   N_Orig = N_Elements( R )
 
   ; Return number of colors if NCOLORS is not passed
   if ( N_Elements( NColors ) ne 1 ) then NColors = N_Orig
 
   ;====================================================================
   ; Expand colortable if NCOLORS is higher than N
   ;==================================================================== 
   if ( NColors gt N_Orig ) then begin
 
      ; Old and new abscissae
      X_Old = FindGen( N_Orig )
      X_New = FindGen( NColors ) * Float( N_Orig ) / NColors
 
      ; Increase number of colors from N_ORIG to N_COLORS
      R     = Fix( Interpol( Temporary( R ), X_Old, X_New ) + 0.5 )
      G     = Fix( Interpol( Temporary( G ), X_Old, X_New ) + 0.5 )
      B     = Fix( Interpol( Temporary( B ), X_Old, X_New ) + 0.5 )
 
      ; Fix color values to the range 0-255
      R     = ( Temporary( R ) < 255 ) > 0
      G     = ( Temporary( G ) < 255 ) > 0 
      B     = ( Temporary( B ) < 255 ) > 0
 
   endif
      
   ;====================================================================
   ; Load new color table (if necessary) 
   ;====================================================================
   if ( Load ) then TvLct, R_Dial, G_Dial, B_Dial
 
   ; Quit
   return
end
