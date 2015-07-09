; $Id: plot_cpd.pro,v 1.1.1.1 2007/07/17 20:41:50 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PLOT_CPD
;
; PURPOSE:
;        Plots a cumulative probability distribution from a data array.
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        PLOT_CPD, DATA, [ , Keywords ]
;
; INPUTS:
;        DATA -> The array holding the data points to plot as a 
;             cumulative probability distribution.
;
; KEYWORD PARAMETERS:
;        COLOR -> Sets the color of the plot window and data.
;             Default is !MYCT.BLACK.
; 
;        CHARSIZE -> Sets the size of the text in the plot window.
;             Default is 1.8.
;
;        /OVERPLOT -> Set this switch to overplot data atop an 
;             existing plot window.  Default is to create a new plot.
;
;        SYMBOL -> Input argument for SYM, which will define the type
;             of plot symbol.  Default is 6 (open circle).
;
;        XMARGIN, YMARGIN -> Specifies the "cushion" of space around
;             the plot window.  Defaults are XMARGIN=[10,1], and
;             YMARGIN=[4,2].
;
;        XMINOR, YMINOR -> Specifies the number of minor ticks (i.e.
;             small ticks between the major ticks) along the X and Y
;             axes.  Defaults are is XMINOR=4 and YMINOR=4.
;
;        XRANGE, YRANGE -> Defines the plot range along the X and Y
;             axes.  Defaults are XRANGE=[-4,4] and YRANGE=[0,100].
;
;        XTICKNAME, YTICKNAME -> Specifies the tick labels on the 
;             X and Y axes.
;
;        XTICKS, YTICKS -> Specifies the number of major ticks (i.e.
;             along the X and Y axes.  Defaults are is XTICKS=8 and 
;             YTICKS=4.
;
;        XTITLE, YTITLE -> Specifies the X and Y axis title strings.
;           
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===================================
;        QQNORM (function)   SYM (function)
;
; REQUIREMENTS:
;        Requires routines from both TOOLS and GAMAP packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        PLOT_CPD, FINDGEN(200), COLOR=!MYCT.BLACK
;        PLOT_CPD, FINDGEN(100), COLOR=!MYCT.RED, /OVERPLOT
;
;             ; Plot 2 data arrays as cumulative probability
;             ; distributions.  The 2nd array (red) is overplotted 
;             ; onto the existing plot window.
;
; MODIFICATION HISTORY:
;  swu & bmy, 10 Oct 2006: TOOLS VERSION 2.05
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2006-2007, Shiliang Wu,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine plot_cpd"
;-----------------------------------------------------------------------


pro Plot_CPD, Data, $
              Color=Color,    CharSize=CharSize,    OverPlot=OverPlot, $
              Symbol=Symbol,  XTickName=XTickName,  XMargin=XMargin,   $
              XMinor=XMinor,  XRange=XRange,        XTicks=XTicks,     $
              XTitle=XTitle,  YTickName=YTickName,  YMargin=YMargin,   $
              YMinor=YMinor,  YRange=YRange,        YTicks=YTicks,     $
              YTitle=YTitle,  _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION QQNorm, Sym

   ; Arguments
   if ( N_Elements( Data      ) eq 0 ) then Message, 'DATA not passed!'

   ; Find min & max of data
   MinD = Min( Data, Max=MaxD )

   ; Keywords
   if ( N_Elements( Color     ) eq 0 ) then Color    = !MYCT.BLACK
   if ( N_Elements( CharSize  ) eq 0 ) then CharSize = 1.8
   if ( N_Elements( Symbol    ) eq 0 ) then Symbol   = 6
   if ( N_Elements( XMargin   ) eq 0 ) then XMargin  = [    7,    1 ]
   if ( N_Elements( YMargin   ) eq 0 ) then YMargin  = [    4,    2 ]
   if ( N_Elements( XRange    ) eq 0 ) then XRange   = [   -4,    4 ]
   if ( N_Elements( YRange    ) eq 0 ) then YRange   = [ MinD, MaxD ]
   if ( N_Elements( XMinor    ) eq 0 ) then XMinor   = 4
   if ( N_Elements( YMinor    ) eq 0 ) then YMinor   = 4
   if ( N_Elements( XStyle    ) eq 0 ) then XStyle   = 1
   if ( N_Elements( YStyle    ) eq 0 ) then YStyle   = 1
   if ( N_Elements( XTicks    ) eq 0 ) then XTicks   = 8
   if ( N_Elements( YTicks    ) eq 0 ) then YTicks   = 4
 
   if ( N_Elements( XTickName ) eq 0 ) then $
      XTickName = [' ', '0.15','2.5', '16', '50', '84', '97.5', '99.85', ' '] 
 
   if ( N_Elements( XTitle    ) eq 0 ) then $
      XTitle = 'Cumulative Probability (%)'

   ; Switches
   OverPlot = Keyword_Set( OverPlot ) 
 
   ;====================================================================
   ; Plot the data!
   ;====================================================================
 
   ; Call QQNORM to get the expected deviation of the mean
   Pos = QQNorm( Data )
 
   if ( OverPlot ) then begin
 
      ; Overplot the data on top of an existing plot window
      OPlot, Pos, Data, $
         PSym=Sym( Symbol ), Color=Color, _EXTRA=e
 
   endif else begin
      
      ; Plot data into a new window
      Plot, Pos, Data,                               $
         Color=Color,          CharSize=CharSize,    $
         XMargin=XMargin,      YMargin=YMargin,      $
         XMinor=XMinor,        YMinor=YMinor,        $
         XRange=XRange,        YRange=YRange,        $    
         XStyle=XStyle,        YStyle=YStyle,        $
         XTicks=XTicks,        YTicks=YTicks,        $
         XTickName=XTickName,  YTickName=YTickName,  $
         XTitle=XTitle,        YTitle=YTitle,        $           
         PSym=Sym( Symbol ),   _EXTRA=e
    
   endelse
end
 
 
 
