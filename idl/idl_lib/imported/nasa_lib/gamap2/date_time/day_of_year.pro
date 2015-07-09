; $Id: day_of_year.pro,v 1.2 2008/04/03 20:12:15 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        DAY_OF_YEAR (function)
;
; PURPOSE:
;        Computes the day number (0-365 or 0-366 if leap year) 
;        of a given date.
;
; CATEGORY:
;        Date & Time
;
; CALLING SEQUENCE:
;        RESULT = DAY_OF_YEAR( MONTH, DAY, YEAR )  OR
;        RESULT = DAY_OF_YEAR( YYYYMMDD  )
;
; INPUTS:
;        With 3 arguments:
;        MONTH (int or long) -> the input month (1 - 12)
;        DAY   (int or long) -> the input day   (0 - 31)
;        YEAR  (int or long) -> the input year  (YEAR<0 is BC; YEAR>0 is AD)
;        
;        With 1 argument:
;        YYYYMMDD (long) -> the input date in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        RESULT -> Day number of the year
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) You cannot abbreviate YEAR.  If you specify 10/14/97
;            DAY_OF_YEAR will compute the day number for 14 Oct 97 AD 
;            instead of 14 Oct 1997 AD
;
; EXAMPLES:
;        (1)
;        PRINT, DAY_OF_YEAR( 10, 14, 1997 )
;          287
;             ; A typical modern date: 14 Oct 1997 AD
;
;        (2)
;        PRINT, DAY_OF_YEAR( 19971014 )
;          287
;             ; The same as example #1, but this time we call
;             ; DAY_OF_YEAR with a date in YYYYMMDD format
;
;        (3)
;        PRINT, DAY_OF_YEAR( 1, 1, 1 )
;          1
;             ; Beginning of the "Anno Domini" era: 1 Jan 1 AD
;
;        (4)
;        PRINT, DAY_OF_YEAR( 3, 15, -44 )  
;           74
;             ; When Julius Caesar was murdered: 15 Mar 44 BC
;
; MODIFICATION HISTORY:
;        bmy, 14 Oct 1997: VERSION 1.00
;        bmy, 26 Mar 1998: VERSION 1.01
;                           -- now written as a function with 
;                              more elegant error checking.
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 03 Apr 2008: GAMAP VERSION 2.12
;                          - Modified to accept either 3 arguments
;                            (month, day, year) or one argument
;                            (date in YYYYMMDD format)
;                          
;-
; Copyright (C) 1997-2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine day_of_year"
;-----------------------------------------------------------------------


function Day_Of_Year, Month, Day, Year

   ; return to caller if error
   on_error, 2

   ; External functions
   FORWARD_FUNCTION Date2YMD

   ; Safety first!
   day_number = -1

   ; Interpret 1 passed argument as YYYY/MM/DD
   ; Call DATE2YMD to split YYYY/MM/DD into separate variables
   if ( N_Params() eq 1 ) then Date2Ymd, Month, Year, Month, Day

   ; Missing parameters?
   if ( n_elements( year  ) eq 0   or $
        n_elements( month ) eq 0   or $
        n_elements( day   ) eq 0 ) then begin
      print, 'One or more parameters are missing....'
      usage, 'day_of_year'
      return, -1
   endif

   ; Month out of range?
   if ( month lt 1 or month gt 12 ) then begin
      print, 'Month is out of range...'
      usage, 'day_of_year'
      return, -1
   endif

   ; Day out of range?
   if ( day lt 0 or day gt 31 ) then begin
      print, 'Day is out of range...'
      usage, 'day_of_year'
      return, -1
   endif

   ; Day number is difference in (astronomical) Julian
   ; days between this date and Jan 0 of the given year
   ; Return as a fix instead of a long...max val is only 365 or 366!
   day_number = fix( julday( month, day, year ) - julday( 1, 0, year ) )
 
   return, day_number
 
end   
