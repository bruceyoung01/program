; $Id: percentiles.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        PERCENTILES
;
; PURPOSE:
;        compute percentiles of a data array
;
; CATEGORY:
;        statistical function
;
; CALLING SEQUENCE:
;        Y = PERCENTILES(DATA [,VALUE=value-array])
;
; INPUTS:
;        DATA --> the vector containing the data
;
; KEYWORD PARAMETERS:
;        VALUE --> compute specified percentiles
;        default is a standard set of min, 25%, median (=50%), 75%, and max
;        which can be used for box- and whisker plots.
;        The values in the VALUE array must lie between 0. and 1. !
;
; OUTPUTS:
;        The function returns an array with the percentile values or
;        -1 if no data was passed or value contains invalid numbers.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;      x = (findgen(31)-15.)*0.2     ; create sample data
;      y = exp(-x^2)/3.14159         ; compute some Gauss distribution
;      p = percentiles(y,value=[0.05,0.1,0.9,0.95])
;      print,p
;
;      IDL prints :  3.92826e-05  0.000125309     0.305829     0.318310

;
; MODIFICATION HISTORY:
;        mgs, 03 Aug 1997: VERSION 1.00
;        mgs, 20 Feb 1998: - improved speed and memory usage
;                (after tip from Stein Vidar on newsgroup)
;
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine percentiles"
;-------------------------------------------------------------


function percentiles,data,value=value

result = -1
n = n_elements(data)
if (n le 0) then return,result   ; error : data not defined

; check if speficic percentiles requested - if not: set standard
if(not keyword_set(value)) then value = [ 0., 0.25, 0.5, 0.75, 1.0 ]

; create a temporary copy of the data and sort
; tmp = data
; tmp = tmp(sort(tmp))
; NO: simply save the sorted index array
  ix = sort(data)

; loop through percentile values, get indices and add to result
; This is all we need since computing percentiles is nothing more
; than counting in a sorted array.
for i=0L,n_elements(value)-1 do begin

   if(value(i) lt 0. OR value(i) gt 1.) then return,-1

   if(value(i) le 0.5) then ind = long(value(i)*n)    $
   else ind = long(value(i)*(n+1))
   if (ind ge n) then ind = n-1L    ; small fix for small n
                                    ; (or value eq 1.)

;  if(i eq 0) then result = tmp(ind)  $
;  else result = [result, tmp(ind) ]
; ## change number 2
   if(i eq 0) then result = data(ix(ind))  $
   else result = [result, data(ix(ind)) ]
endfor

return,result
end

