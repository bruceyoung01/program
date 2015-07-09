;-------------------------------------------------------------
; $Id: default_dirs.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $
;+
; NAME:
;        DEFAULT_DIRS
;
; PURPOSE:
;        Define a couple of system variables to facilitate 
;        file searching across or in multiple platforms.
;        The settings are made depending on the host name which
;        is queried with getenv(). 
;          This file is meant to be modified for your own computing
;        environment and directory structure. It's probably a good 
;        idea to include a call to Default_Dirs in your startup file.
;        A string (or string array) argument allows individual users
;        to add their own default settings for individual projects
;        (see INPUTS).
;
; CATEGORY:
;        Administrative Tools
;
; CALLING SEQUENCE:
;        DEFAULT_DIRS [,projectlist [,searchpath=searchpath] ]
;
; INPUTS:
;        PROJECTLIST -> A string or string array containing the names
;            of projects of individual users for which additional
;            settings shall be made. For each entry for which a procedure
;            named default_<projectname>.pro exists, this procedure
;            will be called with the host name (lower case) as argument.
;            If the procedure is not found, a warning message is issued.
;
; KEYWORD PARAMETERS:
;        SEARCHPATH -> A string that will be inserted at the beginning 
;            of the !PATH variable to look for the default_<projectname>
;            procedures. This keyword is only evaluated when a
;            PROJECTLIST is present. For simplicity, the user must make sure
;            that SEARCHPATH adheres to the syntax of the curent OS. Since
;            DEFAULT_DIRS is usually caled from the startup file, this
;            shouldn't be too much of a problem.
;           
;         /PRINT -> print all system variables ending in 'DIR' after
;            the definition. 
;
; OUTPUTS:
;        Various system variables are created. As a minimum, these are
;          !RootDir = the root of the file system
;          !HomeDir = the user's home directory
;          !DataDir = a general data depository
;          !TmpDir  = a temporary directory
;
;          !FNSep   = filename seperator ('/' for unix and '\' for windows)
;
;        Further project-specific directories should also end in 'Dir',
;        this allows an easy query of all default directories:
;          help,/system_variables,output=o
;          print,o[ where(strpos(o,'DIR') gt 0) ]
;        (see PRINT keyword).
; *******  NEED TO WORK THAT OUT !! ******  it's not that easy !!!  *********
;
; SUBROUTINES:
;        none.
;
; REQUIREMENTS:
;        none.
;
; NOTES:
;        This routine uses a common block (yes!) to remember whether
;        the user had already been warned about non-exisiting project
;        procedures. Therefore, when you add projects on the fly,
;        you can probably call default_dirs safely every time you wish 
;        to compose a search mask.
;
; EXAMPLE:
;        default_dirs    ; set platform dependent default directories
;
;        default_dirs,['GTE','CTM'],searchpath='~/myprogs',/PRINT
;        ; as above, but add definitions from default_gte.pro and
;        ; default_ctm.pro which may be in ~/myprogs or the regular
;        ; IDL search !PATH. Print all !...DIR system variables upon 
;        ; exit. See attached default_gte procedure for an example.
;
; MODIFICATION HISTORY:
;        mgs, 12 May 1999: VERSION 1.00
;
;-
; Copyright (C) 1999, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine default_dirs"
;-------------------------------------------------------------


pro default_dirs,ProjectList,SearchPath=SearchPath,Print=DoPrint


COMMON Default_DirsCom,AlreadyWarned

   if (n_elements(AlreadyWarned) eq 0) then AlreadyWarned = 0

   DoPrint = keyword_set(DoPrint)
 
   ; Are we on a windows or unix platform (no IDL macs around here)
   IsWindows = ( strupcase(!Version.OS_Family) eq 'WINDOWS' )
   IsUnix    = ( strupcase(!Version.OS_Family) eq 'UNIX' )
 
 
   ; ====  Determine host:  ====
   ; Generally one should do  host = getenv('HOSTNAME') or getenv('HOST')
   ; but somehow you have to make sure to capture all varieties in your
   ; computing environment. If we get no answer from either of the two
   ; environment variables, we assume that we are on sol (our SGI Unix
   ; platform here at Harvard). *** DOES WINDOWS RETURN A HOST ? ***
 
   Default_WindowsHost = 'cyclope' 
   Default_UnixHost = 'sol'
   Default_MacHost = '***unknown***'
 
 
   host = getenv('HOSTNAME')
   if (strtrim(host,2) eq '') then begin
      host = getenv('HOST')
      if (strtrim(host,2) eq '') then begin
          if (DoPrint) then $
             print,'no host from environment variables. IsWindows=',IsWindows         
          if (IsWindows) then $
             host = Default_WindowsHost  $
          else if (IsUnix) then $
             host = Default_UnixHost  $
          else  $
             host = Default_MacHost  
      endif
   endif
 
 
   ; ====  Define a number of system variables for easier access to 
   ;       your data  ====

   ; Always use host name in lower case
   ; and strip host from '.'
   host = strlowcase(host)
   p = strpos(host,'.')
   if (p gt 0) then $
       host = strmid(host,0,p)
 
   if (DoPrint) then print,'Hostname = ',host
 
   ; The following section depends on your environment of course
   ; For our purposes we define the following default directories:
   ; === general directories ===
   ; !RootDir
   ; !HomeDir
   ; !DataDir
   ; !TmpDir
   ; !WinDir     for dual boot machines - used internally
   ; and !FNSep which contains '/' for Unix and '\' for Windows (Mac ??)
 
 
   If (IsWindows) then $
      defsysv,'!FNSep','\'  $
   else $
      defsysv,'!FNSep','/'
 
 
 
   case (host) of
 
      'cyclope' : begin                        ; cyclope runs dual boot
                     if (IsWindows) then begin   
                         defsysv,'!RootDir','c:'
                         defsysv,'!HomeDir',!RootDir
                         defsysv,'!DataDir',!RootDir+!FNSep+'data'
                         defsysv,'!TmpDir',!RootDir+!FNSep+'tmp'
                     endif else begin
                         defsysv,'!RootDir',''  ; have to add !FNSep anyway
                         defsysv,'!HomeDir','~'
                         defsysv,'!WinDir','/win95'
                         defsysv,'!DataDir',!WinDir+!FNSep+'data'
                         defsysv,'!TmpDir',!WinDir+!FNSep+'tmp'
                     endelse
                  end
   
      'sol'     : begin                        ; unix IDL workgroup server
                         defsysv,'!RootDir',''  ; have to add !FNSep anyway
                         defsysv,'!HomeDir','~'
                         defsysv,'!DataDir',!RootDir+!FNSep+'data'
                         defsysv,'!TmpDir',!RootDir+!FNSep+'scratch'
                  end
 
       else     : begin
                     message,'Unknown host! Using minimal default set of '+ $
                         'default directories for a generic unix machine.', $
                         /INFO
                         defsysv,'!RootDir',''  ; have to add !FNSep anyway
                         defsysv,'!HomeDir','~'
                         defsysv,'!DataDir',!HomeDir+!FNSep+'data'
                         defsysv,'!TmpDir',!RootDir+!FNSep+'tmp'
                  end
 
   endcase


   ; ====  look for project related default procedures  ====
   if (n_elements(ProjectList) gt 0) then begin
       oldPath = !PATH
       if (n_elements(SearchPath) gt 0) then $
           !PATH = SearchPath[0] + !PATH

       for i = 0,n_elements(ProjectList)-1 do begin

           ; construct filename for default procedure
           defpro = 'default_'+strlowcase(ProjectList[i])

           ; establish error handler -- this is likely to go wrong
           CATCH,errcode

           if (errcode ne 0) then begin
              if (not AlreadyWarned) then $ 
                  message,'Could not call procedure '+defpro+ $
                      '! Reason='+strtrim(errcode,2),/Continue
              goto,Skip_It
           endif

           ; try to call project specific default procedure
           call_procedure,defpro,host

           CATCH,/cancel

Skip_It:
       endfor

       !PATH = oldPATH
   endif


   ; ====  finally print all default directories if requested  ====
   if (keyword_set(DoPrint)) then begin 
      help,/system_variables,output=o
      print,o[ where(strpos(o,'DIR') gt 0) ]
   endif

 
return
end
 
