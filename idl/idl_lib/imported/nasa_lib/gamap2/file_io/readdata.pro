; $Id: readdata.pro,v 1.2 2007/08/21 13:36:26 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        READDATA
;
; PURPOSE:
;        This subroutine reads in  almost any ASCII file and returns 
;        two arrays containing the names of the variables and their 
;        values.  The data is read line by line or in one step if 
;        LINES is specified.
;
; CATEGORY:
;        File & I/O
;
; CALLING SEQUENCE:
;       READDATA, FILENAME, DATA, HEADER [, NCOL, NDAT ] [, KEYWORDS ]
;
; INPUTS:
;       FNAME -> Name of fname to be read, e.g. 'flight12.dat'
;
; KEYWORD PARAMETERS:
;       COLS -> number of columns to be read (must be used if no header 
;             is read in, i.e. /NOHEADER is specified). Can be used
;             to read in a subset of columns if the file contains a header
;             line with variable names (i.e. if *not* /NOHEADER).
;
;       LINES -> number of lines to be read (not much faster for large
;             data sets, but allows to read in a subset of the data)
;
;       DELIM -> Separator between names in the header (default=',')
;
;       SKP1 -> Number of lines to be skipped before the variable 
;             definition (default=0)
;
;       SKP2 -> .. after the variable definition (default=0)
;
;       SKIP -> same as SKP1 (SKP1 will overwrite SKIP. SKIP may be
;             not longer supported in future versions !)
;
;       AUTOSKIP  -> for files that state the number of comment lines 
;             in the first line. If keyword NOHEADER is not set, READDATA 
;             expects a list of variable names as last comment line.
;             AUTOSKIP overrides settings of SKP1 and SKP2.
;
;       TRANSPOSE -> Normally, 1st array dimension is for variables, 
;             2nd is for observations. /TRANSPOSE will reverse that 
;             order (see note).
;
;       NOHEADER -> don't read a header (COLS must be specified in 
;             this case !)
;
;       NODATA -> don't read data (stop after header). DATA parameter 
;             must still be specified !
;
;       COMMENTS -> returns string array of all the comment lines in 
;             the data file for later use
;
;       MAXCOMMENTS -> limits maximum number of comment lines to be 
;             retrieved (default: 255)
;
;       QUIET -> Normally, READDATA prints the number of variables 
;             found and  number of data lines read.  Use this option 
;             to suppress all output.
;
;       /DOUBLE -> If set, will return data in double precision.
;             (Default is to return data in single precision.)
; 
;
; OUTPUTS:
;       DATA -> data array that was read in
;
;       NAMES -> string array of names in header
;
;       NCOL -> integer containing the number of columns
;
;       NDAT -> long integer containing the number of observations
;
;       COMMENTS  -> string array containing all header lines.  
;             If AUTOSKIP is set, skp1, and skp2 will contain the 
;             actual amount of lines to skip (e.g. for re-storing 
;             header information in EXPLORE)
;
; SUBROUTINES:
;      External Subroutines Required:
;      ==============================
;      OPEN_FILE
;      STRBREAK (function)
;      USAGE
;
; REQUIREMENTS:
;      None
;
; NOTES:
;      Default of the returned DATA array is: 1st index = variable, 
;      2nd index = observation. Use the /TRANSPOSE option for reverse order
;
;      If /NOHEADER is used, then COLS must specify the actual number of
;      data columns in FNAME. Otherwise it can be used to read a subset of 
;      the data from 0 to cols-1 columns.
;
;      IDL Parameters are optional. Of course, you should not readdata without
;      passing a DATA argument, but you can ignore the HEADER,NCOL, and NDAT 
;      params.
;
; EXAMPLES:
;      (1)
;      READDATA,'mydata.dat',DATA,HEADER,DELIM=' ',SKIP=5
;
;      ... will read in the ASCII file mydata.dat and store the data in DATA.
;      The header information will be stored in HEADER. The header items are
;      seperated by blank spaces, and the first 5 lines should be ignored.
;      To pick a certain variable afterwards, type:
;      VAR = DATA(WHERE HEADER EQ 'MYVAR'),*)
;
;      (2)
;      READDATA,'noheader.dat',DATA,DELIM=';',NCOLS=3
;
;      ... will read a three column ASCII file with no header information.
;      You can manually make up a header with 
;      HEADER = ['VAR1','VAR2','VAR3'] 
;      or you can pass the HEADER argument and receive ['X1','X2','X3'] as
;      header.
;
;      (3)
;      READDATA,'mydata.dat',DATA,HEADER,DELIM=' ',SKP1=5,LINES=60,COLS=4, $
;         COMMENTS=COMMENTS
;
;      ... will read in 60 lines and 4 columns of the ASCII file mydata.dat 
;      and return 6 comment lines in COMMENTS (5 + variable names)
;
;
; MODIFICATION HISTORY:
;         mgs  03/12/1997: - last update : 05/22/97
;         mgs 01 Aug 1997: - added template
;         mgs 15 Sep 1997: - added LINES option and removed some twitch in the
;                            handling of TRANSPOSE. Unfortunately,
;                            LINES does not improve the speed as
;                            desired, but you can restrict the reading to
;                            a smaller subset of the data.
;         mgs 26 Sep 1997: MAJOR REVIEW
;                          - bug fixes in noheader option
;                          - bug fixes in COLS and NCOL handling
;                          - removed units option and created comments 
;                            keyword instead.  program now reads in
;                            all header lines into a string array
;                            including the variable names line.
;                          - automatic generation of a header if 
;                            /NOHEADER is specified
;         mgs 06 Nov 1997: - Added AUTOSKIP option for easier reading 
;                            of e.g. NASA formatted files.
;         mgs 01 Dec 1997: added MAXCOMMENTS keyword and limit
;                          - skp1 now returns correct amount if
;                            autoskip is set
;         mgs 30 Dec 1997: added NODATA keyword
;         mgs 21 Aug 1998: now uses open_file routine to allow wildcards
;         bmy 12 May 2005: added /DOUBLE keyword to force double precision
;  bmy & phs, 21 Aug 2007: GAMAP VERSION 2.10
;                          - Now use STRBREAK, which is version independent
;                          - Remove internal function USE_READDATA; we
;                            now call USAGE to display program options
;                            if the wrong # of arguments are passed
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
; or phs@io.as.harvard.edu with subject "IDL routine readdata"
;-----------------------------------------------------------------------


;-----------------------------------------------------------------------------
; Prior to 8/21/07:
; Now call USAGE to display std doc header if the wrong # of 
; or keywords are supplied (bmy, 8/21/07)
;;  WARNING: Do not move pro use_readdata to the end of this file !!
;; ==============================================================
; 
; 
;pro use_readdata
; 
;     print
;     print,' usage : '
;     print,'     readdata,filename,data [,names [,ncol [,ndat]]]',  $
;           ' [,keywords]'
;     print
;     print,' keywords = cols,lines,delim,skp1,skp2,skip,autoskip, '
;     print,'            noheader,nodata,comments,transpose,quiet'
;     print
; 
;  return
; 
;  end
;-----------------------------------------------------------------------------
 
 
pro readdata,fname,DATA,NAMES,NCOL,NDAT,cols=cols,lines=lines,   $
             delim=delim,skp1=skp1,skp2=skp2,skip=skip,autoskip=autoskip,    $
             noheader=noheader,nodata=nodata,  $
             comments=comments,maxcomments=maxcomments, $
             transpose=transpose,quiet=quiet, Double=DDouble

   ; External Functions
   FORWARD_Function StrBreak

on_error,2     ; return to caller

  ; Use double precision? (bmy, 5/12/05)
  DDouble = Keyword_Set( DDouble )

; set maximum number of allowed lines and maximum of comment lines
  if(keyword_set(lines)) then IMAX = lines else IMAX = 20000L
  if (n_elements(maxcomments) le 0) then maxcomments = 255
 
 
     DATA = 0         ; default: return 0 as DATA
     NAMES = ''       ; variable names (will be copied into HEADER)
     COMMENTS = ''    ; comment lines

     NDAT = 0         ; number of data lines actually read

     NCOL = 0         ; number of columns found in the data set, i.e. 
                      ; number of variable names in HEADER
                      ; COLS is the variable that is actually used to
                      ; determine the number of variables to read and
                      ; COLS will be set to NCOL if not specified as keyword.
 
; see if parameters are consistent
  if (N_PARAMS() le 1) then begin
     print,' ERROR in readdata : not enough parameters !'
     ;--------------------------------------------------------
     ; Prior to 8/21/07:
     ; Now call USAGE for error msg display (bmy, 8/21/07)
     ;use_readdata
     ;--------------------------------------------------------
     Usage, Routine_Name()
     return
  endif
 
  if (keyword_set(noheader) AND NOT keyword_set(cols)) then begin    
     print,' ERROR in readdata : /noheader requires cols=nn !'
     ;--------------------------------------------------------
     ; Prior to 8/21/07:
     ; Now call USAGE for error msg display (bmy, 8/21/07)
     ;use_readdata
     ;--------------------------------------------------------
     Usage, Routine_Name()
     return
  endif
 
; set keyword parameters or their default values
  if not keyword_set(delim) then delim=','
  if (not (keyword_set(skp1) OR keyword_set(skip)) ) then skp1 = 0
  if (keyword_set(skip) AND NOT keyword_set(skp1)) then skp1 = skip
  if not keyword_set(skp2) then skp2 = 0
 
 
  char='' & i=0
  on_ioerror,bad
  !ERROR = 0

; open the data file
  open_file,fname,unit1,filename=filename,default='*.dat*'
  if (unit1 le 0) then begin
     print,'*** READDATA: Cannot open file '+filename
     return
  endif

  fname = filename   ; store real filename
 
; skip lines in the header 
  if(keyword_set(autoskip)) then begin
     skp2 = 0       ; prevent additional skipping
     readf,unit1,skp1
     ; add to comment array
     comments = [ comments, strcompress(skp1) ]
     skp1 = skp1-1  ; first line already read in
     ; if variable names will be read automatically, they are in last 
     ; comment line
     if (not keyword_set(noheader)) then skp1 = skp1-1
  endif 
  for i=1,skp1 do begin
     readf,unit1,char                  ; read in string 
     if (i lt maxcomments) then $
        comments = [ comments , char ]    ; add to comments
  endfor
; correct skp1 again to return proper result
  if (keyword_set(autoskip)) then $
      skp1 = skp1+1
 
; read in variable definition string
  if(not keyword_set(noheader)) then begin
     readf,unit1,char 
     comments = [ comments , char ]
     char = STRCOMPRESS(STRTRIM(char,2))   ; remove white spaces, leave
                                           ; only one between words
     if(delim ne ' ') then char = STRCOMPRESS(char,/remove_all)
                                           ; remove all white spaces
     ;-----------------------------------------------------------------------
     ; Prior to 8/21/07:
     ; Need to use STRBREAK, which will call either STR_SEP or STRSPLIT
     ; depending on the IDL version (bmy, 8/21/07)
     ;NAMES = STR_SEP(char,delim)           ; convert string to word array
     ;-----------------------------------------------------------------------
     NAMES = StrBreak( char, delim )       ; convert string to word array
  endif
 
; skp 2nd block of comment lines
  for i=1,skp2 do begin
     readf,unit1,char                  ; read in string 
     comments = [ comments , char ]    ; add to comments
  endfor

; if comments were read in, delete first (blind) one
  if (n_elements(comments) gt 1) then   $
        comments = comments(1:n_elements(comments)-1)

 
; find the number of columns actually contained in the data file 
  if (not keyword_set(noheader)) then begin
      NCOL = N_ELEMENTS(NAMES)     
; ... and set the number of columns to be stored
      if(not keyword_set(cols)) then cols = NCOL
      if(not keyword_set(quiet)) then $
          print,fname,' : ',NCOL,' variables found, will read in ',cols
;      (may seem somewhat awkward, but you can read in a subset of columns
;       if the file contains variable names and you specify COLS)
  endif else  $
      NCOL = cols    ; if NOHEADER is specified, then READDATA must assume
                     ; you specified the correct number of columns in COLS

  if (keyword_set(NODATA)) then return

; read in the data.
  if(keyword_set(lines)) then begin
; declare temporary array to hold the data

     ; NOTE: give user option of double precision (bmy, 5/12/05)
     if ( DDouble )                  $
        then Var = DblArr(NCOL,IMAX) $
        else Var = Fltarr(NCOL,IMAX)

     readf,unit1,var   
     var = var(0:cols-1,*)     ; cut out the unwanted columns
     i = n_elements(var(0,*))  ; SHOULD BE IDENTICAL TO LINES OR IMAX ! 

  endif else begin  

     i=0
; declare temporary array to hold data and vector for one data line

     ; NOTE: give user option of double precision (bmy, 5/12/05)
     if ( DDouble ) then begin
        Var = DblArr(cols,IMAX)
        Dum = DblArr(NCOL) 
     endif else begin
        Var = FltArr(cols,IMAX)
        Dum = FltArr(NCOL)
     endelse

     while not eof(unit1) do begin
     readf,unit1,dum
     var(*,i)=dum(0:cols-1)    ; copy wanted columns into data array
     i=i+1
     if (i gt IMAX) then begin
        print,' SORRY : too much data ! Current limit set to ',IMAX
        print,' Will proceed with what I got ...'
        goto,recover
     endif
 
     endwhile
  endelse
  
recover:  close,unit1
 
; set the variables that may be returned
 
  NDAT = i        ; number of data lines
  NCOL = cols     ; number of columns actually in the data array

; cut out unwanted variable names OR create artificial names
  if (not keyword_set(noheader)) then NAMES = NAMES(0:cols-1) $
  else begin
      NAMES = 'X' + strtrim(string(indgen(NCOL)+1,format='(i8)'),2)
  endelse
 
  if(not keyword_set(quiet)) then print,NDAT,' lines of data read.'
 
  if (i le 0) then begin
     !error = 101
     goto,bad
  endif

; optionally transpose the data array 
  if(keyword_set(transpose)) then DATA = TRANSPOSE(var(*,0:i-1))    $
  else DATA = var(*,0:i-1) 
 
  goto, done
 
 
  bad:  print,!ERR_STRING,'  (',!ERROR,')'
        if(!error eq -171 OR !error eq -206) then begin
           print,' File not found.'
           end
        if(!error eq -191 OR !error eq -226) then begin
           use_readdata
           print,' You probably specified a wrong number for skp1 or skp2.'
           end
        if(!error eq 101) then begin
           print,' File was empty.'
           end
  done: if(!error ne -171 AND !error ne -206) then free_lun,unit1
        return
 
 
end


 
 
