; $Id: gamap2_html.pro,v 1.8 2007/11/20 21:55:29 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GAMAP2_HTML
;
; PURPOSE:
;        Wrapper routine for IDL2HTML.  Is used to call IDL2HTML 
;        repeatedly in order to create HTML documentation for each
;        of the source code files in the GAMAP installation.  The
;        user may sort routines by alphabetical order or by category.
;
; CATEGORY:
;        Documentation
;
; CALLING SEQUENCE:
;        GAMAP2_HTML [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        OUTDIR -> Specifies the directory in which HTML documenation
;             will be created.  Passes this to IDL2HTML.
;
;        /ALL_ROUTINES -> Select this option to create an HTML file
;             with documentation information about all routines
;             in the GAMAP directory.  The output file name will be
;             "gamap2_html.pro".
;
;        /BY_ALPHABET -> Select this option to create HTML documentation
;             files for GAMAP routines by alphabetical order.  A file
;             will be created for each letter of the alphabet.
;
;        /BY_CATEGORY -> Select this option to create HTML documentation
;             files for GAMAP routines according to category (as
;             specified by the "CATEGORY" tag of the IDL doc header).
;             A files will be created for each individual category.
;             NOTE: GAMAP routines may be cross-linked across more
;             than one category.  
;
; OUTPUTS:
;
; SUBROUTINES:
;        External Routines Required:
;        ============================
;        IDL2HTML
;        PROGRAM_DIR (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) See also the documentation to IDL2HTML and the IDL manual
;            for routine MK_HTML_HELP.
;
;        (2) One of /ALL_ROUTINES, /BY_ALPHABET, or /BY_CATEGORY must
;            be selected.
;
; EXAMPLES:
;        (1)
;        GAMAP2_HTML, /ALL_ROUTINES, OUTDIR='manual/html'
;
;             ; Creates HTML documentation from the std headers to
;             ; each of the IDL source code programs in the GAMAP 
;             ; installation.  Writes output to the manual/html
;             ; directory.  The output file name is "gamap2.html",
;             ; which directory.   
;
;        (2) 
;        GAMAP2_HTML, /BY_ALPHABET, OUTDIR="manual/html"
;            
;             ; Creates HTML documentation from the std headers to
;             ; each of the IDL source code programs in the GAMAP 
;             ; installation.  Will search through the IDL doc 
;             ; headers and create a new HTML file for each
;             ; letter of the alphabet.
;
;        (3)
;        GAMAP2_HTML, /BY_CATEGORY, OUTDIR='manual/html'
;
;             ; Creates HTML documentation from the std headers to
;             ; each of the IDL source code programs in the GAMAP 
;             ; installation.  Will search through the IDL doc 
;             ; headers and create a new HTML file for each
;             ; category.
;
;
; MODIFICATION HISTORY:
;  bmy & phs, 23 Jul 2007: GAMAP VERSION 2.10
;        bmy, 20 Nov 2007: GAMAP VERSION 2.11
;                          - Added new category for timeseries routines
;
;-
; Copyright (C) 2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine gamap2_html"
;-----------------------------------------------------------------------


pro Gamap2_Html, All_Routines=All_Routines,  By_Alphabet=By_Alphabet, $
                 By_Category=By_Category,    OutDir=OutDir 

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION Add_Separator, Program_Dir

   ; Keywords
   All_Routines = Keyword_Set( All_Routines )
   By_Alphabet  = Keyword_Set( By_Alphabet  )
   By_Category  = Keyword_Set( By_Category  )

   ; Root directory of GAMAP installation
   Dir = Program_Dir( Routine_Name() + '.pro' ) + '../'
 
   ; Default output directory
   if ( N_Elements( OutDir ) eq 0 ) then OutDir = Dir + 'manual/html'

   ; Make sure DIR, OUTDIR end w/ a slash
   Dir    = Add_Separator( Dir )
   OutDir = Add_Separator( OutDir )
 
   ;====================================================================
   ; Create documentation
   ;====================================================================
   
   ; Maks for files
   FileMask = Dir + '*'

   print, 'Searching for files in: ' + FileMask
   print, 'Output file in        : ' + outdir
   
   ;--------------------------------------------------
   ; Create HTML documentation by category
   ;--------------------------------------------------
   if ( By_Category ) then begin
      Idl2Html, FileMask, /Category, OutDir=OutDir, HTML='gamap_%CAT%.html'

      ; Rename category files
      spawn, 'mv ' + OutDir + 'gamap_ATMOSPHERICSCIENCES.html   ' + $
                     OutDir + 'AtmosphericSciences.html'
      spawn, 'mv ' + OutDir + 'gamap_BPCHFORMAT.html            ' + $
                     OutDir + 'BpchFormat.html'
      spawn, 'mv ' + OutDir + 'gamap_COLOR.html                 ' + $
                     OutDir + 'Color.html'
      spawn, 'mv ' + OutDir + 'gamap_DATE-TIME.html             ' + $
                     OutDir + 'DateAndTime.html'
      spawn, 'mv ' + OutDir + 'gamap_DOCUMENTATION.html         ' + $
                     OutDir + 'Documentation.html'
      spawn, 'mv ' + OutDir + 'gamap_FILE-I-O.html              ' + $
                     OutDir + 'FileAndIO.html'
      spawn, 'mv ' + OutDir + 'gamap_GAMAPDATAMANIPULATION.html ' + $
                     OutDir + 'GamapDataManipulation.html'
      spawn, 'mv ' + OutDir + 'gamap_GAMAPEXAMPLES.html         ' + $
                     OutDir + 'GamapExamples.html'
      spawn, 'mv ' + OutDir + 'gamap_GAMAPINTERNALS.html        ' + $
                     OutDir + 'GamapInternals.html'
      spawn, 'mv ' + OutDir + 'gamap_GAMAPMODELS-GRIDS.html     ' + $
                     OutDir + 'GamapModelsAndGrids.html'
      spawn, 'mv ' + OutDir + 'gamap_GAMAPPLOTTING.html         ' + $
                     OutDir + 'GamapPlotting.html'
      spawn, 'mv ' + OutDir + 'gamap_GAMAPUTILITIES.html        ' + $
                     OutDir + 'GamapUtilities.html'
      spawn, 'mv ' + OutDir + 'gamap_GENERAL.html               ' + $
                     OutDir + 'General.html'
      spawn, 'mv ' + OutDir + 'gamap_GRAPHICS.html              ' + $
                     OutDir + 'Graphics.html'
      spawn, 'mv ' + OutDir + 'gamap_MATH-UNITS.html            ' + $
                     OutDir + 'MathAndUnits.html'
      spawn, 'mv ' + OutDir + 'gamap_PLOTTING.html              ' + $
                     OutDir + 'Plotting.html'
      spawn, 'mv ' + OutDir + 'gamap_REGRIDDING.html            ' + $
                     OutDir + 'Regridding.html'
      spawn, 'mv ' + OutDir + 'gamap_SCIENTIFICDATAFORMATS.html ' + $
                     OutDir + 'ScientificDataFormats.html'
      spawn, 'mv ' + OutDir + 'gamap_STRINGS.html               ' + $
                     OutDir + 'Strings.html'
      spawn, 'mv ' + OutDir + 'gamap_STRUCTURES.html            ' + $
                     OutDir + 'Structures.html'
      spawn, 'mv ' + OutDir + 'gamap_TIMESERIES.html            ' + $
                     OutDir + 'Timeseries.html'
   endif

   ;--------------------------------------------------
   ; Create HTML documentation by alphabetical order
   ;--------------------------------------------------
   if ( By_Alphabet ) then begin
      Idl2Html, FileMask, /Alpha, OutDir=OutDir, HTML='gamap_%LETTER%.html'
   endif

   ;--------------------------------------------------
   ; Create HTML for all routines (in one HTML file)
   ;--------------------------------------------------
   if ( All_Routines ) then begin
      Idl2Html, FileMask, HTML=OutDir+'All_GAMAP_Routines.html'
   endif

end
