; $Id: is_defined.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        IS_DEFINED
;
; PURPOSE:
;        Tests if a program argument is defined (i.e. if it 
;        was passed any value(s) from the calling program).
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        RESULT = IS_DEFINED( ARG )
;
; INPUTS:
;        ARG -> The argument to be tested.
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
;        (1)
;        PRINT, IS_DEFINED( ARG )
;           0
;
;             ; Because ARG has not been yet assigned a value,
;             ; IS_DEFINED( ARG ) returns 0.
;        
;        (2)
;        ARG = 1
;        PRINT, IS_DEFINED( ARG )
;           1
;
;             ; Because ARG now has not been yet assigned a value,
;             ; IS_DEFINED( ARG ) now returns 1.
;
; MODIFICATION HISTORY:
;  D.Fanning, 02 Jul 1998: INITIAL VERSION
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments, cosmetic changes

;
;-
; Copyright (C) 1998, David Fanning
; Copyright (C) 2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine is_defined"
;-----------------------------------------------------------------------


function Is_Defined, Arg
 
   ; Test if an argument is defined
   return, Keyword_Set( N_Elements( Arg ) )
 
end
 
