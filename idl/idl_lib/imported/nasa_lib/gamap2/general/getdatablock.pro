; $Id: getdatablock.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GETDATABLOCK
;
; PURPOSE:
;        Retrieve information stored in a DATA block somewhere
;        within an IDL routine. The DATA block must be "hidden"
;        as comment lines for the IDL compiler. The data will be 
;        returned as string array.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        GETDATABLOCK, DATA [, FILENAME=FILENAME, ,LABEL=LABEL ]
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;        FILENAME -> optional filename. Normally, the data block is
;            read from the file that contains the current procedure
;
;        LABEL -> a unique identifier for the start of the data block.
;            Default is '/DATA/'. The end of the data block is reached
;            at the end of file or if the block of comment lines ends.
;
; OUTPUTS:
;        DATA -> a string array with the information contained in the 
;            data block
;
; SUBROUTINES:
;        External Subroutines Required:
;        ======================================
;        FILE_EXIST (function)   ROUTINE_NAME
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The file with the datablock is always searched in !PATH
;
; EXAMPLE:
;        GETDATABLOCK, SDATA
;
;             ; This will retrieve a data block labeled '/DATA/' 
;             ; from the file of the current IDL routine
;
; MODIFICATION HISTORY:
;        mgs, 22 Apr 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments, cosmetic changes
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
; or phs@io.harvard.edu with subject "IDL routine getdatablock"
;-----------------------------------------------------------------------


pro getdatablock, data, filename=filename, label=label


   if (n_elements(label) eq 0) then label = '/DATA/'
 
   ; first get filename of caller routine if no filename provided
   if (n_elements(filename) eq 0) then $
      dum = routine_name(filename=filename,/caller)
 
   if (filename eq '') then begin  ; no retrieval possible
      print,'GETDATABLOCK: Could not identify pro filename!'
      return
   endif
 
   ; search for file in IDL path
   if not(file_exist(filename,path=!PATH,full=full)) then begin
      print,'GETDATABLOCK: Could not find pro file '+filename+'!'
      return
   endif
 
 
   ; open file and look for label in comments
   on_ioerror, badfile
 
   openr,ilun,full,/get_lun
   line = ''
   while (not eof(ilun) AND strpos(line,label) lt 0) do $
     readf,ilun,line
  
   if (strpos(line,label) lt 0) then begin 
      print,'GETDATABLOCK: No label '+label+' in file '+filename+'!'
      free_lun,ilun
      return
   endif
 
   ; initialize data array
   data = ''
 
   ; now read in lines until eof or first character is no ';'
   repeat begin
      readf,ilun,line
      line = strtrim(line,2)
      if (strmid(line,0,1) eq ';') then begin
          len = strlen(line)
          data = [ data, strtrim(strmid(line,1,len),2) ]
      endif
   endrep until (eof(ilun) OR strmid(line,0,1) ne ';')
 
   ; remove first dummy entry
   if (n_elements(data) gt 1) then $
      data = data(1:*)
 
   return
 
 
badfile:
   print,'GETDATABLOCK: file error encountered (',!ERR,')'
   if (ilun ge 0) then free_lun,ilun
   return
 
end
