; $Id: bargraph.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BARGRAPH
;
; PURPOSE:
;        Creates a bar graph from a vector of data points.
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        BARGRAPH, DATA, BASELINE [,keywords]
;
; INPUTS
;        DATA -> Vector of data points to be plotted as a bargraph.
; 
;        BASELINE -> Vector of points to be used as a baseline for 
;             DATA (i.e., Y(I) = DATA(I) + BASELINE(I) ).  If BASELINE 
;             is not specified, its default value will be an array 
;             of zeroes.
;
; KEYWORD PARAMETERS:
;        /OVERPLOT -> Set this switch to prevent the current plot
;             window from being erased.  This is useful for producing 
;             stacked bar plots with successive calls to BARGRAPH.
; 
;        BARWIDTH -> The width of the bars.  If BARWIDTH is not
;            specified, its default value will be 1.0.
;
;        BARCOLOR -> a value or an array containing the colorindex for
;            all boxes or each box, respectively. If a single value
;            is given, *all* boxes will have this color. If an array 
;            is passed that has less elements than there are groups to 
;            plot, the remaining colors will be filled with 15 (grey 
;            in MYCT standard-scheme).  
;
;        BARLABELS -> A string array of labels to be plotted above each
;            bar.  If BARLEVELS may be originally set equal to the
;            DATA vector, and it will be converted to the string 
;            representation of DATA, using the FORMAT statement 
;            contained in L_FORMAT.
;
;        BARCHARSIZE -> Character size for BARLABELS.  Default is 1.0.
;
;        COLOR -> Color index for the plot axes and labels.  
;            Default is !MYCT.BLACK.
;
;        L_FORMAT -> The FORMAT statement used to convert BARLABELS
;            from a numeric array to a string array.
;
;        /NO_LABELS -> Set this switch to suppress printing the labels
;            contained in the BARLABELS atop each bar.  This is useful 
;            for producing stacked bar plots.
;
;        XLABELS -> A string array containing the labels that will be 
;            printed underneath each bar on the X-axis.  
;
;            NOTE: If /HORIZONTAL is set, then these labels will be 
;            printed along the Y-axis instead.
;
;            ALSO NOTE: IDL only allows a maximum limit of 60 ticks 
;            along any axis.  If XLABELS has more than 58 elements
;            (also allowing for null labels at the beginning and end
;            of the plot range), then the labels will not be printed.
;
;        YRANGE -> Use this keyword to specify the range of the data 
;            values.  If YRANGE is not specified, then YRANGE will be 
;            computed based on the maximum value of the DATA array.  
;            For stacked plots, it is useful to compute YRANGE in the 
;            calling program and pass it to BARGRAPH. 
;
;            NOTE: If HORIZONTAL is set, then the YRANGE settings 
;            will apply to the X-axis instead.
;
;        /HORIZONTAL -> Set this switch to plot the bars in the 
;            horizontal instead of in the vertical.  NOTE: In this
;            case, the YRANGE settings will be applied to the X-axis.
;            and the XRANGE and XLABELS settings will be applied to
;            the Y-axis.
;
;        _EXTRA=e -> Passes extra keywords to PLOT and other routines.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;        
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) This routine has been modified to be more general and 
;            more robust than the original version in the IDL 5.0 
;            User's Guide (p. 170).
;
;        (2) IDL 5.x array notation [] is now used.
;
; EXAMPLES:
;        (1)
;
;        BARGRAPH, [1,2,3], BARWIDTH=1.0, BARCOLOR=[10,11,12]
;           XLABELS=['Bart', 'Lisa', 'Maggie']
;
;             ; Create a simple bar graph with bars of 3 different 
;             ; colors, using a baseline of zero.
;
;        (2)
;
;        DATA   = [2,3.5,6,7,2,1]
;        DATA2  = 0.0*DATA + 2
;
;        BARGRAPH, DATA, XLABELS=['A','B','C','D','E','F'],  $
;           XSTYLE=1, BARWIDTH=0.8
;
;        BARGRAPH, DATA2, DATA, BARWIDTH=0.8 ,/OVERPLOT, $
;           BARCOLOR=2, BARLABELS=DATA+DATA2, L_FORMAT='(F8.2)'             
;
;
;             ; Use successive calls to BARGRAPH to create a 
;             ; "stacked" bar graph with two different data vectors.  
;             ; The first vector is used as the baseline for the
;             ; second.  The BARLABELS array is created from the actual 
;             ; data values.
;
;        (3) 
;
;        BARGRAPH, [1,2,3], BARWIDTH=1.0, BARCOLOR=[10,11,12]
;           XLABELS=['Bart', 'Lisa', 'Maggie'], /HORIZONTAL
;
;             ; Same as example (1), but plot bars in the horizontal.
;
; MODIFICATION HISTORY:
;        bmy, 18 Nov 1997: VERSION 1.00
;        bmy, 19 Nov 1997: VERSION 1.01
;        bmy, 29 Apr 1999: VERSION 1.10
;                          - added COLOR keyword
;                          - eliminated help screen 
;                          - enhanced readability & updated comments
;        bmy, 15 Mar 2000: VERSION 1.45
;                          - added BARCHARSIZE keyword
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - added HORIZONTAL keyword to plot
;                            bars in the horizontal 
;                          - Now limits XLABELS array to 58 elements
;                            in order to prevent exceeding an IDL
;                            plotting limit
;
;-
; Copyright (C) 1997-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine bargraph"
;-----------------------------------------------------------------------


pro BarGraph, Data, BaseLine,                                   $  
              OverPlot=OverPlot,     Color=Color,               $
              BarWidth=BarWidth,     BarColor=BarColor,         $
              BarLabels=BarLabels,   BarCharSize=BarCharSize,   $
              L_Format=L_Format,     No_Labels=No_Labels,       $
              XLabels=XLabels,       XRange=XRange,             $
              XTickName=XTickName,   XTicks=XTicks,             $
              YRange=YRange,         YTicks=YTicks,             $        
              Horizontal=Horizontal, No_XTickName=No_XTickName, $
              _EXTRA=e
            
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Error check DATA array
   if ( N_Elements( Data ) eq 0 ) then begin
      Message, 'DATA must be passed to BARGRAPH!', /Continue
      return
   endif

   ; Keywords
   if ( N_Elements( BaseLine     ) eq 0 ) then BaseLine     = 0.0 * Data
   if ( N_Elements( BarColor     ) eq 0 ) then BARCOLOR     = !MYCT.BLACK
   if ( N_Elements( Color        ) eq 0 ) then Color        = !MYCT.BLACK
   if ( N_Elements( L_Format     ) eq 0 ) then L_Format     ='(f7.1)'
   if ( N_Elements( BarWidth     ) eq 0 ) then BarWidth     = 1.0
   if ( N_Elements( BarLabels    ) eq 0 ) then BarLabels    = Data
   if ( N_Elements( BarLabelSize ) eq 0 ) then BarLabelSize = 1.0

   if ( N_Elements( XLabels   ) eq 0 ) then $
      XLabels = Replicate( ' ', N_Elements( Data ) )

   if ( N_Elements( YRange    ) eq 0 ) then $
      Yrange = [ 0.0, ( Ceil( Max( Data ) / 10.0 ) * 10.0 ) ]

   if ( N_Elements( L_FORMAT  ) gt 0 ) then $
      BarLabels = StrTrim( String( BarLabels, Format=L_Format ), 2 )

   Horizontal   = Keyword_Set( Horizontal   )
   No_Labels    = Keyword_Set( No_Labels    )
   No_XTickName = Keyword_Set( No_XTickName )
   OverPlot     = Keyword_Set( OverPlot     )

   ;====================================================================
   ; Compute the BARCOLOR array.  If BARCOLOR consists of a single
   ; value, then give *all* bars this color.  If BARCOLOR has less
   ; elements than DATA, then the remaining colors will be filled 
   ; with 15 (grey in MYCT standard-scheme).     
   ;====================================================================
   NMC = N_Elements( Data ) - N_Elements( BarColor )

   if ( NMC gt 0 ) then begin
      if ( N_Elements( BarColor ) eq 1 ) then begin
         BarColor = [ replicate( BarColor[0], N_Elements( Data ) ) ]  
      endif else begin
         BarColor = [ BarColor, Replicate( 15, NMC ) ]
      endelse
   endif

   ;====================================================================
   ; Initialize quantities for the plot
   ;====================================================================

   ; For horizontal axis
   if ( N_Elements( XRange    ) eq 0 ) then XRange = [ 0,N_elements( Data )+1 ]
   if ( N_Elements( XTicks    ) eq 0 ) then XTicks = N_Elements( Data )+1
   if ( N_Elements( XTickName ) eq 0 ) then XTickName = [' ', Xlabels, ' ']
   
   ; For vertical axis
   YOffset       = 0.5
   if ( N_Elements( YTicks ) eq 0 ) then YTicks = ( Max( YRange ) / 10 ) < 60

   ; 1/2 of the bar width
   Half_BarWidth = BarWidth / 2.0

   ;====================================================================
   ; If /OVERPLOT is not set, create a plot window.  
   ;====================================================================

   ; Horizontal or vertical plot?
   if ( Horizontal ) then begin

      ;-----------------------------------------------------------------
      ; WE ARE PLOTTING THE BARS HORIZONTALLY!
      ;-----------------------------------------------------------------

      ; Create the plot window
      if ( not OverPlot ) then begin                             

         ; Limit plot to less than 60 (58+2) ticks & labels (bmy, 2/14/07)
         if ( No_XTickName ) then begin
            Plot, [0, 0], [0, 0], /NoData,                        $
               YRange=XRange, YTicks=XTicks,                      $
               XRange=YRange, XTitle=YTitle, YMinor=1,            $
               /YStyle,       Color=Color,   _EXTRA=e
         endif else if ( XTicks gt 58 ) then begin
            Plot, [0, 0], [0, 0], /NoData,                        $
               YRange=XRange,                                     $
               XRange=YRange, XTitle=YTitle, YMinor=1,            $
               /YStyle,       Color=Color,   _EXTRA=e
         endif else begin
            Plot, [0, 0], [0, 0], /NoData,                        $
               YRange=XRange, YTicks=XTicks, YTickName=XTickName, $ 
               XRange=YRange, XTitle=YTitle, YMinor=1,            $
               /YStyle,       Color=Color,   _EXTRA=e
         endelse
      endif
      
      ; Loop over the # of bars
      for I = 0L, N_Elements( Data )-1L do begin

         ; Compute the extent of the bars.  The BASELINE array allows 
         ; bars to be stacked atop each other via successive calls.
         Y0 = (I+1) - Half_BarWidth
         Y1 = (I+1) + Half_BarWidth
         X0 = BaseLine[I]
         X1 = Data[I] + BaseLine[I]

         ; Draw the bars
         PolyFill, [X0,X0,X1,X1], [Y0,Y1,Y1,Y0], Color=BarColor[I]
         
         ; Print labels (if necessary)
         if ( not No_Labels ) then begin
            XYOutS, 0.5*(Y0 + Y1)+YOffset, X1, BarLabels[I], $
               Align=0.5, Color=Color, CharSize=BarCharSize, _EXTRA=e
         endif
      endfor

   endif else begin

      ;-----------------------------------------------------------------
      ; WE ARE PLOTTING THE BARS VERTICALLY! (This is the default)
      ;-----------------------------------------------------------------
 
      ; Create the plot window (if necessary)
      if ( not OverPlot ) then begin                               

         ; Limit plot to less than 60 (58+2) ticks & labels (bmy, 2/14/07)
         if ( No_XTickName ) then begin
            Plot, [0, 0], [0, 0], /NoData,                        $
               XRange=XRange, XTicks=XTicks,                      $ 
               YRange=YRange, YTitle=YTitle, XMinor=1,            $
               /XStyle,       Color=Color,   _EXTRA=e
         endif else if ( XTicks gt 58 ) then begin
            Plot, [0, 0], [0, 0], /NoData,                        $
               XRange=XRange,                                     $
               YRange=YRange, YTitle=YTitle, XMinor=1,            $
               /XStyle,       Color=Color,   _EXTRA=e
         endif else begin
            Plot, [0, 0], [0, 0], /NoData,                        $
               XRange=XRange, XTicks=XTicks, XTickName=XTickName, $ 
               YRange=YRange, YTitle=YTitle, XMinor=1,            $
               /XStyle,       Color=Color,   _EXTRA=e
         endelse
      endif

      ; 1/2 of the bar width
      Half_BarWidth = BarWidth / 2.0

      ; Loop over the # of bars
      for I = 0L, N_Elements( Data )-1L do begin

         ; Compute the extent of the bars.  The BASELINE array allows 
         ; bars to be stacked atop each other via successive calls.
         X0 = (I+1) - Half_BarWidth
         X1 = (I+1) + Half_BarWidth
         Y0 = BaseLine[I]
         Y1 = Data[I] + BaseLine[I]
         
         ; Draw the bars
         PolyFill, [X0,X0,X1,X1], [Y0,Y1,Y1,Y0], Color=BarColor[I]
         
         ; Print labels (if necessary)
         if ( not No_Labels ) then begin
            XYOutS, 0.5*(X0 + X1), Y1+YOffset, BarLabels[I], $
               Align=0.5, Color=Color, CharSize=BarCharSize, _EXTRA=e
         endif
      endfor

   endelse

   return
end
     
 
   
