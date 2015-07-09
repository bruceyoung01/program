; $Id: ctm_select_data.pro,v 1.1.1.1 2007/07/17 20:41:46 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_SELECT_DATA (function)
;
; PURPOSE:
;        Provide a user-friendly function to extract data
;        from a DATAINFO structure. The function returns an 
;        index to the given DATAINFO structure which points
;        to all recored that fulfill the specified conditions.
;
; CATEGORY:
;        GAMAP Internals, GAMAP Data Manipulation
;
; CALLING SEQUENCE:
;        index = CTM_SELECT_DATA(DIAGN[,DATAINFO,keywords])
;
; INPUTS:
;        DIAGN -> A diagnostic number or category name. Only one
;            diagnostic can be extracted at the same time. Complete
;            information about the requested diagnostic is returned 
;            via the DIAGSTRU keyword. (see also CTM_DIAGINFO)
;
;        DATAINFO -> An [optional] subset of the global DataInfo
;            structure. As default, CTM_SELECT_DATA operates on
;            the global DATAINFO structure (see gamap_cmn.pro) scanning
;            all files that have been opened.
;
; KEYWORD PARAMETERS:
;        ILUN -> A logical unit value or an array of logical unit
;            values. Only recored from these files will be returned.
;            Default is to use all files.
;            A link between logical unit numbers and filenames can be
;            made through the (global) FileInfo structure (see gamap_cmn.pro)
;
;        TRACER -> A tracer number or an array of tracer numbers to
;            restrict the selection of data records. Default is to
;            return information about all tracers. 
;            Tracer numbers less than 100 are automatically expanded
;            to include the offset of certain diagnostics (see
;            CTM_DIAGINFO and CTM_DOSELECT_DATA).
;
;        TAU -> A time value (tau0 !) or an array of time values
;            to restrict the selection of data records. Default is to
;            return information about all time steps. (see also example)
;
;        LEVELRANGE -> A 1 or 2 element vector with a level index or 
;            a range of level indices for multilevel diagnostics
;            (e.g. 'IJ-AVG$'). As default, information is returned
;            about full 3D data blocks only. See also 
;            EXPAND keyword.
;
;        /EXPAND -> If set, multilevel diagnostic fields are
;            expanded to return the individual layers in addition to
;            the complete 3D cube.
;        
;        DATA -> A named variable that will contain an array with
;            pointers to the indexed data blocks. Note that some may
;            be NIL pointers if the STATUS value is 0 or 2.
;
;        COUNT -> A named variable that will return the number of
;            data blocks found with the given selection criteria
; 
;        DIAGSTRU -> A named variable that will contain complete 
;            information about the requested diagnostics (see
;            CTM_DIAGINFO)
;
;        STATUS -> Restricts the data selection to
;            Data that has not been read  (STATUS = 0)
;            Data that has been read      (STATUS = 1, default)
;            All data blocks              (STATUS = 2)
;            If STATUS is 1, all pointers returned in DATA are valid.
;
; OUTPUTS:
;        The function returns an (long) integer array that contains
;        index values to all the data blocks that match the selection 
;        criteria. If no data is found, -1 is returned.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses CTM_DOSELECT_DATA, EXPAND_CATEGORY, gamap_cmn.pro,
;             GAMAP_INIT, CTM_DIAGINFO
;
; NOTES:
;        This function acts for the most part as a convenient user
;        interface to CTM_DOSELECT_DATA which performs the actual
;        selection process and contains only minimal error checking.
;        For programming purposes, use CTM_DOSELECT_DATA when possible.
;
; EXAMPLE:
;        ; open a CTM punch file
;        CTM_OPEN_FILE
;
;        ; Read diagnostic number 45 for all tracers and time steps
;        CTM_READ_DATA,45
;
;        ; Select data for tracer 1 and diagnostics 45 
;        index = CTM_SELECT_DATA(45,tracer=1,data=pdata)
;
;        ; De-reference the data pointer for the first record
;        ; (usually the first timestep)
;        if (index[0] ge 0) then data = (*pdata)[0] 
;
;        ; find data for a specific time range
;        DataInfo = (*pGlobalDataInfo)[index]
;        taus = where(DataInfo.tau0 ge 77666L AND DataInfo.tau1 le 78888L)
;        taus = DataInfo.tau0[taus]
;        index = CTM_SELECT_DATA(45,DataInfo,tracer=1,tau=taus,data=pdata)
;        
;
; MODIFICATION HISTORY:
;        mgs, 19 Aug 1998: VERSION 1.00
;        mgs, 21 Sep 1998: - changed gamap.cmn to gamap_cmn.pro
;        mgs, 07 Oct 1998: - removed obsolete FILEINFO parameter
;                          - changed NO_EXPAND to EXPAND
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - Now get spacing between diagnostic offsets
;                            from CTM_DIAGINFO and pass to CTM_DOSELECT_DATA
;                          - Now use the /NO_DELETE keyword in the
;                            call to routine EXPAND_CATEGORY
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine ctm_select_data"
;-----------------------------------------------------------------------


function ctm_select_data,diagn,DataInfo,   $
              ilun=ilun,tracer=tracer,tau=tau,  $
              levelrange=levelrange,no_expand=no_expand, $
              data=data,count=count,diagstru=diagstru,  $
              status=status
 
 
    FORWARD_FUNCTION ctm_doselect_data, expand_category
 
 
; include global common block (to access global FileInfo and DataInfo)
@gamap_cmn.pro
 
    ; ============================================================ 
    ; set defaults
    ; ============================================================ 
 
    data = -1 
    count = 0
 
    ; ------------------------------------------------------------ 
    ; Information about diagnostic (returns structure)
    ; ------------------------------------------------------------ 
 
    CTM_DiagInfo, DiagN, DiagStru

    ; Spacing between diagnostic offsets (same for all categories)
    Spacing = DiagStru[0].Spacing
 
    ; ------------------------------------------------------------ 
    ; error checking
    ; ------------------------------------------------------------ 
 
    if (n_params() lt 1) then begin
       message,'Diagnostic parameter required!',/Cont
       return,-1L
    endif
 
    if (n_elements(DataInfo) eq 0) then begin
       ; use global information
       if ( ptr_valid(pGlobalDataInfo) ) then $
           DataInfo = *pGlobalDataInfo  $
       else begin
          message,'No valid DataInfo found!',/Cont
          message,'Use CTM_GET_DATA or CTM_OPEN_FILE first.',/Cont,/NoName
          return,-1L
       endelse
    endif
 
    if (not chkstru(datainfo,'CATEGORY') ) then begin
       message,'Invalid datainfo structure!',/Cont
       return,-1L
    endif
 
 
    ; ============================================================ 
    ; Extract category and expand it for multilevel diagnostics
    ; Keep original with wildcard as well
    ; ============================================================ 
 
    ;-----------------------------------------------------------------------
    ; Prior to 11/19/03:
    ; This same thing is achieved w/ the /NO_DELETE keyword (bmy, 11/19/03)
    ;xcategory = diagstru.category
    ;if (keyword_set(EXPAND)) then $
    ;   xcategory = [ xcategory,  $
    ;                 expand_category( xcategory, range=levelrange ) ]
    ;----------------------------------------------------------------------
    XCategory = Expand_Category( DiagStru.Category, $
                                 Range=LevelRange,  $
                                 No_Delete=Expand )

    ; make local copy of tracer selection
    if ( N_Elements( Tracer ) eq 0 )           $
       then xtracer = Lindgen( Spacing-1L )+1L $
       else xtracer = tracer
 
    ; ============================================================ 
    ; Compute selection index.
    ; Defaults are handled in CTM_DOSELECT_DATA as follows:
    ; - ilun : all files that have been opened (i.e. all iluns in 
    ;          DataInfo)
    ; - tracer : all tracers in DataInfo.tracer
    ; - tau : all time steps in DataInfo.tau0
    ; - status : retrieve only data that has been read (status 1)
    ; ============================================================ 
 
if (DEBUG) then help,xcategory,ilun,xtracer,diagstru.offset,tau,status
    selind = ctm_doselect_data( xcategory, DataInfo,       $
                                ilun=ilun,                 $
                                tracer=xtracer,            $
                                trcoffset=diagstru.offset, $
                                tau=tau,                   $
                                count=count,               $
                                status=status,             $
                                debug=debug,               $
                                Spacing=Spacing )
 
 
    ; ============================================================ 
    ; Analyze result and return information  
    ; ============================================================ 
    
if (DEBUG) then print,'## ',count,' data blocks selected.'
    if (count eq 0) then return,-1L
 
    ; return pointer array to selected data blocks
    data = DataInfo[selind].data
 
    ; return index of selected data blocks
    return,selind
 
end
