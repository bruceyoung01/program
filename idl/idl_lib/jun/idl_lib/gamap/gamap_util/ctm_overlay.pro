; $Id: ctm_overlay.pro,v 1.2 2007/11/06 20:05:05 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_OVERLAY
;
; PURPOSE:
;        Calls TVMAP to plot a pixel or contour map and then overplots 
;        either an aircraft flight track or individual station data 
;        atop it.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Plotting
;
; CALLING SEQUENCE:
;        CTM_OVERLAY, DATA,   XMID,   YMID, $
;                     TRACKD, TRACKX, TRACKY [, Keywords ]
;
; INPUTS:
;        DATA -> Data array (e.g. from CTM_GET_DATA or CTM_GET_DATABLOCK)
;             from which a pixel plot or contour plot will be generated.
;
;        XMID -> Vector of longitudes corresponding to DATA.
;
;        YMID -> Vector of latitudes corresponding to DATA
;
;        TRACKD -> Vector of data values corresponding to the aircraft
;             flight track or station data points.
;
;        TRACKX -> Vector of longitudes corresponding to the aircraft 
;             flight track or station data points.  Should be in the 
;             range [-180,180].
;
;        TRACKY -> Vector of longitudes corresponding to the aircraft
;             flight track or station data points.  Should be in the 
;             range [-90,90].
;
; KEYWORD PARAMETERS:
;        C_COLORS -> Vector to specify the color levels for filled
;             contour plots.  If not passed, then C_COLORS will return
;             to the calling program the default color level values
;             generated internally by TVMAP.
; 
;        C_LEVELS -> Vector containing contour levels for filled
;             contour plots.  Used in conjunction with /FCONTOUR. 
;
;        COLOR -> Color of the map outline.  Passed to TVMAP.
;
;        /FCONTOUR -> Set this switch to generate a filled-contour
;             plot instead of a pixel plot.
;
;        /LOG -> Set this switch to use a logarithmic color table.
;
;        MINDATA -> Minimum value of DATA.  If omitted, then MINDATA
;             will be automatically set to the minimum value of DATA.
;
;        MAXDATA -> Minimum value of DATA.  If omitted, then MINDATA
;             will be automatically set to the minimum value of DATA.
;
;        /OVERPLOT -> Set this keyword to overplot a flight track
;             atop a map previously drawn by TVMAP.
;
;        T_COLOR -> If plotting aircraft flight track data, then
;             T_COLOR will be used to define the color of the line.
;
;        T_LINESTYLE -> IDL linestyle for the aircraft flight track.
;             Takes same values as the LINESTYLE graphic keyword
;             (see help pages).
;
;        T_SYMBOL -> Argument to the SYM keyword, which will be used
;             to define the individual data points if you are plotting
;             station data.  Recommended value: 1 (filled circle).
;
;        T_THICK -> Thickness of the aircraft flight track, in pixels.
; 
;        _EXTRA=e -> Passes extra keywords to TVMAP and OPLOT.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        ==========================================
;        SCALETRACK (function)
;
;        External Subroutines Required:
;        =========================================
;        MULTIPANEL      MYCT_DEFAULTS (function) 
;        TVMAP           RECTANGLE
;        SYM (function)
;
; REQUIREMENTS:
;        None
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
;        TrackD = FltArr( 100 )                  
;               
;        ; Plot a pixel map w/ countries, continents, grid lines,
;        ; and overlay a red, dashed-line flight track atop it.
;        CTM_OverLay, Data, XXMid, YYMid, TrackD, TrackX, TrackY, $
;           /Sample,    /Countries,    /Coasts,    /CBar,         $      
;           Div=4,      Min_Val=1e-20, /Isotropic, /Grid,         $ 
;           Title='Pixel map overlaid /w contour map',            $    
;           T_Color=!MYCT.RED, T_Thick=2, T_LineStyle=2
;         
;        ; Make a second "fake" aircraft track
;        ; (of course, if you have a real flight track, use it...)
;        TrackX = Replicate( 72, 100 )
;        TrackY = Findgen( 100 ) - 50
;        TrackD = Fltarr( 100 )
;         
;        ; Call CTM_OVERLAY again with /OVERPLOT to 
;        ; overplot the second flight track
;        CTM_OverLay, Data, XXMid, YYMid, TrackD, TrackX, TrackY, $
;           T_Color=!MYCT.BLUE, T_Thick=2, T_LineStyle=2, /OVERPLOT
;
;
;       (2) Draw Boxes for Tagged Tracer regions
;       ----------------------------------------
;
;       ; Define (X,Y) coordinates of first tagged tracer region
;       TrackX = [ 0, 60, 60,  0, 0 ]
;       TrackY = [ 0,  0, 30, 30, 0 ]
;       TrackD = [ 0,  0,  0,  0, 0 ]
;    
;       ; Call CTM_OVERLAY with all TVMAP keywords to
;       ; plot the map and to initialize the map dataspace
;       CTM_OverLay, Data, XXMid, YYMid, TrackD, TrackX, TrackY, $
;          /Sample,    /Countries,    /Coasts,    /CBar,         $      
;          Div=4,      Min_Val=1e-20, /Isotropic, /Grid,         $       
;          Title='Test pixel map w/ overlay boxes',              $
;          T_Thick=3,  T_Color=C.BLACK,  T_LineStyle=0
;    
;       ; Define second tagged tracer region
;       TrackX = [ 0, 120, 120,   0, 0 ]
;       TrackY = [ 0,   0, -30, -30, 0 ]
;          
;       ; Call CTM_OVERLAY with /OVERPLOT to overplot
;       ; atop the previously defined map
;       CTM_OverLay, Data, XXMid, YYMid, TrackX, TrackY, $
;          /OVERPLOT, T_Thick=3, T_Color=C.RED, T_LineStyle=0
;
;
;       (3) Plot individual station data points
;       ----------------------------------------
;
;       ; Define "fake" station data for demo
;       ; (along the equator between 60W and 60E)
;       Ind    = Where( XMid ge -60 AND XMid le 60, N )
;       TrackD = Findgen(N) + 20
;       TrackY = Fltarr(N)  + 0
;       TrackX = Xmid[Ind]
;
;       ; Call CTM_OVERLAY with all TVMAP keywords to
;       ; plot the map and to initialize the map dataspace
;       CTM_OverLay, Data, XXMid, YYMid, TrackD, TrackX, TrackY, $
;          /Sample,    /Countries,    /Coasts,    /CBar,         $      
;          Div=4,      Min_Val=1e-20, /Isotropic, /Grid,         $      
;          T_Symbol=1, SymSize=2,                                $
;          Title='Test pixel map w/ station data',           
;         
;
; MODIFICATION HISTORY:
;        bmy, 05 Oct 2006: GAMAP VERSION 2.05
;                          - Modified from CTM_OVERLAY_FLIGHT and
;                            renamed to CTM_OVERLAY
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;  dbm & bmy, 06 Nov 2007: - Modified to allow filled contour plots
;
;-
; Copyright (C) 2006-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_overlay"
;-----------------------------------------------------------------------


function ScaleTrack, TrackD,          Log=Log,           MinData=MinData,  $
                     MaxData=MaxData, FContour=FContour, C_Levels=C_Levels, $
                     C_Colors=C_Colors

   ;====================================================================
   ; Internal function ScaleTrack byte scales the station data points
   ; so that they are on the same color scale as the TVMAP image.
   ; This code was taken from TVMAP. (bmy, 10/4/06)
   ;
   ; NOTE: Modified for filled contour plots (dbm, 11/6/07)
   ;====================================================================

   if ( Keyword_Set( FContour )        AND $
        N_Elements( C_Levels  ) gt 0   AND $
        N_Elements( C_Colors  ) gt 0 ) then begin

      ;--------------------------
      ; For filled contour plots
      ;--------------------------

      ; C_COLORS is the array of colors for each level as returned by TVMAP
      ; Get the # of elements of C_COLORS
      Nc = N_Elements( C_Colors )

      ; For each element of TRACKD, find the nearest index in C_LEVELS
      Ind   = Value_Locate( C_Levels, TrackD )
      
      ; IMAGE is the array of color indices for each station data point
      Image = BytArr( N_Elements( TrackD ) )
      
      ; Loop over all station data points
      for N = 0L, N_Elements( TrackD )-1L do begin

         ; For now, saturate station data points that are either lower
         ; than the lowest contour or higher than the highest contour.
         if ( Ind[N] lt 0     ) then Ind[N] = 0L
         if ( Ind[N] gt Nc-1L ) then Ind[N] = Nc-1L

         ; Save into IMAGE the corresponding color value from C_COLORS
         Image[N] = C_Colors[ Ind[N] ] 
      endfor

   endif else if ( Keyword_Set( Log ) ) then begin
      
      ;--------------------------
      ; For log color scales
      ;--------------------------

      ; Don't take the log10 of points that are zero
      Ind = Where( TrackD gt 0. )
      if ( Ind[0] ge 0 ) then begin
         TrackD[ Ind ] = ALog10( TrackD[ Ind ] )
      endif

      if ( MinData gt 0 )                    $
         then LogMinData = ALog10( MinData ) $
         else LogMinData = 1e-30

      if ( MaxData gt 0 )                    $
         then LogMaxData = ALog10( MaxData ) $
         else LogMaxData = 1e-30

      ; Byte scale to log color scale
      Image = BytScl( TrackD, Min=LogMinData, Max=LogMaxData, $
                      Top=!MYCT.NCOLORS-1, _EXTRA=e ) + !MYCT.BOTTOM

   endif else begin             
         
      ;--------------------------
      ; For linear color scales
      ;--------------------------

      ; Byte scale to linear color scale
      Image = BytScl( TrackD, Min=MinData, Max=MaxData, $
                      Top=!MYCT.NCOLORS-1, _EXTRA=e ) + !MYCT.BOTTOM
   endelse

   ; Return to main program
   return, Image
end


;------------------------------------------------------------------------------

pro CTM_OverLay, Data, XMid, YMid, TrackD, TrackX, TrackY,    $
                 Color=Color,        Log=Log,                 $
                 MinData=MinData,    MaxData=MaxData,         $
                 T_Color=T_Color,    T_Thick=T_Thick,         $
                 T_Symbol=T_Symbol,  T_LineStyle=T_LineStyle, $
                 OverPlot=OverPlot,  FContour=Fcontour,       $
                 C_Levels=C_Levels,  C_Colors=C_Colors,       $
                 _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Common block
   common SaveWindowPosition, WP

   ; Arguments and keywords
   Log      = Keyword_Set( Log      )
   OverPlot = Keyword_Set( OverPlot )
   FContour = Keyword_Set( FContour )
   if ( N_Elements( Data        ) eq 0 ) then Message, 'DATA not passed!'
   if ( N_Elements( XMid        ) eq 0 ) then Message, 'XMID not passed!'
   if ( N_Elements( YMid        ) eq 0 ) then Message, 'YMID not passed!'
   if ( N_Elements( Color       ) ne 1 ) then Color       = !MYCT.BLACK
   if ( N_Elements( MinData     ) eq 0 ) then MinData     = Min( Data )
   if ( N_Elements( MaxData     ) eq 0 ) then MaxData     = Max( Data )
   if ( N_Elements( T_Color     ) ne 1 ) then T_Color     = !MYCT.BLACK
   if ( N_Elements( T_Thick     ) ne 1 ) then T_Thick     = 2
   if ( N_Elements( T_LineStyle ) ne 1 ) then T_LineStyle = 0
 
   ; Get size of TRACKD, TRACKX, TRACKY
   Nd = N_Elements( TrackD )
   Nx = N_Elements( TrackX )
   Ny = N_Elements( TrackY )

   ; Make sure TRACKD, TRACKX, TRACKY are passed
   if ( Nd eq 0  ) then Message, 'TRACKD has zero elements!'
   if ( Nx eq 0  ) then Message, 'TRACKX has zero elements!'
   if ( Ny eq 0  ) then Message, 'TRACKY has zero elements!'

   ; Make sure TRACKD, TRACKX, TRACKY have the same # of elements
   if ( Nd ne Nx ) then Message, 'TRACKD, TRACKX have different # of elements!'
   if ( Nd ne Ny ) then Message, 'TRACKD, TRACKY have different # of elements!'
   if ( Nx ne Ny ) then Message, 'TRACKX, TRACKY have different # of elements!'

   ;====================================================================
   ; Create the plot!
   ;====================================================================

   ; Call TVMAP to plot the pixel or contour map, but don't advance to the
   ; next frame.  NOTE: C_COLORS is the vector of color levels for the
   ; filled contour plot.  If not passed, then C_COLORS will return the 
   ; default values generated by internally by TVMAP.  This will be needed 
   ; for overlaying station data points on a filled contour map.
   if ( OverPlot ne 1L ) then begin
      TvMap, Data, Xmid, Ymid,                                    $
         /NoAdvance,        WindowPos=Wp,      MinData=MinData,   $
         MaxData=MaxData,   FContour=FContour, C_Levels=C_Levels, $
         C_Colors=C_Colors, _EXTRA=e 
   endif

   ; Make XRANGE and YRANGE for the PLOT command
   Dx     = ( XMid[1] - XMid[0] ) / 2.0
   Dy     = ( Ymid[2] - Ymid[1] ) / 2.0
   XRange = [ Min( XMid, Max=M ) - Dx, M + Dx ] 
   YRange = [ Min( YMid, Max=M ) - Dy, M + Dy ]
   
   ; Put bounds on YRANGE
   if ( YRange[0] lt -90 ) then Yrange[0] = -90
   if ( YRange[1] gt  90 ) then Yrange[1] =  90

   ; Set up plot window (data coordinates) but
   ; don't plot any data, and don't erase the screen
   Plot, [0, 1], [0, 1],                                   $           
      /NoData,        /NoErase, /Data,     Color=Color,    $
      Position=wp,    /XStyle,  /Ystyle,   XMargin=[0, 0], $
      Ymargin=[0, 0], Xticks=1, YTicks=1,                  $
      XTickName=[ ' ', ' ' ],   YTickName=[ ' ', ' ' ],    $
      Xrange=XRange,            YRange=YRange

   ; Plot the airplane track or station data
   if ( N_Elements( T_Symbol ) gt 0 ) then begin

      ;-----------------------------------
      ; Station data points
      ;-----------------------------------

      ; Put station data on same color scale as map data
      PointColor = ScaleTrack( TrackD,            Log=Log,           $
                               MinData=MinData,   MaxData=MaxData,   $
                               FContour=FContour, C_Levels=C_Levels, $
                               C_Colors=C_Colors )
   
      ; Plot individual station data points
      for N = 0L, N_Elements( TrackD )-1L do begin

         ; Plot filled symbol (circle recommended!) w/ color
         PlotS, TrackX[N], TrackY[N], $
            Color=PointColor[N], PSym=Sym(T_Symbol), _EXTRA=e

         ; Plot open symbol (circle recommended!) as border
         PlotS, TrackX[N], TrackY[N], $
            Color=T_Color, PSym=Sym(T_Symbol+5), Thick=1, _EXTRA=e

      endfor

   endif else begin

      ;-----------------------------------
      ; Aircraft flight track or lines
      ;-----------------------------------

      ; Plot line data
      OPlot, TrackX, TrackY, Color=T_Color, $
         Thick=T_Thick, LineStyle=T_LineStyle

   endelse

   ; Plot the thick boundary again -- in case PLOT resets it
   Rectangle, Wp, XPoints, YPoints
   PlotS, XPoints, YPoints, Thick=2, Color=Color, /Normal
   
   ; We must advance manually -- go to the next frame
   MultiPanel, Advance=( 1L - OverPlot ), /NoErase
     
   ; Quit
   return
end
 
