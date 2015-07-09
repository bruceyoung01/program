; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;+
; NAME:
;     FINDFILES
;
; PURPOSE:
;     Find all files matching a file filter.  Replacement for the 
;     IDL builtin routine FILEFILE, which does not handle recursive
;     search of directories correctly.
;
;     Currently implemented for UNIX and VMS systems only.  For Windows
;     and MacOS, this routine is a wrapper for FINDFILE.
;
; TYPE:
;     FUNCTION
;
; CATEGORY:
;     FILES
;
; CALLING SEQUENCE:
;     result = FINDFILES (fileFilter [, /RECURSE, ROOT = root, COUNT = count])
;
; INPUTS:
;     fileFilter: Optional STRING denoting the file filter used in the search.
;                 Any valid system command interpreter wildcards can be used.  
;                 If not supplied, one of the following is used:
;                     UNIX: '*'
;                    MACOS: '*'
;                      VMS: '*.*'
;                  WINDOWS: '*.*'
;
; KEYWORD PARAMETERS:
;
;     RECUSE: Set this keyword to search recursively for matching files.
;       ROOT: Set this keyword to a STRING denoting the directory from which
;             to start the search.  If not supplied, the current directory
;             is used.
;      COUNT: A named variable into which the number of files found is placed.
;             If no files are found, a value of 0 is returned.
;
; OUTPUTS:
;     result: STRARR of matching files, or NULL string if no files are found.
;
; COMMON BLOCKS:
;     NONE
;
; SIDE EFFECTS:
;     None known
;
; RESTRICTIONS:
;     None known
;
; DEPENDENCIES:
;     NONE
;
; MODIFICATION HISTORY:
;     Written, 1998 May, Robert.Mallozzi@msfc.nasa.gov
;
;-
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

FUNCTION FINDFILES, fileSpec, RECURSE = recurse, ROOT = root, COUNT = count

    
    doRecurse = KEYWORD_SET (recurse)

    IF (N_ELEMENTS (root) NE 0) THEN BEGIN
       searchDir = root
    ENDIF ELSE BEGIN
       CD, CURRENT = searchDir
    ENDELSE

        
    CASE (STRUPCASE (!VERSION.OS_FAMILY)) OF
    
        'UNIX': BEGIN
            
            IF (N_ELEMENTS (fileSpec) EQ 0) THEN $
               fileSpec = '*'

            IF (doRecurse) THEN BEGIN
            
               command = 'find ' + searchDir + $
                   ' -name "' + fileSpec + '"'
            
            ENDIF ELSE BEGIN
                        
               command = 'find ' + searchDir + $
                   ' -maxdepth 1 -name "' + fileSpec + '"'

            ENDELSE     
            
            SPAWN, /SH, command, result
            END
            
        'VMS': BEGIN
        
            IF (N_ELEMENTS (fileSpec) EQ 0) THEN $
               fileSpec = '*.*'

            IF (doRecurse) THEN BEGIN
               
               command = STRMID (searchDir, 0, STRLEN (searchDir) - 1) + $
                  '...]' + fileSpec
            
            ENDIF ELSE BEGIN
                        
               command = fileSpec

            ENDELSE     
            
            result = FINDFILE (command)
            END
            
        'MACOS': BEGIN
        
            IF (N_ELEMENTS (fileSpec) EQ 0) THEN $
               fileSpec = '*'

            result = FINDFILE (fileSpec)
            END
                   
        'WINDOWS': BEGIN
        
            IF (N_ELEMENTS (fileSpec) EQ 0) THEN $
               fileSpec = '*.*'

            result = FINDFILE (fileSpec)
            END
         
        ELSE: MESSAGE, 'Unsupported operating system.' 

    ENDCASE
    
    IF (result[0] EQ '') THEN BEGIN
       count = 0L 
    ENDIF ELSE BEGIN
       count = N_ELEMENTS (result)
    ENDELSE    
    
    
    RETURN, result 

END

