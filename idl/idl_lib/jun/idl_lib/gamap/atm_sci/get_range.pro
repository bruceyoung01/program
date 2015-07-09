; $Id: get_range.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GET_RANGE
;
; PURPOSE:
;        Enter the data range into a variable descriptor array
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        GET_RANGE,data,vardesc [,minvalid]
;
; INPUTS:
;        DATA -> The data array (NLINES, NVARS)
;
;        VARDESC -> The variable descriptor array (see GTE_VARDESC).
;            Must contain NVARS elements, and a 2-element vector
;            tagged RANGE. These values will be changed.
;
;        MINVALID -> minimum valid data value to discriminate against
;            missing values etc. Default is -1.0E30.
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required
;        ===============================
;        GTE_VARDESC (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        ; read binary data and retrieve range
;        READ_BDT0001, '~/tmp/*.bdt', DATA, VARDESC
;        GET_RANGE, DATA, VARDESC
;
; MODIFICATION HISTORY:
;        mgs, 24 Aug 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine get_range"
;-----------------------------------------------------------------------


pro get_range, data, vardesc, minvalid
 
 
   if (n_params() lt 2) then begin
      print,'*** GET_RANGE: Need two parameters!'
      return
   endif
 
   if (n_elements(data) eq 0) then return
   
   if (n_elements(minvalid) eq 0) then minvalid = -1.0E30
 
   ; make a new variable descriptor if not passed
   if (n_elements(vardesc) eq 0) then begin

      ; get data size information
      s = size(data)
      if (s[0] ne 2) then begin
         print,'*** GET_RANGE: Data not 2D array!'
         return
      endif

      nvars = s[2]

      ; create variable descriptor structure array
      vardesc = gte_vardesc(nvars)
   endif
 
   ; get data range
   for i=0,nvars-1 do begin
      test = where( tmpdat gt minvalid )
      if (test[0] ge 0) then begin
         vardesc[i].range[0] = min( tmpdat[test], max=tmpmax )
         vardesc[i].range[1] = tmpmax
      endif
   endfor
 
   return
 
end
