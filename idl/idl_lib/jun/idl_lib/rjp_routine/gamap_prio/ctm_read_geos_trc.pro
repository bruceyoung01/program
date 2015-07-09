; $Id: ctm_read_geos_trc.pro,v 1.50 2002/05/24 14:03:52 bmy v150 $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_READ_GEOS_TRC  (function)
;
; PURPOSE:
;        Read a GEOS_CTM restart file and store the information
;        in a GAMAP compatible format as DATAINFO structure array.
;
; CATEGORY:
;        GAMAP routines
;
; CALLING SEQUENCE:
;        CTM_READ_GEOS_TRC
;
; INPUTS:
;        ILUN  --> logical unit number for restart file. The file
;            must have been opened as F77_UNFORMATTED
;
;        FILEINFO --> A fileinfo structure describing the file.
;            This structure will contain a valid modelinfo field
;            after successful reading
;
; KEYWORD PARAMETERS:
;        DUMMY  --> just for syntactical reasons. There may be some
;            future keywords when needed.
;
; OUTPUTS:
;        DATAINFO --> An array of N datainfo structures which contain
;            information about the individal data records and the data
;            themselves.
;
;        The function returns 1 if successful, 0 otherwise.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses CREATE3DHSTRU
;
; NOTES:
;        This function is designed for the GAMAP package. For
;        simple reading of a restart file "with no fuss", use
;        procedure CTM_RDTRC
;
; EXAMPLE:
;        thisfileinfo = create3dfstru()
;        ; ... enter reasonable values in thisfileinfo
;        result = CTM_READ_GEOS_TRC(ilun,thisfileinfo,thisdatainfo)
;
; MODIFICATION HISTORY:
;        mgs, 05 Oct 1998: VERSION 1.00
;        mgs, 13 Nov 1998: - bug fix to extract filename
;                          - improved error message
;        bmy, 11 Feb 1999: VERSION 1.01
;                          - now store I0, J0, L0 offsets in DATAINFO
;                          - DATAINFO.TAU0, DATAINFO.TAU1 are now
;                            double-precision instead of longwords
;        bmy, 17 Feb 1999: VERSION 1.02
;                          - changed to accommodate the FIRST field
;                            of the DATAINFO structure, which contains
;                            the I, J, L indices of the first grid box
;-
; Copyright (C) 1998, 1999, Martin Schultz and Bob Yantosca,
; Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_read_geos_trc"
;-------------------------------------------------------------


function ctm_read_geos_trc,ilun,fileinfo,datainfo,DUMMY=dummy
 
    ; dummy keyword just to prevent complaints 
    ; useful keywords may be e.g. a tracer list
 
    FORWARD_FUNCTION create3dhstru

    ; file is already open - little safety check anyway
    if (ilun le 0) then return,0

    ; extract filename
    if (n_elements(fileinfo) eq 0) then begin
       message,'Empty FILEINFO passed!',/Continue
       return,0
    endif
    filename = fileinfo.filename

    on_ioerror,io_errcond
 
    ; reset file pointer to start of file
    point_lun,ilun,0L
 
    ; read title line
    title = bytarr(59)
    readu,ilun,title
 
    ; read dimensional information
    ; initialize values to ensure proper reading
    i1 = 0L
    i2 = 0L
    j1 = 0L
    j2 = 0L
    l1 = 0L
    l2 = 0L
    n1 = 0L
    n2 = 0L
    lNYMDb = 0L
    lNHMSb = 0L
    lNYMDe = 0L
    lNHMSe = 0L
 
    lTAUI4 = 0.0
    lTAUE4 = 0.0
    lIRES = 0L 
    lNYMD = 0L 
    lNHMS = 0L 
    lNTAU = 0L 
 
 
    readu,ilun,i1,i2,j1,j2,l1,l2,n1,n2
    readu,ilun,lNYMDb,lNHMSb,lNYMDe,lNHMSe
    readu,ilun,lTAUI4,lTAUE4,LIRES
    readu,ilun,lNYMD,lNHMS,lNTAU
 
 
    ; dimension the data array based on Imin, Imax, etc...
    dim  = [ i2-i1+1, j2-j1+1, l2-l1+1, n2-n1+1 ]
 
    data = make_array(dim[0],dim[1],dim[2],dim[3],/float)

    ; Get position of file pointer and calculate data block size
    ; *** UNFORTUNATELY WE CANNOT USE THIS METHOD BECAUSE IDL 
    ; *** READU DETECTS A 'corrupted f77 file' WHEN WE TRY TO
    ; *** ACCESS ANY TRACER BUT THE FIRST!
    point_lun,-ilun,pos
    blocksize = dim[0]*dim[1]*dim[2] * 4L 
 
    ; *** WE HAVE TO READ THE COMPLETE DATA SET HERE!
    readu,ilun,data

    ; Create an array of datainfo structures and split data
    ; into individual tracers
    datainfo = create3dhstru(n2-n1+1)
 
    for i=0,n2-n1 do begin
       datainfo[i].ilun = fileinfo.ilun
       datainfo[i].filepos = -1L ; pos+i*blocksize  ; -1L
       datainfo[i].category = 'IJ-INS-$'
       datainfo[i].tracer = n1+i
       ; skip tracername for now
; Save DATAINFO.TAU0 and DATAINFO.TAU1 as double precision (bmy, 2/11/99)
       datainfo[i].tau0 = Double( lTAUI4 )
       datainfo[i].tau1 = Double( lTAUE4 )
       datainfo[i].scale = 1.0
       datainfo[i].unit = 'v/v'
       datainfo[i].status = 1   ; read
       datainfo[i].format = 'BINARY TRACER FILE'
       datainfo[i].dim = [ dim[0:2], 0 ]
       datainfo[i].First = [ I1, J1, L1 ]
       datainfo[i].data = ptr_new(reform(data[*,*,*,i]))
    endfor
 
 
    return,1
 
 
io_errcond:
 
    if (ilun gt 0) then free_lun,ilun
    savemsg = strtrim(!error_state.code,2)+':'+!error_state.msg
    message,'*** Error reading file ***',/Continue
    message,savemsg,/INFO,/NONAME
 
    return,0
end
 
 
    
