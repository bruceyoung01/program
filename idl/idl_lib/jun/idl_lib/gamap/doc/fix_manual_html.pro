; $Id: fix_manual_html.pro,v 1.1 2008/04/23 20:18:56 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        FIX_MANUAL_HTML
;
; PURPOSE:
;        Removes text from the GAMAP manual pages that is
;        automatically inserted by IDL's MK_HTML_HELP routine,
;        and replaces them 

;        ar
;
; CATEGORY:
;        Documentation
;
; CALLING SEQUENCE:
;        FIX_MANUAL_HTML
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ======================================================
;        EXTRACT_FILENAME (function)   EXTRACT_PATH (function)
;        MFINDFILE        (function)   OPEN_FILE    
;        REPLACE_TOKEN    (function)
;
; REQUIREMENTS:
;        Requires routines from the GAMAP package
;
; NOTES:
;        Also see routines GAMAP2_HTML and IDL2HTML.
;
; EXAMPLE:
;        GAMAP2_HTML, /ALL,         OUTDIR='manual/html/all'
;        GAMAP2_HTML, /BY_CATEGORY, OUTDIR='manual/html/by_category'
;        GAMAP2_HTML, /BY_ALPHABET, OUTDIR='manual/html/by_alphabet'
;        FIX_MANUAL_HTML
;
;             ; Creates GAMAP manual pages (HTML format) and then
;             ; removes unwanted text that is automatically added
;             ; by IDL's MK_HTML_HELP routine.
;
; MODIFICATION HISTORY:
;        bmy, 23 Apr 2008: GAMAP VERSION 2.12
;
;-
; Copyright (C) 2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to yantosca@seas.harvard.edu
; or plesager@seas.harvard.edu with subject "IDL routine fix_manual_html"
;-----------------------------------------------------------------------


pro Replace_HTML, File, Repl_Text
 
   ;=====================================================================
   ; Internal routine REPLACE_HTML removes unwanted extra text in a
   ; HTML file that was created by MK_HTML_HELP and replaces that with 
   ; a more useful set of hyperlinks. (bmy, 4/23/08)
   ;=====================================================================
 
   ; Echo info
   Print, 'Editing ' + Extract_FileName( File )
      
   ; Hardwire input & output file units
   Ilun_IN  = 1
   Ilun_OUT = 2
 
   ; Directory where HTML file is located
   Dir = Extract_Path( File )
   
   ; Temporary file name
   TmpFile = Dir + 'temphtml'
 
   ; Open files for input & output
   Open_File, File,    Ilun_IN
   Open_File, TmpFile, Ilun_OUT, /Write
   
   ; Character string
   Line = ''
 
   ; Get the file name sans HTML
   HtmlName = Extract_FileName( File )
   HtmlName = Replace_Token( HtmlName, '.html', '',  Delim='' )
   HtmlName = Replace_Token( HtmlName, '_',  '&nbsp;', Delim='' )
 
   ; Loop thru the input HTML file
   while ( not EOF( Ilun_IN ) ) do begin
     
      ; Read a line from the file
      ReadF, Ilun_IN, Line
 
      ; Remove the "in */" from "A ROUTINES in */" for example
      Line = Replace_Token( Line, ' in */', '',  Delim = '')
 
      ; Remove "Extended IDL help" text
      Line = Replace_Token( Line, 'Extended IDL Help', $
                            HtmlName, Delim='')
      
      ; Make sure we have a white background
      Line = Replace_Token( Line, '<body>', $
                            '<body bgcolor="#FFFFFF">', Delim='')
      
      ; Remove boilerplate text added by MK_HTML_HELP
      Line = Replace_Token( Line, $
                'This page was created by the IDL library routine', $
                '',  Delim = '')
 
      Line = Replace_Token( Line, $
                '<CODE>mk_html_help</CODE>.  For more information on', $
                '',  Delim = '')
 
      Line = Replace_Token( Line, $
                'this routine, refer to the IDL Online Help Navigator', $
                '',  Delim = '')
 
      Line = Replace_Token( Line, $
                'or type: <P>', $
                '',  Delim = '')
 
      Line = Replace_Token( Line, $
                '<PRE>     ? mk_html_help</PRE><P>', $
                '',  Delim = '')
 
      Line = Replace_Token( Line, $
                'at the IDL command line prompt.<P>', $
                '',  Delim = '')
 
      ; Insert the replacement texta above the "Last modified" string
      if ( StrPos( Line, 'Last modified' ) ge 0 ) then begin
         for N=0, N_Elements( Repl_Text )-1L do begin
            PrintF, Ilun_OUT, Repl_Text[N]
         endfor
      endif
 
      ; Write to new HTML file
      PrintF, Ilun_OUT, Line
 
   endwhile
 
Quit:
   ; Cleanup and quit
   Close, Ilun_IN
   Close, Ilun_OUT
 
   ; Replace the original HTML file w/ the temporary file
   Spawn, 'mv ' + TmpFile + ' ' + File
end
 
;------------------------------------------------------------------------------
 
pro Fix_Manual_Html
 
   ;=====================================================================
   ; Initialization
   ;=====================================================================

   ; External functions
   FORWARD_FUNCTION Extract_FileName, Extract_Path, $
                    MFindFile,        Replace_Token

   ; File with replacement HTML
   FileRepl = File_Which( 'gamap_manual_replace.html' )
   
   ;Initialize
   N    = 0
   Ilun = 1
   Line = ''
   Repl_Text = StrArr( 200 )
 
   ; Open replacement text file
   Open_File, FileRepl, Ilun
      
   ; Read the replacement HTML code into a string array
   while ( not EOF( Ilun ) ) do begin
      ReadF, Ilun, Line
      Repl_Text[N] = Line
      N += 1
   endwhile
 
   ; Close file
   Close, Ilun
 
   ; Resize array
   Repl_Text = Repl_Text[0:N-1]
 
   ;=====================================================================
   ; Replace HTML code for All GAMAP Routines
   ;=====================================================================
 
   ; Get a list of all ifles
   List = MFindFile( '~/IDL/gamap2/manual/html/all/*.html')
 
   ; Replace HTML 
   for F = 0L, N_Elements( List )-1L do begin
      Replace_HTML, List[F], Repl_Text
   endfor
 
   ;=====================================================================
   ; Replace HTML code for GAMAP routines by Alphabet
   ;=====================================================================
 
   ; Get a list of all ifles
   List = MFindFile( '~/IDL/gamap2/manual/html/by_alphabet/*.html')
 
   ; Replace HTML 
   for F = 0L, N_Elements( List )-1L do begin
      Replace_HTML, List[F], Repl_Text
   endfor
 
   ;=====================================================================
   ; Replace HTML code for GAMAP routines by Category
   ;=====================================================================
 
   ; Get a list of all ifles
   List = MFindFile( '~/IDL/gamap2/manual/html/by_category/*.html')
 
   ; Replace HTML 
   for F = 0L, N_Elements( List )-1L do begin
      Replace_HTML, List[F], Repl_Text
   endfor
 
end
