; $Id: colorbar.pro,v 1.3 2008/04/21 19:23:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        COLORBAR
;
; PURPOSE:
;        Draw a colorbar (legend) with labels
;
; CATEGORY:
;        Color
;
; CALLING SEQUENCE:
;        COLORBAR [ , Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        ANNOTATION -> Array with string label values.  If specified,
;             ANNOTATION will override the default label values, and 
;             will also override the LABEL keyword.
;
;        BOTOUTOFRANGE, TOPOUTOFRANGE -> a color index value for data
;             that falls below (or above) the normal plot range. If 
;             given, an extra box will be drawn to the left (or right) 
;             of the colorbar, and the colorbar will shrink in size.  
;             A default label '<' (or '>') will be placed below.  
;             NOTE: these options are only available for horizontal 
;             colorbars.
;
;        BOR_LABEL, TOR_LABEL -> label values for BOTOUTOFRANGE and 
;             TOPOUTOFRANGE that replace the defaults.
;
;        BOTTOM -> First color index to use.  Default is !MYCT.BOTTOM.
;             NOTE: In practice you shouldn't have to specify BOTTOM,
;             as the value from !MYCT.BOTTOM will reflect the settings
;             of the current colortable.
;
;        C_COLORS -> Array of color indices for "discrete" color bars
;             e.g. in filled contour plots. You must also use the 
;             C_LEVELS keyword, otherwise there will most likely be
;             a mismatch between your plot colors and your colorbar 
;             colors. COLORBAR normally limits the number of labels
;             it prints to 10. Use the SKIP keyword to force a different
;             behaviour. If C_COLORS is not undefined it overrides the
;             settings from NCOLORS, and BOTTOM.
;
;        C_LEVELS -> Array with label values for "discrete" colorbars.
;             Use the LABEL or ANNOTATION keyword for continuous
;             colorbars.  C_LEVELS must have the same number of elements 
;             as C_COLORS and assigns one label to each color change 
;             (LABEL distributes the labels evenly). Use the SKIP
;             keyword to skip labels.  As default, COLORBAR limits the 
;             number of labels printed to 10.
;
;        CHARSIZE -> Specifies the character size for colorbar labels.
;             Default is !P.CHARSIZE.
;
;        COLOR -> The drawing color for boxes and labels.  
;             Default is !MYCT.BLACK.
; 
;        DIVISIONS -> Number of labels to put on the colorbar.
;             Note that this keyword is overwritten by LABEL.
;             The labels will be equally spaced and the /LOG option
;             will be honored.
;
;        FLAGVAL -> If set, will place a tick mark with label at a
;             user-defined value.  You can use this to denote where
;             0 or 1 falls w/in a color range, for example.
;
;        FORMAT -> Output format of the labels.  Default is determined
;             according to the range given in min and max.  Label 
;             strings will be trimmed, so you can safely specify 
;             '(f14.2)' for example.
;
;        LABEL -> Array containing label values (must be numeric).
;             Normally, it is easier to generate labels with the 
;             DIVISIONS options, but this allows tighter control 
;             (e.g. 1,2,5,10,20 labels on logarithmic scales).
;             Default (if no DIVISIONS are given): MIN and MAX.
;             NOTE: ANNOTATION will 
;
;        /LOG -> Set this switch to invoke logarithmic spacing of 
;             labels.  The colors are *always* linearily distributed.
;
;        MAX -> Maximum value to plot.  Default is NCOLORS.
;
;        MIN -> Minimum value to plot.  Default is BOTTOM.
;
;        /NOGAP -> if 0 then there is a gap b/w the triangle or
;             rectangle OutOfRange boxes and the bar, else no
;             gap. Defalut is to have a gap. If /TRIANGLE and no
;             OutOfRange boxes are set then default is No Gap.
;
;        NCOLORS -> Number of colors to use in the colorbar.  Default 
;             is !MYCT.NCOLORS.  NOTE: In practice you shouldn't have 
;             to specify NCOLORS, as the value from !MYCT.NCOLORS will 
;             reflect the settings of the current colortable.
;
;        ORIENTATION -> Specifies the orientation of the colorbar
;             labels.  This keyword has the same behavior as the 
;             ORIENTATION option in XYOUTS (i.e. ORIENTATION=0 means
;             normal "left-right" text, ORIENTATION=-90 means "top-
;             bottom" text, etc.)
;
;        POSITION -> A position value or 4-element vector. If POSITION
;             contains only one element, it will be centered at the
;             bottom or right side of the page and extend over 60% of
;             the total plotting area.
;
;        SCIENTIFIC -> If set, will call STRSCI to put the colorbar
;             labels in scientific notation format (e.g. in the form
;             A x 10^B).  STRSCI will use the format string specified 
;             in the FORMAT keyword.
;
;        SKIP -> Print only every Nth discrete label.  The default is 
;             computed such that COLORBAR will print no more than 10 
;             labels.
;
;        TITLE -> A title string for the colorbar.  (This works similarly 
;             to the XTITLE or YTITLE options to the PLOT command.)
;
;        TICKLEN -> A number between 0 and 1 which defines the length
;             of the tick marks as a fraction of the size of the plot
;             box.  Default is 0.25.
;
;        /TRIANGLE -> to plot triangles at the end of the color bar. If 
;             OutOfRange boxes are requested, then the triangles
;             replace the rectangle.
;
;        UNIT -> A unit string that will be added to the right of the
;             labels.  If /VERTICAL is set, then the unit string will
;             be placed at the top of the labels.
;
;        /VERTICAL -> Set this keyword to produce a vertical colorbar
;             (default is horizontal).  Note that out-of-range boxes are
;             only implemented for horizontal color bars.  
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ====================================
;        STRSCI (function)  TRIANGLE
;
; REQUIREMENTS:
;        Assumes that we are using a MYCT-defined colortable.
;
; NOTES:
;        (1) This routine was designed after David Fanning's colorbar
;            routine and adapted to our needs.  Some of the postscript
;            handling of DF was removed, positioning is a little easier 
;            but maybe a little less flexible; out-of-range boxes have 
;            been added.
;
;        (2) The !MYCT system variable contains the properties of the
;            current MYCT-defined colortable.  You normally should not
;            have to explicity pass BOTTOM or NCOLORS, as these
;            keywords will be initialized from the values from !MYCT.
;
; EXAMPLES:
;        COLORBAR, MIN=MIN( DATA, MAX=M ), MAX=M
;
;            ; Draw a horizontal colorbar with all available colors
;            ; Default placement is at the bottom of the page.
;            ; will be placed at the bottom of the page
;
;        COLORBAR, MIN=0.1, MAX=10, /LOG, UNIT='[ppt]', $
;            LABELS=[0.1, 0.5, 1, 5, 10 ], 
;            POSITION=[0.3. 0.3, 0.3, 0.3]
; 
;            ; Draw another colorbar above the first one, 
;            ; use logarithmic scale
;
;        COLORBAR, MIN=0.1, MAX=10, /LOG, UNIT='[ppt]', $
;            LABELS=[0.1, 0.5, 1, 5, 10 ], 
;            POSITION=[0.1, 0.1, 0.1, 0.1], /VERTICAL
;
;            ; Draw vertical colorbar closer to the left edge of 
;            ; the plot.  Otherwise options are the same as in the 
;            ; previous example.
;
;        COLORBAR, MIN=0, MAX=100, $
;            DIVISIONS=5, TOPOUTOFRANGE=!MYCT.WHITE
;
;            ; Draw horizontal colorbar with out-of-range box
;            ; (colored white) to the right of the max value.
;
;        COLORBAR, MIN=0, MAX=100, $
;            DIVISIONS=5, TOPOUTOFRANGE=!MYCT.WHITE, $
;            ANNOTATION=[ '0', '2,500', '5,000', '7,500', '10,000' ]
;
;            ; Same example as above, but this time we use the
;            ; ANNOTATION keyword to override the default labels
;            ; with string labels.
;
; MODIFICATION HISTORY:
;        mgs, 02 Jun 1998: VERSION 1.00
;        mgs, 14 Nov 1998: - changed default format to f14.2 from f6.2
;        mgs, 19 Nov 1998: - added cbdefaultformat function to better handle
;                            default labeling format.
;        mgs, 28 Nov 1998: - default labelling format now exponential for
;                            values gt 1.e6
;        mgs, 19 May 1999: - unit string placed a little further right
;                            in horizontal colorbars.
;        mgs, 27 May 1999: - added functionality for discrete colorbars
;                            (C_COLORS, C_LEVELS, and SKIP keywords)
;        bmy, 02 Jun 1999: - added /SCIENTIFIC keyword
;                          - updated comments
;        mgs, 03 Jun 1999: - fixed discrete labeling x positions
;        bmy, 27 Jul 2000: TOOLS VERSION 1.46
;                          - added ORIENTATION keyword so that the user
;                            can control the vertical colorbar labels
;        bmy, 27 Sep 2002: TOOLS VERSION 1.51
;                          - Now use 2 decimal places for exponential
;                            default format instead of 3
;        bmy, 18 Oct 2002: TOOLS VERSION 1.52
;                          - now use _EXTRA=e to pass commands to
;                            XYOUTS (i.e. to set label thickness)
;        bmy, 26 Nov 2002: - Added ANNOTATION keyword to print
;                            string labels instead of numeric labels
;        bmy, 26 Nov 2003: TOOLS VERSION 2.01
;                          - make sure MINV, MAXV, and DIVISIONS
;                            are scalars so as not to generate the
;                            color bar labels incorrectly.
;        bmy, 21 May 2004: TOOLS VERSION 2.02
;                          - If SKIP is passed, make sure that it is
;                            never less than 1.
;                          - added TICKLEN and FLAGVAL keywords
;                          - now add ticks where labels are printed
;                          - Cosmetic changes, updated comments
;        bmy, 07 Mar 2007: TOOLS VERSION 2.06
;                          - Updated documentation and examples
;  dbm & bmy, 13 Jun 2007: - Now define default colors for contour plots
;                            if C_LEVELS is passed but C_COLORS isn't
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;  cdh & phs, 19 Nov 2007: GAMAP VERSION 2.11
;                          - Added out of range boxes options for
;                            vertical bar
;                          - Added TRIANGLE and NoGAP keyword
;                          - Set default for case of /TRIANGLE, but no
;                            OutOfRange boxes.
;        phs, 21 Apr 2008: GAMAP VERSION 2.12
;                          - Bug fix default MAXV should be NCOLORS+BOTTOM
;
;-
; Copyright (C) 1998-2008, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to yantosca@seas.harvard.edu
; or plesager@seas.harvard.edu with subject "IDL routine colorbar"
;-----------------------------------------------------------------------


function CBDefaultFormat, MinV, MaxV, Log=Log

   ;====================================================================
   ; Function CBDefaultFormat returns a default format string depending 
   ; on the min and max value, and the LOG flag
   ;====================================================================

   ; general default
   res = '(f14.2)'              

   ; determine necessary number of decimal places
   ndec    = fix( 2.-alog10( (maxv-minv) > 1.0E-31 ) )
   ndecmin = fix( 2.-alog10( minv        > 1.0E-31 ) )

   if ( keyword_set( log ) ) then ndec = max( [ndec, ndecmin-1 ] )

   ; Change the exponential formats to 2 decimal places (bmy, 9/28/02)
   if ( ndec gt  2         ) then res = '(e12.2)'
   if ( ndec eq  3 AND log ) then res = '(f14.3)'
   if ( ndec le  0         ) then res = '(I14)'
   if ( ndec le -6         ) then res = '(e12.2)'
   
   ; Return to main program
   return, res

end

;------------------------------------------------------------------------------

pro ColorBar, Color=Color,                 Bottom=Bottom,               $
              NColors=NColors,             Min=MinV,                    $
              Max=MaxV,                    Label=Label,                 $
              Divisions=Divisions,         C_Colors=C_Colors,           $
              C_Levels=C_Levels,           Skip=Skip,                   $
              Format=Format,               Log=Log,                     $  
              Vertical=Vertical,           Position=Position,           $
              Charsize=Charsize,           Title=Title,                 $
              Unit=Unit,                   BotOutOfRange=BotOutOfRange, $
              TopOutOfRange=TopOutOfRange, BOR_Label=BOR_Label,         $
              TOR_Label=TOR_Label,         Scientific=Scientific,       $
              Orientation=Orientation,     Annotation=Annotation,       $
              FlagVal=FlagVal,             TickLen=TickLen,             $
              NoGap=NoGap,                 Triangle=TTriangle,          $ 
              _EXTRA=e
    
   ; Pass external functions
   FORWARD_FUNCTION StrSci
 
   ;===================================================================
   ; Initialization
   ;===================================================================

   ; On/Off keywords
   IsLevels   = ( N_Elements( C_Levels ) gt 0 )
   IsColors   = ( N_Elements( C_Colors ) gt 0 )
   IsDiscrete = ( IsColors OR IsLevels )
   Log        = Keyword_Set( Log        )
   Vertical   = Keyword_Set( Vertical   ) 
   Scientific = Keyword_Set( Scientific )
   DoFlagVal  = ( ( not IsDiscrete ) AND ( N_Elements( FlagVal ) gt 0 ) )

   ; Determine if triangle are used forbar ends or out of range boxes 
   ; (cdh, 11/17/2007)
   TTriangle  = Keyword_Set( TTriangle )

   ; Select the size of the space between the out-of-bounds boxes or triangle
   ; and the rest of the colorbar (cdh, 11/17/2007)
   NoGap      = Keyword_Set( NoGap )
   if ( NoGap )                        $
      then Gap = 0.0                   $
      else Gap = TTriangle ? 0. : 0.01 ; default GAP for triangle is 0. (phs)

   ; Keyword Defaults
   if ( N_Elements( Bottom        ) eq 0 ) then Bottom        = !MYCT.BOTTOM
   if ( N_Elements( CharSize      ) eq 0 ) then CharSize      = !P.CHARSIZE
   if ( N_Elements( Color         ) eq 0 ) then Color         = !MYCT.BLACK
   if ( N_Elements( Divisions     ) eq 0 ) then Divisions     = 2
   if ( N_Elements( NColors       ) eq 0 ) then NColors       = !MYCT.NCOLORS 
   if ( N_Elements( MinV          ) eq 0 ) then MinV          = Bottom
   ;---------------------------------------------------------------------------
   ; Prior to 4/21/08:
   ; Bug fix: Default MAXV should be NCOLORS+BOTTOM (phs, 4/21/08)
   ;if ( N_Elements( MaxV          ) eq 0 ) then MaxV          = NColors
   ;---------------------------------------------------------------------------
   if ( N_Elements( MaxV          ) eq 0 ) then MaxV          = NColors+Bottom
   if ( N_Elements( Orientation   ) eq 0 ) then Orientation   = 0
   if ( N_Elements( TickLen       ) eq 0 ) then TickLen       = 0.25 
   if ( N_Elements( Title         ) eq 0 ) then Title         = ''
   if ( N_Elements( Unit          ) eq 0 ) then Unit          = ''

   ; Make sure MINV is not less than zero for log scale
   if ( Log AND MinV le 0.               ) then MinV          = 0.01

   ; Bottom out of range
   if ( N_Elements( BotOutOfRange ) eq 0 ) $
      then BotOutOfRange = TTriangle ? 0 : -1

   if ( N_Elements( BOR_Label     ) eq 0 ) $
      then BOR_Label     = TTriangle ? '' : '<'
   
   ; Top out of range
   if ( N_Elements( TopOutOfRange ) eq 0 ) then $
      TopOutOfRange      = TTriangle ? NColors + Bottom -1 : -1

   if ( N_Elements( TOR_Label     ) eq 0 ) $
      then TOR_Label     = TTriangle ? '' : '>'
   
   ; Get default format string
   if ( N_Elements( Format      ) eq 0 ) $
      then Format = CBDefaultFormat( MinV, MaxV, Log=Log )

   ;------------------------------------------------------------------------
   ; Prior to 11/19/07:
   ; I don't see anything wrong with using out-of-range boxes with a
   ; discrete color bar, so this section is inactive (cdh, 11/17/2007)
   ;
   ;; Disable out-of-range boxes for discrete color tables
   ;; or for the vertical colorbar
   ;if ( IsDiscrete ) then begin
   ;    BotOutOfRange = -1
   ;    TopOutOfRange = -1
   ;endif
   ;------------------------------------------------------------------------

   ;===================================================================
   ; Intialization continued: : Compute default labels
   ;===================================================================

   ; If C_LABELS is passed but not C_COLORS then pick default colors 
   ; for contour or filled contour plots (dbm, bmy, 6/13/07)
   if ( IsDiscrete and not IsColors ) then begin
      C_Colors = Fix( ( IndGen( N_Elements( C_Levels ) )   / $
                      (   1.0 * N_Elements( C_Levels ) ) ) * $
                      NColors + Bottom )
   endif

   ; Compute index of color labels for which labels will be printed
   if ( N_Elements( Skip ) eq 0 ) then begin
      if ( IsDiscrete )                                            $
         then Skip = Fix( ( N_Elements( C_Colors ) -1 ) / 10 ) + 1 $
         else Skip = 1
   endif

   ; Make sure that SKIP is never less than 1 (bmy, 3/3/04)
   Skip = Skip > 1 
  
   ; For discrete colorbar, reset DIVISIONS to # of non-skipped color levels
   if ( IsDiscrete AND N_Elements( C_Levels ) eq 0 ) $
      then Divisions = Fix( ( N_Elements( C_Colors ) - 1 ) / Skip ) + 1 

   ; Make sure MAXV, MINV, DIVISIONS are scalars, otherwise
   ; the labels will be generated incorrectly (bmy, 11/26/03)
   Divisions = Divisions[0]
   MaxV      = MaxV[0]
   MinV      = MinV[0]

   ; If LABEL is not passed, generate defaults
   if ( N_Elements( Label ) eq 0 ) then begin
      if ( Divisions gt 1 ) then begin
         if ( Log ) then $
            label = 10^(findgen(divisions)/(divisions-1)*  $
                        (alog10(maxv/minv))+alog10(minv) ) $
         else $
            label = findgen(divisions)/(divisions-1)*(maxv-minv)+minv 
      endif else $
         label = -1
   endif

   ; Overwrite standard labels with C_Levels if given
   if ( IsDiscrete AND N_Elements( C_Levels) gt 0 ) then begin
      Ind   = indgen( ( N_Elements(C_Levels)-1 )/Skip + 1 ) * Skip
      Label = C_Levels[Ind]
   endif
 
   ; ANNOTATION make a string for label characters (bmy, 11/25/02)
   if ( N_Elements( Annotation ) eq 0 ) $
      then Annotation = StrTrim( String( Label, Format=Format ), 2 )
 
   ; Force ANNOTATION to have same # of elements as LABEL (bmy, 11/25/02)
   if ( N_Elements( Annotation ) ne N_Elements( Label ) ) $
      then Message, 'ANNOTATION must have same # of elements as LABEL!'
   
   ;===================================================================
   ; POSITION: if only one element then center bar according
   ; to vertical keyword and give it a width of 60%
   ;===================================================================
   if ( N_Elements( Position ) eq 0 ) $
      then Position = Abs( ( Vertical ) - 0.10 )

   if ( N_Elements( Position ) ne 4 ) then begin
      if ( Vertical )                                                $
         then Position = [ Position[0], 0.2, Position[0]+0.03, 0.8 ] $
         else Position = [ 0.2, Position[0], 0.8, Position[0]+0.03 ] 
   endif
   
   ;=================================================================== 
   ; Make space for extra boxes for out of range. Now account for 
   ; Vertical (cdh, 11/17/2007).
   ;===================================================================
   if ( Vertical ) then begin
      BarPos       = Position
      x10          = ( Position[3] - Position[1] ) / 10. > 0.03
      TrueCharSize = !D.Y_CH_SIZE * CharSize
      LabelPos     = ( Position[2] *!D.X_VSIZE + TrueCharSize * 0.5 ) / $
                     !D.X_VSIZE
   endif else begin
      BarPos       = Position
      x10          = ( Position[2] - Position[0] ) / 10. > 0.03
      TrueCharSize = !D.Y_CH_SIZE * CharSize
      LabelPos     = ( Position[1] * !D.Y_VSIZE - TrueCharSize*1.05 ) / $
                     !D.Y_VSIZE
   endelse

   ;===================================================================
   ; Draw bottom-out-of-range box.  Now account for both vertical and 
   ; triangle options (cdh, 11/17/2007).
   ;===================================================================
   if ( BotOutOfRange ge 0 ) then begin

      if ( Vertical ) then begin

         ; Get rectangle vectors
         Rpos = [ Position[0], Position[1], Position[2], Position[1]+x10 ]

         ; Get polygon for out-of-bounds box
         if ( TTriangle )                        $
            then Triangle, Rpos, Px, Py, /Down   $
            else Rectangle, Rpos, Px, Py

         ; Print bottom-out-of-range label
         XyOutS, LabelPos, Position[1], BOR_Label,$
            /Norm, Color=Color, Align=0.0, CharSize=CharSize, _EXTRA=e

         ; Shorten central bar accordingly
         BarPos = [ BarPos[0], BarPos[1]+x10+Gap, BarPos[2], BarPos[3] ]

      endif else begin

         ; Get rectangle vectors
         Rpos = [ Position[0], Position[1], Position[0]+x10, Position[3] ]

         ; Get polygon for out-of-bounds box
         if ( TTriangle )                        $
            then Triangle,  Rpos, Px, Py, /Left  $
            else Rectangle, Rpos, Px, Py

         ; Print bottom-out-of-range label
         XyOutS, Position[0], LabelPos, BOR_Label,$
            /Norm, Color=Color, Align=0.0, CharSize=CharSize, _EXTRA=e

         ; Shorten central bar accordingly
         BarPos = [ BarPos[0]+x10+Gap, BarPos[1], BarPos[2], BarPos[3] ]

      endelse

      ; Draw rectangle box and fill w/ color (usually white)
      Polyfill, Px, Py, /norm, Color=BotOutOfRange, /Fill
      Plots,    Px, Py, /norm, Color=Color,         Thick=!P.THICK

   endif
 
   ;====================================================================
   ; Draw top-out-of-range box.  Now account for Vertical and 
   ; Triangle option (cdh, 11/17/2007).
   ;====================================================================
   if ( TopOutOfRange ge 0 ) then begin

      if ( Vertical ) then begin

         ; Get rectangle vectors
         Rpos = [ Position[0], Position[3]-x10, Position[2], Position[3] ]
         
         ; Construct polygon for out of bounds box
         if ( TTriangle )                       $
            then Triangle,  Rpos, Px, Py, /Up   $
            else Rectangle, Rpos, Px, Py

         ; Print top-out-of-range label
         XyOutS, LabelPos, Position[3], TOR_Label,$
            /Norm, Color=Color, Align=0.5, CharSize=CharSize

         ; Shorten central bar accordingly
         BarPos = [ BarPos[0], BarPos[1], BarPos[2], BarPos[3]-x10-Gap ]


      endif else begin

         ; Get rectangle vectors
         Rpos = [ Position[2]-x10, Position[1], Position[2], Position[3] ]

         ; Construct polygon for out of bounds box
         if ( TTriangle )                         $
            then Triangle,  Rpos, Px, Py, /Right  $
            else Rectangle, Rpos, Px, Py

         ; Print top-out-of-range label
         XyOutS, Position[2]-x10/3., LabelPos, TOR_Label,$
            /Norm, Color=Color, Align=0., CharSize=CharSize

         ; Shorten central bar accordingly
         BarPos = [ BarPos[0], BarPos[1], BarPos[2]-x10-Gap, BarPos[3] ]

      endelse

      ; Draw rectangle box and fill w/ color (usually white)
      PolyFill, Px, Py, /Norm, Color=TopOutOfRange, /Fill
      Plots,    Px, Py, /Norm, Color=Color,         Thick=!P.THICK

   endif
 
   ; Reset bar position in case of error 
   if ( BarPos[0] gt BarPos[2] ) then BarPos = Position
  
   ;==================================================================== 
   ; Create (central) colorbar after plotting out-of-range boxes
   ;==================================================================== 

   ; X, Y starting position of central colorbar
   XStart =  BarPos[0] * !D.X_VSIZE
   YStart =  BarPos[1] * !D.Y_VSIZE

   ; X, Y dimension of central colorbar
   XSize = ( BarPos[2] - BarPos[0] ) * !D.X_VSIZE
   YSize = ( BarPos[3] - BarPos[1] ) * !D.Y_VSIZE
 
   ; Test for discrete or continuous color bar
   if ( IsDiscrete ) then begin

      ;=================================================================
      ; DISCRETE COLOR BAR: need to polyfill individual rectangles
      ; compute position for each rectangle
      ;=================================================================
      if ( Vertical ) then begin
         Dx = 0.
         Dy = YSize / N_Elements( C_Colors ) 
      endif else begin
         Dx = XSize / N_Elements( C_Colors )
         Dy = 0.
      endelse

      ; Loop over discrete colors
      for I = 0, N_Elements( C_Colors )-1 do begin

         ; Get rectangle vectors for each discrete color
         if ( Vertical )                                                      $
            then Box = [ XStart, YStart+i*dy, XStart+XSize, YStart+(i+1)*dy ] $
            else Box = [ XStart+i*dx, YStart, XStart+(i+1)*dx, YStart+YSize ]

         ; Fill the rectangle w/ this color
         RectAngle, Box, Px, Py
         PolyFill, Px, Py, /Device, Color=C_Colors[i]
      endfor

   endif else begin

      ;=================================================================
      ; CONTINUOUS COLORBAR: use TV to display a smooth range of colors
      ;=================================================================

      ; Byte index array of color values
      BCol = BIndGen( NColors ) + Bottom

      ; Pad into an array 5 pixels wide
      if ( Vertical )                                       $
         then Bar = Replicate( 1B, 5 ) # Bcol               $
         else Bar = BCol               # Replicate( 1B, 5 )
    
      ; Call TV to plot the colorbar
      if ( !D.Name eq 'PS' ) then begin
         TV, Bar, xstart, ystart, XSIZE=xsize, YSIZE=ysize
      endif else begin
         Bar = CONGRID( Bar, CEIL( XSize ), CEIL( YSize ), /INTERP)
         TV, Bar, xstart, ystart
      endelse
   endelse

    ; Draw frame around colorbar 
    RectAngle, BarPos, Px, Py
    PlotS, Px, Py, /Norm, Color=Color, Thick=!P.THICK
 
    ;===================================================================
    ; LABELLING : set up plot coordinates with x or y range eq to 
    ; device size, then use position parameters for unit and title
    ;===================================================================
    if ( N_Elements( Label ) lt 2 ) then return

    ; Convert LABEL to string representation SLABEL here
    ; If /SCIENTIFIC is set, then put the labels into the form A x 10^B.  
    if ( Scientific )                                                $
       then SLabel = StrSci( Label, /Trim, Format=Format, _EXTRA=e ) $
       else SLabel = StrTrim( String( Label, Format=Format ), 2 )

    ; If ANNOTATION isn't passed, then use SLABEL instead (bmy, 11/25/02)
    if ( N_Elements( Annotation ) eq 0 ) then Annotation = SLabel

    ;===================================================================
    ; Plot labels and tickmarks around the VERTICAL colorbar
    ;===================================================================
    if ( Vertical ) then begin

       ; Compute quantities for DISCRETE or CONTINUOUS colorbar
       if ( IsDiscrete ) then begin 
          YTicks = 1
          YRange = [ 0, N_Elements( C_Colors ) ] ; one more!
          YPos   = FIndGen( N_Elements( Label ) + 1 ) * Skip
          NPos   = N_Elements( Label ) + 1
          XRange = [ -( BarPos[2] - BarPos[0] ) * !D.X_VSIZE, 0.0 ]
          XPos   = Replicate( TrueCharSize*1.05, NPos )
       endif else begin
          YTicks = Divisions - 1
          YRange = [ MinV, MaxV ]
          YPos   = Label
          NPos   = N_Elements( Label )
          XRange = [ -( BarPos[2] - BarPos[0] ) * !D.X_VSIZE, 0.0 ]
          XPos   = Replicate( TrueCharSize*1.05, NPos )
       endelse

       ; Set ALIGN keyword properly for the given label ORIENTATION
       if ( Orientation eq 90 ) $
          then Align = 0.5      $
          else Align = 0.0
        
       ;-----------------------
       ; Plot labels & ticks
       ;-----------------------

       ; Establish PLOT coords, plot tickmarks
       Plot, [0], [0],                                                     $
          /NoData,          YLog=( Log AND not IsDiscrete ),               $
          YStyle=1,         XStyle=5,                                      $
          YRange=YRange,    XRange=XRange,                                 $
          Position=BarPos,  /NOERASE,                                      $
          YTicks=YTicks,    YTickLen=TickLen,                              $ 
          Color=Color,      YTickN=Replicate( ' ', Divisions )

       ; Plot Y-axis labels
       XyOutS, XPos, YPos, Annotation,                                     $
          /Data,       Color=Color,             CharSize=CharSize,         $
          Align=Align, Orientation=Orientation, _EXTRA=e
    
       ;-----------------------
       ; Flag a specific value
       ;-----------------------
       if ( DoFlagVal ) then begin

          ; Flag value
          Oplot, XRange, [ FlagVal, FlagVal ], Color=Color, Thick=2

          ; Plot label 
          S = StrTrim( String( FlagVal, Format=Format ), 2 )
          XYOutS, TrueCharSize*1.05, FlagVal, S,                           $
             /Data,       Align=Align,              CharSize=CharSize,     $
             Color=Color, Orientation=Orientation, _EXTRA=e
       endif

       ;-----------------------
       ; Plot UNIT string
       ;-----------------------
       if ( Unit ne '' ) then begin

          ; Set plot coordinates
          Plot, [0], [0], /NoData,                                         $
             XStyle=5,          YStyle=5,                                  $
             XRange=XRange,     YRange=[0,1],                              $
             Position=Position, /NOERASE
 
          ; Plot unit string
          XyOutS, XPos[0], 1.15, Unit,                                     $
             /Data,       Color=Color,             Charsize=Charsize,      $
             Align=Align, Orientation=Orientation, _EXTRA=e
       endif

       ;-----------------------
       ; Plot TITLE string
       ;-----------------------       
       if ( Title ne '' ) then begin
          XyOutS, TrueCharSize*2.15, 0.5, Title,                           $
             /Data,       Color=Color,             Charsize=Charsize,      $
             Align=Align, Orientation=Orientation, _EXTRA=e
       endif
        
    endif $
        
    ;===================================================================
    ; Plot labels and tickmarks around the HORIZONTAL colorbar
    ;===================================================================
    else begin

       ; Compute quantities for DISCRETE or CONTINUOUS colorbar
       if ( IsDiscrete ) then begin 
          XRange = [ 0, N_Elements( C_Colors ) ] ; one more!
          XPos   = FIndGen( N_Elements( Label ) + 1 ) * Skip
          NPos   = N_Elements( Label ) + 1
          XTicks = 1
          YPos   = Replicate( -TrueCharSize*1.05, NPos )
          Yrange = [ 0.0, ( BarPos[3] - BarPos[1] ) * !D.Y_VSIZE ]
       endif else begin
          XRange = [ MinV, MaxV ]
          XPos   = Label
          NPos   = N_Elements( Label )
          XTicks = Divisions - 1
          YPos   = Replicate( -TrueCharSize*1.05, NPos )
          Yrange = [ 0.0, ( BarPos[3] - BarPos[1] ) * !D.Y_VSIZE ]
       endelse

       ;-----------------------
       ; Plot labels & ticks
       ;-----------------------
       Plot, [0, 1], [0, 1],                                            $
          /NoData,          XLog=( Log AND not IsDiscrete ),            $
          XStyle=1,         YStyle=5,                                   $
          XRange=XRange,    YRange=YRange,                              $
          Position=BarPos,  /NOERASE,                                   $
          XTicks=XTicks,    XTickLen=TickLen,                           $ 
          Color=Color,      XTickN=Replicate( ' ', Divisions )

       ; Print X-axis labels
       XyOutS, XPos, YPos, Annotation,                                  $ 
          /Data,      Color=Color,             CharSize=CharSize,       $
          Align=0.5,  Orientation=Orientation, _EXTRA=e
        
       ;-----------------------
       ; Flag a specific value
       ;-----------------------
       if ( DoFlagVal ) then begin

          ; Flag value
          Oplot, [ FlagVal, FlagVal ], YRange, Color=Color, Thick=2

          ; Plot label 
          S = StrTrim( String( FlagVal, Format=Format ), 2 )
          XYOutS, FlagVal, -TrueCharSize*1.05, S,                       $
             /Data,       Align=0.5,               CharSize=CharSize,   $
             Color=Color, Orientation=Orientation, _EXTRA=e
       endif

       ;-----------------------
       ; Plot UNIT string
       ;-----------------------
       if ( Unit ne '' ) then begin
           
          ; Establish plot coordinates
          Plot, [0, 1], [0, 1], /NoData,                                 $
             XStyle=5,        YStyle=5,                                  $
             XRange=[0,1],    YRange=YRange,                             $
             Position=Position, /NOERASE

          ; Print unit string
          XyOutS, 1.15, YPos[0], Unit,                                   $
             /Data, Color=Color, CharSize=CharSize, Align=0, _EXTRA=e
       endif

       ;-----------------------
       ; Plot TITLE string
       ;----------------------- 
       if ( Title ne '' ) then begin
          XyOutS, 0.5, -TrueCharSize*2.15, Title, $
             /Data, Color=Color, CharSize=CharSize, Align=0.5, _EXTRA=e
       endif

    endelse
 
    ; Exit
    return
end
 
 
