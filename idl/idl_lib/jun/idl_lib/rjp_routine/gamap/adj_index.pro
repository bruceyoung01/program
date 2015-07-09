; $Id: adj_index.pro,v 1.1.1.1 2003/10/22 18:06:03 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        ADJ_INDEX
;
; PURPOSE:
;        Adjusts CTM global index arrays for a particular
;        data-block dimension from global size to window size.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        NEWINDEX = ADJ_INDEX( OLDINDEX, N_SUBTRACT, MAXINDEX )
;
; INPUTS:
;        OLDINDEX -> The globally sized CTM index array to be adjusted.
;
;        N_SUBTRACT -> The number to subtract from each element
;             of OLDINDEX.  
;
;        MAXINDEX -> The maximum number of elements that OLDINDEX
;             can have.  
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        ADJ_INDEX returns the window-sized index array as
;        the value of the function.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None.
;            
; NOTES:
;        Designed for use with GAMAP, but can be used for more
;        general purpose applications as well.
;
; EXAMPLE:
;       WE     = [ 69, 70, 71, 0, 1, 2 ]     ; WE straddles the date line
;       WE_ADJ = ADJ_INDEX( WE, 69, 72 )   
;       print, WE_ADJ
;         0       1       2       3       4       5
;       NEWDATA = DATA[ WE_ADJ, *, * ]
;
;       ; WE has a possible maximum of 72 elements.  Convert WE
;       ; from global size to window size by subtracting 69 
;       ; from each element of WE.  Use WE_ADJ to reference
;       ; elements of the DATA array.
;
; MODIFICATION HISTORY:
;        bmy, 19 Feb 1999: VERSION 1.00
;
;-
; Copyright (C) 1999, Bob Yantosca and Martin Schultz,
; Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or mgs@io.harvard.edu with subject "IDL routine adj_index"
;-------------------------------------------------------------


function Adj_Index, OldIndex, N_Subtract, MaxIndex

   ;=====================================================================
   ; Error checking
   ;=====================================================================
   if ( N_Elements( OldIndex ) lt 0 ) then begin
      Message, 'OLDINDEX must be passed!', /Continue
      return, -1
   endif

   if ( N_Elements( N_Subtract ) lt 0 ) then begin
      Message, 'N_SUBTRACT must be passed!', /Continue
      return, -1
   endif

   if ( N_Elements( MaxIndex ) lt 0 ) then begin
      Message, 'MAXINDEX must be passed!', /Continue
      return, -1
   endif
 
   ;=====================================================================
   ; Return if OLDINDEX < 0 or N_SUBTRACT eq 0
   ;=====================================================================
   if ( OldIndex[0] lt 0 OR N_Subtract eq 0 ) then return, OldIndex
 
   ;=====================================================================
   ; Subtract N_SUBTRACT from each element of OLDINDEX.
   ;=====================================================================
   Index = OldIndex - N_Subtract
 
   ;=====================================================================
   ; Make sure all elements of INDEX are positive.  
   ; Add MAXINDEX to each element of INDEX that is less than zero.
   ;=====================================================================
   Test = Where( Index lt 0 ) 
   if ( Test[0] ge 0 ) then Index[ Test ] =  Index[ Test ] + MaxIndex
 
   ;=====================================================================
   ; Return to calling program
   ;=====================================================================
   return, Index
   
end
