; $Id: in_range.pro,v 1.1.1.1 2007/07/17 20:41:41 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        IN_RANGE
;
; PURPOSE:
;        IN_RANGE checks to see if an input value lies
;        between a minimum value and a maximum value.
;
; CATEGORY:
;        General
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
;       None
;
; REQUIREMENTS:
;       None
;
; EXAMPLE: 
;        IF ( NOT IN_RANGE( VALUE, 0, 100 ) ) $
;           THEN PRINT, 'VALUE is not in between 0-100'
;
;             ; Print a message if VALUE lies outside
;             ; of the range 0-100
;   
;  
; MODIFICATION HISTORY:
;        bmy, 24 Sep 1997: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments
;
;-
; Copyright (C) 1997-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine in_range"
;-----------------------------------------------------------------------


function In_Range, Value, MinVal, MaxVal

   ; Test if VALUE is between MINVAL & MAXVAL
   if ( Value ge MinVal and Value le MaxVal ) $
      then return, 1                          $
      else return, 0

end
	
