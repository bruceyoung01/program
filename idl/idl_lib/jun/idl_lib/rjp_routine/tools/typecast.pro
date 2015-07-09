; $Id: typecast.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        TYPECAST (function)
;
; PURPOSE:
;        Convert a numeric variable to a different type
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        newdata = TYPECAST(data,newtype)
;
; INPUTS:
;        DATA -> The data to convert. This can be a single value,
;            a vector or array of any numeric type.
;
;        NEWTYPE -> type code to convert data into. If not given,
;            the function simply returns data as is.
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        The data value/array with new type.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        a=3.14159
;        help,typecast(a,1)  ; prints    BYTE     = 3
;        help,typecast(a,2)  ; prints    INT      = 3
;        help,typecast(a,3)  ; prints    LONG     = 3
;        help,typecast(a,4)  ; prints    FLOAT    = 3.14159
;        help,typecast(a,5)  ; prints    DOUBLE   = (3.1415901, 0.0)
;        help,typecast(a,6)  ; prints    COMPLEX  = 3.14159
;        help,typecast(a,7)  ; prints    DCOMPLEX = (3.1415901, 0.0)
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
; with subject "IDL routine typecast"
;-------------------------------------------------------------


function typecast,data,newtype
 
 
    ; convert data to a new type
 
    if (n_elements(data) eq 0) then return,!VALUES.F_NAN
 
 
    ; get type information
    ctype = size(data,/type)
 
    ; set default to old type if not given
    if (n_elements(newtype) eq 0) then newtype = ctype
 
 
    case newtype of
       0 : begin
           result = string(data,format=format)
           if (keyword_set(trim)) then result = strtrim(result,2)
           return,result
           end
       1 : return,byte(data)
       2 : return,fix(data)
       3 : return,long(data)
       4 : return,float(data)
       5 : return,double(data)
       6 : return,complex(data)
       7 : return,dcomplex(data)
    else : begin
           print,'*** TYPECAST: Cannot convert to type ',strtrim(newtype,2)
           return,data
           end
    endcase
 
 
end
           
