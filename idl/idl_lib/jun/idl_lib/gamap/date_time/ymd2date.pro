; $Id: ymd2date.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        YMD2DATE
;
; PURPOSE:
;        Given year, month, day (or hour, minute, second) values,
;        returns a variable in YYYYMMDD (or HHMMSS) format.
;
; CATEGORY:
;        Date & Time
;
; CALLING SEQUENCE:
;        RESULT = YMD2DATE( YEAR, MONTH, DAY )
;
; INPUTS:
;        YEAR  -> Year  (or hour  ) value
;        MONTH -> Month (or minute) value
;        DAY   -> Day   (or second) value
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
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
; EXAMPLE:
;        PRINT, YMD2DATE( 2006, 1, 1 )
;           20060101
;             ; Takes separate Y, M, D values and creates a date variable.
;
;        PRINT, YMD2DATE( 12, 30, 0 )
;           123000
;             ; Takes separate H, Mi, S values and creates a time variable.
;
; MODIFICATION HISTORY:
;        bmy, 06 Jun 2006: TOOLS VERSION 2.05
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2006-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine ymd2date"
;-----------------------------------------------------------------------


function Ymd2Date, Year, Month, Day 

   ; Error check
   if ( N_Elements( Year  ) ne 1 ) then Message, 'YEAR not passed!' 
   if ( N_Elements( Month ) ne 1 ) then Message, 'MONTH not passed!' 
   if ( N_Elements( Day   ) ne 1 ) then Message, 'DAY not passed!' 

   ; Compute date variable
   YYYYMMDD =  ( Year * 10000L ) + ( Month * 100L ) + Day 
   
   ; Return
   return, YYYYMMDD

end
