; $Id: cum_total.pro,v 1.1.1.1 2007/07/17 20:41:29 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CUM_TOTAL (function)
;
; PURPOSE:
;        Compute cumulative total of a data vector.
;
; CATEGORY:
;        Math & Units
;
; CALLING SEQUENCE:
;        RESULT = CUM_TOTAL(Y)
;
; INPUTS:
;        Y -> The data vector
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        A data vector with the same number of elements 
;        and the cumulative totals.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        See also function RUN_AV. 
;
; EXAMPLE:
;        Y = FINDGEN(10)
;        PRINT, CUM_TOTAL(Y)
;
;             ; IDL prints:  0  1  3  6  10  15  21  28  36  45
;
; MODIFICATION HISTORY:
;        mgs, 21 Oct 1998: VERSION 1.00
;        bmy, 23 May 2007: TOOLS VERSION 2.06
;                          - Now use longword for loop counter
;                          - Updated comments, cosmetic changes
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.as.harvard.edu with subject "IDL routine cum_total"
;-----------------------------------------------------------------------


function Cum_Total, Y
 
   ; Return for 0 or 1 element
   if ( N_Elements( Y ) eq 0 ) then return, 0d0
   if ( N_Elements( Y ) eq 1 ) then return, Double( Y[0] )
  
   ; Create output vector
   Result    = DblArr( N_Elements( Y ) )
   Result[0] = Y[0]
 
   ; Sum the vector
   for I = 1L, N_Elements( Y )-1L do begin
      Result[I] = Result[I-1] + Y[I]
   endfor

   ; Return
   return, Result
end
 
