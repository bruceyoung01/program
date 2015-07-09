; $Id: testpath.pro,v 1.1.1.1 2007/07/17 20:41:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        TESTPATH
;
; PURPOSE:
;        Set !PATH variable to a limited set of directories for test
;        purposes (or restore the initial value)
;
; CATEGORY:
;        File & I/O
;
; CALLING SEQUENCE:
;        TESTPATH [,pathstring] [,/restore]
;
; INPUTS:
;        PATHSTRING -> a string with the test directory name(s)
;             The !PATH variable will contain this string plus the
;             standard IDL library search path [which is hardwired
;             and may have to be changed after future updates].
;             Note: This parameter is ignored if the /RESTORE keyword 
;             is set.
;
; KEYWORD PARAMETERS:
;        /RESTORE -> restore initial value of !PATH. This is always
;             the value before the very first call to testpath! Use
;             of this keyword overrides the PATHSTRING parameter.
;
; OUTPUTS:
;        None
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
;        testpath,'~mgs/IDL/test3d'
;        ; sets !PATH to the given name + standard IDL libraries
;
;        testpath,/restore
;        ; resets !PATH variable to original value
;
; MODIFICATION HISTORY:
;        mgs, 16 Jun 1998: VERSION 1.00
;        mgs, 02 Nov 1998: - changed IDL path from idl5 to idl
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
; or phs@io.as.harvard.edu with subject "IDL routine testpath"
;-----------------------------------------------------------------------


pro testpath,path,restore=restore
 
    common storepath,oldpath
 
 
    ; restore old path and exit if requested
    if (keyword_set(restore) and n_elements(oldpath) gt 0) then begin
       !path = oldpath
       return
    endif
 
 
    ; otherwise set "minimal" path with passed directory and
    ; IDL system libraries
    if (n_elements(path) eq 0) then path = '' $
    else path = path + ':'
 
    ; store current !path in oldpath only on first call
    if (n_elements(oldpath) eq 0) then oldpath = !path
 
    ; set !path to test directory(ies) and append standard IDL stuff
    !path = path + expand_path('+/usr/local/lib/rsi/idl')
 
    return
end
 
 
