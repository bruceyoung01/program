; $Id: nymd2tau.pro,v 1.3 2005/03/24 18:03:13 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        NYMD2TAU (function)
;
; PURPOSE:
;        Computes the value of TAU, which is the elapsed hours between
;        the current date/time and the beginning of an epoch. This is
;        the starting date for 3D model data assimilation.
;
; CATEGORY:
;        CTM programs
;
; CALLING SEQUENCE:
;        result = NYMD2TAU( NYMD, [NHMS [,NYMD0, NHMS0]] )
;
; INPUTS:
;        NYMD (long)  -> YY/MM/DD for this date (e.g. 940101)
;                  You can either specify year as 4 digits or 2 digits.
;                  With 2 digits, year < 50 will be assumed to be 2000+YY.A
;
;        NHMS (long)  -> HH/MM/SS for this date (e.g. 060000)
;                  will be defaulted to 000000
;
;        NYMD0 (long) -> YY/MM/DD for the start of the epoch
;                  default is {19}850101 which is the GEOS-1 start
;
;        NHMS0 (long) -> HH/MM/SS for the start of the epoch
;                  will be defaulted to 000000
;        
; KEYWORD PARAMETERS:
;        /GEOS1 -> use 1985/01/01 as epoch start
;
;        /GISS_II -> use 1980/01/01 as epoch start
;
; OUTPUTS:
;        The function returns the TAU value as a double-precision number
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
;        Function NYMD2STRU is also contained in function TAU2YYMMDD.
;        Take care when changes are necessary !
;
; EXAMPLE:
;        ; (1) Compute TAU value for 0h on Jan 1, 1994, with the 
;        ;     epoch starting on 0h on Jan 1, 1980 (GISS II value).
;        ;
;        TAU = nymd2tau( 940101L, 0L, 800101L, 0L )
;
;        ; (2) Compute TAU value for 0h on Jan 1, 1994, for the 
;        ;     default GEOS-1 epoch (850101L, 0L).
;        ;
;        TAU = nymd2tau( 940101L, 0L )
;
;        ; (3) Compute GISS model II tau values for the first of
;        ;     each month in 1990
;        date = [ 900101L, 900201L, 900301L, 900401L, 900501L, 900601L, $
;                 900701L, 900801L, 900901L, 901001L, 901101L, 901201L ]
;
;        tau = nymd2tau(date,/GISS)
;
;
; MODIFICATION HISTORY:
;        bmy, 26 Mar 1998: VERSION 1.00
;        mgs, 26 Mar 1998: - now year 2000 compliable 
;        mgs, 23 Mar 1999: - now handles vectors as input
;        bmy, 23 Mar 2005: GAMAP VERSION 2.03
;                          - Added /NO_Y2K keyword to suppress 
;                            special Y2K treatment of dates (i.e.
;                            treat dates w/ 2 digits as from 1900's)
;                          - renamed internal function NYMD2STRU to
;                            N2T_NYMD2STRU to avoid conflict with
;                            similar function in "tau2yymmdd.pro"
;
;-
; Copyright (C) 1998-2005, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine nymd2tau"
;-------------------------------------------------------------



function n2t_nymd2stru,nymd,nhms,Do_Y2K

   result = -1

   Year = long(nymd/10000L)
   Month = long((nymd-Year*10000)/100)
   Day = long(nymd MOD 100)

   ;------------------------------------------------------------
   ; Prior to 3/23/05:
   ; Suppress special handling for Y2K issues so that we 
   ; can compute TAU0 from dates such as 1 A.D. (bmy, 3/23/05)
   ;; take care of year 2000 issues
   ;for i=0,n_elements(year)-1 do begin
   ;   if (Year[i] lt 100) then begin
   ;      if (Year[i] lt 50) then $
   ;         Year[i] = Year[i]+2000 $
   ;      else $
   ;         Year[i] = Year[i] + 1900
   ;   endif
   ;endfor
   ;------------------------------------------------------------

   ; take care of year 2000 issues
   if ( Do_Y2K ) then begin
      for i=0,n_elements(year)-1 do begin
         if ( Year[i] lt 100 ) then begin
            if ( Year[i] lt 50 )             $
               then Year[i] = Year[i] + 2000 $
               else Year[i] = Year[i] + 1900
         endif
      endfor
   endif

   ; make sure we got as many time as date elements
   nel = n_elements(year)
   Hour = long(nhms/10000L)
   if (n_elements(hour) lt nel) then Hour = replicate(hour[0],nel)
   Minute = long((nhms-Hour*10000)/100)
   if (n_elements(Minute) lt nel) then Minute = replicate(Minute[0],nel)
   Second = long(nhms MOD 100)
   if (n_elements(Second) lt nel) then Second = replicate(Second[0],nel)

   result = { Year:Year, Month:Month, Day:Day, $
              Hour:Hour, Minute:Minute, Second:Second }

   return,result

end


; ====================================================================== 

pro use_nymd2tau

   print
   print,'   Usage :'
   print,'      result = nymd2tau( NYMD, NHMS [,NYMD0, NHMS0] )'
   print
   print,'   Input: '
   print,'      NYMD  = YYMMDD for the given date'
   print,'      NHMS  = HHMMSS for the given date'
   print,'      NYMD0 = YYMMDD for the start of the epoch (default: GEOS-1)'
   print,'      NHMS0 = HHMMSS for the start of the epoch (default: GEOS-1)'
   print
   print,'   Keyword options:'
   print,'      /GEOS1   : use 1985/01/01 as epoch start'
   print,'      /GISS_II : use 1980/01/01'
 
   return
end

; ====================================================================== 


function nymd2tau, nymd, nhms, nymd0, nhms0, $
                   GEOS1=GEOS1, GISS_II=GISS_II, No_Y2K=No_Y2K

   ; return to caller if error
   on_error, 2

   ; External functions
   ;---------------------------------
   ; Prior to 3/23/05:
   ;FORWARD_FUNCTION nymd2stru
   ;---------------------------------
   FORWARD_FUNCTION N2T_Nymd2Stru

   ; Safety first!
   tau1 = -1
   tau0 = -1

   ; NYMD must be specified!
   if (n_elements(nhms) eq 0) then nhms = 0L    ; default to 00h

   if ( n_elements( nymd ) eq 0 ) then begin
      print, 'NYMD must be specified...'
      use_nymd2tau
      return, -1
   endif

   ; Flag to suppress special treatment of years w/ 2 digits (bmy, 3/23/05)
   Do_Y2K = 1L - Keyword_Set( No_Y2K )

   ; If NYMD0 and NHMS0 aren't specified, default to GEOS-1 epoch
   if (keyword_set(GEOS1)) then nymd0 = 19850101L
   if (keyword_set(GISS_II)) then nymd0 = 19800101L
   if ( n_elements( nymd0 ) eq 0 ) then nymd0 = 19850101L
   if ( n_elements( nhms0 ) eq 0 ) then nhms0 = 000000L

   ;--------------------------------------------------------------------------
   ; Prior to 3/23/05:
   ; Now pass DO_Y2K to enable special treatment for Y2K issues (bmy, 3/23/05)
   ;; extract year, month, day and hour, minute, second
   ;This  = nymd2stru(nymd,nhms)
   ;First = nymd2stru(nymd0,nhms0)
   ;--------------------------------------------------------------------------

   ; Extract year, month, day and hour, minute, second
   This  = N2T_Nymd2Stru( NYMD,  NHMS,  Do_Y2K )
   First = N2T_Nymd2Stru( NYMD0, NHMS0, Do_Y2K )

   ; Tau0 is now an absolute Julian time in hours at start of epoch
   tau0 = ( julday( First.Month, First.Day, First.Year ) * 24d0 ) + $
          First.Hour + ( First.Minute / 60d0 ) + ( First.Second / 3600d0 )
   
   tau1 = dblarr(n_elements(This.Year))

   for i=0,n_elements(This.Year)-1 do begin

      ; Tau1 is now an absolute Julian time in hours at current date
      tau1[i] = ( julday( This.Month[i],  $
                          This.Day[i],    $
                          This.Year[i] ) * 24d0 ) + $
                          This.Hour[i] +  $
                        ( This.Minute[i] / 60d0 ) + $
                        ( This.Second[i] / 3600d0 )
   
   endfor
    
   ; The elapsed time since the beginning of the epoch is tau1 - tau0
   tau = tau1 - tau0
 
   ; return as a double precision variable since tau can take 
   ; non-integral values
   return, tau
 
end   
