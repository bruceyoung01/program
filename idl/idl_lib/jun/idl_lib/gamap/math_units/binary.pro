; $Id: binary.pro,v 1.1.1.1 2007/07/17 20:41:29 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BINARY (function)
;
; PURPOSE:
;        This function returns the binary representation of a number. 
;        Numbers are converted to LONG integers if necessary.
;
; CATEGORY:
;        Math & Units
;
; CALLING SEQUENCE:
;        RESULT = BINARY( NUMBER ) 
;
; INPUTS:
;        NUMBER -> Number for which its binary representation 
;             will be returned.  Number may be any of the numeric
;             types (BYTE, INT, LONG, FLOAT, DOUBLE, COMPLEX, etc).
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
; EXAMPLES:
;        (1)
;        PRINT, BINARY( 11B )                                           
;           0 0 0 0 1 0 1 1
;
;             ; Binary representation of 11B
;
;        (2) 
;        PRINT, FORMAT='(Z9.8,5X,4(1X,8A1))', LONG(!PI,0), BINARY(!PI)
;           40490fdb      01000000 01001001 00001111 11011011
;
;
;             ; If data extraction is used instead of conversion 
;             ; Binary representation of pi (little endian IEEE 
;             ; representation)
;
;
; AUTHOR:
;        Kevin Ivory                         Tel: +49 5556 979 434
;        Max-Planck-Institut fuer Aeronomie  Fax: +49 5556 979 240
;        Max-Planck-Str. 2                   mailto:Kevin.Ivory@linmpi.mpg.de
;        D-37191 Katlenburg-Lindau, GERMANY
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments, cosmetic changes
;
;-
; Copyright (C) 2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine binary"
;-----------------------------------------------------------------------


FUNCTION BINARY, number
 
   ; Error handling
   On_Error, 1

   ; Find the numeric type
   s    = SIZE( number )
   type = s[s[0] + 1]

   ; Returne for undefined types
   IF ( Type EQ 0 ) THEN Message, 'Number parameter must be defined.'

   bit = ['0','1']

   IF ( type EQ 1 OR type EQ 2 ) THEN BEGIN

      ; NUMBER is a BYTE or INT
      bitvalue = 2^INDGEN( 8 * type )

   ENDIF ELSE BEGIN

      ; For floating point types, first convert to LONG
      Print, 'Converting "number" to LONG...'
      number = LONG( number )     

      ; If you want the binary representation of the floating point value,
      ; use extraction instead of conversion: 
      ; number = LONG(number, 0)    
      bitvalue = 2L^LINDGEN( 32 )

   ENDELSE
 
   ; Return byte representation
   RETURN, REVERSE( bit( ( number AND bitvalue ) EQ bitvalue ) )
END
 
