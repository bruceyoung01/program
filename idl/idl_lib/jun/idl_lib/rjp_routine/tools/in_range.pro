; $Id: in_range.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        IN_RANGE
;
; PURPOSE:
;        IN_RANGE checks to see if an input value lies
;        between a minimum value and a maximum value.
;
; CATEGORY:
;        Error checking
;
; CALLING SEQUENCE:
;        RESULT = IN_RANGE(VALUE, MINVAL, MAXVAL)
;
; INPUTS:
;        VALUE  -> The value to be checked
;        MINVAL -> The minimum value 
;        MAXVAL -> The maximum value
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       If MINVAL <= VALUE <= MAXVAL, IN_RANGE returns 0
;       If VALUE < MINVAL,            IN_RANGE returns 1
;       If VALUE > MAXVAL,            IN_RANGE returns 1 
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; EXAMPLE: 
;
;        if (not IN_RANGE(VALUE, 0, 100) then ...
;   
;  
; MODIFICATION HISTORY:
;        bmy, 24 Sep 1997: VERSION 1.00
;-
; Copyright (C) 1997, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine in_range
;-------------------------------------------------------------


function IN_RANGE, VALUE, MINVAL, MAXVAL

	if (VALUE ge MINVAL and VALUE le MAXVAL) then return,1  $
      else return,0

end
	
