; $Id: get_defaultformat.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GET_DEFAULTFORMAT (function)
;
; PURPOSE:
;        Return format string that will produce legible and
;        concise strings for a given value range. The format
;        should be applied in a string() statement and the 
;        string should be trimmed.
;
; CATEGORY:
;        String handling
;
; CALLING SEQUENCE:
;        myformat = GET_DEFAULTFORMAT(minval,maxval [,/LOG])
;
; INPUTS:
;        MINVAL, MAXVAL -> the range of values that shall be 
;            displayed with this format.
;
; KEYWORD PARAMETERS:
;        /LOG -> set this keyword if you plan logarithmic labels.
;            (changes behaviour for 0.001)
;
;        DEFAULTLEN -> 1 or 2 strings with the default length 
;            specification for 'f' and 'e' formats. If only one
;            string is passed, it will be used for both, otherwise
;            the first string applies to 'f' and the second to 'e'.
;            Example: DEFAULTLEN='10.3' results in 'f10.3'.
;
;        THRESHOLD -> threshold value to switch from 'f' to 'e' format.
;            Default is '2' for linear and '3' for log scale. This
;            value is determined by the negative decadal log of (maxv-minv)
;            plus 2.
;
; OUTPUTS:
;        A format string (e.g. '(f14.2)' )
;
; SUBROUTINES:
;        none
;
; REQUIREMENTS:
;        none
;
; NOTES:
;
; EXAMPLE:
;        print,get_defaultformat(0.01,1.)
;
;        returns  '(f14.2)'
;
;        print,get_defaultformat(0.0001,0.01)
;
;        returns  '(e12.3)'
;
; MODIFICATION HISTORY:
;        mgs, 17 Mar 1999: VERSION 1.00
;        mgs, 25 Mar 1999: - added DEFAULTLEN keyword
;        mgs, 19 May 1999: - DEFAULTLEN now converted to string.
;                          - added THRESHOLD keyword
;        bmy, 27 Sep 2002: TOOLS VERSION 1.51
;                          - made default exponential format e12.2
;
;-
; Copyright (C) 1999, Martin Schultz;
;               2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine get_defaultformat"
;-----------------------------------------------------------------------


function get_defaultformat,minv,maxv,log=log,  $
        defaultlen=defaultlen,threshold=threshold


ON_ERROR,2 

    ; return default format string depending on min and max value
    ; and log flag

    log = keyword_set(log) 

    if (n_elements(defaultlen) eq 1) then  $
        defaultlen = [ defaultlen, defaultlen ]

    ;---------------------------------------------------
    ; Prior to 9/28/02:
    ;if (n_elements(defaultlen) ne 2) then  
        ;defaultlen = [ '14.2', '12.3' ]
    ;---------------------------------------------------
    if (n_elements(defaultlen) ne 2) then defaultlen = [ '14.2', '12.2' ]

    if (n_elements(threshold) ne 1) then threshold = 2
    if (log) then threshold = threshold + 1
 
    res = '(f'+strtrim(defaultlen[0],2)+')'    ; general default

    if (n_elements(minv) eq 0) then return,res
    if (n_elements(maxv) eq 0) then begin
       message,'You must supply MINV and MAXV!'
    endif
 
    ; determine necessary number of decimal places
    ndec = fix( 2.-alog10( (maxv-minv) > 1.0E-31 ) )
    ndecmin = fix( 2.-alog10( minv > 1.0E-31 ) )
 
    if (keyword_set(log)) then ndec = max([ndec,ndecmin-1])

; print,'## ndec, ndecmin : ',ndec,ndecmin
 
    if (ndec gt threshold) then res = '(e'+strtrim(defaultlen[1],2)+')'   ; e-default
 ;  if (ndec eq threshold+1 AND log) then res = '(f'+strtrim(defaultlen[0],2)+')' 
    if (ndec le 0) then res = '(I14)'
    if (ndec le -6) then res = '(e'+strtrim(defaultlen[1],2)+')'
 
    return,res
 
end
 
 
