; $Id: strsize.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        STRSIZE
;
; PURPOSE:
;        Given a string argument and the character size, returns the
;        # of characters that can fit w/in the horizontal or vertical
;        extent of a plot window.
;
; CATEGORY:
;        Plotting, Strings
;
; CALLING SEQUENCE:
;        RESULT = STRSIZE( STRARG, CHARSIZE [, Keywords ] )
;
; INPUTS:
;        STRARG -> A string of characters.
;
;        CHARSIZE -> The size of each character.  1.0 is normal 
;             size, 2.0 is double size, etc.
; 
; KEYWORD PARAMETERS:
;        /Y -> Set this switch to compute the number of characters
;             that can fit along the vertical extent of the plot.
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
; EXAMPLE:
;        OPEN_DEVICE, WINPARAM=[ 0, 800, 600 ]
;        PRINT, STRSIZE( 'Hello', 3 )
;           80.0000
;           
;             ; Computes the # of characters of size 3 
;             ; that can fit in the plot window
;
;
; MODIFICATION HISTORY:
;        bmy, 10 Oct 2006: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2006-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine strsize"
;-----------------------------------------------------------------------


function StrSize, StrArg, Width, Y=Y
 
   ; Fraction of the plot window that one "average" character occupies
   if ( Keyword_Set( Y ) )                                      $
      then OneChar = Float( !D.Y_CH_SIZE ) / Float( !D.Y_SIZE ) $
      else OneChar = Float( !D.X_CH_SIZE ) / Float( !D.X_SIZE )  

   ; Return # of characters that can fit along the horizontal 
   ; (or vertical if /Y is set) extent of the plotting window
   if ( StrLen( StrArg ) gt 0 )                                 $
      then return, Width / ( OneChar * StrLen( StrArg ) )       $  ;????
      else return, 1.
end
 
