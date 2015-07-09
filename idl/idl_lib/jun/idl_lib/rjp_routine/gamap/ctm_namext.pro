; $Id: ctm_namext.pro,v 1.3 2005/03/24 18:03:11 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_NAMEXT
;
; PURPOSE:
;        Returns the proper filename extension for CTM model names.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        Result = CTM_NAMEXT( MODELINFO )
;
; INPUTS:
;        MODELINFO -> a MODELINFO structure (output from function
;             CTM_TYPE) desribing the desired CTM model.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        Returns a string containing the model name (e.g. 'geos1',
;        'geoss', 'geos2', 'giss2', 'giss2p', 'fsu', 'generic', etc.).
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
;        (2) Add more model names as is necessary.
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
;
;-
; Copyright (C) 2000-2004, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_namext"
;-------------------------------------------------------------


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
 
