; $Id: ctm_resext.pro,v 1.1.1.1 2007/07/17 20:41:28 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_RESEXT
;
; PURPOSE:
;        Returns the proper filename extension for CTM resolution.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Models & Grids
;
; CALLING SEQUENCE:
;        RESULT = CTM_RESEXT( MODELINFO )
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
;        (e.g. '05x05', '1x1', '2x25', '4x5', '8x10' etc.)
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        CHKSTRU (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Add more grid resolutions as is necessary.
;
; EXAMPLE:
;        MODELINFO = CTM_TYPE( 'GEOS4' )
;        PRINT, CTM_NAMEXT( MODELINFO )
;             4x5
;
;             ; Returns filename extension for the 
;             ; 4x5 GEOS-4 model grid
;
; MODIFICATION HISTORY:
;        bmy, 30 Jun 2000: GAMAP VERSION 1.46
;        bmy, 08 Aug 2000: - Added string for 0.5 x 0.5
;        bmy, 08 Feb 2006: GAMAP VERSION 2.04
;                          - Added strings for 1.0 x 1.25 and 
;                            0.5 x 0.625
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - added string for 0.5 x 0.667
;
;-
; Copyright (C) 2000-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_resext"
;-----------------------------------------------------------------------


function CTM_ResExt, ModelInfo
 
   ; External functions
   FORWARD_Function ChkStru

   ; Make sure MODELINFO has the RESOLUTION structure tag
   if ( not ChkStru( ModelInfo, [ 'RESOLUTION' ] ) )  then begin
      Message, 'Invalid MODELINFO structure!'
   endif

   ; Return filename extension for model grid resolution
   case ( ModelInfo.Resolution[1] ) of
      0.5  : begin
                case( ModelInfo.Resolution[0] ) of
                   0.5   : return, '05x05'
                   0.625 : return, '05x0625'
                   else  : return, '05x0667'
                endcase
             end
      1    : begin
                if ( ModelInfo.Resolution[0] eq 1.25 ) $
                   then return, '1x125'                $
                   else return, '1x1'
             end
      2    : return, '2x25'
      4    : return, '4x5'
      8    : return, '8x10'
 
      else : begin
         Message, 'Invalid MODELNAME.RESOLUTION value', /Continue
         return, '-1'
      end
   endcase
end
 
