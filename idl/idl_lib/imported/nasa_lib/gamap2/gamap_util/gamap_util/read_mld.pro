; $Id: read_mld.pro,v 1.1.1.1 2007/07/17 20:41:25 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        READ_MLD
;
; PURPOSE:
;        Read Ocean mixed layer depth data as retrieved from 
;        http://www.nodc.noaa.gov/OC5/mixdoc.html and store 
;        them as datainfo records so that they can be displayed 
;        with GAMAP.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation
;
; CALLING SEQUENCE:
;        READ_MLD [,DATA] [,keywords]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        FILENAME -> filename of MLD data
;
;        DATAINFO -> A named variable will return the newly
;             created daatinfo structure.
;
;        MODELINFO, GRIDINFO -> named variables will return 
;             the "model" and grid information for the EP-TOMS
;             data. The grid is a 2-dimensional "generic" grid.
;
; OUTPUTS:
;        DATA -> contains 2D array with mixed layer depth data 
;             (for use without GAMAP).
;
; SUBROUTINES:
;        uses open_file, ctm_type, ctm_grid, ctm_make_datainfo
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        In the call to GAMAP you must use the /NOFILE option.
;
; EXAMPLE:
;        READ_MLD, FILE='~/download/mixed_layer_depth/mld*'
;        GAMAP, /NOFILE, ...
;
; MODIFICATION HISTORY:
;        mgs, 30 Jun 1999: VERSION 1.00 (derived from read_eptoms)
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine read_mld"
;-----------------------------------------------------------------------


pro read_mld,data,filename=filename,datainfo=datainfo,   $
         gridinfo=gridinfo,modelinfo=modelinfo
 
 
 
 
    if (n_elements(filename) eq 0) then  $ 
         filename = '~mgs/download/mixed_layer_depth/mld*'
 
 
    open_file,filename,ilun,title='Read Mixed Layer Depth Data'
 
 
    if (ilun le 0) then return
 
 
    ; file format :
    ; plain ASCII with 360x180 data points, format 10f7.1
 
    on_ioerror,read_err
 
 
    ; skip header (not necessary)
    ; s = ''
    ; for i=0,2 do begin
    ;    readf,ilun,s
    ;    print,s
    ; endfor
 
 
    data = fltarr(360,180)
 
    readf,ilun,data,format='(10f7.1)'
 
    close,ilun
    on_ioerror,null


    ; The data are stored from 0..360, so we need to shift it
    data = [ data[180:359,*], data[0:179,*] ] 

    ; Also convert missing values (continents) from -99 to -0.1
    ind = where(data lt 0.)
    if (ind[0] ge 0) then $
       data[ind] = -0.1
 
    ; create information for use in GAMAP
    read,date,prompt='Enter date as YYMMDD :'
    tau0 = nymd2tau(date)
    modelinfo=ctm_type('generic',res=[1.0,1.0],psurf=1013.25)
    gridinfo = ctm_grid(modelinfo,/no_vert)
    success = ctm_make_datainfo(data,datainfo,model=modelinfo, $
                     grid=gridinfo,tau0=tau0,tau1=tau0+24., $
                     diagn='MLD',tracer=2091,trcname='OCMLD',unit='m')
 
    return
 
read_err:
    print,!error_state.msg
    close,ilun
    return
 
end
 
