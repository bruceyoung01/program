; $Id: myct_defaults.pro,v 1.4 2008/04/21 19:23:41 bmy Exp $ 
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
;        Color
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
;             WHITE       : Color index for "drawing color" WHITE
;             BLACK       : Color index for "drawing color" BLACK
;             RED         : Color index for "drawing color" RED
;             GREEN       : Color index for "drawing color" GREEN
;             BLUE        : Color index for "drawing color" BLUE
;             ORANGE      : Color index for "drawing color" ORANGE
;             PURPLE      : Color index for "drawing color" PURPLE
;             LIGHTRED    : Color index for "drawing color" LIGHTRED   
;             LIGHTGREEN  : Color index for "drawing color" LIGHTGREEN  
;             LIGHTBLUE   : Color index for "drawing color" LIGHTBLUE
;             LIGHTORANGE : Color index for "drawing color" LIGHTORANGE  
;             LIGHTPURPLE : Color index for "drawing color" LIGHTPURPLE
;             YELLOW      : Color index for "drawing color" YELLOW  
;             MAGENTA     : Color index for "drawing color" MAGENTA  
;             CYAN        : Color index for "drawing color" CYAN 
;             GRAY85      : Color index for "drawing color" 85% GRAY 
;             GRAY67      : Color index for "drawing color" 67% GRAY
;             DARKGRAY    : Color index for "drawing color" 67% GRAY 
;             GRAY50      : Color index for "drawing color" 50% GRAY
;             MEDIUMGRAY  : Color index for "drawing color" 50% GRAY 
;             GRAY33      : Color index for "drawing color" 33% GRAY
;             GRAY        : Color index for "drawing color" 33% GRAY
;             LIGHTGRAY   : Color index for "drawing color" 33% GRAY
;             GRAY15      : Color index for "drawing color" 15% GRAY
;             FILE        : Name of the color table (*.tbl) file
;             NAME        : Color table name
;             INDEX       : Color table index 
;             BOTTOM      : Color table starts at this index
;             NCOLORS     : Number of colors
;             RANGE       : Range of IDL color table to be used
;             SAT         : Saturation value for MYCT
;             VALUE       : Hue value for MYCT
;             REVERSE     : REVERSE=1 means light --> dark
;                           REVERSE=0 means dark  --> light
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Designed to be used by the GAMAP routine "myct.pro".
;
; NOTES:
;        (1) This routine is designed to be called by MYCT_DEFINE.
;        You should not normally have to call MYCT_DEFAULTS.
;
;        (2) MYCT defines a colortable such that the first 17
;        colors are "drawing" colors, or pure colors intended
;        for use with the PLOT, CONTOUR, MAP_SET, etc. commands.
;        MYCT then loads a standard IDL colortable (with NCOLORS
;        specifying the number of individual colors) into color
;        indices 18  and higher.
;
;        (3) New drawing colors (that are less saturated and
;        easier to read on the screen) are now the defaults.
;        See the documentation to the MYCT routine for more info.
;
; EXAMPLE:
;        C = MYCT_DEFAULTS()
;
;            ; Defines a grayscale colortable for use w/ MYCT.
;            
;
; MODIFICATION HISTORY:
;        bmy, 23 Jul 2001: TOOLS VERSION 1.48
;                          - adapted from "default_colors.pro"
;        bmy, 04 Feb 2004: TOOLS VERSION 2.01
;                          - Increased grayscale color range slightly
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - renamed DIAL to CUSTOM, to reflect that
;                            we have other custom colortables in use
;  cdh & bmy, 19 Nov 2007: GAMAP VERSION 2.11
;                          - Added names for the new MYCT drawing colors
;        bmy, 21 Apr 2008: GAMAP VERSION 2.12
;                          - Removed obsolete settings and keywords
;                          - Removed IS_CUSTOM tag name from !MYCT
;                          - Added INDEX, FILE tag names to !MYCT
;
;-
; Copyright (C) 2001-2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to yantosca@seas.harvard.edu
; or plesager@seas.harvard.edu with subject "IDL routine myct_defaults"
;
; ColorBrewer license info:
; -------------------------
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
; implied. See the License for the specific language governing 
; permissions and limitations under the License.
;-----------------------------------------------------------------------


function MYCT_Defaults 
;----------------------------------------------
; Prior to 4/21/08:
; Remove keywords (bmy, 4/21/08)
;, GrayScale=GrayScale, NColors=NColors
;----------------------------------------------
                         
   ;====================================================================
   ; Define defaults
   ;====================================================================
   ;-------------------------------------------------------------------------
   ; Prior to 4/21/08:
   ; Remove this, this is now obsolete (bmy, 4/21/08)
   ;if ( Keyword_Set( GrayScale ) ) then begin
   ;
   ;   ; Grayscale colortable (white to dark gray)
   ;   Table   = 0
   ;   Range   = [ 0.05, 0.8 ]
   ;   Sat     = 0.8
   ;   Value   = 1.3
   ;   Reverse = 1
   ;   Name     = String( Table )
   ;   Custom   = -1L
   ;  
   ;endif else begin
   ;
   ;   ; "TRACE-P" colortable
   ;   Table   = 25
   ;   Range   = [ 0.23, 1 ]
   ;   Sat     = 0.8 
   ;   Value   = 1.3
   ;   Reverse = 0
   ;   Name    = String( Table )
   ;   Custom  = -1L
   ;
   ;endelse
   ;
   ; Also define default NCOLORS -- you can specify more than 120
   ; colors via the NCOLORS keyword if your terminal supports it!
   ;if ( N_Elements( NColors ) ne 1 ) then NColors = 120
   ;-------------------------------------------------------------------------

   ; Define NCOLORS and bottom
   NColors = 256
   Bottom  = 18      < ( !D.N_COLORS - 1      )
   NColors = NColors < ( !D.N_COLORS - Bottom )

   ;====================================================================
   ; Define return structure
   ;====================================================================
   Result = {                           $ 
              
              ; ----- Drawing Colors -----
              WHITE       :  0,         $
              BLACK       :  1,         $
              RED         :  2,         $
              GREEN       :  3,         $
              BLUE        :  4,         $
              ORANGE      :  5,         $
              PURPLE      :  6,         $
              LIGHTRED    :  7,         $
              LIGHTGREEN  :  8,         $
              LIGHTBLUE   :  9,         $
              LIGHTORANGE : 10,         $
              LIGHTPURPLE : 11,         $
              YELLOW      :  0,         $
              MAGENTA     :  0,         $
              CYAN        :  0,         $

              ;----- Drawing Grayscale ------
              GRAY85      : 12,         $  ; 85% gray
              GRAY67      : 13,         $  ; 67% gray
              DARKGRAY    : 13,         $  ; Synonym for GRAY67
              GRAY50      : 14,         $  ; 50% grey
              MEDIUMGRAY  : 14,         $  ; Synonym for GRAY50
              GRAY33      : 15,         $  ; 33% grey
              GRAY        : 15,         $  ; Synonym for GRAY33 (default)
              LIGHTGRAY   : 15,         $  ; Synonym for GRAY33 
              GRAY15      : 16,         $  ; 15% gray
                  
              ; ----- Parameters -----
              FILE        : '',         $  ; Default *.tbl file
              NAME        : '',         $  ; Color table name
              INDEX       : 0,          $  ; Color table index 
              BOTTOM      : Bottom,     $  ; Default colortable bottom
              NCOLORS     : NColors,    $  ; Default # of colors
              RANGE       : [0.0, 1.0], $  ; Default range
              SAT         : 1.0,        $  ; Default saturation
              VALUE       : 1.0,        $  ; Default hue value
              REVERSE     : 0          }   ; REVERSE=1 means from light -> dark


   ; Return structure to calling program
   return, Result

end
