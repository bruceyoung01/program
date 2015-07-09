; $Id: pwd.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PWD
;
; PURPOSE:
;        Print current working directory
;
; CATEGORY:
;        General
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
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Set !QUIET to 1 if you only want to return the working directory
;        but no screen output.
;
; EXAMPLE:
;        PWD
;             ; Prints current directory.
;
; MODIFICATION HISTORY:
;        mgs, 23 Dec 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine pwd"
;-----------------------------------------------------------------------


pro pwd,result
 
   cd,current=result
   message,'Current directory is '+result,/INFO,/NONAME
 
   return
end
 
