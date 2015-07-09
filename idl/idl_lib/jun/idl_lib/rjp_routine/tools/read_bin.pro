;-------------------------------------------------------------
; $Id: read_bin.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;+
; NAME:
;        READ_BIN  and  PLOT_BIN
;
; PURPOSE:
;        Read a simple binary 2-D file. The file must be F77 
;        unformatted and contain the XDIM and YDIM information
;        as LONG integers in the first record.
;
; CATEGORY:
;        File I/O
;
; CALLING SEQUENCE:
;        READ_BIN,FILENAME,DATA [,keywords]
;        PLOT_BIN,DATA [,keywords]
;
; INPUTS:
;        FILENAME -> Name of the file to read
;
;        DATA (for PLOT_BIN) -> The data array as read with READ_BIN 
;
; KEYWORD PARAMETERS:
;        XDIM, YDIM -> return the dimensions of the data set.
;
;        _EXTRA -> used to pass extra keywords to OPEN_FILE. Probably
;              only useful with /SWAP_ENDIAN.
;
;        /PLOT -> Call PLOT_BIN directly.
;
;        (for PLOT_BIN)
;        MIN, MAX -> minimum and maximum to be used for conversion of
;              data to a byte array for display with TVIMAGE
;
;        TOP -> top value for BYTSCL
;
;        CT -> colortable numebr to use
;
;        /MAP -> set this keyword to overlay a map (isotropic cylindrical
;              projection)
;
; OUTPUTS:
;        DATA -> The data array returned from READ_BIN
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses OPEN_FILE and TVIMAGE
;
; NOTES:
;        Rather primitive program but demonstrates the principle use
;        of binary data files and TVIMAGE.
;
; EXAMPLE:
;        READ_BIN,'~/mydata/*.bdat',data
;        PLOT_BIN,data,min=min(data,max=m),max=m
;
;        ; is equivalent to 
;        READ_BIN,'~/mydata/*.bdat',dat,/PLOT
;
; MODIFICATION HISTORY:
;        mgs, 15 Jan 1999: VERSION 1.00
;        mgs, 15 Jun 1999: - added header
;                          - added PLOT keyword and _EXTRA
;
;-
; Copyright (C) 1999, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine read_bin"
;-------------------------------------------------------------


pro plot_bin,data,min=min,max=max,top=top,ct=ct,map=map
 
    ; create a simple tvimage plot from binary 2D array
 
    if (n_elements(min) eq 0) then min = min(data)
    if (n_elements(max) eq 0) then max = max(data)
    if (n_elements(top) eq 0) then top = !D.N_COLORS-2
    if (n_elements(ct) eq 0) then ct = 2
 
 
    im = bytscl(data,min=min,max=max,top=top)
    erase
    loadct,ct
    p=[0.02,0.02,.98,.98]
    tvimage,im,/keep_aspect,pos=p
 
    if (keyword_set(map)) then begin
       map_set,0,0,position=p,color=top+1,/noborder,/continents,/noerase
    endif
end
 
 
 
pro read_bin,filename,data,xdim=xdim,ydim=ydim,PLOT=DO_PLOT,_EXTRA=e
 
 
    ; read a simple binary (F77) data file that has dimensions stored
    ; as first 2 values, then the data
 
    xdim = 0L
    ydim = 0L
 
    open_file,filename,ilun,/f77_unformatted,_EXTRA=e
 
    if (ilun le 0) then return
 
    readu,ilun,xdim,ydim
 
    data = fltarr(xdim,ydim)
    readu,ilun,data
 
    free_lun,ilun

    if (keyword_set(DO_PLOT)) then $
       PLOT_BIN,data      


    return
end
 
