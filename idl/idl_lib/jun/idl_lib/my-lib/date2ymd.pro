;-------------------------------------------------------------
;+
; NAME:
;       DATE2YMD
; PURPOSE:
;       Date text string to the numbers year, month, day.
; CATEGORY:
; CALLING SEQUENCE:
;       date2ymd,date,y,m,d
; INPUTS:
;       date = date string.		in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y = year number.		out
;       m = month number.		out
;       d = day number.		out
; COMMON BLOCKS:
; NOTES:
;       Notes: The format of the date is flexible except that the
;         month must be month name.
;         Dashes, commas, periods, or slashes are allowed.
;         Some examples: 23 sep, 1985     sep 23 1985   1985 Sep 23
;         23/SEP/85   23-SEP-1985   85-SEP-23   23 September, 1985.
;         Doesn't check if month day is valid. Doesn't
;         change year number (like 86 does not change to 1986).
;         Dates may have only 2 numeric values, year and day. If
;         both year & day values are < 31 then day is assumed first.
;         systime() can be handled: date2ymd,systime(),y,m,d
;         For invalid dates y, m and d are all set to -1.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 29 Oct, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       25-Nov-1986 --- changed to REPCHR.
;       RES 18 Sep, 1989 --- converted to SUN.
;       R. Sterner, 1994 Mar 29 --- Modified to handle arrays.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro date2ymd_1,date,y,m,d, help=hlp
 
	;----  Get just date part of string  -----
	dt_tm_brk, date, dt, tmp
 
	;----  Edit out punctuation  -------
	dt = repchr(dt,'-')  	; from dt replace all - by space.
	dt = repchr(dt,'/')    	; from dt replace all / by space.
	dt = repchr(dt,',')	; from dt replace all , by space.
	dt = repchr(dt,'.')	; from dt replace all . by space.
 
	;----  Want 1 monthname and 2 numbers. Start counts at 0.  -----------
	nmn = 0			; Number of month names found is 0.
	nnm = 0			; Number of numbers found is 0.
	nums = [0]		; Start numbers array.
 
	;----  Loop through words in text string  -------------
	for iw = 0, nwrds(dt)-1 do begin
	  wd = strupcase(getwrd(dt,iw))	; Get word as upper case.
	  ;---- check if month name  -------
	  txt = strmid(wd,0,3)		; Check only first 3 letters.
	  i = strpos('JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC',txt)  ; find month.
	  if i ge 0 then begin		; Found month name.
	    m = 1 + i/3			; month number.
	    nmn = nmn + 1		; Count month name.
	    goto, skip			; Skip over number test.
	  endif
	  ;----  Check for a number  -------
	  if isnumber(wd) then begin
	    nnm = nnm + 1		; Count number.
	    nums = [nums,wd+0]		; Store it.
	  endif
skip:
	endfor
 
	;----  Test for only 1 month name  -------
	if nmn ne 1 then begin		; Must be exactly 1 month name.
	  y = -1
	  m = -1
	  d = -1
	  return
	endif
 
	;----  Look for y and m -----
	if nnm ne 2 then begin		; Must be exactly 2 numeric items.
	  y = -1
	  m = -1
	  d = -1
	  return
	endif
	nums = nums(1:*)		; Trim off leading 0.
	if max(nums) gt 31 then begin	; Assume a number > 31 is the year.
	  y = max(nums)
	  d = min(nums)
	  return
	endif
	if min(nums) eq 0 then begin	; Allow a year of 0 (but not a day).
	  y = min(nums)
	  d = max(nums)
	  return
	endif				; Both < 31, assume day was first.
	d = nums(0)
	y = nums(1)
	return
 
	end
 
 
;===============================================================
;	Wrapper to feed single values to the main routine.
;===============================================================
	pro date2ymd,date,y,m,d, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Date text string to the numbers year, month, day.'
	  print,' date2ymd,date,y,m,d
	  print,'   date = date string.		in'
	  print,'   y = year number.		out'
	  print,'   m = month number.		out'
	  print,'   d = day number.		out'
	  print,' Notes: The format of the date is flexible except that the'
	  print,'   month must be month name.'
	  print,'   Dashes, commas, periods, or slashes are allowed.
	  print,'   Some examples: 23 sep, 1985     sep 23 1985   1985 Sep 23'
	  print,'   23/SEP/85   23-SEP-1985   85-SEP-23   23 September, 1985.'
	  print,"   Doesn't check if month day is valid. Doesn't"
	  print,'   change year number (like 86 does not change to 1986).'
	  print,'   Dates may have only 2 numeric values, year and day. If'
	  print,'   both year & day values are < 31 then day is assumed first.'
	  print,'   systime() can be handled: date2ymd,systime(),y,m,d
	  print,'   For invalid dates y, m and d are all set to -1.'
	  return
	endif
 
	n = n_elements(date)
 
	y = intarr(n)
	m = intarr(n)
	d = intarr(n)
 
	for i = 0, n-1 do begin
	  date2ymd_1, date(i), yy, mm, dd
	  y(i) = yy
	  m(i) = mm
	  d(i) = dd
	endfor
 
	if n eq 1 then begin	; Return scalars for a scalar input.
	  y = y(0)
	  m = m(0)
	  d = d(0)
	endif
 
	return
	end

