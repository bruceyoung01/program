;-------------------------------------------------------------
; $Id: pwd.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $
;+
; NAME:
;        PWD
;
; PURPOSE:
;        Print current working directory
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        PWD [,result]
;
; INPUTS:
;        none
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        RESULT -> (optional) string containing the current directory
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        Set !QUIET to 1 if you only want to return the working directory
;        but no screen output.
;
; EXAMPLE:
;        pwd
;
; MODIFICATION HISTORY:
;        mgs, 23 Dec 1998: VERSION 1.00
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
; with subject "IDL routine pwd"
;-------------------------------------------------------------


pro pwd,result
 
   cd,current=result
   message,'Current directory is '+result,/INFO,/NONAME
 
return
end
 
