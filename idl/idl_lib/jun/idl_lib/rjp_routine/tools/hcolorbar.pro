; $Id: hcolorbar.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        HCOLORBAR
;
; PURPOSE:
;        Plot a horizontal colorbar 
;
; CATEGORY:
;        Plotting program
;
; CALLING SEQUENCE:
;        HCOLORBAR, CX, CY, [,keywords]
;
; INPUTS:
;        CX     -> [Min X, Max X] vector in NORMAL coords
;        CY     -> [Min Y, Max Y] vector in NORMAL coords
;
; KEYWORD PARAMETERS:
;        COLORS -> array of color levels
;        LABELS -> string array of labels for the color levels
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        HCOLORBAR assumes n_elements(COLORS) >= n_elements(LABELS)+1
;
; NOTES:
;        The colorbar will be plotted as follows:
;
;             LABELS(0)   LABELS(1)                     LABELS(NL-1)
;    +-----------+-----------+----------- // --------------+------------+
;    | COLORS(0) | COLORS(1) | COLORS(2)  //  COLORS(NL-1) | COLORS(NL) |
;    +-----------+-----------+----------- // --------------+------------+
;
;        COLORS(0) = color index for data < first contour level
;        COLORS(1) = color index for data between 1st and 2nd levels
;           ...
;        COLORS(NL) = color index for data >= the last contour level
;
;        LABELS(0)  = label for the first contour level
;        LABELS(1)  = label for the 2nd contour level, etc...
;           ...
;        LABELS(NL) = label for data >= the last contour level
;  
; EXAMPLE:
;        HCOLORBAR, [0.025, 0.275], [0.680, 0.690], $
;           COLORS=[0,1,2,3,4,5],  LABELS=['1','2','3','4','5']
;
; MODIFICATION HISTORY:
;        bmy, 10 Nov 1994: VERSION 1.00
;        bmy, 24 Jun 1997: VERSION 1.01
;        bmy, 30 Sep 1997: VERSION 1.10
;        bmy, 20 Nov 1997: VERSION 1.11
;        bmy, 02 Aug 1999: VERSION 1.43 
;                          - minor bug fix
;
;-
; Copyright (C) 1997, 1999, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine hcolorbar"
;-------------------------------------------------------------

pro use_hcolorbar
   print
   print,'   Usage :'
   print,'      hcolorbar, CX, CY (LABELS=LABELS | COLORS=COLORS)'
   print
   print,'   Input:' 
   print,'      CX     --> X-placement vector in NORMAL coords'
   print,'      CY     --> Y-placement vector in NORMAL coords'
   print,'      LABELS --> vector of string labels for the contour levels'
   print,'      COLORS --> vector of color indices for the contour levels'
   print,'                 (must be at least of size n_elements(LABELS)+1'
   print
   return
end


pro hcolorbar, CX, CY, COLORS=COLORS, LABELS=LABELS
   
;==============================================================================
;  Error checking 
;==============================================================================
   on_error, 2	
   
   if (n_params() lt 2) then begin
      print, 'The CX and CY vectors must be specified...'
      use_hcolorbar
      return
   endif

   if (not keyword_set(LABELS)) then LABELS = [' ']
   if (not keyword_set(COLORS)) then COLORS = indgen(n_elements(LABELS)+1)

   if (n_elements(COLORS) lt n_elements(LABELS)+1) then begin
      print, 'COLORS must be at least of size n_elements(LABELS)+1...'
      use_hcolorbar
      return
   endif

;==============================================================================
;  NC = number of color levels
;  Compute the X and Y-limits for the color bar
;==============================================================================
   X0   = min(CX, max=X1)
   INCR = (X1 - X0) / n_elements(COLORS)

   Y0   = min(CY, max=Y1)

;==============================================================================
;  X0 is the leftmost X-position in normal coordinates.  
;
;  XLAB and YLAB are arrays containing the (X, Y) normal coordinates
;  where the labels will be printed above the colorbar.
;
;  Since this is a horizontal colorbar, YLAB = constant = YMAX + 0.01
;==============================================================================
   YLAB    = fltarr(n_elements(COLORS))
   YLAB(*) = Y1 + 0.01 
   XLAB    = X0 + (findgen(n_elements(COLORS)) + 1) * INCR
   
;==============================================================================
;  Draw the colorbar and plot the labels!  
;==============================================================================
   for C = 0, n_elements(COLORS)-1 do begin
      X1 = X0 + INCR
      polyfill, [X0,X1,X1,X0], [Y0, Y0, Y1, Y1], /norm, color=COLORS(C)
      X0 = X1
   endfor      
   
;==============================================================================
;  Draw a border around the colorbar using the PLOTS command
;==============================================================================
   X0 = min(CX, max=X1)
   Y0 = min(CY, max=Y1)
   plots, [X0, X1, X1, X0, X0], [Y0, Y0, Y1, Y1, Y0], $
      /norm, thick=2, color=1
   
;==============================================================================
;  Position the labels above the colorbar and return
;==============================================================================
   xyouts, XLAB, YLAB, LABELS, align=0.5, charsize=0.8, $
      charthick=2, /norm, color=1
   
   return
end
