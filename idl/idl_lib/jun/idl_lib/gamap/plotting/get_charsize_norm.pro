; $Id: get_charsize_norm.pro,v 1.1 2007/12/05 15:42:02 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GET_CHARSIZE_NORM
;
; PURPOSE:
;        Returns the size in normal coordinates of an average
;        character. The function accounts for !P.MULTI, !P.CHARSIZE,
;        and the charsize scaling you pass to a plotting routine with
;        the CHARSIZE keyword.
;
; CATEGORY:
;        Plotting, Strings
;
; CALLING SEQUENCE:
;        RESULT = GET_CHARSIZE_NORM( CHARSIZE [, Keywords ] )
;
; INPUTS:
;        CHARSIZE -> A N-elements vector that gives the character
;             size, in character unit: 1.0 is normal size, 2.0 is
;             double size, etc. Default is 1.0. 
; 
; KEYWORD PARAMETERS:
;        /DEVICE -> Set this switch to compute the average character
;             size in device units (which is usually pixel) instead of 
;             the default normal coordinates.
;
; OUTPUTS:
;        A N-by-2 array that gives average character size in
;        normal coordinates:
;            RESULT[*,0] are along the X direction, 
;            RESULT[*,1] are along the Y direction. 
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
;        PRINT, GET_CHARSIZE_NORM
;
;            0.00878049    0.0168750    
;
;
;        PRINT, GET_CHARSIZE_NORM( /DEVICE )
;
;             7.20000      10.8000
;
;
;        MULTIPANEL, 6
;        PRINT, GET_CHARSIZE_NORM( [1, 2, 3.5 ], /DEVICE )
;
;           3.60000      7.20000      12.6000   ; => X sizes in pixel
;           5.40000      10.8000      18.9000   ; => Y sizes in pixel          
;
;
; MODIFICATION HISTORY:
;        phs,  3 Dec 2007: VERSION 1.00
;
;-
; Copyright (C) 2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to yantosca@seas.harvard.edu
; or plesager@seas.harvard.edu with subject "IDL routine 
; Get_CharSize_Norm"
;-----------------------------------------------------------------------


function GET_CHARSIZE_NORM, CharSize, Device=Device
 
   If n_elements( CharSize ) eq 0 then CharSize = 1.  $
   else CharSize = FLOAT( CharSize )
   
   ;; First, get CharSize in device units (usually pixels):
   TextSizeVert = CharSize * !D.Y_Ch_Size * !P.charsize
   TextSizeHor  = CharSize * !D.X_Ch_Size * !P.charsize

   ;; If more than two rows or columns of plots are produced,
   ;; IDL decreases the character size by a factor of 2. So:
   if ( !p.multi[1] ge 3 ) or ( !p.multi[2] ge 3 ) then begin
      TextSizeVert = TextSizeVert * 0.5
      TextSizeHor  = TextSizeHor  * 0.5
   endif


   ;; Divide by size of display in device unit (usually pixels) to get 
   ;; CharSize in Normal Coordinates (i.e., where !D.x_size and
   ;; !D.y_size are 1.)
   if keyword_set( Device )                                        $
      then return, reform( [ [ TextSizeHor ], [ TextSizeVert ] ] ) $
      else return, reform( [ [ TextSizeHor  / !D.X_SIZE ],         $   
                             [ TextSizeVert / !D.Y_SIZE ] ] )


end
 
