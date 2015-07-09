; $Id: ctm_read_multilevel.pro,v 1.2 2004/01/29 19:33:38 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_MULTILEVEL
;
; PURPOSE:
;        Read all levels of a multilevel diagnostic (e.g. IJ-AVG-$)
;        and return a 3D data block. The associated datainfo structure
;        must be created before and passed into this routine.
;        This is an internal procedure which should not be used
;        directly.
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        CTM_READ_MULTILEVEL,data,datainfo, $
;                   Use_DataInfo=Use_DataInfo, $
;                   Use_FileInfo=Use_FileInfo, $
;                   result=result
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
;        External Subroutines Required:
;        ===========================================
;        EXPAND_CATEGORY     CTM_DIAGINFO
;        CTM_DOSELECT_DATA   CTM_READ_DATA
;
; REQUIREMENTS:
;        Requires routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        The dimensional information of the DATAINFO parameter is 
;        adapted to the number of levels actually read from disk.
;
; EXAMPLE:
;        See source code of CTM_RETRIEVE_DATA
;
; MODIFICATION HISTORY:
;        mgs, 19 Aug 1998: VERSION 1.00
;        mgs, 26 Oct 1998: - made more error tolerant: 
;                            = if file ends within record, now returns 
;                              what's there
;                            = if no dimensions were read, 
;                              assumes 72x46 and prints warning
;                            = added status keyword
;        mgs, 10 Nov 1998: VERSION 3.00
;                          - major design change
;        mgs, 28 Nov 1998: - hopefully fixed scaling bug now
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - Now get diagnostic spacing from CTM_DIAGINFO
;
;-
; Copyright (C) 1998, 2003,
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine ctm_read_multilevel"
;-----------------------------------------------------------------------


pro ctm_read_multilevel,data,datainfo,  $
          Use_DataInfo=Use_DataInfo,  $
          Use_FileInfo=Use_FileInfo,  $
          result=result,debug=debug
 

    FORWARD_FUNCTION expand_category,ctm_doselect_data

 
    result = 0
    debug = keyword_set(debug)

    if (n_elements(Use_FileInfo) eq 0) then return
    if (n_elements(Use_DataInfo) eq 0) then return

    ; Get diagnostic spacing (same for all values)
    CTM_DiagInfo, DataInfo[0].Category, Spacing=Spacing
    Spacing = Spacing[0]
 
    ; ------------------------------------------------------------ 
    ; Expand category name to get all levels
    ; ("original" category with wildcard not returned)
    ; ------------------------------------------------------------ 
 
    xcategory = expand_category(DataInfo.category)
 

    ; ------------------------------------------------------------ 
    ; Get indices of all data records to be read
    ; ------------------------------------------------------------ 

    ctracer = DataInfo.tracer
    ;-------------------------------------------------------------------------
    ; Prior to 11/19/03:
    ; Now use SPACING instead of 100 (bmy, 11/19/03)
    ;if (ctracer ge 100) then ctracer = [ ctracer, ctracer mod 100 ]
    ;-------------------------------------------------------------------------
    if ( CTracer ge Spacing ) $
       then CTracer = [ CTracer, CTracer mod Spacing ]

    testindex = ctm_doselect_data(xcategory,use_datainfo,  $
                                  ilun=DataInfo.ilun, $
                                  tracer=ctracer, $
                                  tau=DataInfo.tau0,$
                                  count=count, $
                                  Spacing=Spacing )
 
   
    ; ------------------------------------------------------------ 
    ; count now contains number of levels to read
    ; ------------------------------------------------------------ 
 
    if (count eq 0) then begin
        message,'## Nothing to read! -- Tracer=' +  $
                string(tracer,format='(I5)'), $ 
                /Continue
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
; print,'#### DIMI, DIMJ = ',dimI,dimJ
 
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
if (DEBUG) then message,'## reading multilevel data ...',/INFO
    for l=0,n_elements(testindex)-1 do begin
       ctm_read_data,newdata,use_datainfo[testindex[l]],result=result

       if (result) then begin
           data[*,*,l] = newdata
           count = count + 1
       endif else $
           goto,break_loop


if (DEBUG) then print,'## LEVEL : ',strtrim(l,2),  $
                      ' MIN,MAX : ',min(newdata),max(newdata)
 
    endfor
 
break_loop: 
    ; ------------------------------------------------------------ 
    ; Return data and adjust dimensions in data record
    ; ------------------------------------------------------------ 

    if (count eq 0) then return     ; nothing was read 

    message,/reset                  ; reset error status
    result = 1

    DataInfo.dim[0] = dimI
    DataInfo.dim[1] = dimJ
    DataInfo.dim[2] = count         ; adjust dimensional information

    if (DataInfo.scale ne 1.0) then begin
       data = data * DataInfo.scale
       if (DEBUG) then message,'## scaling factor '+  $
                                strtrim(DataInfo.scale,2)+' applied.',/INFO
       DataInfo.scale = 1.0            ; ### *** RESET SCALE FACTOR TO 1 !!
    endif
   
 
    return
end
 
