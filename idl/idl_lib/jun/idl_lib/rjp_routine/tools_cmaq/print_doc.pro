pro print_doc, file, print_to_file, out_lun, $
               first=first, code=code

;+
; NAME:
;   print_doc
;
; PURPOSE:
;   Prints out the calling sequence, documentaion, and optionally the
;   code for a procedure or function in a file.
;
; DESCRIPTION:
;   This procedure opens the file specified by parameter file and prints
;   the calling sequence, documentation lines, and optionally the code
;   for the procedure or function in it (if more than one procedure/function
;   in the file, only the first one is printed).  Parameter print_to_file
;   is optional and if true (1), then the output will be written to the file
;   opened on logical unit out_lun (must be passed in this case) instead of to
;   stdout.  If keyword first is passed and zero, a form feed is printed before
;   any of the output lines.
;
; CATEGORY:
;   documentation
;
; CALLING SEQUENCE:
;   print_doc, file, print_to_file, out_lun
;
; INPUTS:
;   file = name of file containing the procedure of function for which
;          the calling sequence and documentation lines are to be printed
;          (wildcard characters are NOT allowed); name must include the
;          directory name (if file is not in the default directory) and
;          the file name and extenstion.
;
; OPTIONAL INPUT PARAMETERS:
;
;   print_to_file = flag which indicates whether the output should be
;                   printed to the file opened on logical unit out_lun
;                   (print_to_file = 1) or not (print_to_flag = 0, output
;                   written to stdout).
;
;   out_lun = logical unit of output file (must be passed if print_to_file
;             is equal to 1); a file must already have been opened on this
;             logical unit.
;
; KEYWORD PARAMETERS (all input unless otherwise specified):
;
;   code = a flag variable; if non-zero, then the code of the procedure
;          or function is also printed (i.e., the entire file is printed)
;
;   first = a flag variable; if zero, it indicates that a form feed should
;           be printed before the output; if not passed, it defaults to 1.
;
; OUTPUTS:
;
; OPTIONAL OUTPUT PARAMETERS:
;
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;   prints the calling sequence and documentation for procedure or function
;
; REQUIRED ROUTINES:
;
; MODIFICATION HISTORY: 
;   written by Pat Guimaraes, STX, Feb. 12, 1991
;
;   PTG 03/31/94 - made parameter first be an input keyword
;
;                - added keyword code
;-

;
; Check the optional parameters and initialize them to their default values
;
if (n_params() gt 1) then begin
  if (print_to_file) then begin
    if (n_elements(out_lun) eq 0) then begin  ; out_lun is undefined
      print,' '
      print,'PRINT_DOC:  Parameter out_lun must be defined and the ' $
            + 'output file opened on it.'
      print,' '
      return
    endif
  endif
endif else begin
  print_to_file = 0b
endelse
if n_elements(first) eq 0 then first = 1b

;
; Open the input file
;
get_lun,lun
openr,lun,file,error=open_error
if (open_error ne 0) then begin
  print,' '
  print,'PRINT_DOC: Cannot open ',file,' for input.'
  print,' '
  close,lun
  free_lun,lun
endif else begin
  if (print_to_file) then begin
    ;
    ; Print the output to a file
    ;
    if (first) then $
      first = 0b $
    else $
      printf,out_lun,string(12b)  ; print a form feed
    printf,out_lun,' '
    printf,out_lun,'FILE:  ' + file
    printf,out_lun,' '
  endif else begin
    ;
    ; Print the output to stdout
    ;
    if (first) then $
      first = 0b $
    else $
      print,string(12b)  ; print a form feed
    print,' '
    print,'FILE:  ' + file
    print,' '
  endelse
  read_call_seq = 0b
  read_doc_lines = 0b
  if keyword_set(code) then $
    read_code = 0b $
  else $
    read_code = 1b
  line = ''

  ;
  ; Loop to read each line from the input file until the call sequence
  ; and documentation lines (and possibly the code) have been printed
  ;
  while ((not eof(lun)) and $
         ((not read_call_seq) or (not read_doc_lines) or (not read_code))) $
    do begin

    readf,lun,line
    ;
    ; Skip lines until the first non-null line is read
    ;
    while ((not eof(lun)) and (strtrim(line,2) eq '')) do begin
      readf,lun,line
    endwhile
    if (not eof(lun)) then begin
      if (((strupcase(strmid(line,0,4)) eq 'PRO ') or $
           (strupcase(strmid(line,0,9)) eq 'FUNCTION ')) and $
          (not read_call_seq)) then begin
        ;
        ; Print the calling sequence
        ;
        if (print_to_file) then begin
          printf,out_lun,' '
          printf,out_lun,'---------------------------- Full Calling Sequence ' $
                         + '----------------------------'
          printf,out_lun,' '
        endif else begin
          print,' '
          print,'---------------------------- Full Calling Sequence ' $
                + '----------------------------'
          print,' '
        endelse
        if (print_to_file) then $
          printf,out_lun,line $
        else $
          print,line
        while ((not eof(lun)) and (strpos(line,'$') ne -1)) do begin
          readf,lun,line
          if (print_to_file) then $
            printf,out_lun,line $
          else $
            print,line
        endwhile
        if (strpos(line,'$') eq -1) then begin
          if (print_to_file) then $
            printf,out_lun,' ' $
          else $
            print,' '
          read_call_seq = 1b
        endif
      endif else begin
        if ((strupcase(strmid(line,0,2)) eq ';+') and $
            (not read_doc_lines)) then begin
          ;
          ; Print the documentation lines
          ;
          if (print_to_file) then begin
            printf,out_lun,' '
            printf,out_lun,'----------------------------  Documentation ' $
                           + 'Lines  ----------------------------'
            printf,out_lun,' '
          endif else begin
            print,' '
            print,'----------------------------  Documentation Lines  ' $
                  + '----------------------------'
            print,' '
          endelse
          if (print_to_file) then $
            printf,out_lun,line $
          else $
            print,line
          while ((not eof(lun)) and (strmid(line,0,2) ne ';-')) do begin
            readf,lun,line
            if (print_to_file) then $
              printf,out_lun,line $
            else $
              print,line
          endwhile
          if (strmid(line,0,2) eq ';-') then begin
            if (print_to_file) then $
              printf,out_lun,' ' $
            else $
              print,' '
            read_doc_lines = 1b
          endif
        endif else begin
          if (read_call_seq) and (read_doc_lines) and (keyword_set(code)) $
            then begin
            if (print_to_file) then begin
              printf,out_lun,' '
              printf,out_lun,'----------------------------------- Code ' $ 
                             + '--------------------------------------'
              printf,out_lun,' '
            endif else begin
              print,' '
              print,'------------------------------------ Code ' $ 
                    + '-------------------------------------'
              print,' '
            endelse
            if (print_to_file) then $
              printf,out_lun,line $
            else $
              print,line
            while (not eof(lun)) do begin
              readf,lun,line
              if (print_to_file) then $
                printf,out_lun,line $
              else $
                print,line
            endwhile
            read_code = 1b
          endif
        endelse
      endelse
    endif
  endwhile
  close,lun
endelse
if (print_to_file) then $
  printf,out_lun,' ' $
else $
  print,' '
return
end
