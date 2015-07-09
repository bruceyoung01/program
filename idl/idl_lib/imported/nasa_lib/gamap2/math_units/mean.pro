; $Id: mean.pro,v 1.1.1.1 2007/07/17 20:41:29 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MEAN
;
; PURPOSE:
;        Computes the mean value of an array, along a given dimension.
;
; CATEGORY:
;        Math & Units
;
; CALLING SEQUENCE:
;        RESULT = MEAN( X, DIM, _EXTRA=e )
;
; INPUTS:
;        X -> The input vector or array.
;
;        DIM -> The dimension along which to compute the mean of X.
;             DIM may be omitted if the X is 1-dimensional.
;             
; KEYWORD PARAMETERS:
;        _EXTRA=e -> Passes extra keywords to the TOTAL command.
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
;        Multidimensional version from Kevin Ivory (04/03/1997)
;
; EXAMPLES:
;        (1)
;
;        PRINT, MEAN( FINDGEN(10) )
;
;        IDL prints:
;           4.50000
;
;            ; Prints the mean of a 1-D array
;
;        (2)
;
;        ARRAY = MEAN( DIST(10,10), 2 )
;        HELP, ARRAY
;        PRINT, ARRAY
;
;        IDL prints:
;           ARRAY           FLOAT     = Array[10]
;           2.50000   2.79703   3.36695   4.08519   4.89073      
;           5.75076   4.89073   4.08519   3.36695   2.79703
;
;            ; Prints the mean of a 2-D array along
;            ; the second dimension.
;         
; MODIFICATION HISTORY:
;      ivory, 04 Mar 1997: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Cosmetic changes, added comments
;
;-
; Copyright (C) 1997-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine mean"                   
;-----------------------------------------------------------------------


function Mean, X, Dim, _EXTRA=e

   ; Return up a level if an error occurs
   On_Error, 2

   ; Keyword defaults
   if ( N_Elements( Dim ) eq 0 ) then Dim = 0

   ; Return mean of the X along DIM (exclude NaN values)
   return, Total( X, Dim, _EXTRA=e ) / ( Total( Finite( X ), Dim ) > 1 )

end
