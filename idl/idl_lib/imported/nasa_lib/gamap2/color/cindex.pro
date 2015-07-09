; $Id: cindex.pro,v 1.2 2008/04/21 19:23:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:		
;        CINDEX
;
; PURPOSE:	
;        This is a program for viewing the current colors in the 
;	 colortable with their index numbers overlayed on each color.
;        
;	 CINDEX Draws a NROW x NCOL set of small rectangles, each of 
;        which displays one of the colors in the color table.  It also
;        writes the color index number on top of each rectangle.
;
; CATEGORY:	
;        Color
;
; CALLING SEQUENCE:	
;        CINDEX
;
; INPUTS:	
;        None
;	
; KEYWORD PARAMETERS:
;        NCOL -> Specify the number of columns in the plot. 
;             Default is 16.
;
;        NROW -> Specify the number of columns in the plot.  If not 
;             specified, then CINDEX will compute the minimum number
;             of rows that are needed to display all of the colors,
;             given the setting of NCOL.
;
;        TITLE -> Specify the title for the plot window.
;
;        /ALL -> Set this switch to plot all 256 colors on a 16x16 grid.
;             Colors that are not defined will be rendered as white.
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
; EXAMPLES:
;        (1)
;        MYCT, /WhGrYlRd
;        CINDEX
; 
;             ; Displays the colors of the MYCT color table
;             ; WHITE-GREEN-YELLOW-RED (spectral).  The drawing
;             ; colors and all 20 colors of this table are shown.
;
;        (2)
;        MYCT, /WhGrYlRd
;        CINDEX, /ALL
; 
;             ; Same as above, but plots the colors on a 
;             ; 16 x 16 grid.
;
; MODIFICATION HISTORY:  
;        INITIAL REVISION: David Fanning, RSI, May 1995
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Added NCOL, ROW, TITLE, ALL keywords to
;                            allow the user to specify these settings
;                            instead of having these be hardwired.
;        bmy, 21 Apr 2008: GAMAP VERSION 2.12
;                          - Now use NAME and INDEX tags from !MYCT 
;                            to define the default title string.
;
;-
; Copyright (C) 1995-2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine cindex"
;-----------------------------------------------------------------------


pro CIndex, NCol=NCol, NRow=NRow, Title=Title, All=All, _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Default # of columns
   if ( N_Elements( NCol ) ne 1 ) then NCol = !MYCT.BOTTOM 
  
   ; Default # of rows (just leave enough room for colors)
   if ( N_Elements( NRow ) ne 1 ) then begin
      NRow = ( ( !MYCT.BOTTOM + !MYCT.NCOLORS ) /   NCol      ) + $
             ( ( !MYCT.BOTTOM + !MYCT.NCOLORS ) mod NCol ne 0 ) 
   endif

   ; If /ALL is set, then show all 256 color indices
   if ( Keyword_Set( All ) ) then begin
      NRow = 16
      NCol = 16
   endif

   ; Default plot title
   if ( N_Elements( Title ) eq 0 ) then begin 
      ;-----------------------------------------------------------------------
      ; Prior to 4/21/08:
      ; Use !MYCT.NAME and !MYCT.INDEX to define default title (bmy, 4/21/08)
      ; to defa(bmy, 4/21/08)
      ;if ( !MYCT.CUSTOM )        $
      ;   then Title = !MYCT.NAME $
      ;   else Title = 'IDL colortable # ' + !MYCT.NAME
      ;-----------------------------------------------------------------------
      Title = 'Color table # ' + StrTrim( String( !MYCT.INDEX ), 2 ) + $
              ': '             + StrTrim(         !MYCT.NAME,    2 )
   endif

   ;====================================================================
   ; Draw the plot
   ;====================================================================

   ; Default X and Y sizes of boxes (pixels)
   XBox = 31
   YBox = 25

   ; Default size of plot window (pixels)
   XSize = NCol * XBox 
   YSize = NRow * YBox

   ; Open a window that is currently not being used.  Save the current
   ; graphics window id, so it can be reset (if necessary) after the
   ; color indices have been drawn here.
   oldWindowID = !D.Window
   Window, /Free, XSize=XSize, YSize=YSize, Title=Title

   ; Set the starting index for the polygons.
   XIndex = 0
   YIndex = 0

   ; Loop over rows
   for I = 0, NRow do begin

      ; Y-coords of the box corners
      Y      = [ YIndex, Yindex+YBox, YIndex+YBox, YIndex, YIndex ]

      ; Increment YINDEX
      YIndex = YIndex + YBox

      ; Start at beginning of row
      XIndex = 0
    
      ; Loop over columns
      for J = 0, NCol do begin
         
         ; X-coords of the box corners
         X     = [ XIndex, XIndex, XIndex+XBox, XIndex+XBox, XIndex]

         ; Color index number
         Color = J + ( I * NCol )
     
         ; Skip if color is out of range
         if ( Color gt 255 ) then goto, Next
   
         ; Draw the polygon in a specfic color.
         Polyfill, X, Y, /Device, Color=Color

         ; Define a string for the color index number
         ColorStr = StrTrim( Color, 2 )

         ; Draw the index number in the "opposite" color.
         XYOutS, XIndex+XBox/3, Yindex-YBox/2, ColorStr, $
            Color=Byte( Color-180 ), /Device, Charsize=0.75
           
         ; Reset the xindex number.
         XIndex = XIndex + XBox
        
Next:
      endfor
   endfor

   ; Reset the current graphics window, if necessary.
   if ( oldWindowID NE -1 ) then WSet, oldWindowID

end 
