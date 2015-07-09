; $Id: mfindfile.pro,v 1.3 2004/06/03 18:01:27 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MFINDFILE
;
; PURPOSE:
;        Find all the files that match a given specification.
;        MFINDFILE is a wrapper for IDL routines FILE_SEARCH 
;        (v5.5 and higher) and FINDFILE (v5.4 and lower).
;
; CATEGORY:
;        System routines
;
; CALLING SEQUENCE:
;        LISTING = MFINDFILE( MASK )
;
; INPUTS:
;        FILEMASK -> a path and filename specification to look for.
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        A string list containing all the files that match the 
;        specification.
;
; SUBROUTINES:
;        External Routines Required:
;        ===========================
;        ADD_SEPARATOR (function)
;
; REQUIREMENTS:
;        References routines from the TOOLS package.
;
; NOTES:
;        (1) For IDL 5.5+, use FILE_SEARCH to return a listing of
;            files with the given path name specified by MASK.  This
;            should work regardless of platform.
;
;        (2) For IDL 5.4- running under Unix, The built-in FINDFILE() 
;            function has problems on whenever a lot of files are 
;            matching the file specification.  This is due to the fact 
;            that filename expansion is done by the shell before 
;            interpreting a command.  Too many files cause too long 
;            commands which are not accepted.  This causes FINDFILE() 
;            to return an empty list of candidates. (cf. www.dfanning.com)
;            
;            Therefore, we implement a workaround where we issue a
;            "ls -1" command under the Unix shell.  This isn't 100%
;            foolproof either but it's better than nothing.
;
;        (3) For IDL 5.5- running under other operating systems,
;            call the built-in IDL FINDFILE routine as usual.
;
; EXAMPLE:
;        LIST = MFINDFILE( '~mgs/terra/chem1d/code/*.f' )
;
;        ; returns all fortran files in Martin's chem1d directory.
;
; MODIFICATION HISTORY:
;        mgs, 14 Sep 1998: VERSION 1.00
;        bmy, 14 Oct 2003: TOOLS VERSION 1.53
;                          - Now use built-in FINDFILE() routine to
;                            return file listing for IDL 5.3 and higher
;        bmy, 06 Nov 2003: TOOLS VERSION 2.01
;                          - return to pre v1-53 algorithm
;        bmy, 28 May 2004: TOOLS VERSION 2.02
;                          - For IDL 5.5+, now use FILE_SEARCH to return
;                            a list of files corresponding to MASK
;    
;-
; Copyright (C) 1998, 2003, 2004,
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine mfindfile"
;-----------------------------------------------------------------------


function MFindFile, Mask, _EXTRA=e
 
   ; External functions
   FORWARD_FUNCTION Add_Separator

   ;====================================================================
   ; For IDL versions 5.5 and higher, we can use FILE_SEARCH, which 
   ; is much more platform-independent than FINDFILE (bmy, 5/28/04)
   ;====================================================================
   if ( Float( !VERSION.RELEASE ) ge 5.5 ) then begin

      ; Return file listing (bmy, 5/28/04)
      return,  File_Search( Mask, _EXTRA=e )

   endif

   ;====================================================================
   ; For IDL versions 5.4 and lower, proceed as follows:
   ;====================================================================
   if ( !VERSION.OS_FAMILY eq 'unix' ) then begin

      ;-----------------------------------------------------------------
      ; Special treatment for IDL running under UNIX:
      ;
      ; The workaround is to spawn a "ls -1" command under Unix 
      ; instead of using the built-in FINDFILE command (mgs, 09/14/98)
      ;
      ; In some versions of IDL, the EXPAND_PATH seems to truncate 
      ; any trailing "/" characters in the directory path name.  Call
      ; ADD_SEPARATOR to restore the "/" if necessary (bmy, 11/4/03)
      ;-----------------------------------------------------------------

      ; Separate MASK into file path and file mask
      Path = Extract_Path( Mask, FileName=FName )
      
      ; Expand again (i.e. replace "~" w/ the path)
      Path = Add_Separator( Expand_Path( Path ) )

      ; NEWPATH is now the expanded file path + file mask
      NewPath = Path + FName
         
      ; Spawn a Unix ls command
      Command = 'ls -1'
      CStr    = Command + ' ' + NewPath
      Spawn, CStr, Listing

      ; Return to calling program
      return, Listing

   endif else begin             
    
      ;-----------------------------------------------------------------
      ; For other OS's, use IDL's built-in FINDFILE function
      ;-----------------------------------------------------------------

      return, FindFile( Mask )
      
   endelse

end
 
