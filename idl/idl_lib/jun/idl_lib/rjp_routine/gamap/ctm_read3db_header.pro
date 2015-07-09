; $Id: ctm_read3db_header.pro,v 1.3 2005/03/24 18:03:11 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_READ3DB_HEADER
;
; PURPOSE:
;        retrieve header information and file positions of data
;        blocks from binary global 3D model output. This is a
;        twin of CTM_READ3DP_HEADER which digests the header
;        information from ASCII punch files.
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        test = CTM_READ3DB_HEADER(LUN,FILEINFO,DATAINFO [,keywords])
;
; INPUTS:
;        LUN --> logical file unit of the binary punch file. The file 
;             must be open (see CTM_OPEN_FILE or OPEN_FILE)
;
;        FILEINFO --> a (single) fileinfo structure containing information
;             about the (open) file (see CREATE3DFSTRU). FILEINFO also
;             contains information about the model which generated
;             the output (see CTM_TYPE)
;
;        DATAINFO --> a named variable that will contain an array of
;             structures describing the file content (see
;             CREATE3DHSTRU)
;
; KEYWORD PARAMETERS:
;        PRINT  -> if activated, print all headers found in the file
;
; OUTPUTS:
;        The function returns 1 if successful, and 0 otherwise. 
;
;        FILEINFO --> toptitle and modelinfo tags will be set
;
;        DATAINFO --> contains an array of named structures 
;             (see CREATE3DHSTRU) with all relevant information
;             from the punch file header and what is needed to find
;             and load the data.
;              
; SUBROUTINES:
;
; REQUIREMENTS:
;        uses CREATE3DHSTRU function to create header structure
;        uses CHKSTRU to test FILEINFO structure
;        uses CTM_TYPE to create modelinfo structure
;        needs gamap_cmn.pro to access global common block
;
; NOTES:
;        This routine uses the new binary file format introduced
;        first to the GEOS/Harvard CTM.
;
; EXAMPLE:
;              fileinfo = create3dfstru()   ; not required !
;              fname = '~bmy/terra/CTM4/results/ctm.bpch'
;              open_file,fname,ilun,/F77_UNFORMATTED   ; <=== !!
;              if (ilun gt 0) then $
;                 result = CTM_READ3DB_HEADER(ilun,fileinfo,datainfo)
;              print,result
;
;        To get e.g. all scaling factors, type 
;              print,datainfo[*].scale
;
;        To retrieve the header structure for one data block, type
;              blocki = datainfo[i]
;
; MODIFICATION HISTORY:
;        mgs, 15 Aug 1998: VERSION 1.00
;                          - derived from CTM_READ3DP_HEADER
;        mgs, 21 Sep 1998: - changed gamap.cmn to gamap_cmn.pro
;        mgs, 14 Jan 1999: - now expects diag category name instead 
;                            of number
;        bmy, 11 Feb 1999: - change TAU0, TAU1 to double-precision,
;                            in accordance w/ new binary file format
;                          - clean up some POINT_LUN calls
;        bmy, 22 Feb 1999: VERSION 1.01
;                          - now store I0, J0, L0 from binary file
;                            in new FIRST field from CREATE3DHSTRU
;                          - comment out assignment statement for
;                            SKIP; now use value from binary file
;        mgs, 16 Mar 1999: - cosmetic changes
;        mgs, 24 May 1999: - now supports 'CTM bin 02' files
;                          - added a filetype check
;                          - now defaults to 512 records (former 4096)
;        mgs, 27 May 1999: - fixed bug with new record default: new
;                            records were never added as they were 
;                            supposed to.
;        bmy, 26 Jul 1999: - also print out SKIP field in debug output
;        bmy, 10 Jul 2003: GAMAP VERSION 1.53
;                          - added kludge so that GEOS-3 reduced grid
;                            w/ 30 layers will be added to FILEINFO
;                            correctly
;        bmy, 21 Nov 2003: GAMAP VERSION 2.01
;                          - BPCH file v1 now has FILETYPE=101
;                          - BPCH file v2 now has FILETYPE=102
;                          - Now define separate DATAINFO.FORMAT values
;                            for BPCH v1 and BPCH v2 type files   
;                          - removed kludge for GEOS3_30L, since the
;                            bug in CTM_TYPE has now been fixed
;        bmy, 24 Aug 2004: GAMAP VERSION 2.03
;                          - now assign FORMAT string for Filetype 105
;                            which is BPCH file for GEOS-CHEM station
;                            timeseries (e.g. ND48 diagnostic)
;
;-
; Copyright (C) 1998, 1999, 2003, 2004, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine CTM_READ3DB_HEADER"
;-------------------------------------------------------------



function CTM_READ3DB_HEADER,ilun,fileinfo,datainfo,  $
              print=pprint


    FORWARD_FUNCTION chkstru, ctm_type, create3dhstru

; if we ever need to include global common block ...
; @gamap_cmn.pro

    ; initialize return variables
    datainfo = -1

    pprint = keyword_set(pprint)
;  pprint=1


    ; ======================================== 
    ; retrieve punch file name
    ; ======================================== 

    if (chkstru(fileinfo,'filename'))          $
       then thisfilename = fileinfo.filename   $
       else thisfilename = '<UNKNOWN FILE>'

    ; === check filetype ===
    if (chkstru(fileinfo,'filetype'))      $
       then filetype = fileinfo.filetype   $
       else filetype = 999  ; unknown -- will default to 2

    if (keyword_set(PPrint)) then begin
       print,'Reading header from ',thisfilename,', filetype ',filetype
    endif

    if ( filetype lt 100 OR filetype gt 200 ) then begin
       message,'WARNING!! Filetype does not indicate binary file!'+ $
            ' Will try new format...', /INFO
       filetype = 102
    endif

    ; ========================================  
    ; read general file information
    ; (reset file pointer to 0 and re-read 
    ; file type identifier)
    ; ========================================  

    fti       = bytarr(40)
    toptitle  = bytarr(80)

    on_ioerror,readerr
    point_lun,ilun,0L
    readu,ilun,fti 
    if (keyword_set(pprint)) then  print,'>> ',string(fti)
    readu,ilun,toptitle
    if (keyword_set(pprint)) then  print,'Title:',string(toptitle)


    ; === for old binary files: read modelname and resolution,
    ;      set defaults for halfpolar and center180
    ; === new binary files have this info along with each record.
    if ( filetype eq 101 ) then begin
       modelname = bytarr(20)
       modelres  = fltarr(2)
       readu,ilun,modelname,modelres
       if (keyword_set(pprint)) then $
         print,'Model and resolution: ',string(modelname),modelres
    
       ; get model type structure and extract halfpolar and center180 flags
       modelname = strtrim(modelname,2)
       modelinfo = ctm_type(string(modelname),resolution=modelres)
       mhalfpolar = modelinfo.halfpolar
       mcenter180 = modelinfo.center180
    endif


    ; ========================================  
    ; initialize the datainfo structure array
    ; ========================================  
 
    MAXENTRIES = 512            ; reduced from 4096, 05/24/99, mgs
    struc = create3dhstru(MAXENTRIES)
    Nel = MAXENTRIES

    ; ... and a line counter
    count = -1L     ; line counter


    ; get file size and current file position
    fsize  = (fstat(ilun)).size
    point_lun,-ilun,newpos


    ; ========================================  
    ; read in header information of each data
    ; block
    ; ========================================  
   
    while (newpos lt fsize-1) do begin

       diagc = bytarr(40)
       tracer = 0L
       unit = bytarr(40)
       tau0 = 0.D
       tau1 = 0.D
       reserved = bytarr(40)
       dim = lonarr(6)
       skip = 0L

       ; new records for modelinfo only in new binary format!
       if ( filetype ne 101 ) then begin
          modelname = bytarr(20)
          modelres  = fltarr(2)
          mhalfpolar = -1L 
          mcenter180 = -1L 
       endif

       on_ioerror,headererr
       point_lun,ilun,newpos    ; set file pointer to next header line


       ; === old format ===
       if ( filetype eq 101 ) then begin
          readu, ilun, diagc, tracer, tau0, tau1, skip
          readu,ilun,dim
       endif else begin
       ; === new format ===
          readu,ilun,modelname,modelres,mhalfpolar,mcenter180

          if (pprint) then $
             print,strtrim(modelname,2),modelres,mhalfpolar,mcenter180, $
             format='(A,2f8.2,2I4)'

          readu,ilun,diagc,tracer,unit,tau0,tau1,reserved,dim,skip

          if (pprint) then $
             print,strtrim(diagc,2),tracer,strtrim(unit,2),tau0,tau1, $
             format='(A,I6,A,2F9.2)'
       endelse

       modelname = strtrim(modelname,2)
       diagc = strtrim(diagc,2)
       unit  = strtrim(unit ,2)

       ; FILEPOS pointer now points to beginning of data block
       ; add skip to get to next header
       point_lun,-ilun,filepos
       
       ; NEWPOS pointer now points to the first header 
       ; line of the next data block
       newpos = filepos + skip

;### note: SKIP value is determined in CTM as follows:
;### skip = 4L * ( dim[0]*dim[1]*dim[2] ) + 8L    ( 8 is for EOL in fortran )

       count = count + 1L

       ; *** TEMPORARY SOLUTION: modelinfo still stored in
       ; *** fileinfo structure instead of datainfo!!
       ; *** only do it for first record

       if (count eq 0) then begin
          ; get model information and enter in fileinfo structure
          modelinfo = ctm_type(modelname,resolution=modelres,  $
                         halfpolar=mhalfpolar,center180=mcenter180)

          if (chkstru(fileinfo,'MODELINFO')) then $
              fileinfo.modelinfo = modelinfo
       endif


       ; sort information into datainfo structure
       struc(count).ilun     = ilun
       struc(count).filepos  = filepos
       struc(count).category = diagc
       struc(count).tracer   = fix(tracer)
       struc(count).tau0     = tau0
       struc(count).tau1     = tau1
       struc(count).unit     = unit
       struc(count).dim      = [ fix(dim[0:2]), 0 ]
       struc(count).first    = [ fix(dim[3:5]) ] 

       ; Now define format types for BPCH v1 and BPCH v2 files (bmy, 11/21/03)
       case ( FileType ) of 
          101  : Struc(Count).Format = 'BINARY PUNCH v1.0'   
          102  : Struc(Count).Format = 'BINARY PUNCH v2.0'   
          105  : Struc(Count).Format = 'BINARY PUNCH v2.0: GEOS-CHEM stations'
          else : Struc(Count).Format = 'BINARY'
       endcase

       if (keyword_set(PPRINT)) then begin
          print,'       category : ',diagc
          print,'         tracer : ',tracer
          print,'           unit : ',unit
          print,' time (from,to) : ',tau0,tau1
          print,'     dimensions : ',dim[0:2]
          print,'  first indices : ',dim[3:5]
          print,'           skip : ',skip
          print,'         newpos : ',newpos
       endif


next_header:
    ; check if MAXENTRIES is exceeded, if so, create another structure 
    ; array and concatenate
    if (count ge NEl-1L) then begin 
       tmpstru = create3dhstru(MAXENTRIES)
       struc = [ temporary(struc), tmpstru ]
       NEl = NEl + MAXENTRIES
    endif

    endwhile   ; (end of file)


end_of_file:
    ; ========================================  
    ; prepare information to be returned
    ; ========================================  

    ; if count is less than 0, nothing was read in
    if (count lt 0) then begin
        dum = dialog_message(['No information read from file', $
                    thisfilename+'!'] )
        free_lun,ilun
        return,0
    endif


 
    ; enter toptitle in fileinfo structure
    if (chkstru(fileinfo,'TOPTITLE')) then $
        fileinfo.toptitle = string(toptitle)
 
    ; truncate struc array and pass it as datainfo 
    datainfo = struc(0:count)
;----------------------------------------------------------------
; Prior to 1/4/03:
; Comment this out for now 
;    message,strtrim(count+1,2)+' records read from file '+  $ 
;             fileinfo[0].filename,/INFO 
;----------------------------------------------------------------
   
    return,1   ; successful !


    ; ========================================  
    ; error messages for IO errors
    ; ========================================  

; error while reading data from the file
readerr:
    dum = dialog_message(['Error ('+strtrim(!ERR,2)+  $
              ') reading file ',             $
              thisfilename, $
              ' in block '+strtrim(count,2), $
              strcompress(!ERR_STRING) ], $
              /ERROR )

    ; for error -221 (unexpected end of file) return what we got
    if (!ERR eq -221 AND count ge 0) then goto,end_of_file

    ; otherwise close file and return as unsuccessful
    free_lun,ilun
    return,0

; error while parsing a header line
headererr:

    ; print error and exit
    print,'Error occured while reading header information ...'
    goto,readerr
 
end
 
 
 
