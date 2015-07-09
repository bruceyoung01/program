; $Id: ctm_read3dp_header.pro,v 1.1.1.1 2007/07/17 20:41:47 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ3DP_HEADER
;
; PURPOSE:
;        retrieve header information and file positions of data
;        blocks from global 3D model punch file output.
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        test = CTM_READ3DP_HEADER(LUN,FILEINFO,DATAINFO [,keywords])
;
; INPUTS:
;        LUN --> logical file unit of the punch file. The file
;             must be open (see CTM_OPEN_FILE or OPEN_FILE)
;
;        FILEINFO --> a (single) fileinfo structure containing information
;             about the (open) file (see CREATE3DFSTRU). FILEINFO also
;             contains information about the model that generated the
;             data, which is queried interactively.
;
;        DATAINFO --> a named variable that will contain an array of
;             structures describing the file content (see
;             CREATE3DHSTRU)
;
; KEYWORD PARAMETERS:
;        /NO_TOPTITLE --> do not interprete first line of file as
;             header line. Only one header line will be skipped
;             (as normally only one header line is read in).
;
;        /EXTRA_SPACE -> digests output from GISS_II_PRIME model with
;             extra spaces in the punch file. This keyword is optional
;             in the following sense: If CTM_READ3DP_HEADER detects
;             an error reading a header line, it is called again
;             automatically with this option set.
;
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
;        uses CTM_TYPE to set modelinfo
;        needs gamap_cmn.pro to set default in query for model type
;
; NOTES:
;        This routine does rely on the output format from the global GCM
;        as specified first for the GEOS/Harvard CTM. However, it is
;        designed to digest the output from all models currently used
;        in DJJ's group.
;        It uses the NL parameter to skip blocks between headers.
;
;        The window offsets (I0, J0, L0) are set to
;        zero, since the ASCII punch file is not set up to save
;        a sub-region of the globe (bmy, 2/11/99)
;
; EXAMPLE:
;              fileinfo = create3dfstru()   ; not required !
;              fname = '~bmy/terra/CTM4/results/ctm.pch.m2'
;              open_file,fname,ilun
;              if (ilun gt 0) then $
;                 result = ctm_read3dp_header(ilun,fileinfo,datainfo)
;              print,result
;
;        To get e.g. all scaling factors, type
;              print,datainfo[*].scale
;
;        To retrieve the header structure for one data block, type
;              blocki = datainfo[i]
;
; MODIFICATION HISTORY:
;        mgs, 21 Aug 1997: VERSION 1.00
;        mgs, 02 Mar 1998: VERSION 1.10
;                  - can handle GEOS output now
;                  - reads in file header
;                  - returns structure instead of string array
;                  - always returns all entries, filtering must be done later
;        mgs, 03 Mar 1998: - now returns a structure and is a function
;        mgs, 04 Mar 1998: - toptitle is now default, changed keyword to
;                    NO_TOPTITLE ; eliminated search for '!' or '%'
;        mgs, 10 Mar 1998: - rewritten again, now with named structure
;                    returned as DATAINFO. Skipping of data blocks
;                    drastically improved by setting the file pointer
;                    instead of reading the lines.
;        mgs, 16 May 1998: - removed DATATYPE3DP function, set type tag to -1
;                  - added EXTRA_SPACE option for GISS_II_PRIME output and
;                    LINELENGTH keyword for full flexibility
;                  - now ignores time series ('TS...') data
;        mgs, 13 Aug 1998: - format string now composed here, not in
;                    read3dp_data
;        mgs, 14 Aug 1998: VERSION 2.00 - major changes!
;                  - now requires open file and uses ILUN parameter
;                  - automatic EXTRA_SPACE detection
;                  - fileinfo structure not created any more, and only
;                    extended if present (chkstru)
;                  - error messages as dialog box
;                  - LINELENGTH keyword removed
;        mgs, 15 Aug 1998: - now calls select_model and inserts model
;                    information in fileinfo structure
;                  - gamap_cmn.pro included for default model name
;                  - had to change DEBUG keyword into PRINT
;        mgs, 21 Sep 1998: - changed gamap.cmn to gamap_cmn.pro
;        mgs, 26 Oct 1998: - now resets error state in no_dim
;        mgs, 14 Jan 1998: - new lcount for line counting in error report
;                  - linelength adjusted for working in Windows (CR/LF)
;        bmy, 11 Feb 1999: VERSION 2.01
;                  - Add window offsets (I0,J0,L0) to DATAINFO 
;                  - save DATAINFO.TAU0 and DATAINFO.TAU1 as double precision
;        bmy, 17 Feb 1999: VERSION 2.02
;                  - changed to accommodate the FIRST field (instead of OFFSET)
;                    of the DATAINFO structure, which contains
;                    the I, J, L indices of the first grid box
;        bmy, 01 Mar 1999: 
;                  - bug fix!  NL needs to be a longword, so that
;                    we can read 2 x 2.5 punch files correctly!! 
;        mgs, 23 Mar 1999: 
;                  - cleaned up reading of dimensions from label a little
;        mgs, 27 May 1999: 
;                  - new default number of records is 512 instead of 4096.
;                  - bug fix: new records were never appended.
;        mgs, 22 Jun 1999: 
;                  - bug fix: "title" needed to be trimmed.
;        bmy, 20 Jan 2000: FOR GAMAP VERSION 1.44
;                  - !ERR is now replaced by !ERROR_STATE.CODE
;                  - !ERR_STRING is now replaced by !ERROR_STATE.MSG
;                  - I/O error trapping is now done by testing error
;                    messages instead of testing for error numbers
;                  - cosmetic changes, updated comments
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1997-2007, Martin Schultz,
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine ctm_read3dp_header"
;-----------------------------------------------------------------------



function ctm_read3dp_header,ilun,fileinfo,datainfo,  $
              print=pprint, $
              no_toptitle=no_toptitle, $
              extra_space=extra_space, automode=automode

; include global common block
@gamap_cmn.pro
                               
   ; External functions
   FORWARD_FUNCTION chkstru, select_model

   PPRINT = keyword_set(PPRINT)

   ; initialize return variables
   datainfo = -1

   ; default forcelinelength to automatic computation
   if (n_elements(forcelinelength) eq 0) then forcelinelength = -1
    
   extra_space = keyword_set(extra_space)

   ;====================================================================
   ; retrieve punch file name
   ;====================================================================
   if (chkstru(fileinfo,'filename')) then $
      thisfilename = fileinfo.filename   $
   else  $
      thisfilename = '<UNKNOWN FILE>'


   ;====================================================================
   ; initialize the datainfo structure array
   ;====================================================================
   MAXENTRIES = 512
   struc = create3dhstru(MAXENTRIES)

   ; ... and some temporary variables
   toptitle = ''   ; first title line of punch file
   count = -1L     ; data block counter
   lcount = 0L     ; line counter


   ;====================================================================
   ; read in header information of each data
   ; block, then skip to the next header
   ;====================================================================
   message,'Parsing file header information ...',/INFO,/NONAME

   ; Direct I/O errors to the READERR section 
   on_ioerror,readerr

   ; Read each line from the file
   while (not eof(ilun)) do begin

      line = ''
      readf, ilun, line
; print,lcount,'###',line
      lcount = lcount + 1

      ; at beginning of file: store toptitle
      if (count lt 0) then begin
         if (not keyword_set(NO_TOPTITLE)) then  begin
            toptitle = line     ; save title line
            if (PPRINT) then print, toptitle
            readf, ilun, line   ; read next line
; print,lcount,'###',line
            lcount = lcount + 1
         endif
      endif

      ; initialize (temporary) input fields for this data block
      title=''

      ; NL must be a longword for 2x2.5 models
      nl=0L
      n=0
      ntau0=0L    ; note that TAU will be stored as double !
      ntau1=0L
      ascale=0.0
      label = ''
      filepos = 0L
      dim = [ 0,0,0,0 ]
      First = [ 1, 1, 1 ]

      ; Direct line parse errors to the HEADRERR section 
      on_ioerror,headererr

      ; NOTE: this is formatted input and depends on the format
      ;    of the 3D model output of course
      ; special measures have to be taken to digest time series format
      ; this will be trapped in the error handler and simply ignored
      reads,line,title,nl,n,ntau0,ntau1,ascale,label, $
         format='(2X,A8,2I5,2I10,E10.3,2X,A)'


      title = strtrim(title,2)


      ; if category is BUDGETS* or BUGDETS* then switch to e-format (8E10.3)
      eformat = (strpos(strupcase(title),'BUDGETS*') ge 0 OR  $
                 strpos(strupcase(title),'BUGDETS*') ge 0)

       ; determine length of one output line
   ;   if (forcelinelength gt 0) then begin
   ;      linelength = forcelinelength
   ;      goto,forcedl
   ;   endif
      
      if (eformat) then begin
         litems = 8
         itemlen = 10
         dataformat = '(8e10.3)'
         if (extra_space) then dataformat = '(8(e10.3,1x))'
      endif else begin
         litems = 12
         itemlen = 6
         dataformat = '(12f6.2)'
         if (extra_space) then dataformat = '(12(f6.2,1x))'
      endelse
      linelength = litems*itemlen
      
      ; take care of extra spaces in output from GISS_II_PRIME
      if (extra_space) then $
         linelength = linelength+(litems-1)

      ; in Windows we have CR/LF instead of LF
      newlinelen = 1 + (!version.os_family eq 'Windows')


;  forcedl:

; use io_error to check if dimensions are provided with the header line
; This is needed to digest the old format
; NOTE: it is not very clean since we use the IO_ERROR also to skip
;       the entries in dim which are not supplied. Simply luck that it
;       works (does it?) !

      on_ioerror,no_dim
      tmpdim = intarr(3)
      ReadS, Label, TmpDim
      
      Dim[0:2] = TmpDim

no_dim:
      Message,/Reset            ; reset error status
      on_ioerror,readerr


      ; first, get file pointer
      point_lun,-ilun,curpos    ; similar to : res = fstat(ilun)

      count = count + 1

      ; sort information into structure
      struc(count).ilun = ilun
      struc(count).filepos = curpos
      struc(count).category = title
      struc(count).tracer = n
      struc(count).tau0 = Double( NTau0 )
      struc(count).tau1 = Double( NTau1 )
      struc(count).scale = ascale
      struc(count).format = dataformat
      struc(count).dim = dim
      struc(count).First = First
      
      if(PPRINT) then begin
         print,'       category : ',title
         print,'         curpos : ',curpos
         ;print,'      data type : ',struc(count).type
         print,'number of lines : ',nl
         print,'         tracer : ',n
         print,' time (from,to) : ',ntau0,ntau1
         print,'   scale factor : ',ascale
         print,'         format : ',dataformat
         print,'     dimensions : ',dim
         print,' first grid box : ',First
         print,'          label :>',label,'<'
      endif

      ; skip nl lines
      ; set pointer to nl-1 lines
      ; read last line as string because it may be shorter !!
; print,'FILE POINTER ##:',res.cur_ptr
      newpos = curpos               $ ; set file pointer to new position
         + (nl-1)*(linelength+newlinelen) ; take care of NEWLINE !!
      ; make sure NL is type LONG !

      point_lun,ilun,newpos
       
      dummy = ''
      readf,ilun,dummy
      lcount = lcount + nl - 1
      

next_header:
      ; check if MAXENTRIES is exceeded, if so, 
      ; create another structure array and concatenate
      if (count ge MAXENTRIES-1L) then begin
         tmpstru = create3dhstru(4096)
         struc = [ temporary(struc), tmpstru ]
         MAXENTRIES = MAXENTRIES+4096
      endif
       
   endwhile                     ; (end of file)

    ;=================================================================
    ; prepare information to be returned
    ;=================================================================
end_of_file:

   message,'Done.',/INFO,/NONAME

   ; if count is less than 0, nothing was read in
   if (count lt 0) then begin
      dum = dialog_message(['No information read from file', $
                            thisfilename+'!'] )
      free_lun,ilun
      return,0
   endif

   ; return last linelength if computed automatically
   ;  if (forcelinelength lt 0) then forcelinelength = linelength


    ; enter toptitle in fileinfo structure
   if (chkstru(fileinfo,'TOPTITLE')) then $
      fileinfo.toptitle = toptitle

    ; get model information and enter in fileinfo structure
   if (not keyword_set(automode)) then begin
      modelinfo = select_model(default=DefaultModel)
      if (chkstru(fileinfo,'MODELINFO')) then $
         fileinfo.modelinfo = modelinfo
   endif


    ; truncate struc array and pass it as datainfo
   datainfo = struc(0:count)


   return,1   ; successful !


   ;====================================================================
   ; I/O error encountered while reading data from the file
   ;====================================================================
readerr:
    
   ; Error message, taken from the !ERROR_STATE structure
   Msg = StrUpCase( StrCompress( !ERROR_STATE.MSG, /Remove_All ) )

    ; Incorrect format encountered!  We will try to read the
    ; punch file again, allowing for the extra space...
   if ( StrPos( Msg, 'UNABLETOAPPLYFORMATCODE' ) ge 0 $
        AND not Extra_Space ) then begin
      print,'trying extra_space ...'

      ; reset file pointer to zero
      point_lun,ilun,0L

      ; call CTM_READ3DP_HEADER recursively with /EXTRA_SPACE
      return,ctm_read3dp_header(ilun,fileinfo,datainfo,  $
                                print=pprint, $
                                no_toptitle=no_toptitle, $
                                /extra_space)
   endif

   ; Otherwise we have encountered a potentially serious I/O error!
   ; Display error message in a dialog box 
   dum = dialog_message( ['Error (' +  strtrim( !ERROR_STATE.CODE , 2 ) +  $
                          ') reading file ', thisfilename,                 $
                          ' in block ' +     strtrim( count, 2  ),         $
                          ' line '     +     strtrim( lcount, 2 ),         $
                          strcompress( !ERROR_STATE.MSG ) ],               $
                         /ERROR )

   ; For unexpected end of file, reset error status and return what we got
   ; NOTE: We should only land here if EOF was encountered abnormally!
   if ( StrPos( Msg, 'ENDOFFILEENCOUNTERED' ) ge 0 ) then begin
      message,/Reset
      goto,end_of_file
   endif

   ; otherwise close file and return as unsuccessful
   free_lun,ilun
   return,0

   ;====================================================================
   ; I/O error encountered while parsing a header line
   ;====================================================================
headererr:

    ; Error message, taken from the !ERROR_STATE structure
    Msg = StrUpCase( StrCompress( !ERROR_STATE.MSG, /Remove_All ) )

    ; if caused by time series then skip (## always 1 line ??)
    ; NOTE: This will most likely result in a crash, but that is OK
    ; since we don't have many punch files w/ timeseries info in them
    ; these days (bmy, 1/20/2000).
    if ( StrPos( Msg, 'UNABLETOAPPLYFORMATCODE' ) ge 0 ) then begin
       if ( ( StrPos( Title, 'TS' ) eq 0 )   OR $
            ( StrPos( Title, 'TB' ) eq 0 ) ) then begin
          dummy = ''
          ;   for i=0,nl-1 do  $
          readf,ilun,dummy
          ;   endfor
          goto,next_header
       endif
    endif

    ; otherwise print error and exit
    goto,readerr

end



