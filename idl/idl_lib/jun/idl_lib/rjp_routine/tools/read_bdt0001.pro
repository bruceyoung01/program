; $Id: read_bdt0001.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        READ_BDT0001
;
; PURPOSE:
;        Read a simple binary data file with size information
;        and variable names and units (format BDT0001).
;
; CATEGORY:
;        File Routines
;
; CALLING SEQUENCE:
;        READ_BDT0001,filename,data,vardesc,nvars,nlines [,keywords]
;
; INPUTS:
;        FILENAME -> Name of the file to read or a file mask that
;            will be used in the PICKFILE dialog (see OPEN_FILE)
;            If FILENAME is a named variable, the actual filename
;            will be returned and replace a template.
;
; KEYWORD PARAMETERS:
;        NAMES -> a named variable will contain a string array with
;            NVARS variable names
;
;        UNITS -> ... a string array with NVARS physical units
;
;        COMMENTS -> A named variable that will return comment lines
;            stored in the data file. NOTE that comments are not
;            saved in vardesc.
;
;        DEFAULTMASK -> Default mask for PICKFILE dialog (see
;            OPEN_FILE).
;
;        FILE_ID -> A named variable will return the file identifier
;            string (80 characters). This string will be returned
;            even if the file is of wrong type and no data was read.
;
;        TYPE -> A named variable will contain the data type
;
;        _EXTRA keywords are passed on to OPEN_FILE
;
; OUTPUTS:
;        DATA -> an array with NLINES * NVARS values. The type of the
;            data array depends on the information stored in the file.
;
;        VARDESC -> A variable descriptor structure (see GTE_VARDESC)
;
;        NVARS -> number of variables in file
;
;        NLINES -> number of data lines
;
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses OPEN_FILE
;
; NOTES:
;        See also WRITE_BDT0001
;
;        Format specification:
;        file_ID  :      80 byte character string
;        NVARS, NLINES, NCOMMENTS, TYPE : 4 byte integer (long)
;        NAMES :         NVARS*40 byte character string
;        UNITS :         NVARS*40 byte character string
;        COMMENTS :      NCOMMENTS records of 80 byte length
;        DATA  :         8 byte float (double) array NLINES*NVARS
;
; EXAMPLE:
;        READ_BDT0001,'~/tmp/*.bdt',data,vardesc,comments=comments
;
;        ; Will read a file that the user selects with the PICKFILE
;        ; dialog. No information about the actual filename is
;        ; returned.
;
;        FILE = '~/tmp/*.bdt'
;        READ_BDT0001,FILE,data,vardesc,nvars,nlines,file_id=file_id
;
;        ; Does the same thing, but this time FILE will contain the
;        ; actual filename. The number of variables and lines are
;        ; returned in NVARS and NLINES, the file identifier string
;        ; is returned in file_id
;
; MODIFICATION HISTORY:
;        mgs, 24 Aug 1998: VERSION 1.00
;        mgs, 23 Dec 1998: VERSION 1.10:
;            - DATA now undefined if unsuccessful
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
; with subject "IDL routine read_bdt0001"
;-------------------------------------------------------------


pro read_bdt0001,filename,data,vardesc,nvars,nlines,  $
          names=names,units=units,comments=comments, $
          defaultmask=defaultmask,file_id=file_id, $
          type=type,_EXTRA=e


    ; read simple binary data file with size information, names and units


    nvars = 0L
    nlines = 0L
    ncomments = 0L
    type = 0L
    if (n_elements(data) gt 0) then undefine,data
    names = ''
    units = ''
    file_ID = ''


    ; open the file for reading
    if (n_elements(defaultmask) eq 0) then defaultmask = '*.bdt'
    open_file,filename,ilun,filename=realname,default=defaultmask, $
              /F77_UNFORMATTED,_EXTRA=e

; print,ilun
    if (ilun le 0) then return

    filename = realname  ; return real filename


    on_ioerror,read_error

    ; read file ID
    file_ID = bytarr(80)
    readu,ilun,file_ID
; print,'fileID=',file_ID

    ; check for correct type
    file_ID = string(file_ID)
    filetype = strmid(file_ID,0,8)
    if (strupcase(filetype) ne 'BDT0001:') then begin
       message,'Wrong file type!',/CONT
       goto,close_file
    endif


    t0 = systime(1)

    ; Read dimensional information
    readu,ilun,nvars,nlines,ncomments,type
; print,'nvars,nlines,ncomments,type:',nvars,nlines,ncomments,type

    ; Retrieve names and units information
    tmp = bytarr(40,nvars)
    readu,ilun,tmp
    names = strtrim(tmp,2)
; help,names

    readu,ilun,tmp
    units = strtrim(tmp,2)
; help,units

    ; Retrieve comments
    if (ncomments gt 0) then begin
       tmp = bytarr(80)
       comments = strarr(ncomments)
       for i=0,ncomments-1 do begin
          readu,ilun,tmp
          comments[i] = strtrim(tmp,2)
       endfor
       if (ncomments eq 1) then comments = comments[0]
    endif else $
       comments = ''
; help,comments


    ; Read data
    data = make_array(nlines,nvars,type=type)

    readu,ilun,data
; help,data

    t1 = systime(1)

    message,filename+': '+strtrim(nlines,2)+' lines of '+strtrim(nvars,2)+ $
          ' variables read in '+strtrim(t1-t0,2)+' seconds.', $
          /INFO,/NONAME,/NOPREF


    ; make variable descriptor
    vardesc = gte_vardesc(nvars)
    vardesc.name = names
    vardesc.unit = units

    ; get data range
    for i=0,nvars-1 do begin
       tmpdat = data[*,i] > (-1.E30)
       test = where( tmpdat gt (-1.E30) )
       if (test[0] ge 0) then begin
          vardesc[i].range[0] = min( tmpdat[test], max=tmpmax )
          vardesc[i].range[1] = tmpmax
       endif
    endfor

close_file:
    free_lun,ilun

    return


read_error:
    message,!ERR_STRING+' ('+strcompress(!ERR,/remove_all)+')',/CONT

    free_lun,ilun

    return


end

