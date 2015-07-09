; $Id: strdate.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        STRDATE
;
; PURPOSE:
;        format a "standard form" date string 
;
; CATEGORY:
;        date and time functions
;
; CALLING SEQUENCE:
;        result=STRDATE([DATE][,keywords])
;
; INPUTS:
;        DATE --> (optional) Either a up to 6 element array
;            containing year, month, day, hour, minute, and secs
;            (i.e. the format returned from BIN_DATE) or
;            a structure containing year, month, day, hour, minute, seconds
;            (as returned from tau2yymmdd) or a date string in "standard" 
;            format as returned by SYSTIME(0). 
;            If DATE is omitted, STRDATE will automatically 
;            return the current system time. 
;
; KEYWORD PARAMETERS:
;        SHORT --> omit the time value, return only date
;
;        SORTABLE --> will return 'YYYY/MM/DD HH:MM' 
;
;        GERMAN --> will return 'DD.MM.YYYY HH:MM'
;
;        IS_STRING --> indicates that DATE is a date string rather
;            than an integer array. This keyword is now obsolete but kept
;            for compatibility.
;
; OUTPUTS:
;        A date string formatted as 'MM/DD/YYYY HH:MM'.
;        If SHORT flag is set, the format will be 'MM/DD/YYYY'
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        /GERMAN and /SORTABLE will have effect of SORTABLE but
;        with dots as date seperators.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 11 Nov 1997: VERSION 1.00
;        mgs, 26 Mar 1998: VERSION 1.10 
;            - examines type of DATE parameter and accepts structure input.
;
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine strdate"
;-------------------------------------------------------------


function strdate,date,is_string=is_string, $
            short=short,sortable=sortable,german=german
 
 
; on_error,2
 
 
if(n_elements(date) gt 0) then begin

    ; analyze format of DATE
    s = size(date)
    dtype = s(s(0)+1)
    if (dtype eq 7) then is_string = 1 else is_string=0
    if (dtype eq 8) then is_stru = 1 else is_stru=0

    if(is_string) then bdate=bin_date(date) $ 
    else if(is_stru) then begin
             bdate = intarr(6)
             for i=0,5 do bdate(i) = fix(date.(i))
         endif else bdate = date

endif else bdate = bin_date()    ; insert system time

 
; in case of not enough elements pad with zero's
tmp = intarr(6)
bdate = [bdate,tmp]
 
; convert to formatted string items
bdate = strtrim(string(bdate,format='(i4.2)'),2)
 
; and compose result string
; determine date seperator
if(keyword_set(german)) then sep='.' else sep='/'
; default : US format
   result = bdate(1)+sep+bdate(2)+sep+bdate(0)
; german format, day first
if (keyword_set(german)) then $
   result = bdate(2)+sep+bdate(1)+sep+bdate(0)
; sortable: year month day
if(keyword_set(sortable)) then $
   result = bdate(0)+sep+bdate(1)+sep+bdate(2)

if (not keyword_set(SHORT)) then  $
    result = result+' '+bdate(3)+':'+bdate(4)
 
return,result
 
end
 
