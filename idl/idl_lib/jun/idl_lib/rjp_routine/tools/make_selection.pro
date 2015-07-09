; $Id: make_selection.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        MAKE_SELECTION (function)
;
; PURPOSE:
;        Convert an array of selected values to an index
;        array that identifies the selected values in a list
;        or data array. 
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        index = MAKE_SELECTION(NAMES,SELNAMES [,keywords])
;
; INPUTS:
;        NAMES -> A list or array of values to choose from 
;
;        SELNAMES -> A list of selected values
;
; KEYWORD PARAMETERS:
;        ONLY_VALID -> Return only indices of found values. Values not
;            found are skipped. Default is to return 1 index value for
;            each SELNAME, which is -1 if SELNAME is not contained in 
;            NAMES. If ONLY_VALID is set, the -1 values will be deleted,
;            and a value of -1 indicates that no SELNAME has been found
;            at all.
;
;        REQUIRED -> Normally, MAKE_SELECTION will return indices for
;            all values that are found, simply ignoring the selected
;            values that are not in the NAMES array (although an error
;            message is displayed). Set this keyword to return with
;            -1 as soon as a selected value is not found.
;
;        QUIET -> Suppress printing of the error message if a
;            selected value is not found (the error condition will
;            still be set).
;
; OUTPUTS:
;        A (long) array with indices to reference the selected values
;        in the NAMES array.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        If the NAMES array contains multiple entries of the same value,
;        only the index to the first entry will be returned.
;
;        A selection can contain multiple instances of the same value.
;        The index array will contain one entry per selected item
;        (See example below)
;
; EXAMPLE:
;        names = [ 'Alfred','Anton','Peter','John','Mary']
;        index = MAKE_SELECTION(names,['Peter','Mary'])
;        print,index
;        ; prints  2  4
;
;        vals = indgen(20)
;        index = MAKE_SELECTION(vals,[9,-5,8,7,7,8,9])
;        print,index
;        ; prints  9  -1  8  7  7  8  9
;
;        index = MAKE_SELECTION(vals,[9,-5,8,7,7,8,9],/ONLY_VALID)
;        print,index
;        ; prints  9  8  7  7  8  9
;
;        index = MAKE_SELECTION(vals,[9,-5,8,7,7,8,9],/REQUIRED)
;        print,index
;        ; prints  -1
;
;
; MODIFICATION HISTORY:
;        mgs, 28 Aug 1998: VERSION 1.00
;        mgs, 29 Aug 1998: - changed behaviour and added ONLY_VALID keyword
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
; with subject "IDL routine make_selection"
;-------------------------------------------------------------


function make_selection,names,selnames,  $
            only_valid=only_valid,required=required,  $
            quiet=quiet
 
 
 
    ; return an index array with a number for each element in 
    ; selnames that is found in names.
    ; Set the REQUIRED keyword to return -1 if one element is
    ; not found, otherwise -1 will only be returned, if no 
    ; element is found.
 
    ; reset error state to 0
    message,/reset
 
    quiet = keyword_set(quiet)
    result = -1L
 
    for i=0,n_elements(selnames)-1 do begin
       test = where(names eq selnames[i])
       result = [ result, test[0] ] 
       if (test[0] lt 0) then begin
           if (keyword_set(ONLY_VALID) OR keyword_set(REQUIRED)) then $
              message,'Selected name not found in names array ('+ $
                      strtrim(selnames[i],2)+')!',/CONT,NOPRINT=quiet
           if (keyword_set(required)) then return,-1L
       endif
    endfor
 
    if (n_elements(result) gt 1) then result = result[1:*]

    if (keyword_set(only_valid)) then begin
        ind = where(result ge 0)
        if (ind[0] ge 0) then result = result[ind] $
        else result = -1L
    endif
 
    return,result
 
end
