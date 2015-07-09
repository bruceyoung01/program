; $Id: myct_define.pro,v 1.1.1.1 2003/10/22 18:09:41 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MYCT_DEFINE
;
; PURPOSE:
;        Defines the !MYCT system variable with default values.
;        !MYCT is used to make colortable parameters available to
;        plotting programs.
;
; CATEGORY:
;        Color Table Manipulation
;
; CALLING SEQUENCE:
;        MYCT_DEFINE
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        MYCT_DEFAULTS (function)
;
; REQUIREMENTS:
;        References other routines from the TOOLS package.
;
; NOTES:
;        This routine should be called from your "idl_startup.pro"
;        batch file, so that !MYCT will be defined and ready for
;        use by all other routines that need it.
;
; EXAMPLE:
;        MYCT_DEFINE
;
;             ; Defines the !MYCT system variable 
;
; MODIFICATION HISTORY:
;        bmy, 30 Sep 2002: VERSION 1.00
;
;-
; Copyright (C) 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine myct_define"
;-----------------------------------------------------------------------


pro MyCt_Define
 
   ; First test to see if MYCT already exists
   DefSysV, '!MYCT', Exists=Exists
 
   ; If !MYCT doesn't exist, then define a structure
   if ( not Exists ) then begin
 
      ; Get default values
      Result = MyCt_Defaults()
 
      ; Define !MYCT
      DefSysV, '!MYCT', Result
 
   endif
 
end
