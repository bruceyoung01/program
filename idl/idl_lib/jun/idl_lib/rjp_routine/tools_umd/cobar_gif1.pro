;+
; NAME:
;	COLORBAR
;
; PURPOSE:
;       The purpose of this routine is to add a color bar to the current
;       graphics window.
;
; CATEGORY:
;       Graphics, Widgets.
;
; CALLING SEQUENCE:
;       COLORBAR
;
; INPUTS:
;       None.
;	
; KEYWORD PARAMETERS:
;
;       BOTTOM:	The lowest color index of the colors to be loaded in the bar.
;
;       CHARSIZE: The character size of the color bar annotations. Default is 1.0.
;
;       COLOR: The color index of the bar outline and characters. Default is 
;       ncolors - 1 + bottom.
;
;       DIVISIONS: The number of divisions to divide the bar into. There will
;       be divisions + 1 annotations. The default is 2.
;
;       FORMAT: The format of the bar annotations. Default is '(F6.2)'.
;
;       LOCATION: A four-element array of normalized coordinates in the same
;       form as the POSITION keyword on a plot. Default is [0.88, 0.15, 0.95, 0.95]
;       for a vertical bar and [0.15, 0.88, 0.95, 0.95] for a horizontal bar.
;
;       MAX: The maximum data value for the bar annotation. Default is NCOLORS-1.
;
;       MIN: The minimum data value for the bar annotation. Default is 0.
;
;       NCOLORS: This is the number of colors in the color bar.
;
;       TITLE: This is title for the color bar. The default is no title.
;
;       VERTICAL: Setting this keyword give a vertical color bar. The default
;       is a horizontal color bar.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       Color bar is drawn in the current graphics window.
;
; RESTRICTIONS:
;       None.
;
; EXAMPLE:
;       To display a horizontal color bar above a contour plot, type:
;
;       LOADCT, 5, NCOLORS=100
;       CONTOUR, DIST(31,41), POSITION=[0.15, 0.15, 0.95, 0.8], $
;          C_COLORS=INDGEN(25)*4, NLEVELS=25
;       COLORBAR, NCOLORS=100
;
; MODIFICATION HISTORY:
;       Written by:	David Fanning, 10 JUNE 96.
;       Modified:       Jeff Haferman  11 OCT  96
;                         added PS (postscript) option
;       Modified:       Ye Hong  14 OCT  96
;                         added SELFTICK option to input own tick name.  
;			Otherwise it is automatically produced
;-



PRO COBAR_GIF1, BOTTOM=bottom, CHARSIZE=charsize, COLOR=color, DIVISIONS=divisions, $
   FORMAT=format,  LOCATION=location, MAX=max, MIN=min, NCOLORS=ncolors, $
   TITLE=title, VERTICAL=vertical, PS=ps, SELFTICK=selftick, BAR=bar, ticmark=ch_z
   
     ; Check and define keywords.
     
IF N_ELEMENTS(ncolors) EQ 0 THEN ncolors = !D.N_COLORS
IF N_ELEMENTS(bottom) EQ 0 THEN bottom = 0B
IF N_ELEMENTS(charsize) EQ 0 THEN charsize = 1.0
IF N_ELEMENTS(format) EQ 0 THEN format = '(F6.2)'
IF N_ELEMENTS(color) EQ 0 THEN color = ncolors - 1 + bottom
IF N_ELEMENTS(min) EQ 0 THEN min = 0.0
IF N_ELEMENTS(max) EQ 0 THEN max = FLOAT(ncolors) - 1
IF N_ELEMENTS(divisions) EQ 0 THEN divisions = 2
IF N_ELEMENTS(title) EQ 0 THEN title = ''

; Scale the color bar.
   bbar = bar(bottom:ncolors) #  REPLICATE(1B, 10)

   xsize = (location(2) - location(0)) * !D.X_VSIZE
   ysize = (location(3) - location(1)) * !D.Y_VSIZE    
   ; Size the color bar for the current graphics window.
   bbar = CONGRID(bbar, CEIL(xsize), CEIL(ysize))
   ;bbar = CONGRID(bbar, CEIL(xsize), CEIL(ysize), /INTERP)
   ; Display the color bar in the window.
   TV, bbar, location (0), location(1), /NORMAL

   ; Annotate the color bar.
    
IF KEYWORD_SET(vertical) THEN BEGIN
   IF KEYWORD_SET(selftick) THEN $   
      PLOT, [1,10], XTICKS=1, YTICKS=divisions,XSTYLE=1, YSTYLE=1,  $
         POSITION=location, COLOR=color, CHARSIZE=charsize, $
         /NODATA,  /NOERASE, /normal, yminor = 1,  $
        xtickname=[' ', ' '],  ytickname = selftick $
   ELSE $
      PLOT, [1,10], /NODATA, XTICKS=1, YTICKS=divisions, XSTYLE=1, YSTYLE=1, $
         POSITION=location, COLOR=color, CHARSIZE=charsize, /NOERASE, $
         YTICKFORMAT=format, XTICKFORMAT='(A1)', YTICKLEN=0.1 , $
        YRANGE=[min, max], YTITLE=title  
ENDIF ELSE BEGIN
;  IF KEYWORD_SET(selftick) THEN $   
;     PLOT, [1,10], YTICKS=1, XTICKS=divisions,XSTYLE=1, YSTYLE=1,  $
;        POSITION=location, COLOR=color, CHARSIZE=charsize, $
;        /NODATA,  /NOERASE, /normal, xminor = 1,  $
;       ytickname=[' ', ' '],  xtickname = selftick $
;  ELSE $
;     PLOT, [min, max],[1,10], /NODATA, XTICKS=divisions, YTICKS=1, XSTYLE=1, YSTYLE=1, $
;       POSITION=location, COLOR=color, CHARSIZE=charsize, /NOERASE, $
;       YTICKFORMAT='(A1)', XTICKFORMAT=format, XTICKLEN=0.1, $
;       XRANGE=[min, max], TITLE=title

      PLOT, [min,max],[1,10], /NODATA, XTICKS=1, YTICKS=1, XSTYLE=1, YSTYLE=1, $
        POSITION=location, COLOR=0    , CHARSIZE=charsize, /NOERASE, $
        YTICKFORMAT='(A1)', XTICKFORMAT=format, XTICKLEN=0.1, $
        XRANGE=[min, max], TITLE=title

      ;;-- Title
      xyouts, (min+max)/2., 13.,title,charsize=charsize,color=254, alignment=0.5

      ;;-- BOX
      plots, min, 1, COLOR=color
      plots, max, 1, COLOR=color, /continue
      plots, max,10, COLOR=color, /continue
      plots, min,10, COLOR=color, /continue
      plots, min, 1, COLOR=color, /continue

      ;;-- TIC
      for j=0,divisions do begin
       xpo= ((max-min)/divisions )*j
       plots, xpo,1 ,COLOR=color
       plots, xpo,10,COLOR=color,/continue
       xyouts, xpo, -6.,ch_z(j), charsize=charsize,color=254, alignment=0.5
      endfor

ENDELSE

END
