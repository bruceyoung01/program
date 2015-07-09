; $Id: strsci.pro,v 1.1.1.1 2007/07/17 20:41:48 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        STRSCI (function)
;
; PURPOSE:                                                 
;        Given a number, returns a string of that number in 
;        scientific notation format ( e.g. A x 10  )
;
; CATEGORY:
;        Strings
;
; CALLING SEQUENCE:
;        RESULT = STRSCI( DATA  [, Keywords ] )
;
; INPUTS:
;        DATA -> A floating point or integer number to be
;             converted into a power of 10.
;
; KEYWORD PARAMETERS:
;        FORMAT -> The format specification used in the string
;             conversion for the mantissa (i.e. the "A" of 
;             "A x 10^B").  Default is '(f12.2)'.  
;
;        /POT_ONLY -> Will return only the "power of 10" part of 
;             the string (i.e. the "10^B").  Default is to return 
;             the entire string (e.g. "A x 10^B" )
;
;        /MANTISSA_ONLY -> return only mantissa of the string
;
;        /SHORT -> return 10^0 as '1' and 10^1 as '10'
;
;        /TRIM -> don't insert blanks (i.e. return Ax10^B)
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
;        This function does not "evaluate" the format statement thoroughly
;        which can result in somewhat quirky strings. Example:
;        print,strsci(-9.999) results in -10.0x10^0 instead of -1.0x10^1.
;
;        Need a better symbol than the 'x' for the multiplier...
;
; EXAMPLE:
;        Result = STRSCI( 2000000, format='(i1)' )
;        print, result                
;        ;                                                     6
;        ;     prints 2 x 10!u6!n, which gets plotted as 2 x 10 
;        
;        Result = STRSCI( -0.0001 )
;        print, result
;        ;                                                            4
;        ;     prints -1.00 x 10!u-4!n, which gets plotted as 1.00 x 10
;
;        Result = STRSCI( 0d0, format='(f13.8)' )
;        print, result
;        ;
;        ;     prints, 0.00000000
; 
;
; MODIFICATION HISTORY:
;        bmy, 28 May 1998: INITIAL VERSION
;                          - now returns string of the form A x 10
;        mgs, 29 May 1998: - bug fix: now allows negative numbers
;                          - keyword MANTISSA_ONLY added
;                          - default format changed to f12.2
;        bmy, 02 Jun 1998: - renamed to STRSCI 
;                            ("STRing SCIentific notation")
;        mgs, 03 Jun 1998: - added TRIM keyword
;        mgs, 22 Sep 1998: - added SHORT keyword
;                          - modified handling of TRIM keyword
;        mgs, 24 Sep 1998: - bug fix with SHORT flag
;  bmy & mgs, 02 Jun 1999: - now can handle DATA=0.0 correctly
;                          - updated comments
;        mgs, 03 Jun 1999: - can now also handle values lt 1 ;-)
;                          - and doesn't choke on arrays
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - updated comments
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
; or phs@io.as.harvard.edu with subject "IDL routine strsci"
;-------------------------------------------------------------


function StrSci, Data, Format=Format, POT_Only=POT_Only, $
             MANTISSA_ONLY=MANTISSA_ONLY,SHORT=SHORT,TRIM=TRIM

   ;====================================================================
   ; Error checking / Keyword settings
   ;====================================================================
   ;on_error, 2

   if ( n_elements( Data ) eq 0 ) then begin
      return, ''
   endif

   if ( not Keyword_Set( Format ) ) then Format   = '(f12.2)'

   POT_Only      = keyword_set( POT_Only      )
   MANTISSA_Only = keyword_set( MANTISSA_Only )
   Short         = Keyword_Set( Short         )
   Trim          = Keyword_Set( Trim          )

   NDat = n_elements(Data)
   Result = strarr(NDat)

   for i=0,NDat-1 do begin
      ;====================================================================
      ; If ABS( DATA ) > 0 then we can proceed to take the common log.
      ; For DATA < 0, place a "-" sign in front of the number
      ;====================================================================
      if ( Abs( Data[i] ) ne 0.0 ) then begin
   
         ; take the common log and store in LOG10DATA
         Log10Data = ALog10( Abs( Data[i] ) )  
   
         ; Boolean flag if data < 0
         sign = ( Data[i] lt 0.0 ) 
   
         ; Compute the characteristic (int part)
         ; Add the 1d-6 to prevent roundoff errors
         Characteristic = Fix( Log10Data + 1.0d-6 )
         if (Log10Data lt 0) then $
            Characteristic = Characteristic - 1 
   
         ; Compute the Mantissa (frac part) and take its antilog.
         Mantissa = Log10Data - Characteristic 
         Mantissa = 10.0^Mantissa
   
   ;  print,data[i],log10data,mantissa,characteristic,format='(3f24.14,i8)'
   
         ; String for the coefficient part, 
         ; The coefficient is just antilog of the Mantissa
         ; Add the minus sign if DATA < 0.0
         A = StrTrim( String( Mantissa, Format=Format ), 2 )
         if ( Sign ) then A = '-' + A
   
         ; String for the power of 10 part
         B = '10!u' + strtrim( string( Characteristic ), 2 ) + '!n'
         if ( Short ) then begin
            if ( Characteristic eq 0 ) then B = '1'
            if ( Characteristic eq 1 ) then B = '10'
         endif
   
         ; composite string
         Result[i] = A + ' x ' + B
         if ( Short AND B eq '1') then Result[i] = A
   
   
      ;====================================================================
      ; If DATA = 0, then we cannot take the common log, so return
      ; zeroes for the result strings.  Use the FORMAT string.
      ;====================================================================
      endif else begin
         A      = String( 0d0, Format=Format )
         B      = A
         Result[i] = A
   
      endelse
   
      ;====================================================================
      ; Return result to calling program (depending on keyword settings)
      ; Eliminate blanks if TRIM keyword is set
      ;====================================================================
      if ( POT_Only ) then $
         Result[i] = B
      if ( MANTISSA_Only ) then $
         Result[i] = A
      if ( Trim ) then $
         Result[i] = StrCompress( Result[i], /Remove_All )
     
   endfor

   if (n_elements(Result) eq 1) then $
      Result = Result[0]
 
   return, Result

end
