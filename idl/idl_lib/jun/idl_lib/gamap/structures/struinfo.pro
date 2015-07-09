; $Id: struinfo.pro,v 1.1.1.1 2007/07/17 20:41:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        STRUINFO (function)
;
; PURPOSE:
;        Return information about structures. This routine is designed 
;        to help handling variable structures of mixed type.
;
; CATEGORY:
;        Structures
;
; CALLING SEQUENCE:
;        INFO = STRUINFO( STRU, [, Keywords ] )
;
; INPUTS:
;        STRU -> a structure  
;
; KEYWORD PARAMETERS:
;        NAMES -> return variable names as spelled in structure tags
;        
;        ORIGINAL_NAMES -> return variable names as stored in 
;             __NAMES__ tag
;        
;        EXTRA -> return information stored in __EXTRA__ tag. This
;             information is always returned as a structure 
;
;        NVARS -> return number of variables, i.e. tags that do 
;             not begin with '__'
;
;        HOMOGENEOUS -> return tag indices of tags with identical '
;             number of elements (only those can be combined to an 
;             array with Stru2Arr).  This keyword honors the RefIndex 
;             keyword.
;
;        NUMERIC -> return tag indices of numeric structure tags
;
;        TYPE -> return variable type of structure tags. For 
;             non-variable tags (whose name begin with '__') a -1 
;             is returned
;        
;        REFINDEX -> indicates the tag index to compare the number 
;             of elements to (default is the first variable index).
;
; OUTPUTS:
;        The desired information (hopefully)
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================
;        CHKSTRU (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        PRINT, STRUINFO( !p, /names )
;           BACKGROUND CHARSIZE CHARTHICK CLIP COLOR FONT LINESTYLE 
;           MULTI NOCLIP NOERASE NSUM POSITION PSYM REGION SUBTITLE
;           SYMSIZE T T3D THICK TITLE TICKLEN CHANNEL
;
;             ; Print the names from the !P system variable structure
;
; MODIFICATION HISTORY:
;        mgs, 03 May 1999: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine struaddvar"
;-----------------------------------------------------------------------


function StruInfo, stru, Names=Names, Original_Names=Original_Names,$
                   Extra=Extra, NVars=NVars, Homogeneous=Homogeneous, $
                   Numeric=Numeric,RefIndex=RefIndex, Type=Type
 
 
   ; External functions
   FORWARD_FUNCTION ChkStru 
 
   ; exit if argument is no structure
   if (not ChkStru(stru)) then begin
      message,'Argument must be a structure!',/Continue
      return,-1L
   endif
 
   ; extract tag names - we almost certainly need them
   tnames = Tag_Names(stru)
   vind = where(strmid(tnames,0,2) ne '__',NNVars)  ; variable names
 
 
   ; return variable names as stored in tags
   if (keyword_set(Names)) then begin
      if (vind[0] ge 0) then $
         return,tnames[vind]  $
      else  $
         return,-1L
   endif
 
   ; return original variable names 
   if (keyword_set(Original_Names)) then begin
      if (ChkStru(stru,'__NAMES__')) then  $
         return,stru.__names__  $
      else begin
         message,'Structure contains no original names. Will return' + $
                 ' tag names instead.',/INFO
         if (vind[0] ge 0) then $
            return,tnames[vind]  $
         else  $
            return,-1L
      endelse
   endif
 
   ; return __EXTRA__ stuff
   ; always return as a structure so that it can be easily passed
   ; through an _EXTRA keyword
   if (keyword_set(Extra)) then begin
      if (ChkStru(stru,'__EXTRA__')) then  $
         return,stru.__extra__  $
      else begin
         message,'Structure contains no EXTRA tags.',/INFO
         return,-1L
      endelse
   endif
 
 
   ; return number of variables
   if (keyword_set(NVars)) then $
      return,NNVars
   
   
   ; The follwoing tests require at least one "variable" tag
   if (NNVars lt 1) then begin
      message,'At least one variable required in structure!',/Continue
      return,-1L
   endif
 
 
   ; check for homogeneity of structure variables:
   ; do they all contain the same number of elements?
   if (n_elements(RefIndex) eq 0) then RefIndex = vind[0L]
 
   if (keyword_set(homogeneous)) then begin
      ; get number of elements for all tags (-1L for non-variables)
      nel = lonarr(N_Tags(stru))-1L
      for i=0,NNVars-1 do $
         nel[vind[i]] = N_Elements( stru.(vind[i]) )
      return,where( nel eq nel[RefIndex] )
   endif
 
 
   ; check for numerical structure variables:
   if (keyword_set(numeric)) then begin
      ; get type of all tags (set -1L for non-variables)
      tel = lonarr(N_Tags(stru))-1L
      for i=0,NNVars-1 do $
         tel[vind[i]] = size( stru.(vind[i]), /TYPE )
      return,where( (tel ge 1 AND tel le 5) OR (tel ge 12 AND tel le 15) )
   endif
 
 
   ; return variable type
   if (keyword_set(type)) then begin
      ; get type of all tags (set -1L for non-variables)
      tel = lonarr(N_Tags(stru))-1L
      for i=0,NNVars-1 do $
         tel[vind[i]] = size( stru.(vind[i]), /TYPE )
      return,tel
   endif
 
 
   message,'Unknown Request!',/Continue
   return,-1L
 
end
 
