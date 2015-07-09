; $Id: idl2html.pro,v 1.2 2007/11/20 21:55:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        IDL2HTML
;
; PURPOSE:
;        Wrapper for MK_HTML_HELP.  Can be used to create HTML files
;        which contain the comments from the standard doc headers
;        that are included with each IDL routine.
;
; CATEGORY:
;        Documentation
;
; CALLING SEQUENCE:
;        IDL2HTML, PATH, [ , Keywords ]
;
; INPUTS:
;        PATH -> A file path (can be a directory, single file name,
;             or file mask) for the IDL routines whose doc headers
;             you wish to convert to HTML format.
;
; KEYWORD PARAMETERS:
;        /ALPHABETICAL -> Set this switch to create a separate HTML 
;             documentation file for files beginning with each letter
;             of the alphabet.  This is useful if you have a lot of
;             files to process.
;
;        /CATEGORY -> If specified, IDL2HTML will create a HTML file
;             for all *.pro files corresponding to a given category
;             (as specified by the CATEGORY tag in the standard
;              IDL documentation headers).
;
;        HTMLFILE -> Name of the HTML file that will be created.
;             A default file name will be used if HTMLFILE is omitted.
;
;        OUTDIR -> Name of the directory into which the HTML
;             documentation files will be written.
;
;        _EXTRA=e -> Passes extra keywords to MK_HTML_HELP.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =======================================================
;        ADD_SEPARATOR (function)   EXTRACT_FILENAME (function)
;        IS_DIR (function)          STRWHERE         (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        IDL2HTML, '~/IDL/tools/', OUTDIR='~/doc/html/', /ALPHABETICAL
;
;             ; Will create HTML files with documentation from the
;             ; IDL routines in the ~/IDL/tools directory.  Will
;             ; place the output in the ~/doc/html directory.
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine idl2html"
;-----------------------------------------------------------------------


pro Idl2Html, Path,                                         $
              Alphabetical=Alphabetical, HtmlFile=HtmlFile, $
              OutDir=OutDir,             Category=Category, $
              _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION Add_Separator, Is_Dir,  Replace_Token, $
                    StrBreak,      StrRepl, StrWhere

   ; error handling since we may use pointers (phs)
   Catch, BUG
   if ( bug ne 0 ) then begin
      cacth,  /cancel
      ptr_free, ptr_valid()      
      return
   endif

   ; Keywords and arguments
   Alphabetical = Keyword_Set( Alphabetical )
   Category     = Keyword_Set( Category )
   if ( N_Elements( OutDir ) eq 0 ) then OutDir = './'
   if ( N_Elements( Path   ) eq 0 ) then Path = Dialog_Pickfile(/Directory) 

   ; Make sure OUTDIR ends w/ a slash
   OutDir = Add_Separator( OutDir )

   ; Get separator character for the given OS
   Sep    = Add_Separator( '' )
 
   ;-------------------------------------------------
   ; Extract the directory name from the path name
   ;-------------------------------------------------

   ; If PATH is a file name, just take the directory part
   if ( Is_Dir( Path ) )                                   $
      then Dir     = Path                                  $
      else TmpFile = Extract_FileName( Path, FilePath=Dir )

   ; Get the length of PATHDIR
   Len = StrLen( Dir )

   ; Find the locations of the separator in PATHDIR
   Ind = StrWhere( Dir, Sep, C )
 
   ; Extract the text from the last separator to the end of the file
   ; If the text ends in a separator, then ignore that
   if ( Ind[C-1]+1 eq Len )                                     $ 
      then Dir = StrMid( Dir, Ind[C-2]+1, Ind[C-1]-Ind[C-2]-1 ) $
      else Dir = StrMid( Dir, Ind[C-1]+1, Len-Ind[C-1]+1      )

   ;====================================================================
   ; Create HTML doc files with IDL header info
   ;====================================================================
 
   ; Split by the 1st letter of each file name
   if ( Alphabetical ) then begin

      ;-------------------------------------------------
      ; New HTML file for each letter of the alphabet
      ;-------------------------------------------------
 
      ; Lowercase letters
      Alpha = [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', $
                'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', $
                's', 't', 'u', 'v', 'w', 'x', 'y', 'z' ]
 
      ; Default HTML file name
      if ( N_Elements( HtmlFile ) eq 0 ) $
         then HtmlFile = Dir + '_%LETTER%.html'
 
      ; Loop thru the letters
      for A = 0L, N_Elements( Alpha )-1L do begin
 
         ; Find files starting /w each letter of the alphabet
         F1    = MFindFile( Path + Sep +            Alpha[A]   + '*' )
         F2    = MFindFile( Path + Sep + StrUpCase( Alpha[A] ) + '*' ) 
         Files = [ F1, F2 ]

         ; If there are matching files
         if ( N_Elements( Files ) gt 0 ) then begin
 
            ; Replace token in the output file name
            OutFile = OutDir + Replace_Token( HtmlFile, 'LETTER', Alpha[A] )
 
            Title = StrUpCase( Alpha[A] ) + ' routines in ' + Dir + '/'

            ; Write IDL doc headers in FILES to an HTML file
            Mk_Html_Help, Files, OutFile, Title=Title, _EXTRA=e

          endif
      endfor

   endif else if ( Category ) then begin

      ;-------------------------------------------------
      ; New HTML file for each category
      ;-------------------------------------------------

      ;; find all *.pro files.
      ;; for IDL 5.5 and above only since FILE_SEARCH is used
      ;; to search all subdirectories.
      FLIST = File_Search( Path, '*.pro', count=count )

      if count eq 0 then begin
         print, 'No file... HTML file not created'
         return
      endif else print, 'Found '+strtrim(count, 2)+' files.'

      ; Default HTML file name
      if ( N_Elements( HtmlFile ) eq 0 ) $
         then HtmlFile = Dir + '_%CAT%.html'


      ;; --- Get category for each routine/file
      str = ' '
      allcateg = [' ']
      categ = ptrarr(count, /allocate)  
      ; allows for more than one category per routine

      for klm=0L, count-1L do begin
         openr, lun, flist[klm], /get_lun

         while ( not EOF( LUN ) and $
                 not stregex(str, '; *CATEGORY', /fold_case, /boolean ) ) do $

            readf, lun, str

         if eof(lun) then begin 
            *categ[klm] = ['NO CATEGORY']
            allcateg = [allcateg, 'NO CATEGORY']
         endif else begin

            readf, lun, str
            str = strUpCase( strcompress(str) )

            ;; extract categories. Can probably be improve, maybe w/
            ;; stregex or /reg in strsplit ??
            ;; Will require some standard in possible category name.
            ;; NOTE: DO NOT USE WHITE SPACES TO SEPARATE CATEGORIES
            *categ[klm] = StrTrim( StrBreak( str, ';.:,-' ), 2 )
            allcateg = [ allcateg, *categ[klm] ]

         endelse

         free_lun, lun
      endfor
      allcateg = allcateg[1:*]

      ;; --- Get the list of category
      
      CategUniq = allcateg[ Uniq(allcateg, sort(allcateg)) ]
      ncat      = n_elements(CategUniq)

      Print, 'Found ' + strtrim(ncat) + 'categories:'
      Print,  transpose(categuniq)    



      ;; ---  Loop thru the categories
      badcat = ['O', 'OR', 'TWO','I', 'PUT', 'FOR', 'HERE',  $
                'D', 'AND', 'A', '3', '5']

      for A = 0L, ncat-1L do begin

         ; kludge to disregard some category
         dummy = where(badcat eq categuniq[a], one)
         if one eq 0 then begin
 
            Files  = ''

            ;; Find files w/ category
            for klm=0l, count-1l do begin
               dummy = where(*categ[klm] eq categuniq[a], one)
               if one ne 0 then Files = [Files, Flist[klm]]
            endfor

            ; Replace some bad chars in the file name for Unix
            CleanCat = StrRepl( CATEGUNIQ[A], '&',  '-' )
            CleanCat = StrRepl( CleanCat,     '/',  '-' )

            ;; Replace token in the output file name
            OutFile = OutDir + $
               Replace_Token( HtmlFile, 'CAT',  $
                              ;StrCompress(CATEGUNIQ[A], /remove_all) )
                              StrCompress( CleanCat, /remove_all) ) 

            ; Echo info
            Message, 'Creating ' + StrTrim( OutFile, 2 ), /Info

            Title = StrUpCase( categUniq[A] ) + ' routines in ' + Dir

            ;; Write IDL doc headers in FILES to an HTML file
            Mk_Html_Help, Files[1:*], OutFile, Title=Title, _EXTRA=e

         endif
         
      endfor
      

   endif else begin

      ;-------------------------------------------------
      ; One HTML file for all of the entries in PATH
      ;-------------------------------------------------

      ; Create an HTML file w/ header info
      Mk_Html_Help, Path, HtmlFile, _EXTRA=e

   endelse 

   ; clean up
   ptr_free, ptr_valid()

end
