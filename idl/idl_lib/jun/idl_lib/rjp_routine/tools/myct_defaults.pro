; $Id: myct_defaults.pro,v 1.2 2004/02/04 21:42:35 bmy Exp $ 
;-----------------------------------------------------------------------
;+
; NAME:
;        MYCT_DEFAULTS (function)
;
; PURPOSE:
;        Returns a structure associating the names of MYCT
;        drawing colors with their numeric values, plus
;        the default bottom and number of colors. 
;
; CATEGORY:
;        Color Table Manipulation
;
; CALLING SEQUENCE:
;        C = MYCT_DEFAULTS()
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        /GRAYSCALE -> If set, will define a grayscale colortable
;             such that the lowest color is white, and the highest
;             color is dark grey.  Otherwise the standard "TRACE-P"
;             colortable (based on Mac Style #25) will be defined.
;
;        NCOLORS -> Specifies the number of colors for MYCT.  The
;             default is 120, but if your terminal can support more,
;             you may specify a higher value.
;
; OUTPUTS:
;        C -> Structure with the following tag names:
;             WHITE      : Color index for "drawing color" WHITE
;             BLACK      : Color index for "drawing color" BLACK
;             RED        : Color index for "drawing color" RED
;             GREEN      : Color index for "drawing color" GREEN
;             BLUE       : Color index for "drawing color" BLUE
;             YELLOW     : Color index for "drawing color" YELLOW  
;             MAGENTA    : Color index for "drawing color" MAGENTA  
;             CYAN       : Color index for "drawing color" CYAN 
;             LIGHTRED   : Color index for "drawing color" LIGHTRED   
;             LIGHTGREEN : Color index for "drawing color" LIGHTGREEN  
;             LIGHTBLUE  : Color index for "drawing color" LIGHTBLUE
;             GRAY85     : Color index for "drawing color" 85% GRAY 
;             GRAY67     : Color index for "drawing color" 67% GRAY
;             DARKGRAY   : Color index for "drawing color" 67% GRAY 
;             GRAY50     : Color index for "drawing color" 50% GRAY
;             MEDIUMGRAY : Color index for "drawing color" 50% GRAY 
;             GRAY33     : Color index for "drawing color" 33% GRAY
;             GRAY       : Color index for "drawing color" 33% GRAY
;             LIGHTGRAY  : Color index for "drawing color" 33% GRAY
;             GRAY15     : Color index for "drawing color" 15% GRAY
;             BOTTOM     : Bottom color index for IDL colortable 
;             NCOLORS    : Number of colors for IDL colortable
;             TABLE      : Color table number (0-39)
;             RANGE      : Range of IDL color table to be used
;             SAT        : Saturation value for MYCT
;             VALUE      : Hue value for MYCT
;             REVERSE    : REVERSE=1 means light --> dark
;                          REVERSE=0 means dark  --> light
;             DIAL       : DIAL=1 means we are using the DIAL/Lidar colors
;         
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        For use w/ a MYCT colortable.
;
; NOTES:
;        (1) MYCT defines a colortable such that the first 17
;        colors are "drawing" colors, or pure colors intended
;        for use with the PLOT, CONTOUR, MAP_SET, etc. commands.
;        MYCT then loads a standard IDL colortable (with NCOLORS
;        specifying the number of individual colors) into color
;        indices 18 and higher.
;
;        (2) So far, supports just 2 colortables, one grayscale
;        and one color (the "TRACE-P" color scale).  This is all
;        you really need anyway, otherwise it gets too confusing.
;
; EXAMPLE:
;        C = MYCT_DEFAULTS( /GRAYSCALE )
;
;        MYCT, C.TABLE, $
;            NCOLORS=C.NCOLORS, RANGE=C.RANGE, SAT=C.SAT, $
;            VALUE=C.VALUE, BOTTOM=C.BOTTOM, REVERSE=C.REVERSE
;
;        PLOT, X, Y, COLOR=C.BLACK
;
;            ; Defines a grayscale colortable for use w/ MYCT.
;            
;
; MODIFICATION HISTORY:
;        bmy, 23 Jul 2001: TOOLS VERSION 1.48
;                          - adapted from "default_colors.pro"
;        bmy, 04 Feb 2004: TOOLS VERSION 2.01
;                          - Increased grayscale color range slightly
;   
;-
; Copyright (C) 1997-1999, Martin Schultz, and 
; (C) 2001-2004 Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine myct_defaults"
;-----------------------------------------------------------------------


function MYCT_Defaults, GrayScale=GrayScale, NColors=NColors

   ;====================================================================
   ; Define defaults for GRAYSCALE or COLOR table
   ;====================================================================
   if ( Keyword_Set( GrayScale ) ) then begin

      ; Grayscale colortable (white to dark gray)
      Table   = 0
      ;----------------------------------------
      ; Prior to 2/4/04:
      ; Increase range slightly (bmy, 2/4/04)
      ;Range   = [ 0.2, 0.8 ]
      ;----------------------------------------
      Range   = [ 0.05, 0.8 ]
      Sat     = 0.8
      Value   = 1.3
      Reverse = 1
      Dial    = 0
     
   endif else begin

      ; "TRACE-P" colortable
      Table   = 25
      Range   = [ 0.23, 1 ]
      Sat     = 0.8 
      Value   = 1.3
      Reverse = 0
      Dial    = 0

     ; rjp add
      Table   = 33
      Range   = [ 0.1, 0.9 ]
      Sat     = 1.3
      Value   = 1.3

   endelse

   ; Also define default NCOLORS -- you can specify more than 120
   ; colors via the NCOLORS keyword if your terminal supports it!
   if ( N_Elements( NColors ) ne 1 ) then NColors = 255

   ; Make sure we have enough colors for BOTTOM and NCOLORS
   Bottom  = 18      < ( !D.N_COLORS - 1      )
   NColors = NColors < ( !D.N_COLORS - Bottom )

   ;====================================================================
   ; Define return structure
   ;====================================================================
   Result = {                        $ 
              
              ; ----- Drawing Colors -----
              WHITE      :  0,       $
              BLACK      :  1,       $
              RED        :  2,       $
              GREEN      :  3,       $
              BLUE       :  4,       $
              YELLOW     :  5,       $
              MAGENTA    :  6,       $
              CYAN       :  7,       $
              LIGHTRED   :  8,       $
              LIGHTGREEN :  9,       $
              LIGHTBLUE  : 10,       $

              ;----- Drawing Grayscale ------
              GRAY85     : 12,       $  ; 85% gray
              GRAY67     : 13,       $  ; 67% gray
              DARKGRAY   : 13,       $  ; Synonym for GRAY67
              GRAY50     : 14,       $  ; 50% grey
              MEDIUMGRAY : 14,       $  ; Synonym for GRAY50
              GRAY33     : 15,       $  ; 33% grey
              GRAY       : 15,       $  ; Synonym for GRAY33 (default)
              LIGHTGRAY  : 15,       $  ; Synonym for GRAY33 
              GRAY15     : 16,       $  ; 15% gray
                  
              ; ----- Parameters -----
              BOTTOM     : Bottom,   $  ; Default colortable bottom
              NCOLORS    : NColors,  $  ; Default # of colors
              TABLE      : Table,    $  ; Default colortable
              RANGE      : Range,    $  ; Default range
              SAT        : Sat,      $  ; Default saturation
              VALUE      : Value,    $  ; Default hue value
              REVERSE    : Reverse,  $  ; REVERSE=1 means from light -> dark
              DIAL       : Dial }       ; Are we using DIAL/Lidar colors?

   ; Return structure to calling program
   return, Result

end
