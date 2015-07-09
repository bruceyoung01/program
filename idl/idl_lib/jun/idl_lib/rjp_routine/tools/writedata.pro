; $Id: writedata.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        WRITEDATA
;
; PURPOSE:
;        write a 2 dimensional data array and header information to a file
;
; CATEGORY:
;        file handling routines
;
; CALLING SEQUENCE:
;        WRITEDATA,FILENAME,DATA [,HEADER,UNITS,CFACT,MCODE] [,keywords]
;
; INPUTS:
;        FILENAME --> the name of the output file. If the output file
;            exists, the user will be prompted for a new name unless
;            keyword NO_WARN is set.
;
;        DATA --> The data array to be written.
;
;        HEADER --> An optional string array containing variable names.
;            These will be composed to a string using the DELIM delimiter.
;            Note that the HEADER information can also be passed in the
;            pre-formatted COMMENTS keyword parameter.
;
;        UNITS, CFACT, MCODE --> string arrays that will be added to the
;            file header concatenated with blank delimiters. These parameters
;            are optional and merely there to facilitate creating chem1d
;            model input files.
;
; KEYWORD PARAMETERS:
;        TITLE --> A title string that will be the first header line.
;            It is also possible to pass a string array here, although for
;            more complicate file headers it is recommended to pre-format
;            the file header and pass it in the COMMENTS keyword.
;
;        DELIM --> A delimiter character for the HEADER (variable name)
;            items. Default is a blank ' '.
;
;        COMMENTS --> A string array containing all the lines of the file
;            header. Note that COMMENTS overrules the input of HEADER, UNITS,
;            CFACT, and MCODE as well as TITLE.
;
;        /NO_WARN --> Suppress warning message and user prompt for a new
;            filename if the file already exists.
;
; OUTPUTS:
;        A file containing a file header and the data array written
;        line by line.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        DATA = findgen(3,10)
;        HEADER = ['A','B','C']
;        writedata,'test.out',DATA,HEADER,TITLE='test file',DELIM=';'
;
;        This will create a file like:
;            test file
;            A;B;C
;                  0.00000      1.00000      2.00000
;                  3.00000      4.00000      5.00000
;            ...
;
; MODIFICATION HISTORY:
;        mgs, 25 Nov 1997: VERSION 1.00
;        mgs, 05 Apr 1999: - now uses formatted write statement
;                 (looks like a bug in IDL for windows: sometimes no space
;                  is printed between numbers if you simply print,data)
;
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine writedata"
;-------------------------------------------------------------


pro writedata,filename,data,header,units,cfact,mcode, $
       title=title,delim=delim,   $
       comments=comments,  $
       no_warn=no_warn



    on_error,2   ; return to caller

; check consistency of variables, built comments string if
; not already passed

    if (n_params() lt 2) then begin
        print,'*** WRITEDATA : At least 2 parameters required ' + $
              '(filename and data) ! ***'
        return
    endif

    if (n_elements(comments) eq 0) then comments = ''
    if (comments[0] ne '' AND  $
        (n_elements(header) gt 0 OR n_elements(units) gt 0 OR $
         n_elements(cfact) gt 0 OR n_elements(mcode) gt 0) ) then begin
       print,'*** WRITEDATA : You passed data in COMMENTS and at least one '+$
             'of the parameters HEADER, UNITS, CFACT, MCODE. !'
       print,'I will use the information in COMMENTS.'
    endif

    if (n_elements(delim) le 0) then delim = ' '    ; blank as default

    if (n_elements(COMMENTS) le 0) then begin
       comments = ''     ; dummy to begin with
       if (n_elements(title) gt 0) then comments = [ comments, title ]
       if (n_elements(header) gt 0) then begin
           tmp = string(header,format='(500(A,:,"'+delim+'"))')
           comments = [ comments, tmp ]
       endif
       if (n_elements(units) gt 0) then begin
           tmp = string(units,format='(500(A,:," "))')
           comments = [ comments, tmp ]
       endif
       if (n_elements(cfact) gt 0) then begin
           tmp = string(cfact,format='(500(A,:," "))')
           comments = [ comments, tmp ]
       endif
       if (n_elements(mcode) gt 0) then begin
           tmp = string(mcode,format='(500(A,:," "))')
           comments = [ comments, tmp ]
       endif
       if (n_elements(comments) gt 1) then $
          comments = comments(1:n_elements(comments)-1)
    endif


; check if file exists and prompt user for different filename
    if (not keyword_set(NO_WARN)) then begin
       force = 0
       while (file_exist(filename) AND not force) do begin
          newname=''
          print,'## File '+filename+' exists! ' + $
                'Input new name or press enter to overwrite. A single "."' + $
                ' will abort.'
          read,newname,prompt='>>'
          newname = strcompress(newname,/remove_all)
          if (newname eq '.') then return
          if (newname eq filename OR newname eq '') then $
              force = 1 $
          else $
              filename = newname
       endwhile
    endif

; open file and write comments, then data line by line

    openw,olun,filename,/get_lun,width=8192

    if (comments(0) ne '') then $
       for i=0,n_elements(comments)-1 do $
           printf,olun,comments(i)

    ndat = n_elements(data[0,*])
    nvars = n_elements(data[*,0])
if (nvars le 0) then stop

    ; find min/max values for each variable to determine
    ; the output format
    m1 = fltarr(nvars)
    for j=0,nvars-1 do $
         m1[j] = max(abs(data[j,*]))

    for i=0,ndat-1 do begin
       dataline = (data(*,i))

       ; "standardize" missing values
       ind = where(abs(dataline+999.9) lt 1.)
       if (ind[0] ge 0) then dataline[ind] = -999.99
       ind = where(abs(dataline+9.99E+30) lt 1.E26)
       if (ind[0] ge 0) then dataline[ind] = -999.99
       ind = where(abs(dataline+7.77E30) lt 1.E26)
       if (ind[0] ge 0) then dataline[ind] = -777.77
       ind = where(abs(dataline+8.88E30) lt 1.E26)
       if (ind[0] ge 0) then dataline[ind] = -888.88

       ; construct output line
       dats = ''
       for j=0,nvars-1 do  $
           if (m1[j] lt 0.5 OR m1[j] gt 1.0e6) then $
              dats = dats+' '+string(dataline(j),format='(e12.4)')  $
           else   $
              dats = dats+' '+string(dataline(j),format='(f10.2)')
       printf,olun,dats
    endfor


    close,olun
    free_lun,olun

    print,ndat,' lines written to file '+filename+'.'

return
end

