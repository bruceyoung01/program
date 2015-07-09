; $Id: colorbar.pro,v 1.4 2005/04/11 14:43:23 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        COLORBAR
;
; PURPOSE:
;        Draw a colorbar (legend) with labels
;
; CATEGORY:
;        Plot utilities
;
; CALLING SEQUENCE:
;        COLORBAR [ , Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        COLOR -> The drawing color for boxes and labels.  
;             The default is !MYCT.BLACK.
; 
;        BOTTOM -> First color index to use.  The default is !MYCT.BOTTOM.
;
;        NCOLORS -> Number of colors to use.  THe(default: 
;             !D.N_Colors-bottom)
;
;        MIN, MAX -> range of the data (default bottom and 
;             bottom+ncolors-1
;
;        LABEL -> array with label values (must be numeric).
;             Normally, it is easier to generate labels with the 
;             DIVISIONS options, but this allows tighter control 
;             (e.g. 1,2,5,10,20 labels on logarithmic scales).
;             Default (if no DIVISIONS are given): min and max
;
;        DIVISIONS -> number of labels to put on the colorbar.
;             Note that this keyword is overwritten by LABEL.
;             The labels will be equally spaced and the /LOG option
;             will be honored.
;
;        FORMAT -> output format of the labels. Default is determined
;             according to the range given in min and max. Label strings 
;             will be trimmed, so you can safely specify f14.2 for example.
;
;        SCIENTIFIC -> If set, will call STRSCI to put the colorbar
;             labels in scientific notation format (e.g. in the form
;             A x 10^B).  STRSCI will use the format string specified 
;             in the FORMAT keyword.
;
;        /LOG -> logarithmic spacing of labels (colors are *always* 
;             linearily distributed)
;
;        C_COLORS -> array of color indices for "discrete" color bars
;             e.g. in filled contour plots. You must also use the 
;             C_LEVELS keyword, otherwise there will most likely be
;             a mismatch between your plot colors and your colorbar 
;             colors. COLORBAR normally limits the number of labels
;             it prints to 10. Use the SKIP keyword to force a different
;             behaviour. If C_COLORS is not undefined it overrides the
;             settings from NCOLORS, and BOTTOM.
;
;        C_LEVELS -> array with label values for discrete colorbars.
;             Use the LABEL keyword for continuous colors. C_LEVELS
;             must have the same number of elements as C_COLORS and 
;             assigns one label to each color change (LABEL distributes
;             the labels evenly). Use the SKIP keyword to skip labels.
;             As default, COLORBAR limits the number of labels printed 
;             to 10.
;
;        SKIP -> print only every nth discrete label. Default is computed
;             so that COLORBAR will print no more than 10 labels.
;
;        /VERTICAL -> set this keyword to produce a vertical colorbar
;             (default is horizontal). Note that out-of-range boxes are
;             only implemented for horizontal color bars.
;
;        POSITION -> a position value or 4-element vector. If POSITION
;             contains only one element, it will be centered at the
;             bottom or right side of the page and extend over 60% of
;             the total plotting area.
;
;        CHARSIZE -> character size (default !p.charsize)
;
;        TITLE -> a title string (similar to XTITLE or YTITLE for PLOT)
;
;        UNIT -> a unit string that will be added to the right (top) of
;             the labels
;
;        BotOutOfRange, TopOutOfRange -> a colorindex value for data
;             that falls below or above the normal plot range. If given,
;             an extra box will be drawn to the left or right of the color-
;             bar, and the colorbar will shrink in size. A default label
;             '<' ('>') will be placed below. Note that these options are
;             only available for horizontal colorbars.
;
;        BOR_Label, TOR_Label -> label values for BOTOutOfRange and 
;             TopOutOfRange that replace the defaults.
;
;        TICKLEN -> A number between 0 and 1 which defines the length
;             of the tick marks as a fraction of the size of the plot
;             box.  Default is 0.25.
;
;        FLAGVAL -> If set, will place a tick mark with label at a
;             user-defined value.  You can use this to denote where
;             0 or 1 falls w/in a color range.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        ==============================
;        
;
;        External Subroutines Required:
;        ==============================
;
; REQUIREMENTS:
;        Requires routines from the TOOLS package.  Also assumes that
;        we are using a MYCT-defined colortable.
;
;        This program uses STRSCI for labels in scientific notation.
;
; NOTES:
;        This routine was designed after David Fanning's colorbar
;        routine and adapted to our needs. Some of the postscript
;        handling of DF was removed, positioning is a little easier but
;        maybe a little less flexible; out-of-range boxes have been
;        added.
;
;        A nice color choice for global 3D model output is achieved with
;        myct (EOS-B colortable):
;           myct,27,bottom=20,range=[0.1,0.7]
;        If you want discrete color levels, add ncolors=X  keyword
;
; EXAMPLE:
;        ; draw a colorbar with all available colors on top of index 20
;        ; will be placed at the bottom of the page
;
;        colorbar,bottom=20,min=min(data),max=max(data)
;
;        ; draw another colorbar above the first one, use logarithmic scale
;
;        colorbar,bottom=20,min=0.1,max=10.,labels=[0.1,0.5,1.,5.10.],/log, $
;              position=0.3,unit='ppt'
;
;        ; (simply add keyword /vertical and you'll get it flipped)
;
;        ; colorbar with out-of-range information on right side only
;        ; Here we used 20 colors for the plot, the 21st is for 
;        ; out-of-range data
;
;        colorbar,bottom=20,ncolors=20,min=0,max=100,divisions=5, $
;              TopOutOfRange=40
;
;        ; (use colorindex 0 if out-of-range color shall be white (myct))
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
;                          
;-
; Copyright (C) 1998-2004, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine colorbar"
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

pro original_ColorBar, Color=Color,                 Bottom=Bottom,               $
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
              _EXTRA=e, UpperLabel=UpperLabel, positive = positive,     $
              xminor = xminor
   
   ; Pass external functions
   FORWARD_FUNCTION StrSci
 
   ;===================================================================
   ; Initialization
   ;===================================================================

   ; On/Off keywords
   IsDiscrete = ( N_Elements( C_Colors ) gt 0 )
   Log        = Keyword_Set( Log        )
   Vertical   = Keyword_Set( Vertical   ) 
   Scientific = Keyword_Set( Scientific )
   DoFlagVal  = ( ( not IsDiscrete ) AND ( N_Elements( FlagVal ) gt 0 ) )

;   print, 'positive ===', positive

   ; Keyword Defaults
   if ( N_Elements( Bottom        ) eq 0 ) then Bottom        = !MYCT.BOTTOM
   if ( N_Elements( BotOutOfRange ) eq 0 ) then BotOutOfRange = -1
   if ( N_Elements( BOR_Label     ) eq 0 ) then BOR_Label     = '<'
   if ( N_Elements( CharSize      ) eq 0 ) then CharSize      = !P.CHARSIZE
   if ( N_Elements( Color         ) eq 0 ) then Color         = !MYCT.BLACK
   if ( N_Elements( Divisions     ) eq 0 ) then Divisions     = 2
   if ( N_Elements( NColors       ) eq 0 ) then NColors       = !MYCT.NCOLORS 
   if ( N_Elements( MinV          ) eq 0 ) then MinV          = Bottom
   if ( N_Elements( MaxV          ) eq 0 ) then MaxV          = NColors
   if ( N_Elements( Orientation   ) eq 0 ) then Orientation   = 0
   if ( N_Elements( TickLen       ) eq 0 ) then TickLen       = 0.25 
   if ( N_Elements( Title         ) eq 0 ) then Title         = ''
   if ( N_Elements( TopOutOfRange ) eq 0 ) then TopOutOfRange = -1
   if ( N_Elements( TOR_Label     ) eq 0 ) then TOR_Label     = '>'
   if ( N_Elements( Unit          ) eq 0 ) then Unit          = '' 
   if ( N_Elements( UpperLabel    ) eq 0 ) then UpperLabel    = 0 
   if ( N_Elements( Positive      ) eq 0 ) then Positive      = 1 
   if ( N_Elements( xminor      ) eq 0 ) then  xminor = 0

   ; Make sure MINV is not less than zero for log scale
   if ( Log AND MinV le 0.             ) then MinV        = 0.01
   
   ; Get default format string
   if ( N_Elements( Format      ) eq 0 ) $
      then Format = CBDefaultFormat( MinV, MaxV, Log=Log )

   ; Disable out-of-range boxes for discrete color tables
   ; or for the vertical colorbar
   if ( Vertical OR IsDiscrete ) then begin
      BotOutOfRange = -1
      TopOutOfRange = -1
   endif
 
   ;===================================================================
   ; Intialization continued: : Compute default labels
   ;===================================================================

   ; Compute index of color labels for which labels will be printed
   if ( N_Elements( Skip ) eq 0 ) then begin
      if ( IsDiscrete )                                           $
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

   if ( positive eq 0 ) then $ 
      Annotation = StrTrim( String( Label*(-1.), Format=Format ), 2 )
  
   ; In case want to have double labels for the same color bar
   ; the labels are just a factor difference say, 10
   ; add by Jun Wang
   if (  UpperLabel eq 1) $
      then begin
         Annotation1 = StrTrim( String( Label, Format=Format ), 2 )
         Annotation = StrTrim( String( Label*30, Format=Format ), 2 )
         if ( positive eq 0 ) then begin 
          Annotation = StrTrim( String( Label*(-30.), Format=Format ), 2 )
       print, 'positive : ', positive,  'annotation = ', annotation
         endif 
   endif 
 
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
   ; Make space for extra boxes for out of range
   ;===================================================================
   BarPos       = Position
   x10          = ( Position[2] - Position[0] ) / 10. > 0.03
   TrueCharSize = !D.Y_CH_SIZE * CharSize
   LabelPos     = ( Position[1] * !D.Y_VSIZE - TrueCharSize*1.05 ) / !D.Y_VSIZE

   ;===================================================================
   ; Draw bottom-out-of-range box
   ;===================================================================
   if ( BotOutOfRange ge 0 ) then begin

      ; Get rectangle vectors
      Rpos = [ Position[0], Position[1], Position[0]+x10, Position[3] ]
      RectAngle, Rpos, Px, Py
      
      ; Draw rectangle box and fill w/ color (usually white)
      Polyfill, Px, Py, /norm, Color=BotOutOfRange, /Fill
      Plots,    Px, Py, /norm, Color=Color,         Thick=!P.THICK
 
      ; Print bottom-out-of-range label
      XyOutS, Position[0], LabelPos, BOR_Label,$
         /Norm, Color=Color, Align=0.0, CharSize=CharSize, _EXTRA=e
 
      ; Shorten central bar accordingly
      BarPos = [ BarPos[0]+x10+0.01, BarPos[1], BarPos[2], BarPos[3] ]
   endif
 
   ;====================================================================
   ; Draw top-out-of-range box
   ;====================================================================
   if ( TopOutOfRange ge 0 ) then begin

      ; Get rectangle vectors
      Rpos = [ Position[2], Position[1], Position[2]-x10, Position[3] ]
      RectAngle, Rpos, Px, Py

      ; Draw rectangle box and fill w/ color (usually white)
      PolyFill, Px, Py, /Norm, Color=TopOutOfRange, /Fill
      Plots,    Px, Py, /Norm, Color=Color,         Thick=!P.THICK
 
      ; Print top-out-of-range label
      XyOutS, Position[2]-x10/2., LabelPos, TOR_Label,$
         /Norm, Color=Color, Align=0.5, CharSize=CharSize
 
      ; Shorten central bar accordingly
      BarPos = [ BarPos[0], BarPos[1], BarPos[2]-x10-0.01, BarPos[3] ]
   endif
 
   ; reset bar position in case of error 
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
    if ( Scientific )  then begin                       
       SLabel = StrSci( Label, /Trim, Format=Format, _EXTRA=e )
       print, 'slabel = ', slabel
    endif else begin  
        SLabel = StrTrim( String( Label, Format=Format ), 2 )
    endelse

    ; If ANNOTATION isn't passed, then use SLABEL instead (bmy, 11/25/02)
    if ( N_Elements( Annotation ) eq 0 ) then Annotation = SLabel
    if (  Scientific  ) then Annotation = SLabel

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
       print, 'Log , IsDiscrete', Log, IsDiscrete 
       Plot, [0, 1], [0, 1],                                            $
          /NoData,          XLog=( Log AND not IsDiscrete ),            $
          XStyle=1,         YStyle=5,                                   $
          XRange=XRange,    YRange=YRange,                              $
          Position=BarPos,  /NOERASE,                                   $
          XTicks=XTicks,    XTickLen=TickLen,                           $ 
          Color=Color,      XTickN=Replicate( ' ', Divisions ),         $
          xminor = xminor

       ; Print X-axis labels
       XyOutS, XPos, YPos, Annotation,                                  $ 
          /Data,      Color=Color,             CharSize=CharSize,       $
        Align=0.5,  Orientation=Orientation, _EXTRA=e
       
      ; Jun Wang 
       if ( upperLabel eq 1 ) then begin
       XyOutS, XPos, Barpos[1] - YPos + BarPos[3] - TrueCharSize*0.1 , Annotation1,         $ 
          /Data,      Color=Color,             CharSize=CharSize,       $
        Align=0.5,  Orientation=Orientation, _EXTRA=e
       endif 
        
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
 
 
