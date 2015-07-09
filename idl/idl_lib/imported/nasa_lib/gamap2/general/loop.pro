; $Id: loop.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        LOOP
;
; PURPOSE:
;        This routine provides a wrapper for function calls that accept
;        only scalars so that they can operate on arrays.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        RESULT = LOOP( name, arg, p1, p2, p3, p4)
;
; INPUTS:
;        NAME -> the name of the function (string)
;
;        ARG -> the argument (array)
;
;        P1 .. P4 -> optional function parameters 
;
; KEYWORD PARAMETERS:
;        Unfortunately None. Would be nice if _EXTRA would work.
;
; OUTPUTS:
;        RESULT -> Vector with the same number of elements as ARG.
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
;        A  = [ 0.05, 0.01, 0.001 ]
;        PRINT, LOOP( "CHISQR_CVF", A, 17 )
;          27.5871   33.4087   40.7903
;
;             ; Define a vector of arguments and then then loop
;             ; thru the vector, calling CHISQR_CVF each time.
;             ; Then display the vector of results.
;
; MODIFICATION HISTORY:
;        mgs, 05 Dec 1997: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.harvard.edu with subject "IDL routine loop"
;-----------------------------------------------------------------------


function loop,name,arg,p1,p2,p3,p4
 
 
   on_error,2   ; return to caller
 
 
   result = fltarr(n_elements(arg))
 
; print,n_elements(p1),n_elements(p2),n_elements(p3),n_elements(p4)
   ; call function with number of parameters supplied
   ; not very elegant but safe.
   ; (would probably look nicer with EXECUTE, but isn't that slower ?)
 
   if (n_elements(p4) gt 0) then begin
       for i=0,n_elements(arg)-1 do   $
           result(i) = call_function(name,arg(i),p1,p2,p3,p4)
       return,result
   endif
 
   if (n_elements(p3) gt 0) then begin
       for i=0,n_elements(arg)-1 do   $
           result(i) = call_function(name,arg(i),p1,p2,p3)
       return,result
   endif
 
   if (n_elements(p2) gt 0) then begin
       for i=0,n_elements(arg)-1 do   $
           result(i) = call_function(name,arg(i),p1,p2)
       return,result
   endif
 
   if (n_elements(p1) gt 0) then begin
       for i=0,n_elements(arg)-1 do   $
           result(i) = call_function(name,arg(i),p1)
       return,result
   endif
 
 
   for i=0,n_elements(arg)-1 do   $
       result(i) = call_function(name,arg(i))
   return,result
 
end
