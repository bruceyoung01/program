; $Id: gamap2_revisions.pro,v 1.2 2007/11/27 16:33:44 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GAMAP2_REVISIONS
;
; PURPOSE:
;        Wrapper routine for REVISIONS, used to create a "REVISIONS"
;        file for each code directory in the GAMAP installation.
;
; CATEGORY:
;        Documentation
;
; CALLING SEQUENCE:
;        GAMAP2_REVISIONS
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
;        ===============================
;        PROGRAM_DIR (function)
;        REVISIONS
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The REVISIONS routine requires the tag "MODIFICATION HISTORY"
;        to be present.  Files without this tag (e.g. data files or
;        input files) will not be included in the REVISIONS output.
;
; EXAMPLE:
;        GAMAP2_REVISIONS
;
;             ; Search through all of the directories in the GAMAP
;             ; installation and create a REVISIONS file containing
;             ; the modification histories of each *.pro file.
;
; MODIFICATION HISTORY:
;        bmy, 17 Jul 2007: VERSION 1.00
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
; or phs@io.as.harvard.edu with subject "IDL routine gamap2_revisions"
;-----------------------------------------------------------------------


pro Gamap2_Revisions
 
   ; Get the directory in which this program resides
   Dir = Program_Dir( Routine_Name() + '.pro' )
 
   ; Create REVISIONS files for all of the GAMAP directories
   Revisions, Dir + '../atm_sci/' 
   Revisions, Dir + '../color/'
   Revisions, Dir + '../date_time/'
   Revisions, Dir + '../doc/'
   Revisions, Dir + '../examples/'
   Revisions, Dir + '../file_io/'
   Revisions, Dir + '../gamap_util/'
   Revisions, Dir + '../general/'
   Revisions, Dir + '../graphics/'
   Revisions, Dir + '../html_doc/'
   Revisions, Dir + '../internals/'
   Revisions, Dir + '../math_units/'
   Revisions, Dir + '../pdf_doc/'
   Revisions, Dir + '../plotting/'
   Revisions, Dir + '../regridding/'
   Revisions, Dir + '../strings/'
   Revisions, Dir + '../structures/'
   Revisions, Dir + '../timeseries/'
 
end
