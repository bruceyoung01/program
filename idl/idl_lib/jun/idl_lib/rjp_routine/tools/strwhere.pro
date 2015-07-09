; $Id: strwhere.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        STRWHERE  (function)
;
; PURPOSE:
;        return position *array* for occurence of a character in
;        a string
;
; CATEGORY:
;        string tools
;
; CALLING SEQUENCE:
;        pos = STRWHERE(str, schar [,Count] )
;
; INPUTS:
;        STR -> the string
;
;        SCHAR -> the character to look for
;
; KEYWORD PARAMETERS:
;        none.
;
; OUTPUTS:
;        COUNT -> (optional) The number of matches that were found 
;
;        The function returns an index array similar to the 
;        result of the where function
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        ind = strwhere('abcabcabc','a')
;
;        ; returns [ 0, 3, 6 ]
;
; MODIFICATION HISTORY:
;        mgs, 02 Jun 1998: VERSION 1.00
;        bmy, 30 Jun 1998: - now returns COUNT, the number 
;                            of matches that are found (this is
;                            analogous to the WHERE command)
;
;-
; Copyright (C) 1998, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine strwhere"
;-------------------------------------------------------------


function strwhere,str,schar,Count
 
 
   if (n_elements(str) eq 0) then return,-1
 
   ; convert to byte
   BStr = byte(Str)
   BSC  = (byte(schar))[0]
 
   ; Search for matches
   Ind = where( Bstr eq BSC, Count )

   ;### bmy ### return,where(BStr eq BSC)
   return, Ind

end
   
