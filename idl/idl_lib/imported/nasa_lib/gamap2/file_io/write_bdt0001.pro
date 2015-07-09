; $Id: write_bdt0001.pro,v 1.2 2008/04/02 15:19:02 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        WRITE_BDT0001
;
; PURPOSE:
;        Write a binary data file with size information and
;        variable names and units
;
; CATEGORY:
;        File & I/O
;
; CALLING SEQUENCE:
;        WRITE_BDT0001,filename,data,vardesc[,keywords]
;
; INPUTS:
;        FILENAME -> Name of the file to write or a file mask
;            which will be used in the PICKFILE dialog. If the 
;            filemask is a named variable, it will return the 
;            actual filename.
;
;        DATA -> a 2D data array with dimensions LINES,VARIABLES
;
;        VARDESC -> A variable descriptor structure array (see 
;            GTE_VARDESC). This array must contain one structure 
;            for each variable and the structure must have the 
;            tags NAME and UNIT. Alternatively, you can use the
;            NAMES and UNITS keywords to pass string arrays.
;
; KEYWORD PARAMETERS:
;        NAMES -> A string array containing variable names. This 
;            will only be used if no VARDESC structure array is 
;            given.
; 
;        UNITS -> A string array with physical units for each 
;            variable. (see NAMES)
;
;        COMMENTS -> A string (or string array) with comment lines.
;            Only the first 80 characters of each line will be stored.
;
;        SELECTION -> An index array to select only a subset of
;            variables from the data set. Indices are truncated 
;            to lie in the range 0..n_elements(names), which can
;            lead to multiple output of the same variable!
;
;        _EXTRA keywords are passed on to OPEN_FILE
;
;        Flags to determine the data type:
;        Default is to store the data in its current type. Use the
;        TYPE keyword to convert it to any other (numeric) type
;        or use one of the following keywords. The type information
;        is saved in the file, so READ_BDT0001 can automatically 
;        read the data regardless of the format.
;
;        /BYTE -> convert data to byte format
;        /INT -> convert data to (2 byte) integer format
;        /LONG -> convert data to (4 byte) integer format
;        /FLOAT -> convert data to (4 byte) real format
;        /DOUBLE -> convert data to (8 byte) double prec. real format
;        /COMPLEX -> convert data to (8 byte) complex
;        /DCOMPLEX -> convert data to (16 byte) double complex
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Uses OPEN_FILE, STR2BYTE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Format specification:
;        file_ID  :      80 byte character string
;        NVARS, NLINES, NCOMMENTS, TYPE : 4 byte integer (long)
;        NAMES :         NVARS*40 byte character string
;        UNITS :         NVARS*40 byte character string
;        COMMENTS :      NCOMMENTS records with 80 characters each
;        DATA  :         8 byte float (double) array NLINES*NVARS
;
; EXAMPLE:
;        WRITE_BDT0001,'~/tmp/*.bdt',data,vardesc
;
; MODIFICATION HISTORY:
;        mgs, 24 Aug 1998: VERSION 1.00
;        mgs, 28 Aug 1998: - changed specs to allow comments
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Now write data as big-endian
;
;-
; Copyright (C) 1998-2007, Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine writebdt_0001";
;-------------------------------------------------------------


pro write_bdt0001,filename,data,vardesc,names=names,units=units,  $
          comments=comments,selection=selection,  $
          byte=byte,int=int,float=float,double=double,  $
          complex=complex,dcomplex=dcomplex,type=type, $
          _EXTRA=e
 

FORWARD_FUNCTION str2byte, Little_Endian

   ; reset error state
   message,/reset
 
   ; check arguments: if desc is not provided, names and units
   ; must be present
 
   if (n_params() lt 2) then begin
      message,'Usage write_bdt0001,filename,data,vardesc [,keywords]', $
              /CONT
      return
   endif
 
   if (n_params() lt 3) then begin
      if (n_elements(names) eq 0 OR n_elements(units) eq 0) then begin
         message,'No names or units given!',/CONT
         return
      endif
   endif else begin
   ; extract variable names and units from descriptor structure
      if (not chkstru(vardesc,['name','unit'])) then begin
         message,'Invalid descriptor !',/CONT
         return
      endif
      names = vardesc.name
      units = vardesc.unit
   endelse
 
 
   ; Make selection of variables if requested
   totalvars = long(n_elements(names))
   if (n_elements(selection) gt 0) then begin
      ; numerical selection list   ; *** primitive version ***
      ; only makes sure that indices are in range
      selind = (selection > 0) < (totalvars-1)
   endif else $
      selind = lindgen(totalvars)    ; select all variables


   ; determine data type 
   dtype = size(data,/type)
   if (dtype lt 1 OR dtype gt 7) then begin
      message,'Invalid data type!',/CONT
      return
   endif
   if (keyword_set(byte    )) then dtype = 1
   if (keyword_set(int     )) then dtype = 2
   if (keyword_set(long    )) then dtype = 3
   if (keyword_set(float   )) then dtype = 4
   if (keyword_set(double  )) then dtype = 5
   if (keyword_set(complex )) then dtype = 6
   if (keyword_set(dcomplex)) then dtype = 7
   if (n_elements(type) gt 0) then dtype = (type > 1) < 7
   dtype = long(dtype)    ; to store as 4 byte integer
 
   ; get number of variables, lines, and comments to save
   nvars = long(n_elements(selind))  
   nlines = long(n_elements(data[*,0]))
   ncomments = long(n_elements(comments))
 
   ; Compose binary header (byte arrays)
   header1 = bytarr(40,nvars)
   header2 = bytarr(40,nvars)
   for i=0,nvars-1 do begin
      header1[*,i] = str2byte(names[selind[i]],40) 
      header2[*,i] = str2byte(units[selind[i]],40)
   endfor
 
 
   ; Open file for binary writing
   ; ### Test requirement of /SWAP_IF_BIGENDIAN etc. when using PC !! ###
   open_file,filename,olun,default='*.bdt',/F77_UNFORMATTED,  $
            /WRITE, Swap_Endian=Little_Endian(), _EXTRA=e
 
   if (olun le 0) then return   ; cancelled
 
   ; Write file identifier
   file_id = str2byte('BDT0001:Simple binary data file with size '+  $
                        'information, variable names and units',80)
   writeu,olun,file_id
 
   ; Write size information
   writeu,olun,nvars,nlines,ncomments,dtype
 
   ; Write header
   writeu,olun,header1
   writeu,olun,header2

   ; Write comments
   for i=0,ncomments-1 do $
      writeu,olun,str2byte(comments[i],80)
 
   ; Write data
   writeu,olun,typecast(data[*,selind],dtype)

   ; close file
   free_lun,olun
 
 
   return
end
 
 
