; $Id: ctm_namext.pro,v 1.1.1.1 2007/07/17 20:41:27 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_NAMEXT
;
; PURPOSE:
;        Returns the proper filename extension for CTM model names.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Models & Grids
;
; CALLING SEQUENCE:
;        RESULT = CTM_NAMEXT( MODELINFO )
;
; INPUTS:
;        MODELINFO -> a MODELINFO structure (output from function
;             CTM_TYPE) desribing the desired CTM model.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> Returns a string containing the model name 
;             (e.g. 'geos3', 'geos4', 'geos5', 'gcap', 'giss2p', 
;              'generic', etc.).
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
;        (1) Add more model names as is necessary.
;
; EXAMPLE:
;        MODELINFO = CTM_TYPE( 'GEOS_STRAT', RESOLUTION=4 )
;        PRINT, CTM_NAMEXT( MODELINFO )
;             geoss
;
;             ; Returns filename extension for the GEOS-STRAT model
;
; MODIFICATION HISTORY:
;        bmy, 30 Jun 2000: GAMAP VERSION 1.46
;        bmy, 02 Jul 2001: GAMAP VERSION 1.48
;                          - added GENERIC as a return option
;        bmy, 02 Oct 2003: GAMAP VERSION 1.53
;                          - now add GEOS3_30L to the CASE statement
;        bmy, 16 Oct 2003: - now add GEOS4 to the CASE statement
;        bmy, 12 Feb 2004: GAMAP VERSION 2.01a
;                          - added GEOS4_30L to the CASE statement
;        bmy, 05 Aug 2004: GAMAP VERSION 2.02
;                          - added GCAP to the CASE statement
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - added GEOS5, GEOS5_47L to the CASE statement
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
; or phs@io.harvard.edu with subject "IDL routine ctm_namext"
;-----------------------------------------------------------------------


function CTM_NamExt, ModelInfo
 
   ; Error check
   if ( not ChkStru( ModelInfo, [ 'NAME' ] ) )  then begin
      Message, 'Invalid MODELINFO structure!'
   endif
 
   ; Return proper filename extension for model name
   case ( ModelInfo.Name ) of
      'GEOS1'         : return, 'geos1' 
      'GEOS_STRAT'    : return, 'geoss'
      'GEOS2'         : return, 'geos2' 
      'GEOS3'         : return, 'geos3'
      'GEOS3_30L'     : return, 'geos3'
      'GEOS4'         : return, 'geos4'
      'GEOS4_30L'     : return, 'geos4'
      'GEOS5'         : return, 'geos5'
      'GEOS5_47L'     : return, 'geos5'
      'GCAP'          : return, 'gcap'
      'GISS_II'       : return, 'giss2'
      'GISS_II_PRIME' : return, 'giss2p'
      'FSU'           : return, 'fsu'
      'GENERIC'       : return, 'generic'
      'DUMMY'         : return, 'generic'

      else: begin
         Message, 'Invalid MODELINFO.NAME field!', /Continue
         return, '-1'
      end
   endcase
 
end
 
