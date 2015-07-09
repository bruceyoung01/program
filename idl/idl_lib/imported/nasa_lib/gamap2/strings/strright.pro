; $Id: strright.pro,v 1.1.1.1 2007/07/17 20:41:48 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        STRRIGHT
;
; PURPOSE:
;        Return right subportion from a string
;
; CATEGORY:
;        Strings 
;
; CALLING SEQUENCE:
;        RESULT = STRRIGHT( STRING [,nlast] )
;
; INPUTS:
;        STRING -> the string to be searched
;
;        NLAST -> the number of characters to be returned. 
;             Default is 1. If NLAST is ge strlen(STRING), 
;             the complete string is returned.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> The portion of NLAST characters of STRING 
;             counted from the back.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        IF ( STRRIGHT( PATH ) NE '/' ) THEN PATH = PATH + '/'
;
;             ; Add a slash to a directory name if necessary
;
; MODIFICATION HISTORY:
;        mgs, 19 Nov 1997: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments
;
;-
; Copyright (C) 1997-2007, Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine strright"
;-----------------------------------------------------------------------


function strright,s,lastn
 
    on_error,2   ; return to caller
 
    if (n_elements(s) le 0) then return,-1L
 
    l = strlen(s)
 
    if (n_elements(lastn) le 0) then lastn = 1
    if lastn gt l then lastn = l
 
    result = strmid(s,l-lastn,l)
 
    return,result
end
