; $Id: get_is_edged.pro,v 1.1.1.1 2007/07/17 20:41:47 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GET_IS_EDGED  (function)
;
; PURPOSE:
;        Determine if a GEOS-5 data field is defined on the
;        vertical grid box edges or centers.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation
;
; CALLING SEQUENCE:
;        RESULT = GET_IS_EDGED( NAME )
;
; INPUTS:
;        NAME -> Name of the tracer or met field to be tested.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        RESULT -> Returns 1 if the tracer or met field specified by
;             NAME is defined on grid box vertical edges, or 0
;             otherwise.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) This is currently a KLUDGE.  Figure out a more 
;            robust way of determining if fields are defined on 
;            level edges or level centers later on. (bmy, 7/16/07)
;
;        (2) Add more names to the CASE statement as necessary.
;
; EXAMPLES:
;        (1)
;        PRINT, GET_IS_EDGED( 'PEDGE' )
;          1
;             ; The GEOS-5 PEDGE field is defined on the vertical
;             ; grid edges, so GET_IS_EDGED returns 1.
;
;        (2)
;        PRINT, GET_IS_EDGED( 'UWND' )
;          0
;
;             ; The GEOS-5 UWND field is defined on the vertical
;             ; grid centers, so GET_IS_EDGED returns 0.
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
; or phs@io.harvard.edu with subject "IDL routine get_is_edged"
;-----------------------------------------------------------------------


function Get_Is_Edged, Name

   ; Certain GEOS-5 fields are defined on the edges
   case ( StrUpCase( StrTrim( Name, 2 ) ) ) of
      'PEDGE' : Is_Edged = 1L
      'PLE'   : Is_Edged = 1L
      'CMFMC' : Is_Edged = 1L
      'MFXC'  : Is_Edged = 1L
      'MFYC'  : Is_Edged = 1L
      'MFZ'   : Is_Edged = 1L
      else    : Is_Edged = 0L
   endcase

   ; Return
   return, Is_Edged
end
