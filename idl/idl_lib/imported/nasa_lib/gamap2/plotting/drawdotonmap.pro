; $Id: drawdotonmap.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        DRAWDOTONMAP
;
; PURPOSE:
;        Draws a dot atop a world map, in order to highlight a given
;        (lat,lon) location.  Also prints a label next to the point,
;        and draws a line from the point to the label.
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        DRAWDOTONMAP, X, Y, R, THETA, NAME, COLOR  [, ALIGN=ALIGN ]
;
; INPUTS:
;        X -> Longitude of the point to be drawn (degrees)
;
;        Y -> Latitude of the point to be drawn (degrees)
;
;        R -> Radius (in degrees) of the line that will extend from
;             the point to the the label.
;
;        THETA -> Angle (in the trigonometric sense, 0=due east) 
;             which specifies the direction of the line that will
;             connect the plot label to the point.
;
;        NAME -> String for the plot label.  Default is ''.
;
;        COLOR -> Color of the point to be plotted.  Default 
;             is !MYCT.BLACK.  
;
;
; KEYWORD PARAMETERS:
;        ALIGN -> Specifies the alignment of NAME.  Works in the same
;             way as the ALIGN keyword to XYOUTS (e.g. ALIGN=0 is
;             left-justified, ALIGN=0.5 is centered, ALIGN=1 is 
;             right-justified).
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        SYM (function)
;
; REQUIREMENTS:
;        Assumes that we are using a MYCT-defined colortable.
;
; NOTES:
;        None
;
; EXAMPLE:
;        MAP_SET, LIMIT=[ 10, -140, 55,-40 ], GRID=0, $
;             COLOR=!MYCT.BLACK, /CYL, /NOBORDER
;
;        MAP_CONTINENTS, /COUNTRIES, /COASTS, $
;             COLOR=!MYCT.BLACK, /USA
;
;        DRAWDOTONMAP, -71, 42, 3, 0, 'Harvard', !MYCT.RED
;
;             ; Draws a USA map and then plots a dot at the (lat,lon) 
;             ; of Harvard University.  The label will be plotted 3
;             ; units away along THETA=0 (due east).
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine drawdotonmap"
;-----------------------------------------------------------------------


pro DrawDotOnMap, X, Y, R, Theta, Name, Color, Align=Align
 
   ;====================================================================
   ; Internal routine GCM_DRAWDOT draws a dot of a given color atop a 
   ; world map.  It also draws a line from the dot to a name at a
   ; given (R,THETA) angle. 
   ;====================================================================
 
   ; Arguments
   if ( N_Elements( R     ) eq 0 ) then R     = 0
   if ( N_Elements( Theta ) eq 0 ) then Theta = 0
   if ( N_Elements( Name  ) eq 0 ) then Name  = ''
   if ( N_Elements( Color ) eq 0 ) then Color = !MYCT.BLACK
   if ( N_Elements( Align ) eq 0 ) then Align = 0
 
   ; Convert degrees to radians
   D2R  = 3.141592658979323d0 / 180d0
 
   ; Symbol size
   SymS = 1.2
 
   ; Get ending coords of the arrow
   X1   = X + ( R * Cos( Theta * D2R ) )
   Y1   = Y + ( R * Sin( Theta * D2R ) )
 
   ; Set X and Y offsets
   XOff = +0.25
   YOff = -0.25
 
   if ( Align eq 0.5 ) then begin
      XOff = 0.0
      if ( Theta gt  75 and Theta lt 135 ) then YOff = +0.25
      if ( Theta eq  90                  ) then YOff = +0.25
      if ( Theta eq -90                  ) then YOff = -0.25
   endif
 
   if ( Align eq 1.0 ) then begin
      XOff = -0.25
      if ( Theta eq  90 ) then YOff = +0.25
      if ( Theta eq -90 ) then YOff = -0.25
   endif
 
   ; Plot colored circle at (X,Y) lon and lat
   PlotS, X, Y, /Data, PSym=Sym(1), SymS=SymS, Color=Color
 
   ; Plot black open circle at (X,Y) lon and lat
   PlotS, X, Y, /Data, PSym=Sym(6), SymS=SymS, Color=!MYCT.BLACK    
 
   ; Plot a line from (X,Y) to (X1,Y1)
   Oplot, [X,X1], [Y,Y1], LineStyle=0, Color=!MYCT.BLACK, Thick=1
 
   ; Plot the name on the map at (X1,Y1)
   XYOutS, X1+Xoff, Y1+YOff, Name, Align=Align, Color=!MYCT.BLACK, _EXTRA=e
 
end
