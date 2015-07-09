; $Id: tau2yymmdd.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        TAU2YYMMDD (function)
;
; PURPOSE:
;        Converts a tau value (elapsed hours between
;        the current date/time and the beginning of an epoch) into a
;        calendar date and time value.
;
; CATEGORY:
;        CTM programs
;
; CALLING SEQUENCE:
;        result = tau2yymmdd( TAU, [ NYMD0, NHMS0 ] )
;
; INPUTS:
;        TAU -> the tau value to be converted (type long)
;
;        NYMD0 (long) -> YY/MM/DD for the start of the epoch
;                  default is {19}850101 which is the GEOS-1 start
;
;        NHMS0 (long) -> HH/MM/SS for the start of the epoch
;                  will be defaulted to 000000
;        
; KEYWORD PARAMETERS:
;        /NFORMAT --> produce 2-element vector instead of structure
;              The result will be NYMD and NHMS with NYMD as YYYYMMDD.
;
;        /SHORT --> produce 2-element vector with 2-digit year format.
;              (implies NFORMAT=1)
;
;        /GEOS1 -> use 1985/01/01 as epoch start
;
;        /GISS_II -> use 1980/01/01 as epoch start
;
; OUTPUTS:
;        The function returns the calendar date and time as either a structure
;        with tags Year, Month, Day, Hour, Minute, Second
;        or a 2 element array with NYMD and NHMS long values.
;
; SUBROUTINES:
;        NYMD2STRU : extracts year, month, day, hour, minute and seconds from
;            NYMD and NHMS values.
;
;        JULDAY (IDL user library procedure)
;
; REQUIREMENTS:
;
; NOTES:
;        Function NYMD2STRU is also embedded in NYMD2TAU function. This should
;        be kept in mind when changes are necessary.
;
;        Function STRDATE can be used to produce a formatted string from
;        the structure returned by TAU2YYMMDD.
;
; EXAMPLE:
;        get calendar structure from tau value for 1994/01/01 (GEOS)
;
;           print,tau2yymmdd(78888,/GEOS1)
;
;        result (structure with Year, Month, Day, Hour, Minute, Second):
;        {    1994     1      1      0      0      0}
;
;        ... and in the format of NYMD, NHMS
;
;           print,tau2yymmdd(78888,/GEOS1,/NFORMAT)
;           print,tau2yymmdd(78888,/GEOS1,/NFORMAT,/SHORT)
;
;        results (array with 2 elements):
;              19940101           0
;                940101           0
;
; MODIFICATION HISTORY:
;        mgs, 26 Mar 1998: VERSION 1.00
;        mgs, 16 Mar 1999: - now allows floating point tau values
;                            CAUTION: Use double for second precision !
;        bmy, 27 Jul 1999: VERSION 1.42
;                          - updated comments
;        bmy, 03 Jan 2000: VERSION 1.44
;                          - updated comments
;        bmy, 23 Mar 2005: GAMAP VERSION 2.03
;                          - renamed internal function NYMD2STRU to
;                            T2N_NYMD2STRU to avoid conflict with
;                            similar function in "tau2yymmdd.pro";
;
;-
; Copyright (C) 1998-2005, Martin Schultz and Bob Yantosca, 
; Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine tau2yymmdd"
;-------------------------------------------------------------



function t2n_nymd2stru,nymd,nhms


   result = -1

   
   Year = long(nymd/1.D4)
   Month = long((nymd-Year*1.D4)/1.D2)
   Day = long(nymd MOD 1.D2)

   ; take care of year 2000 issues
   if (Year lt 100) then begin
      if (Year lt 50) then $
         Year = Year + 2000 $
      else $
         Year = Year + 1900
   endif

   Hour = long(nhms/1.D4)
   Minute = long((nhms-Hour*1.D4)/1.D2)
   Second = long(nhms MOD 1.D2)


   result = { Year:Year, Month:Month, Day:Day, $
              Hour:Hour, Minute:Minute, Second:Second }

return,result

end


; ====================================================================== 

pro use_tau2yymmdd

   print
   print,'   Usage :'
   print,'      result = tau2yymmdd( TAU [,NYMD0, NHMS0] )'
   print
   print,'   Input: '
   print,'      TAU   = hours elapsed since start of model epoch'
   print,'      NYMD0 = YYMMDD for the start of the epoch (default: GEOS-1)'
   print,'      NHMS0 = HHMMSS for the start of the epoch (default: GEOS-1)'
   print
   print,'   Keyword options:'
   print,'      /NFORMAT : produce 2-element array instead of structure'
   print,'      /SHORT   : dto. but with short (2 digit) year format'
   print,'      /GEOS1   : use 1985/01/01 as epoch start'
   print,'      /GISS_II : use 1980/01/01'
 
   return
end

; ====================================================================== 


function tau2yymmdd, tau, nymd0, nhms0, GEOS1=GEOS1, GISS_II=GISS_II, $
             NFORMAT=NFORMAT, SHORT=SHORT

   ; return to caller if error
   on_error, 2

   ; External functions
   ;-------------------------------------
   ; Prior to 3/23/05:
   ;FORWARD_FUNCTION nymd2stru
   ;-------------------------------------
   FORWARD_FUNCTION T2N_Nymd2Stru

   result = -1

   ; TAU must be specified!
   if ( n_elements( tau ) eq 0 ) then begin
      print, 'TAU must be specified...'
      use_tau2yymmdd
      return, -1
   endif

   ; If NYMD0 and NHMS0 aren't specified, default to GEOS-1 epoch
   if (keyword_set(GEOS1)) then nymd0 = 19850101L
   if (keyword_set(GISS_II)) then nymd0 = 19800101L
   if ( n_elements( nymd0 ) eq 0 ) then nymd0 = 19850101L
   if ( n_elements( nhms0 ) eq 0 ) then nhms0 = 000000L

   ; extract year, month, day and hour, minute, second from epoch start
   ;-------------------------------------
   ; Prior to 3/23/05:
   ;First = nymd2stru(nymd0,nhms0)
   ;-------------------------------------
   First = T2N_Nymd2Stru( NYMD0, NHMS0 )

   ; Tau0 as absolute Julian day at start of epoch
   jday0 = julday( First.Month, First.Day, First.Year )
   jday1 = jday0 + long(tau)/24L    ; integer division !

   ; convert to month, day, year
   ; Year will be a 4-digit number
   caldat,jday1,mm,dd,yy
  
   ; calculate hours
   time1 = double(tau mod 24.D0)
   hour1 = long(time1)
   min1  = long(60.*(time1-hour1))
   sec1  = long(3600.*(time1-hour1-min1/60.))

   ; compose structure
   if (keyword_set(SHORT)) then NFORMAT = 1
   if (not keyword_set(NFORMAT)) then begin
     result = { Year:long(yy), Month:long(mm), Day:long(dd), $
                Hour:hour1, Minute:min1, Second:sec1 }
   endif else begin
     result = [ yy*10000L+mm*100L+dd, hour1*10000L+min1*100L+sec1 ]
     if (keyword_set(SHORT)) then result(0) = (result(0) mod 1000000L)
   endelse

 
   return,result
 
end   
