; $Id: gamap2_manual_create.pro,v 1.2 2008/07/01 15:15:38 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GAMAP2_MANUAL_CREATE
;
; PURPOSE:
;        This routine creates the HTML documentation pages for each of
;        the GAMAP routines.  This is a convenience wrapper routine
;        which calls both GAMAP2_HTML and FIX_MANUAL_HTML.
;
; CATEGORY:
;        Documentation
;
; CALLING SEQUENCE:
;        GAMAP2_MANUAL_CREATE
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
;        External Routines Required:
;        ============================
;        GAMAP2_HTML
;        FIX_MANUAL_HTML
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Will save output to the ../manual/html/* directories.
;
; EXAMPLES:
;        GAMAP2_MANUAL_CREATE
;
;             ; Creates HTML documentation from the std headers to
;             ; each of the IDL source code programs in the GAMAP 
;             ; installation.  Writes output to the manual/html
;             ; directory. 
;
; MODIFICATION HISTORY:
;        bmy, 01 Jul 2008: GAMAP VERSION 2.12
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
; or plesager@seas.harvard.edu with subject "IDL routine gamap2_html"
;-----------------------------------------------------------------------


pro Gamap2_Manual_Create

   ; Directory for HTML manual pages
   Dir = Program_Dir( Routine_Name() + '.pro' ) + '../manual/html/'

   ; Create manual pages
   Gamap2_Html, /All,         OutDir=Dir+'all'
   Gamap2_Html, /By_Category, OutDir=Dir+'by_category'
   Gamap2_Html, /By_Alphabet, OutDir=Dir+'by_alphabet'

   ; Edit the headers to remove ugly junk that is automatically
   ; placed there by IDL_HTML_HELP
   Fix_Manual_Html

end
