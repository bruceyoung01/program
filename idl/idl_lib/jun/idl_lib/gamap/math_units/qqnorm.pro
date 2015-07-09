; $Id: qqnorm.pro,v 1.1.1.1 2007/07/17 20:41:29 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        QQNORM
;
; PURPOSE:
;        Procedure: sort the data, assign actual "probability" and 
;        calculate the expected deviation from the mean.
;
; CATEGORY:
;        Math & Units
;
; CALLING SEQUENCE:
;        RESULT = QQNORM( DATA )
;
; INPUTS:
;        DATA -> Vector containing the data values.  NOTE: DATA 
;             will be sorted in ascending order and then returned.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> Array where each element contains the expected
;              deviation from the mean of DATA.
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
;        RESULT = QQNORM( DATA )
;            ; Computes expected deviation from the mean.         
;
; MODIFICATION HISTORY:
;            mgs, 14 Dec 1998: VERSION 1.0
;                              - extracted from w_calc.pro
;  pip, clh, bmy, 10 Oct 2002: TOOLS VERSION 1.52
;  amf, swu, bmy, 10 Oct 2006: TOOLS VERSION 2.05
;                              - Now use simpler algorithm from
;                                Arlene Fiore's code
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
; or phs@io.as.harvard.edu with subject "IDL routine qqnorm"
;-----------------------------------------------------------------------


function QQNorm, Data

   ; Sort the data in ascending order for return
   Data = Data[ Sort( Data ) ]

   ; Define position array 
   Pos  = DblArr( N_Elements( Data ) )

   ; Divide standard normal probability distribution 
   ; function into equal area (total area = 1)
   ADiv = 1d0 / Double( N_Elements( Data ) )

   ; Loop through to get positions - use GAUSS_CVF function which
   ; calculates the cutoff position, at which the area under the 
   ; Gaussian to the right of the cutoff is equal to the input
   ; value.  We want to plot at the midpoint, so start with ADIV/2.
   for I = 0L, N_Elements( Data ) - 1L do begin
      Pos[I] = -Gauss_CVF( ADiv/2.0D + ADiv*Double( I ) )
   endfor

   ; Return to calling program
   return, Pos
end
