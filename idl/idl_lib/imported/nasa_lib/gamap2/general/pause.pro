; $Id: pause.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PAUSE
;
; PURPOSE:
;        Halts program execution until the user presses RETURN.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        PAUSE
;
; INPUTS:
;        MSG -> Specify a message to be displayed before pausing
;             program execution.  MSG may be omitted.
;            
; KEYWORD PARAMETERS:
;        None
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
;        PRINT, DATA
;        PAUSE
;             ; Prints a data array and then pauses to allow
;             ; the user time to examine the results.
;
;        PRINT, DATA
;        PAUSE, 'look at data'
;             ; Same as above exmaple, but this time, print an
;             ; informational message before pausing.
; 
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.harvard.edu with subject "IDL routine pause"
;-----------------------------------------------------------------------


pro Pause, Msg
 
   ; Print message if passed
   if ( N_Elements( Msg ) gt 0 ) then begin
      Message, Msg, /Info
   endif
 
   ; Halt with a READ statement
   Str = ''
   Read, Str, Prompt='% Hit RETURN to continue...'
 
   ; Quit
   return
end
