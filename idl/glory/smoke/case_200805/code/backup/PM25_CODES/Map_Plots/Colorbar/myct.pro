; $ID: myct.pro,v 1.4 2008/02/12 21:59:24 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MYCT
;
; PURPOSE:
;        Define a set of standard drawing colors and load a colortable 
;        on top of these.  The color table can be manipulated in various 
;        ways (see KEYWORD PARAMETERS).
;
;        The standard MYCT drawing colors are as follows.  These
;        were implemented by Chris Holmes, based on the ColorBrewer 
;        definitions.  These colors are less saturated than the 
;        traditional MYCT drawing colors, and are easier to read
;        on the screen:
;
;           0 : white              9 : lightblue
;           1 : black             10 : lightorange
;           2 : red               11 : lightpurple
;           3 : green             12 : 85% grey
;           4 : blue              13 : 67% grey
;           5 : orange            14 : 50% grey
;           6 : purple            15 : 33% grey
;           7 : lightred          16 : 15% grey
;           8 : lightgreen        17 : white
;
;        However, if you use the /BRIGHT_COLORS keyword to MYCT, you
;        may still use the traditional MYCT drawing colors (which were
;        created by Martin Schultz).  These are defined as follows:
;
;           0 : white             9  : lightgreen
;           1 : black             10 : lightblue
;           2 : red               11 : black
;           3 : green             12 : 85% grey
;           4 : blue              13 : 67% grey
;           5 : yellow            14 : 50% grey
;           6 : magenta           15 : 33% grey
;           7 : cyan              16 : 15% grey
;           8 : lightred          17 : white
;         
;        With MYCT, you may load any of the standard IDL color tables
;        or any of the ColorBrewer color tables.  For backwards
;        compatibility, MYCT also supports several customized color
;        tables that used to be defined with the CUSTOM_COLORTABLE
;        routine.
;
;        MYCT reads color table definitions from an IDL *.tbl file.
;        The default file name is "gamap_colors.tbl".  You may specify
;        a different file with the CTFILE keyword (see below).  Also,
;        if you wish to add a custom color table, the best way to 
;        proceed is to create your own *.tbl file with your custom
;        color table definitions.  See the routine GAMAP_COLORS for
;        more information.
;
; CATEGORY:
;        Color
;
; CALLING SEQUENCE:
;        MYCT, [ TABLE ] [ , keywords ]
;
; INPUTS:
;        TABLE (optional) -> Number or name of the IDL color table 
;             to be used.  If no number or name is provided, the
;             routine will default to color table 0 (which for the 
;             "gamap_colors.tbl" file is B-W LINEAR).  The MYCT
;             drawing colors will be loaded first, and the color
;             table will be loaded on top of that.  You can choose
;             the bottom color index for the color table with the
;             BOTTOM keyword.  MYCT will ensures that the system
;             variable !D.N_COLORS is set correctly.  
;
; KEYWORD PARAMETERS:
;        /BRIGHT_COLORS -> Selects the older set of MYCT drawing colors
;             to be loaded at the bottom of the colortable.  Default is 
;             to select the newer set of MYCT drawing colors, which
;             are less saturated and easier to read on the screen.
;
;        BOTTOM -> specify where to start color table (see BOTTOM keyword
;             in LOADCT). Default is number of standard drawing colors+1
;             or 0 (if NO_STD is set). If BOTTOM is less than the number
;             of standard drawing colors (17), no standard colors will be
;             defined (equivalent to setting NO_STD).  RANGE has no
;             effect on the DIAL/LIDAR colortable.  Default is 18.
;             NOTE: You should not normally have to change this value.
;
;        CTFILE -> Specify a file containing the color table
;             definitions.  Default is "gamap_colors.tbl", which is
;             a combination of the standard IDL color tables plus
;             the ColorBrewer color tables.  (See routine GAMAP_COLORS.)
;
;        NCOLORS -> number of color indices to be used by the color table.
;             Default is !D.N_COLORS-BOTTOM. 
;
;        /NO_STD -> prevents definition of standard drawing colors.
;
;        RANGE -> a two element vector which specifies the range of colors
;             from the color table to be used (fraction 0-1). The colortable
;             is first loaded into the complete available space, then
;             the selected portion is interpolated in order to achieve the
;             desired number of colors.   RANGE is only effective when
;             a TABLE parameter is given.  RANGE has no effect on the 
;             customized colortables.
;
;        /REVERSE -> Set this switch to reverse the color table.
;             /REVERSE works for both IDL and custom color tables.
;
;        SATURATION -> factor to scale saturation values of the extra
;             color table. Saturation ranges from 0..1 (but the factor 
;             is free choice as long as positive).  SATURATION has no
;             effect on the customized colortables.  Default is 1.
;               
;        VALUE -> factor to scale the "value" of the added colortable.
;             (i.e. this is like the contrast knobon a TV set).  Value 
;             ranges from 0..1; 0 = black, 1 = white.  Default is 1.
;
;        /USE_CURRENT -> By default, MYCT will reset the color table
;             to all white before loading a new colortable.  Set
;             /USE_CURRENT to prevent this from happening.
;
;        /VERBOSE -> Set this switch to print out information about
;             the color table that has just been selected.
;
;        /XINTERACTIVE -> to call XLOADCT instead of LOADCT for
;             interactivity. Has no effect if a custom colortable is
;             loaded.
;
;
;        The following keywords are kept for backwards compatibility.
;        These will replicate the color tables that used to be defined
;        with the now obsolete CUSTOM_COLORTABLE routine.
;        
;        /BuWhRd   -> Loads 19-color BLUE-WHITE-RED color table
;        /BuWhWhRd -> Loads 20-color BLUE-WHITE-WHITE-RED color table
;        /BuYlRd   -> Loads 11-color BLUE-YELLOW-RED color table
;        /BuYlYlRd -> Loads 12-color BLUE-YELLOW-YELLOW-RED color table
;        /DIAL     -> Loads the 26-color DIAL/LIDAR color table 
;                      (cf. E. Browell)
;        /DIFF     -> Synonym for /BuWhRd.  
;        /ModSpec  -> Loads the 11 color MODIFIED SPECTRUM color table
;        /WhBu     -> Loads the 10-color WHITE-BLUE color table
;        /WhGrYlRd -> Loads the 20-color WHITE_GREEN-YELLOW-RED color table
;                      (cf. Aaron van Donkelaar)
;        /WhGyBk   -> Loads the 10-color the WHITE-GRAY-BLACK color
;        /WhRd     -> Loads the 10-color the WHITE-RED color table
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines Provided:
;        ===============================
;        MYCT_Drawing_Colors
;
;        External Subroutines Required:
;        ===============================
;        COMPRESS_DIV_CT   
;        DATATYPE (function)
;        XCOLORS
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) It is recommended to use the COLOR keyword in all PLOT 
;            commands. This will ensure correct colors on (hopefully) 
;            all devices.  In order to get 256 colors on a postscript 
;            printer use DEVICE,/COLOR,BITS_PER_PIXEL=8 
;
;        (2) MYCT will also save several parameters in the MYCT system 
;            variable, so that graphics programs can access them.
;
;        (3) MYCT uses the "gamap_colors.tbl" file.  This file
;            contains all of the IDL standard color table definitions
;            all of the olorBrewer color table definitions, and some
;            extra colortables.  If you wish to add a color table
;            you should probably use routine GAMAP_COLORS to create
;            a new *.tbl file.  Then call MYCT and specify the name
;            of the new *.tbl file with the CTFILE keyword.
;
;        (4) We will use the ColorBrewer color abbreviations:
;               Bk = Black    Br = Brown    Bu = Blue      
;               Gr = Green    Gy = Gray     Or = Orange    
;               Pi = Pink     Pu = Purple   Rd = Red     
;               Wh = White    Yl = Yellow
;
;        (5) An MS Excel spreadsheet with all ColorBrewer color tables 
;            is available for download from:
;            www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_RGB.html
;
;        (6) NOTE: Use a temporary hack to center the ColorBrewer
;            diverging color tables. (phs, 4/23/08)
;
; EXAMPLES:
;        MYCT, 8, /NO_STD     
;             ; load IDL colortable green-white (#8)
;             ; identical result as loadct,3
;
;        MYCT, 'EOS B', NCOLORS=20  
;             ; change first 17 colors to standard drawing colors
;             ; and add EOS-B (#27) color table in indices 18-36
;
;        MYCT, 0, NCOLORS=20, /REVERSE, /NO_STD, /Use_Current
;             ; add reversed grey scale table on top
;
;        MYCT, 'EOS B', NCOLORS=40, /NO_STD, /Use_Current, $
;             RANGE=[0.1,0.7], SATURATION=0.7
;             ; add a less saturated version of a fraction
;             ; of the EOS-B color table in the next 40 indices
;             ; NOTE that color indices above 97 will still contain 
;             ; the upper portion of the green-white color table.
;
;        MYCT, 0 /REVERSE     
;             ; On b/w terminals MYCT can be used to reverse
;             ; the IDL black & white (#0) colortable 
;
;        MYCT, /DIAL, NCOLORS=120
;            ; Loads the DIAL LIDAR color table with 120 colors
;
;        MYCT, /BuYlYlRd
;        MYCT, 'RdBu', /MIDCOLORPRESENT, /YELLOW, NCOLORS=20
;            ; Both of these commands do the same thing: loads
;            ; the ColorBrewer "RdBu" colortable and inserts yellow
;            ; into the 2 middle colors.  This is a good choice
;            ; if you are creating an absolute or % difference plot.
;
; MODIFICATION HISTORY:
;        mgs, 06 Feb 1997: VERSION 1.00
;        mgs, 03 Aug 1997: - added input parameter and template
;        mgs, 26 Mar 1998: - added NCOLORS keyword
;        mgs, 06 Apr 1998: - added BOTTOM, RANGE, and RGB keywords
;        mgs, 04 May 1998: - added test for null device
;        mgs, 03 Jun 1998: - return if !D.N_COLORS is less than 3 (b/w)
;        mgs, 16 Jun 1998: - bug fix: range check now after tvlct
;        mgs, 18 Jul 1998: - bug re-visited, added HLS keyword and changed
;                            default to HSV. Also added SATURATION and
;                            VALUE keywords.
;        mgs, 12 Aug 1998: - re-written with bug fixes and more concise.
;                            removed RGB and HLS keywords, added REVERSE 
;                            and NO_STD               keywords.
;        mgs, 14 Jan 1999: - limit oldcolors and ncolors to MaxColors (256) 
;                            on PC with TrueColor Graphics to ensure 
;                            compatibility with Unix.
;        bmy, 26 Sep 2002: TOOLS VERSION 1.51
;                          - added /DIAL keyword to specify the DIAL/LIDAR
;                            colortable from Ed Browell et al.
;                          - now save MYCT parameters into a system variable
;                            so that plotting routines can access them.
;        bmy, 22 Oct 2002: TOOLS VERSION 1.52
;                          - fixed minor bugs in defining the !MYCT variable 
;        bmy, 28 May 2004: TOOLS VERSION 2.02
;                          - removed TESTMYCT routine, it's obsolete
;                          - Bug fix: make sure RANGE is defined before
;                            saving it to the !MYCT variable
;        bmy, 09 Jun 2005: TOOLS VERSION 2.04
;                          - Added default value for RANGE keyword
;        bmy, 05 Oct 2006: TOOLS VERSION 2.05
;                          - Now also define the DIFFERENCE color table
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Now calls CUSTOM_COLORTABLE to define
;                            several custom colortables 
;                          - Now allow /REVERSE to reverse custom
;                            color table indices
;                          - Added /VERBOSE keyword for printing info
;                            about the selected color table
;                          - Added /BuWhWhRd keyword for the 
;                            BLUE-WHITE-WHITE-RED colortable
;                          - Added /BuYlYlRd keyword for the 
;                            BLUE-YELLOW-YELLOW-RED colortable
;                          - Added /UserDef keyword to select
;                            a user-defined color table.
;  cdh & bmy, 19 Nov 2007: GAMAP VERSION 2.11
;                          - Now implement newer, less-saturated MYCT
;                            drawing colors as defaults
;                          - Added /BRIGHT_COLORS keyword to use
;                            the older drawing colors for backwards
;                            compatibility.
;       phs, 17 Apr 2008: GAMAP VERSION 2.12
;                          - Now passes _extra to LOADCT, so a different
;                            table file (*.tbl) can be used for example.
;                          - bug fix: ncolors is correctly passed to
;                            LOADCT if RANGE is not set.
;                          - Added the XINTERACTIVE keyword to use
;                            XCOLORS instead of LOADCT when no custom
;                            table is loaded.
;                          - Now use extra !MYCT tags: NAME, INDEX, FILE
;                          - Added MIDCOLORPRESENT, USE_CURRENT keywords
;                         
;-
; Copyright (C) 1997-2008, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine myct"
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


pro MYCT_Drawing_Colors, Bright_Colors, Red, Green, Blue

   ;====================================================================
   ; Routine MYCT_Drawing_Colors returns the Red, Green, Blue vectors
   ; which define the MYCT drawing colors (i.e. simple colors like
   ; red, green, blue, orange, yellow, etc. that can be used to color
   ; data points and/or lines in plots).  (cdh, bmy, 11/19/07)
   ;====================================================================

   if ( Bright_Colors ) then begin

      ;-----------------------------------------
      ; "Traditional" bright drawing colors
      ; (Original to MYCT, by Martin Schultz)
      ;-----------------------------------------
      Red   = [ 255,   0, 255,   0,   0, 255, 255,   0, 255, $
                127, 127,   0,  90, 150, 188, 220, 240, 255 ]
      Green = [ 255,   0,   0, 255,   0, 255,   0, 255, 127, $
                255, 127,   0,  90, 150, 188, 220, 240, 255 ]
      Blue  = [ 255,   0,   0,   0, 255,   0, 255, 255, 127, $
                127, 255,   0,  90, 150, 188, 220, 240, 255 ]
   endif else begin
       
      ;-----------------------------------------
      ; New drawing colors color are less 
      ; saturated and better for screen viewing
      ; (cdh, 11/19/07)
      ;-----------------------------------------
      Red   = [ 255,   0, 227,  51,  31, 255, 106, 251, 178, $
                156, 253, 202,  90, 150, 188, 220, 240, 255 ]
      Green = [ 255,   0,  26, 160, 120, 127,  61, 154, 223, $
                216, 191, 178,  90, 150, 188, 220, 240, 255 ]
      Blue  = [ 255,   0,  28,  44, 180,   0, 154, 153, 138, $
                217, 111, 214,  90, 150, 188, 220, 240, 255 ]

   endelse

end

;------------------------------------------------------------------------------

pro MyCt, Table,                   Xinteractive=Xinteractive,        $
          Bottom=Bottom,           NColors=NColors,                  $
          Range=Range,             Reverse=Reverse_Colors,           $
          Saturation=Saturation,   Value=Value,                      $
          No_Std=No_Std,           Bright_Colors=Bright_Colors,      $ 
          CtFile=CtFile,           Verbose=Verbose,                  $
          ; ----------- CUSTOM color table keywords -------------------
          BuWhRd=BuWhRd,           BuWhWhRd=BuWhWhRd,                $
          BuYlRd=BuYlRd,           BuYlYlRd=BuYlYlRd,                $
          Dial=Dial,               Diff=Diff,                        $
          ModSpec=ModSpec,         UserDef=UserDef,                  $
          WhBu=WhBu,               WhGrYlRd=WhGrYlRd,                $
          WhGyBk=WhGyBk,           WhRd=WhRd,                        $
          White=White,             Yellow=Yellow,                    $
          Use_Current=Use_Current, MidColorPresent=MidColorPresent,  $
          _EXTRA=e
   
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION DataType

   ; Check for NULL device. Can be used to identify remote IDL sessions
   if ( !D.NAME eq 'NULL' ) then goto, DefineNQuit

   ;----------------------------
   ; Get MYCT drawing colors
   ;----------------------------

   ; /BRIGHT_COLORS will select the older set of drawing colors
   ; Default is to use the newer (less-saturated) drawing colors
   Bright_Colors  = Keyword_Set( Bright_Colors )

   ; Return RGB vectors for the MYCT drawing colors
   MYCT_Drawing_Colors, Bright_Colors, Red, Green, Blue

   ;----------------------------
   ; Define other quantities
   ;----------------------------

   ; Initialization
   Custom         = ''
   Reverse_Colors = Keyword_Set( Reverse_Colors )
   No_Std         = Keyword_Set( No_Std         )
   Is_NC_defined  = n_elements( NColors ) gt 0

   ; Initialize: set everything to white, unless user requires to keep
   ; current colors
   if not ( Keyword_Set( Use_Current ) ) then begin
      R = FltArr( 256 ) + 255
      G = FltArr( 256 ) + 255
      B = FltArr( 256 ) + 255
      TvLct, R, G, B
   endif
   
   ; Now manually specify the colortable file location.  This is done
   ; to force LOADCT & XLOADCT to reload the table (they use a common 
   ; block) if it was previously called with another colortable file.
   ; (phs, bmy, 4/18/08)
   if ( N_Elements( CtFile ) eq 0 ) $
      then CtFile = File_Which( 'gamap_colors.tbl' )

   ; CTNAMES is the array of color table names
   LoadCT, Get_Names=CtNames, File=CtFile
      
   ; Define default BOTTOM value
   if ( N_Elements( Bottom ) eq 0 ) then begin
      if ( No_Std )                      $
         then Bottom = 0                 $
         else Bottom = N_Elements( Red )
   endif

   ; Suppress drawing colors if BOTTOM is too low
   if ( Bottom lt N_Elements( Red ) ) then No_Std = 1

   ; For backwards compatibility
   if ( Keyword_Set( Diff ) ) then BuWhRd = 1

;-----------------------------------------------------------------------------
; Prior to 4/18/08:
; Now replicate this below with equivalent options.
; The old method with CUSTOM_COLORTABLE is now obsolete! (phs, bmy, 4/18/08)
;   ; Are we using a custom colortable?
;   Is_Custom = ( Keyword_Set( BuWhRd   ) OR Keyword_Set( BuWhWhRd ) OR $
;                 Keyword_Set( BuYlRd   ) OR Keyword_Set( BuYlYlRd ) OR $ 
;                 Keyword_Set( Dial     ) OR Keyword_Set( Diff     ) OR $
;                 Keyword_Set( ModSpec  ) OR Keyword_Set( UserDef  ) OR $
;                 Keyword_Set( WhBu     ) OR Keyword_Set( WhGrYlRd ) OR $
;                 Keyword_Set( WhGyBk   ) OR Keyword_Set( WhRd     ) ) 
;
;   ;====================================================================
;   ; Load custom colortables
;   ;====================================================================
;
;   if ( Is_Custom ) then begin
;
;      ; Default setting for BOTTOM 
;      if ( N_Elements( Bottom ) ne 1 ) then Bottom = N_Elements( Red )
;
;      ; Initialize: set everything to white
;      R = FltArr( 256 ) + 255
;      G = FltArr( 256 ) + 255
;      B = FltArr( 256 ) + 255
;      TvLct, R, G, B
;
;      ; Copy drawing color vectors into R, G, B
;      N        = N_Elements( Red )
;      R[0:N-1] = Red
;      G[0:N-1] = Green
;      B[0:N-1] = Blue
;     
;      ; Get color vectors for custom color table
;      Custom_ColorTable, R_Tmp, G_Tmp, B_Tmp,                        $
;         BuWhRd=BuWhRd,      BuWhWhRd=BuWhWhRd,  BuYlRd=BuYlRd,      $
;         BuYlYlRd=BuYlYlRd,  Dial=Dial,          Diff=Diff,          $
;         ModSpec=ModSpec,    UserDef=UserDef,    WhBu=WhBu,          $
;         WhGrYlRd=WhGrYlRd,  WhGyBk=WhGyBk,      WhRd=WhRd,          $
;         Name=Name,          NColors=NColors,    /NoLoad,            $
;         _EXTRA=e
;
;      ; Reverse customized colors (if /REVERSE is set)
;      if ( Reverse_Colors ) then begin
;         R_Tmp = Reverse( R_Tmp )
;         G_Tmp = Reverse( G_Tmp )
;         B_Tmp = Reverse( B_Tmp )
;      endif
;
;      ; Merge drawing colors w/ custom colors (if /NO_STD is set)
;      if ( No_Std ) then begin
;         R = R_Tmp
;         G = G_Tmp
;         B = B_Tmp
;      endif else begin
;         R = [ R[0:Bottom-1L], R_Tmp ]
;         G = [ G[0:Bottom-1L], G_Tmp ]
;         B = [ B[0:Bottom-1L], B_Tmp ]
;      endelse
;
;      ; Load the merged colortable!
;      TvLct, R, G, B
;
;      ; Define the !MYCT variable and quit
;      Table          = -1L
;      Range          = -1L
;      Saturation     = -1L
;      Value          = -1L
;      Name           = Name
;      goto, DefineNQuit
;   endif
;-----------------------------------------------------------------------------

   ;====================================================================
   ; Set defaults for IDL colortables
   ;====================================================================

;-----------------------------------------------------------------------------
; Prior to 4/21/08
; Now use !D.TABLE_SIZE-BOTTOM as the max # of colors (bmy, 4/21/08)
;   ; limit NCOLORS to 256 on TrueColor PC to ensure compatibility
;     then ncolors = ( !d.n_colors-bottom > 2 ) < 256
;-----------------------------------------------------------------------------

   ; limit NCOLORS to number of available colors in the table
   if (n_elements(ncolors) eq 0) $
    then ncolors = 2 > ( !D.N_COLORS-bottom ) < ( !D.TABLE_SIZE-bottom ) $
    else ncolors =  ncolors < ( !D.N_COLORS-bottom ) < ( !D.TABLE_SIZE-bottom )
   
   if (n_elements(saturation) eq 0) then saturation = 1.  ; leave unchanged
   if (n_elements(value) eq 0)      then value = 1.       ; leave unchanged

   ;--------------------------------------------------------
   ; Set maximum allowed color number
   ;--------------------------------------------------------
   MaxColors = !D.TABLE_SIZE 

   ;--------------------------------------------------------
   ; Get current entries in colortable
   ; NOTE: Upon startup,
   ; * the colortable results in 256 grey scale entries
   ; * !D.N_Colors is not defined correctly
   ;--------------------------------------------------------
   TVLCT,rback,gback,bback,/get

   ;--------------------------------------------------------
   ; remember number of colors available
   ; may change after !D.N_Colors is determined correctly
   ;--------------------------------------------------------
   oldcolors = !D.N_COLORS

   ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ; For backward compatibility's sake, replicate the custom colortable
   ; keywords with the equivalent options.  NOTE: This is deprecated and
   ; is slated to be removed in a future release (phs, bmy, 4/21/08)
   
   ; BLUE-WHITE-RED (19 colors)
   if ( Keyword_Set( BuWhRd ) ) then begin
      Table           = 'RdBu(Diverging)'
      NColors         = Is_NC_defined ? ncolors : 19
      MidColorPresent = 1
      White           = 1
      Yellow          = 0
      Reverse_Colors  = ~Reverse_Colors
   endif

   ; BLUE-WHITE-WHITE-RED (20 colors)
   if ( Keyword_Set( BuWhWhRd ) ) then begin
      Table           = 'RdBu(Diverging)'
      NColors         = Is_NC_defined ? ncolors : 20
      MidColorPresent = 1
      White           = 1
      Yellow          = 0
      Reverse_Colors  = ~Reverse_Colors
   endif

  ; BLUE-YELLOW-RED (19 colors)
   if ( Keyword_Set( BuYlRd ) ) then begin
      Table           = 'RdBu(Diverging)'
      NColors         = Is_NC_defined ? ncolors : 19
      MidColorPresent = 1
      White           = 0
      Yellow          = 1
      Reverse_Colors  = ~Reverse_Colors
   endif

   ; BLUE-WHITE-WHITE-RED (20 colors)
   if ( Keyword_Set( BuYlYlRd ) ) then begin
      Table           = 'RdBu(Diverging)'
      NColors         = Is_NC_defined ? ncolors : 20
      MidColorPresent = 1
      White           = 0
      Yellow          = 1
      Reverse_Colors  = ~Reverse_Colors
   endif

   ; DIAL (26 colors)
   if ( Keyword_Set( Dial ) ) then begin
      Table           = 'DIAL/LIDAR'
      NColors         = Is_NC_defined ? ncolors : 26
   endif

   ; MODSPEC (11 colors)
   if ( Keyword_Set( ModSpec ) ) then begin
      Table           = 'MODIFIED SPECTRUM'
      NColors         = Is_NC_defined ? ncolors : 11
   endif   

   ; WHITE-BLUE (10 colors)
   if ( Keyword_Set( WhBu ) ) then begin
      Table           = 'Blues (Sequential)'
      NColors         = Is_NC_defined ? ncolors : 10
   endif  

   ; WHITE-BLUE (10 colors)
   if ( Keyword_Set( WhGrYlRd ) ) then begin
      Table           = 'WHITE-GREEN-YELLOW-RED'
      NColors         = Is_NC_defined ? ncolors : 20
   endif 

   ; WHITE-BLUE (10 colors)
   if ( Keyword_Set( WhGyBk ) ) then begin
      Table           = 'Greys (Sequential)'
      NColors         = Is_NC_defined ? ncolors : 9
   endif 

   ; WHITE-RED (10 colors)
   if ( Keyword_Set( WhRd ) ) then begin
      Table           = 'Reds (Sequential)'
      NColors         = Is_NC_defined ? ncolors : 10
   endif 

   ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   ;--------------------------------------------------------
   ; If the user specified a color table name rather 
   ; than a number, then find the corresponding color 
   ; table index. (phs, bmy, 4/18/08)
   ;--------------------------------------------------------
   if ( DataType( Table, /Name ) eq 'STRING' ) then begin

      ; Loop over all color table names
      for C = 0L, N_Elements( CtNames )-1L do begin

         ; Test TABLE against all each color table names
         Ind = StrCmp( CtNames[C], Table, StrLen( Table ), /Fold_Case )

         if ( Ind gt 0 ) then begin
            Table = C
            goto, Color_Table_Found
         endif
      endfor
      
      ; Warning : table with requested name is not found
      message, 'WARNING: No color table named '+ StrUpCase(TABLE) + $
        '. Will use ' + CtNames[0],  /cont
      Table = 0

   endif

Color_Table_Found:

   ;--------------------------------------------------------
   ; If the user did not specified a color table, 
   ; default to color table #0
   ;--------------------------------------------------------
   NoTable = ( N_Elements( Table ) eq 0 )
   If ( NoTable ) then Table  = 0

   ;--------------------------------------------------------
   ; Load NCOLORS colors.
   ; If RANGE (to clip the original table) is defined or 
   ; MIDCOLPRESENT (to force a White or Yellow color in the 
   ; middle of a diverging color table) is set, load the 
   ; max # of colors, and we will select the NCOLORS later.
   ;--------------------------------------------------------

   ; Number of colors to load
   NbCLoad = n_elements(RANGE) eq 2 or keyword_set(MidColorPresent) ? $
             maxcolors : ncolors
   
   ; Load Color Table
   if ( Keyword_Set( Xinteractive ) ) then begin
      
      ; Interactive colortable load. Use XColors from David Fanning 
      ; to get NAME and INDEX of table in output (phs, 4/21/08)
      XColors, NColors=NbCLoad, /Block, $
               File=CtFile,     ColorInfo=ColorInfoData, _EXTRA=e

      Name  = ColorInfoData.Name
      Table = ColorInfoData.Index

   endif else begin
   
      ; if no table is specified, load only two colors:
      ; this should be safe also on b/w terminals
      loadct, table, bottom=0, ncolors=NbCLoad, file=ctfile, _extra=e
         
   endelse 

   ; Set color table name (bmy, 3/16/07)
   if ( Table lt 0 )                                   $
      then Name  = 'Unknown Name'                      $
      ;----------------------------------------------------------
      ; Prior to 4/18/08:
      ;else Name  = StrTrim( String( Table ), 2 )
      ;----------------------------------------------------------
      else Name = StrTrim( String( CtNames[Table] ), 2 )

   ;--------------------------------------------------------
   ; Get entries of new color table
   ; Insert midpoint colors if necessary
   ;--------------------------------------------------------
   tvlct, r, g, b, /get

   ;--------------------------------------------------------
   ; Temporary hack for Brewer diverging tables: they are 
   ; centered on color #117 instead of #125. This hack 
   ; works only if !d.table_size is 256 (phs, 4/23/08)
   if strPos(Name, '(Diverging)') ge 0 then begin

      ; load only the good colors
      loadct, table, file=ctfile, /SILENT
      tvlct, r, g, b, /get
      r = r[0:233]
      g = g[0:233]
      b = b[0:233]

      ncolors = ncolors < 234

      ; compress to ncolors if needed
      if ( Is_NC_defined and ~keyword_set(MidColorPresent) ) then begin
         R = Congrid( R, NColors, /Minus_One, /Interp, _EXTRA=e )
         G = Congrid( G, NColors, /Minus_One, /Interp, _EXTRA=e )
         B = Congrid( B, NColors, /Minus_One, /Interp, _EXTRA=e )
      endif

   endif
   ;----------------- End Hack -----------------------------

   ; Diverging table : Add a middle color regardless of odd or even
   ; NCOLORS
   if keyword_set( MidColorPresent ) then $
     compress_div_ct, r, g, b, ncolors=ncolors,        $
                      MidColorPresent=MidColorPresent, $
                      White=White, Yellow=Yellow,      $
                      _EXTRA=e


   ; for color tables defined with few colors, overwrite
   ; NCOLORS. These tables name end with "## colors".
   if table ge 0 then begin
      res = stregex(CtNames[table], '([0-9]+) colors$', /fold, /extract, /subex)

      if strlen(res[1]) gt 0 then begin
         ncolors = fix(res[1])

         ; Reload table if needed (i.e, if user passed NColors).
         if NbCload ne MaxColors then begin
            loadct, table, ncolors=MaxColors, file=ctfile, _extra=e, /SILENT
            tvlct, r, g, b, /get
         endif
      endif
   endif

   ; At this point, the correct value of !D.N_Colors has 
   ; been determined. Adjust MaxColors if necessary (still needed?? phs)
   MaxColors = ( MaxColors < !D.N_Colors )

   ;--------------------------------------------------------
   ; On b/w terminals: does the following help ??  ### 
   ; if (!D.N_COLORS lt 3) then return
   ;
   ; if number of available colors has changed due to 
   ; loadct (i.e. during IDL startup) then create dummy 
   ; backup color arrays with the correct number of colors.
   ; Limit array size to MaxColors
   ; (Don't change top value: this indicates the byte 
   ; entry 'white' and is not a color index!)
   ;--------------------------------------------------------
   if (!D.N_COLORS ne oldcolors) then begin
      rback = bytscl(findgen(MaxColors),top=255)
      gback = rback
      bback = rback
   endif

   ;===================================================================
   ; Now handle requested settings for new colortable
   ;===================================================================

   ; adjust value of NCOLORS, BOTTOM and NO_STD if necessary
   ;(still needed?? phs)
   if (bottom ge MaxColors) then begin
      bottom = 0
      no_std = 1
   endif
   if (bottom+ncolors gt MaxColors) then $
        ncolors = MaxColors-bottom > 2 

;-----------------------------------------------------------------------------
; Prior to 4/21/08
; Now load #1 with !d.table_size-bottom by default (phs, 4/21/08)
;   ;===================================================================
;   ; if no color table is requested, only set drawing colors
;   ;===================================================================
;
;   if (n_elements(table) eq 0) then goto,ONLY_SET_DRAWINGCOLS
;-----------------------------------------------------------------------------

   ;===================================================================
   ; filter colors that are actually used and insert them
   ; into backup table
   ;===================================================================

   ; if RANGE is provided, extract subset and interpolate colortable
   if (n_elements(RANGE) eq 2) then begin

      ; convert percentage to index
      irange = fix( (range < 1.0) * MaxColors )
      if (irange(0) eq irange(1)) then $
          irange(1) = irange(0)+1
      irange = ( (irange(sort(irange)) > 0) < (MaxColors-1) )

      ; extract portion of colortable that shall be used
      r = r(irange[0]:irange[1])
      g = g(irange[0]:irange[1])
      b = b(irange[0]:irange[1])

      ; convert to HSV color space
      COLOR_CONVERT, r, g, b, h, s, v, /RGB_HSV

      ; interpolate to ncolor values
      h = congrid(h,fix(NCOLORS),/interp)
      s = congrid(s,fix(NCOLORS),/interp)
      v = congrid(v,fix(NCOLORS),/interp)

   endif else $

      ; if no range given, extract number of colors requested and 
      ; convert them to HSV
      COLOR_CONVERT, r(0:ncolors-1), g(0:ncolors-1), b(0:ncolors-1), $
                     h, s, v, /RGB_HSV

   
   ; revert colortable if wished
   if (keyword_set(REVERSE_COLORS)) then begin
      h = reverse(h)
      s = reverse(s)
      v = reverse(v)
   endif


   ;===================================================================
   ; adapt saturation and "lightness" for color palette
   ; (requires color values in HSV system)
   ;===================================================================

   s = ((s * saturation) > 0) < 1
   v = ((v * value) > 0) < 1

   ;===================================================================
   ; overwrite portion of original colortable and store it
   ;===================================================================

   ; restore original first, then overwrite.
   ; (if too flickering, think new)

   tvlct,rback,gback,bback
   tvlct,h,s,v,bottom,/HSV 
 
   ;=================================================================== 
   ; set standard drawing colors
   ;=================================================================== 
ONLY_SET_DRAWINGCOLS: 

   if (n_elements(red) le !D.N_COLORS AND no_std eq 0 ) then  $
      TVLCT, red, green, blue
 
   ;====================================================================
   ; Define MYCT system variable and then quit
   ;====================================================================
DefineNQuit:

   ; Define the !MYCT variable if it doesn't exist
   MyCt_Define

   ; Now assign the values to the !MYCT variable
   if ( Bright_Colors ) then begin

      ;-----------------------------------------
      ; "Traditional" bright drawing colors
      ; (Original to MYCT, by Martin Schultz)
      ;-----------------------------------------
      !MYCT.WHITE       =  0
      !MYCT.BLACK       =  1
      !MYCT.RED         =  2
      !MYCT.GREEN       =  3
      !MYCT.BLUE        =  4
      !MYCT.YELLOW      =  5
      !MYCT.MAGENTA     =  6
      !MYCT.CYAN        =  7
      !MYCT.LIGHTRED    =  8
      !MYCT.LIGHTGREEN  =  9
      !MYCT.LIGHTBLUE   = 10
      !MYCT.GRAY85      = 12
      !MYCT.GRAY67      = 13
      !MYCT.DARKGRAY    = 13
      !MYCT.GRAY50      = 14
      !MYCT.MEDIUMGRAY  = 14
      !MYCT.GRAY33      = 15
      !MYCT.GRAY        = 15
      !MYCT.LIGHTGRAY   = 15
      !MYCT.GRAY15      = 16

      ; These colors aren't used, set to white
      !MYCT.ORANGE      = 0
      !MYCT.PURPLE      = 0
      !MYCT.LIGHTORANGE = 0
      !MYCT.LIGHTPURPLE = 0
      
   endif else begin

      ;-----------------------------------------
      ; New drawing colors color are less 
      ; saturated and better for screen viewing
      ; (cdh, 11/19/07)
      ;-----------------------------------------
      !MYCT.WHITE       =  0
      !MYCT.BLACK       =  1
      !MYCT.RED         =  2
      !MYCT.GREEN       =  3
      !MYCT.BLUE        =  4
      !MYCT.ORANGE      =  5
      !MYCT.PURPLE      =  6
      !MYCT.LIGHTRED    =  7
      !MYCT.LIGHTGREEN  =  8
      !MYCT.LIGHTBLUE   =  9
      !MYCT.LIGHTORANGE = 10
      !MYCT.LIGHTPURPLE = 11
      !MYCT.GRAY85      = 12
      !MYCT.GRAY67      = 13
      !MYCT.DARKGRAY    = 13
      !MYCT.GRAY50      = 14
      !MYCT.MEDIUMGRAY  = 14
      !MYCT.GRAY33      = 15
      !MYCT.GRAY        = 15
      !MYCT.LIGHTGRAY   = 15
      !MYCT.GRAY15      = 16
      
      ; These colors aren't used, set to white
      !MYCT.YELLOW      = 0
      !MYCT.MAGENTA     = 0
      !MYCT.CYAN        = 0

   endelse

   ; Define other tags of the !MYCT sysvar
   !MYCT.FILE    = CtFile
   !MYCT.NAME    = Name
   !MYCT.INDEX   = Table
   !MYCT.BOTTOM  = Bottom  
   !MYCT.NCOLORS = NColors 
   !MYCT.SAT     = Saturation
   !MYCT.VALUE   = Value  
   !MYCT.REVERSE = Reverse_Colors 
   ;-------------------------------------------------------------------
   ; Prior to 4/18/08:
   ; Remove the CUSTOM tag name from the !MYCT sysvar (bmy, 4/18/08)
   ;MYCT.CUSTOM  = Is_Custom        
   ;MYCT.CUSTOM  = 0L
   ;
   ; Prior to 4/18/08:
   ; We now use NAME and INDEX keywords in !MYCT, this is obsolete
   ; (bmy, 4/18/08)
   ;; Prevent error if TABLE is undefined (bmy, 3/19/07)
   ;if ( not Is_Custom AND N_Elements( Table ) eq 0 ) $ 
   ;   then !MYCT.TABLE = -1L       $
   ;   else !MYCT.TABLE = Table
   ;
   ; Prior to 4/18/08:
   ; Now do not overwrite RANGE with -1's.  If RANGE is not passed
   ; then we'll keep the last value of !MYCT.RANGE (which is set
   ; to [0,1] in MYCT_DEFAULTS. (bmy, 4/22/08)
   ;;  Prevent error if RANGE is undefined (bmy, 5/28/04)
   ;if ( N_Elements( Range ) gt 0 ) $
   ;   then !MYCT.RANGE = Range     $
   ;   else !MYCT.RANGE = -1L
   ;-------------------------------------------------------------------
   !MYCT.RANGE = ( N_Elements( Range ) gt 0 ) ? Range : !MYCT.RANGE

   ; If /VERBOSE is set, then echo info about the color table
   if ( Keyword_Set( Verbose ) ) then begin
      Print, !MYCT.NAME, Format='(''% Color table      : '', a)'

      Print, StrTrim( String( Long( !D.N_COLORS ) ), 2 ), $
         Format='(''% Available Colors : '', a)'

      Print, StrTrim( String( Long( !MYCT.BOTTOM ) ), 2 ), $
         Format='(''% Bottom for MYCT  : '', a)'

      Print, StrTrim( String( Long( !MYCT.NCOLORS ) ), 2 ), $
         Format='(''% NColors for MYCT : '', a)'
   endif

end


