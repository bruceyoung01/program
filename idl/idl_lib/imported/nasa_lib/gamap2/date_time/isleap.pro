; $Id: isleap.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ISLEAP (function)
;
; PURPOSE:
;        Returns 1 for each year that is a leap year.
;
; CATEGORY:
;        Date & Time
;
; CALLING SEQUENCE:
;        RESULT = ISLEAP( YEAR )
;
; INPUTS:
;        YEAR -> A year or an array of years. Must be "4 digit" years.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> An integer value or array with 1 for each 
;             year that is a leap year.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        For many purposes one should take a look at built-in
;        IDL date functions first (version > 5.0).
;
; EXAMPLE:
;        YEARS = FINDGEN(25) + 1980 
;        PRINT, 365 + ISLEAP(YEARS), FORMAT='(10i4)'
;          366 365 365 365 366 365 365 365 366 365
;          365 365 366 365 365 365 366 365 365 365
;          366 365 365 365 366
;
;             ; Compute the number of days in each year
;             ; from 1980 to 2005 using ISLEAP to add
;             ; either 1 or 0 to 365.
;
; MODIFICATION HISTORY:
;        mgs, 02 Oct 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - updated comments, cosmetic changes
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
; or phs@io.as.harvard.edu with subject "IDL routine isleap"
;-----------------------------------------------------------------------


function isleap, year
 
   ; return 1 if a year is a leap year. Also works for arrays!
 
   result = ( ( fix( year mod 4   ) eq 0   AND $
                fix( year mod 100 ) ne 0 ) OR  $
              ( fix( year mod 400 ) eq 0 ) )
 
   return,result
end
 
