; $Id: ctm_getdefaultstructures.pro,v 1.1.1.1 2003/10/22 18:06:01 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_GETDEFAULTSTRUCTURES
;
; PURPOSE:
;        Return default values for FileInfo and DataInfo for
;        subsequent analysis. The defaults are taken from the
;        global common block defined in gamap_cmn.pro
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_GETDEFAULTSTRUCTURES,FileInfo,DataInfo,result=result
;
; INPUTS:
;        FILEINFO -> A named variable that will contain the global
;            FileInfo structure array, i.e. information about all
;            files that have been opened.
;
;        DATAINFO -> A named variable that will contain the global
;            DataInfo structure array, i.e. information about all
;            data records that have been read from the headers of 
;            all opened CTM files.
;
; KEYWORD PARAMETERS:
;        RESULT -> returns 1 if assignment was successful, 0 otherwise.
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        CTM_GETDEFAULTSTRUCTURES,FileInfo,DataInfo,result=result
;
;        if (not result) then return
;
;        ; the current state of the global FileInfo and DataInfo 
;        ; structures will be copied into FileInfo and DataInfo
;
; MODIFICATION HISTORY:
;        mgs, 20 Aug 1998: VERSION 1.00
;        mgs, 21 Sep 1998: - changed gamap.cmn to gamap_cmn.pro
;
;-
; Copyright (C) 1998, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine ctm_getdefaultstructures"
;-------------------------------------------------------------


pro ctm_getdefaultstructures,FileInfo,DataInfo,result=result
 
; include global common block
@gamap_cmn.pro
 
    ; If no FileInfo or DataInfo structures are passed,
    ; return the global structures
 
    if (n_elements(FileInfo) eq 0) then begin
       if ( ptr_Valid(pGlobalFileInfo) ) then $
          FileInfo = *pGlobalFileInfo  
    endif
 
    if (n_elements(DataInfo) eq 0) then begin
       if ( ptr_Valid(pGlobalDataInfo) ) then $
          DataInfo = *pGlobalDataInfo 
    endif
 
    ; return 1, if both structures contain something
    result = (n_elements(FileInfo) gt 0 AND n_elements(DataInfo) gt 0)
 
    return
end
 
 
 
