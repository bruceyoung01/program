; $Id: day_of_year.pro,v 1.1.1.1 2003/10/22 18:06:03 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        DAY_OF_YEAR (function)
;
; PURPOSE:
;        Computes the day number (0-365 or 0-366 if leap year) 
;        of a given date.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        DAY_OF_YEAR, MONTH, DAY, YEAR
;
; INPUTS:
;        MONTH (int) -> the input month (1 - 12)
;        DAY   (int) -> the input day   (0 - 31)
;        YEAR  (int) -> the input year  (YEAR < 0 is BC; YEAR > 0 is AD)
;        
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        The function returns the day number of the year
;        as an integer variable
;
; SUBROUTINES:
;        JULDAY (IDL user library procedure)
;
; REQUIREMENTS:
;
; NOTES:
;        (1) You cannot abbreviate YEAR.  If you specify 10/14/97
;            DAY_OF_YEAR will compute the day number for 14 Oct 97 AD 
;            instead of 14 Oct 1997 AD
;
; EXAMPLE:
;        (1) A typical modern date: 14 Oct 1997 AD
;            DAYNUM = DAY_OF_YEAR(10, 14, 1997)  
;
;        (2) Beginning of the "Anno Domini" era: 1 Jan 1 AD
;            DAYNUM = DAY_OF_YEAR(1, 1, 1)  
;
;        (3) When Julius Caesar was murdered: 15 Mar 44 BC
;            DAYNUM = DAY_OF_YEAR( 3, 15, -44)  
;
; MODIFICATION HISTORY:
;        bmy, 14 Oct 1997: VERSION 1.00
;        bmy, 26 Mar 1998: VERSION 1.01
;                           -- now written as a function with 
;                              more elegant error checking.
;              
;-
; Copyright (C) 1997, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine day_of_year"
;-------------------------------------------------------------

pro use_day_of_year

   print
   print,'   Usage :'
   print,'      result = day_of_year(MONTH, DAY, YEAR)'
   print
   print,'   Input: '
   print,'      MONTH = the input month (1 - 12)'
   print,'      DAY   = the input day   (1 - 31)'
   print,'      YEAR  = the input year  (- for BC, + for AD)'
 
   return
end


function day_of_year, month, day, year

   ; return to caller if error
   on_error, 2

   ; Safety first!
   day_number = -1

   ; Missing parameters?
   if ( n_elements( year  ) eq 0   or $
        n_elements( month ) eq 0   or $
        n_elements( day   ) eq 0 ) then begin
      print, 'One or more parameters are missing....'
      use_day_of_year
      return, -1
   endif

   ; Month out of range?
   if ( month lt 1 or month gt 12 ) then begin
      print, 'Month is out of range...'
      use_day_of_year
      return, -1
   endif

   ; Day out of range?
   if ( day lt 0 or day gt 31 ) then begin
      print, 'Day is out of range...'
      use_day_of_year
      return, -1
   endif

   ; Day number is difference in (astronomical) Julian
   ; days between this date and Jan 0 of the given year
   ; Return as a fix instead of a long...max val is only 365 or 366!
   day_number = fix( julday( month, day, year ) - julday( 1, 0, year ) )
 
   return, day_number
 
end   
