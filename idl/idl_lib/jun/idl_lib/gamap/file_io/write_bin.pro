; $Id: write_bin.pro,v 1.2 2008/04/02 15:19:02 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        WRITE_BIN
;
; PURPOSE:
;        Save a 2-D data array into a binary file together with
;        its size info. Use read_bin.pro to read it.;
;
; CATEGORY:
;        File & I/O
;
; CALLING SEQUENCE:
;        WRITE_BIN, data, filename, _EXTRA=e
;
; INPUTS:
;        DATA -> Array to save to binary file format.
;
;        FILENAME -> Name of the output binary file.
;
; KEYWORD PARAMETERS:
;        _EXTRA=e -> Passes extra keywords to OPEN_FILE
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        OPEN_FILE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Use READ_BIN to read the data file.
;
; EXAMPLES:
;        (1)
;        WRITE_BIN, DIST(20,20), 'myfile.bin'
;
;             ; Writes a data array to a binary file.
;
;        (2)
;        WRITE_BIN, DIST(20,20), 'myfile.bin', /SWAP_ENDIAN
;
;             ; Writes a data array to a binary file
;             ; converts to BIG-ENDIAN (i.e. use this if
;             ; you are running IDL on a PC.)
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Now write data as big-endian
;
;-
; Copyright (C) 2007-2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine write_bin"
;-----------------------------------------------------------------------


pro write_bin, data, filename, _EXTRA=e
 
    ; save a 2-D data array into a binary file together with
    ; it's size info. Use read_bin.pro to read it.

    FORWARD_FUNCTION Little_Endian
 
    if (n_elements(data) eq 0) then return
 
    if (size(data,/N_Dimensions) ne 2) then begin
       message,'Data not 2-dimensional!',/Continue
       return
    endif
 
    if (N_elements(filename) eq 0) then $
        filename = '*'
 
    ; Write data as big-endian
    open_file,filename,olun,/WRITE,/F77_UNFORMATTED,_EXTRA=e, $
       title='Choose a filename for output', Swap_Endian=Little_Endian()
 
 
    if (olun le 0) then return
 
 
    ; print dimensions, then write data
    s = size(Data,/Dimensions)
 
    writeu,olun,long(s)
 
    writeu,olun,float(data)
 
    free_lun,olun
 
    return
end
 
