; $Id: ctm_read_multitracer.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_READ_MULTITRACER
;
; PURPOSE:
;        Read all entries of a 'multitracer' diagnostic (i.e.
;        source type diagnostic) and return a 3D data block.
;        The associated datainfo structure must be created before 
;        and passed into this routine. This routien is meant for
;        internal use in the CTM_GET_DATA routines.
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        CTM_READ_MULTITRACER,data,datainfo, $
;                   Use_DataInfo=Use_DataInfo,  $
;                   Use_FileInfo=Use_FileInfo,  $
;                   result=result,debug=debug
;
; INPUTS:
;        DATAINFO -> The datainfo structure that is to hold the new
;             3D data block. 
;
; KEYWORD PARAMETERS:
;        USE_DATAINFO, USE_FILEINFO -> The array of Datainfo and Fileinfo
;             stuctures to select from. Unlike the higher level routines,
;             CTM_READ_MULTILEVEL does not provide default values for
;             these!
;
;        RESULT -> A named variable that will be 1 if successful, 
;             0 otherwise.
;
; OUTPUTS:
;        DATA -> The 3D data block composed of the individual levels
;             from the ASCII punch file.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses CTM_DOSELECT_DATA, CTM_READ_DATA
;
; NOTES:
;        The dimensional information of the DATAINFO parameter is
;        adapted to the number of levels actually read from disk.
;
; EXAMPLE:
;        See source code of CTM_***
;
; MODIFICATION HISTORY:
;        mgs, 19 Aug 1998: VERSION 1.00
;        mgs, 26 Oct 1998: made more error tolerant:
;             - if file ends within record, now returns what's there
;             - if no dimensions were read, assumes 72x46 and prints warning
;        mgs, 10 Nov 1998: VERSION 3.00
;             - major design change
;        mgs, 28 Nov 1998: 
;             - hopefully fixed scaling bug now
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
; with subject "IDL routine ctm_read_multitracer"
;-------------------------------------------------------------


pro ctm_read_multitracer,data,datainfo, $
                    Use_DataInfo=Use_DataInfo,  $
                    Use_FileInfo=Use_FileInfo,  $
                    result=result,debug=debug
 
 

    FORWARD_FUNCTION ctm_doselect_data

 
    result = 0
    debug = keyword_set(debug)

    if (n_elements(Use_DataInfo) eq 0) then return
    if (n_elements(Use_FileInfo) eq 0) then return
 
    ; ------------------------------------------------------------ 
    ; Get indices of all data records to be read
    ; all_tracer will contain a list of tracers that constitute the
    ; diagnostics
    ; ------------------------------------------------------------ 
 
    testindex = ctm_doselect_data(DataInfo.category,  $
                                  use_datainfo,  $
                                  ilun=DataInfo.ilun, $
                                  tracer=all_tracer,  $
                                  tau=DataInfo.tau0,  $
                                  count=count)


    ; ------------------------------------------------------------ 
    ; eliminate record index to compound structure (tracer = offset)
    ; ------------------------------------------------------------ 

    ctm_diaginfo,DataInfo.category,offset=offset
    
    ind = where(use_datainfo[testindex].tracer ne offset)
    if (ind[0] lt 0) then return
    testindex = testindex[ind]
    count = n_elements(testindex)
   
    ; ------------------------------------------------------------ 
    ; count now contains number of levels to read
    ; ------------------------------------------------------------ 
 
    if (count eq 0) then begin
        message,'## Nothing to read!',/Continue
        return
    endif
 
 
    ; ------------------------------------------------------------ 
    ; prepare resulting data array and dimensional information
    ; for CTM_READ_DATA
    ; Use dimensional information from first record found
    ; ------------------------------------------------------------ 
 
    tmp = use_datainfo[testindex[0]]
 
    ; extract I and J dimensions
    dimI = tmp.dim[0]
    dimJ = tmp.dim[1]
 
    ; Make sure they are both greater than 1
    if (dimI lt 2 OR dimJ lt 2) then begin
       message,'WARNING: Error in datainfo structure!',/Cont
       message,'Level data has no dimensions! - will try 72x46 ...',  $
               /Cont,/NoName
       dimI = 72
       dimJ = 46
       use_datainfo[testindex].dim[0] = dimI
       use_datainfo[testindex].dim[1] = dimJ
    endif

    ; create array to store result 
    data = make_array(dimI,dimJ,count,/FLOAT)

    ; reset counter
    count = 0
 
    ; loop through testindex and read them all
if (DEBUG) then message,'## reading multitracer data ...',/INFO
    for l=0,n_elements(testindex)-1 do begin
       ctm_read_data,newdata,use_datainfo[testindex[l]],result=result

       if (result) then begin
           data[*,*,l] = newdata
           count = count + 1
       endif else $
           goto,break_loop

if (DEBUG) then print,'## INDEX (Tracer) : ',  $
                      strtrim(use_datainfo[testindex[l]].tracer,2),  $
                      ' MIN,MAX : ',min(newdata),max(newdata)
    endfor
 
 
break_loop: 
    ; ------------------------------------------------------------ 
    ; Return data and adjust dimensions in datainfo record
    ; ------------------------------------------------------------ 

    if (count eq 0) then return     ; nothing was read

    message,/reset                  ; reset error status
    result = 1

    DataInfo.dim[0] = dimI
    DataInfo.dim[1] = dimJ
    DataInfo.dim[2] = count         ; adjust dimensional information
    if (DataInfo.scale ne 1.0) then begin
       data = data * DataInfo.scale
       if (DEBUG) then message,'## scaling factor '+strtrim(DataInfo.scale,2)+' applied.',/INFO
       DataInfo.scale = 1.0            ; ### *** RESET SCALE FACTOR TO 1 !!
    endif

 
    return
end
 
