; $Id: isleap.pro,v 1.1.1.1 2003/10/22 18:09:41 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        ISLEAP (function)
;
; PURPOSE:
;        Returns 1 for each year that is a leap year.
;
; CATEGORY:
;        Calendar routines
;
; CALLING SEQUENCE:
;        result = ISLEAP(year)
;
; INPUTS:
;        YEAR -> A year or an array of years. Must be "4 digit" years.
;
; KEYWORD PARAMETERS:
;        none.
;
; OUTPUTS:
;        An integer value or array with 1 for each year that is
;        a leap year.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        For many purposes one should take a look at built-in
;        IDL date functions first (version > 5.0).
;
; EXAMPLE:
;        ; Create an array of years from 1980 to 1998
;        years = findgen(19) + 1980
;        ; Compute the number of days for each year
;        ndays = 365 + isleap(years)
;
; MODIFICATION HISTORY:
;        mgs, 02 Oct 1998: VERSION 1.00
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
; with subject "IDL routine isleap"
;-------------------------------------------------------------


function isleap,year
 
   ; return 1 if a year is a leap year. Also works for arrays!
 
   result = ( (fix(year mod 4) eq 0 AND fix(year mod 100) ne 0) $
                   OR (fix(year mod 400) eq 0) )
 
return,result
end
 
