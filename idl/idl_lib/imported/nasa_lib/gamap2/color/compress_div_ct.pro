; $Id: compress_div_ct.pro,v 1.2 2008/04/23 18:21:42 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        COMPRESS_DIV_CT
;
; PURPOSE:
;        Compresses a diverging color table with even number of colors 
;        into NCOLORS.  If the /MIDCOLORPRESENT keyword is specified,
;        COMPRESS_DIV_CT will also place white or yellow spaces in
;        the middle of the color table.
;
; CATEGORY:
;	 Color
;
;
; CALLING SEQUENCE:
;        COMPRESS_DIV_CT, R, G, B [, Keywords ]
;
; INPUTS:
;        R, G, B -> The vectors containing the red, blue, and 
;             green color values that define the color table.
;
; KEYWORD PARAMETERS:
;        NCOLORS -> Requested number of colors to be returned.
;             If NCOLORS is omitted, then COMPRESS_DIV_CT will
;             return without doing anything.
;
;        /MIDCOLORPRESENT -> Set this switch to add 1 or 2 extra
;             white or yellow color spaces in the color table.  
;            
;        /WHITE -> If /MIDCOLORPRESENT is set, this switch will
;             cause 1 (if NCOLORS is odd) or 2 (if NCOLORS is even)
;             extra white color spaces to be placed
;             at the center of the color table.  
;            
;        /YELLOW -> If /MIDCOLORPRESENT is set, this switch will
;             cause 1 (if NCOLORS is odd) or 2 (if NCOLORS is even)
;             extra white color spaces to be placed
;             at the center of the color table.  ;
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Designed for use with MYCT.  You shouldn't normally 
;        have to call COMPRESS_DIV_CT directly.
;
; NOTES:
;        None
;
; EXAMPLE:
;        LOADCT, 63, FILE=FILE_WHICH( 'gamap_colors.tbl' )
;        TVLCT, R, G, B, /Get
;
;             ; Load the ColorBrewer "RdBu" table
;             ; and return the color vectors
;
;        COMPRESS_DIV_CT, R, G, B, $
;                         NCOLORS=20, /MIDCOLORPRESENT, /WHITE
;
;             ; Compress the color table down to 20 colors and 
;             ; insert 2 white spaces at the middle of the table.
;
; MODIFICATION HISTORY:
;        phs, 21 Apr 2008: GAMAP VERSION 2.12
;
;-
; Copyright (C) 2008, Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to plesager@seas.harvard.edu 
; with subject "IDL routine compress_div_ct"
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


pro Compress_Div_CT, R, G, B, $
                     ncolors=ncolors, white=wh, yellow=yl, $
                     MidColorPresent=MidColorPresent

   ;=====================================================================
   ; Initialization
   ;=====================================================================

   ; assumptions test
   if n_elements(ncolors) eq 0L            then return 
 
   if n_elements(ncolors) gt n_elements(R) then begin
      message, 'CT extrapolation not handled. Returning...',  /info
      return
   endif
 
   if n_elements(R) mod 2 ne 0          then begin
      message, 'Expected Diverging table with EVEN nb of colors.' + $
               ' Returning...',  /info
      return
   endif
      
 
   ; Get middle index in input
   Half = n_elements(R) / 2
 
 
   ; Get middle RGB for diverging pattern
   ; Use WHITE for default 
   MidRGB = [255, 255, 255]
   if keyword_set(yl) then MidRGB = [255, 255, 191]
 
 
   ;=====================================================================
   ; Specific treatment so that the middle range color is always
   ; present, i.e., the the middle color is doubled for even
   ; number of output colors.
   ;=====================================================================
   if keyword_set( MidColorPresent ) then begin
 
      ; add the Middle color TWICE
      R = [ R[0:Half-1], MidRGB[0], MidRGB[0], R[Half:*] ]
      G = [ G[0:Half-1], MidRGB[1], MidRGB[1], G[Half:*] ]
      B = [ B[0:Half-1], MidRGB[2], MidRGB[2], B[Half:*] ]
      
      ; tell if even or odd # of colors in output
      Odd_Out = NColors mod 2
 
      ; Number of colors for each half-side of the table. Make sure
      ; that it includes the middle range color
      Steps = Fix( NColors ) / 2 + Odd_Out
      
      ; Interpolate LEFT and RIGT parts separately to the new number
      ; of colors w/ CONGRID 
      R1 = Congrid( R[0:Half],   Steps, /Minus_One, /Interp, _EXTRA=e )
      G1 = Congrid( G[0:Half],   Steps, /Minus_One, /Interp, _EXTRA=e )
      B1 = Congrid( B[0:Half],   Steps, /Minus_One, /Interp, _EXTRA=e )
      
      R2 = Congrid( R[Half+1:*], Steps, /Minus_One, /Interp, _EXTRA=e )
      G2 = Congrid( G[Half+1:*], Steps, /Minus_One, /Interp, _EXTRA=e )
      B2 = Congrid( B[Half+1:*], Steps, /Minus_One, /Interp, _EXTRA=e )
 
      ; Concatenate the vectors (final length = ncolors)
      R  = [ R1, R2[Odd_Out:*] ]
      G  = [ G1, G2[Odd_Out:*] ]
      B  = [ B1, B2[Odd_Out:*] ]
 
   endif else begin
      
      ; add the Middle color (we assume it is missing, if not we
      ; should do nothing)
      R = [ R[0:Half-1], MidRGB[0], R[Half:*] ]
      G = [ G[0:Half-1], MidRGB[1], G[Half:*] ]
      B = [ B[0:Half-1], MidRGB[2], B[Half:*] ]
 
      ; Interpolate to the new number of colors w/ CONGRID 
      R = Congrid( R, NColors, /Minus_One, /Interp, _EXTRA=e )
      G = Congrid( G, NColors, /Minus_One, /Interp, _EXTRA=e )
      B = Congrid( B, NColors, /Minus_One, /Interp, _EXTRA=e )
      
   endelse
 
 
   return
end
