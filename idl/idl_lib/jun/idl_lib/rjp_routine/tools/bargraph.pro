; $Id: bargraph.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        BARGRAPH
;
; PURPOSE:
;        Creates a bar graph from a vector of data points
;
; CATEGORY:
;        Plotting program
;
; CALLING SEQUENCE:
;        BARGRAPH, DATA, BASELINE [,keywords]
;
; INPUTS
;        DATA -> Vector of data points to be plotted as a bargraph
; 
;        BASELINE -> Vector of points to be used as a baseline for DATA
;             (i.e. Y(I) = DATA(I) + BASELINE(I)).  If BASELINE
;             is not specified, its default value will be an
;             array of zeroes.
;
; KEYWORD PARAMETERS:
;        OVERPLOT -> /OVERPLOT will not cause the current plot window
;             to be erased.  This is useful for producing
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
;        COLOR -> Color index for the plot axes and labels.  Default
;            is 1 (which is BLACK for a MYCT color table).
;
;        L_FORMAT -> The FORMAT statement used to convert BARLABELS
;            from a numeric array to a string array.
;
;        NO_LABELS -> /NO_LABELS will suppress printing the labels
;            contained in the BARLABELS atop each bar.  This is
;            useful for producing stacked bar plots.
;
;        XLABELS -> X-axis labels corresponding to each bar.
;
;        YRANGE -> YRANGE keyword for the PLOT command.  If YRANGE is
;            not specified then YRANGE will be computed based on the 
;            maximum value of the DATA array.  For stacked plots, it 
;            is useful to compute YRANGE in the calling program and 
;            pass it to BARGRAPH.
;
;        _EXTRA=e -> Passes extra keywords to plot
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
;            more robust than the original version in the IDL 5.0 User's
;            Guide (p. 170).
;
;        (2) IDL 5.x array notation [] is now used.
;
; EXAMPLE:
;        (1) Create a simple bar graph with bars of 3 different colors,
;            using a baseline of zero.
;
;        BARGRAPH, Data=[1,2,3], BarWidth=1.0, BarColor=[10,11,12]
;           XLabels=['Bart', 'Lisa', 'Maggie']
;
;        (2) Use successive calls to BARGRAPH to create a "stacked" bar
;            graph with two different data vectors.  The first vector is
;            used as the baseline for the second.  The BARLABELS array
;            is created from the actual data values.
;
;        Data   = [2,3.5,6,7,2,1]
;        Data2  = 0.0*DATA + 2
;
;        BARGRAPH, Data, Xlabels=['A','B','C','D','E','F'], 
;        XStyle=1, BarWidth=0.8
;
;        BARGRAPH, Data2, Data, BarWidth=0.8 ,/OverPlot, $
;           BarColor=2, BarLabels=Data+Data2, L_Format='(F8.2)'             
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
;
;-
; Copyright (C) 1997, 1999, 2000, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine bargraph"
;-------------------------------------------------------------


pro BarGraph, Data, BaseLine,                               $  
              OverPlot=OverPlot,   Color=Color,             $
              BarWidth=BarWidth,   BarColor=BarColor,       $
              BarLabels=BarLabels, BarCharSize=BarCharSize, $
              L_Format=L_Format,   No_Labels=No_Labels,     $
              XLabels=XLabels,     YRange=YRange,           $
              _EXTRA=e
            
   ;====================================================================
   ; Error checking / Keyword settings
   ;====================================================================
   if ( N_Elements( Data ) eq 0 ) then begin
      Message, 'DATA must be passed to BARGRAPH!', /Continue
      return
   endif

   if ( N_Elements( BaseLine     ) eq 0 ) then BaseLine = 0.0 * Data
   if ( N_Elements( BarColor     ) eq 0 ) then BARCOLOR = 15
   if ( N_Elements( Color        ) eq 0 ) then Color    = 0
   if ( N_Elements( L_Format     ) eq 0 ) then L_Format  ='(f7.1)'
   if ( N_Elements( BarWidth     ) eq 0 ) then BarWidth = 1.0
   if ( N_Elements( BarLabels    ) eq 0 ) then BarLabels = Data
   if ( N_Elements( BarLabelSize ) eq 0 ) then BarLabelSize = 1.0

   if ( N_Elements( XLabels   ) eq 0 ) then $
      XLabels = Replicate( ' ', N_Elements( Data ) )

   if ( N_Elements( YRange    ) eq 0 ) then $
      Yrange = [0, ( Ceil( Max( Data ) / 10 ) * 10 ) ]

   if ( N_Elements( L_FORMAT  ) gt 0 ) then $
      BarLabels = StrTrim( String( BarLabels, Format=L_Format ), 2 )

   OverPlot  = Keyword_Set( OverPlot  )
   No_Labels = Keyword_Set( No_Labels )

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
   ;  If /OVERPLOT is not set, create a plot window.  
   ;  The bars will be overplotted in this window.
   ;====================================================================
   XRange    = [ 0, n_elements( Data )+1 ]
   XTicks    = N_Elements( Data )+1
   XTickName = [' ', Xlabels, ' ']

   YOffset   = 0.5
   YTicks    = ( Max( YRange ) / 10 ) < 30

   if ( not OverPlot ) then                                 $
      Plot, [0, 0], [0, 0], /NoData,                        $ 
         XRange=XRange, XTicks=XTicks, XTickName=XTickName, $ 
         YRange=YRange, YTitle=YTitle, XMinor=1,            $
         /XStyle,       Color=Color,   _EXTRA=e

   ;====================================================================
   ; Draw the colored bars that correspond to each element of 
   ; the DATA array.  Use POLYFILL to fill in the bars.
   ;
   ; The BASELINE array allow bars to be stacked atop each 
   ; other via successive calls to BARGRAPH.
   ;
   ; If /NO_LABELS, then suppress printing of BARLABELS atop each bar.
   ;====================================================================
   Half_BarWidth = BarWidth / 2.0

   for I = 0, N_Elements( Data ) - 1 do begin
      X0 = (I+1) - Half_BarWidth
      X1 = (I+1) + Half_BarWidth
      Y0 = BaseLine[ I ]
      Y1 = Data[ I ] + BaseLine[ I ]
         
      PolyFill, [ X0, X0, X1, X1 ], [ Y0, Y1, Y1, Y0 ], Color=BarColor[ I ]
      
      if ( not No_Labels ) then $
         XYOutS, 0.5*(X0 + X1), Y1+YOffset, BarLabels[I], $
            Align=0.5, Color=Color, CharSize=BarCharSize, _EXTRA=e
   endfor

   return
end
     
 
   
