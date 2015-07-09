; $Id: get_freelun.pro,v 1.1.1.1 2007/07/17 20:41:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        GET_FREELUN (function)
;
; PURPOSE:
;        Return next available logical unit number. Unlike 
;        the internal GET_LUN procedure, this function is not
;        restricted to unit numbers above 100, and it will 
;        detect any blocked unit number.
;
; CATEGORY:
;        File & I/O
;
; CALLING SEQUENCE:
;        lun = GET_FREELUN([LUN])
;
; INPUTS:
;        none
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        The lowest available logical unit number. This number is 
;        also returned in the LUN parameter for later use.
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
;        OPENW, GET_FREELUN( LUN ), FILENAME
;
;             ; Open a file and get the next free unit number.
;
; MODIFICATION HISTORY:
;        mgs, 17 Sep 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments, cosmetic changes
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
; or phs@io.as.harvard.edu with subject "IDL routine get_freelun"
;-----------------------------------------------------------------------


function get_freelun,lun
 
   help,/files,output=list

   lun = 1
 
   ; at least one file open 
   ; find lowest available unit number
   if (n_elements(list) gt 1) then begin
 
      ; maximum allowed number of open files exceeded?
      if (n_elements(list) gt  99) then $
         message,'Cannot handle any more open files'
 
        ; extract numbers and compare to expectation
      for i=1,n_elements(list)-1 do begin
         usedlun = fix(strmid(list[i],0,3))
         if (usedlun gt i) then begin
            lun = i
            return,lun     ; this one's free
         endif
      endfor
                           ; next free unit is greater than all used ones
      lun = i
      return,lun
 
   endif else $            ; no file opened
      return,lun
 
 
end
 
