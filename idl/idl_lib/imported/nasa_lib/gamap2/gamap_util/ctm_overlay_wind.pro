; $Id: ctm_overlay_wind.pro,v 1.2 2008/03/24 14:51:17 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_OVERLAY_WIND
;
; PURPOSE:
;        Calls TVMAP to plot a pixel or contour map and then overplots 
;        wind data atop it.
;        %%%% NOTE: Still in BETA testing! %%%%
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Plotting
;
; CALLING SEQUENCE:
;        CTM_OVERLAY, DATA, XMID, YMID, U, V, [, Keywords ]
;
; INPUTS:
;        DATA -> Data array (e.g. from CTM_GET_DATA or CTM_GET_DATABLOCK)
;             from which a pixel plot or contour plot will be generated.
;
;        XMID -> Vector of longitudes corresponding to DATA.
;
;        YMID -> Vector of latitudes corresponding to DATA
;
;        U -> Array of U-wind values
;
;        V -> Array of V-wind values
;
; KEYWORD PARAMETERS:
;        COLOR -> Color of the map outline.  Passed to TVMAP.
;
;        /LOG -> Set this switch to use a logarithmic color table.
;
;        MINDATA -> Minimum value of DATA.  If omitted, then MINDATA
;             will be automatically set to the minimum value of DATA.
;
;        MAXDATA -> Minimum value of DATA.  If omitted, then MINDATA
;             will be automatically set to the minimum value of DATA.
;
;        /OVERPLOT -> Set this keyword to overplot the wind
;             atop a map previously drawn by TVMAP.
; 
;        _EXTRA=e -> Passes extra keywords to TVMAP and VELOCITY_FIELD.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        ==========================================
;        SCALETRACK (function)
;
;        External Subroutines Required
;        =========================================
;        MULTIPANEL      MYCT_DEFAULTS (function) 
;        TVMAP           RECTANGLE
;        SYM (function)
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
;        ; Make a "fake" wind [TO DOCUMENT]
;         
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2007-2008
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to yantosca@seas.harvard.edu
; or plesager@seas.harvard.edu with subject "IDL routine ctm_overlay_wind"
;-----------------------------------------------------------------------


;------------------------------------------------------------------------------

pro CTM_OverLay_Wind, Data, XMid, YMid, U,  V,  $
                      Color=Color,        Log=Log,                 $
                      MinData=MinData,    MaxData=MaxData,         $
                      OverPlot=OverPlot,  _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Common block
   common SaveWindowPosition, WP

   ; Arguments and keywords
   Log      = Keyword_Set( Log      )
   OverPlot = Keyword_Set( OverPlot )
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
   ;Nx = N_Elements( U )
   ;Ny = N_Elements( V )
   Su = Size( U, /Dim )
   Sv = Size( V, /Dim )
   if ( Su[0] ne Sv[0] ) then Message, 'U and V have different # of lons!'
   if ( Su[0] ne Sv[0] ) then Message, 'U and V have different # of lons!'
   
   ;====================================================================
   ; Create the plot!
   ;====================================================================

   ; Call TVMAP to plot the pixel map -- don't advance to next frame
   if ( OverPlot ne 1L ) then begin
      TvMap, Data, Xmid, Ymid, $
         /NoAdvance, WindowPos=Wp, MinData=MinData, MaxData=MaxData, _EXTRA=e
   endif

;-------- call to PLOT is not needed with new TVMAP. Commented out
;         (phs, 3/20/08)
;
;   ; Make XRANGE and YRANGE for the PLOT command
;   Dx     = ( XMid[1] - XMid[0] ) / 2.0
;   Dy     = ( Ymid[2] - Ymid[1] ) / 2.0
;   XRange = [ Min( XMid, Max=M ) - Dx, M + Dx ] 
;   YRange = [ Min( YMid, Max=M ) - Dy, M + Dy ]
;
;   
;   ; Put bounds on YRANGE
;   if ( YRange[0] lt -90 ) then Yrange[0] = -90
;   if ( YRange[1] gt  90 ) then Yrange[1] =  90
;
;   ; Set up plot window (data coordinates) but
;   ; don't plot any data, and don't erase the screen
;   Plot, [0, 1], [0, 1],                                   $           
;      /NoData,        /NoErase, /Data,     Color=Color,    $
;      Position=wp,    /XStyle,  /Ystyle,   XMargin=[0, 0], $
;      Ymargin=[0, 0], Xticks=1, YTicks=1,                  $
;      XTickName=[ ' ', ' ' ],   YTickName=[ ' ', ' ' ],    $
;      Xrange=XRange,            YRange=YRange
;
;--------


   ; now pass MapPosition (phs, 3/20/08)
   Velocity_Field, U, V, XMid, YMid, PlotPosition=Wp, $
                   /LegendLen, /LegendNorm, /LegendMag, _EXTRA=e

   ; Quit
   return
end
 
