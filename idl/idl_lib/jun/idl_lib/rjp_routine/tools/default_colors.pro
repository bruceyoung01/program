;-----------------------------------------------------------------------
;+
; NAME:
;        MYCT_DRAWINGCOLORS (function)
;
; PURPOSE:
;        Returns a structure associating the names of MYCT
;        drawing colors with their numeric values.
;
; CATEGORY:
;        color table manipulation
;
; CALLING SEQUENCE:
;        COLOR = MYCT_DRAWINGCOLORS()
;
; INPUTS:
;        None
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
;        Assumes MYCT colortable has been loaded.
;
; NOTES:
;        
;
; EXAMPLE:
;        MYCT, 25, NCOLORS=120, RANGE=[0.23, 1], $
;          SAT=0.8, VALUE=1.3, BOTTOM=20
;
;        C = MYCT_DRAWINGCOLORS()
;
;        PLOT, X, Y, COLOR=C.BLACK
;
;            ; Uses C.BLACK to refer to the MYCT index for BLACK.
;            ; so that you don't have to remember the number itself.
;
; MODIFICATION HISTORY:
;        bmy, 23 Jul 2001: TOOLS VERSION 1.48
;                          - adapted from "default_colors.pro"
;   
;-
; Copyright (C) 1997-1999, Martin Schultz and Bob Yantosca,
; Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine myct_drawingcolors"
;-----------------------------------------------------------------------


function MYCT_DrawingColors

   Result = { WHITE             :  0, $
              BLACK             :  1, $
              RED               :  2, $
              GREEN             :  3, $
              BLUE              :  4, $
              YELLOW            :  5, $
              MAGENTA           :  6, $
              CYAN              :  7, $
              LIGHTRED          :  8, $
              LIGHTGREEN        :  9, $
              LIGHTBLUE         : 10, $
              GREY85            : 12, $  ; 85% grey
              GREY67            : 13, $  ; 67% grey
              DARKGREY          : 13, $  ; Synonym for GREY67
              GREY50            : 14, $  ; 50% grey
              MEDIUMGREY        : 14, $  ; Synonym for GREY50
              GREY33            : 15, $  ; 33% grey
              GREY              : 15, $  ; Synonym for GREY33 (default)
              LIGHTGREY         : 15, $  ; Synonym for GREY33 
              GREY15            : 16 }   ; 15% grey

   ; Return structure
   return, Result

end
