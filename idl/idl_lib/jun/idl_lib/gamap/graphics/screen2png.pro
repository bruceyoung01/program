; $Id: screen2png.pro,v 1.1.1.1 2007/07/17 20:41:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SCREEN2PNG
;
; PURPOSE:
;        Captures an image from the X-window or Z-buffer device and 
;        saves the image to a PNG file.  Handles 8-bit and TRUE
;        COLOR displays correctly.
;  
; CATEGORY:
;        Graphics
;
; CALLING SEQUENCE:
;        SCREEN2PNG, FILENAME [ , Keywords ]
;
; INPUTS:
;        FILENAME -> Name of the PNG file that will be created.
;             FILENAME may be omitted if you wish to only return
;             the image (via the THISFRAME keyword).
;
; KEYWORD PARAMETERS:
;        THISFRAME -> Returns to the calling program the 
;             byte image captured from the screen.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        TVREAD (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Should work for Unix/Linux, Macintosh, and Windows.
;        (2) SCREEN2PNG is just a convenience wrapper for TVREAD.
;
; EXAMPLES:
;        PLOT, X, Y
;        SCREEN2PNG, 'myplot.png'
;
;             ; Creates a simple plot and writes it to a PNG file
;             ; via capture from the screen (X-window device).
;
;        PLOT, X, Y
;        SCREEN2PNG, THISFRAME=THISFRAME
;
;             ; Creates a simple plot and saves the screen 
;             ; capture image to the byte array THISFRAME. 
;
;        OPEN_DEVICE, /Z
;        PLOT, X, Y
;        SCREEN2PNG, 'myplot.png'
;        CLOSE_DEVICE
;
;             ; Creates a simple plot and writes it to a PNG file
;             ; via capture from the Z-buffer device.
;
;
; MODIFICATION HISTORY:
;        bmy, 25 Sep 2003: TOOLS VERSION 1.53
;                          - Bug fix in passing file name to TVREAD
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - now pass _EXTRA=e to TVREAD
;                          - updated comments
;
;-
; Copyright (C) 2003-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine screen2png"
;-----------------------------------------------------------------------


pro Screen2PNG, FileName, ThisFrame=ThisFrame, _EXTRA=e
  
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION TvRead

   ; Did we pass a filename?
   Is_File = ( N_Elements( FileName ) eq 1 )

   ; Since TVIMAGE writes the ".png" extension to the filename, then
   ; we must remove it from the filename.  This is a hack. (bmy, 9/25/03)
   if ( Is_File ) then begin
      Ind = StrPos( FileName, '.png' )
      if ( Ind[0] ge 0 ) $
         then NewFileName = StrMid( FileName, 0, Ind ) $
         else NewFileName = FileName
   endif
      
   ;====================================================================
   ; Do screen capture for either X or Z devices
   ;====================================================================
   case ( StrUpCase( StrTrim( !D.NAME, 2 ) ) ) of 
       
      ; X-WINDOW: 
      'X': begin
         if ( Is_File )                                                     $
            then ThisFrame = TvRead( FileName=NewFileName, /PNG, _EXTRA=e ) $
            else ThisFrame = TvRead( _EXTRA=e )
      end

      ; Z-BUFFER
      'Z': begin
         if ( Is_File )                                                     $
            then ThisFrame = TvRead( FileName=NewFileName, /PNG, _EXTRA=e ) $
            else ThisFrame = TvRead( _EXTRA=e )
      end

      ; Otherwise return w/ error
      else: begin
         Message, 'Cannot screen grab from ' + !D.NAME, /Continue
         return
      end

   endcase

   ; Quit
   return
end
 
