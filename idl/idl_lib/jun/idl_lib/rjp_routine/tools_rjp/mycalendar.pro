; $Id: calendar.pro,v 1.7 1999/05/28 16:37:28 ali Exp $
;
; Copyright (c) 1988-1999, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;

;+
; NAME:
;	CALENDAR
;
; PURPOSE:
;	Display a calandar for a month or an entire year using IDL's
;	plotting subsystem. This IDL routine imitates the Unix cal
;	command.
;
; CATEGORY:
;	Misc.
;
; CALLING SEQUENCE:
;	CALENDAR
;	CALENDAR, YEAR
;	CALENDAR, MONTH, YEAR
;
; INPUTS:
;	If called without arguments, CALENDAR draws a calendar for the
;	current month.
;
;	MONTH:  The number of the month for which a calandar is
;		desired (1 is January, 2 is February, ..., 12 is December).
;
;	YEAR:   The number of the year for which a calendar should be
;		drawn. If YEAR is provided without MONTH, a calendar
;		for the entire year is drawn.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	The specified calandar is drawn on the current graphics device.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; MODIFICATION HISTORY:
;	AB, September, 1988
;-
;


pro CAL_INFO, MONTH, YEAR, START_SQUARE, NUM_DAYS

  compile_opt hidden

L_MONTH = MONTH - 1
MONTHS = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

DAY = (JULDAY(1, 1, YEAR) + 1) MOD 7
DAY1_NEXT_YEAR = (JULDAY(1, 1, YEAR+1) + 1) MOD 7

case ((DAY1_NEXT_YEAR + 7 - DAY) mod 7) of
	2 :
	1 : MONTHS[1] = 28	; Not a leap year
	else: MONTHS[8] = 19	; 1752
	endcase

for I = 0, L_MONTH - 1 do DAY = DAY + MONTHS[I]
START_SQUARE = (DAY MOD 7)
NUM_DAYS = MONTHS[L_MONTH]
end






pro DRAW_CAL, XR, YR, MONTH, YEAR, SMALL

  compile_opt hidden

MONTHS = ['January','February','March','April','May','June','July','August', $
	  'September','October','November','December']

x_range = xr[1] - xr[0]
y_range = yr[1] - yr[0]
if (SMALL) then y_div = 7. else y_div = 6.
x_delta = x_range / 7.
y_delta = y_range / y_div

TSIZE = 2.5 * x_range
if (SMALL) then TSIZE = TSIZE * 1.75

if (not SMALL) then begin
    ; Frame
    plots,/norm,[xr[0],xr[1],xr[1],xr[0],xr[0]],[yr[0],yr[0],yr[1],yr[1],yr[0]],$
    color=1
    ; Draw Vertical lines
    y = yr[1] - y_delta
    for i = 1,6 do begin x=xr[0]+ i*x_delta & plots,[x,x],[yr[0],y],/norm,color=1 & end
    ; Draw Horizontal lines
    for i=0,y_div do begin y=yr[0]+i*y_delta & plots,[xr[0],xr[1]],[y,y], $
	/norm,color=1 & end
    endif

; Month and year title
if (SMALL) then begin
	x = xr[0] + 3.5 * x_delta
	y = yr[0] + 6.6 * y_delta
	xyouts,/norm,size=TSIZE*1.6, align=.5, x, y, MONTHS[MONTH-1],color=1
    endif else begin
	x = xr[0] + 1.5 * x_delta
	y = yr[0] + 5.5 * y_delta
	xyouts,/norm,size=TSIZE*.9, align=.5, x, y, MONTHS[MONTH-1],color=1
	x = xr[0] + 5.5 * x_delta
	xyouts,/norm,size=TSIZE*.9,align=.5, x, y, $
		strcompress(string(YEAR),/rem),color=1
    endelse

; Day titles
if (SMALL) then begin
	DAYS = ['S', 'M', 'T', 'W', 'T', 'F', 'S']
	DAYSIZE = TSIZE * .75
	y = yr[0] + 5.8 * y_delta
	y_factor = .25
    endif else begin
	DAYS = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
	DAYSIZE = TSIZE * .6
	y = yr[0] + 5.1 * y_delta
    endelse
for I = 0, 6 do xyouts,/norm,size=DAYSIZE, align=.5, $
	xr[0] + (I + .5) * x_delta , y, DAYS[I],color=1

; Calculate Horizontal and Vertical positions
X = fltarr(7)
Y = fltarr(y_div)
if (SMALL) then begin
	for i = 0, 5 do Y[I] = yr[0] + (5-I) * y_delta
	for i = 0, 6 do X[I] = xr[0] + (I - .5) * x_delta
	NALIGN = .5			; Center numbers
	NSIZE = TSIZE
    endif else begin
	J = 0
	for i = 4.65, .5, -1 do begin
	    Y[J] = i
	    J = J + 1
	    endfor
	Y[5] = .3 
	for i = 0, 5 do Y[I] = yr[0] + Y[I] * y_delta
	for i = 0, 6 do X[I] = xr[0] + (I + .95) * x_delta
	NALIGN = 1.			; Right justify
	NSIZE = TSIZE 
    endelse

; Get starting square and number of days in month
CAL_INFO, MONTH, YEAR, COL, NUM_DAYS
ROW = 0

; Numbers
for I = 1, NUM_DAYS do begin
    if (COL gt 6) then begin ROW = ROW + 1 & COL = 0 & endif
    xyouts, /norm, size=TSIZE, align = NALIGN, X[COL], Y[ROW], I,color=1
    COL = COL + 1
    endfor

end







pro MYCALENDAR , MONTH, YEAR

ON_ERROR, 2		; Return to caller if errors

MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG', $
	  'SEP','OCT','NOV','DEC']

; Process the input
NP = n_params()
case NP of
	0: begin
	    DATE = systime()
	    L_MONTH = long(where(strupcase(strmid(DATE, 4, 3)) eq MONTHS))
	    L_MONTH = L_MONTH[0] + 1	; Scalarize it...
	    L_YEAR = long(strmid(DATE, 20, 4))
	    end
	1: begin
	    L_YEAR=LONG(MONTH)		; Only 1 parm, take it as year
	    DO_ALL_YEAR = 1
	    end
	2: begin
	    L_MONTH = LONG(MONTH)
	    L_YEAR=LONG(YEAR)
	    end
	else: message, 'Wrong number of parameters.'
	endcase

erase
if (NP eq 1) then begin
	x_delta = .2325
	y_delta = .28
	l = .025
	r = .975
	plots,/norm,[l,r,r,l,l],[l,l,r,r,l],color=1
;	plots,/norm,[l,r],[.9,.9]
	xyouts,/norm,size=2.75,align=.5, .5, .9, $
		strcompress(string(L_YEAR),/rem),color=1
	cur = 1
	for i = 2, 0, -1 do for j = 0, 3 do begin
	    DRAW_CAL, [l + (j+.1)*x_delta, l + (j+1)*x_delta], $
		[l + l + i*y_delta, l + (i+1)*y_delta], cur, L_YEAR, 1
	    CUR = CUR + 1
	    endfor
    endif else begin
	DRAW_CAL, [.025, 0.975], [.025, .975], L_MONTH, L_YEAR, 0
    endelse

end
