; $Id: ctm_read_data.pro,v 1.2 2004/01/29 19:33:37 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_READ_DATA
;
; PURPOSE:
;        read in one data block from a global model punch file output
;        (ASCII or binary)
;
; CATEGORY:
;        file routines
;
; CALLING SEQUENCE:
;        CTM_READ_DATA,data,datainfo
;        or:
;        CTM_READ_DATA,data,ilun,filepos,xsize,ysize[,zsize,keywords]
;
; INPUTS:
;        DATAINFO -> a datainfo structure as retrieved from
;             CTM_OPEN_FILE. This is the easiest way to read 3D
;             model output. Alternatively, the individual parameters
;             can be specified as follows.
;             
;        ILUN  -> logical file unit of input file (must be opened before)
;        FILEPOS -> a long word containing the start position of the data
;             block to be read (normally retrieved by CTM_OPEN_FILE)
;        XSIZE -> 1st dimension of the data array
;        YSIZE -> 2nd dimension of the data array
;        ZSIZE -> optional 3rd dimension of the data array
;
; KEYWORD PARAMETERS:
;        Note: These keywords are ineffective when parameters are passed
;        via the DATAINFO structure!
;
;        SCALE -> apply scaling factor to data (default = 1.0)
;
;        FORMAT -> string with format identifier for data block
;             Default is '(12f6.2)'. Use '(8e10.3)' for BUDGETS output and
;             '(12(f6.2,1x))' for "extra_space" output. Format='BINARY'
;             indicates a binary file with REAL*4 data. (As long as the
;             dimensions are specified correctly ANY binary file can
;             be read this way, i.e. there is no need for additional 
;             routines to read in e.g. gridded emission data files)
;
;        RESULT -> will return 1 if successful, 0 otherwise
;
; OUTPUTS:
;        DATA  -> a float array containing the block of data which is 
;             either a 2D or a 3D array.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        file must have been opened and file positions of the data block
;        must be known (see CTM_OPEN_FILE)
;
; NOTES:
;        The data array is *not* added to the datainfo structure! 
;
; EXAMPLE:
;        ; Open a punch file interactively
;        CTM_OPEN_FILE,'',fileinfo,datainfo
;
;        ; Test if successful
;        IF (not chkstru(datainfo)) then return
;
;        ; Read in data of first data block
;        CTM_READ_DATA,data,datainfo[0]
;
;        ; This is equivalent to:
;        CTM_READ_DATA,data,fileinfo.ilun,datainfo[0].filepos, $
;             datainfo[0].dim[0],datainfo[0].dim[1],datainfo[0].dim[2], $
;             scale=datainfo[0].scale,format=datainfo[0].format
;
; MODIFICATION HISTORY:
;        mgs, 13 Aug 1998: VERSION 1.00 (from CTM_READ3DP_DATA)
;                          - replaced EFORMAT keyword by more flexible 
;                            FORMAT keyword (involves changes in 
;                            CTM_READ3DP_HEADER and CREATE_3DHSTRU)
;        mgs, 17 Aug 1998: VERSION 2.00
;                          - now possible to pass DATAINFO structure
;                          - made it necessary to place DATA argument 
;                            as first parameter
;        mgs, 19 Aug 1998: - added RESULT keyword
;        mgs, 26 Oct 1998: - changed print statements to message
;                          - user is now prompted when dimensions 
;                            are not given
;        bmy, 07 Apr 2000: - Added DAO keyword for reading in DAO met fields
;        bmy, 11 Apr 2001: - now uses DATA = TEMPORARY( DATA ) * SCALE[0]
;                            in order to prevent excess memory usage
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - Removed GMAO keyword, we now use the
;                            FORMAT string to test for GMAO data files
;
;-
; Copyright (C) 1997, 1998, 2000, 2003, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_read_data"
;-------------------------------------------------------------


pro ctm_read_data,data,param1,filepos,xsize,ysize,zsize,  $
            scale=scale,format=format,result=result
 
    on_error,2    ; return to caller

    result = 0


    ; Need at least two parameters. If not more, test if second
    ; parameter is DATAINFO structure. Otherwise need at least
    ; five parameters. 

    if(n_params() lt 2) then return  


    if(n_params() eq 2) then begin
        if (not chkstru(param1,['ILUN','FILEPOS', $
                  'DIM','SCALE','FORMAT'])) then begin
           message,'Not a valid datainfo structure',/Cont
           return
        endif

        ; extract information
        ilun = param1.ilun
        filepos = param1.filepos
        xsize = param1.dim[0]
        ysize = param1.dim[1]
        zsize = param1.dim[2]
        scale = param1.scale
        format = param1.format
        
    endif  else begin          ; scan single parameters 

        if(n_params() lt 5) then return   ; need all relevant information

        ilun = param1   ; first parameter now logical unit number
        if (n_elements(zsize) eq 0) then zsize = 0
        if (n_elements(scale) eq 0) then scale = 1.0
        ; set standard ASCII format if not provided
        if (n_elements(format) eq 0) then format = '(12f6.2)'
    endelse
   
     
 
    if(filepos le 0) then return      ; invalid file pointer
 

    ; make sure data has at least one dimension of ge 1
    if (xsize > ysize > zsize le 0) then begin
       message,'Data file did not contain dimensions!',/Cont

       ; Interactive determination
       xin = '' 
       if (chkstru(param1,'CATEGORY')) then dname = param1.category $
       else dname = 'UNKNOWN'

       message,'Please enter X, Y, Z for diagnostics ' + $
               dname + ' (Hit ENTER for 72x46)',/Cont,/NoName
       read,xin,prompt='GAMAP>'

       on_ioerror,invalid_entry
       reads,xin,xsize
       reads,xin,xsize,ysize
       on_ioerror,entry_ok
       reads,xin,xsize,ysize,zsize
invalid_entry:
       print,'72  46   1'
       xsize = 72
       ysize = 46
entry_ok:
       on_ioerror,NULL
    endif

    ; create data array as 2D or 3D
    if (zsize gt 1) then $
        data = fltarr(xsize,ysize,zsize)  $
    else   $
        data = fltarr(xsize,ysize)


    ; read data block either formatted or unformatted
    on_ioerror,readerr 
    point_lun,ilun,filepos    ; set file pointer

    ;---------------------------------------------------------------------
    ; Prior to 11/20/03:
    ;if ( StrPos( Format, 'BINARY' ) ge 0 ) then begin
    ;
    ;   ; FIX for DAO fields -- the data block is preceded by 2 REAL*4 
    ;   ; variables...so we have to read those in first. (bmy, 4/7/00)
    ;   if ( Keyword_Set( GMAO ) ) then begin
    ;      Tmp1 = 0.0
    ;      Tmp2 = 0.0
    ;      ReadU, Ilun, Tmp1, Tmp2, Data  
    ;
    ;   ; for binary data that are NOT DAO met fields          
    ;   endif else begin
    ;      readu,ilun,data  
    ;
    ;   endelse
    ;
    ;; For formatted ASCII data
    ;endif else begin
    ;   readf,ilun,data,format=format  
    ;
    ;endelse
    ;--------------------------------------------------------------------

    ; Test for BINARY or ASCII
    if ( StrPos( Format, 'BINARY' ) ge 0 ) then begin

       ; Binary data types
       if ( StrPos( Format, 'GMAO' ) ge 0 ) then begin

          ;-------------------
          ; GMAO Binary Data
          ;-------------------         
          Tmp1 = 0.0
          Tmp2 = 0.0
          ReadU, Ilun, Tmp1, Tmp2, Data  

       endif else begin

          ;-------------------
          ; Other binary data
          ;-------------------
          ReadU, Ilun, Data 
       endelse

    endif else begin
       
       ;----------------------
       ; Formatted ASCII data
       ;----------------------
       Readf, Ilun, Data, Format=Format  
    
    endelse

    ; scale data
    data = Temporary( data ) * scale[0]

    ; indicates successful reading
    result = 1   
 
    return

readerr:
    message,!error_state.msg,/Cont
    return
end
 
 
