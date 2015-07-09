;-------------------------------------------------------------
; $Id: read_sondestations.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;+
; NAME:
;        READ_SONDESTATIONS
;
; PURPOSE:
;        Retrieve station codes and geographical locations for 
;        ozone sonding stations as listed in file station.codes
;        from Jennifer A. Logan's ozone sonde climatology.
;        This routine is called from procedure READ_SONDE, and
;        only needs to be called explicitely if the station.codes
;        file resides neither in the current directory nor the 
;        directory of the sonde data files.
;        The procedure will read the file station.codes once then
;        store the information in a common block for later use.
;
; CATEGORY:
;        Atmospheric chemistry
;
; CALLING SEQUENCE:
;        READ_SONDESTATIONS,stations [,filename]
;
; INPUTS:
;        FILENAME (optional) -> if given, it specifies the path and filename
;              of the file that is normally called station.codes.
;              FILENAME may contain wildcards (*,?) in which case a 
;              file selector dialog is displayed. 
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;        STATIONS -> An array with structures containing the stations
;              codes (integer), latitude, longitude, altitude (float),
;              amd name (string). 
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses OPEN_FILE and EXTRACT_FILENAME (used in OPEN_FILE)
;
; NOTES:
;
; EXAMPLE:
;        read_sondestations,stations,'station.codes'
;        ; if called for the first time, reads file station.codes
;        ; and returns information for all stations in stations.
;        ; NOTE: In this case, the filename argument could have been
;        ; omitted.
;
;
; MODIFICATION HISTORY:
;        mgs, 02 Nov 1998: VERSION 1.00
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
; with subject "IDL routine read_sondestations"
;-------------------------------------------------------------


pro read_sondestations,stations,filename
 
; define common block so that file needs to be read only once
COMMON sondestations,stationdata
 
    ; default filename
    if (n_elements(filename) eq 0) then filename = 'station.codes'
    filemask = filename
 
    ; return information from common block if file already read 
    if (n_elements(stationdata) gt 0) then begin
       stations = stationdata
       return
    endif
 
 
    ; otherwise open file and read station locations
    open_file,filemask,ilun,filename=filename
 
    if (ilun le 0) then begin
       message,'Unsuccessful opening file '+filename+'!',/Cont
       return
    endif
 
    on_ioerror,read_err
 
    ; define string to read data
    title = ''
    readf,ilun,title
    
    ; test whether file is correct
    test = (strcompress(strupcase(title),/remove_all) eq $
            'CODELATLONALTSTATIONNAME')
 
    if (test eq 0) then begin
       message,filename+' does not contain correct data!',/Cont
       free_lun,ilun
       return
    endif
 
    ; create structure template
    struc = { code:0, lat:-999.0, lon:-999.0, alt:-999.0, name:'' }
 
    ; now get data until EOF
    while not (eof(ilun)) do begin
        readf,ilun,title
        ; get tokens
        tmp = str_sep(strcompress(strtrim(title,2)),' ')
; DEBUG output
; print,tmp,format='(200(A,"<>"),"<")'
        struc.code = fix(tmp[0])
        struc.lat = float(tmp[1])
        struc.lon = float(tmp[2])
        struc.alt = float(tmp[3])
        struc.name = tmp[4]
 
        ; create or append to collecting array
        if (n_elements(info) eq 0) then info = struc $
        else info = [ info, struc ]
 
    endwhile
 
    ; close file
    free_lun,ilun
 
    ; store result in common block and return data
    stationdata = info
    stations = info
 
    ; print a log message
    message,strtrim(n_elements(info),2)+' stations read from '+filename, $
            /INFO
 
    return
 
 
read_err:
    message,!error_state.msg,/Cont
    free_lun,ilun
    return
 
end
 
