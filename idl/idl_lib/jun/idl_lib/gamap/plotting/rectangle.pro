; $Id: rectangle.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        RECTANGLE
;
; PURPOSE:
;        Converts a vector with corner coordinates into X and Y 
;        vectors that can be used with PLOTS, POLYFILL, or similar
;        IDL plotting commands.
;     
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        RECTANGLE, CORNERS, XVEC, YVEC [, Keywords ]
;
; INPUTS:
;        CORNERS -> A 1-D vector with [ X0, Y0, X1, Y1 ] coordinates.
;             (X0,Y0) is the bottom left corner of the plot region and
;             (X1,Y1) is the top right corner of the plot region.
;
; KEYWORD PARAMETERS:
;        EXPAND -> A value that will be used to expand the size 
;             of the rectangle by the same amount on all sides.
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
;        RECTANGLE, POSITION, XPOINTS, YPOINTS
;        PRINT, XPOINTS
;             0.112505   0.466255   0.466255  0.112505  0.112505
;        PRINT, YPOINTS
;             0.0874544  0.0874544  0.956280  0.956280  0.0874544
;
;        ; Call PLOTS to draw a box
;        PLOTS, XPOINTS, YPOINTS, THICK=2, COLOR=1, /NORMAL
;
; MODIFICATION HISTORY:
;        mgs, 13 Apr 1998: INITIAL VERSION
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments, cosmetic changes
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine rectangle"
;-----------------------------------------------------------------------


pro Rectangle, Corners, XVec, YVec, Expand=Expand
 
   ; Define output vectors
   xvec = [ 0 ]
   yvec = [ 0 ]
 
   ; Exit if less than 4 corners provided
   if ( N_Elements( Corners ) ne 4 ) then return
   
   ; Default value for EXPAND
   if ( N_Elements( Expand  ) eq 0 ) then Expand = 0.
 
   ; Vector of X-coordinates, in proper order for PLOTS, POLYFILL, etc
   XVec = [ Corners[0]-Expand, Corners[2]+Expand,                    $
            Corners[2]+Expand, Corners[0]-Expand, Corners[0]-Expand ]

   ; Vector of Y-coordinates, in proper order for PLOTS, POLYFILL, etc
   YVec = [ Corners[1]-Expand, Corners[1]-Expand,                    $
            Corners[3]+Expand, Corners[3]+Expand, Corners[1]-Expand ]
 
   ; Exit
   return
end
 
