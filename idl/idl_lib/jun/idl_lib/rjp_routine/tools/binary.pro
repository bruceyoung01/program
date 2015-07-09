; $Id: binary.pro,v 1.1.1.1 2003/10/22 18:09:41 bmy Exp $
FUNCTION BINARY, number
;+
; PURPOSE:
;   This function returns the binary representation
;   of a number. Numbers are converted to LONG integers
;   if necessary.
; EXAMPLE:
;   Binary representation of 11B:
;     IDL> print, binary(11B)                                           
;     0 0 0 0 1 0 1 1
;   If data extraction is used instead of conversion ->
;   Binary representation of pi (little endian IEEE representation):
;     IDL> print, format='(z9.8,5x,4(1x,8a1))', long(!pi,0), binary(!pi)
;     40490fdb      01000000 01001001 00001111 11011011
; AUTHOR:
;      Kevin Ivory                           Tel: +49 5556 979 434
;      Max-Planck-Institut fuer Aeronomie    Fax: +49 5556 979 240
;      Max-Planck-Str. 2                     mailto:Kevin.Ivory@linmpi.mpg.de
;      D-37191 Katlenburg-Lindau, GERMANY
;
;-
  On_Error, 1
  s = SIZE(number)
  type = s[s[0] + 1]
  IF type EQ 0 THEN Message, 'Number parameter must be defined.'
  bit = ['0','1']
  IF type EQ 1 OR type EQ 2 THEN BEGIN
    bitvalue = 2^INDGEN(8*type)
  ENDIF ELSE BEGIN
    Print, 'Converting "number" to LONG...'
    number = LONG(number)       ; data conversion
;   If you want the binary representation of the floating point value,
;   use extraction instead of conversion:
;   number = LONG(number, 0)    ; data extraction
    bitvalue = 2L^LINDGEN(32)
  ENDELSE

  RETURN, REVERSE(bit((number AND bitvalue) EQ bitvalue))
END

