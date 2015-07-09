; $Id: little_endian.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        LITTLE_ENDIAN (function)
;
; PURPOSE:
;        Determines if the computer system on which we are 
;        running IDL has little-endian byte ordering.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        RESULT = LITTLE_ENDIAN
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> Returns 1 if the machine on which you  are running IDL
;             is a little endian machine, or 0 otherwise.
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
;        PRINT, LITTLE_ENDIAN
;           1
;    
;             ; Returns 1 if we are running IDL on a 
;             ; little-endian  machine, or zero otherwise
;
; MODIFICATION HISTORY:
;  R.Mallozi, 02 Jul 1998: INITIAL VERSION
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.harvard.edu with subject "IDL routine little_endian"
;-----------------------------------------------------------------------


function Little_Endian
 
   ; Test for little-endian
   return, ( BYTE( 1, 0, 1 ) )[0]
 
end
 
