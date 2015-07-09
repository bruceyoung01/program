; $Id: close_device.pro,v 1.1.1.1 2007/07/17 20:41:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CLOSE_DEVICE
;
; PURPOSE:
;        CLOSE_DEVICE closes the PostScript device and spawns
;        a print job to the printer specified by the user or
;        it can be used to close a graphics window.
;
; CATEGORY:
;        Graphics
;
; CALLING SEQUENCE:
;        CLOSE_DEVICE [,OLD_DEVICE] [, Keywords ]
;
; INPUTS:
;        OLD_DEVICE -> Name of device that shall become the active
;             plotting device. If omitted, "X", "WIN" or "MAC" will
;             be set depending on !VERSION.OS_FAMILY.  Hence, 
;             specification of OLD_DEVICE is only rarely needed.
;             This parameter works together with the OLD_DEVICE 
;             parameter of OPEN_DEVICE which returns the device name 
;             before the postscript device (or a graphics device) is 
;             opened.  The OLD_DEVICE parameter can be misused to set 
;             the output device to anything! Therefore, it's probably 
;             safest to not use it and stick with the operating system 
;             dependent default.
;
; KEYWORD PARAMETERS:
;        LABEL -> a string that contains an annotation for a postscript
;             plot (usually a user name and/or filename). The current 
;             data and time will be appended if TIMESTAMP is set. 
;             NOTE: TIMESTAMP will produce an annotation even if LABEL
;             is not provided. The annotation is only added to 
;             postscript plots and only if the ps file is actually 
;             open.
;
;        /TIMESTAMP  -> add date and time to the LABEL on the plot.
;             If no LABEL is provided, the username and filename 
;             (value of FILENAME will be used or the filename of the 
;             current postscript file will be added). The timestamp 
;             is only added to postscript plots and only on the last 
;             page.
;
;        PRINTER -> Name of the printer queue to send output to.
;             Default is 'none', i.e. the postscript file will only 
;             be closed and can then be manually printed e.g. using 
;             the Unix lpr command.  Direct printing only works in 
;             Unix environments.
;
;        WINDOW -> window number to be closed (or -1 if current)
;
;        _EXTRA=e -> any additional keywords to CLOSE_DEVICE will 
;             be passed on to STRDATE which is used to format the 
;             date and time string.  Possible values are: /SHORT, 
;             /SORTABLE, /EUROPEAN.
;
;        LCOLOR -> the color value for the LABEL (default 1).
;
;        LPOSITION -> the position of the LABEL in normalized 
;             coordinates (a two-element vector with default 
;             [0.98,0.007]).
;
;        LSIZE -> the charcter size of the LABEL (default 0.7).
;
;        LALIGN -> the alignment of the LABEL (default 1).
;
;        FILENAME -> name of the PostScript file.  This is actaully
;             obsolete now because the PostScript filename is 
;             determined at the time the file is opened (e.g. in
;             routine OPEN_DEVICE)
;
; OUTPUTS:
;        If postscript device is active, a *.ps file will be closed 
;        and optionally sent to the printer.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================
;        STRDATE (function)
;
; REQUIREMENTS:
;        Requires routines in the 
;
; NOTES: 
;        The WINDOW keyword is only evaluated if the current device 
;        supports windows [!D.FLAGS AND 256) GT 0]. If you only want 
;        to close a postscript file and don't fuss around with your 
;        screen windows then simply don't set this keyword.
;
; EXAMPLES:
;        (1)
;        CLOSE_DEVICE
;
;            ; Closes a postscript file (if opened) and resets the 
;            ; current plotting device to 'X', 'WIN', or 'MAC' 
;            ; depending on the OS_FAMILY.
;
;        (2) 
;        CLOSE_DEVICE, PRINTER='hplj4', LABEL='mgs', /TIMESTAMP
;
;            ; If current device name is PS then the postscript 
;            ; file will be closed, a user, date and time label will 
;            ; be added and the file will be spooled to the printer 
;            ; queue 'hplj4'. NOTE: Printing of the file fails if you 
;            ; specified FILENAME as a relative path in the OPEN_DEVICE 
;            ; command and you changed your working directory while
;            ; the device was opened.
;  
;        (3)
;        CLOSE_DEVICE, WIN=-1
;
;            ; If current device name is PS then the postscript file 
;            ; will be closed. If the current device is a screen 
;            ; device (that supports windows), then the active window
;            ;  will be deleted.
; 
; MODIFICATION HISTORY:
;        bmy, 18 Aug 1997: VERSION 1.00
;        bmy, 19 Aug 1997: VERSION 1.01
;        mgs, 20 Aug 1997: VERSION 1.02
;        mgs, 08 Apr 1998: VERSION 2.00 
;                          - automatic filename detection
;                          - default device depending on OS_FAMILY
;        mgs, 21 May 1998: 
;                          - added L.. keywords to control label 
;                            and timestamp output
;        mgs, 18 Nov 1998:
;                          - added output of username as default in timestamp
;        bmy, 28 Jul 2000: TOOLS VERSION 1.46
;                          - cleaned up a few things
;        bmy, 24 May 2007: TOOLS VERSION 2.06
;                          - Updated comments
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1997-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine close_device"
;-----------------------------------------------------------------------


pro Close_Device, Old_Device,                         $
                  Printer=Printer,     Label=Label,   $
                  TimeStamp=TimeStamp, LColor=LColor, $
                  LPosition=LPosition, LSize=LSize,   $
                  LAlign=LAlign,       Window=Window, $
                  FileName=FileName,   _EXTRA=e 

   ; Return to caller
   on_error, 2

   ; determine default device
   case ( strupcase( !VERSION.OS_FAMILY ) ) of
      'UNIX'    : DefDev = 'X'
      'WINDOWS' : DefDev = 'WIN'
      'MACOS'   : DefDev = 'MAC'

      else : begin
         print,'*** CLOSE_DEVICE: unknown operating system ! ***'
         DefDev = 'NULL'
      end
   endcase

   ; set default value of Old_Device
   if ( n_params() le 0 ) then Old_Device = DefDev
      
   ; set default for printer queue
   if ( N_Elements( Printer ) eq 0 ) then Printer  = '' 

   ; set default position, charsize and color for label
   if ( N_Elements( LPosition ) ne 2 ) then LPosition = [0.98,0.007]
   if ( N_Elements( LSize     ) eq 0 ) then LSize = 0.7
   if ( N_Elements( LColor    ) eq 0 ) then LColor = 1
   if ( N_Elements( LAlign    ) eq 0 ) then LAlign = 1

   ;====================================================================
   ; if postscript device active
   ;====================================================================
   if (!d.name eq 'PS') then begin 

      ; determine if ps file was opened
      if ( !D.UNIT gt 0 ) then begin

         ; extract current filename
         r = fstat( !D.UNIT )
         CFileName = r.name

         ; add label and timestamp if desired
         addlabel = 0           

         ; default: no label
         if ( N_Elements( Label ) eq 0 ) then begin

            ; get user name
            user_name = getenv( 'USER' )
            if ( user_name ne '' ) then user_name = user_name+' '

            ; for compatibility set FileName as default label
            if ( N_Elements( FileName ) gt 0 ) then $
               Label = user_name + FileName $
            else $              ; use actual filename as label
               Label = user_name + CFileName
         endif else $
            addlabel = 1        ; add label in any case
              
         if ( keyword_set( TimeStamp ) ) then begin
            Label = Label + ', ' + strdate(_EXTRA=e)
            addlabel = 1        ; add label
         endif

         if ( addlabel ) then $
            XYOutS, LPosition(0), LPosition(1), Label, $
               Color=LColor, Align=LAlign, /Norm, CharSize=LSize

         ; close postscript file
         device, /close    

         ; spawn postscript file to printer
         if ( Printer ne '' ) then begin 
            TRIM_Printer = strtrim(Printer,2)
            print, 'Sending output to printer ' + TRIM_Printer
            spawn, 'lpr -P ' + TRIM_Printer + ' ' + CFileName
         endif
      endif else $              ; ps file was not open
         device,/close          ; only close it

   endif $

   ;====================================================================
   ; no postscript device active
   ;====================================================================
   else begin                   

      ; check if device supports windows and if a window shall be closed
      if( N_Elements(window) gt 0) then begin
         if( window lt 0 ) then window = !D.WINDOW 
         if( (!D.FLAGS AND 256) GT 0 AND window ge 0 ) then wdelete,window
      endif

   endelse

   ; make Old_Device (usually default screen) active
   Set_Plot, Old_Device

   return
end


