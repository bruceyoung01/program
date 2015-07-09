; $Id: str_size.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;+
; NAME:
;  STR_SIZE
;
; PURPOSE:
;
;  The purpose of this function is to return the proper
;  character size to make a specified string a specifed
;  width in a window. The width is specified in normalized
;  coordinates. The function is extremely useful for sizing
;  strings and labels in resizeable graphics windows.
;
; CATEGORY:
;
;  Graphics Programs, Widgets.
;
; CALLING SEQUENCE:
;
;  thisCharSize = STR_SIZE(thisSting, targetWidth)
;
; INPUTS:
;
;  thisString:  This is the string that you want to make a specifed
;     target size or width.
;
; OPTIONAL INPUTS:
;
;  targetWidth:  This is the target width of the string in normalized
;     coordinates in the current graphics window. The character
;     size of the string (returned as thisCharSize) will be
;     calculated to get the string width as close as possible to
;     the target width. The default is 0.25.
;
; KEYWORD PARAMETERS:
;
;  INITSIZE:  This is the initial size of the string. Default is 1.0.
;
;  STEP:   This is the amount the string size will change in each step
;     of the interative process of calculating the string size.
;     The default value is 0.05.
;
; OUTPUTS:
;
;  thisCharSize:  This is the size the specified string should be set
;     to if you want to produce output of the specified target
;     width. The value is in standard character size units where
;     1.0 is the standard character size.
;
; EXAMPLE:
;
;  To make the string "Happy Holidays" take up 30% of the width of
;  the current graphics window, type this:
;
;               XYOUTS, 0.5, 0.5, ALIGN=0.5, "Happy Holidays", $
;        CHARSIZE=STR_SIZE("Happy Holidays", 0.3)
;
; MODIFICATION HISTORY:
;
;  Written by: David Fanning, 17 DEC 96.
;  Added a scaling factor to take into account the aspect ratio
;     of the window in determing the character size. 28 Oct 97. DWF
;-

FUNCTION STR_SIZE, string, targetWidth, INITSIZE=initsize, STEP=step

ON_ERROR, 1

   ; Check positional parameters.

np = N_PARAMS()
CASE np OF
   0: MESSAGE, 'One string parameter is required.'
   1: targetWidth = 0.25
   ELSE:
ENDCASE

   ; Check keywords. Assign default values.

IF N_ELEMENTS(step) EQ 0 THEN step = 0.05
IF N_ELEMENTS(initsize) EQ 0 THEN initsize = 1.0

   ; Calculate a trial width.

size = initsize
XYOUTS, 0.5, 0.5, ALIGN=0.5, string, WIDTH=thisWidth, $
      CHARSIZE=-size, /NORMAL

   ; Size is perfect.

IF thisWidth EQ targetWidth THEN RETURN, size * Float(!D.Y_Size)/!D.X_Size

   ; Initial size is too big.

IF thisWidth GT targetWidth THEN BEGIN
   REPEAT BEGIN
     XYOUTS, 0.5, 0.5, ALIGN=0.5, string, WIDTH=thisWidth, $
        CHARSIZE=-size, /NORMAL
      size = size - step
   ENDREP UNTIL thisWidth LE targetWidth
   RETURN, size * Float(!D.Y_Size)/!D.X_Size
ENDIF

   ; Initial size is too small.

IF thisWidth LT targetWidth THEN BEGIN
   REPEAT BEGIN
     XYOUTS, 0.5, 0.5, ALIGN=0.5, string, WIDTH=thisWidth, $
        CHARSIZE=-size, /NORMAL
      size = size + step
   ENDREP UNTIL thisWidth GT targetWidth
   size = size - step ; Need a value slightly smaller than target.
   RETURN, size * Float(!D.Y_Size)/!D.X_Size
ENDIF

END