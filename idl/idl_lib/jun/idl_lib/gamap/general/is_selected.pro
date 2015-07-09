; $Id: is_selected.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        IS_SELECTED (function)
;
; PURPOSE:
;        Return a boolean vector with 1 for each element of VAR
;        that is contained in SELECTION. This is a generalization
;        of WHERE(VAR eq value) in that value can be an array
;        instead of a single value.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        INDEX = IS_SELECTED(VAR,SELECTION)
;
; INPUTS:
;        VAR -> The data vector
;
;        SELECTION -> A vector with chosen values. If no selection
;            is given, the function returns a vector with all entries
;            set to zero.
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        INDEX -> An integer vector of length n_elements(VAR) 
;             that contains 1 for each element of VAR that has
;             one of the SELECTION values.
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
; EXAMPLES:
;        (1)
;        A = [ 1, 1, 1, 2, 2, 3 ]
;        B = [ 2, 3 ]
;        PRINT, IS_SELECTED( A, B )
;           0 0 0 1 1 1
;
;        (2)
;        PRINT, WHERE( IS_SELECTED( A, B ) )
;           3 4 5
;
;        ; (i.e. indices of A that correspond to a value of 2 or 3)
;        ; equivalent to:
;        print,where(A eq 2 or A eq 3)
;
; MODIFICATION HISTORY:
;        mgs, 19 Aug 1998: VERSION 1.00
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
; or phs@io.harvard.edu with subject "IDL routine is_selected"
;-----------------------------------------------------------------------


function is_selected,var,selection
 
   ; returns a boolean array with 1 for each item that is
   ; selected
 
   res = intarr(n_elements(var))
 
   for i=0,n_elements(selection)-1 do begin
      ind = where(var eq selection[i])
      if (ind[0] ge 0) then res[ind] = 1
   endfor
 
   return,res
end
 
 
