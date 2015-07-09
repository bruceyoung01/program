; $Id: pedge.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PEDGE  (function)
;
; PURPOSE:
;        Given the pressures at the centers of a model grid, returns
;        the pressures at the edges of the grid.
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = PEDGE( MID, PSURF )
;
; INPUTS:
;        MID -> Vector of pressure centers that defines the grid.  
;             MID will be sorted in descending order.
;
;        PSURF -> Surface pressure (which also corresponds to the
;             lowest pressure edge).  Default is 1000.0 (mb).
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> The vector of pressures at level edges [hPa]
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The relationship between sigma centers and sigma edges is
;        as follows:
;   
;              MID[N] = ( EDGE[N] + EDGE[N+1] ) / 2
;   
;        or conversely:
;    
;              EDGE[N+1] = ( 2 * MID[N] ) - EDGE[N]
;   
;        where EDGE[N] is the lower pressure edge, and EDGE[N+1]
;        is the upper sigma edge of the box with center MID[N].
;          
;        The boundary condition PE[0] = PSURF is necessary to
;        start the iteration.
;      
; EXAMPLE:
;        RESULT = PEDGE( [ 900, 700, 500 ], 1000.0 ) 
;        PRINT, RESULT
;           1000.00      800.000      600.000      400.000
;
;             ; Prints edges between levels 900, 700, 500 hPa
;             ; with the surface pressure being 1000 hPa.
;
; MODIFICATION HISTORY:
;        bmy, 17 Jun 1999: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine pedge"
;-----------------------------------------------------------------------


function PEdge, Mid, PSurf 
 
   ;====================================================================
   ; Error checking / Keyword settings
   ;====================================================================
   if ( N_Elements( Mid ) eq 0 ) then begin
      Message, 'Must supply MID!', /Continue
      return, -1
   endif
 
   if ( N_Elements( PSurf ) eq 0 ) then PSurf = 1000.00

   ;====================================================================
   ; First sort PMID in descending order
   ; Do the interation as described above
   ; RESULT will have one more element than PMID (obviously!)
   ;====================================================================
   Mid         = Mid( Reverse( Sort( Mid ) ) )
   Result      = FltArr( N_Elements( Mid ) + 1 )
   Result[ 0 ] = PSurf[ 0 ]
 
   for N = 0, N_Elements( Mid )-1 do begin
      Result[ N+1 ] = ( 2.0 * Mid[ N ] ) - Result[ N ]
   endfor
   
   ;====================================================================
   ; Test to make sure that all elements of RESULT are monotonically
   ; decreasing.  If not, then the surface pressure does not 
   ; correspond to the pressure levels.  Stop with a warning.
   ;====================================================================
   Test = ( Shift( Result, 1 ) - Result )[1:*]
   if ( Min( Test ) lt 0 ) then begin
      Message, 'WARNING!  PEDGE contains negative numbers!', /Continue
      print, result
      Message, 'Make sure PSURF is correctly specified!', /Continue
      stop
   endif

   ;====================================================================
   ; Return to calling program
   ;====================================================================
   return, Result
 
end
