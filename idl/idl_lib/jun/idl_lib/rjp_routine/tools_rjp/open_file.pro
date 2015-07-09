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
;        UPDATE -> Set this keyword to open the file for reading and
;            writing. Contrary to Write, the file must already exist,
;            and its content will not be erased (unless you start
;            writing into it without setting the file pointer to the
;            end). Note that the APPEND option is also available via
;            the _EXTRA mechanism.
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
;        ; Quick and dirty with pickfile dialog
;        OPEN_FILE,'*.dat',ilun
;        if (ilun le 0) then stop    ; check error condition
;
;        ; A few more options invoked
;        OPEN_FILE,'~/data/thisfile.dat',lun,default='*.dat', $
;            title='Choose a data file',filename=name
;        if (lun le 0) then stop    ; check error condition
;        print,filename,' was opened successfully
;        ; NOTE that filename does not have to be identical with
;        ; '~/data/thisfile.dat' !
;        ; readf,lun,...
;        free_lun,lun
;
; MODIFICATION HISTORY:
;        mgs, 13 Aug 1998: VERSION 1.00
;        mgs, 14 Aug 1998:
;          - small bug fix: handle empty filename string correctly
;        mgs, 22 Aug 1998:
;          - added WRITE keyword to open writable files
;        mgs, 22 Oct 1998:
;          - now always returns LUN=-1 in case of an error
;        mgs, 21 Jan 1999:
;          - Added explicit F77_Unformatted keyword and set
;            Swap_If_Little_Endian or Swap_If_Big_Endian automatically
;        mgs, 10 Feb 1999:
;          - bug fix: swap_if was wrong way round
;        mgs, 12 May 1999:
;          - ok. finally got the hang of byte swapping! it's the
;            machine architecture not the operating system! Now changed
;            it so that !version.arch is tested for 'x86'
;        mgs, 20 May 1999: 
;          - abandoned SWAP_IF completely and use explicit SWAP_ENDIAN
;            keyword in users grace now.
;        mgs, 08 Aug 2000:
;          - include extract_filename and rstrpos as a local
;            procedures and changed copyright to open source
;        mgs, 13 Aug 2000:
;          - added UPDATE keyword.
;
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Martin Schultz  
; -- except for RSTRPOS which is Copyright ©1993-1999 Research Systems, Inc.
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################



;-------------------------------------------------------------
; This routine is an IDL library routine which is copyrighted by
; RSI. However, since they labeled it obsolete, I don't think they
; have too many objections if you use and/or redistribute this routine. 

FUNCTION RSTRPOS, Expr, SubStr, Pos     
  ON_ERROR, 2
  N = N_PARAMS()
  if (n lt 2) then message, 'Incorrect number of arguments.'
 
  ; Is expr an array or a scalar? In either case, make a result
  ; that matches.
  if (size(expr, /n_dimensions) eq 0) then result = 0 $
  else result = make_array(dimension=size(expr,/dimensions), /INT)
 
  RSubStr = STRING(REVERSE(BYTE(SubStr)))       ; Reverse the substring
 
  for i = 0L, n_elements(expr) - 1 do begin
    Len = STRLEN(Expr[i])
    IF (N_ELEMENTS(Pos) EQ 0) THEN Start=0 ELSE Start = Len - Pos
 
    RString = STRING(REVERSE(BYTE(Expr[i])))    ; Reverse the string
 
    SubPos = STRPOS(RString, RSubStr, Start)
    IF SubPos NE -1 THEN SubPos = Len - SubPos - STRLEN(SubStr)
    result[i] = SubPos
  endfor
 
  RETURN, result
END    

;-------------------------------------------------------------

function extract_filename,fullname,filepath=thisfilepath

; determine path delimiter
    if (!version.os_family eq 'Windows') then sdel = '\' else sdel = '/'

    filename = ''
    thisfilepath = ''

retry:
; look for last occurence of sdel and split string fullname
    p = rstrpos(fullname,sdel)

; extra Windows test: if p=-1 but fullname contains '/', retry
    if (p lt 0 AND strpos(fullname,'/') ge 0) then begin
       sdel = '/'
       goto,retry
    endif


    if (p ge 0) then begin
       thisfilepath = strmid(fullname,0,p+1)
       filename = strmid(fullname,p+1,strlen(fullname)-1)
    endif else $
       filename = fullname


return,filename

end


;-------------------------------------------------------------

pro open_file,filemask,lun,filename=filename,  $
              write=write, update=update,  $
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
       ; seperate filename from filepath
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

; print,'### fname, path=>',fname,'<>',path,'<>',expand_path(path),'<'
       ; call pickfile dialog
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

    ; Now try to open the file
    if (lun le 0) then get_lun,lun

    on_ioerror, openerr
    if (keyword_set(WRITE)) then $
       openw,lun,thisfilename,F77=F77_Unformatted, $
            Swap_Endian=Swap_Endian,_EXTRA=e   $
    else if keyword_set(update) then $
       openu,lun,thisfilename,F77=F77_Unformatted, $
            Swap_Endian=Swap_Endian,_EXTRA=e  $
    else  $
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
              update=update,/pickfile,title=title,  $
              defaultmask=defaultmask,_EXTRA=e
    endif

    return

end
