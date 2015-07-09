;-------------------------------------------------------------
; $Id: cum_total.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;+
; NAME:
;        CUM_TOTAL  (function)
;
; PURPOSE:
;        Compute cumulative total of a data vector.
;
; CATEGORY:
;        Math
;
; CALLING SEQUENCE:
;        result = CUM_TOTAL(Y)
;
; INPUTS:
;        Y -> The data vector
;
; KEYWORD PARAMETERS:
;        none.
;
; OUTPUTS:
;        A data vector with the same number of elements and the cumulative 
;        totals.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        See also function RUN_AV. 
;
; EXAMPLE:
;        y = findgen(10)
;        print,cum_total(y)
;        ; IDL prints:  0  1  3  6  10  15  21  28  36  45
;
; MODIFICATION HISTORY:
;        mgs, 21 Oct 1998: VERSION 1.00
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
; with subject "IDL routine cum_total"
;-------------------------------------------------------------


function cum_total,y
 
 
    if (n_elements(y) eq 0) then return,0.
    if (n_elements(y) eq 1) then return,y[0]
 
    result = dblarr(n_elements(y))
    result[0] = y[0]
 
    for i=1,n_elements(y)-1 do result[i] = result[i-1] + y[i]
    return,result
 
end
 
