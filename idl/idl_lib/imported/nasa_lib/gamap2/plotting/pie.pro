; $Id: pie.pro,v 1.1.1.1 2007/07/17 20:41:50 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PIE
;
; PURPOSE:
;	 This procedure plots a pie chart.
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;	 PIE, DATA
;
; INPUTS:
;	 DATA -> The data vector to be plotted in the pie chart.
;
; KEYWORD PARAMETERS:
;	 BORDERCOLOR -> The color of the circumference line of the 
;             pie chart. The default is the background color.
;
;	 BORDERTHICK -> The thickness of the circumference line of 
;             the pie chart.
;
;	 COLORS -> A vector containing the color table for the 
;             pie slices.
;
;	 DATA ->  If set, the plot is done in data coordinates.  
;             The default is normal coordinates.
;
;	 DEVICE ->  If set, the plot is done in device coordinates.  
;             The default is normal coordinates.
;
;	 NORMAL -> If set, the plot is done in normal coordinates.  
;             This is the default.
;
;	 NPOINTS ->  The total number of points to be used for 
;             defining all of the arcs, measured around the 
;             circumference.
;
;	 XPOS, YPOS ->  The [X,Y] coordinates of the centre of the 
;             pie chart.
;
;	 RADIUS -> The radius of the pie chart.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
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
;	 PIE, [2,3,4,5]
;
;	      ; Make a pie chart of the values 2, 3, 4, and 5.
;
; MODIFICATION HISTORY:
;	 Written by: Edward C. Wiebe, 1998-02-05.
;	 Modified:   Daithi A. Stone (stoned@atm.ox.ac.uk), 2002-04-12 
;		     (re-wrote, added documentation)
;	 Modified:   DAS, 2005-08-05 (replaced SUM.PRO use with TOTAL; 
;		     removed CONSTANTS.PRO use)
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - updated comments
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
; or phs@io.harvard.edu with subject "IDL routine pie" 
;-----------------------------------------------------------------------

PRO PIE, $
         Data, $
         BORDERCOLOR=bordercolor, BORDERTHICK=borderthick, $
         COLORS=colors, $
         DATA=dataopt, DEVICE=deviceopt, NORMAL=normalopt, $
         NPOINTS=npoints, $
         XPOS=xpos, YPOS=ypos, $
         RADIUS=radius

   ;***********************************************************************
   ; Constants, Variables, and Options

   ; Constants
   pi = !pi

   ; Data vector size
   ndata = n_elements( data )

   ; Data vector sum
   sumdata = total( data )

   ;Number of points for drawing the circle
   if keyword_set( npoints ) then begin
      if sumdata / min( data ) gt npoints then begin
         npoints = round( sumdata / min( data ) )
      endif
   endif else begin
      npoints = max( [ 100, round( sumdata / min( data ) ) ] )
   endelse

   ;The points vector
   points = indgen( npoints )

   ;Color table
   if not( keyword_set( colors ) ) then colors = indgen( ndata ) + 2
 
   ;Border circle

   ;Color
   if not( keyword_set( bordercolor ) ) then bordercolor = !p.background

   ;Thickness
   if not( keyword_set( borderthick ) ) then borderthick = 1

   ;Position and dimension
   if not( keyword_set( xpos ) ) then xpos = 0.5
   if not( keyword_set( ypos ) ) then ypos = 0.5
   if not( keyword_set( radius ) ) then radius = 0.4

   ;Plotting coordinate system
   dataopt = keyword_set( dataopt )
   deviceopt = keyword_set( deviceopt )
   normalopt = keyword_set( normalopt )
   if not( dataopt ) and not( deviceopt ) then normalopt = 1

   ;***********************************************************************
   ;Create Pie Graph

   ;Calculate arc coordinates
   arcs = data
   for i = 1, ndata-1 do arcs[i] = data[i] + total( data[0:i-1] )
   arcs = 1. * arcs * ( npoints - 1. ) / max( arcs )
   
   ;Plots pie slices
   for i = 0, ndata-1 do begin
      if i eq 0 then id0 = 0. $
      else id0 = (where( points eq round( arcs[i-1] ) ))[0]
      id1 = (where( points eq round( arcs[i] ) ))[0]
      arc = points[id0:id1] / ( npoints - 1. ) * 2. * pi
      x = [ xpos, radius * cos( arc ) + xpos, xpos ]
      y = [ ypos, radius * sin( arc ) + ypos, ypos ]
      polyfill, x, y, data=dataopt, device=deviceopt, normal=normalopt, $
         color=colors[i]
   endfor

   ;Border
   plots, circle( xpos, ypos, radius, npoints ), $
      color=bordercolor, thick=borderthick, $
      data=dataopt, device=deviceopt, normal=normalopt
   
   ;***********************************************************************
   ;The End

   return
END
