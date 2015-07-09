; $Id: open_device.pro,v 1.1.1.1 2007/07/17 20:41:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        OPEN_DEVICE
;
; PURPOSE:
;        If hard copy is to be generated, OPEN_DEVICE opens the 
;        PostScript device.  Otherwise OPEN_DEVICE opens an Xwindow. 
;
; CATEGORY:
;        Graphics
;
; CALLING SEQUENCE:
;        OPEN_DEVICE [,OLD_DEVICE] [,keywords]
;
; INPUTS:
;        OLD_DEVICE -> This is now obsolete, and is only maintained
;             for backwards compatibility.
;
; KEYWORD PARAMETERS:
;        /PS -> will send PostScript file to printer
;
;        FILENAME -> The name to be given the PostScript file.
;             Default: idl.ps
;
;        /LANDSCAPE  -> will enable PostScript landscape mode
;
;        /PORTRAIT -> will enable PostScript portrait mode
;
;        XOFFSET, YOFFSET -> Keywords for the DEVICE command.  XSIZE
;             specifies the horizontal offset (in inches) of the page,
;             and YSIZE specifies the vertical offset (in inches) of
;             the page.  Defaults are as follows:
;
;             Plot type         XOFFSET          YOFFSET

;             -------------------------------------------------
;             Portrait           0.25             0.25
;             Landscape          0.75             0.75
;             
;        XSIZE, YSIZE -> Keywords for the DEVICE command.  XSIZE
;             specifies the horizontal size (in inches) of the page,
;             and YSIZE specifies the vertical size (in inches) of
;             the page.  Defaults are as follows:
;             
;             Plot type         XSIZE            YSIZE
;             -------------------------------------------------
;             Portrait           8.0              10.0
;             Landscape      11 - 2*XOFFSET   8.5 - 2*YOFFSET
;
;
;        /COLOR -> will enable PostScript color mode
;
;        WINPARAM -> An integer vector with up to 5 elements:
;             WINPARAM(0) = window number  (if negative, a window
;                          will be opened with the /FREE option.
;             WINPARAM(1) = X dimension of window in pixels (width)
;             WINPARAM(2) = Y dimension of window in pixels (height)
;             WINPARAM(3) = X offset of window (XPOS)
;             WINPARAM(4) = Y offset of window (YPOS)
;
;        TITLE -> window title
;
;        /Z -> If set, will initialize the Z-buffer device.  If WINPARAM
;             is specified, then the size of the Z-buffer region will be
;             WINPARAM[1] x WINPARAM[2] pixels.  If WINPARAM is not 
;             specified, then the size of the Z-buffer region will be 
;             set to a default size of 640 x 512 pixels.
;
;        NCOLORS -> If /Z is set, NCOLORS specifies the number of colors
;             that will be made available to the Z-buffer device.
;         
;        _EXTRA=e -> additional keywords that are passed to the call to
;             the DEVICE routine (e.g. /ENCAPSULATED)
;
; OUTPUTS:
;        OLD_DEVICE -> stores the previous value of !D.NAME for
;             use in CLOSE_DEVICE. Note that CLOSE_DEVICE will automatically
;             set the default screen device if OLD_DEVICE is not provided,
;             hence it will only rarely be used.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        If PS=0 then  
;            Open Xwindow WINPARAM(0), which is WINPARAM(1) pixels wide
;            in the X-direction, and WINPARAM(2) pixels wide in the
;            Y-direction. 
;
;        If PS=1 then 
;           depending on /PORTRAIT or /LANDSCAPE and /COLOR
;           postscript is enabled in either portrait or landscape
;           mode as color or b/w plot
;
;        The key parameter which determines whether to open a postscript
;        file or a screen window is PS. Therefore, e.g. in a widget 
;        application, you can pass a standard set of parameters for both,
;        postscript and screen, to this routine, and determine the device
;        to be chosen by a button state or checkbox which is passed into PS.
;              
;        Also is currently hardwired for 8.5 x 11 inch paper (US
;        format).  Need to extend this to European A4 paper soon.
;        
;
; EXAMPLES:
;        (1)
;        OPEN_DEVICE, WINPARAM=[0,800,800]  
;
;             ; opens a screen window of size 800x800 
;             ; pixels at the default position
;
;        (2)
;        OPEN_DEVICE, /LANDSCAPE, FILENAME='myplot.ps'
;
;             ; opens a postscript file named myplot.ps in 
;             ; b/w and landscape orientation
;
;        (3)
;        OPEN_DEVICE, PS=PS, /PORTRAIT, /COLOR, WIN=2
;
;             ; depending on the value of PS either a color 
;             ; postscript file named idl.ps is opened or screen 
;             ; window number 2 in default size.
;
;        (4)
;        OPEN_DEVICE, /Z
;
;             ; Opens the IDL Z-buffer device.  The current 
;             ; color table will be preserved in the Z-buffer device.
;
; MODIFICATION HISTORY:
;        bmy  15 Aug 1997: VERSION 1.00
;        bmy, 19 Aug 1997: VERSION 1.01
;        mgs, 20 Aug 1997: VERSION 1.02
;        mgs, 09 Apr 1998: VERSION 1.10 
;                          - added 2 more parameters for WINPARAM
;                            and TITLE keyword
;        bmy, 28 Jul 2000: VERSION 1.46   
;                          - now make XSIZE, XOFFSET, YSIZE, YOFFSET keywords
;                          - cosmetic changes, updated comments
;        bmy, 30 Jan 2001: VERSION 1.47
;                          - added /Z and NCOLORS keywords for the Z-buffer
;                          - updated comments
;        bmy, 26 Jul 2001: VERSION 1.48
;                          - use default window size of 640 x 512 for
;                            the Z-buffer, if WINPARAM isn't specified.
;        bmy, 27 Aug 2001: - now call DEVICE with XSIZE, YSIZE,
;                            XOFFSET, YOFFSET for /LANDSCAPE plots
;                          - Updatedd comments
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1997-2007, Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine open_device"
;-----------------------------------------------------------------------


pro Open_Device, Old_Device,                               $
                 PS=PS,               FileName=FileName,   $
                 LandScape=LandScape, Portrait=Portrait,   $
                 XSize=XSize,         YSize=YSize,         $
                 XOffset=XOffset,     YOffset=YOffset,     $
                 WinParam=WinParam,   Title=Title,         $
                 Color=Color,         NColors=NColors,     $
                 Z=Z,                 _EXTRA=e

                 

   on_error, 2                  ; return to caller
	
   Old_Device = !D.NAME         ; retrieve current device

   ; Keyword settings
   if ( N_Elements( FileName ) eq 0 ) then FileName = 'idl.ps'
   if ( N_Elements( Color    ) eq 0 ) then Color    = 0
   if ( N_Elements( NColors  ) eq 0 ) then NColors  = 120

   Portrait  = Keyword_Set( Portrait )
   LandScape = 1 - Portrait

   ;====================================================================
   ; If /PS is set, then set up PostScript plot
   ;====================================================================
   if ( Keyword_Set( PS ) ) then begin
      Set_Plot, 'PS'
      
      ; Landscape mode
      if ( LandScape ) then begin 
         
         ; Defaults for /LANDSCAPE mode
         if ( N_Elements( XOffSet  ) ne 1 ) then XOffSet = 0.75
         if ( N_Elements( YOffSet  ) ne 1 ) then YOffSet = 0.75
         if ( N_Elements( XSize    ) ne 1 ) then XSize   = 11.0 - 2.0*XOffSet
         if ( N_Elements( YSize    ) ne 1 ) then YSize   = 8.5  - 2.0*YOffSet

         ; Call DEVICE for /LANDSCAPE mode
         Device, /Landscape,        Color=Color,     Bits=8,               $
                 Filename=FileName, XOffSet=XOffset, YOffset=11.0-YOffSet, $
                 XSize=XSize,       YSize=YSize,     /Inches,              $
                 _EXTRA=e

      ; Portrait mode
      endif else begin          

         ; Defaults for /PORTRAIT mode
         if ( N_Elements( XSize    ) ne 1 ) then XSize    = 8.0
         if ( N_Elements( YSize    ) ne 1 ) then YSize    = 10.0
         if ( N_Elements( XOffSet  ) ne 1 ) then XOffSet  = 0.25
         if ( N_Elements( YOffSet  ) ne 1 ) then YOffSet  = 0.25

         ; Call DEVICE w/ /PORTRAIT 
         Device, Color=Color, Bits=8,          /Portrait,         $
                 /Inches,     XOffSet=XOffSet, YOffSet=YOffSet,   $
                 XSize=XSize, YSize=YSize,     FileName=FileName, $
                 _EXTRA=e
      endelse


   endif $

   ;====================================================================
   ; If /Z is set, then initialize the Z-buffer
   ;====================================================================
   else if ( Keyword_Set( Z ) ) then begin
      Set_Plot, 'Z', /Copy

      ; Use default window size of 640 x 512 if WINPARAM isn't passed
      if ( N_Elements( WinParam ) eq 0 ) then WinParam = [0, 640, 512]

      Device, Set_Colors=NColors, $
              Set_Resolution=[ WinParam[1] > 60, WinParam[2] > 10 ]

   endif $

   ;====================================================================
   ; No PostScript or Z-buffer desired
   ; Only take action if WinParam given and device supports windows 
   ;====================================================================
   else begin                   
                                
      if ( ( !D.FLAGS AND 256 )   gt 0   AND $
           N_Elements( WinParam ) gt 0 ) then begin 

         ; WINPARAM must have 1, 3, or 5 elements, otherwise, default
         ; values for YSIZE and YOFFSET are used
         if ( N_Elements( WinParam ) gt 5 ) then WinParam = WinParam(0:4)
         
         if ( N_Elements( WinParam ) eq 4 ) then $
            WinParam = [ WinParam, 500 ]
         
         if ( N_Elements( WinParam ) eq 2 ) then $
            WinParam = [ WinParam, fix( WinParam(1) / 1.41 ) ]

         case ( N_Elements( WinParam ) ) of
            5 :  Window, WinParam(0), FREE=(WinParam(0) lt 0),  $
                    xsize=WinParam(1)>60, ysize=WinParam(2)>10, $
                    xpos=WinParam(3), ypos=WinParam(4),         $
                    Title=Title

            3 :  Window, WinParam(0), FREE=(WinParam(0) lt 0),  $
                    xsize=WinParam(1)>60, ysize=WinParam(2)>10, $
                    Title=Title

            1 :  Window, WinParam(0), FREE=(WinParam(0) lt 0), Title=Title

            else : print,'*** OPEN_DEVICE: UNEXPECTED ERROR ! ***'
         endcase
         
      endif 
      
   endelse

   return	
end

