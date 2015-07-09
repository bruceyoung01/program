; $Id: screen2png.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
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
;        PNG Tools
;
; CALLING SEQUENCE:
;        SCREEN2PNG, FILENAME [ , Keywords ]
;
; INPUTS:
;        FILENAME -> Name of the PNG file that will be created.
;             If not specified, SCREEN2PNG will use "idl.png"
;             as the default filename.  
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
;        (2) SCREEN2PNG is just a convenience wrapper for TVIMAGE.
;
; EXAMPLES:
;        (1) 
;        PLOT, X, Y
;        SCREEN2PNG, 'myplot.png'
;
;             ; Creates a simple plot and writes it to a PNG file
;             ; via capture from the screen (X-window device).
;
;        (2) 
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
;
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine screen2png"
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
         if ( Is_File )                                           $
            then ThisFrame = TvRead( FileName=NewFileName, /PNG ) $
            else ThisFrame = TvRead()
      end

      ; Z-BUFFER
      'Z': begin
         if ( Is_File )                                           $
            then ThisFrame = TvRead( FileName=NewFileName, /PNG ) $
            else ThisFrame = TvRead()
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
 
