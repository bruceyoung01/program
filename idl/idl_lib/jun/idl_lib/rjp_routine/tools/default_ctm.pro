;-------------------------------------------------------------
; $Id: default_ctm.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;+
; NAME:
;        DEFAULT_CTM
;
; PURPOSE:
;        Define default system variable for CTM data directory.
;        This procedure is caled from DEFAULT_DIRS when 'CTM' is
;        added as an argument.
;
; CATEGORY:
;        Administrative Tools
;
; CALLING SEQUENCE:
;        DEFAULT_CTM,host
;
; INPUTS:
;        HOST -> the name of the host computer which is running IDL.
;            In our environment these are sol or cyclope for now.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        Additional system variable is created:
;          !CTM_Dir = the root of the file system
;          !CTM_Filetypes = a list of frequently encountered extensions
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
;        mgs, 20 May 1999: VERSION 1.00
;
;-
; Copyright (C) 1999, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine default_dirs"
;-------------------------------------------------------------


pro default_CTM,host


   ; Are we on a windows or unix platform (no IDL macs around here)
   ; Need this for cyclope which is dual boot !
   IsWindows = ( strupcase(!Version.OS_Family) eq 'WINDOWS' )
   IsUnix    = ( strupcase(!Version.OS_Family) eq 'UNIX' )
 
 
   ; Host name must be lower case
 
   ; For our purposes we define the following default directories:
   ; === special project directories ===
   ; !CTM_Dir

   amalthea = '~/amalthea' 
 
   case (host) of
 
      'cyclope' : begin                        ; cyclope runs dual boot
                     if (IsWindows) then begin   
                         defsysv,'!CTM_Dir',!DataDir
                     endif else begin
                         defsysv,'!CTM_Dir',!DataDir
                     endelse
                  end
   
      'sol'     : begin                        ; unix IDL workgroup server
                         defsysv,'!CTM_Dir',amalthea+!FNSep+'CTM4'
                  end
 
       'else'   : begin
                     message,'Unknown host! Cannot add project specific ' + $
                         'default directories.', $
                         /INFO
                  end
 
   endcase



   ; ====  here we define a few other potentialy useful things  ====
   defsysv,'!CTM_Filetypes',[ '.pch', '.bpch', '.ts' ]

 
return
end
 
