; $Id: zmid.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        ZMID  (function)
;
; PURPOSE:
;        Computes altitude centers from altitude edges.
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = ZMID( EDGE )
;
; INPUTS:
;        EDGE -> Vector of altitude edges that defines the grid.  
;             EDGE will be sorted in ascending order.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        The vector of altitude centers is returned in RESULT.  
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The relationship between altitude centers and edges is:
;
;              ZMID[N] = ( ZEDGE[N] + ZEDGE[N+1] ) / 2.0
;   
; EXAMPLE:
;        Result = ZMID( [ 0.0, 2.0, 4.0, 6.0, 8.0 ] )
;        print, Result
;             1.00000      3.00000      5.00000      7.00000
;
;
; MODIFICATION HISTORY:
;        bmy, 21 Jun 1999: VERSION 1.00
;        bmy, 22 Oct 1999: VERSION 1.44
;                          - Now use SHIFT to compute the average
;                            between successive edges
;
;-
; Copyright (C) 1999, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine zmid"
;-------------------------------------------------------------


function ZMid, Edge
 
   ;====================================================================
   ; Error checking / Keyword settings
   ;====================================================================
   if ( N_Elements( Edge ) eq 0 ) then begin
      Message, 'Must supply altitude edges!', /Continue
      return, -1
   endif
 
   ;====================================================================
   ; Sort EDGES in ascending order (ZMID)
   ; Do the interation as described above
   ; RESULT will have one more element than PMID (obviously!)
   ;====================================================================
   Edge   = Edge( Sort( Edge ) )

   N      = N_Elements( Edge )
   Result = 0.5 * ( Edge[0:N-1] + ( Shift( Edge, -1 ) )[0:N-2] ) 

   ;====================================================================
   ; Return to calling program
   ;====================================================================
   return, Result
 
end
