; $Id: triangle.pro,v 1.1 2007/11/19 19:08:02 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        TRIANGLE
;
; PURPOSE:
;        Converts a vector with corner coordinates into X and Y 
;        vectors for a triangle shape.  The output vectors can be 
;        used with PLOTS, POLYFILL, or similar IDL plotting commands.
;     
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        TRIANGLE, CORNERS, XVEC, YVEC [, Keywords ]
;
; INPUTS:
;        CORNERS -> A 1-D vector with [ X0, Y0, X1, Y1 ] coordinates.
;             (X0,Y0) is the bottom left corner of the plot region and
;             (X1,Y1) is the top right corner of the plot region.
;
; KEYWORD PARAMETERS:
;        EXPAND -> A value that will be used to expand the size 
;             of the triangle by the same amount on all sides.
;             Default is 0.
; 
; OUTPUTS:
;        XVEC -> A 1-D vector with the X-coordinates listed in the
;             proper order for the POLYFILL or PLOTS commands.
; 
;        YVEC -> A 1-D vector with the X-coordinates listed in the
;             proper order for the POLYFILL or PLOTS commands.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:         
;        ; Get a plot position vector from MULTIPANEL
;        MULTIPANEL, 2, POSITION=POSITION
;        PRINT, POSITION
;             0.112505   0.0874544  0.466255  0.956280
;
;        ; Convert to X and Y vectors for PLOTS input
;        TRIANGLE, POSITION, XPOINTS, YPOINTS
;        PRINT, XPOINTS
;             0.112505   0.466255   0.466255  0.112505  0.112505
;        PRINT, YPOINTS
;             0.0874544  0.0874544  0.956280  0.956280  0.0874544
;
;        ; Call PLOTS to draw a box
;        PLOTS, XPOINTS, YPOINTS, THICK=2, COLOR=1, /NORMAL
;
; MODIFICATION HISTORY:
;        cdh, 19 Nov 2007: GAMAP VERSION 2.11
;                          - Adapted from "rectangles.pro"
;
;-
; Copyright (C) 2007, Chris Holmes,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine triangle"
;-----------------------------------------------------------------------


pro Triangle, Corners, XVec, YVec, Expand=Expand, $
              Left=Left, Right=Right, Up=Up, Down=Down

   ;====================================================================
   ; Initialiation
   ;====================================================================

   ; Keywords
   Left  = Keyword_Set( Left )
   Right = Keyword_Set( Right )
   Up    = Keyword_Set( Up )
   Down  = Keyword_Set( Down )

   ; Set UP as the default
   If ( Left + Right + Down ) eq 0 Then Up = 1

   ; Define output vectors
   xvec = [ 0 ]
   yvec = [ 0 ]
 
   ; Exit if less than 4 corners provided
   if ( N_Elements( Corners ) ne 4 ) then return
   
   ; Default value for EXPAND
   if ( N_Elements( Expand  ) eq 0 ) then Expand = 0.
 
   ;====================================================================
   ; Create vectors
   ;====================================================================

   if ( Up ) then begin

      ;-----------------------------
      ; Triangle pointing upward
      ;-----------------------------

      ; X Coordinate of triangle point
      Point = ( Corners[0] + Corners[2] ) / 2. 

      ; Vector of X-coordinates, in proper order for PLOTS, POLYFILL, etc
      XVec = [ Corners[0]-Expand, Corners[2]+Expand,                    $
               Point, Corners[0]-Expand ]

     ; Vector of Y-coordinates, in proper order for PLOTS, POLYFILL, etc
      YVec = [ Corners[1]-Expand, Corners[1]-Expand,                    $
               Corners[3]+Expand, Corners[1]-Expand ]

   endif else if ( Down ) then begin

      ;-----------------------------
      ; Triangle pointing downward
      ;-----------------------------

      ; X Coordinate of triangle point
      Point = ( Corners[0] + Corners[2] ) / 2. 

      ; Vector of X-coordinates, in proper order for PLOTS, POLYFILL, etc
      XVec = [ Corners[0]-Expand, Corners[2]+Expand,                    $
               Point, Corners[0]-Expand ]

      ; Vector of Y-coordinates, in proper order for PLOTS, POLYFILL, etc
      YVec = [ Corners[3]+Expand, Corners[3]+Expand,                    $
               Corners[1]-Expand, Corners[3]+Expand ]

   endif else if ( Right ) then begin

      ;-----------------------------
      ; Triangle pointing rightward
      ;-----------------------------

      ; Y Coordinate of triangle point
      Point = ( Corners[1] + Corners[3] ) / 2. 

      ; Vector of X-coordinates, in proper order for PLOTS, POLYFILL, etc
      XVec = [ Corners[0]-Expand, Corners[2]+Expand,                    $
               Corners[0]-Expand, Corners[0]-Expand ]

      ; Vector of Y-coordinates, in proper order for PLOTS, POLYFILL, etc
      YVec = [ Corners[1]-Expand, Point,                                $ 
               Corners[3]+Expand, Corners[1]-Expand ]
       
   endif else begin

      ;-----------------------------
      ; Triangle pointing leftward
      ;-----------------------------

      ; Y Coordinate of triangle point
      Point = ( Corners[1] + Corners[3] ) / 2. 

      ; Vector of X-coordinates, in proper order for PLOTS, POLYFILL, etc
      XVec = [ Corners[2]+Expand, Corners[2]+Expand,                    $
               Corners[0]-Expand, Corners[2]+Expand ]

      ; Vector of Y-coordinates, in proper order for PLOTS, POLYFILL, etc
      YVec = [ Corners[1]-Expand, Corners[3]+Expand,                    $
               Point,             Corners[1]-Expand ]
       
   endelse

   ; Exit
   return
end
 
