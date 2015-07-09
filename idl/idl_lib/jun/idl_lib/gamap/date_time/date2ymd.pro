; $Id: date2ymd.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        DATE2YMD
;
; PURPOSE:
;        Given a date in YYYYMMDD format, returns the year, month,
;        and day in separate variables.  Also can be used to separate
;        time in a HHMMSS format into hours, minutes, seconds.
;
; CATEGORY:
;        Date & Time
;
; CALLING SEQUENCE:
;        DATE2YMD, YYYYMMDD, YEAR, MONTH, DAY
;
; INPUTS:
;        YYYYMMDD -> Today's date as YYYY/MM/DD (or time as HH/MM/SS)
;        YEAR     -> Year  (or hour  ) value
;        MONTH    -> Month (or minute) value
;        DAY      -> Day   (or second) value
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
;        DATE2YMD, 20060101, Y, M, D
;        PRINT, Y, M, D
;           2006  1   1
;             ; Separates the date into Y, M, D variables
;
;        DATE2YMD, 123000, H, Mi, S
;        PRINT, H, Mi, S
;           12  30  0
;             ; Separates the time into H, Mi, S variables
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
; or phs@io.as.harvard.edu with subject "IDL routine date2ymd";
;-----------------------------------------------------------------------


pro Date2Ymd, YYYYMMDD, Year, Month, Day 

   ; Error check
   if ( N_Elements( YYYYMMDD ) ne 1 ) then Message, 'YYYYMMDD not passed!' 

   ; Extract individual values from YYYYMMDD format
   Year     = YYYYMMDD / 10000L 
   MonthDay = YYYYMMDD - ( Year  * 10000L )
   Month    = MonthDay / 100L
   Day      = MonthDay - ( Month * 100L   )

end
