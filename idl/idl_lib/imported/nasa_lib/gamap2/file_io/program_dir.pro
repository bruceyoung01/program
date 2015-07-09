; $Id: program_dir.pro,v 1.1.1.1 2007/07/17 20:41:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PROGRAM_DIR
;
; PURPOSE:
;        Given a file, returns the directory in which the file resides.
;
; CATEGORY:
;        File & I/O
;
; CALLING SEQUENCE:
;        RESULT = PROGRAM_DIR( FILE [, Keywords ] )
;
; INPUTS:
;        FILE -> Name of the file for which a directory search
;             will be performed.
;
; KEYWORD PARAMETERS:
;        /FULL_PATH -> Set this switch to return the directory
;             name as an absolute path (e.g. /users/home/IDL/) 
;             instead of a relative path (e.g. ~/IDL).
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        EXPAND_PATH      (function) 
;        EXTRACT_FILENAME (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Unix is case-sensitive.  It is recommended to keep 
;            file names in all lowercase on Unix to avoid file 
;            search confusion.
;
; EXAMPLES:
;        (1) 
;        PRINT, PROGRAM_DIR( 'myct.pro' )
;           ~/IDL/tools/
;
;            ; Finds the directory in which "myct.pro" resides.
;
;        (2)
;        PRINT, PROGRAM_DIR( 'myct.pro', /FULL_PATH )
;           /users/ctm/bmy/IDL/tools
;
;            ; Same as the above example, but this time returns
;            ; the directory as an absolute path name.
;
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2002-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine program_dir"
;-----------------------------------------------------------------------


function Program_Dir, File, Full_Path=Full_Path
 
   ; External functions
   FORWARD_FUNCTION Expand_Path, Extract_FileName
 
   ; Given the file name, find its full path
   FileName = File_Which( File, /Include_Current_Dir )
 
   ; Extract the directory part from the full file path
   TmpFile  = Extract_FileName( FileName, FilePath=DirName )
 
   ; If /FULL_PATH is set, convert to an absolute path
   if ( Keyword_Set( Full_Path ) ) then DirName = Expand_Path( DirName )
 
   ; Return to calling program
   return, DirName

end
