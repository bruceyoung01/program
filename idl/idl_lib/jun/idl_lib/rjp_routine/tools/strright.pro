; $Id: strright.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        STRRIGHT
;
; PURPOSE:
;        return right subportion from a string
;
; CATEGORY:
;        string handling 
;
; CALLING SEQUENCE:
;        res = STRRIGHT(string [,nlast])
;
; INPUTS:
;        STRING --> the string to be searched
;
;        NLAST --> the number of characters to be returned. Default
;           is 1. If NLAST is ge strlen(STRING), the complete string
;           is returned.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        The portion of NLAST characters of STRING counted from the back.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        if (strright(path) ne '/') then path = path + '/'
;
; MODIFICATION HISTORY:
;        mgs, 19 Nov 1997: VERSION 1.00
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
; with subject "IDL routine strright"
;-------------------------------------------------------------


function strright,s,lastn
 
    on_error,2   ; return to caller
 
    if (n_elements(s) le 0) then return,-1L
 
    l = strlen(s)
 
    if (n_elements(lastn) le 0) then lastn = 1
    if lastn gt l then lastn = l
 
    result = strmid(s,l-lastn,l)
 
    return,result
end
