; $Id: ctm_doselect_data.pro,v 1.3 2005/03/24 18:03:10 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_DOSELECT_DATA (function)
;
; PURPOSE:
;        Return indices for data blocks that match specific
;        criteria. See CTM_GET_DATA for a user-friendly
;        interface to this function.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        index = CTM_DOSELECT_DATA(DIAGN,USE_DATAINFO,keywords)
;
; INPUTS:
;        CATEGORY -> A string or string array with category names
;            to search for. Multilevel categories can be expanded to
;            a string array with the EXPAND_CATEGORY function.
;            Usually, CTM_DOSELECT_DATA should be called with only
;            one "logical" category at the time, i.e. only for
;            multilevel diagnostics should it contain more than one
;            element. Otherwise, the tracer offset may be wrong.
;
;        USE_DATAINFO -> A valid DataInfo structure. No error checking 
;            is performed.
;
;        Both parameters are mandatory.
;
; KEYWORD PARAMETERS:
;        ILUN -> A logical unit value or an array of logical unit
;            values. Only records from corresponding files will be 
;            returned. If ILUN is an undefined variable, information
;            about all previously opened files will be returned,
;            and ILUN will contain all logical unit numbers that 
;            match the selection criteria.
;
;        TRACER -> A tracer number or an array of tracer numbers to
;            restrict the selection of data records. Default is to
;            return information about all tracers.
;            Tracer numbers less than 100 are automatically expanded
;            to include the offset of certain diagnostics (see
;            keyword TRCOFFSET and routine CTM_DIAGINFO). If TRACER is
;            an undefined variable, all tracers that match the selection 
;            criteria are returned.
;
;        TRCOFFSET -> A tracer offset (multiple of 100) that will be
;            added to TRACER. The search is performed for both,
;            TRACER and TRACER+TRCOFFSET. (for tracer offsets see
;            routine CTM_DIAGINFO and file diaginfo.dat)
; 
;        TAU -> A time value (tau0 !) or an array of time values
;            to restrict the selection of data records. Default is to
;            return information about all time steps. If TAU is an
;            undefined variable, it will return all time steps that
;            match the selection criteria.
;
;        STATUS -> Restricts the data selection to
;            Data that has not been read  (STATUS = 0)
;            Data that has been read      (STATUS = 1)
;            All data blocks              (STATUS = 2, default)
;            If STATUS is 1, all pointers returned in DATA are tested
;            for validity. Status will automatically be restricted 
;            to range 0..1
;
;        COUNT -> A named variable that will return the number of
;            data blocks found with the given selection criteria
;
;        MISSING -> If no records were found that match the selection 
;            criteria, MISSING will return a string array with the 
;            items that could not be matched (e.g. ['TRACER','ILUN']).
;            If records were found, MISSING returns an empty string.
;
;        SPACING -> Passes to CTM_DOSELECT_DATA the spacing between
;            diagnostic offsets listed in "diaginfo.dat".  
;
; OUTPUTS:
;        The function returns an (long) integer array that contains
;        index values to all the data blocks that match the selection
;        criteria. If no data is found, -1L is returned.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses Is_Selected function
;
; NOTES:
;
; EXAMPLE:
;        See CTM_SELECT_DATA and CTM_READ_DATA source codes.
;
; MODIFICATION HISTORY:
;        mgs, 19 Aug 1998: VERSION 1.00
;        mgs, 07 Oct 1998: - added DEBUG keyword
;        mgs, 22 Oct 1998: - now filters ilun, tracer, and tau
;                            after finding matching records. This
;                            was necessary to find the correct first
;                            or last time step in CTM_GET_DATA.
;                            Needs some more testing whether there are
;                            side effects when TAU0 and ILUN or TRACER
;                            are specified.
;        mgs, 09 Nov 1998: - improved documentation
;                          - default status now 2
;                          - uses status field in use_datainfo instead of
;                            ptr_valid function
;                          - ILUN, TRACER and TAU only overwritten
;                            if they are undefined variables
;                          - added MISSING keyword
;        mgs, 10 Nov 1998: - minor bug fix for status=1
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - added SPACING keyword to pass the
;                            diagnostic spacing from CTM_DIAGINFO
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
; with subject "IDL routine ctm_doselect_data"
;-------------------------------------------------------------


function ctm_doselect_data,category,Use_DataInfo,   $
              ilun=sel_ilun,tracer=sel_tracer,trcoffset=trcoffset, $
              tau=sel_tau,status=status,  $
              count=count,missing=missing,debug=debug, Spacing=Spacing
 
    FORWARD_FUNCTION Is_selected
 
    ; ============================================================ 
    ; set defaults
    ; ============================================================ 
 
    data = -1 
    count = 0
    missing = 'unspecified'
    debug = keyword_set(debug)
 
    ; ------------------------------------------------------------ 
    ; error checking
    ; ------------------------------------------------------------ 
 
    if (n_params() lt 2) then begin
       message,'2 parameters required: CATEGORY, USE_DATAINFO',/Cont
       return,-1L
    endif
 
 
    ; ------------------------------------------------------------ 
    ; Continue with defaults
    ; ------------------------------------------------------------ 
 
    ; all files that have been opened
    if (n_elements(sel_ilun) eq 0) then begin
        ilun = Use_DataInfo.ilun
        ilun = ilun( uniq(ilun,sort(ilun)) )
    endif else $
        ilun = sel_ilun

    ; all tracers 
    if (n_elements(sel_tracer) eq 0) then begin 
       tracer = Use_datainfo.tracer
       tracer = tracer( uniq(tracer,sort(tracer)) )
    endif else $
       tracer = sel_tracer

    ; no offset in tracernumbers
    if (n_elements(trcoffset) eq 0) then trcoffset = 0

    ; all possible timesteps
    if (n_elements(sel_tau) eq 0) then begin
       tau = Use_datainfo.tau0
       tau = tau( uniq(tau,sort(tau)) )
    endif else $
       tau = sel_tau
 
    ; data that has or has not been read
    if (n_elements(status) eq 0) then status = 2
    status = ( status > 0 ) < 2
 
 
    ; ============================================================ 
    ; Expand tracer numbers to account for offset if necessary
    ; ============================================================

    Ind = Where( Tracer gt 0 AND Tracer lt Spacing )
    ;-------------------------------------------------------------
    ; Prior to 11/19/03:
    ;ind = where(tracer lt 100 AND tracer gt 0)
    ;### ind = where(tracer lt 100 AND tracer ge 0)
    ;-------------------------------------------------------------
    if (ind[0] ge 0 AND trcoffset gt 0) then $
        tracer =[  tracer, tracer[ind]+trcoffset ]

    if (DEBUG) then begin 
        print,'----------------'
        print,'CATEGORY:',category
        print,'TRACER  :',tracer
        print,'TAU     :',tau
        print,'ILUN    :',ilun
        print,'STATUS  :',status
        print,'----------------'
    endif

 
 
    ; ============================================================ 
    ; Compute individual selections and combine them
    ; ============================================================ 
 
 
    bsel1 = Is_Selected( Use_DataInfo.category, category )
    bsel2 = Is_Selected( Use_DataInfo.ilun, ilun )
    bsel3 = Is_Selected( Use_DataInfo.tracer, tracer )
    bsel4 = Is_Selected( Use_DataInfo.tau0, tau )

    case (status) of
 
    ; only records that have not been read
       0 : bsel5 = (Use_DataInfo.status eq 0)
 
    ; only records that have been read
    ; - for safety reasons include test for pointer validity here
    ;   this may become obsolete after rigorous testing
       1 : begin
           bsel5 = (Use_DataInfo.status eq 1)
           errind = where(bsel5 gt 0 AND not ptr_valid(Use_DataInfo.data) )
           if (errind[0] ge 0) then begin
              if (errind[0] ge 0) then $
                 for erri = 0,n_elements(errind)-1 do $
                     message,'STATUS=1, but data pointer invalid: ' + $
                             string(Use_DataInfo[errind[erri]].ilun, $
                                    Use_DataInfo[errind[erri]].category, $
                                    Use_DataInfo[errind[erri]].tracer, $
                                    Use_DataInfo[errind[erri]].tau0, $
                                    format='(I4,A14,I5,I8)'), $
                             /Continue
           endif
           end
 
    ; all records (default)
       2 : bsel5 = intarr(n_elements(Use_DataInfo)) + 1
 
    endcase

if (DEBUG GT 1) then begin
print,'---------------------'
print,category
print,'BSEL1:' & i=where(bsel1) 
if (n_elements(i) lt n_elements(Use_datainfo)) then print,i else print,'ALL' 
print,'BSEL2:' & i=where(bsel2) 
if (n_elements(i) lt n_elements(Use_datainfo)) then print,i else print,'ALL' 
if (i[0] ge 0) then print,Use_datainfo[i].tracer
print,'BSEL3:' & i=where(bsel3) 
if (n_elements(i) lt n_elements(Use_datainfo)) then print,i else print,'ALL' 
print,'BSEL4:' & i=where(bsel4) 
if (n_elements(i) lt n_elements(Use_datainfo)) then print,i else print,'ALL' 
print,'BSEL5:' & i=where(bsel5) 
if (n_elements(i) lt n_elements(Use_datainfo)) then print,i else print,'ALL' 
print,'---------------------'
endif

    ; compute selection index
    selind = where ( bsel1 AND bsel2 AND bsel3 AND bsel4 AND bsel5 )

    ; get items that did not work out
    missing = 'combination of ILUN, TRACER, TAU0, STATUS'
    if (max(bsel1) eq 0) then missing = [ missing, 'CATEGORY' ] $
    else begin
       if (max(bsel1 AND bsel2) eq 0) then missing = [ missing, 'ILUN' ] 
       if (max(bsel1 AND bsel3) eq 0) then missing = [ missing, 'TRACER' ] 
       if (max(bsel1 AND bsel4) eq 0) then missing = [ missing, 'TAU0' ] 
       if (max(bsel1 AND bsel5) eq 0) then missing = [ missing, 'STATUS' ] 
    endelse
    if (n_elements(missing) gt 1) then missing = missing[1:*]

    if (selind[0] lt 0) then return,-1L
 
    ; return number of data blocks found 
    count = n_elements(selind)


    ; ----------------------------------------------------------
    ; return ilun, tracer, tau values that match selection
    ; ----------------------------------------------------------
    isel = where( Is_Selected( ilun, Use_DataInfo[selind].ilun ) )
    if (isel[0] lt 0) then begin
        message,'*** SERIOUS ERROR: No matching logical unit number!'
        ilun = -1
    endif else $
        if (n_elements(sel_ilun) eq 0) then sel_ilun = ilun[isel]

    isel = where( Is_Selected( tracer, Use_DataInfo[selind].tracer ) )
    if (isel[0] lt 0) then begin
        message,'*** SERIOUS ERROR: No matching tracer!'
        tracer = -1
    endif else $
        if (n_elements(sel_tracer) eq 0) then sel_tracer = tracer[isel]

    isel = where( Is_Selected( tau, Use_DataInfo[selind].tau0 ) )
    if (isel[0] lt 0) then begin
        message,'*** SERIOUS ERROR: No matching time step!'
        tau = -1L
    endif else $
        if (n_elements(sel_tau) eq 0) then sel_tau = tau[isel]

    ; return index of selected data blocks
    return,selind
 
end

