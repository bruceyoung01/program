; $Id: ctm_get_data.pro,v 1.3 2004/02/18 15:56:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_GET_DATA
;
; PURPOSE:
;        Retrieve specific data records from CTM output files.
;        Opening files, parsing header information, and loading
;        of data are handled transparently and can be 
;        controlled by various keywords. The routine returns a
;        subset of the global DATAINFO structure that matches the
;        requested category and (optional) tracer and time step(s).
;
;        This routine should be called *whenever* you want to 
;        access data and you are not sure that it has been 
;        loaded previously. It provides the general user-interface
;        for GAMAP (the Global Atmospheric Model output Analysis 
;        Package). 
;
;        For the future, a widget interface to this routine is 
;        planned.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_GET_DATA,DATAINFO [,DIAGN] [,keywords]
;
; INPUTS:
;        DIAGN -> A diagnostic number or category name (see
;             (CTM_DIAGINFO). A value of 0 (or an empty string)
;             prompts processing of all available diagnostics.
;             DIAGN can also be an array of diagnostic numbers or
;             category names.
;
; KEYWORD PARAMETERS:
;        FILENAME -> (optional) If FILENAME is a fully qualified file path
;             the specified file is opened without user interaction.
;             If filename is empty or contains wildchards (*,?), a
;             pickfile dialog will be displayed.
;             If FILENAME is a named variable it will contain the full
;             file path upon return so that a subsequent call to
;             CTM_GET_DATA with the same FILENAME argument will not prompt
;             another file selection dialog.
;                If the FILENAME keyword is present, CTM_GET_DATA
;             will restrict it's scope to records from the selected
;             is file (even if FILENAME contains an empty string, it will 
;             restrict the scope of the search!).
;                If the file is found in the global FILEINFO structure or
;             the USE_FILEINFO structure (i.e. it has been opened 
;             previously), then it will not be parsed again; instead the
;             data records are returned from memory.
;                The data itself is loaded transparently via 
;             CTM_RETRIEVE_DATA.
;
;        ILUN -> An optional value or array of logical unit numbers. If
;             given, the search is restricted to data from the specified
;             files. Default is to use all files (unless the FILENAME
;             keyword is present). If an undefined variable
;             is passed into ILUN, information about all accessible files
;             in the global FILEINFO structure (or USE_FILEINFO) is returned.
;
;        TRACER -> A tracer ID number or a list of those. If given, the
;             search is restricted to those tracers. Default is to use all 
;             tracers. If an undefined variable is passed into TRACER, 
;             and one specific diagnostics is requested with DIAGN,
;             information about all accessible tracers in the global
;             DATAINFO structure or USE_DATAINFO structure or the
;             DATAINFO structure associated with a specific file is returned.
;
;        TAU0 -> A time value or list of values to restrict the search.
;             Default handling as with ILUN or TRACER. TAU0 superseeds
;             /FIRST, /LAST or TAURANGE.
;
;        TAURANGE -> A 2-element vector containing the first and last tau0
;             value to look for. 
;
;        /FIRST, /LAST -> extract first or last time step that is stored for
;             the selected diagnostics, ilun, and tracer. Only one can be 
;             be active at a time. /LAST superseeds /FIRST.
;
;        INDEX -> A named variable that will contain the indices of the 
;             records in USE_DATAINFO that match the selection criteria.
;             You can test INDEX[0] ge 0 in order to see if CTM_GET_DATA has
;             been successful although it is now recommended to test for
;             n_elements(DATAINFO) eq 0. 
;                The INDEX keyword is useful if you want to change the
;             information contained in the selected DATAINFO structures
;             globally.
;
;        USE_FILEINFO -> (optional) If provided, CTM_GET_DATA will 
;             restrict its search to only the files that are
;             contained in USE_FILEINFO which must be a FILEINFO 
;             structure array. Default is to use the global information 
;             (see gamap_cmn.pro).
;             If an undefined named variable is provided in USE_FILEINFO,
;             it will either contain the global FILEINFO structure array 
;             or the FILEINFO record of the specified file.
;             USE_FILEINFO must contain entries for all logical unit numbers
;             that are used in USE_DATAINFO.
;
;        USE_DATAINFO -> (optional) Restrict search to records contained
;             in USE_DATAINFO which must be a DATAINFO structure array. 
;             If an undefined named variable is provided in USE_DATAINFO,
;             it will either contain the global DATAINFO structure array 
;             or all DATAINFO records of the specified file.
;             See also USE_FILEINFO.
;
;        /INTERNAL_USE -> Set this keyword if you want to prevent a call
;             to CTM_OPEN_FILE, but instead abort in case of undefined 
;             (global) FILEINFO or DATAINFO structures.
;
; OUTPUTS:
;        DATAINFO -> An array of DATAINFO records that match the selected 
;             criteria. You can then simply loop over 
;             0..n_elements(DATAINFO)-1 to access all data records and 
;             extract the data as *(DATAINFO[i].data).
;             DATAINFO will be undefined if no records are found!!
;             Always test for  IF (n_elements(DATAINFO) eq 0) ... !
;             NOTE: Alternatively you can return the INDEX to the selected
;             data records in the global (or USE_) datainfo structure array
;             with the INDEX keyword. This may in some cases eliminate the
;             need to make a local copy of the selected DATAINFO records. 
;
; SUBROUTINES:
;       pro reopen_all_files,fileinfo
;       (needed in order to get free unit numbers)
;
;       pro make_compound_datainfo,DataInfo,category,ilun,tracer,tau0,tau1
;       (make compound structure for multilevel or multitracer diagnostics)
;
;       pro update_tracer_datainfo,datainfo,traceroffset
;       (enter tracer information into global datainfo structure)
;
; REQUIREMENTS:
;       Several ctm_* routines are used
;       Also uses UNDEFINE (by D. Fanning)
;
; NOTES:
;       Please test rigorously. In case of read errors, try using CTM_OPEN_FILE
;       with the /PRINT keyword.
;
;       If your model output (ASCII punch file) does not contain the
;       dimensional information about each data block, it may cause problems
;       for diagnostics that do not contain 72x46 elements.
;       It's defintively a good idea to implement this little change *NOW* !
;
;       Outline of this procedure:
;       - get all data records that match selection criteria
;       - create "compound" datainfo structures for multilevel and
;         multitracer diagnostics (those hold 3D data blocks)
;       - read data for all selected compound structures unless only
;         status information requested
;
; EXAMPLE:
;       See CTM_EXAMPLES
;       
;
; MODIFICATION HISTORY:
;        mgs, 20 Aug 1998: VERSION 1.00
;        mgs, 21 Sep 1998: - changed gamap.cmn to gamap_cmn.pro
;        mgs, 22 Sep 1998: - changed to accomodate usage of 
;                            tracer information
;        mgs, 22 Oct 1998: - old FILEINFO and DATAINFO parameters now
;                            keywords USE_..., new DATAINFO parameter
;                            returns selected subset of records.
;                          - print statements replaced with message
;                          - DEBUG messages improved
;                          - catch cancelled file open dialog
;        mgs, 26 Oct 1998: - datainfo now undefined at start
;                          - allows for multiple categories
;                          - ilun, tracer, tau0 keyword variables renamed
;                            as sel_... in order to preserve them
;        mgs, 04 Nov 1998: - sel_tracer now expanded to include offsets
;        mgs, 10 Nov 1998: VERSION 3.0 
;                          - major update! Program structure much more
;                            straightforward!
;        mgs, 12 Nov 1998: - bug fixes for simple diagnostics (line 732)
;                            and finding offset tracers (in update_...)
;                            replaced tracer by (tracer mod 100) in 3 places
;        mgs, 19 Nov 1998: - bug fix with scale factor. Didn't get globally
;                            updated because it was linked to unit. Need a
;                            more generic global update procedure !
;        mgs, 03 Dec 1998: - yet another bug fix in reopen files: needed
;                            to test for negative ilun before fstat
;        bmy, 21 Jan 1999: - added outer parentheses to the FORMAT
;                            descriptor (255(I4,1x)) to avoid errors
;        mgs, 17 Feb 1999: - bug fix for simple diagnostics: needed
;                            to add dummy value to compound array.
;        mgs, 16 Mar 1999: - catch error in tracerinfo.dat (more than one
;                            tracer with same number)
;                          - error in update_tracer... should have been
;                            fixed. Some more debug output added for 
;                            testing.
;        mgs, 23 mar 1999: - set vertical dimension to -1 for new compound
;                            datainfo records
;        mgs, 24 May 1999: - updated filetype info
;        mgs, 02 Jun 1999: - added retall statement after error
;                            message
;        bmy, 23 Nov 1999: - added /SMALLCHEM keyword for CTM_TRACERINFO
;        bmy, 27 Sep 2001: GAMAP VERSION 1.49
;                          - Set F77=1 for filetype 4 (DAO met fields)
;                          - Now reference function LITTLE_ENDIAN
;                          - Swap endian in OPEN_FILE if reading data
;                            on a little-endian machine (e.g. PC) 
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - now test valid diagnostics using 
;                            DIAGSTRU[*].CATEGORY and not DIAGSTRU[*].INDEX
;                          - removed /SMALLCHEM keyword, it's obsolete
;                          - Now recognizes binary files as having
;                            FILETYPE values between 100 and 200
;                          - Removed /SMALLCHEM flag, it's obsolete
;                          - Now uses diagnostic spacing from CTM_DIAGINFO
;                            and pass this to UPDATE_TRACER_DIAGINFO
;        bmy, 11 Feb 2004: GAMAP VERSION 2.01a
;                          - Internal routine MAKE_COMPOUND_DATAINFO
;                            now passes SPACING from CTM_DIAGINFO
;                            to routine CTM_DOSELECT_DATA
;        bmy, 27 Oct 2004: GAMAP VERSION 2.03
;                          - added QUIET keyword to suppress printing
;                            information about retrieved tracers
;
; KNOWN BUGS OR WEAKNESSES:
;        - handling of USE_DATAINFO and USE_FILEINFO is not carried 
;          through all lower level subroutines, i.e. they may be replaced
;          by *pGlobal... in some occasions. Since USE_... should always
;          be a subset of *pGlobal..., no serious errors are expected
;          from this weakness. 
;
;        - known bug in update_tracer_datainfo, see comment in routine.
;
;-
; Copyright (C) 1998, 1999, 2001, 2003, 2004,
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_get_data"
;-------------------------------------------------------------


pro reopen_all_files,fileinfo
 
   ; Need to reference the LITTLE_ENDIAN function (bmy, 9/27/01)
   FORWARD_FUNCTION Little_Endian

    on_error,2
 
    for i=0,n_elements(FileInfo)-1 do begin

       ; get file status
       if ( FileInfo[i].ilun lt 0 ) then goto, skip_thisfile
       test = fstat( FileInfo[i].ilun )
 
       ; re-open file if accidentally closed
       ; (Note: detached composites contain negative ilun)
       if ( not test.open ) then begin

          ; Open file only if BINARY or ASCII
          ; BINARY files have FILETYPE values between 100 and 200
          Is_Binary = ( FileInfo[I].FileType ge 100 AND $
                        FileInfo[I].FileType lt 200 )

          ; Open file -- assume big endian
          Open_File, FileInfo[I].FileName, FileInfo[I].Ilun, $
             F77_Unformatted=Is_Binary, Default=DefaultPath, $
             /No_PickFile,              Swap_Endian=Little_Endian()
 
           ; error test
          if (fileinfo[i].ilun lt 0) then $
             message,'*** Serious error: Cannot re-open file '+ $
             fileinfo[i].filename
       endif
skip_thisfile:
    endfor
 
    return
end
 
;------------------------------------------------------------------------------
 
pro make_compound_datainfo, DataInfo, category, ilun, tracer, $
                            tau0,     tau1,     dim,  first,  $
                            Status=Sel_Status 
   
   ;====================================================================
   ; Internal routine MAKE_COMPOUND_DATAINFO
   ;
   ; IMPORTANT: tracer must be specified including the tracer offset for
   ; the selected diagnostics! For multitracer diagnostics, it must be the 
   ; traceroffset alone.
   ;
   ; NOTES:
   ; (1) Removed /SMALLCHEM keyword (bmy, 11/19/03)
   ; (2) Call CTM_DIAGINFO to get the diagnostic spacing (bmy, 2/11/04)
   ;====================================================================

   ; include global common block   
   @gamap_cmn

   ; Get the spacing between diagnostic offsets (bmy, 2/11/04)
   CTM_DiagInfo, Category, Spacing=Spacing

   ; test whether compound is already defined globally and only had
   ; been masked out in user selection
   if (ptr_valid(pGlobalDataInfo)) then begin
      test = ctm_doselect_data( category, *pGlobalDataInfo, $
                                ilun=ilun, tracer=tracer,   $
                                tau=tau0,  Spacing=Spacing )

       ; if found, append to DataInfo argument and return
      if (test[0] ge 0) then begin
         if (DEBUG) $
            then message,'## found compound in global datainfo.',/Info 
         DataInfo = [ DataInfo, (*pGlobalDataInfo)[test[0]] ]
         return
      endif
   endif else $
      message,'*** SERIOUS ERROR! No global datainfo structure!'


   ; Otherwise create local copy of new compound datainfo record
   newd = create3dhstru()
   newd.category = category
   newd.ilun = ilun
   newd.tracer = tracer
   newd.tau0 = tau0
   newd.tau1 = tau1
   newd.dim = dim
   newd.dim[2] = -1             ; number of levels unknown
   newd.first = first

   ; get name, unit, and standard scaling factor for tracer
   ctm_tracerinfo,tracer,tstru  
                                
   if (n_elements(tstru) gt 1) then begin
      message,'More than one tracer with number '+strtrim(tracer)+ $
         '! Check tracerinfo.dat file!',/Continue
      message,'Will use first one ...',/INFO,/NONAME
      tstru = tstru[0]
   endif
   newd.tracername = tstru.name
   newd.unit = tstru.unit
   newd.scale = tstru.scale
   
   if (DEBUG) then message,'## new datainfo record created.',/Info
   if (DEBUG) then print,'## scaling factor from tstru : ',newd.scale

   ; and append this to DataInfo argument
   ; as well as global datainfo array
   DataInfo = [ DataInfo, newd ]
   *pGlobalDataInfo = [ *pGlobalDataInfo, newd ]
    
   return
end

;------------------------------------------------------------------------------


pro update_tracer_datainfo, datainfo, traceroffset, Spc 

   ;====================================================================
   ; Internal routine UPDATE_TRACER_DATAINFO
   ;
   ; NOTES:
   ; (1) Removed /SMALLCHEM keyword (bmy, 11/19/03)
   ; (1) Added SPC keyword to pass the diagnostic spacing from
   ;     CTM_DIAGINFO from the main program (bmy, 11/19/03)
   ;====================================================================
   FORWARD_FUNCTION ctm_doselect_data

   ; include global common block
   @gamap_cmn
 
   ; look for tracer numbers < SPACING. These have to be offset
   test = where( DataInfo.tracer lt Spc )
   if (test[0] ge 0) then  $
      DataInfo[test].tracer =  $
            DataInfo[test].tracer + traceroffset

   ; get tracer information. Note: we pass an array of tracer
   ; numbers to ctm_tracerinfo !
   ctm_tracerinfo,DataInfo.tracer,tstru 

   ; supplement names
   test = where(strtrim(DataInfo.tracername,2) eq '')

   if (test[0] ge 0) then begin
      DataInfo[test].tracername = tstru[test].name

      ; update global structure case by case
      for i=0,n_elements(test)-1 do begin
         ind = ctm_doselect_data(DataInfo[test[i]].category,  $
                                 *pGlobalDataInfo,  $
                                 ilun=DataInfo[test[i]].ilun, $
                                 tracer=(DataInfo[test[i]].tracer MOD Spc), $
                                 trcoffset=traceroffset, $
                                 tau=DataInfo[test[i]].tau0, $
                                 Spacing=Spc ) ; (bmy, 11/19/03)

         ; The following message should NOT occur !!
         if (n_elements(ind) gt 1) then message,'## suppl. names:'+$
            string(ind,format='(255(I4,1X))'),/Continue

         if (ind[0] ge 0) then begin
           (*pGlobalDataInfo)[ind[0]].tracername = DataInfo[test[i]].tracername
         endif else begin  ; ### else: DEBUG
            message,'WARNING: Use_DataInfo appears independent from '+ $
                    'global array!',/INFO
         endelse
 
      endfor
   endif

   ; supplement scale factors and units
   ; (scale factor only when no unit was assigned previously!)
   if (DEBUG) then print,'## SCALE before=',DataInfo.scale
   test = where( strtrim(DataInfo.unit,2) eq '' )

   if (test[0] ge 0) then begin
      DataInfo[test].scale =  $
         DataInfo[test].scale * tstru[test].scale
      DataInfo[test].unit = tstru[test].unit
      if (DEBUG) then print,'## SCALE after=',DataInfo.scale

      ; Need to apply scaling factor if status=1 (already read)
      for i=0,n_elements(test)-1 do begin
         if (DataInfo[test[i]].status eq 1   $
             AND DataInfo[test[i]].scale ne 1.0) then $
            if (ptr_valid(DataInfo[test[i]].data) ) then begin
               *DataInfo[test[i]].data = *DataInfo[test[i]].data   $
                                         * DataInfo[test[i]].scale
               DataInfo[test[i]].scale = 1.0
               if (DEBUG) then message,'## Scaling factor applied.',/INFO
            endif else print,'% CTM_GET_DATA: ##3A !' ; DEBUG !! ####
      endfor

      ; update global structure case by case
      for i=0,n_elements(test)-1 do begin
         ind = ctm_doselect_data(DataInfo[test[i]].category,  $
                                 *pGlobalDataInfo,  $
                                 ilun=DataInfo[test[i]].ilun, $
                                 tracer=(DataInfo[test[i]].tracer MOD Spc), $
                                 trcoffset=traceroffset, $
                                 tau=DataInfo[test[i]].tau0, $
                                 Spacing=Spc ) ; (bmy, 11/19/03) 
         
         if (n_elements(ind) gt 1) then message,'## suppl. names:'+$
            string(ind,format='(255(I4,1X))'),/Continue

         if (ind[0] ge 0) then begin
            (*pGlobalDataInfo)[ind[0]].scale = DataInfo[test[i]].scale
            (*pGlobalDataInfo)[ind[0]].unit = DataInfo[test[i]].unit
         endif else $           ; ### else: DEBUG
            message,'Use_DataInfo must be independent from global array!',/INFO
 
      endfor
   endif


; *********************************************************************
; * QUICK FIX(?) for now: Just set all global scale fields of loaded 
;                         data records to 1 !!!

; should now be fixed (?) -> Add debug output

   if (n_elements(*pglobaldatainfo) gt 0) then begin
      ind = where((*pglobaldatainfo).status eq 1)
      if (ind[0] ge 0) then begin
          ind2 = where((*pglobaldatainfo)[ind].scale ne 1.0)
          if (ind2[0] ge 0) then begin
             print,'###>>CTM_GET_DATA : loaded data set with scale ',$
                   'factor <> 1 !'
             print,'Index = ',ind[ind2]
          endif
          (*pglobaldatainfo)[ind].scale = 1.0
      endif
   endif

; *********************************************************************

   return

end

;------------------------------------------------------------------------------
 
pro ctm_get_data,datainfo,diagn,  $
              filename=filename,ilun=sel_ilun,tracer=sel_tracer, $
              tau0=sel_tau0,taurange=taurange,first=first,last=last,  $
              index=index,status=sel_status,   $
              use_fileinfo=use_fileinfo,use_datainfo=use_datainfo,  $
              internal_use=internal_use, Quiet=Quiet
 
; side effects: ilun,tracer and tau0 will be overwritten with actually
; used values - except if no specific diagnostics is requested

    FORWARD_FUNCTION ctm_doselect_data
 
; include global common block
@gamap_cmn.pro
 
    ; Safe exit condition
    index = -1L

    ; Remove old DATAINFO variable
    if (n_elements(DataInfo) gt 0) then undefine,DataInfo

    ; default for diagn is 0 (all diagnostics)
    if (n_elements(diagn) eq 0) then diagn = 0
 
    internal_use = keyword_set(internal_use)
 
    ; determine whether file has to be read
    force_reading = ( n_elements(filename) gt 0 AND not internal_use )

    ; ============================================================ 
    ; Error checking
    ; ============================================================ 
 
    ; ------------------------------------------------------------ 
    ; Get default FileInfo and DataInfo structures
    ; (may still be undefined, if global pointers are NIL !)
    ; ------------------------------------------------------------ 
 
    ctm_GetDefaultStructures,Use_FileInfo,Use_DataInfo,result=result

    if (not result) then force_reading = 1  ; must read something
 
    ; ------------------------------------------------------------ 
    ; Check validity of diagnostics and get diaginfo
    ; ------------------------------------------------------------ 

    ; if no diagnostics was given or diagn = 0, then request data
    ; for all diagnostics
    all_diags = 0
    if (n_elements(diagn) eq 0) then diagn = 0
    if (size(diagn,/type) lt 7) then begin     ; diagnostic by number
       if (diagn[0] eq 0) then all_diags=1  
    endif else if (size(diagn,/type) eq 7) then begin
       if (diagn[0] eq '') then all_diags=1    ; diagnostic by name
    endif

    ; get diagnostic information (name, traceroffset, multitracer?)
    ctm_diaginfo,diagn,diagstru,all_diags=all_diags 

    ; Get the spacing between diagnostic offsets (bmy, 11/19/03)
    Spacing = DiagStru[0].Spacing

    ; test for invalid diagnostics
    test = where( diagstru.Category eq '' )
    if (test[0] ge 0) then begin 
       message,'Invalid diagnostic requested:' +  $
               string(diagstru[test],format='(255(A,1X))'), $
               /Cont
       return
    endif
 
    ; ============================================================ 
    ; Open a new CTM file or re-open all files 
    ; ============================================================ 

    ; reset error state
    Message,/Reset
 
    ; ------------------------------------------------------------ 
    ; Open a new CTM file if requested, i.e. a filename is
    ; provided (may be empty string). As a consequence, only 
    ; data from this file will be loaded! Use_FileInfo and 
    ; Use_DataInfo are overwritten with values for that file.
    ; If the file has been opened already, this provides a
    ; convenient way to extract all data records from this file.
    ; The file will not be parsed again.
    ; ------------------------------------------------------------ 
 
    if (force_reading) then begin
 
       ctm_open_file,filename,use_fileinfo,use_datainfo,  $
                     cancelled=cancelled

    endif else begin
 
    ; ------------------------------------------------------------ 
    ; re-open all files if called internally or no filename is
    ; given 
    ; Use_FileInfo and Use_DataInfo will be set to their global values
    ; ------------------------------------------------------------ 

       cancelled = 0 
       Reopen_All_Files,use_fileinfo

    endelse

    ; Test for errors (NOTE: a F77 read error in a routine 
    ; upstream can cause CTM_GET_DATA to exit here!!!)
    if (cancelled or !Error_State.Code lt 0) then return

 
    ; ------------------------------------------------------------ 
    ; Test validity of FileInfo and DataInfo structures
    ; ------------------------------------------------------------ 
 
    ctm_ValidateStructures,use_FileInfo,use_DataInfo,result=result,/PRINT

    if (not result) then return   ; something went wrong

    ; ============================================================ 
    ; Loop through diagnostics
    ; ============================================================ 

    resindex = -1L

    for dn = 0,n_elements(diagstru)-1 do begin

       ; ============================================================ 
       ; Set selection criteria:
       ; - if ilun, tracer, tau0, or status not provided, use all
       ;   that are available for current diagnostics
       ; Use CTM_DoSelect_Data to retrieve all available items
       ; that match specified ILUN, TRACER and TAU0.
       ;
       ; CTM_DoSelect_Data will return all available values for
       ; ilun, tracer, and tau0 if they were not specified.
       ; Therefore, we must undefine them for each diagnostics
       ; unless they were specified with the ILUN, TRACER and 
       ; TAU0 keywords.
       ; ============================================================ 
 
       ; Expand category first (multilevel diagnostics)
       xcategory = expand_category(diagstru[dn].category,/No_Delete) 

       if (n_elements(sel_ilun) eq 0) $
          then undefine,ilun          $
          else ilun = sel_ilun

       if (n_elements(sel_tracer) eq 0) then undefine,tracer  $
       else begin
          ;-----------------------------------------------------------
          ; Prior to 11/20/03:
          ;tracer = (sel_tracer mod 100)  ; ### mgs, 11/12/98
          ;-----------------------------------------------------------
          tracer = ( sel_tracer mod Spacing ) 
          ; special for multitracer diagnostics: add tracer offset as 
          ; generic tracer
          if (diagstru[dn].maxtracer gt 1) then  $
             tracer = [ tracer, diagstru[dn].offset ]
       endelse

       if (n_elements(sel_tau0) eq 0) then undefine,tau0  $
       else tau0 = sel_tau0

       if (n_elements(sel_status) eq 0) then status = 2  $
       else status = sel_status


       xcatindex = ctm_doselect_data(xcategory,                      $
                                     Use_DataInfo,                   $
                                     ilun=ilun,                      $
                                     tracer=tracer,                  $
                                     trcoffset=diagstru[dn].offset,  $
                                     tau=tau0,                       $
                                     status=status,                  $
                                     count=count,                    $
                                     missing=missing,                $
                                     DEBUG=debug,                    $
                                     Spacing=Spacing )

       ; No matching records found:
       ; print warning only if specific diagnostics requested
       if ( count eq 0 ) then begin
          if ( not all_diags ) then begin
             message,'Records for diagnostic ' +  $
                     diagstru[dn].category + $
                     ' do not match criteria!',  $
                     /Continue
             message,'Could not match ' +  $
                     string(missing,format='(6(A,1X))'), $
                     /Continue,/NoName
          endif
          goto,end_diag_loop

       ;----------------------------------------------------------------
       ; Prior to 7/20/04:
       ; Now suppress printing of the category name if /QUIET is set
       ; (bmy, 10/27/04)
       ;endif else $
       ;   message,'--- Retrieve records for diagnostic ' +  $
       ;           xcategory[0] +  $
       ;           ' ... ---',/INFO,/NONAME
       ;----------------------------------------------------------------
       endif else begin

          ; Suppress info output when /QUIET is set (bmy, 10/27/04)
          if ( not Keyword_Set( QUIET ) ) then begin
             message,'--- Retrieve records for diagnostic ' +  $
                xcategory[0] +  $
                ' ... ---',/INFO,/NONAME
          endif

       endelse
 
       ; ------------------------------------------------------------ 
       ; Extract requested timesteps from available timesteps
       ; if keywords FIRST, LAST or TAURANGE were used instead of 
       ; TAU0.
       ; Note: Use of TAU0 superseeds FIRST, LAST, TAURANGE keywords 
       ; and TAURANGE superseeds FIRST or LAST.
       ;
       ; Variable TAU0 has stored all available time steps, SEL_TAU0
       ; is the variable associated with keyword TAU0.
       ; ------------------------------------------------------------ 

       if (n_elements(sel_tau0) eq 0) then begin

          selind = lindgen(n_elements(xcatindex))
 
          if (keyword_set(FIRST)) then  $
             selind = where( Use_DataInfo[xcatindex].tau0 eq min(tau0) )

          if (keyword_set(LAST))  then  $
             selind = where( Use_DataInfo[xcatindex].tau0 eq max(tau0) )

          if (n_elements(TAURANGE) eq 2) then  $
             selind = where( Use_DataInfo[xcatindex].tau0 ge taurange[0] AND $
                             Use_DataInfo[xcatindex].tau0 lt taurange[1] )

          if (selind[0] lt 0) then begin
             message,'No data available in requested time range!',  $
                     /Continue,/NoName
             goto,end_diag_loop
          endif else $
             xcatindex = xcatindex[selind]
       endif
 
       ; ============================================================ 
       ; Reduce selection to compound records for multilevel or
       ; multitracer diagnostics. Treat simple diagnostics individually.
       ; "Compound" indices will later be copied into the resulting
       ; resindex.
       ; ============================================================ 

       compound = -1L
       ;### for debug purposes:  ###
       issimple = 0

       ; ------------------------------------------------------------
       ; If current diagnostics is multilevel diagnostics, make sure
       ; that "compound" header exists for all "cases" defined by 
       ; ILUN, TRACER and TAU0. If not, create a new datainfo structure
       ; and append to global datainfo as well as use_DataInfo.
       ; ------------------------------------------------------------

       if ( n_elements(xcategory) gt 1 ) then begin
          if (DEBUG) $
             then message,'multilevel diagnostics. Finding compounds ...',/INFO
          ; copy selected records in use_datainfo into d
          d = use_datainfo[xcatindex]
          for i = 0,n_elements(d)-1 do begin

             ; if this record is compound, add to resindex. 
             ; Otherwise find associated compound record or create one
             ; if it does not exist.
             if ( d[i].category eq xcategory[0] ) then begin
               compound = [ compound, xcatindex[i] ]
             endif else begin
               ctracer = d[i].tracer
               if (ctracer lt Spacing) then  $
                  ctracer = ctracer + diagstru[dn].offset

               test = where( Use_DataInfo[xcatindex].category eq xcategory[0] $
                        AND  Use_DataInfo[xcatindex].ilun eq d[i].ilun $
                        AND  Use_DataInfo[xcatindex].tracer eq ctracer $
                        AND  Use_DataInfo[xcatindex].tau0 eq d[i].tau0 )
               ; compound not found, make it and append to xcatindex
               ; and compound
               if (test[0] lt 0) then begin

;  DEBUG=1 ; ####
                  if (DEBUG) then begin
                     message,'make_compound: tracer='+string(d[i].tracer),/INFO
                  endif
                  make_compound_datainfo,Use_DataInfo,xcategory[0], $
                       d[i].ilun,ctracer,d[i].tau0,d[i].tau1,  $
                       d[i].dim,d[i].first ;, SmallChem=SmallChem
                  ; bmy added smallchem flag 11/23/99
                  ; Removed SMALLCHEM (bmy, 11/19/03)

                  xcatindex = [ xcatindex, n_elements(Use_DataInfo)-1 ]
                  compound = [ compound, n_elements(Use_DataInfo)-1 ]
               endif
             endelse

          endfor
       endif  $
 
       ; ------------------------------------------------------------
       ; If current diagnostics is multitracer diagnostics, make sure
       ; that "compound" header exists for all "cases" defined by 
       ; ILUN and TAU0. If not, create a new datainfo structure
       ; and append to global datainfo as well as use_DataInfo.
       ; The tracer number will be diagstru[dn].offset.
       ; ------------------------------------------------------------

       else if ( diagstru[dn].maxtracer gt 1 ) then begin
          if (DEBUG) then begin
             message,'multitracer diagnostics. Finding compounds ...',/INFO
          endif

          ; copy selected records in use_datainfo into d
          d = use_datainfo[xcatindex]

          for i = 0,n_elements(d)-1 do begin
             ; if this record is compound, add to resindex. 
             ; Otherwise find associated compound record or create one
             ; if it does not exist.
             if ( d[i].tracer eq diagstru[dn].offset ) then begin
               compound = [ compound, xcatindex[i] ]
             endif else begin
               test = where( Use_DataInfo[xcatindex].category eq xcategory[0] $
                        AND  Use_DataInfo[xcatindex].ilun eq d[i].ilun $
                        AND  Use_DataInfo[xcatindex].tracer eq  $
                                                     diagstru[dn].offset  $
                        AND  Use_DataInfo[xcatindex].tau0 eq d[i].tau0 )
               ; compound not found, make it and append to xcatindex
               ; and resindex.
               if (test[0] lt 0) then begin
                  if (DEBUG) then begin
                     message,'make_compound: tracer='+string(d[i].tracer),/INFO
                  endif
                  ctracer = diagstru[dn].offset
                  make_compound_datainfo,Use_DataInfo,xcategory[0], $
                       d[i].ilun,ctracer,d[i].tau0,d[i].tau1,  $
                       d[i].dim,d[i].first ;, SmallChem=SmallChem
                                ;bmy added smallchem 11/23/99
                                ;Removed smallchem (bmy, 11/19/03)

                  xcatindex = [ xcatindex, n_elements(Use_DataInfo)-1 ]
                  compound = [ compound, n_elements(Use_DataInfo)-1 ]
               endif
             endelse

          endfor
       endif  $

       ; ------------------------------------------------------------
       ; Simple diagnostics: Equate compound with xcatindex,
       ; change tracer number to tracer + offset
       ; ------------------------------------------------------------


       else begin
          if (DEBUG) then message,'Simple diagnostics.',/INFO
          compound = [ -1, xcatindex ]

          ;### for debug purposes:  ###
          issimple = 1

       endelse

       ; ============================================================ 
       ; Eliminate bogus from compound
       ; ============================================================ 

       if (n_elements(compound) gt 1) then compound = compound[1:*] $
       else if (not issimple) then begin
message,'*** NO COMPOUND FOUND! (this message shouldn''t be displayed)', $
            /Continue
          return
       endif

       ; ============================================================ 
       ; Supplement tracer name, unit and scale factor
       ; These changes must be transferred to the global datainfo array
       ; need to make copy in order to pass by reference
       ; ============================================================ 

       dc = Use_DataInfo[compound]

       update_tracer_datainfo, dc, diagstru[dn].offset, Spacing
                              ;,SmallChem=SmallChem
                              ; bmy added smallchem flag 11/23/99
                              ; Removed SMALLCHEM flag (bmy, 11/19/03)
                              ; Now pass SPACING (bmy, 11/19/03)

       Use_DataInfo[compound] = dc

       ; at this point all units in compound should have a 
       ; non-empty string!
       test = where(Use_DataInfo[compound].unit eq '')
       if (test[0] ge 0) then   $
          Message,'*** CONCEPTIONAL ERROR: Empty units detected!'

       ; ============================================================ 
       ; If status keyword was used, clean up compound again. If 
       ; compound records were previously created they may have 
       ; been added in spite of a different status -- this is 
       ; necessary for automatic reading.
       ; ============================================================ 

       if (n_elements(sel_status) gt 0) then begin
          if (sel_status[0] eq 0 OR sel_status[0] eq 1) then begin
             okind = where(Use_DataInfo[compound].status eq sel_status[0])
             if (okind[0] ge 0) then compound = compound[okind] $
             else begin
                message,'No data records with matching status found!',/Cont
                return
             endelse
          endif 
       endif  $

       ; ============================================================ 
       ; Read data where necessary. If STATUS keyword was used, we
       ; only requested information, so nothing needs to be read.
       ; Otherwise loop through "compound" records and read those
       ; with status = 0.
       ; ============================================================ 

       else begin
          for i=0,n_elements(compound)-1 do $
             ; need to make local copy because we need to change
             if ( Use_DataInfo[compound[i]].status eq 0 ) then begin
; print,'#### GETDATA: before i,status=',i,Use_DataInfo[compound[i]].status
                dc = Use_DataInfo[compound[i]]
                ctm_retrieve_data,dc,diagstru[dn],result=result
                if (result) then Use_DataInfo[compound[i]] = dc $
                else begin ; #### DEBUG for now, message should be displayed
                           ;      in lower level routines already
                   message,'*** ERROR reading data for current datainfo!', $
                           /Continue
                   print,dc
                   retall       ; return to top level
                endelse
; print,'#### GETDATA: after status=',dc.status,Use_DataInfo[compound[i]].status

             endif
       endelse

;### Comment out, since this sets the global DEBUG flag to zero (bmy, 12/4/00)
;DEBUG=0 ; #####

       ; ============================================================ 
       ; That's all for the current category. Add "compound" records 
       ; to resindex and proceed with next diagnostics.
       ; ============================================================ 

       resindex = [ resindex, compound ]

end_diag_loop:
    endfor     ; << LOOP over diagnostics 


    ; ================================================================ 
    ; locate valid records and return subset of Use_DataInfo
    ; display error message if no record matching the criteria were 
    ; found
    ; ================================================================ 

    test = where(resindex ge 0)
    if (test[0] ge 0) then begin
       index = resindex[test]
       datainfo = use_datainfo[index]

       ;-------------------------------------------------------------- 
       ; store information in selected ilun, tracer, and tau0 keyword
       ; variables if one specific diagnostics was requested
       ;-------------------------------------------------------------- 
       if (n_elements(diagstru) eq 1) then begin
           sel_ilun = ilun
           sel_tracer = tracer
           sel_tau0 = tau0
       endif
    endif else $
       if (n_elements(diagstru) gt 1) then $
          message,'No data that match criteria found!',/Cont

    return
end
 
