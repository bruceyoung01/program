; $Id: interpolate_2d.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        INTERPOLATE_2D
;
; PURPOSE:
;        Interpolates a 2-D array from one grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        NEWDATA = INTERPOLATE_2D( DATA,    OLDXMID, OLDYMID,    $
;                                  NEWXMID, NEWYMID  [, Keywords ] )
;
; INPUTS:
;        DATA -> A 2-D array containing the data to be interpolated.
;
;        OLDXMID -> A 1-D vector containing the X-coordinates (e.g. 
;             longitude) corresponding to the DATA array.
;
;        OLDYMID -> A 1-D vector containing the Y-coordinates (e.g. 
;             latitude) corresponding to the DATA array.
;
;        NEWXMID -> A 1-D vector containing the X-coordinates (e.g. 
;             longitude) of the new grid onto which DATA will be 
;             interpolated.
;
;        NEWYMID -> A 1-D vector containing the Y-coordinates (e.g. 
;             latitude) of the new grid onto which DATA will be 
;             interpolated.
;
; KEYWORD PARAMETERS:
;        /DOUBLE -> Set this switch to force computation in double 
;             precision.  Default is to use single precision.
;
; OUTPUTS:
;        NEWDATA -> A 2-D array containing the data on the new grid.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        INTERPOLATE_2D can be used to interpolate from coarse grids
;        to fine grids or fine grids to coarse grids.  This routine
;        uses the IDL INTERPOL command.
;    
; EXAMPLE:
;
;        ; Define old grid (GEOS-Chem 2x25)
;        OLDTYPE  = CTM_TYPE( 'GEOS4', RES=2 )
;        OLDGRID  = CTM_GRID( OLDTYPE        )
;
;        ; Define new grid (GEOS-Chem 4x5)
;        NEWTYPE  = CTM_TYPE( 'GEOS4', RES=4 )
;        NEWGRID  = CTM_GRID( NEWTYPE        )
;
;        ; Interpolate DATA array from 2x25 to 4x5
;        NEWDATA  = INTERPOLATE_2D( DATA,                       $
;                                   OLDGRID.XMID, OLDGRID.YMID, $
;                                   NEWGRID.XMID, NEWGRID.YMID )
;
;             ; Interpolate a data array from the GEOS-Chem 
;             ; 2 x 2.5 grid to the GEOS-Chem 4 x 5 grid
;        
; MODIFICATION HISTORY:
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine interpolate_2d"
;-----------------------------------------------------------------------


function InterPolate_2D, Data, OldXMid, OldYMid, NewXMid, NewYMid, $
                         Double=Double
 
   ;====================================================================
   ; Error checking
   ;====================================================================

   ; Exit if less than 5 inputs
   if ( N_Params() ne 5 ) then begin
      Message,'Must supply DATA, OLDXMID, OLDYMID, NEWXMID, NEWYMID!' 
   endif
   
   ; Sizes of arrays
   SD  = Size( Data,    /Dim )
   SOX = Size( OldXMid, /Dim )  
   SOY = Size( OldYMid, /Dim )
   SNX = Size( NewXMid, /Dim )
   SNY = Size( NewYMid, /Dim )
 
   ; Check dimensions of arrays
   if ( N_Elements( SD  ) ne 2 ) then Message, 'DATA must be a 2-D array!'
   if ( N_Elements( SOX ) ne 1 ) then Message, 'OLDXMID must be a 1-D vector!'
   if ( N_Elements( SOY ) ne 1 ) then Message, 'OLDYMID must be a 1-D vector!'
   if ( N_Elements( SNX ) ne 1 ) then Message, 'NEWXMID must be a 1-D vector!'
   if ( N_Elements( SNY ) ne 1 ) then Message, 'NEWYMID must be a 1-D vector!'
 
   ; OLDXMID and DATA must conform
   if ( SD[0] ne SOX[0] ) $
      then Message, 'OLDXMID must match the 1st dimension of DATA!'
   
   ; OLDYMID and DATA must conform
   if ( SD[1] ne SOY[0] ) $
      then Message, 'OLDYMID must match the 2nd dimension of DATA!'
   
   ;====================================================================
   ; Define arrays
   ;====================================================================
   TmpArr = DblArr( SNX[0], SOY[0] )
   NewArr = DblArr( SNX[0], SNY[0] )
 
   ;====================================================================
   ; Interpolate
   ;====================================================================
 
   ; E-W direction
   for J = 0L, SOY[0] - 1L  do begin
      TmpArr[*, J] = InterPol( Data[*, J], OldXMid, NewXMid )
   endfor
 
   ; N-S direction
   for I = 0L, SNX[0] - 1L do begin
      NewArr[I, *] = Interpol( TmpArr[I, *], OldYMid, NewYMid )
   endfor
 
   ;====================================================================
   ; Cleanup and return
   ;====================================================================
   if ( not Keyword_Set( Double ) ) $
      then return, Float( NewArr )  $
      else return, NewArr
end
   
   
