; $Id: is_dir.pro,v 1.1.1.1 2007/07/17 20:41:38 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;	 IS_DIR (function)
;
; PURPOSE:
;	 Tests if a directory exists
;
; CATEGORY:
;	 File & I/O
;
; CALLING SEQUENCE:
;	 RESULT = IS_DIR( PATH )
;
; INPUTS:
;        PATH -> The variable to be tested.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> =1 if directory exists, =0 otherwise
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
; EXAMPLE:
;	 PRINT, IS_DIR( '~/IDL/tools/' )
;           1
;
;	      ; Test the existence of the ~/IDL/tools directory.
;
; MODIFICATION HISTORY:
;    R.Bauer, 26 Jan 1999: INITIAL VERSION
;                          - from Forschungszentrum Juelich GmbH ICG-1
;        bmy, 24 May 2007: TOOLS VERSION 2.06
;                          - updated comments
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
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine is_dir"
;-----------------------------------------------------------------------


FUNCTION is_dir,path
   errvar=0
   CATCH,errvar
   IF errvar NE 0 THEN RETURN,0
   CD,curr=curr,path
   CD,curr
   RETURN,1
END

