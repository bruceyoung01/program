; $Id: screen2gif.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SCREEN2GIF
;
; PURPOSE:
;        Captures an image from the X-window or Z-buffer device and 
;        saves the image to a GIF file.  Handles 8-bit and TRUE
;        COLOR displays correctly.
;  
; CATEGORY:
;        GIF Tools
;
; CALLING SEQUENCE:
;        SCREEN2GIF, FILENAME [ , Keywords ]
;
; INPUTS:
;        FILENAME -> Name of the GIF file that will be created.
;             If not specified, SCREEN2GIF will use "idl.gif"
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
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Should work for Unix/Linux, Macintosh, and Windows.
;   
;        (2) With the advent of David Fanning's TVREAD function, 
;            SCREEN2GIF is more or less obsolete.  We keep it here
;            for backwards compatibility for now.  
;
; EXAMPLES:
;        (1) 
;        PLOT, X, Y
;        SCREEN2GIF, 'myplot.gif'
;
;             ; Creates a simple plot and writes it to a GIF file
;             ; via capture from the screen (X-window device).
;
;        (2) 
;        OPEN_DEVICE, /Z
;        PLOT, X, Y
;        SCREEN2GIF, 'myplot.gif'
;        CLOSE_DEVICE
;
;             ; Creates a simple plot and writes it to a GIF file
;             ; via capture from the Z-buffer device.
;
;
; MODIFICATION HISTORY:
;        bmy, 24 Jul 2001: TOOLS VERSION 1.49
;        bmy, 02 Dec 2002: TOOLS VERSION 1.52
;                          - now uses TVREAD function from D. Fanning
;                            which works on both PC's & Unix terminals
;        bmy, 30 Apr 2003: TOOLS VERSION 1.53
;                          - Bug fix in passing file name to TVREAD
;
;-
; Copyright (C) 2001, 2002, 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine screen2gif"
;-----------------------------------------------------------------------


pro Screen2GIF, FileName, ThisFrame=ThisFrame, _EXTRA=e
  
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION TvRead, StrRight

   ; Keywords 
   if ( N_Elements( FileName ) ne 1 ) then FileName = 'idl.gif'

   ; Since TVIMAGE writes the ".gif" extension to the filename, then
   ; we must remove it from the filename.  This is a hack. (bmy, 12/2/02)
   Ind = StrPos( FileName, '.gif' )
   if ( Ind[0] ge 0 ) $
      then NewFileName = StrMid( FileName, 0, Ind ) $
      else NewFileName = FileName

   ;====================================================================
   ; Do screen capture for either X or Z devices
   ;====================================================================
   case ( StrUpCase( StrTrim( !D.NAME, 2 ) ) ) of 
       
      ; X-WINDOW: 
      'X': begin
         ThisFrame = TvRead( FileName=NewFileName, /GIF )
      end
 
      ; Z-BUFFER
      'Z': begin
         ThisFrame = TvRead( FileName=NewFileName, /GIF )
      end

      ; Otherwise return w/ error
      else: begin
         Message, 'Cannot screen grab from ' + !D.NAME, /Continue
         return
      end

   endcase

   ; quit
   return
end
 
