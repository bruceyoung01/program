; $Id: add_date.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ADD_DATE
;
; PURPOSE:
;        Computes the YYYY/MM/DD date after a number of days in the
;        future (or past) have elapsed.
;
; CATEGORY:
;        Date & Time
;
; CALLING SEQUENCE:
;        RESULT = ADD_DATE( YYYYMMDD, NDAYS )
;
; INPUTS:
;        YYYYMMDD -> Today's date in YYYY/MM/DD format
;
;        NDAYS -> The number of days (either positive or negative)
;              to add to YYYYMMDD.  Default is 1.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        DATE2YMD    YMD2DATE (function)
;       
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;   
; EXAMPLES:
;        PRINT, ADD_DATE( 20060101, 100 )
;           20060411
;             ; Computes the date 100 days after 2006/01/01
;
;        PRINT, ADD_DATE( 20060101, -100 )
;           20050923
;             ; Computes the date 100 days before 2006/01/01
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
; or phs@io.as.harvard.edu with subject "IDL routine add_date"
;-----------------------------------------------------------------------


function Add_Date, YYYYMMDD, NDays
 
   ; External functions
   FORWARD_FUNCTION JulDay, Ymd2Date

   ; Keywords
   if ( N_Elements( YYYYMMDD ) ne 1 ) then Message, 'YYYYMMDD not passed!'
   if ( N_Elements( NDays    ) ne 1 ) then NDays  = 1L 
 
   ; Get today's year, month, day from YYYYMMDD
   Date2Ymd, YYYYMMDD, Year0, Month0,  Day0
 
   ; Convert today's date to an astronomical Julian date
   JDay    = JulDay( Month0, Day0, Year0, 0, 0, 0 )
 
   ; Add the NDAYS (# of days) in Julian date space
   JDay    = JDay + NDays
 
   ; Convert the new date back to Year/Month/Date 
   CalDat, Jday, Month1, Day1, Year1, Hour1
 
   ; Save the new date back into YYYYMMDD format
   NewDate = Ymd2Date( Year1, Month1, Day1 )
 
   ; Return 
   return, NewDate
 
end
