; $Id: ctm_validatestructures.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_VALIDATESTRUCTURES
;
; PURPOSE:
;        Test validity of a FileInfo and DataInfo structure
;        or structure array.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_VALIDATESTRUCTURES,FILEINFO,DATAINFO,result=result, $
;              print_warn=print_warn
;
; INPUTS:
;        FILEINFO -> A FileInfo structure (array) to be tested
;
;        DATAINFO -> A DataInfo (array) to be tested
;
;        Both arguments must be present!
;
; KEYWORD PARAMETERS:
;        RESULT -> A named variable that will be set to 1 if
;            both structures are valid. This keyword is mandatory.
;
;        PRINT_WARN -> print a warning message on the screen if
;            a structure is non-existent or corrupt.
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses ROUTINE_NAME and CHKSTRU functions
;
; NOTES:
;
; EXAMPLE:
;        CTM_VALIDATESTRUCTURES,FileInfo,DataInfo,result=result
;        if (not result) then return
;
; MODIFICATION HISTORY:
;        mgs, 20 Aug 1998: VERSION 1.00
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
; with subject "IDL routine ctm_validatestructures"
;-------------------------------------------------------------


pro ctm_validatestructures,fileinfo,datainfo,result=result, $
            print_warn=print_warn
 
 
 
    FORWARD_FUNCTION routine_name
 
 
    print_warn = keyword_set(print_warn)
 
    result = 0
 
    callername = strupcase( routine_name(/CALLER) )
 
    ; ------------------------------------------------------------ 
    ; first test: do FileInfo and DataInfo contain anything?
    ; ------------------------------------------------------------ 
 
    if (n_elements(FileInfo) eq 0) then begin
       if (print_warn) then $
          print,'*** '+callername+ $    
                ': FileInfo structure contains no elements!'
       return
    endif
 
    if (n_elements(DataInfo) eq 0) then begin
       if (print_warn) then $
          print,'*** '+callername+  $
                ': DataInfo structure contains no elements!'
       return
    endif
 
 
    ; ------------------------------------------------------------ 
    ; second test: check for validity of structures
    ; (should suffice to test a few tags)
    ; ------------------------------------------------------------ 
 
    if (not chkstru(FileInfo,['FILENAME','ILUN']) ) then begin
       if (print_warn) then $
          print,'*** '+callername+': Corrupted FileInfo structure!'
       return
    endif
 
    if (not chkstru(DataInfo,['CATEGORY',  $
             'TRACER','FILEPOS']) ) then begin
       if (print_warn) then $
          print,'*** '+callername+': Corrupted DataInfo structure!'
       return
    endif
 
 
    ; ------------------------------------------------------------ 
    ; passed all tests
    ; ------------------------------------------------------------ 
 
    result = 1
 
    return
 
end
