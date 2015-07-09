; Copyright (c) 1999, Forschungszentrum Juelich GmbH ICG-1
; All rights reserved.
; Unauthorized reproduction prohibited.
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.
;
;+
; NAME:
;       is_dir
;
; PURPOSE:
;       Test if directory exist
;
; CATEGORY:
;       PROG_TOOLS
;
; CALLING SEQUENCE:
;       Result = is_dir(path)
;
; INPUTS:
;       path: The variable to be tested.
;
; OUTPUTS:
;       This function returns 1 if directory exist else it returns 0
;
; EXAMPLE:
;       dir='C:\temp'
;       PRINT, is_dir(dir)
;       -> 1
;
; MODIFICATION HISTORY:
;       Written by:     R.Bauer , 26.01.99
;-


FUNCTION is_dir,path
   errvar=0
   CATCH,errvar
   IF errvar NE 0 THEN RETURN,0
   CD,curr=curr,path
   CD,curr
   RETURN,1

END

