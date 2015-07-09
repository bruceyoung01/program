pro rjp_ct, R, G, B, NoLoad=NoLoad, NColors=NColors, _EXTRA=e
   
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
   R = [   0,   0,   0,   0,   0,   0,  17,  97, 178, $
         255, 255, 255, 255, 255, 248, 170]
 
   ; Green
   G = [   0,  21,  83, 145, 207, 255, 255, 255, 255, $
         251, 189, 127,  65,   3,   0,   0]
 
   ; Blue
   B = [ 255, 255, 255, 255, 255, 243, 160,  79,   0, $
           0,   0,   0,   0,   0,   0,   0]
 
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
   if ( Load ) then TvLct, R, G, B
 
   ; Quit
   return
end
