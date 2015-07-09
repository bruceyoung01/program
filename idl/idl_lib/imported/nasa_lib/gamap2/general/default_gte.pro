; $Id: default_gte.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        DEFAULT_GTE
;
; PURPOSE:
;        Define default system variables for GTE data directories
;        and GTE programs. Specific entries are made for the
;        PEM-Tropics A and B projects.
;        This procedure is caled from DEFAULT_DIRS when 'GTE' is
;        added as an argument.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        DEFAULT_GTE,host
;
; INPUTS:
;        HOST -> the name of the host computer which is running IDL.
;            In our environment these are sol or cyclope or now.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        Additional system variables are created:
;           !GTE_Dir   = home of GTE data on current platform
;           !PEMTA_Dir = PEM-Tropics A data
;           !PEMTB_Dir = PEM-Tropics B data
;
;           !GTE_Filetypes = list of fiel extensions used with GTE data
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        It is assumed that this routine is called from DEFAULT_DIRS
;        although it should be working stand-alone as well.
;
; NOTES:
;
; EXAMPLE:
;        see default_dirs
;
; MODIFICATION HISTORY:
;        mgs, 12 May 1999: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine default_gte"
;-----------------------------------------------------------------------


pro default_gte,host


   ; Are we on a windows or unix platform (no IDL macs around here)
   ; Need this for cyclope which is dual boot !
   IsWindows = ( strupcase(!Version.OS_Family) eq 'WINDOWS' )
   IsUnix    = ( strupcase(!Version.OS_Family) eq 'UNIX' )
 
 
   ; Host name must be lower case
 
   ; For our purposes we define the following default directories:
   ; === special project directories ===
   ; !GTE_Dir
   ; !PEMTA_Dir
   ; !PEMTB_Dir
 
 
   case (host) of
 
      'cyclope' : begin                        ; cyclope runs dual boot
                     if (IsWindows) then begin   
                         defsysv,'!GTE_Dir',!DataDir+!FNSep+'gte'
                         defsysv,'!PEMTA_Dir',!GTE_Dir+!FNSep+'pem-ta'
                         defsysv,'!PEMTB_Dir',!GTE_Dir+!FNSep+'pem-tb'
                     endif else begin
                         defsysv,'!GTE_Dir',!DataDir+!FNSep+'gte'
                         defsysv,'!PEMTA_Dir',!GTE_Dir+!FNSep+'pem-ta'
                         defsysv,'!PEMTB_Dir',!GTE_Dir+!FNSep+'pem-tb'
                     endelse
                  end
   
      'sol'     : begin                        ; unix IDL workgroup server
                         defsysv,'!GTE_Dir',!DataDir
                         defsysv,'!PEMTA_Dir',!GTE_Dir+!FNSep+'pem-t'
                         defsysv,'!PEMTB_Dir',!GTE_Dir+!FNSep+'pem-tb'
                  end
 
       'else'   : begin
                     message,'Unknown host! Cannot add project specific ' + $
                         'default directories.', $
                         /INFO
                  end
 
   endcase



   ; ====  here we define a few other potentialy useful things  ====
   defsysv,'!GTE_Filetypes',[ '.bdt', '.pmt', '.pmb', '.pwa', '.pwb' ]

 
return
end
 
