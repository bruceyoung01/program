; $Id: open_file.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        OPEN_FILE
;
; PURPOSE:
;        Open a file for input. This routine can automatically
;        decide whether to use DIALOG_PICKFILE, and it contains
;        basic error handling. After successful operation the
;        file with logical unit LUN will be open for input.
;
; CATEGORY:
;        I/O routines
;
; CALLING SEQUENCE:
;        OPEN_FILE,filemask,lun [,keywords]
;
; INPUTS:
;        FILEMASK -> a filename with path information that may
;            contain wildcards ('*', '?')
;
;        LUN -> a named variable that will contain the logical unit
;            number upon return. If a unit number > 0 is passed,
;            an attempt is made to open the file with this number,
;            otherwise, a free unit is selected with /GET_LUN. In case
;            of an error, LUN contains -1. This can be used instead of
;            the RESULT keyword to detect errors (see below).
;
;        (both parameters are mandatory !)
;
; KEYWORD PARAMETERS:
;        FILENAME -> a named variable that will contain the complete
;            filename upon return (i.e. the file selected with PICKFILE)
;
;        WRITE -> Set this keyword to open a file for read and write
;            operations. Normally, a file is opened for reading only.
;
;        RESULT -> a named variable that will return the error status
;            of the operation. A value of 0 indicates the file was
;            opened sucessfully, otherwise the value of !Error_State.Code
;            is returned.
;
;        PICKFILE -> logical flag to force use of the DIALOG_PICKFILE
;            routine, even if a complete filemask without wildcards was
;            passed.
;
;        TITLE -> the title of the pickfile dialog. Default is
;            'Choose a file'.
;
;        DEFAULTMASK -> A default filemask to be used when no filename
;            is given or the filename does not contain wildcards and
;            /PICKFILE is set. This mask will also be used if the
;            file cannot be opened because of 'FILE NOT FOUND' error.
;
;        NO_PICKFILE -> prevents the pickfile dialog for batch operation.
;            The filemask must not contain wildcards.
;            Normally a 'FILE NOT FOUND' condition leads to
;            a second attempt with the /PICKFILE flag set (recursive
;            call). Use this flag if you want to abort instead.
;
;        _EXTRA keywords are passed to the openr routine
;            (e.g. /F77_UNFORMATTED)
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses EXTRACT_FILENAME function
;
; NOTES:
;
; EXAMPLE:
;        (1)
;        ; Quick and dirty with pickfile dialog
;        OPEN_FILE,'*.dat',ilun
;        if (ilun le 0) then stop    ; check error condition
;
;        (2)
;        ; A few more options invoked
;        OPEN_FILE,'~/data/thisfile.dat',lun,default='*.dat', $
;            title='Choose a data file',filename=name
;
;        IF (LUN LE 0) THEN STOP    ; check error condition
;
;        PRINT, FILENAME,' was opened successfully
;        ; NOTE that filename does not have to be identical with
;        ; '~/data/thisfile.dat' !
;        ; readf,lun,...
;
;        CLOSE,    LUN
;        FREE_LUN, LUN
;
; MODIFICATION HISTORY:
;        mgs, 13 Aug 1998: VERSION 1.00
;                          - extracted from ctm_read3dp_header.pro and 
;                            modified
;        mgs, 14 Aug 1998: - small bug fix: handle empty filename
;                            string correctly
;        mgs, 22 Aug 1998: - added WRITE keyword to open writable files
;        mgs, 22 Oct 1998: - now always returns LUN=-1 in case of an error
;        mgs, 21 Jan 1999: - Added explicit F77_Unformatted keyword and set
;                            Swap_If_Little_Endian or Swap_If_Big_Endian  
;                            automatically
;        mgs, 10 Feb 1999: - bug fix: swap_if was wrong way round
;        mgs, 12 May 1999: - ok. finally got the hang of byte swapping! 
;                            It's the machine architecture not the operating
;                            system!  Now changed it so that !VERSION.ARCH is
;                            tested for 'x86'
;        mgs, 20 May 1999: - abandoned SWAP_IF completely and use explicit
;                            SWAP_ENDIAN keyword in users grace now.
;        bmy, 14 Oct 2003: TOOLS VERSION 1.53
;                          - For IDL 6.0+, if PATH is a null string, then
;                            manually reset it to './'.  This will avoid
;                            the contents of the !PATH variable from being
;                            listed in the dialog box. 
;
;-
; Copyright (C) 1998-2003, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine open_file"
;-------------------------------------------------------------


pro open_file,filemask,lun,filename=filename,write=write, $
              result=result, $
              pickfile=pickfile,title=title,defaultmask=defaultmask, $
              no_pickfile=no_pickfile,verbose=verbose,  $
              F77_Unformatted=F77_Unformatted,   $
              Swap_Endian=Swap_endian,_EXTRA=e



    FORWARD_FUNCTION extract_filename


    ; fail safe : set result to error condition first
    result = -1
    ; reset error state
    message,/reset

    filename = ''
    if (n_elements(lun) eq 0) then lun = -1

    ; error check
    ON_ERROR,2
    if (n_params() lt 2) then begin
       message,'Procedure must be called with 2 parameters (FILENAME,ILUN)!'
    endif

    ; ============================================================
    ; set standard search mask and see if DIALOG_PICKFILE shall
    ; be called
    ; ============================================================

    if (n_elements(defaultmask) gt 0) then $
        stdmask = defaultmask[0] $
    else begin
        stdmask = '*'
        if (strupcase(!version.os_family) eq 'WINDOWS') then stdmask = '*.*'
    endelse

    if (n_elements(filemask) eq 0) then filemask = stdmask
    if (filemask eq '') then filemask = stdmask


    ; if filemask contains wildcards, always use pickfile dialog
    ; Abort if NO_PICKFILE is set
    if (strpos(filemask,'*') ge 0 OR strpos(filemask,'?') ge 0) then begin
       if (keyword_set(NO_PICKFILE)) then begin
          message,'Filename must not contain wildcards when '+ $
                'NO_PICKFILE option is set!',/CONT
          lun = -1   ; yet another error indicator
          return
       endif
       pickfile = 1
    endif

    ; make working copy of filemask (will be overwritten by PICKFILE dialog)
    thisfilename = filemask


    ; ============================================================
    ; set up parameters for DIALOG_PICKFILE
    ; ============================================================

    if (keyword_set(pickfile)) then begin

       ; separate filename from filepath
       ; If FILENAME is undefined , then PATH will be undefined as well.
       fname = extract_filename(filemask,filepath=path)

       ; if filename contains wildcards, put them to filemask and
       ; set filename to empty string
       ; if not (pickfile keyword set), then set standard search mask
       if (strpos(fname,'*') ge 0 OR strpos(fname,'?') ge 0) then begin
           fmask = fname
           fname = ''
       endif else begin
           fmask = stdmask
       endelse

       ; set dialog title
       if (n_elements(title) eq 0) then title = 'Choose a file'

       ; For IDL 6.0+, if PATH is a null string, then EXPAND_PATH will
       ; list all of the directories in your !PATH variable in the
       ; dialog box.  To avoid this, we just manually set PATH to
       ; the present directory, './' (bmy, 10/14/03)
       if ( !VERSION.RELEASE ge 6.0 AND StrLen( Path ) eq 0 ) then Path = './' 

       ; Pop up the dialog box for filename selection
       thisfilename = dialog_pickfile(file=fname,path=expand_path(path),  $
                                      filter=fmask, $
                                      title=title, $
                                      must_exist=(1 - keyword_set(WRITE)) )
          
          

       if (thisfilename eq '') then begin   ; cancel button pressed (?)
          lun = -1   ; yet another error indicator
                     ; note that !error_state.code should be 0
          return
       endif
    endif


; print,'#DEBUG: little_endian = ',little_endian()

    ; now try to open the file
    ; NOTE: Do not close the file in this routine since we will need
    ;    the open file to get the data out when we need it
    if (lun le 0) then get_lun,lun

    on_ioerror, openerr
    if (keyword_set(WRITE)) then $
       openw,lun,thisfilename,F77=F77_Unformatted, $
            Swap_Endian=Swap_Endian,_EXTRA=e   $
    else $
       openr,lun,thisfilename,F77=F77_Unformatted, $
            Swap_Endian=Swap_Endian,_EXTRA=e

    ; return parameters
    filename = expand_path(thisfilename)
    result = 0
    return

openerr:
    result = !Error_State.Code
    lun = -1

    if (keyword_set(Verbose) OR not keyword_set(NO_PICKFILE)) then begin
       ; display error message
       dum=dialog_message(['Error opening file ',thisfilename+'!',  $
          !Error_State.sys_msg],/ERROR)
       ; try again
       if (not keyword_set(NO_PICKFILE) and not keyword_set(PICKFILE)) then $
       open_file,filemask,lun,filename=filename,result=result, $
              /pickfile,title=title,  $
              defaultmask=defaultmask,_EXTRA=e
    endif

    return

end
