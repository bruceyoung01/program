; $Id: myct_define.pro,v 1.2 2008/04/21 19:23:41 bmy Exp $
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
;        Color
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
;        None
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
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2002-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to yantosca@seas.harvard.edu
; or plesager@seas.harvard.edu with subject "IDL routine myct_define"
;
; ColorBrewer license info:
; -------------------------
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
; implied. See the License for the specific language governing 
; permissions and limitations under the License.
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
