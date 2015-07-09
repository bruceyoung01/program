; $Id: format_inp.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        FORMAT_INP
;
; PURPOSE:
;        Display one line of S-type input file for CHEM1D model
;        formatted so that each line contains name, unit, value and
;        scaling factor of 1 species (may help to find errors).
;        
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        FORMAT_INP, FILENAME [ , Keywords ]
;
; INPUTS:
;        FILENAME -> name of the input file
;
; KEYWORD PARAMETERS:
;        OUTFILE -> filename for ASCII file with formatted output
;             (default: FILENAME+'.formatted')
;
;        SKP1, SKP2, DELIM -> parameters for READDATA routine:
;             number of lines to skip before variable names and 
;             delimiter for variable names (defaults: 1, 3, and ' ')
;
;        LINE -> data line to be displayed (default=1)
;
;        SIMPLE -> assume no unit and scale factor line, and print
;             dummies instead. Will be automatically set if SKP2 is 
;             less than 2.
;
; OUTPUTS:
;        Screen output and output to file OUTFILE
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        READDATA
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        FORMAT_inp, 'test.inp', LINE=3
;
;        will display the third line of a chem1d input file test.inp in a
;        format similar to:
;               NAME         UNIT       VALUE       SCALE
;          O3_COLUMN           DU     227.330   2.687e+16
;        DECLINATION          deg      -1.634   1.000e+00
;               PSMB           mb     238.434   1.000e+00
;    ...
;
; MODIFICATION HISTORY:
;        mgs, 18 Dec 1997: VERSION 1.00
;        mgs, 11 Jun 1998: - added SIMPLE and SKP2 keyword
;        mgs, 30 Oct 1998: - bug fix with units and scale
;                          - improved formatting for large numbers
;                            (allows display of chem1d output files)
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments
;
;-
; Copyright (C) 1997-2007, Martin Schultz 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine format_inp"
;-----------------------------------------------------------------------


pro format_inp,filename,outfile=outfile,skp1=skp1,skp2=skp2, $
           delim=delim,line=line,simple=simple
 
    if (n_elements(filename) le 0) then $
          message,'FILENAME required as argument.'
 
    if (n_elements(outfile) le 0) then outfile=filename+'.formatted'
 
    if (n_elements(skp1) le 0) then skp1 = 1
    if (n_elements(skp2) le 0) then skp2 = 3
    if (skp2 lt 2) then simple=1
    if (n_elements(delim) le 0) then delim = ' '
 
    if (n_elements(line) le 0) then line = 0 else line = line-1
    ; 1 should denote the first data line
 
 
    readdata,filename,data,header,skp1=skp1,skp2=skp2,delim=delim, $
             comments=comments,lines=line+1
 
 
    if (keyword_set(simple)) then begin 
       units = replicate(' ',n_elements(header))
       scale = fltarr(n_elements(header)) + 1.
    endif else begin
       units = extract_comments(comments,skp1+1)
       scale = extract_comments(comments,skp1+2)
    endelse

    logoutput = 1
    on_ioerror,no_log 
    openw,ilun,outfile,/get_lun
so_what:
    on_ioerror,null
 
    print,'NAME','UNIT','VALUE','SCALE',format='(A20,1X,4A12)'
    if (logoutput) then $
      printf,ilun,'NAME','UNIT','VALUE','SCALE',format='(A20,1X,4A12)'
 
    for i=0,n_elements(header)-1 do begin
         numf = 'f12.3'
         if (abs(data[i,line]) gt 1.0E6 OR abs(data[i,line]) lt 1.0E-4) then $
             numf = 'e12.4'
         print,header(i),units(i),data(i,line),scale(i),  $
              format='(A20,1X,A12,'+numf+',e12.3)'

       if (logoutput) then $ 
         printf,ilun,header(i),units(i),data(i,line),scale(i),  $
              format='(A20,1X,A12,'+numf+',e12.3)'
    endfor

    if (logoutput) then begin 
      close,ilun
      free_lun,ilun
    endif

    return
 
no_log:
    logoutput = 0
    goto,so_what
 
return
end
 
