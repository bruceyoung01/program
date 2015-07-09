; $Id: ctm_retrieve_data.pro,v 1.2 2004/01/29 19:33:38 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_RETRIEVE_DATA
;
; PURPOSE:
;        Read one "compound" data block from disk. The datainfo
;        parameter must contain only one entry, and it must have
;        status=0. The data pointer is assumed to be NULL.
;        If requested data block is a multilevel or multitracer 
;        diagnostics, the routine will search all individual data 
;        records that belong to that block and loop over them
;        (this is actually done in ctm_read_multilevel and 
;        ctm_read_multitracer).
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_RETRIEVE_DATA,DataInfo,DiagStru,  $
;                  Use_DataInfo=Use_DataInfo,  $
;                  Use_FileInfo=Use_FileInfo,  $
;                  result=result
;
; INPUTS:
;        DataInfo -> DataInfo structure that is to hold the data.
;            Normally, this is either created in CTM_GET_DATA for
;            multilevel or multitracer diagnostics, or it is created
;            upon parsing the header information (ctm_read3d?_header).
;
;        DIAGSTRU -> A (single) diagnostic structure containing
;            information what to load (see CTM_DIAGINFO)
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
;        The DATAINFO structure will contain the correct dimensional
;        information, the status will be set to 1, and the data pointer
;        points to a 2D or 3D data array. (if reading was successful)
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses CTM_DOSELECT_DATA, CTM_READ_MULTILEVEL, 
;             CTM_READ_MULTITRACER, CTM_READ_DATA,
;             gamap_cmn.pro
;
; NOTES:
;        This routine is meant for internal use from CTM_GET_DATA.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 19 Aug 1998: VERSION 1.00
;        mgs, 21 Sep 1998: - changed gamap.cmn to gamap_cmn.pro
;        mgs, 22 Oct 1998: - scale factor set to 1 after unit scaling
;                            is applied for multi...
;                          - tracername and unit setting now also done
;                            for non-multi fields
;        mgs, 26 Oct 1998: - added status keyword. If used (0,1,or 2)
;                            no data will be read but datainfo record 
;                            will be prepared as usual.
;        mgs, 04 Nov 1998: - bug fix for reading of 2D arrays. Now return
;                            correct (offset) tracer number
;        mgs, 10 Nov 1998: VERSION 3.00
;                          - major design change 
;        mgs, 28 Nov 1998: - hopefully fixed scaling bug now!
;        bmy, 07 Apr 2000: - now can read DAO met field files
;        bmy, 21 Nov 2003: GAMAP VERSION 2.01
;                          - Removed GMAO keyword in call to
;                            CTM_READ_DATA
;
;-
; Copyright (C) 1998, 2000, 2003, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_retrieve_data"
;-------------------------------------------------------------


pro ctm_retrieve_data,DataInfo,DiagStru,  $
           Use_DataInfo=Use_DataInfo,Use_FileInfo=Use_FileInfo, $
           result=result
 
 
    FORWARD_FUNCTION ctm_doselect_data
  
; include global common block : we need to update it!
@gamap_cmn.pro 

    result = 0

    ; ---------------------------------------------------------------- 
    ; Minimal error checking: all parameters provided ?
    ; Test for availability of global File and Data Info
    ; ---------------------------------------------------------------- 
    if (n_params() ne 2) then begin
       message,'Wrong number of parameters!',/Cont
       return
    endif

    if (not ptr_valid(pGlobalFileInfo)) then begin
       message,'*** SERIOUS ERROR: Global FILEINFO not valid! ***', $
               /Continue
       return
    endif

    if (not ptr_valid(pGlobalDataInfo)) then begin
       message,'*** SERIOUS ERROR: Global DATAINFO not valid! ***', $
               /Continue
       return
    endif


    if (n_elements(Use_FileInfo) eq 0) then $
        Use_FileInfo = *pGlobalFileInfo

    if (n_elements(Use_DataInfo) eq 0) then $
        Use_DataInfo = *pGlobalDataInfo

    ; Match up fileinfo with datainfo (bmy, 4/7/00)
    Ind = Where( Use_FileInfo.Ilun eq DataInfo.Ilun )
    if ( Ind[0] ge 0 ) then begin
       FileInfo = Use_FileInfo[Ind]
    endif else begin
       Message, 'Cannot match FILEINFO and DATAINFO!', /Continue
       return
    endelse

    ; ================================================================ 
    ; Test for multilevel diagnostics that is stored as 2D fields
    ; (ASCII punch files)
    ; ================================================================ 

    if (strpos(diagstru.category,'$') ge 0  $
        AND DataInfo.filepos le 0L) then begin

; #### debug
; print,'### CTM_RETRIEVE_DATA: read_multilevel will be called now!'
; print,'diagstru.category=',diagstru.category
;;  print,'DataInfo=',DataInfo

        ctm_read_multilevel,newdata,DataInfo, $
                Use_DataInfo=Use_DataInfo,  $
                Use_FileInfo=Use_FileInfo,  $
                result=result,debug=debug

        goto,Insert_Data

    endif


    ; ================================================================ 
    ; Test for multitracer diagnostics
    ; ================================================================ 

    if (diagstru.maxtracer gt 1  $
        AND DataInfo.filepos le 0L) then begin

        ctm_read_multitracer,newdata,DataInfo, $
                Use_DataInfo=Use_DataInfo,  $
                Use_FileInfo=Use_FileInfo,  $
                result=result,debug=debug

        goto,Insert_Data
    endif


    ; ================================================================ 
    ; If we arrive here, the DataInfo record must be straightforward
    ; to read (with CTM_READ_DATA). If you want to add additional
    ; complications, do it right here!!
    ; In order to be "straightforward", DataInfo must contain a
    ; valid filepos, and it should carry valid dimensional information
    ; ================================================================ 

    CTM_Read_Data, NewData, DataInfo, Result=Result


    ; ================================================================ 
    ; Arrival point for all category types. Now the data block has
    ; been read into newdata (provided result=1) and we need to hook
    ; it to the DataInfo record and also update the global copy of it.
    ; ================================================================ 
Insert_Data:

    DataInfo.scale = 1.0   ; scaling factor has been applied !!

    if (DEBUG) then begin
        message,'Data records read from file. Result='+strtrim(result,2), $
                /INFO
        help,newdata
    endif


    if (not result) then begin
       message,'ERROR: Could not read data block!',/Continue
       return
    endif


    ; just for safety, test if newdata has more than 1 element(s)
    if (n_elements(newdata) lt 2) then  $
       message,'*** SERIOUS ERROR: newdata empty !'



    DataInfo.data = ptr_new(newdata,/NO_COPY)
    DataInfo.status = 1

    ; now update global copy 
    ; Added SPACING keyword (bmy, 11/19/03)
    index = ctm_doselect_data( DataInfo.category,         $
                               *pGlobalDataInfo,          $
                               ilun=DataInfo.ilun,        $
                               tracer=DataInfo.tracer,    $
                               trcoffset=DiagStru.offset, $
                               tau=DataInfo.tau0,         $
                               Spacing=DiagStru[0].Spacing )

    if (index[0] ge 0) then begin
if (n_elements(index) gt 1) then message,'*** SERIOUS: More than 1 item found!'

       (*pGlobalDataInfo)[index[0]].dim = DataInfo.dim
       (*pGlobalDataInfo)[index[0]].data = DataInfo.data
       (*pGlobalDataInfo)[index[0]].status = DataInfo.status
       (*pGlobalDataInfo)[index[0]].scale = DataInfo.scale
; print,'#### RETRIEVE: DataInfo.Status=',DataInfo.Status
    endif else begin
; Comment out this annoying message (bmy, 12/6/99)
;message,'No matching global record found !' ,/INFO
    endelse


    return


end
 
