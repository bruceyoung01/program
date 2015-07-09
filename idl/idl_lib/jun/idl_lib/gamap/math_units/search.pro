; $Id: search.pro,v 1.1.1.1 2007/07/17 20:41:29 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SEARCH (function)
;
; PURPOSE:
;        Perform a binary search for the data point closest
;        to a given value. Data must be sorted.
;
; CATEGORY:
;        Math & Units
;
; CALLING SEQUENCE:
;        INDEX = SEARCH( DATA, VALUE )
;
; INPUTS:
;        DATA -> a sorted data vector
;
;        VALUE -> the value to look for
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        INDEX -> The function returns the index of the 
;             nearest data point.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        This routine is much faster than WHERE or MIN for
;        large arrays. It was written in response to a newsgroup
;        request by K.P. Bowman.
;
; EXAMPLE:
;        TEST = FINDGEN(10000)
;        PRINT, SEARCH( TEST, 532.3 )
;
;             ; prints 532
;
; MODIFICATION HISTORY:
;        mgs, 21 Sep 1998: VERSION 1.00
;        bmy, 24 May 2007: TOOLS VERSION 2.06
;                          - updated comments, cosmetic changes
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
; or phs@io.as.harvard.edu with subject "IDL routine search"
;-----------------------------------------------------------------------


function search, data, value
 
 
    ; search first occurence of value in data set
    ; data must be sorted
 
    ; simple error checking on data and value
    if (n_elements(value) eq 0) then begin
        message,'Must supply sorted data array and value),/CONT'
        return
    endif
 
    ndat = n_elements(data)
 
    try  = fix(0.5*ndat)
    step = 0.5*try
 
    ; find index of nearest points
    while (step gt 1) do begin

       if (data[try] gt value) $
          then try = try-step $
          else try = try+step

        step = fix(0.5*(step+1))

    endwhile
 
    ; now get the data point closest to value
    ; can only be one out of three (try-1, try, try+1)
    dummy = min( abs(value-data[try-1:try+1]), location )
 
    return,try+location-1
 
end
 
 
 
 
