; $Id: document_color_table.pro,v 1.2 2008/04/23 18:21:42 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        DOCUMENT_COLOR_TABLE
;
; PURPOSE:
;        Displays all of the color tables within a standard IDL
;        *.tbl file.  Can display output to the Xwindow device,
;        or create PostScript and PDF output.
;
; CATEGORY:
;	 Color
;
; CALLING SEQUENCE:
;	 DOCUMENT_COLOR_TABLE [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;	 FILE -> Name of the the color table (*.tbl) file to read. 
;             Default is "gamap_colors.tbl".
;
;        /PS -> Set this switch to print output to a PostScript
;             document instead of plotting to the screen.
;
;        /PDF -> Set this switch to create a PostScript document
;             and then also create a PDF document.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        The Unix utility "ps2pdf" must be installed on your system 
;        for the /PDF keyword to work.  The ps2pdf utility should come
;        standard with most Unix or Linux builds. 
;
; NOTES:
;        None
;
; EXAMPLES
;        DOCUMENT_COLOR_TABLE
;
;             ; Prints out the color tables to the screen.
;             ; Will set a 900x900 pixel window by default.
;         
;        DOCUMENT_COLOR_TABLE, /PS
;
;             ; Prints color tables to a PostScript file
;             ; called "table_info.ps".
;
;        DOCUMENT_COLOR_TABLE, /PDF
;
;             ; Prints out the color tables to a PostScript file
;             ; "table_info.ps", then also creates a PDF file
;             ; "table_info.pdf" using "ps2pdf".
;
; MODIFICATION HISTORY:
;        phs, 21 Apr 2008: VERSION 1.00
;
;-
; Copyright (C) 2008, Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to plesager@seas.harvard.edu 
; with subject "IDL routine compress_div_ct"
;
; ColorBrewer license info:
; -------------------------
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
; implied. See the License for the specific language governing 
; permissions and limitations under the License.
;-----------------------------------------------------------------------


pro Document_Color_Table, File=File, PS=PS, PDF=PDF, _EXTRA=e

   ;=====================================================================
   ; Initialization
   ;=====================================================================

   ; Name of the file with the color table definitions
   if ( N_Elements( File ) eq 0 ) then File = File_Which( 'gamap_colors.tbl' )

   ; Create PS/PDF output or print to screen?
   PS   = Keyword_Set( PS ) or Keyword_Set( PDF )
   PDF  = Keyword_Set( PDF )
   XWIN = 1L - PS 

   ; Get the names of each color table in the *.tbl file
   LoadCT, File=File, Get_Names=name

   ; Call MULTIPANEL to set the plot parameters
   Cols = 3 & Rows = 15
   MultiPanel, cols=cols, rows=rows

   ; Open the plot device for Xwindow, PS, or PDF
   if ( XWIN ) then begin
      Open_Device, WinParam=[0, 900, 900]
   endif else begin
      Open_Device, File='table_info.ps', /Color,  Bits=8,  $
                   /Portrait,            Ps=PS,  _EXTRA=e
   endelse

   ;=====================================================================
   ; Cycle thru each color table and plot it
   ;=====================================================================
   for klm=0L, n_elements(name)-1L do begin

      ; Create title string for each color table
      title = strtrim(klm, 2) + '. ' + name[klm]

      ; Load the color table with MYCT
      myct, klm, /silent

      ; Call MULTIPANEL to advance to the next page if necessary,
      ; and also to test if this is the last panel on the page
      multipanel, advance=klm eq 0L?0:1, position=position, lastpanel=lastpanel

      ; Get panel width
      wx = (position[2]-position[0])
      wy = (position[3]-position[1])

      ; Bar position, from Normal w/r/t Panel to Normal w/r/t/ to device
      BarPosition    = [0.1, 0.2, 0.8, 0.7];*(1.+1.15*PS)]
      BarPosition[0] = position[0]+wx*BarPosition[0]
      BarPosition[1] = position[1]+wy*BarPosition[1]
      BarPosition[2] = position[0]+wx*BarPosition[2]
      BarPosition[3] = position[1]+wy*BarPosition[3]

      ; Call COLORBAR to plot the color table
      Colorbar, position=BarPosition, annotation=['', '']

      ; get char size in normal(device), and put title
      ;chsz = get_charsize_norm()  ; pb /w PS and/or !p.font=0

      ; Print the title underneath the colorbar
      XYoutS, BarPosition[0], BarPosition[1]-0.014, /norm, title, COLOR=1, $
              CharSize = XWIN ? 1.2 : 0.5+0.35*PS

      ; If we are printing to the screen, then stop if this is
      ; the last panel to give user time to look at the page.
      if ( XWIN and LastPanel ) then Pause
   endfor

   ;=====================================================================
   ; Cleanup & quit
   ;=====================================================================
Quit:
   Close_device
   MultiPanel, /off

   ; Make PDF file? 
   if ( PDF ) then spawn, 'ps2pdf table_info.ps'

END
