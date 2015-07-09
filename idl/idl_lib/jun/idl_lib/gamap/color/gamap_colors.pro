; $Id: gamap_colors.pro,v 1.1 2008/04/21 19:23:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GAMAP_COLORS
;
; PURPOSE:
;        Concatenates several different color tables (including
;        IDL standard color tables and the ColorBrewer color
;        tables) into single file for for use with GAMAP.
;
; CATEGORY:
;        Color
;
; CALLING SEQUENCE:
;        GAMAP_COLORS
;
; INPUTS:
;        OUTFILENAME -> Name of the color table file to modify.
;             Default is "gamap_colors.tbl".  GAMAP_COLORS will
;             locate this file with FILE_WHICH.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        MYCT
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        IDL's MODIFYCT function may require that the file to be
;        modified already be on disk.
;
; EXAMPLE:
;        GAMAP_COLORS, 'new_gamap_colors.tbl'
;
;             ; Will modify the colortable file 
;             ; 'new_gamap_colors.tbl'.
;
; MODIFICATION HISTORY:
;        bmy, 18 Apr 2008: VERSION 1.00
;
;-
; Copyright (C) 2008, Bob Yantosca, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine gamap_colors"
;-----------------------------------------------------------------------


pro GAMAP_Colors, OutFileName, Verbose=Verbose, _EXTRA=e
 
   ; Arguments
   if ( N_Elements( OutFileName ) eq 0 ) $
      then OutFileName = File_Which( 'gamap_colors.tbl' )
 
   ; Keywords
   Verbose = Keyword_Set( Verbose )
 
   ; Load original colortable
   TvLct, R_Orig, G_Orig, B_Orig, /Get
 
   ;=====================================================================
   ; Standard IDL color tables 
   ;=====================================================================
 
   ; Zero the color table index
   Index = 0L
 
   ; Get the IDL color table names
   LoadCt, Get_Names=IDL_Tables
 
   ; Loop over each IDL color table 
   for C = 0L, N_Elements( IDL_Tables )-1L do begin
      
      ; Load the color table
      LoadCt, C, Silent=1L-Verbose, _EXTRA=e
 
      ; Get the RGB vectors
      TvLct, R, G, B, /Get
      
      ; Save to the new file
      ModifyCt, Index, IDL_Tables[C], R, G, B, File=OutFileName
 
      ; Increment color table index
      Index = Index + 1L
 
   endfor
 
   ;=====================================================================
   ; ColorBrewer color tables (cf. Janice Brewer)
   ;=====================================================================
 
   ; Locate the file w/ ColorBrewer color table definitions
   Brewer_File = File_Which( 'brewer.tbl' )
 
   ; Get the ColorBrewer color table names
   LoadCt, Get_Names=Brewer_Tables, File=Brewer_File
 
   ; Loop over each ColorBrewer color table
   for C = 0L, N_Elements( Brewer_Tables )-1L do begin
      
      ; Load the Brewer colortable
      LoadCT, C, File=Brewer_File, Silent=1L-Verbose, _EXTRA=e
 
      ; Get the RGB vectors
      TvLct, R, G, B, /Get
      
      ; Save to the new file
      ModifyCt, Index, Brewer_Tables[C], R, G, B, File=OutFileName
 
      ; Increment color table index
      Index = Index + 1L
 
   endfor
 
   ;=====================================================================
   ; Custom color tables
   ;=====================================================================
 
    ; DIAL
   MyCt, /DIAL, Verbose=Verbose, /No_Std, NColors=256
   TvLct, R, G, B, /Get
   Name = 'DIAL/LIDAR (diverging)'
   ModifyCt, Index, Name, R, G, B, File=OutFileName
   Index = Index + 1L
 
   ; ModSpec
   MyCt, /ModSpec, Verbose=Verbose, /No_Std, NColors=256
   TvLct, R, G, B, /Get
   Name = 'MODIFIED SPECTRUM (spec)'
   ModifyCt, Index, Name, R, G, B, File=OutFileName
   Index = Index + 1L  
 
   ; WhGrYlRd
   MyCt, /WhGrYlRd, Verbose=Verbose, /No_Std, NColors=256
   TvLct, R, G, B, /Get
   Name = 'WHITE-GREEN-YELLOW-RED (spec)'
   ModifyCt, Index, Name, R, G, B, File=OutFileName
   Index = Index + 1L 

   ; All-white (for calibration)
   R = IntArr(256)+255
   G = IntArr(256)+255
   B = IntArr(256)+255
   Name = 'ALL-WHITE (calibration)'
   ModifyCt, Index, Name, R, G, B, File=OutFileName
   Index = Index + 1L 
 
   ;=====================================================================
   ; Cleanup and quit
   ;=====================================================================
 
   ; Restore original colortable
   TvLct, R_Orig, G_Orig, B_Orig
 
end
