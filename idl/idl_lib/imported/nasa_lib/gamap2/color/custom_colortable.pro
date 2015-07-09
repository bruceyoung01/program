; $Id: custom_colortable.pro,v 1.3 2008/04/21 19:23:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CUSTOM_COLORTABLE
;
; PURPOSE:
;        Defines various customized color tables for use with MYCT.
;        Color tables may be stretched to more than the original #
;        of colors, or compressed to less than the original # of 
;        colors.  You may add more color tables as necessary.
;
;        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;        %% AS OF GAMAP v2-12, CUSTOM_COLORTABLE IS DEPRECATED.  %%
;        %% MYCT NOW LOADS IDL AND ColorBrewer COLORTABLES FROM  %%
;        %% THE "gamap_colors.tbl" FILE. (phs, bmy, 4/21/08)     %%
;        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;        
; CATEGORY:
;        Color
;
; CALLING SEQUENCE:
;        CUSTOM_COLORTABLE, R, G, B [ , Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS
;        /BuWhRd -> Set this switch to load the BLUE-WHITE-RED 
;             (diverging) color table from Harvard University.  This
;             color table is a concatenation of the WHITE-BLUE and
;             WHITE-RED ColorBrewer colortables.  The center color
;             is white.  (Original # of colors = 19)
;
;        /BuWhWhRd -> Set this switch to load the BLUE-WHITE-WHITE-RED 
;             (diverging) color table.  This is a concatenation of 
;             the WhBu and WhRd colortables from ColorBrewer.  The two
;             center colors in this colortable are white, which makes
;             it easier to align colorbar tickmarks at the divisions
;             between colors.  (Original # of colors = 20)
;
;        /BuYlRd -> Set this switch to load the BLUE-YELLOW-RED 
;             (diverging) color table from ColorBrewer.  (Original 
;             # of colors = 12)
;
;        /BuYlYlRd -> Set this switch to load the BLUE-YELLOW-YELLOW-RED 
;             (diverging) color table from ColorBrewer.  The two center
;             colors in this colortable are light yellow, which makes
;             it easier to align colorbar tickmarks at the divisions
;             between colors.  Use this colortable instead of /BuWhWhRd 
;             if you need to denote "missing data" values by white.  
;             (Original # of colors = 12)
;
;        /DIAL -> Set this switch to load the DIAL/LIDAR (diverging)
;             color table from Ed Browell. (Original # of colors = 27)
;
;        /DIFF -> Synonym for /BuWhRd.  Kept for backwards compatibility.
;
;        /ModSpec -> Set this switch to load the MODIFIED SPECTRUM
;             (diverging) color table from ColorBrewer.  (Original #
;             of colors = 11)
;
;        NAME -> Returns to the calling program the name of the color
;             table that we have selected.
;
;        NCOLORS -> The number of colors that you would like to be
;             included in the colortable.  If NCOLORS is greater than
;             the native number of colors for the given colortable,
;             the colortable will be stretched to produce a finer
;             gradation of colors.  Conversely, if NCOLORS is less
;             than the native number of colors, then the colortable
;             will be compressed to produce a coarser gradation of
;             colors.
;
;        /NOLOAD -> If set, then CUSTOM_COLORTABLE will just return R, 
;             G, B to the calling program without loading the colortable.
;
;        /TRUNCATE -> When NCOLORS is less than the number of colors
;             in the given color table, setting /TRUNCATE will cause 
;             CUSTOM_COLORTABLE to truncate the color table to NCOLORS
;             rather than trying to compress it via interpolation.
;
;        /UserDef -> Set this switch to load a user-defined colortable.
;             In order to use this option, you must first add the R, G,
;             B color vectors into internal routine DEFINE_UserDef.
;
;        /WhBu -> Set this switch to load the WHITE-BLUE (spectral)
;             color table from ColorBrewer.  (original # of colors = 10)
;
;        /WhGrYlRd -> Set this switch to load the WHITE-GREEN-YELLOW-RED
;             (spectral) color table from A. van Donkelaar.  (Original
;             # of colors = 20)
;
;        /WhGyBk -> Set this switch to load the WHITE-GRAY-BLACK 
;             (spectral) color table from ColorBrewer.  (Original # 
;             of colors = 10)
;
;        /WhRd -> Set this switch to load the WHITE-RED (spectral) color
;             table from ColorBrewer.  (original # of colors = 10)
;
; OUTPUTS:    
;        R -> Returns to the calling program the red color
;             vector that defines the customized colortable.
;
;        G -> Returns to the calling program the green color
;             vector that defines the customized colortable.
;
;        B -> Returns to the calling program the blue color
;             vector that defines the customized colortable.
;
; SUBROUTINES:
;        Internal Subroutines Included:
;        ================================================    
;        DEFINE_BuWhRd     DEFINE_BuWhWhRd   DEFINE_BuYlRd   
;        DEFINE_BuYlYlRd   DEFINE_DIAL       DEFINE_MODSPEC  
;        DEFINE_WhBu       DEFINE_WhGrYlRd   DEFINE_WhRd     
;        DEFINE_WhGyBk
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) For contour plots, the native resolution of the
;            custom colortables should be sufficient.
;
;        (2) For smoothed pixel plots, NCOLORS=100 or higher will
;            eliminate the streaking caused by TVIMAGE's smoothing
;            algorithm.
;
;        (3) Some color tables were adapted from the ColorBrewer
;            package (see license info below).
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
; EXAMPLES:
;
;        CUSTOM_COLORTABLE, R, G, B, /NOLOAD, /DIAL
;
;             ; Returns the red, green, blue color vectors for the
;             ; DIAL colortable at native resolution (26 colors)
;
;        CUSTOM_COLORTABLE, NCOLORS=120, /DIAL
;
;             ; Loads the DIAL colortable and stretches it 
;             ; from 26 to 120 colors.
;
;        CUSTOM_COLORTABLE, /WhGrYlRd
;
;             ; Loads the WHITE-GREEN-YELLOW-RED (spectral) 
;             ; color table with 20 colors.
;        
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Adapted from "dial_ct.pro"
;                          - Now can compress the colortable if
;                            NCOLORS is less than N_ORIG
;                          - Added /BuWhWhRd keyword for selecting
;                            the BLUE-WHITE-WHITE-RED colortable
;                          - Added /BuYlYlRd keyword for selecting
;                            the BLUE-YELLOW-YELLOW-RED colortable
;                          - /DIFF is now a synonym for /BuWhWhRd
;                          - Added /UserDef keyword and internal
;                            routine DEFINE_UserDef for selecting
;                            a user-defined color table. 
;        phs, 12 Feb 2008: GAMAP VERSION 2.12
;                          - Now create /BuWhRd as a concatenation of
;                            the /WhBu and /WhRd colortables.
;                          - Updated the interpolation for case of  
;                            NCOLORS lt NORIG.  It works fine with all 
;                            the 4 diverging colortables, and keeps the 
;                            doubling of the middle range color if NCOLORS 
;                            is even and BuWhWhRd or BuYlYlRd is used. 
;        bmy, 18 Apr 2008: - Bug fix: don't overwrite colortable name
;                            for BuWhRd colortable 
;
;-
; Copyright (C) 2007-2008,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine custom_colortable"
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


pro Define_BuWhRd, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_BuWhRd returns the RGB color vectors for 
   ; the BLUE-WHITE-RED (aka DIFFERENCE) colortable w/ 19 colors. 
   ;
   ; NOTE: This color table is now defined from /WhBu and /WhRd.
   ;====================================================================
 
   ; Color table name
   Name = 'BLUE-WHITE-RED (diverging)'
 
   ; Get colors from WHITE-BLUE colortable
   Define_WhBu, Rb, Gb, Bb, Name1

   ; Get colors from WHITE-RED colortable
   Define_WhRd, Rr, Gr, Br, Name1

   ; Reverse the WHITE-BLUE colors, concatenate w/ WHITE-RED colors, and
   ; and keep only one white
   R = [ Reverse( Rb ), Rr[1:*] ]
   G = [ Reverse( Gb ), Gr[1:*] ]
   B = [ Reverse( Bb ), Br[1:*] ]

end

;------------------------------------------------------------------------------

pro Define_BuWhWhRd, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_BuWhWhRd returns the RGB color vectors for 
   ; the BLUE-WHITE-WHITE-RED colortable w/ 20 colors. 
   ;====================================================================

   ; Color table name
   Name = 'BLUE-WHITE-WHITE-RED (diverging)'
 
   ; Get colors from WHITE-BLUE colortable
   Define_WhBu, Rb, Gb, Bb, Name1

   ; Get colors from WHITE-RED colortable
   Define_WhRd, Rr, Gr, Br, Name1

   ; Reverse the WHITE-BLUE colors & concatenate w/ WHITE-RED colors 
   R = [ Reverse( Rb ), Rr ]
   G = [ Reverse( Gb ), Gr ]
   B = [ Reverse( Bb ), Br ]

end

;------------------------------------------------------------------------------

pro Define_BuYlRd, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_BuYlRd returns RGB color vectors for the
   ; BLUE-YELLOW-RED 12-color table from ColorBrewer.
   ;====================================================================

   ; Color table name
   Name = 'BLUE-YELLOW-RED (diverging)'

   ; Color vectors
   R = [  41,  38,  63, 114, 170, 224, 255, 255, 255, 247, 216, 165 ]
   G = [  10,  77, 160, 217, 247, 255, 255, 224, 173, 109,  38,   0 ]
   B = [ 216, 255, 255, 255, 255, 255, 191, 153, 114,  94,  50,  33 ]

end

;------------------------------------------------------------------------------

pro Define_BuYlYlRd, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_BuYlYlRd returns RGB color vectors for the
   ; BLUE-YELLOW-RED 12-color table from ColorBrewer.
   ;====================================================================

   ; Color table name
   Name = 'BLUE-YELLOW-YELLOW-RED (diverging)'

   ; Color vectors
   R = [  49,  69, 116, 171, 224, 255, 255, 254, 253, 244, 215, 165 ]
   G = [  54, 117, 173, 217, 243, 255, 255, 224, 174, 109,  48,   0 ]
   B = [ 149, 180, 209, 233, 248, 191, 191, 144,  97,  67,  39,  38 ]

end

;------------------------------------------------------------------------------

pro Define_Dial, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_DIAL returns the color vectors for the DIAL 
   ; LIDAR instrument colortable w/ 26 colors. (Courtesy Ed Browell)  
   ;====================================================================
 
   ; Color table name
   Name = 'DIAL/LIDAR (diverging)'

   ; Color vectors
   R = [ 255, 221, 187, 153, 119, 178, 133,  89,  44,   0, $
         191, 143,  95,  47,   0, 255, 255, 255, 255, 255, $
         255, 216, 178, 140, 102,   0 ]
 
   G = [ 140, 111,  82,  54,  25, 255, 204, 153, 102,  51, $
         255, 255, 255, 255, 255, 255, 207, 159, 111,  63, $
           0,   0,   0,   0,   0,   0 ]
 
   B = [ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, $
         191, 143,  95,  47,   0,   0,   0,   0,   0,   0, $
           0,  15,  31,  47,  63,   0 ]

end

;------------------------------------------------------------------------------

pro Define_ModSpec, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_MODSPEC returns RGB color vectors for 
   ; the MODIFIED SPECTRUM 11-color table. For more information, see:
   ; http://geography.uoregon.edu/datagraphics/color/RdYlBu_11.txt
   ;====================================================================

   ; Color table name
   Name = 'MODIFIED SPECTRUM (spectral)'

   ; Color vectors
   R = [ 38,  63,  114, 170, 224, 255, 255, 255, 247, 216, 165 ]
   G = [ 76,  160, 216, 247, 255, 255, 224, 173, 109, 38,  0   ]
   B = [ 255, 255, 255, 255, 255, 191, 153, 114, 94,  50,  33  ]

end

;------------------------------------------------------------------------------

pro Define_UserDef, R, G, B, Name, NColors

   ;====================================================================
   ; Internal routine DEFINE_UserDef is where you can manually specify
   ; the R, G, B color vectors for your favorite color table!
   ;====================================================================

   ; Color table name
   Name = 'USER-DEFINED'

   ; Color vectors -- by Dylan Millet
   ; Modified DIAL colortable (9 colors)
   R = [ 255, 183,   0, 109, 214, 255, 255, 240, 143 ]
   G = [ 255, 246, 225, 255, 255, 204,  99,   7,   0 ]
   B = [ 255, 255, 251, 125,  45,   0,   0,   0,   0 ]

end

;------------------------------------------------------------------------------

pro Define_WhBu, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_WhBu returns RGB color vectors for 
   ; the WHITE-BLUE 10-color table from ColorBrewer.  
   ;====================================================================

   ; Color table name
   Name = 'WHITE-BLUE (spectral)'

   ; Color vectors
   R = [ 255, 204, 178, 153, 127, 101, 76,  50,  25,  0   ]
   G = [ 255, 250, 242, 229, 212, 191, 165, 136, 101, 63  ]
   B = [ 255, 255, 255, 255, 255, 255, 255, 255, 240, 200 ]

end

;------------------------------------------------------------------------------

pro Define_WhGrYlRd, R, G, B, Name, NColors

   ;====================================================================
   ; Internal routine DEFINE_WhGrYlRd returns RGB color vectors for 
   ; the WHITE-GREEN-YELLOW-RED color table.  From Aaron von Donkelaar
   ; (Dalhousie Univ.)
   ;====================================================================

   ; Color table name
   Name = 'WHITE-GREEN-YELLOW-RED (spectral)'

   ; Color vectors
   R = [ 255, 183, 112,  41,   0,  15,  59, 104, 148, 192, $
         237, 255, 255, 255, 255, 255, 255, 232, 187, 143 ]

   G = [ 255, 246, 237, 228, 225, 255, 255, 255, 255, 255, $
         255, 244, 199, 155, 110,  66,  21,   0,   0,   0 ]

   B = [ 255, 255, 255, 255, 251, 198, 164, 130,  96,  62, $
         28,    0,   0,   0,   0,   0,   0,   0,   0,   0 ]

end

;------------------------------------------------------------------------------

pro Define_WhGyBk, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_GRAYSCALE returns the RGB color vectors 
   ; for the WHITE-GRAY-BLACK grayscale colortable. (cf. ColorBrewer)
   ;====================================================================
 
   ; Color table name
   Name = 'WHITE-GRAY-BLACK (spectral)'

   ; Color vectors
   R = [ 255, 240, 217, 189, 150, 115, 82, 37, 0 ]
   G = [ 255, 240, 217, 189, 150, 115, 82, 37, 0 ]
   B = [ 255, 240, 217, 189, 150, 115, 82, 37, 0 ]
   
end

;------------------------------------------------------------------------------

pro Define_WhRd, R, G, B, Name

   ;====================================================================
   ; Internal routine DEFINE_WhRd returns RGB color vectors for the
   ; WHITE-RED 10-color table from ColorBrewer. 
   ;====================================================================

   ; Color table name
   Name = 'WHITE-RED (spectral)'

   ; Color vectors
   R = [ 255, 250, 245, 245, 245, 245, 245, 230, 210, 165 ]
   G = [ 255, 230, 215, 200, 172, 120, 61,  39,  21,  0   ]
   B = [ 255, 220, 188, 153, 117, 86,  61,  53,  47,  33  ]

end

;------------------------------------------------------------------------------

pro Custom_ColorTable, R, G, B,                                    $
                       BuWhWhRd=BuWhWhRd,   BuWhRd=BuWhRd,         $
                       BuYlRd=BuYlRd,       BuYlYlRd=BuYlYlRd,     $
                       Dial=Dial,           Diff=Diff,             $
                       ModSpec=ModSpec,     Name=Name,             $
                       NColors=NColors,     NoLoad=NoLoad,         $
                       Truncate=Truncate,   UserDef=UserDef,       $
                       WhBu=WhBu,           WhRd=WhRd,             $
                       WhGrYlRd=WhGrYlRd,   WhGyBk=WhGyBk,         $
                       _EXTRA=e
   
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Load colortable or not?
   Load = 1L - Keyword_Set( NoLoad )

   ; Blank out all colors to white at first (if necessary)
   if ( Load ) then begin
      R = FltArr( 255 ) + 255
      G = FltArr( 255 ) + 255
      B = FltArr( 255 ) + 255
      TvLct, R, G, B
   endif

   ; Initialize color table name
   Name = ''
 
   ;====================================================================
   ; Define the custom colortable 
   ; (add new internal routines for new colortables!)
   ;====================================================================
 
   ; Get the color vectors and color table name
   ; /DIFF is a synonym for BuWhWhRd!
   if ( Keyword_Set( BuWhRd   ) ) then Define_BuWhRd,   R, G, B, Name
   if ( Keyword_Set( BuWhWhRd ) ) then Define_BuWhWhRd, R, G, B, Name
   if ( Keyword_Set( BuYlRd   ) ) then Define_BuYlRd,   R, G, B, Name
   if ( Keyword_Set( BuYlYlRd ) ) then Define_BuYlYlRd, R, G, B, Name
   if ( Keyword_Set( Dial     ) ) then Define_Dial,     R, G, B, Name
   if ( Keyword_Set( Diff     ) ) then Define_BuWhWhRd, R, G, B, Name
   if ( Keyword_Set( ModSpec  ) ) then Define_ModSpec,  R, G, B, Name
   if ( Keyword_Set( UserDef  ) ) then Define_UserDef,  R, G, B, Name
   if ( Keyword_Set( WhBu     ) ) then Define_WhBu,     R, G, B, Name
   if ( Keyword_Set( WhGyBk   ) ) then Define_WhGyBk,   R, G, B, Name
   if ( Keyword_Set( WhGrYlRd ) ) then Define_WhGrYlRd, R, G, B, Name
   if ( Keyword_Set( WhRd     ) ) then Define_WhRd,     R, G, B, Name   

   ; Error check
   if ( Name eq '' ) then Message, 'Color table not found!'
 
   ; Original Number of colors
   N_Orig = N_Elements( R )

   ; Return number of colors if NCOLORS is not passed
   if ( N_Elements( NColors ) ne 1 ) then NColors = N_Orig
 
   ;====================================================================
   ; Stretch colortable if NCOLORS is greater than N_ORIG
   ;==================================================================== 
   if ( NColors gt N_Orig ) then begin
 
      ; Old and new abscissae
      X_Old = FindGen( N_Orig )
      X_New = FindGen( NColors ) * Float( N_Orig ) / NColors
 
      ; Increase number of colors from N_ORIG to N_COLORS
      R     = Fix( Interpol( Temporary( R ), X_Old, X_New ) + 0.5 )
      G     = Fix( Interpol( Temporary( G ), X_Old, X_New ) + 0.5 )
      B     = Fix( Interpol( Temporary( B ), X_Old, X_New ) + 0.5 )
 
      ; Fix color values to the range 0-255
      R     = ( Temporary( R ) < 255 ) > 0
      G     = ( Temporary( G ) < 255 ) > 0 
      B     = ( Temporary( B ) < 255 ) > 0
 
   endif $

   ;=====================================================================
   ; Compress colortable if NCOLORS is less than N_ORIG (phs, 2/12/08)
   ;=====================================================================
   else if ( NColors lt N_Orig ) then begin

      if ( Keyword_Set( Truncate ) ) then begin

         ;---------------------------------------------------------------
         ; TRUNCATE ALL COLORTABLES (if /TRUNCATE is set!)
         ;---------------------------------------------------------------

         ; Truncate the colortable to N_COLORS w/o interpolating
         R = R[0:NColors-1]
         G = G[0:NColors-1]
         B = B[0:NColors-1]

      endif else begin

         if ( Keyword_Set( BuWhWhRd ) or Keyword_Set( BuYlYlRd ) ) then begin
    
            ;------------------------------------------------------------
            ; COMPRESS /BuYlYlRd or /BuWhWhRd COLORTABLES (phs, 2/12/08)
            ;
            ; Specific treatment so that the middle range color is 
            ; always present,  i.e., the doubling of the middle color 
            ; is conserved for even number of output colors.
            ;
            ; For BuWhRd, we have the usual behavior : middle range 
            ; color present only for odd number of output colors.  
            ; This is automatically done by applying congrid to all 
            ; colors at once (see below).
            ;------------------------------------------------------------

            ; Get middle color index
            Mid = N_Orig / 2

            ; tell if even or odd # of colors in output
            Odd_Out = NColors mod 2

            ; Number of colors for each half-side of the table. Make sure
            ; that it includes the middle range color
            Steps = Fix( NColors ) / 2 + Odd_Out
         
            ; Interpolate Blue and Red parts separately to the new number
            ; of colors w/ CONGRID 
            R1 = Congrid( R[0:Mid-1], Steps, /Minus_One, /Interp, _EXTRA=e )
            G1 = Congrid( G[0:Mid-1], Steps, /Minus_One, /Interp, _EXTRA=e )
            B1 = Congrid( B[0:Mid-1], Steps, /Minus_One, /Interp, _EXTRA=e )
            
            R2 = Congrid( R[Mid:*],   Steps, /Minus_One, /Interp, _EXTRA=e )
            G2 = Congrid( G[Mid:*],   Steps, /Minus_One, /Interp, _EXTRA=e )
            B2 = Congrid( B[Mid:*],   Steps, /Minus_One, /Interp, _EXTRA=e )

            ; Concatenate the vectors (final length = ncolors)
            R  = [ R1, R2[Odd_Out:*] ]
            G  = [ G1, G2[Odd_Out:*] ]
            B  = [ B1, B2[Odd_Out:*] ]
         
         endif else begin
         
            ;------------------------------------------------------------
            ; COMPRESS ALL OTHER COLORTABLES (phs, 2/12/08)
            ;------------------------------------------------------------

            ; Interpolate to the new number of colors w/ CONGRID 
            R = Congrid( R, NColors, /Minus_One, /Interp, _EXTRA=e )
            G = Congrid( G, NColors, /Minus_One, /Interp, _EXTRA=e )
            B = Congrid( B, NColors, /Minus_One, /Interp, _EXTRA=e )

         endelse

      endelse

   endif

   ;====================================================================
   ; Load new color table (if necessary) 
   ;====================================================================
   if ( Load ) then TvLct, R, G, B
 
   ; Quit
   return
end
