;-------------------------------------------------------------
; $Id: code_tree.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;+
; NAME:
;        CODE_TREE
;
; PURPOSE:
;       This routine produces a tree structure for Fortran programs.
;       It will scan a directory for FORTRAN files and gather all
;       SUBROUTINE names and CALL statements. FUNCTIONS are not
;       parsed.
;
; CATEGORY:
;       Tools
;
; CALLING SEQUENCE:
;        CODE_TREE [,default_path,default_main] [,/FILENAMES]
;
; INPUTS:
;        DEFAULT_PATH -> the default search path to look for FORTRAN files
;
;        DEFAULT_MAIN -> the default name of the main program file. Note
;             that code_tree will not work properly if the main file
;             contains subroutine definitions.
;
; KEYWORD PARAMETERS:
;        /FILENAMES -> display the filename where each routine can be
;             found together with the routine name.
;
; OUTPUTS:
;        A calling tree is generated on the screen or dumped into a file.
;
; SUBROUTINES:
;        several
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        code_tree
;
; MODIFICATION HISTORY:
;       99/5/18 Philip Cameron-Smith, Harvard 
;         Initial code.
;       99/5/21 Philip Cameron-Smith, Harvard 
;         Have included some of my utilities to allow easy distribution.
;         Added '1' to names to ensure no future conflicts.
;       99/5/24 Philip Cameron-Smith, Harvard 
;         Now removes tabs and strings.
;         Various other improvements.
;       99/5/25 Philip Cameron-Smith, Harvard 
;         Reversed order of path and filename arguments
;         Converted a "print" to a "printf,lun" to stop lines running
;         on when printing to a file.
;         Improved check for ENTRY before SUBROUTINE.
;
;-
; Copyright: see below.
;-------------------------------------------------------------


; =================================================================
; ORIGINAL HEADE FROM PJC FOLLOWS HERE
; =================================================================
 
;+

;_TITLE	code_tree
;       This routine produces a tree structure for Fortran programs.

;_ARGS	DIM TYPE      VARIABLE  I/O DESCRIPTION
;        0  string  default_path I  default path for files [optional]
;        0  string  default_main I  default main filename [optional]
;        0  KEYWORD   filenames  I  If set then show file that 
;                                   contains each routine. [optional]

;_VARS	DIM TYPE      VARIABLE I/O DESCRIPTION

;_DESC  This code produces an ASCII tree of the subroutine call
;       structure of FORTRAN code.
;       The calls made by each routine are ordered according to the
;       first time they appear within the routine.
;       The numbers indicate the number of times the subroutine is
;       called from the calling routine.
;       Calls to ENTRY statements are in square brackets.
;       Functions are ignored.

;_FILE	list of files opened (OPTIONAL SECTION)

;_LIMS	Design limitations (OPTIONAL SECTION)
;       ENTRY commands are handled poorly, but they are difficult to
;       handle correctly.
;       FUNCTIONS are ignored completely. They are exceptionally
;       difficult to handle.
;       Preprocessor commands are ignored. I suggest you
;       preprocess the code before running this program.
;       There are bound to be some FORTRAN syntaxes that this program
;       will not handle correctly, but it does try.
;       All source code files must be in the same directory.
;       Only .f and .F file extensions are recognised, but this is
;       easy to fix if necessary.

;_BUGS	Known bugs (OPTIONAL SECTION)
;       If a function is defined after a subroutine within a single
;       file, and the function definition includes a call statement,
;       the call will erroneously be attributed to the previous
;       subroutine. To solve this would require reliable detection of
;       the end of subroutines.

;_HIST	99/5/18 Philip Cameron-Smith, Harvard 
;         Initial code.
;       99/5/21 Philip Cameron-Smith, Harvard 
;         Have included some of my utilities to allow easy distribution.
;         Added '1' to names to ensure no future conflicts.
;       99/5/24 Philip Cameron-Smith, Harvard 
;         Now removes tabs and strings.
;         Various other improvements.
;       99/5/25 Philip Cameron-Smith, Harvard 
;         Reversed order of path and filename arguments
;         Converted a "print" to a "printf,lun" to stop lines running
;         on when printing to a file.
;         Improved check for ENTRY before SUBROUTINE.

;_COPY  Copyright (C) 1999, Philip Cameron-Smith, Harvard University
;       This software is provided as is without any warranty
;       whatsoever. It may be freely used, copied, or distributed
;       for non-commercial purposes. This copyright notice must be
;       kept with any copy of this software. If this software shall
;       be used for any other purpose please contact the author.
;       Bugs and comments may be directed to pjc@io.harvard.edu
;       with subject "IDL routine code_tree"
;
;       This copyright includes all included utilities, unless noted
;       otherwise therein, in which case the utility remains the
;       property of the copyright holder.

;_END
;-

;=============== Start of utilities ====================

PRO CONVERT_TYPE,In_Variable,Type,Out_Variable
;+
;	PROCEDURE CONVERT_TYPE,In_Variable,Type,Out_Variable
;_TITLE	CONVERT_TYPE converts variables to the required type

;_ARGS	TYPE            VARIABLE     I/O  DESCRIPTION
;	UNKNOWN         IN_VARIABLE   !I  Variable to be converted
;       INTEGER         TYPE          !I  Type to convert to      
;       As IN_VARIABLE  OUT_VARIABLE  !O  Variable once converted      
;_VARS	TYPE       VARIABLE I/O	DESCRIPTION

;_DESC  PROC_NAME does ... detailed blah ...

;_FILE	list of files opened

;_LIMS	Design limitations
;         No redimensioning is done

;_BUGS	Known bugs (OPTIONAL SECTION)

;_CALL	List of Calls (OPTIONAL SECTION)

;_KEYS	List of Keys

;_HIST	950405 Philip Smith, Oxford, Original Version

;_END
;-

CASE type OF
    0: STOP,'Expression to be converted is undefined'
    1: out_variable = BYTE(in_variable)
    2: out_variable = FIX(in_variable)
    3: out_variable = LONG(in_variable)
    4: out_variable = FLOAT(in_variable)
    5: out_variable = DOUBLE(in_variable)
    6: out_variable = COMPLEX(in_variable)
    7: out_variable = STRING(in_variable)
    8: STOP,'Structures cannot be converted'
 ENDCASE

RETURN
END


PRO INPUT1,prompt,default,result
;+
;	PROCEDURE INPUT1,prompt,default,result
;_TITLE	INPUT1 is a routine to standardize input.

;_ARGS	TYPE       VARIABLE I/O	DESCRIPTION
;	STRING     prompt    !I Prompt for input
;       UNKNOWN    default   !I Default to return if input is blank
;       AS default result    !O The user input, or default if no input
;_VARS	TYPE       VARIABLE I/O	DESCRIPTION

;_DESC  INPUT1 will display the prompt and default, then read input
;         from the keyboard

;_FILE	

;_LIMS	Design limitations
;       Assumes result must be of same type as default
;       Default must be a single element type

;_BUGS	Known bugs (OPTIONAL SECTION)

;_CALL	List of Calls (OPTIONAL SECTION)

;_KEYS	List of Keys

;_HIST	950405 Philip Smith, Oxford, Original Version

;_END
;-

; dsize contains the size and variable type information about default 
dsize=SIZE(default)
; Complain if default is not a single element
IF (dsize(0) NE 0) THEN STOP,'The default cannot be an array'
IF (dsize(1) EQ 0) THEN STOP,'The default is undefined'
IF (dsize(1) EQ 8) THEN STOP,'The default is not allowed to be a structure'

; user input is read in as a string and converted later
user_input=""                                                          
READ,prompt+" { "+STRTRIM(STRING(default),2)+" } : ",user_input
result=default
IF (user_input NE "") THEN convert_type,user_input,dsize(1),result

RETURN
END


FUNCTION strim1,number, flag, DP=dp
;+ 
; This function converts a number into a string with the leading
; spaces removed. It is very useful when constructing text output for
; plot labels etc.
;
; strim(number) = STRTRIM(STRING(number),FLAG,DP=dp) 
; 
;   FLAG = 0   : Trailing blanks are removed. 
;        = 1   : Leading blanks are removed. 
;        = 2   : Leading & trailing blanks removed. (Default)
;
;   DP = number of decimal places to round to.

; Philip Smith
; AOPP Oxford
; 19/2/96
;-

IF N_ELEMENTS(flag) EQ 0 THEN flag = 2

IF N_elements(DP) NE 0 THEN BEGIN
   number = round_dp(number, dp)
ENDIF

;STRING() of type byte doesn't work, so convert to integer.
number_type = SIZE(number, /tname)
IF number_type EQ 'BYTE' THEN number = FIX(number) 


output_string = STRTRIM(STRING(number),flag)

IF N_elements(DP) NE 0 THEN BEGIN
   IF dp GT 0 THEN BEGIN
      extra_chars = dp+1
   ENDIF ELSE BEGIN
      extra_chars = 0
   ENDELSE
   FOR str_elt=0, N_elements(output_string)-1 DO BEGIN
      dot_pos = STRPOS(output_string[str_elt], '.')
      output_string[str_elt] =  $
         strmid(output_string[str_elt], 0, dot_pos+extra_chars)
   ENDFOR
ENDIF


RETURN, output_string

END

PRO GET_FILENAME1,filenam,default_filename,default_directory, $
       get_path=chosen_path, _EXTRA=extras
;+
;	PROCEDURE GET_FILENAME,filenam,default_filename,default_directory
;_TITLE	GET_FILENAME prompts the user for a directory
;         and a filename.

;_ARGS	TYPE       VARIABLE I/O	DESCRIPTION
;	STRING     FILENAM           !O Filename
;       STRING     DEFAULT_DIRECTORY !I Default directory (optional)
;       STRING     DEFAULT_FILENAME  !I Default filename (optional)
;       STRING     CHOSEN_PATH       !O Path that was chosen (optional)
;       SPECIAL    _EXTRAS           !I extra parameters to be passed
;                                       to dialog_pickfile (optional)

;_VARS	TYPE       VARIABLE I/O	DESCRIPTION

;_DESC  GET_FILENAME prompts the user for a directory
;         and a filename. The procedure should distinguish
;         between UNIX and VMS, and should work with both
;         version 4 and version 5 of IDL.
;       NOTE: useful switches that can be pased to DIALOG_PICKFILE
;         in IDL Version 5 include:
;         /MUST_EXIST to only allow a filename that exists to be chosen
;         FILTER='*.ext'  to specify the default filename filter.
;         
;       This procedure will check the value of the
;         system variable !USE_WIDGETS. This variable was first
;         conceived to allow users of PDP to avoid having to use
;         dialogue boxes if they are operating over a slow network link.
;         IF !USE_WIDGETS is set equal to the value zero then the old
;         text input system will be used. To set !USE_WIDGETS use
;         
;            DEFSYSV, '!USE_WIDGETS', 0
;
;         !USE_WIDGETS should be set before calling get_filename.
;

;_FILE	list of files opened
;         None

;_LIMS	Design limitations

;_BUGS	Known bugs (OPTIONAL SECTION)

;_CALL	List of Calls (OPTIONAL SECTION)
;         INPUT

;_KEYS	List of Keys

;_HIST	950407 Philip Smith, Oxford, Original Version
;       980201 Philip Cameron-Smith, Added option to avoid widgets.

;_END
;-

FORWARD_FUNCTION dialog_pickfile


;; Prior to IDL V5.0 Dialog_Pickfile didn't exist, so if an old version
;; of IDL is being used then we can't use it anyway. We also want to
;; check to see if the !USE_WIDGETS variable is set to 1 or not.
;IF (FIX(!VERSION.RELEASE) GE 5 AND !USE_WIDGETS EQ 1) THEN BEGIN
IF (FIX(!VERSION.RELEASE) GE 5) THEN BEGIN
    use_dialog_pickfile = 1
ENDIF ELSE BEGIN
    use_dialog_pickfile = 0
ENDELSE

; We need to make sure that both default_directory and
; default_filename are defined.
IF (N_ELEMENTS(default_directory) EQ 0) THEN default_directory = ''
IF (N_ELEMENTS(default_filename) EQ 0) THEN default_filename = ''
    
IF ( use_dialog_pickfile EQ 1 ) THEN BEGIN
                                ; IF default_path is specified using a
                                ; ~ then dialog_pickfile gets
                                ; confused. Therefore we shall expand
                                ; the path using a spawn command.
    spawn,['/bin/echo '+default_directory],def_dir,count=count
    default_directory = def_dir(count-1)    
    ; Use IDL 5's DIALOG_PICKFILE widget routine.
    filenam=DIALOG_PICKFILE(PATH=default_directory, $
                            FILE=default_filename, $
                            get_path=chosen_path, _EXTRA=extras)

ENDIF ELSE BEGIN
    ; Use text input.
    
    IF (default_directory EQ '') THEN BEGIN
        CASE !VERSION.OS OF
            'vms'   : default_directory="[]" 
            'linux' : BEGIN                       
                spawn,['pwd'],current_dir,/NOSHELL
                default_directory=current_dir(0)+'/'
            END    
            'OSF'   : BEGIN                       
                spawn,['pwd'],current_dir,/NOSHELL
                default_directory=current_dir(0)+'/'
            END    
            'ultrix': BEGIN                       
                spawn,['pwd'],current_dir,/NOSHELL
                default_directory=current_dir(0)+'/'
            END
        ENDCASE
    ENDIF
    
    IF (default_filename EQ '') THEN default_filename = "filename.tub"
    
    input1,"Directory",default_directory,directory
    input1,"Filename",default_filename,filenam
    
    IF (!version.os_family EQ 'unix' AND STRMID(directory,STRLEN(directory)-1,1) NE '/') THEN BEGIN
        directory=directory+'/'
    ENDIF
    filenam=directory+filenam
ENDELSE

    
RETURN
END

;-------------------------------------------------------------
;+
; NAME:
;        STRWHERE  (function)
;
; PURPOSE:
;        return position *array* for occurence of a character in
;        a string
;
; CATEGORY:
;        string tools
;
; CALLING SEQUENCE:
;        pos = STRWHERE(str, schar [,Count] )
;
; INPUTS:
;        STR -> the string
;
;        SCHAR -> the character to look for
;
; KEYWORD PARAMETERS:
;        none.
;
; OUTPUTS:
;        COUNT -> (optional) The number of matches that were found 
;
;        The function returns an index array similar to the 
;        result of the where function
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        ind = strwhere('abcabcabc','a')
;
;        ; returns [ 0, 3, 6 ]
;
; MODIFICATION HISTORY:
;        mgs, 02 Jun 1998: VERSION 1.00
;        bmy, 30 Jun 1998: - now returns COUNT, the number 
;                            of matches that are found (this is
;                            analogous to the WHERE command)
;
;-
; Copyright (C) 1998, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine strwhere"
;-------------------------------------------------------------


function strwhere,str,schar,Count
 
 
   if (n_elements(str) eq 0) then return,-1
 
   ; convert to byte
   BStr = byte(Str)
   BSC  = (byte(schar))[0]
 
   ; Search for matches
   Ind = where( Bstr eq BSC, Count )

   ;### bmy ### return,where(BStr eq BSC)
   return, Ind

end
   
FUNCTION remove_strings, str_in, delim
;+ 

; This function is designed to remove all parts of the string str_in
; delimited by delim.

; Philip Cameron-Smith, Harvard, 99/5/24
;-
   
   str = str_in  ; isolate str from outside world
   delim_pos = strwhere(str, delim, count)
   FOR delim_num=(count/2)-1, 0, -1 DO BEGIN ; NB start with last string.
      str_left = strmid(str, 0, delim_pos[delim_num*2])
      str_right = strmid(str, delim_pos[delim_num*2+1]+1)
      str = str_left+str_right
   ENDFOR
   RETURN, Str
END


FUNCTION clean_string,str_in
;+ 
   
; This function is designed to eliminate various problems from str:
;    + Convert to uppercase
;    + Convert tabs to spaces
;    + Remove comments
;    + remove strings
;
; Philip Cameron-Smith, Harvard, 99/5/24
;-

   str = str_in  ; isolate str from outside world

;    ++ Convert to uppercase ++
   str = strupcase(str)
   
   
;    ++ Remove comments ++
   exclaim_pos = STRPOS(str,'!') ;Find first exclamation mark
   IF exclaim_pos GE 0 then begin
      str = strmid(str, 0, exclaim_pos-1)
   ENDIF
   
;    ++ remove strings ++
   str = remove_strings(str, "'")
   str = remove_strings(str, '"')

;    ++ Convert tabs to spaces ++
   tab_replacement = '      ' ; String to replace tabs with
   byte_str = byte(str)
   tab_pos = where(byte_str EQ 9B, count) ; Tabs are 9B
   FOR tab_num= 0, count-1 DO BEGIN
      str_left = strmid(str, 0, tab_pos[tab_num])
      str_right = strmid(str, tab_pos[tab_num]+1)
      str = str_left+tab_replacement+str_right
   ENDFOR
     
   RETURN, str
END


; ====================== end of utilities =========================

;+++++++ Start of MAIN CODE +++++++

PRO code_tree, default_path, default_main, filenames=show_filenames

;if N_ELEMENTS(fname_pjc) GT 0 THEN BEGIN
;   input1, 'Scan Files?', 'N', read_files
;   IF STRUPCASE(read_files) EQ 'N' THEN goto, skip_read
;ENDIF

IF N_ELEMENTS(default_main) EQ 0 THEN default_main = 'MAIN.f'
IF N_ELEMENTS(default_path) EQ 0 THEN default_path = '~'
;help, default_main, default_path;debugging {PJC}

PRINT, 'Choose top level procedure (typically called MAIN.f).'
PRINT, 'NB: If this file contains procedures prior to the main'
print, 'code the result may not be reliable.'

GET_FILENAME1, fname_pjc, default_main, default_path, get_path=directory, TITLE="Choose main function", /must_exist, filter='*.[f,F]'
;directory = '~/amalthea/23Layer' ;debugging {PJC}
;MAIN_proc_name = 'MAIN.f' ;debugging {PJC}
last_slash_pos = RSTRPOS(fname_pjc, "/")
IF last_slash_pos GE 0 THEN BEGIN
   MAIN_proc_name = strmid(fname_pjc,last_slash_pos+1)
ENDIF ELSE BEGIN
   MAIN_proc_name = fname_pjc
ENDELSE 
print, "Analysing files in : ", directory
print, "Main file is       : ", MAIN_proc_name

;print, fname_pjc
;print, directory
;print, MAIN_proc_name


; ------ Get list of source files -------
; 'files' includes the path, while 'filenames' contains just the filenames

print
print, 'Getting list of files.'
spawn, 'ls -1 '+directory+'/*.[f,F]', files
num_files = n_elements(files)
last_slash_pos = RSTRPOS(files[0], "/")
filenames = files  ; dimension filenames
FOR file_num=0, num_files-1 DO BEGIN
filenames[file_num] = strmid(files[file_num], last_slash_pos+1)
ENDFOR

; ---- Scan files for procedure names ----

print
PRINT, 'Parse 1: Scanning source code for procedure names.'

dummy = ''
Procedures = [main_proc_name] ; Main has no 'SUBROUTINE' statement so it won't be added again. 
Entries = ['******']
Proc_in_file = [main_proc_name]
Entry_in_file = [main_proc_name]
max_num_calls = -1
FOR file_num=0, num_files-1 DO BEGIN
   print, '.', FORMAT='($,A)'
   IF filenames(file_num) EQ main_proc_name THEN BEGIN ;detect top file
      main_proc = 1
   ENDIF ELSE BEGIN 
      main_proc = 0
   ENDELSE
   openr, lun, files(file_num), /get_lun
;   num_calls = 0
   Calls_temp = ['++++']
   procs_found_in_file = 0
   WHILE NOT EOF(lun) DO BEGIN
      READF, lun, dummy
      dummy = clean_string(dummy)
      first_char = STRMID(dummy, 0, 1)
      IF (first_char NE 'C') THEN BEGIN 
      dummy6 = strim1(strmid(dummy, 6)) ; Eliminate first 6 columns (for 'CALL')
      dummy = strim1(dummy) ; Eliminate leading blanks (for 'SUBROUTINE' & 'ENTRY')
      IF (strmid(dummy, 0, 10) EQ 'SUBROUTINE') THEN BEGIN
         proc_name = strim1(strmid(dummy, 11))
;         print, 'dummy = ',dummy  ;debugging {PJC}
;         print, 'subroutine_pos =', subroutine_pos;debugging {PJC}
;         print, 'proc_name = ', proc_name ;debugging {PJC}
         open_br_pos=STRPOS(proc_name,'(') ;Find first open bracket
         IF open_br_pos GE 0 then begin
            proc_name = strim1(strmid(proc_name, 0, open_br_pos))
         ENDIF
         Procedures = [Procedures, proc_name]
         Proc_in_file = [Proc_in_file, filenames[file_num]]
         max_num_calls = max_num_calls > (N_ELEMENTS(Calls_temp)-1) ;Needed here if more than 1 procedure per file.
;         num_calls = 0
         Calls_temp = ['++']
         main_proc = 0
         procs_found_in_file = procs_found_in_file +1
      ENDIF
      IF (strmid(dummy, 0, 5) EQ 'ENTRY') THEN BEGIN
         IF procs_found_in_file EQ 0 THEN BEGIN
            print
            PRINT, '**** ENTRY found before SUBROUTINE in '+ $
               filenames(file_num)+' ****'
            PRINT, '****       Assuming it is within a FUNCTION ****'
;            PRINT, 'File being read = '+filenames(file_num)
;            RETURN
         ENDIF
            entry_name = strim1(strmid(dummy, 6))
            open_br_pos=STRPOS(entry_name,'(') ;Find first open bracket
            IF open_br_pos GE 0 then begin
               entry_name = strim1(strmid(entry_name, 0, open_br_pos))
            ENDIF
            Entries = [Entries, entry_name]
            Entry_in_file = [Entry_in_file, filenames[file_num]]
      ENDIF
      IF (STRPOS(dummy6, 'CALL') GE 0) then BEGIN
;This is just to get some idea of how large to make the arrays, but is often a large over estimate.
         
         IF (STRMID(dummy6, 0, 4) EQ 'CALL') OR  $
            (STRMID(dummy6, 0, 2) EQ 'IF') OR $
            (STRMID(dummy6, 0, 5) EQ 'WHILE') OR  $
            (STRMID(dummy6, 0, 2) EQ 'DO') OR  $
            (STRMID(dummy6, 0, 6) EQ 'REPEAT') THEN BEGIN
            call_pos = STRPOS(dummy, 'CALL') 
            call_name = strim1(strmid(dummy, call_pos+5)) ;delete 'CALL' and all before.
            open_br_pos=STRPOS(call_name,'(') ;Find first open bracket
            IF open_br_pos GE 0 then begin
               call_name = strim1(strmid(call_name, 0, open_br_pos))
            ENDIF
;print, 'calls_temp =', calls_temp  ; debugging {PJC}
;print, 'call_name =', call_name   ; debugging {PJC}
            repeat_name = WHERE(calls_temp EQ call_name)
            repeat_name = repeat_name[0] ; convert to scalar
            IF repeat_name EQ -1 THEN BEGIN
               calls_temp = [calls_temp, call_name]
;            num_calls = num_calls +1
            ENDIF
         ENDIF 
      ENDIF
      ENDIF
   ENDWHILE
   free_lun, lun
   max_num_calls = max_num_calls > (N_ELEMENTS(Calls_temp)-1)
;print, 'max_num_calls =', max_num_calls ;debugging {PJC}
;wait, 1 ;debugging {PJC}
;   PRINT, files(file_num), NUM_proc_in_file
;STOP, '*** debugging {PJC} ***'
ENDFOR
num_entries = n_elements(Entries)
;print, Procedures

; ---- Scan files for procedure calls ----

print
PRINT, 'Parse 2: Scanning source code for procedure calls.'


num_procedures = N_ELEMENTS(procedures)
proc_tree = intarr(num_procedures, max_num_calls, 2)
Calls_in_Proc = replicate(-1, num_procedures)

Procedure_num = 0
call_num = -1
FOR file_num=0, num_files-1 DO BEGIN
   print, '.', FORMAT='($,A)'
   openr, lun, files(file_num), /get_lun
   IF filenames(file_num) EQ main_proc_name THEN BEGIN ;detect top file
;   IF STRPOS(files(file_num), main_proc_name) GE 0 THEN BEGIN ;detect MAIN.f
      main_proc = 1
   ENDIF ELSE BEGIN
      main_proc = 0
   ENDELSE
   procs_found_in_file = 0
   WHILE NOT EOF(lun) DO BEGIN
      READF, lun, dummy
      dummy = clean_string(dummy)
      first_char = STRMID(dummy, 0, 1)
      IF (first_char NE 'C') THEN BEGIN 
      dummy6 = strim1(strmid(dummy, 6)) ; Eliminate first 6 columns (for 'CALL')
      dummy = strim1(dummy) ; Eliminate leading blanks (for 'SUBROUTINE' & 'ENTRY')
      IF (strmid(dummy, 0, 10) EQ 'SUBROUTINE') THEN BEGIN
         proc_name = strim1(strmid(dummy, 11))
         procedure_num = procedure_num+1
         open_br_pos=STRPOS(proc_name,'(') ;Find first open bracket
         IF open_br_pos GE 0 then begin
            proc_name = strim1(strmid(proc_name, 0, open_br_pos))
         ENDIF
         IF procedures[procedure_num] NE proc_name THEN BEGIN
            STOP, '**** Something has gone wrong. Help. (1) ****'
         ENDIF
         
         call_num = -1
         main_proc = 0
         procs_found_in_file = procs_found_in_file +1
;         print, proc_name
      ENDIF
      IF (STRPOS(dummy6, 'CALL') GE 0) then BEGIN
;         print, dummy  ;debugging {PJC}
         
         IF (STRMID(dummy6, 0, 4) EQ 'CALL') OR  $
            (STRMID(dummy6, 0, 2) EQ 'IF') OR $
            (STRMID(dummy6, 0, 5) EQ 'WHILE') OR  $
            (STRMID(dummy6, 0, 2) EQ 'DO') OR  $
            (STRMID(dummy6, 0, 6) EQ 'REPEAT') THEN BEGIN
;         IF (STRMID(dummy6, 0, 4) EQ 'CALL') OR (STRMID(dummy6, 0, 2) EQ 'IF') THEN BEGIN
         IF (procs_found_in_file EQ 0) AND (main_proc EQ 0) THEN BEGIN
            PRINT
            PRINT, '**** Something is wrong: CALL found before SUBROUTINE ****'
            PRINT, 'This is probably because the file contains a function or'
            PRINT, 'this is a top level file, hence ignoring this call.'
            PRINT, 'File being read = '+filenames(file_num)
         ENDIF ELSE BEGIN
            call_num = call_num+1
            IF MAX_num_calls LT call_num THEN BEGIN
               STOP, '**** Something has gone wrong. Help. (2) ****'
            ENDIF
            call_pos = STRPOS(dummy, 'CALL') 
            call_name = strim1(strmid(dummy, call_pos+5)) ;delete 'CALL' and all before.
            open_br_pos=STRPOS(call_name,'(') ;Find first open bracket
            IF open_br_pos GE 0 then begin
               call_name = strim1(strmid(call_name, 0, open_br_pos))
            ENDIF
;         PRINT, '    '+CALL_NAME
            IF main_proc EQ 1 THEN BEGIN
               proc_idx = 0
            ENDIF ELSE BEGIN
               proc_idx = procedure_num
            ENDELSE
;;;proc_tree = intarr(num_procedures, max_num_calls, 2)
            name_idx = where(procedures EQ call_name)
            name_idx = name_idx[0]
            IF name_idx EQ -1 THEN BEGIN
               name_idx = -1*where(entries EQ call_name) ; Note negation.
               name_idx = name_idx[0]            
               IF name_idx EQ 1 THEN BEGIN
                  PRINT
                  PRINT, '## '+call_name+' not recognised. Assuming it is '+ $
                     'an intrinsic procedure ##'
                  procedures = [procedures, CALL_NAME]
                  proc_in_file = [proc_in_file, 'intrinsic procedure?']
                  name_idx = N_ELEMENTS(procedures)-1
               ENDIF
            ENDIF
;         print, name_idx
            repeat_call_idx = where(proc_tree[proc_idx,*,0] EQ name_idx)
            repeat_call_idx = repeat_call_idx[0]
            IF repeat_call_idx EQ -1 THEN BEGIN
               call_idx = call_num
            ENDIF ELSE BEGIN
               call_idx = repeat_call_idx
               call_num = call_num-1 ;subtract 1 since not a unique call from this routine
            ENDELSE
;         print, proc_name, '   ', call_name, call_num, call_idx ;*** PJC ***
            proc_tree(proc_idx, call_idx, 0) = name_idx
            proc_tree(proc_idx, call_idx, 1) =  $
               proc_tree(proc_idx, call_idx, 1)+1
            Calls_in_Proc[proc_idx] = call_num 
         ENDELSE
         ENDIF
      ENDIF
      ENDIF
   ENDWHILE
   free_lun, lun

ENDFOR
Calls_in_Proc = Calls_in_proc+1 ;Make unity referenced, like N_ELEMENTS

IF calls_in_proc[0] EQ 0 THEN BEGIN
   print
   print
   PRINT, '******** WARNING ********'
   print, 'No calls found from top level file.'
   print, 'This is probably because: '
   print, '     1) This program contains no subroutines.'
   print, '          What is the point of a tree?'
   print, '     2) You have chosen the wrong file.'
   print, '          Run the code again and select the correct file.'
   print, '     3) There are subroutines inside the top level file.'
   print, '          Results may be unreliable !!!!!'
   print, '          The easiest solution is to edit the top level'
   print, '          file and move the subroutines into a different '
   print, '          file. The alternative is to edit code_tree to'
   print, '          handle this possibility, but this will take '
   print, '          some messing around because of the need to '
   print, '          detect the ends of subroutines.'
   print
   print, 'Subroutines found in top level file:'
   top_level_procs = where(proc_in_file EQ main_proc_name, count)
; NB proc_in_file[0] == main_proc_name by construction, and is
; irrelevant here
   IF count GE 2 THEN BEGIN  
      print, procedures[top_level_procs[1:*]]
   ENDIF ELSE BEGIN
      print, '      none'
   ENDELSE
   return
ENDIF

;; ---------- List Procedures and calls ------
;
;openw, lun, 'proc_list.txt', /get_lun
;FOR proc_num=0, num_procedures-1 DO BEGIN
;   PRINTF, lun, procedures[proc_num]
;   FOR call_num=0, Calls_in_Proc[proc_num]-1 DO BEGIN
;      ; Check for whether it is a procedure or an entry:
;      IF proc_tree[proc_num, call_num, 0] GT 0 THEN BEGIN 
;         print_name = procedures[proc_tree[proc_num, call_num, 0]]
;      ENDIF ELSE BEGIN
;         print_name = '['+entries[-1*proc_tree[proc_num, call_num, 0]]+']'
;      ENDELSE
;      ; Add number of calls if more than 1:
;      IF proc_tree[proc_num, call_num, 1] GT 1 THEN BEGIN
;       print_name=' ('+strim1(proc_tree[proc_num, call_num, 1])+') '+print_name
;      ENDIF ELSE BEGIN
;         print_name = '     '+print_name
;      ENDELSE
;
;      printf, lun, print_name
;
;   ENDFOR
;
;ENDFOR
;free_lun, lun

skip_read:

; ----------- Draw Tree Output --------------

start_output:

print
print
input1, 'Procedure to start from. Blank for main. 99 to end', '', top_routine
top_routine = strim1(strupcase(top_routine))
IF top_routine EQ '99' THEN goto, finish
IF top_routine EQ '' THEN BEGIN
   Current_call = [[0, -1]]
ENDIF ELSE BEGIN
   proc_where = where(top_routine EQ procedures, count)
   IF count LE 0 THEN BEGIN
      PRINT, '**** Procedure not recognised ****'
      GOTO, start_output
   ENDIF
   IF count GE 2 THEN BEGIN
      PRINT, '**** Multiple definitions of procedure ****'
      GOTO, start_output
   ENDIF      
   proc_where = proc_where[0]
   Current_call = [[proc_where, -1]]   
ENDELSE

input1, "Filename to print to. Blank for screen.", "", print_file
print
print_to_file = strupcase(strim1(print_file))
IF print_file EQ "" then BEGIN
   lun = -1          ; print to standard out (screen)
ENDIF ELSE BEGIN
   OPENW, lun, print_file, /get_lun   ;open file for output
ENDELSE

; Date stamp output
;DT_TO_VAR, today(), day=day,month=mnth,year=year
;printf, lun, 'Tree produced '+strim1(day)+' '+!MONTH_NAMES[mnth-1]+' '+strim1(year)+'.'
;printf, lun

;Initialise current_call


outer_FINISH = 'FALSE'

WHILE outer_finish EQ 'FALSE' DO BEGIN
;print, 'current_call =', current_call   ; debugging {PJC}
call_depth = N_ELEMENTS(current_call[0, *])-1
call_num = current_call[1, call_depth]

; +++ Print current node +++
FOR depth=0, call_depth-2 DO BEGIN   ;+++ Continue prior branches +++
;   print, 'depth =', depth, ',  current_call =', current_call[*, depth-1];debugging {PJC}
;   print, 'calls_in_proc =', calls_in_proc[current_call[0, depth-1]] ;debugging {PJC}
   printf,lun, '  ', FORMAT='($,A2)'
   IF current_call[1, depth] LT calls_in_proc[current_call[0, depth]]-1 THEN BEGIN
      printf,lun, '|', FORMAT='($,A1)'
   ENDIF ELSE BEGIN
      printf,lun, ' ', FORMAT='($,A1)'
   ENDELSE
   printf,lun, '    ', FORMAT='($,A4)'
ENDFOR

IF call_depth GE 1 THEN BEGIN ; +++ Show current branch +++
;   print, 'call_depth =', call_depth, ',  current_call =', current_call[*, call_depth-1];debugging {PJC}
;   print, 'calls_in_proc =', calls_in_proc[current_call[0, call_depth-1]] ;debugging {PJC}

;   printf,lun, '  ', FORMAT='($,A2)'
   IF proc_tree[current_call[0, call_depth-1], current_call[1, call_depth-1], 1] GT 1 THEN BEGIN ;++ Show number of times called ++
      printf,lun, proc_tree[current_call[0, call_depth-1], current_call[1, call_depth-1], 1], FORMAT='($,I2)'
   ENDIF ELSE BEGIN
      printf,lun, '  ', FORMAT='($,A2)'
   ENDELSE
   IF current_call[1, call_depth-1] LT calls_in_proc[current_call[0, call_depth-1]]-1 THEN BEGIN ;++ show whether last branch from current node ++
      printf,lun, '|', FORMAT='($,A1)'
   ENDIF ELSE BEGIN
      printf, lun, '\', FORMAT='($,A1)'
   ENDELSE
   printf,lun, '----', FORMAT='($,A4)'
;   printf,lun, '-', FORMAT='($,A1)'
;   IF proc_tree[current_call[0, call_depth-1], current_call[1, call_depth-1], 1] GT 1 THEN BEGIN
;      printf,lun, proc_tree[current_call[0, call_depth-1], current_call[1, call_depth-1], 1], FORMAT='($,I2)'
;   ENDIF ELSE BEGIN
;      printf,lun, '--', FORMAT='($,A2)'
;   ENDELSE
;   printf,lun, '-', FORMAT='($,A1)'
ENDIF
IF current_call[0, call_depth] GE 0 THEN BEGIN ; Test whether procedure or entry
   printf,lun, procedures[current_call[0, call_depth]], FORMAT='($,A)';Procedure
ENDIF ELSE BEGIN
   printf,lun, '['+entries[-1*current_call[0, call_depth]]+']', FORMAT='($,A)' ;Entry
ENDELSE
IF keyword_set(show_filenames) THEN BEGIN
   IF current_call[0, call_depth] GE 0 THEN BEGIN ; Test whether procedure or entry
      printf, lun, '   {'+proc_in_file[current_call[0, call_depth]]+'}'
   ENDIF ELSE BEGIN
      printf, lun, '   {'+Entry_in_file[-1*current_call[0, call_depth]]+'}'
   ENDELSE
ENDIF ELSE BEGIN
   printf, lun, format='()'
ENDELSE
;wait, .5                         ;debugging {PJC}

; +++ Ascend as far as necessary: +++

inner_FINISH = 'FALSE'

WHILE inner_finish EQ 'FALSE' DO BEGIN
; Test to see whether there is a another call
   ;; +++ Increment call index: +++
   Current_call[1, call_depth] = Current_call[1, call_depth]+1
   call_num =Current_call[1, call_depth]

   IF current_call[0, call_depth] GE 0 THEN BEGIN  ; Test whether procedure or entry
      IF Current_call[0, call_depth] LT num_procedures THEN BEGIN ;Test whether intrinsic procedure or not
         num_calls_in_proc = calls_in_proc[Current_call[0, call_depth]] ;Procedure
      ENDIF ELSE BEGIN
         num_calls_in_proc = 0 ; Intrinsic procedure
      ENDELSE
   ENDIF ELSE BEGIN
      num_calls_in_proc = 0  ;Entry
   ENDELSE
   IF Current_call[1, call_depth] GT num_calls_in_proc-1 THEN BEGIN
      
;; + Ascend tree +
;      PRINT, 'Ascending ...'   ;debugging {PJC}
      call_depth = call_depth-1      
      IF call_depth EQ -1 THEN BEGIN ; Check to see if we have completed tree.
         inner_finish = 'TRUE'
         outer_finish = 'TRUE'
      ENDIF ELSE BEGIN
      Current_call = current_call[*, 0:call_depth] ; Shrink array
;      call_num = current_call[1, call_depth]+1 ; increment call index
;      current_call[1, call_depth] = call_num
      ENDELSE
   ENDIF ELSE BEGIN
      inner_finish = 'TRUE'
   ENDELSE
      
ENDWHILE
   
IF outer_finish EQ 'FALSE' THEN BEGIN
;; +++  descend tree to next node +++
;PRINT, 'Descending ...' ;debugging {PJC}
Current_call = [[current_call],  $
                [proc_tree[CURRENT_CALL[0, call_depth], call_num], -1]]
ENDIF

;IF call_depth EQ 2 THEN BEGIN      ;debugging {PJC}
;print, 'call_depth =', call_depth, ',  call_num =', call_num
;print, current_call
;STOP, '*** PJC ***'
;ENDIF

ENDWHILE

IF print_file NE "" then BEGIN
   FREE_LUN, lun  ;Free up lun, but only if not stdout.
ENDIF

goto, start_output

finish:

return

END
