pro catalog, proc_name, path=path, file=output_file, code=code

;+
; NAME:
;   catalog
;
; PURPOSE:
;   Prints out the calling sequence, documentaion, and optionally the code
;   for a procedure/function or a set of procedures/functions
;
; CATEGORY:
;   documentation
;
; CALLING SEQUENCE:
;   catalog, proc_name
;
; INPUTS:
;   proc_name = a string containing the name of the procedure(s) or
;               function(s) for which the calling sequence and
;               documentation lines are to be printed (wildcard
;               characters such as "*" are allowed.)
;
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORD PARAMETERS (all input unless otherwise specified):
;
;   path = path of directories to be searched; if omitted, !path is used.
;
;   output_file = file in which to save the output; if omitted, lines are
;                 printed to stdout.
;
;   code = a flag variable; if non-zero, then the code of the procedure(s)
;          or function(s) is also printed
;
; OUTPUTS
;
; OPTIONAL OUTPUT PARAMETERS:
;
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;   if the file keyword is used, 'output_file' is created.
;
; RESTRICTIONS:
;
; PROCEDURE:
;   prints the calling sequence and documentation for procedure or function
;
; REQUIRED ROUTINES:
;   print_doc
;
; MODIFICATION HISTORY: 
;   written by Pat Guimaraes, STX, Feb. 11, 1991, adapted from callseq.pro
;
;   PTG 03/31/94 - added keyword code
;-
;
; Initialize variables
;
true  = 1b
false = 0b

;
; Check if the keyword path was specified, and if not, use !path
;
if (n_elements(path) eq 0) then path = !path

;
; Set the operating system flag accordingly
;
if (!version.os eq 'vms') then begin
   vms = true
endif else begin
   vms = false
endelse

;
; Check if the keyword file was specified
;
if (n_elements(output_file) eq 0) then begin
   print_to_file = false
endif else begin
   print_to_file = true
   get_lun,out_lun
   openw,out_lun,output_file,error=open_error
   if (open_error ne 0) then begin
      print,' '
      print,'CATALOG: Cannot open ',output_file,' for output.'
      print,' '
      close,out_lun
      free_lun,out_lun
      print_to_file = false
   endif
endelse

;
; Append file extension to file name if it doesn't already have one
;
proc = proc_name
if (strpos(proc_name,'.') eq -1) then proc = proc + '.pro'

;
; Define the directory separator in the path
;
if (vms) then begin
  dir_separator = ","   ; comma for VMS
endif else begin 
  dir_separator = ":"   ; colon for Unix
endelse

;
; Parse the path to print the documentation for each file in the path
;
first = true
temp_path = path
path_len = strlen(temp_path)
while (path_len gt 0) do begin
  i = strpos(temp_path,dir_separator)
  if (i lt 0) then i = path_len
  dir = strmid(temp_path,0,i)
  temp_path = strmid(temp_path,i+1,path_len-i-1)
  path_len = strlen(temp_path)
  if (dir ne '') then begin
    if (strmid(dir,0,1) eq '@') then begin
      ;
      ; A library name was included in the path
      ;
      print,' '
      print,'ROUTINES IN THE IDL LIBRARY:'
      print,' '
      print,dir
      print,' '
      print,'WILL NOT BE PRINTED'
      print,' '
    endif else begin
      if (not vms) then $
        dir = dir + '/'
      file_spec = dir + proc
      file_names = findfile(file_spec,count=num_files)
      if (num_files gt 0) then begin
        ;
        ; Print the calling sequence and documentation for each file
        ; in this directory
        ;
        for i=0,num_files-1 do begin
          file = file_names(i)
          print_doc, file, print_to_file, out_lun, $
                     first = first, code = code
        endfor
      endif
    endelse
  endif
endwhile

;
; Close the output file if it has been opened
;
if (print_to_file) then begin
  close,out_lun
  free_lun,out_lun
endif

return
end
