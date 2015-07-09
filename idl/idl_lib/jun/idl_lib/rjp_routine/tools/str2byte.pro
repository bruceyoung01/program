; $Id: str2byte.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        STR2BYTE (function)
;
; PURPOSE:
;        Convert a string into a byte vector of a given length
;        for output in binary data files.
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        bstr = STR2BYTE(string [,length])
;
; INPUTS:
;        STRING -> The string to be converted
;
;        LENGTH -> Length of the byte vector. Default is to use the 
;            length of the string. If LENGTH is shorter, the string
;            will be truncated, if it is longer, it will be filled 
;            with blanks (32B).
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        A byte vector of the specified length
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        ; write a 80 character string into a binary file
;        openw,lun,'test.dat',/F77_UNFORMATTED,/get_lun
;        writeu,lun,str2byte('Test string',80)
;        free_lun,lun
;
; MODIFICATION HISTORY:
;        mgs, 24 Aug 1998: VERSION 1.00
;
;-
; Copyright (C) 1998, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine str2byte"
;-------------------------------------------------------------


function str2byte,str,len
 
    if (n_elements(str) eq 0) then return,[0B]
 
    ; if len argument is not given, use actual string size
    if (n_elements(len) eq 0) then len=strlen(str)
    if (len le 0) then return,[0B]
 
    ; convert string to byte; cut if too long
    bytstr = byte(strmid(str,0,len))  
 
    ; make result array of desired length
    result = bytarr(len)+32B    ; byte array, fill with spaces
 
    ; copy string into result array 
    result[0:n_elements(bytstr)-1] = bytstr
   
    return,result
 
end
 
