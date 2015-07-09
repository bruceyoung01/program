; $Id: ctm_resext.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_RESEXT
;
; PURPOSE:
;        Returns the proper filename extension for CTM resolution.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        Result = CTM_RESEXT( MODELINFO )
;
; INPUTS:
;        MODELINFO -> a MODELINFO structure (output from function
;             CTM_TYPE) desribing the desired CTM model.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        Returns a string containing the model resolution.
;        (e.g. '1x1', '2x25', '4x5', '8x10')
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        CHKSTRU (function)
;
; REQUIREMENTS:
;        References routines from both GAMAP & TOOLS packages
;
; NOTES:
;        (1) The filename extensions returned by CTM_NAMEXT and CTM_RESEXT
;            are typically used in files containing global CTM data.
;  
;        (2) Add more grid resolutions as is necessary.
;
; EXAMPLE:
;        MODELINFO = CTM_TYPE( 'GEOS_STRAT' )
;        PRINT, CTM_NAMEXT( MODELINFO )
;             4x5
;
;             ; Returns filename extension for the 4x5 GEOS-STRAT model
;
; MODIFICATION HISTORY:
;        bmy, 30 Jun 2000: GAMAP VERSION 1.46
;        bmy, 08 Aug 2000: - Added string for 0.5 x 0.5
;
;-
; Copyright (C) 2000, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_resext"
;-----------------------------------------------------------------------


function CTM_ResExt, ModelInfo
 
   ; Error check
   if ( not ChkStru( ModelInfo, [ 'RESOLUTION' ] ) )  then begin
      Message, 'Invalid MODELINFO structure!'
   endif
 
   ; Return filename extension for model grid resolution
   case ( ModelInfo.Resolution[1] ) of
      0.5 : return, '05x05'
      1   : return, '1x1'
      2   : return, '2x25'
      4   : return, '4x5'
      8   : return, '8x10'
 
      else : begin
         Message, 'Invalid MODELNAME.RESOLUTION value', /Continue
         return, '-1'
      end
   endcase
end
 
