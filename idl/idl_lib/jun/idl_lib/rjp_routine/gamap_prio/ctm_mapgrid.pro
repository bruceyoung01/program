; $Id: ctm_mapgrid.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_MAPGRID
;
; PURPOSE:
;        Plots CTM grid boxes superposed atop a world map.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_MAPGRID, GRIDINFO [, Keywords ]
;
; INPUTS:
;        GRIDINFO -> Output structure returned from CTM_GRID
;             containing information about the particular
;             grid being used.
;
; KEYWORD PARAMETERS:
;        COLOR -> Color index for the map outline, continents, and
;             title.  Default is BLACK (assuming MYCT color table).
;
;        G_COLOR -> Color index for the grid lines.  
;             Default is BLACK (assuming MYCT color table).
;
;        LIMIT -> Vector containing [ LatMin, LonMin, LatMax, LonMax ].
;             These define the latitude and longitude ranges for
;             the map projection.  If LIMIT is not supplied,
;             CTM_MAPGRID will construct LIMIT from the information
;             supplied in GRIDINFO.
;
;        /PS -> If set, will send output to a PostScript file.
;
;        _EXTRA=e -> Picks up any extra keywords for OPEN_DEVICE,
;             MAP_SET, MAP_CONTINENTS, PLOTS, and CLOSE_DEVICE.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ---------------------------------------------
;        CHKSTRU (function)               CONVERT_LON
;        OPEN_DEVICE                      CLOSE_DEVICE 
;        MYCT_DEFAULTS (function)
;        
; REQUIREMENTS:
;        References routines from GAMAP and TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLES:
;        (1)
;        GRIDINFO = CTM_GRID( CTM_TYPE( 'GEOS1', RES=2 ) )
;        CTM_MAPGRID, GRIDINFO, LIMIT=[ -90, 130, 90, -130 ], /ISOTROPIC
;
;             ; Plots a world map (pacific region, spanning
;             ; the date line) for the GEOS-1 2 x 2.5 grid 
;
;
;        (2)
;        CTM_MAPGRID, GRIDINFO, LIMIT=[ -90, -182.5, 90, 177.5 ], /ISOTROPIC
;
;             ; For the same grid as above, plots the entire world
;             ; centered on 0 degrees lat and 0 degrees longitude.
;
; MODIFICATION HISTORY:
;        bmy, 03 Nov 1999: VERSION 1.00
;        bmy, 24 Mar 2000: VERSION 1.45
;                          - now prints map labels 
;                          - added /NOBORDER to MAP_SET call
;        bmy, 27 May 2003: GAMAP VERSION 1.53
;                          - now plots continent lines after grid lines
;
;-
; Copyright (C) 1999-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_mapgrid"
;-----------------------------------------------------------------------


pro CTM_MapGrid, GridInfo,                         $ 
                 Color=M_Color,   G_Color=G_Color, $
                 C_Color=C_Color, Limit=Map_Limit, $
                 PS=PS,           _EXTRA=e

   ;--------------------------------------------------------------------
   ; Prior to 7/23/01:
   ; Get default drawing colors
   ;@default_colors
   ;--------------------------------------------------------------------
   ; Now use MYCT_DEFAULTS() to set up color table (bmy, 7/23/01)
   C = MYCT_Defaults()

   ; Pass external functions
   FORWARD_FUNCTION ChkStru

   ;====================================================================
   ; Error checking / Keyword Settings
   ;====================================================================
   if ( not ChkStru( GridInfo, ['IMX', 'JMX', 'LMX'] ) ) then begin
      Message, 'Invalid GRIDINFO structure!', /Continue
      return
   endif

   ; Default colors
   if ( N_Elements( M_Color ) eq 0 ) then M_Color = C.BLACK
   if ( N_Elements( G_Color ) eq 0 ) then G_Color = C.BLACK
   if ( N_Elements( C_Color ) eq 0 ) then C_Color = M_Color

   ; Default Limit for MAP_SET
   if ( N_Elements( Map_Limit ) eq 0 ) then begin
      Map_Limit = [ GridInfo.YEDGE[0],              $
                    GridInfo.XEDGE[0],              $
                    GridInfo.YEDGE[ GridInfo.JMX ], $
                    GridInfo.XEDGE[ GridInfo.IMX ] ]
   endif

   ; PostScript output
   PS = Keyword_Set( PS )

   ;====================================================================
   ; Open the plot device
   ;====================================================================
   Open_Device, /Color, Bits=8, PS=PS, _EXTRA=e

   ;====================================================================
   ; XIND is the index array of valid longitude edges.
   ;====================================================================
   Is_Pacific  = ( Map_Limit[1] gt Map_Limit[3] )
   LonRange    = [ Map_Limit[1], Map_Limit[3] ]

   if ( Is_Pacific ) then begin
 
      ; "PACIFIC" range: Straddles the date line
      ; Convert LONRANGE and TMPXEDGE to 0..360 degrees
      Convert_Lon, LonRange, /Pacific
      
      TmpXEdge = GridInfo.XEdge
      Convert_Lon, TmpXEdge, /Pacific

   endif else begin

      ; "ATLANTIC" range: Does not straddle the date line
      ; Keep longitudes in range -180..180 degrees
      TmpXEdge = GridInfo.XEDGE

   endelse

   XInd = Where( TmpXEdge ge LonRange[0] AND $
                 TmpXEdge le LonRange[1], XCount )

   if ( XCount gt 0 ) then begin
      XEdge = GridInfo.XEDGE[ XInd ]
   endif else begin
      Message, 'Longitude edges incompatible with LIMIT!', /Continue
      return
   endelse

   ;====================================================================
   ; YIND is the index array of valid latitude edges (YEDGE).
   ;
   ; To avoid quirkiness in overplotting the grid lines, only 
   ; consider -89.9 <= YEDGE <= 89.9 as valid latitude edges.
   ;====================================================================
   LatRange = [ Min( [ Map_Limit[0], Map_Limit[2] ], Max=M ), M ]
   LatRange = ( LatRange < 89.9 ) > ( -89.9 )

   YInd = Where( GridInfo.YEDGE ge LatRange[0] AND $
                 GridInfo.YEDGE le LatRange[1], YCount )

   if ( YCount gt 0 ) then begin
      YEdge = ( GridInfo.YEDGE[ YInd ] < 89.9 ) > ( -89.9 ) 
   endif else begin
      Message, 'Latitude edges incompatible with LIMIT!', /Continue
      return
   endelse

   ;====================================================================
   ; Define plot limits.  Make sure that the latitudes only extend
   ; to +/- 89 degrees, to avoid quirkiness in MAP_SET.
   ;====================================================================
   NewLimit = [ LatRange[0], LonRange[0], LatRange[1], LonRange[1] ]

   ;====================================================================
   ; "PACIFIC" PLOTS: Longitude range straddles the date line!
   ; 
   ; LONRANGE is in the range 0..360 degrees.  This necessitates the
   ; call to MAP_SET with the parameters 0, 180.
   ;====================================================================
   if ( Is_Pacific ) then begin

      ; Plot the map...do not put a border of white space at the edges
      Map_Set, 0, 180, $
         Limit=NewLimit, Color=M_Color, /NoBorder, $
         XMargin=[7,3],  YMargin=[3,3], _EXTRA=e
      
      ; Overplot vertical lines
      for I = 0, XCount - 1 do begin
         OPlot, [ XEdge[I], XEdge[I] ], LatRange, Color=G_Color, _EXTRA=e
      endfor

      ; Overplot Horizontal Lines
      if ( Abs( LonRange[1] - LonRange[0] ) gt 180.0 ) then begin

         ; If the longitude range is greater than 180 degrees,
         ; then break it up into two separate ranges and
         ; plot them individually...
         Tmp1 = [ LonRange[0], 180.0 ]
         Tmp2 = [ 180.0, LonRange[1] ]

         for J = 0, YCount - 1 do begin
            OPlot, Tmp1, [ YEdge[J], YEdge[J] ], Color=G_Color, _EXTRA=e
            OPlot, Tmp2, [ YEdge[J], YEdge[J] ], Color=G_Color, _EXTRA=e
         endfor

      endif else begin

         ; ... otherwise just plot the longitude range as is
         for J = 0, YCount - 1 do begin
            OPlot, LonRange, [ YEdge[J], YEdge[J] ], Color=G_Color, _EXTRA=e
         endfor
         
      endelse

      ; Draw continents over the grid lines
      Map_Continents, Color=M_Color, _EXTRA=e

      ; Construct latitude and longitude labels, as well as
      ; the normal coordinates where they will be placed
      LatRange = [ Map_Limit[0], Map_Limit[2] ]
      LonRange = [ Map_Limit[1], Map_Limit[3] ]

      Map_Labels, LatLabel, LonLabel,          $
         LatRange=LatRange, LonRange=LonRange, $
         Lats=Lats,         Lons=Lons,         $
         NormLats=NormLats, NormLons=NormLons, $
         Color=M_Color,     /MapGrid,          $
         _EXTRA=e

      ; Plot latitude and longitude labels using normal coordinates
      XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
         Align=1.0, /Normal, Color=M_Color, CharSize=1.0

      XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
         Align=0.5, /Normal, Color=M_Color, CharSize=1.0

      ; Draw a rectangle border around the map window region
      NewPosition = [ !X.Window[0], !Y.Window[0], !X.Window[1], !Y.Window[1] ]
      
      Rectangle, NewPosition, XPoints, YPoints

      PlotS, XPoints, YPoints, Thick=2, Color=M_Color, /Normal

   ;====================================================================
   ; "ATLANTIC" PLOTS: Longitude range does not straddle the date line!
   ; 
   ; LONRANGE is in the range -180..180 degrees.  
   ; Call MAP_SET as usual.  
   ;
   ; Also, when overplotting the horizontal lines, we have to break 
   ; the longitude range at zero degrees, or else the lines will not
   ; be plotted correctly.  More quirkiness.
   ;
   ; To avoid even further quirkiness when overplotting the horizontal
   ; grid lines, force the plot range to be between -179.9 and 179.9
   ; degrees.  Otherwise you might get some weird results.
   ;====================================================================
   endif else begin
      Map_Set, Limit=NewLimit, Color=M_Color, /NoBorder, $
               XMargin=[7,3],  YMargin=[3,3], _EXTRA=e

      ; Overplot vertical lines
      for I = 0, XCount - 1 do begin
         OPlot, [ XEdge[I], XEdge[I] ], LatRange, Color=G_Color, _EXTRA=e
      endfor

      ; Overplot Horizontal lines
      ;print, '### LonRange: ', LonRange
      Tmp1 = [ LonRange[0] > ( -179.9 ), 0.0 ]
      Tmp2 = [ 0.0, LonRange[1] < ( 179.9 ) ]

      for J = 0, YCount - 1 do begin
         OPlot, Tmp1, [ YEdge[J], YEdge[J] ], Color=G_Color, _EXTRA=e
         OPlot, Tmp2, [ YEdge[J], YEdge[J] ], Color=G_Color, _EXTRA=e
      endfor

      ; Draw continents over the grid lines
      Map_Continents, Color=M_Color, _EXTRA=e

      ; Construct latitude and longitude labels, as well as
      ; the normal coordinates where they will be placed
      LatRange = [ Map_Limit[0], Map_Limit[2] ]
      LonRange = [ Map_Limit[1], Map_Limit[3] ]

      Map_Labels, LatLabel, LonLabel,           $
         LatRange=LatRange,  LonRange=LonRange, $
         Lats=Lats,          Lons=Lons,         $
         NormLats=NormLats,  NormLons=NormLons, $
         Color=M_Color,      /MapGrid,          $
         _EXTRA=e

      ; Plot latitude and longitude labels using normal coordinates
      XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
         Align=1.0, /Normal, color=M_Color, charsize=1.0

      XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
         Align=0.5, /Normal, color=M_Color, charsize=1.0

      ; Draw a rectangle border around the map window region
      NewPosition = [ !X.Window[0], !Y.Window[0], !X.Window[1], !Y.Window[1] ]

      Rectangle, NewPosition, XPoints, YPoints

      PlotS, XPoints, YPoints, Thick=2, Color=M_Color, /Normal

   endelse

   ;====================================================================
   ; Close the device and quit
   ;====================================================================    
Quit:
   Close_Device, _EXTRA=e

   return
end
 
