; $Id: colorbar_ndiv.pro,v 1.1.1.1 2007/07/17 20:41:37 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        COLORBAR_NDIV
;
; PURPOSE:
;        Returns the maximum number of colorbar divisions possible
;        (up to a user-defined limit) such that tickmarks are placed 
;        in between colors.
;
; CATEGORY:
;        Color
;
; CALLING SEQUENCE:
;        Result = COLORBAR_NDIV( NCOLORS [, Keywords ] )
;
; INPUTS:
;        NCOLORS -> (OPTIONAL) Specifies the number of colors 
;             in the color table.  Default is !MYCT.NCOLORS.
;
; KEYWORD PARAMETERS:
;        MAXDIV -> Specifies the maximum number of divisions 
;             for the colorbar.  Default is 6.
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
;        DIV = COLORBAR_NDIV( 20, MAXDIV=8 )
;        TVMAP, ..., DIVISONS=DIV, ...
;             
;             ; Computes the number of color bar divisions for
;             ; a colortable with 20 colors.  DIV will not exceed
;             ; the value of MAXDIV (in this case =8).  The value 
;             ; of DIV is then passed to the TVMAP routine (which
;             ; in turn passes it to the COLORBAR routine).
;
; MODIFICATION HISTORY:
;        phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.as.harvard.edu with subject "IDL routine colorbar_ndiv"
;-----------------------------------------------------------------------


function ColorBar_NDiv, NColors, maxdiv=maxdiv
 
   ; Arguments
   if ( N_Elements( NColors ) eq 0 ) then NColors = !MYCT.NCOLORS
   if ( N_Elements( MaxDiv  ) eq 0 ) then MaxDiv  = 6

   ;====================================================================
   ; Generally, to get the annotations located at the transitions 
   ; b/w colors, you need to get the number of divisions in colorbar 
   ; (D) and the number of colors (N) satisfying: 
   ; 
   ;     N / (D-1)  = integer 
   ;
   ; Note that it does not take away the responsibility of the caller 
   ; to define the "good" number of colors for his/her problem... 
   ; Prime numbers should probably be avoided and seem to be the root 
   ; of the problem here, unless 2 annotations is what the user really
   ; wants.  (phs, 5/11/07)
   ;====================================================================
 
   IntA = IndGen( MaxDiv - 1 ) + 1

   return, Max( Where( not( Float( NColors )/IntA - NColors/IntA ) ) ) + 2
 
end
