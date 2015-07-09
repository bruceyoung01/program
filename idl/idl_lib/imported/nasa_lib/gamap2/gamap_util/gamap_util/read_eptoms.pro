; $Id: read_eptoms.pro,v 1.1.1.1 2007/07/17 20:41:25 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        READ_EPTOMS
;
; PURPOSE:
;        Read Earth Probe TOMS data as retrieved from 
;        http://jwocky.gsfc.nasa.gov and store them as datainfo
;        records so that they can be displayed with GAMAP.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation
;
; CALLING SEQUENCE:
;        READ_EPTOMS [,DATA] [,keywords]
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;        FILENAME -> filename of TOMS data
;
;        DATAINFO -> A named variable will return the newly
;             created daatinfo structure.
;
;        MODELINFO, GRIDINFO -> named variables will return 
;             the "model" and grid information for the EP-TOMS
;             data. The grid is a 2-dimensional "generic" grid.
;
; OUTPUTS:
;        DATA -> contains 2D array with EP-TOMS data (for use without
;             GAMAP).
;
; SUBROUTINES:
;        uses open_file, ctm_type, ctm_grid, ctm_make_datainfo
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        For tropical ozone in March, I used the following options
;        in the call to GAMAP:
;           myct,27,ncol=32,bot=20,range=[0.15,0.8]
;           c_lev = [150,200,220,230,240,250,260,270,280,  $
;                    290,300,310,320,330,340,350,375,400]
;           gamap,/nofile,c_lev=c_lev,c_col=[0,17,2*indgen(21)+18],  $
;                    /cbar,mlinethick=2,ncolors=32,bottom=18,  $
;                    cbmin=220,cbmax=400,div=10  [,frame0=4]
;           
;           (the frame0 keyword is used to save GIF files)
;
; EXAMPLE:
;        read_eptoms,file='/data/pem-tb/satellite/eptoms/*.ept'
;        gamap [... options]
;
; MODIFICATION HISTORY:
;        mgs, 02 Apr 1999: VERSION 1.00
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
; or phs@io.harvard.edu with subject "IDL routine read_eptoms"
;-----------------------------------------------------------------------


pro read_eptoms,data,filename=filename,datainfo=datainfo,   $
         gridinfo=gridinfo,modelinfo=modelinfo
 
 
 
 
    if (n_elements(filename) eq 0) then  $ 
         filename = '/data/gte/pem-tb/satellite/ep-toms/*'
 
 
    open_file,filename,ilun,title='Read Earth Probe TOMS data'
 
 
    if (ilun le 0) then return
 
 
    ; file format :
    ; skip 3 lines (may later extract date)
    ; 180 lat bands with 288 entries each.
    ; 11 lines 25i3, 1 line 13i3,a
 
    on_ioerror,read_err
 
 
    s = ''
    for i=0,2 do begin
       readf,ilun,s
       print,s
    endfor
 
 
    data = fltarr(288,180)
    dataline = intarr(288)
 
    for i=0,179 do begin
       readf,ilun,dataline,format='(1x,25i3)'
       data[*,i] = float(dataline)
    endfor
 
    close,ilun
    on_ioerror,null
 
 
    ; create information for use in GAMAP
    read,date,prompt='Enter date as YYMMDD :'
    tau0 = nymd2tau(date)
    modelinfo=ctm_type('generic',res=[1.25,1.0],psurf=1013.25)
    gridinfo = ctm_grid(modelinfo,/no_vert)
    success = ctm_make_datainfo(data,datainfo,model=modelinfo, $
                     grid=gridinfo,tau0=tau0,tau1=tau0+24., $
                     diagn='TOMS',tracer=399,trcname='O3COL',unit='DU')
 
    return
 
read_err:
    print,!error_state.msg
    close,ilun
    return
 
 
