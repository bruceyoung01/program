PRO CIndex

;+
; NAME:		CIndex
;
; PURPOSE:	This is a program for viewing the current colors in the 
;		colortable with their index numbers overlayed on each color.
;
; CATEGORY:	Graphics
;
; CALLING SEQUENCE:	CIndex
;
; INPUTS:	None.
;	
; Optional Inputs:	None
;
; OUTPUTS:	None
;
; OPTIONAL OUTPUTS:	None
;
; KEYWORD Parameters:	None
; 
; COMMON BLOCKS:	None
;
; SIDE EFFECTS:	None
;
; RESTRICTIONS:	None
;
; PROCEDURE:
;
;	Draws a 16x16 set of small rectangles in 256 different colors.
;	Writes the color index number on top of each rectangle.
;
; MODIFICATION HISTORY:  David Fanning, RSI, May 1995
;	
;-

    ; Open a window that is currently not being used. Save the current
    ; graphics window id, so it can be reset (if necessary) after the
    ; color indices have been drawn here.
   
oldWindowID = !D.Window
Window, /Free, XSize=496, YSize=400, Title='Color Index Numbers'

   ; Set the starting index for the polygons.
   
xindex = 0
yindex = 0

   ; Start drawing. There are 16 rows and 16 columns of colors.

FOR i=0,15 DO BEGIN

    y = [yindex, yindex+25, yindex+25, yindex, yindex]
    yindex = yindex+25
    xindex = 0
    
    FOR j=0,15 DO BEGIN
    
        x = [xindex, xindex, xindex+31, xindex+31, xindex]
        color = j+(i*16)
        
           ; Draw the polygon in a specfic color.
           
        Polyfill, x, y, /Device, Color=color
        output = StrTrim(j+(i*16), 2)
                
           ; Draw the index number in the "opposite" color.
           
        XYOutS, xindex+8, yindex-15, output, Color=Byte(color-180), $
           /Device, Charsize=0.75
           
           ; Reset the xindex number.
                        
        xindex = xindex+31
        
    ENDFOR
    
ENDFOR

   ; Reset the current graphics window, if necessary.
   
IF oldWindowID NE -1 THEN WSet, oldWindowID

END ; ***********************************************************************
