; $Id: bar_plot.pro,v 1.1 1993/04/02 19:43:31 idl Exp $

pro bar_plot,values,baselines=baselines,colors=colors,barnames=barnames, $
          title=title,xtitle=xtitle,ytitle=ytitle,baserange=baserange, $
          barwidth=barwidth,barspace=barspace,baroffset=baroffset, $
          outline=outline,overplot=overplot,background=background, $
          rotate=rotate,yrange=yrange,charsize=charsize,charthick=charthick,$
	  xmargin=xmargin,ymargin=ymargin,xrange=xrange,$
	  orientation=orientation,spacing=spacing,xpt=xpt,ypt=ypt,spt=spt
;+
; NAME:  
;	BAR_PLOT
;
; PURPOSE:
;	Create a bar graph, or overplot on an existing one.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	BAR_PLOT, Values
;
; INPUTS:
;	Values:	A vector containing the values to be represented by the bars.
;		Each element in VALUES corresponds to a single bar in the
;		output.
;
; KEYWORD PARAMETERS:
;   BASELINES:	A vector, the same size as VALUES, that contains the
;		base value associated with each bar.  If not specified,
;		a base value of zero is used for all bars.
;
;      COLORS:	A vector, the same size as VALUES, containing the color index
;		to be used for each bar.  If not specified, the colors are
;		selected based on spacing the color indices as widely as 
;		possible within the available colors (specified by D.N_COLORS).
;
;    BARNAMES:	A string array, containing one string label per bar.
;		If the bars are vertical, the labels are placed beneath
;		them.  If horizontal (rotated) bars are specified, the labels
;		are placed to the left of the bars.
;
;	TITLE:	A string containing the main title to for the bar plot.
;
;	XTITLE:	A string containing the title for the X axis.
;
;	YTITLE:	A string containing the title for the Y axis.
;
;   BASERANGE:	A floating-point scalar in the range 0.0 to 1.0, that
;		determines the fraction of the total available plotting area
;		(in the direction perpendicular to the bars) to be used.
;		If not specified, the full available area is used.
;
;    BARWIDTH:	A floating-point value that specifies the width of the bars
;		in units of "nominal bar width".  The nominal bar width is
;		computed so that all the bars (and the space between them, 
;		set by default to 20% of the width of the bars) will fill the 
;		available space (optionally controlled with the BASERANGE 
;		keyword).
;
;    BARSPACE: 	A scalar that specifies, in units of "nominal bar width",
;		the spacing between bars.  For example, if BARSPACE is 1.0,
;		then all bars will have one bar-width of space between them.
;		If not specified, the bars are spaced apart by 20% of the bar
;		width.
;
;   BAROFFSET:	A scalar that specifies the offset to be applied to the
;		first bar, in units of "nominal bar width".  This keyword 
;		allows, for example, different groups of bars to be overplotted
;		on the same graph.  If not specified, the default offset is
;		equal to BARSPACE.
;
;     OUTLINE:	If set, this keyword specifies that an outline should be 
;		drawn around each bar.
;
;    OVERPLOT:	If set, this keyword specifies that the bar plot should be
;		overplotted on an existing graph.
;
;  BACKGROUND:	A scalar that specifies the color index to be used for
;		the background color.  By default, the normal IDL background
;		color is used.
;
;	ROTATE:	If set, this keyword indicates that horizontal rather than
;		vertical bars should be drawn.  The bases of horizontal bars
;		are on the left, "Y" axis and the bars extend to the right.
;
; OUTPUTS:
;	A bar plot is created, or an existing one is overplotted.
;
; EXAMPLE:
;	By using the overplotting capability, it is relatively easy to create
;	stacked bar charts, or different groups of bars on the same graph.
;
;	For example, if ARRAY is a two-dimensional array of 5 columns and 8
;	rows, it is natural to make a plot with 5 bars, each of which is a
;	"stacked" composite of 8 sections.  First, create a 2D COLORS array,
;	equal in size to ARRAY, that has identical color index values across
;	each row to ensure that the same item is represented by the same color
;	in all bars.
;
;	With ARRAYS and COLORS defined, the following code fragment
;	illustrates the creation of stacked bars (note that the number of rows
;	and columns is arbitrary):
;
;	!Y.RANGE = [0,ymax] ; Scale range to accommodate the total bar lengths.
;	BASE = INTARR(NROWS)
;	FOR I = 0, NROWS-1 DO BEGIN
;	   BAR_PLOT, ARRAY(*,I), COLORS=COLORS(*,I), BASELINES=BASE, $
;	             BARWIDTH=0.75, BARSPACE=0.25, OVER=(I GT 0)
;	   BASE = BASE + ARRAY(*,I)
;	ENDFOR
;
;	To plot each row of ARRAY as a clustered group of bars within the same
;	graph, use the BASERANGE keyword to restrict the available plotting
;	region for each set of bars.  The sample code fragment below
;	illustrates this method:
;
;	FOR I = 0, NROWS-1 DO $
;	   BAR_PLOT, ARRAY(*,I), COLORS=COLORVECT, BARWIDTH=0.8,BARSPACE=0.2, $
;	     BAROFFSET=I*((1.0+BARSPACE)*NCOLS), OVER=(I GT 0), BASERANGE=0.19
;
;	where NCOLS is the number of columns in ARRAY, and COLORVECT is a
;	vector containing the color indices to be used for each group of
;	bars.  (In this example, each group uses the same set of colors, but
;	this could easily be changed.)
;
; MODIFICATION HISTORY:
;	August 1990, T.J. Armitage, RSI, initial programming.  Replacement
;	for PLOTBAR and OPLOTBAR routines written by William Thompson.
;
;	September 1990, Steve Richards, RSI, changed defaults to improve the
;	appearance of the bar plots in the default mode. Included
;	spacing the bars slightly.
;-

if (n_params(d) eq 0) then begin  ;Print call & return if no parameters
  print,'bar_test,values,baselines=baselines,colors=colors,barnames=barnames,$'
  print,' title=title,xtitle=xtitle,ytitle=ytitle,baserange=baserange, $'
  print,' barwidth=barwidth,barspace=barspace,baroffset=baroffset, $'
  print,' outline=outline,overplot=overplot,background=background, $'
  print,' rotate=rotate'
  return
endif

if n_elements(xmargin) eq 0 then xmargin = [4,4]
if n_elements(ymargin) eq 0 then ymargin = [4,4]
if n_elements(orientation) eq 0 then orientation = 0
if n_elements(spacing) eq 0 then spacing = 0 

case n_elements(yrange) of 
0:    begin & !y.range(0) = 0 & !y.range(1) = 0 & end 
else: begin & !y.range(0) = yrange(0) & !y.range(1) = yrange(1) & end
endcase
if n_elements(charsize) eq 0 then charsize = 1.0
if n_elements(charthick) eq 0 then charthick = 2.5 
!x.thick = 2.5 & !y.thick = 2.5 & !p.thick=2.5

nbars=n_elements(values)		; Determine number of bars
; Baselines (bars extend from baselines through values); default=0
if not(keyword_set(baselines)) then baselines=intarr(nbars)
; Default colors spaced evenly in current color table
if not(keyword_set(colors)) then $
   colors=fix((!d.n_colors/float(nbars))*(indgen(nbars)+0.5))
; Labels for the individual bars; none by default
if not(keyword_set(barnames)) then barnames=strarr(nbars)+' '
; Main title
if not(keyword_set(title)) then title=''
; Centered title under X-axis
if not(keyword_set(xtitle)) then xtitle=''
; Title for Y-axis
if not(keyword_set(ytitle)) then ytitle=''             
; Fraction (0-1) of full X range to use
if not(keyword_set(baserange)) then baserange=1.0
; Space betw. bars, taken from nominal bar widths; default is none
If not(keyword_set(barspace)) then barspace=0.2
; Bar width scaling factor, relative to nominal
if not(keyword_set(barwidth)) then barwidth=1.0 - barspace - barspace / nbars
; Initial X offset, in scaled bar widths; default is none
if not(keyword_set(baroffset)) then baroffset=barspace/barwidth
; Outline of bars; default is none
outline = keyword_set(outline)
; Overplot (do not erase the existing display); default is to create new plot
overplot = keyword_set(overplot)
; Background color index; defaults to 0 (usually black) if not specified
if not(keyword_set(background)) then background=0
; Rotate (make horizontal bars); default is vertical bars
rotate = keyword_set(rotate)

if (rotate) then begin				   ;Horizontal bars
   if (n_elements(xrange) eq 0) $  ;Determine range for X-axis
      then $
        xrange=[(min(baselines)<min(values)), $    ;Minimum of bases & values
                (max(baselines)>max(values))] $    ;Maximum of bases & values
      else xrange=xrange			   ;Or, use range specified
   yrange=!y.range				   ;Axis perpend. to bars
   yticks=1					   ;Suppress ticks in plot
   ytickname=strarr(2)+' '
   xticks=0
   xtickname=strarr(1)+''
endif else begin				   ;Vertical bars
   if (!y.range(0) eq 0) and (!y.range(1) eq 0) $  ;Determine range for Y-axis
      then $
        yrange=[(min(baselines)<min(values)), $    ;Minimum of bases & values
                (max(baselines)>max(values))] $    ;Maximum of bases & values
      else yrange=!y.range	           	   ;Or, use range specified
   xrange=!x.range				   ;Axis perpend. to bars
   xticks=1					   ;Suppress ticks in plot
   xtickname=strarr(2)+' '
   yticks=0
   ytickname=strarr(1)+''
endelse
if (overplot eq 0) then $			   ;Create new plot, no data
plot,[values],/nodata,title=title,xtitle=xtitle,ytitle=ytitle, $
   noerase=overplot,xrange=xrange,yrange=yrange,xticks=xticks, $
   xtickname=xtickname,yticks=yticks,ytickname=ytickname, $
   xstyle=1,/data,background=background,charsize=charsize,$
   charthick=charthick,xmargin=xmargin,ymargin=ymargin

if n_elements(spt) eq 0 then spt = replicate('',nbars)
if n_elements(xpt) eq 0 then xpt = replicate(1.1,nbars)
if n_elements(ypt) eq 0 then ypt = replicate(1.1,nbars)

for i=0,nbars-1 do xyouts,xpt(i),ypt(i),spt(i),/normal,alignment=0.5


if (rotate) then begin				   ;Horizontal bars
   base_win=!y.window				   ;Window range in Y
   scal_fact=!x.s				   ;Scaling factors
   tick_scal_fact=!y.s				   ;Tick scaling factors
endif else begin				   ;Vertical bars
   base_win=!x.window				   ;Window range in X
   scal_fact=!y.s				   ;Scaling factors
   tick_scal_fact=!x.s				   ;Tick scaling factors
endelse
winrange=baserange*(base_win(1)-base_win(0))	   ;Normal. window range
barsize=barwidth*winrange/nbars			   ;Normal. bar width
winoffset=base_win(0)+(baroffset*barsize)	   ;Normal. first offset
bases=scal_fact(0)+(scal_fact(1)*baselines)	   ;Baselines, in normal coor.
normal=scal_fact(0)+(scal_fact(1)*values)	   ;Values, in normal coor.
barstart=indgen(nbars)*(barsize+barspace*(winrange/nbars)) ;Coor. at left edges
tickv=winoffset+barstart+(0.5*barsize)		   ;Tick coor. (centered)
for i=0,nbars-1 do begin			   ;Draw the bars
   width=winoffset+[barstart(i),barstart(i), $     ;Compute bar width
     (barstart(i)+barsize),(barstart(i)+barsize)]
   length=[bases(i),normal(i),normal(i),bases(i)]  ;Compute bar length
   if (rotate) then begin			   ;Horizontal bars
      x=length					   ;X-axis is "length" axis
      y=width					   ;Y-axis is "width" axis
   endif else begin				   ;Vertical bars
      x=width					   ;X-axis is "width" axis
      y=length					   ;Y-axis is "length" axis
   endelse
   
   case 1 of
   (spacing eq 0): polyfill,x,y,color=colors(i),/normal
   else: polyfill,x,y,/normal,orientation=orientation,spacing=spacing
   endcase
   		  
   if (outline) then plots,x,y,/normal		   ;Outline using !p.color
endfor

tickv=(tickv-tick_scal_fact(0))/tick_scal_fact(1)  ;Locations of the ticks
if (rotate) then $				   ;Label the bars (Y-axis)
  axis,yaxis=0,ystyle=1,yticks=(nbars-1),ytickv=tickv,ytickname=barnames, $
  ticklen=0.0,charsize=charsize,charthick=charthick,$
  xmargin=xmargin,ymargin=ymargin $
else $						   ;Label the bars (X-axis)
  axis,xaxis=0,xstyle=1,xticks=(nbars-1),xtickv=tickv,xtickname=barnames, $
  ticklen=0.0,charsize=charsize,charthick=charthick,xmargin=xmargin,ymargin=$
  ymargin

return
end
