; $Id: ctm_overlay_flight.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_OVERLAY_FLIGHT
;
; PURPOSE:
;        Overplots a flight track (or Tagged Tracer box regions)
;        atop a lat-lon pixel map or contour map.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_OVERLAY_FLIGHT, DATA, XMID, YMID, TRACKX, TRACKY [,Keywords]
;
; INPUTS:
;        DATA -> Data array (e.g. from CTM_GET_DATA or CTM_GET_DATABLOCK)
;             from which a pixel plot or contour plot will be generated.
;
;        XMID -> Vector of longitudes corresponding to DATA.
;
;        YMID -> Vector of latitudes corresponding to DATA
;
;        TRACKX -> Vector of longitudes corresponding to the
;             aircraft flight track.  Should be in the range [-180,180].
;
;        TRACKY -> Vector of longitudes corresponding to the
;             aircraft flight track.  Should be in the range [-90,90].
;
; KEYWORD PARAMETERS:
;        /OVERPLOT -> Set this keyword to overplot a flight track
;             atop a map previously drawn by TVMAP.
;
;        COLOR -> Color of the map outline.  Passed to TVMAP.
;
;        T_COLOR -> Color of the aircraft flight track.
;
;        T_THICK -> Thickness of the aircraft flight track, in pixels.
; 
;        T_LINESTYLE -> IDL linestyle for the aircraft flight track.
;             Takes same values as the LINESTYLE graphic keyword
;             (see help pages).
;
;        _EXTRA=e -> Passes extra keywords to TVMAP.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required
;        =====================================
;        MULTIPANEL   MYCT_DEFAULTS (function) 
;        TVMAP        RECTANGLE
;
; REQUIREMENTS:
;        Uses routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        You can pass all of the same keywords to CTM_OVERLAY_FLIGHT
;        as you do to TVMAP.    
;
; EXAMPLE:
;        (1) Plot flight tracks atop a pixel or contour map
;        --------------------------------------------------
;
;        ; Read the data -- in this case, CO concentrations
;        SUCCESS = CTM_Get_DataBlock( Data, 'IJ-AVG-$',     $
;                                     File='ctm.bpch.1995', $
;                                     Tra=4,                $
;                                     /First,               $
;                                     Lon=[-180, 180],      $
;                                     Lat=[-88,   88],      $
;                                     Lev=1,                $
;                                     XMid=XXmid, Ymid=YYMid )
;         
;
;        ; Make a "fake" aircraft track
;        ; (of course, if you have a real flight track, use it...)
;        TrackX = Replicate( -72, 100 )
;        TrackY = Findgen( 100 ) - 50
;                  ;               
;        ; Plot a pixel map w/ countries, continents, grid lines,
;        ; and overlay a red, dashed-line flight track atop it.
;        CTM_OverLay_Flight, Data, XXMid, YYMid, TrackX, TrackY, $
;           /Sample,    /Countries,    /Coasts,    /CBar,              $      
;           Div=4,      Min_Val=1e-20, /Isotropic, /Grid,              $ 
;           Title='Pixel map overlaid /w contour map',                 $    
;           T_Color=!MYCT.RED, T_Thick=2, T_LineStyle=2
;         
;        ; Make a second "fake" aircraft track
;        ; (of course, if you have a real flight track, use it...)
;        TrackX = Replicate( 72, 100 )
;        TrackY = Findgen( 100 ) - 50
;         
;        ; Call CTM_OVERLAY_FLIGHT again with /OVERPLOT to 
;        ; overplot the second flight track
;        CTM_OverLay_Flight, Data, XXMid, YYMid, TrackX, TrackY, $
;           T_Color=!MYCT.BLUE, T_Thick=2, T_LineStyle=2, /OVERPLOT
;
;
;       (2) Draw Boxes for Tagged Tracer regions
;       ----------------------------------------
;
;       ; Define (X,Y) coordinates of first tagged tracer region
;       TrackX = [ 0, 60, 60, 0,  0 ]
;       TrackY = [ 0,  0, 30, 30, 0 ]
;    
;       ; Call CTM_OVERLAY_FLIGHT with all TVMAP keywords to
;       ; plot the map and to initialize the map dataspace
;       CTM_OverLay_Flight, Data, XXMid, YYMid, TrackX, TrackY, $
;          /Sample,    /Countries,    /Coasts,    /CBar, $      
;          Div=4,      Min_Val=1e-20, /Isotropic, /Grid, $      
;          Title='Test pixel map w/ overlay boxes',     $
;          T_Thick=3,  T_Color=C.BLACK,  T_LineStyle=0
;    
;       ; Define second tagged tracer region
;       TrackX = [ 0, 120, 120,   0, 0 ]
;       TrackY = [ 0,   0, -30, -30, 0 ]
;          
;       ; Call CTM_OVERLAY_FLIGHT with /OVERPLOT to overplot
;       ; atop the previously defined map
;       CTM_OverLay_Flight, Data, XXMid, YYMid, TrackX, TrackY, $
;          /OVERPLOT, T_Thick=3, T_Color=C.RED, T_LineStyle=0
;
; MODIFICATION HISTORY:
;        bmy, 13 Sep 2002: GAMAP VERSION 1.51
;
;-
; Copyright (C) 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_overlay_flight"
;-----------------------------------------------------------------------


pro CTM_OverLay_Flight, Data, XMid, YMid, TrackX, TrackY,   $
                        Color=Color,        T_Color=T_Color,         $
                        T_Thick=T_Thick,    T_LineStyle=T_LineStyle, $
                        OverPlot=OverPlot,  _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Common block
   common SaveWindowPosition, WP

   ; Keywords
   OverPlot = Keyword_Set( OverPlot )
   if ( N_Elements( Data        ) eq 0 ) then Message, 'DATA not passed!'
   if ( N_Elements( XMid        ) eq 0 ) then Message, 'XMID not passed!'
   if ( N_Elements( YMid        ) eq 0 ) then Message, 'YMID not passed!'
   if ( N_Elements( TrackX      ) eq 0 ) then Message, 'TRACKX not passed!'
   if ( N_Elements( TrackY      ) eq 0 ) then Message, 'TRACKY not passed!'
   if ( N_Elements( Color       ) ne 1 ) then Color       = !MYCT.BLACK
   if ( N_Elements( T_Color     ) ne 1 ) then T_Color     = !MYCT.BLACK
   if ( N_Elements( T_Thick     ) ne 1 ) then T_Thick     = 2
   if ( N_Elements( T_LineStyle ) ne 1 ) then T_LineStyle = 0
 
   ;====================================================================
   ; Create the plot!
   ;====================================================================

   ; Call TVMAP to plot the pixel map -- don't advance to next frame
   if ( OverPlot ne 1L ) $
      then TvMap, Data, Xmid, Ymid, /NoAdvance, WindowPos=Wp, _EXTRA=e

   ; Set up plot window (data coordinates) but
   ; don't plot any data, and don't erase the screen
   Plot, [0, 1], [0, 1],                                   $           
      /NoData,        /NoErase, /Data,     Color=Color,    $
      Position=wp,    /XStyle,  /Ystyle,   XMargin=[0, 0], $
      Ymargin=[0, 0], Xticks=1, YTicks=1,                  $
      XTickName=[ ' ', ' ' ],   YTickName=[ ' ', ' ' ],    $
      Xrange=[ Min(XMid, Max=M), M ],                      $
      YRange=[ Min(YMid, Max=M), M ]

   ; Plot the airplane track!
   OPlot, TrackX, TrackY, $
      Color=T_Color, Thick=T_Thick, LineStyle=T_LineStyle
 
   ; Plot the thick boundary again -- in case PLOT resets it
   Rectangle, Wp, XPoints, YPoints
   PlotS, XPoints, YPoints, Thick=2, Color=Color, /Normal
   
   ; We must advance manually -- go to the next frame
   MultiPanel, Advance=( 1L - OverPlot ), /NoErase
     
   ; Quit
   return
end
 
