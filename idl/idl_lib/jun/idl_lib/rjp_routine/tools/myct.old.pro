; $Id: myct.old.pro,v 1.48 2001/08/27 20:26:30 bmy v1.48 $
;-------------------------------------------------------------
;+
; NAME:
;        MYCT
;
; PURPOSE:
;        load a color table and define the first 16 colors for 
;        drawing colors (white,black,red,green,blue,yellow,magenta,
;        lightblue,lightred,lightgreen,purple,black,85%grey,67%grey,
;        50%grey,33%grey,15%grey).
;
; CATEGORY:
;        color table manipulation
;
; CALLING SEQUENCE:
;        MYCT
;
; INPUTS:
;        TABLE --> [optional] number of the color table to be used
;               default is EOS-B (number 27)
;
; KEYWORD PARAMETERS:
;        NCOLORS --> compress color table into NCOLORS colors
;
;        BOTTOM --> specify where to start color table (see BOTTOM keyword
;               in loadct)
;
;        RANGE --> a two element vector which specifies the range of colors
;               from the color table to be used. If both values are between
;               0 and 1 they are treated as percentage (*100), otherwise the 
;               values of RANGE are interpreted as indices. The colortable 
;               will be expanded so that the given range of colors fills
;               NCOLORS. RANGE is only effective when a TABLE parameter is
;               given.
;
;        RGB --> force interpolation of color values in the RGB scheme.
;               Normally, colors are converted into HSV before expanding
;               which gives better results.
;
;        HLS --> force interpolation of color values in the HLS scheme.
;
;        SATURATION --> factor to scale saturation values of the extra
;               color table. Saturation ranges from 0..1 (but the factor 
;               is free choice as long as positive)
;               
;        VALUE --> factor to scale the "value" of the added colortable.
;               Value ranges from 0..1; 0 = black, 1 = white.
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        It is recommended to use the COLOR= keyword whenever possible
;        This will ensure correct colors on (hopefully) all devices.
;        In order to get 256 colors on a postcript printer use
;        DEVICE,/COLOR,BITS_PER_PIXEL=8 
;
; EXAMPLE:
;        myct,27,NCOLORS=20
;
;        loads EOS-B color table in colors 17 and up, compressing it into 
;        20 color values. Colors 0 to 16 are drawing colors.
;
; MODIFICATION HISTORY:
;        mgs, 06 Feb 1997: VERSION 1.00
;        mgs, 03 Aug 1997: added input parameter and template
;        mgs, 26 Mar 1998: added NCOLORS keyword
;        mgs, 06 Apr 1998: added BOTTOM, RANGE, and RGB keywords
;        mgs, 04 May 1998: added test for null device
;        mgs, 03 Jun 1998: return if !D.N_COLORS is less than 3 (b/w)
;        mgs, 16 Jun 1998: bug fix: range check now after tvlct
;        mgs, 18 Jul 1998: bug re-visited, added HLS keyword and changed
;                 default to HSV. Also added Saturation and Value keywords.
;
;-
; Copyright (C) 1997, 1998, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine myct"
;-------------------------------------------------------------


pro myct,table,NCOLORS=ncolors,BOTTOM=bottom,RANGE=range,   $
         RGB=rgb,HLS=hls,SATURATION=saturation,VALUE=value
 
; loads colortable (default EOS-B) and modifies first entries:
;   color 0 becomes white for background
;   colors 1..10 become brilliant plot colors
;       black, red, green, blue, yellow, magenta, cyan, lightred,
;       lightgreen, lightblue
;   colors 11..16 become grey shadings, beginning with black
;   the rest is unaltered or overwritten by colortable TABLE

if (!d.name eq 'NULL') then return  ; for remote calls
if (!d.n_colors lt 3) then return   ; black and white terminals


if (n_elements(bottom) eq 0) then bottom = 17
if (n_elements(ncolors) eq 0) then ncolors = !d.n_colors-bottom
if (n_elements(saturation) eq 0) then saturation = 1.  ; leave unchanged
if (n_elements(value) eq 0) then value = 1.  ; leave unchanged

   ; load colortable
   loadct, table, bottom=bottom, ncolors=ncolors

   ; expand colortable if requested
   if (n_elements(RANGE) eq 2) then begin
      ; make sure range is in correct order and does not exceed limits
      range = ((range(sort(range)) > 0) < ncolors)
      ; convert percentage to index or vice versa
      if (max(range) le 1) then begin
         range = fix(range*NCOLORS)
      endif
      if (range[1] ge !D.N_COLORS) then begin
         print,'MYCT: Cannot expand colortable ! ***'
         goto,ONLY_SET_DRAWINGCOLS
      endif

      ; calculate spread factor
      if (range(0) eq range(1)) then range(1) = range(0)+1
      spread = float(NCOLORS)/(range(1)-range(0))

      ; load and cut RGB vectors 
      tvlct,r,g,b,/get

      ; range check
      if (bottom ge !D.N_COLORS) then $
          bottom = !d.n_colors-2
      if (bottom+ncolors ge !D.N_COLORS) then $
          ncolors = !d.n_colors-bottom-1

if (n_elements(table) gt 0 AND ncolors gt 1) then begin
      r = r(bottom:bottom+ncolors-1)
      g = g(bottom:bottom+ncolors-1)
      b = b(bottom:bottom+ncolors-1)

      if (keyword_set(rgb)) then goto,RGB_EXPAND
      if (keyword_set(hls)) then goto,HLS_EXPAND

HSV_EXPAND:
      COLOR_CONVERT,r,g,b,h,s,v,/RGB_HSV
      ; expand and interpolate color values
      h = congrid(h,fix(NCOLORS*spread),/interp)
      s = congrid(s,fix(NCOLORS*spread),/interp)
      v = congrid(v,fix(NCOLORS*spread),/interp)

      ; cut them back  
      range = fix(range*spread)
      h = h(range(0):range(1)-1)
      s = s(range(0):range(1)-1)
      v = v(range(0):range(1)-1)
      COLOR_CONVERT,h,s,v,r,g,b,/HSV_RGB
      goto,STORE_IT

RGB_EXPAND:
      ; expand and interpolate color values
      r = congrid(r,fix(NCOLORS*spread),/interp)
      g = congrid(g,fix(NCOLORS*spread),/interp)
      b = congrid(b,fix(NCOLORS*spread),/interp)

      ; cut them back  
      range = fix(range*spread)
      r = r(range(0):range(1)-1)
      g = g(range(0):range(1)-1)
      b = b(range(0):range(1)-1)
      goto,STORE_IT

HLS_EXPAND:
      COLOR_CONVERT,r,g,b,h,l,s,/RGB_HLS
      ; expand and interpolate color values
      h = congrid(h,fix(NCOLORS*spread),/interp)
      l = congrid(l,fix(NCOLORS*spread),/interp)
      s = congrid(s,fix(NCOLORS*spread),/interp)

      ; cut them back  
      range = fix(range*spread)
      h = h(range(0):range(1)-1)
      l = l(range(0):range(1)-1)
      s = s(range(0):range(1)-1)
      COLOR_CONVERT,h,l,s,r,g,b,/HLS_RGB

STORE_IT:
      ; and store them
      tvlct,r,g,b,bottom
   endif
endif


; adapt saturation for color palette
      tvlct,r,g,b,/get
      ; extract range of loaded colors
      r = r(bottom:bottom+ncolors-1)
      g = g(bottom:bottom+ncolors-1)
      b = b(bottom:bottom+ncolors-1)
    
      COLOR_CONVERT,r,g,b,h,s,v,/RGB_HSV
      ; scale saturation and value, restrict range of results
      ; to 0..1
      s = ((s * saturation) > 0) < 1
      v = ((v * value) > 0) < 1
      tvlct,h,s,v,bottom,/HSV   ; store them back
 


ONLY_SET_DRAWINGCOLS: 
; Do not alter saturation for these !!
red  =[  255,  0,255,  0,  0,255,255,  0,255,127,127,0,90,150,188,220,240,255]
green=[  255,  0,  0,255,  0,255,  0,255,127,255,127,0,90,150,188,220,240,255]
blue =[  255,  0,  0,  0,255,  0,255,255,127,127,255,0,90,150,188,220,240,255]
 
; red  =[  255,  0,255,  0,  0,255,255,  0,255,127,127,0,62,98,172,200,232,255]
; green=[  255,  0,  0,255,  0,255,  0,255,127,255,127,0,62,98,172,200,232,255]
; blue =[  255,  0,  0,  0,255,  0,255,255,127,127,255,0,62,98,172,200,232,255]
 
TVLCT, red, green, blue
end
