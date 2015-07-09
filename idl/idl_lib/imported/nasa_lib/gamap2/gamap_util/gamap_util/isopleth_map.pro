; $Id: isopleth_map.pro,v 1.3 2008/07/17 14:08:52 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ISOPLETH_MAP
;
; PURPOSE:
;        Plots a 3-D (longitude, latitude, altitude) isopleth of
;        a data concentration field atop a world map.
;
; CATEGORY:
;        GAMAP Utilities
;
; CALLING SEQUENCE:
;        ISOPLETH_3D
;
; INPUTS:
;        DATA -> The data array to be plotted.  DATA must be
;             3-dimensional.
;
;        XMID, YMID, ZMID -> XMID is the array of longitude grid box
;             centers.  YMID is the array of latitude grid box centers.  
;             ZMID is the array of altitude grid box centers.  
;             ISOPLETH_MAP will be able to label the X, Y, and Z axes
;             based on the values of XMID, YMID, ZMID.
;
; KEYWORD PARAMETERS:
;        ISOPLETH -> Value of data for which to show an iso-contour surface.  
;             Default is 35.0 [ppbv].
;
;        /LOW -> Set this keyword to display the low side of the iso-contour 
;             surface (i.e., the contour surfaces enclose high data values). 
;             If this keyword is omitted or is 0, the high side of the 
;             contour surface is displayed and the contour encloses low
;             data values. If this parameter is incorrectly specified,
;             errors in shading will result.  
;
;        TITLE1 -> First line of the title that is to be placed atop the plot
;             window.  TITLE is passed explicitly to avoid keyword name
;             duplication in the _EXTRA=e facility.  A default title
;             string of "Volume Rendering" will be used if TITLE is not
;             passed explicitly.
; 
;        TITLE2 -> Second line of the title string for the top of the plot
;             window.  This line should be used for specifying the value
;             and units of the isosurface.  A default string such as:
;             "ISOSURFACE = 20.000 [ppbv]" will be created if TITLE2 is
;             not passed explicitly.  Also, if TITLE2 is not passed 
;             explicitly, the format descriptor string passed via the
;             FORMAT keyword will be used to determine the number of
;             decimal places 
;
;        USTR -> String to specify the units of the isocontour surface
;             (e.g. '[ppbv]', '[kg/s]', etc).  Default is a null
;             string, ''.
;
;        FORMAT -> Format descriptor string used in generating a default
;             value of TITLE2.  Default is '(f14.3)'.
;
;        MPARAM -> A 3 element vector containing values for
;             [ P0Lat, P0Lon, Rot ], for the MAP_SET command.  
;             Default is [ 0, 0, 0 ]. Elements not specified are 
;             automatically set to zero.
;
;        LIMIT -> A four-element vector which specifies the latitude
;             and longitude extent of the map.  The elements of LIMIT
;             are arranged thus: [ LatMin, LonMin, LatMax, LonMax ].
;             Default is to set LIMIT = [ -90, -180, 90, 180 ] (i.e.
;             to include the entire globe). P0Lon will be computed
;             to fit into the LIMIT range unless it is explicitely
;             requested in MParam.
;
;        MCOLOR -> Color index of the map outline and title characters.
;             Default is 1 (MYCT black).
;
;        ACOLOR -> Color index of the 3-D axes which surround the map
;             plot.  Defaults is 1 (MYCT black).
;
;        [XYZ]MARGIN -> A 2-element array specifying the margin on
;             the left (bottom) and right (top) sides of the plot
;             window, in units of character size. Defaults are 
;             XMARGIN=[ 5, 3 ], YMARGIN=[ 3, 3], ZMARGIN=[ 3, 3 ].
;             These are used to put some "white space" into the plot
;             window for aesthetic purposes.
;
;        WINPARAM -> An integer vector with up to 5 elements:
;             WINPARAM(0) = window number  (if negative, a window
;                           will be opened with the /FREE option.
;             WINPARAM(1) = X dimension of window in pixels (width)
;             WINPARAM(2) = Y dimension of window in pixels (height)
;
; OUTPUTS:
;        A picture will be displayed in the X-window device.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================
;        OPEN_DEVICE     CLOSE_DEVICE
;        MULTIPANEL      MAP_LABELS
;        TVIMAGE
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages
;
; NOTES:
;        (1) Does not quite work for multi-panel plots, due to the 
;            screen capturing done in the Z-buffer.  
;
;        (2) Verified that the map and data coincide (bmy, 1/19/01)
;
; EXAMPLE:
;      ISOPLETH_MAP, DATA, XMID, YMID, ZMID, $
;         ISOPLETH=40, MPARAM=[0, 180, 0], MCOLOR=1, ACOLOR=1
;
;             ; Will display a 35 [ppbv] isopleth with black
;             ; map labels, lines, and axes.  MPARAM is set to
;             ; accept longitude values (XMID) in the range of
;             ; 0 - 360.  
;
; MODIFICATION HISTORY:
;        bmy, 23 Jan 2001: GAMAP VERSION 1.47
;                          - based on example code by David Fanning
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        phs, 17 Jul 2008: GAMAP VERSION 2.12
;                          - Now set N_COLORS to !D.TBLE_SIZE 
;
;-
; Copyright (C) 2001-2008, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine isopleth_map"
;-----------------------------------------------------------------------


pro IsoPleth_Map, Data, XMid, YMid, ZMid,               $
                  IsoPleth=IsoPleth, Low=Low,           $
                  Title1=Title1,     Title2=Title2,     $
                  UStr=UStr,         Format=Format,     $ 
                  MParam=MParam,     Limit=Limit,       $
                  MColor=MColor,     AColor=AColor,     $
                  XMargin=XMargin,   YMargin=YMargin,   $
                  ZMargin=ZMargin,   WinParam=WinParam, $
                  _EXTRA=e
  
   ;====================================================================
   ; Defaults for arguments & Keywords
   ;====================================================================
   
   ; Check size of data array
   SData = Size( Data, /Dim )
   if ( N_Elements( SData ) ne 3 ) then begin
      Message, 'DATA must be 3-D. Returning...', /Continue
      return
   endif
   
   ; Limits and Ranges for X, Y, Z (these are # of array elements)
   XMax   = SData[0]
   YMax   = SData[1]
   ZMax   = SData[2]
   XRange = [ 0L, XMax - 1L ]
   YRange = [ 0L, YMax - 1L ]
   ZRange = [ 0L, ZMax - 1L ]

   ; Error check for XMID (bmy, 5/10/00)
   if ( N_Elements( XMid ) gt 0 ) then begin
      SXMid = Size( XMid, /Dimensions )

      ; XMID must be a 1-D vector
      if ( N_Elements( SXMid ) ne 1 ) then begin
         Message, 'XMID must be a 1-D vector!', /Continue
         return
      endif
     
      ; XMID must have the same # of elements as the 1st dim of DATA
      SXMid = SXMid[0]
      if ( SXMid ne XMax ) then begin
         Message, 'XMID is not compatible with DATA!', /Continue
         return
      endif
   endif

   ; Error check for YMID (bmy, 5/10/00)
   if ( N_Elements( YMid ) gt 0 ) then begin
      SYMid = Size( YMid, /Dimensions )

      ; YMID must be a 1-D vector
      if ( N_Elements( SYMid ) ne 1 ) then begin
         Message, 'YMIDDD must be a 1-D vector!', /Continue
         return
      endif
     
      ; YMID must have the same # of elements as the 2nd dim of DATA
      SYMid = SYMid[0]
      if ( SYMid ne YMax ) then begin
         Message, 'YMIDDD is not compatible with DATA!', /Continue
         return
      endif
   endif

   ; Error check for ZMID (bmy, 5/10/00)
   if ( N_Elements( ZMid ) gt 0 ) then begin
      SZMid = Size( ZMid, /Dimensions )

      ; ZMID must be a 1-D vector
      if ( N_Elements( SZMid ) ne 1 ) then begin
         Message, 'ZMID must be a 1-D vector!', /Continue
         return
      endif
     
      ; ZMID must have the same # of elements as the 3rd dim of DATA
      SZMid = SZMid[0]
      if ( SZMid ne ZMax ) then begin
         Message, 'ZMID is not compatible with DATA!', /Continue
         return
      endif
   endif  

   ; Settings for window size -- use actual size of the window
   if ( N_Elements( WinParam ) ne 3 ) $
      then WinParam = [ 0, !D.X_SIZE, !D.Y_SIZE ]

   Window = WinParam[0]  
   XSize  = WinParam[1]
   YSize  = WinParam[2]

   ; Default settings for LIMIT (bmy, 5/10/00)
   if ( N_Elements( Limit ) eq 0 ) then begin
 
      ; If XMID and YMID are passed, use them to determine LIMIT
      if ( SXMid gt 3 AND SYMid gt 3 ) then begin
         Limit = [ ( YMid[0]       ) > ( -90.0 ),  $
                   ( XMid[0]       ),              $
                   ( YMid[SYMid-1] ) < 90.0,       $
                   ( XMid[SXMid-1] ) ]
      endif $

      ; Otherwise use the default limit for the entire globe
      else begin
         Limit = [ -90, -180, 90, 180 ]
      endelse
   endif

   ; Set P0Lat, P0Lon, Rot from MPARAM or LIMIT
   if ( N_Elements( MParam ) ge 2 )      $
      then P0Lon = MParam[1]             $
      else P0Lon = total( Limit[[1,3]] )/2. ; make sure it's at the map center

   if ( N_Elements( MParam ) eq 0 )       $
      then MParam = [ 0,0,0 ]             $
      else MParam = ([ Mparam,0,0,0] )[0:2]

   P0Lat = Mparam[0]
   Rot   = MParam[2]

   ; Default settings for other keywords 
   Low = Keyword_Set( Low )
   if ( N_Elements( IsoPleth ) ne 1 ) then IsoPleth = 35.0
   if ( N_Elements( XMargin  ) ne 2 ) then XMargin  = [ 5, 3 ]
   if ( N_Elements( YMargin  ) ne 2 ) then YMargin  = [ 3, 3 ]
   if ( N_Elements( ZMargin  ) ne 2 ) then ZMargin  = [ 3, 3 ]
   if ( N_Elements( MColor   ) ne 1 ) then MColor   = 1
   if ( N_Elements( AColor   ) ne 1 ) then AColor   = 1
   if ( N_Elements( UStr     ) ne 1 ) then UStr     = ''
   if ( N_Elements( Format   ) ne 1 ) then Format   = '(f14.3)'
   if ( N_Elements( Title1   ) ne 1 ) then Title1   = 'Volume Rendering'

   ; Create default value for TTITLE2 
   if ( N_Elements( Title2   ) ne 1 ) then begin
      Title2 = 'Isopleth = ' + $
         StrTrim( String( IsoPleth, Format=FFormat ), 2 )

      ; Put a space before displaying the unit string
      if ( UStr ne '' ) then Title2 = Title2 + ' ' + UStr
   endif
      
   ; If /LOW is set, then adjust TITLE2 accordingly
   if ( Low ) then Title2 = StrTrim( Title2, 2 ) + ' and below'
      
   ; Make sure that ISOPLETH is not outside the range of DATA
   MaxData = Max( Data, Min=MinData )

   if ( IsoPleth gt MaxData or IsoPleth lt MinData ) then begin
      Print, '% SELECTED ISOPLETH VALUE  : ', IsoPleth
      Print, '% MIN( Data ), Max( DATA ) : ', MinData, MaxData
      Message, 'Isopleth value is outside range of data...Returning!', $
         /Continue
      return
   endif

   ;====================================================================
   ; Define title strings & tick labels 
   ;====================================================================
   
   ; Set up title string
   NewTitle  = Title1 + '!C!C' + Title2

   ; Set up Z-axis labels 
   ZTickV    = IndGen( N_Elements( ZMid ) )
   ZTicks    = N_Elements( ZTickV ) - 1L
   ZTickName = StrTrim( String( ZMid, Format='(f14.2)' ), 2 )
   ZMinor    = 0   

   ;====================================================================
   ; Set up the IDL Z-buffer device
   ;====================================================================

   ; Save old device name and number of colors
   ThisDevice = !D.Name
   N_Colors   = !D.Tble_size ; !D.N_Colors
 
   ; Open the Z-Buffer and set the size & color table
   Set_Plot, 'Z', /Copy
   Erase
   Device, Set_Resolution=[ XSize, YSize ], Set_Colors=N_Colors
 
   ;====================================================================
   ; Do volume rendering in the Z-buffer
   ;====================================================================

   ; Get the position vector from MULTIPANEL
   MultiPanel, Position=PPosition

   ; Call SURFACE to set up transformation matrix
   ; Suppress X, Y axes, but plot Z-axis
   Surface, Dist(2),                                                $
      /XStyle,       XRange=XRange,         XMargin=XMargin,        $
      XTicks=1,      XMinor=0,              XTickName=[ ' ', ' ' ], $
      /YStyle,       YRange=YRange,         YMargin=YMargin,        $
      YTicks=1,      YMinor=0,              YTickName=[ ' ', ' ' ], $
      /ZStyle,       ZRange=ZRange,         ZMargin=ZMargin,        $
      ZTickV=ZTickV, ZTickName=ZTickName,   ZTicks=ZTicks,          $
      ZMinor=0,      ZTitle='Altitude (km)',                        $
      /Save,         /NoErase,              /NoData,                $
      Color=AColor,  Position=PPosition,    _EXTRA=e

   ; Render the isosurface
   ; Make sure that IMAGE has the same dimensions as the window
   Shade_Volume, Data, IsoPleth, V, P, Low=Low, _EXTRA=e
   Image = PolyShade( V, P, /T3D, XSize=XSize, YSize=YSize, Top=NColors )
 
   ; Print map at bottom of plot
   Map_Set, P0Lat, P0Lon, Rot,                                 $
      /Cylindrical,    /Continents,        Color=MColor,       $
      /NoBorder,       /T3D,               ZValue=0.0,         $
      /NoErase,        Limit=Limit,        XMargin=XMargin,    $
      YMargin=YMargin, Position=PPosition, _EXTRA=e
 
   ; Draw continents and country boundaries (same color as the map)
   Map_Continents, $
      /Countries, /Coasts,         Color=MColor,     $
      ZValue=0.0, XMargin=XMargin, YMargin=YMargin,  $
      /T3D,       _EXTRA=e

   ; Generate latitude and longitude labels
   LatRange = [ Limit[0], Limit[2] ]
   LonRange = [ Limit[1], Limit[3] ]

   Map_Labels, LatLabel, LonLabel,              $
      Lats=Lats,         LatRange=LatRange,     $
      Lons=Lons,         LonRange=LonRange,     $
      NormLats=NormLats, NormLons=NormLons,     $
      /MapGrid,          _EXTRA=e

   ; Plot latitude labels (same color as the axes)
   XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
      Align=1.0, Color=AColor, /Normal, /T3D, _EXTRA=e

   ; Plot longitude labels (same color as the axes)
   XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
      Align=0.5, Color=AColor, /Normal, /T3D, _EXTRA=e

   ; Draw grid lines on the map 
   Map_Grid, $
      /XStyle,  XMargin=XMargin, Lons=Lons, $
      /YStyle,  YMargin=YMargin, Lats=Lats, $
      /T3D,     Color=MColor,    _EXTRA=e
   
   ; Print the plot title atop the screen 
   XYOuts, 0.5, 0.95, NewTitle, $
      /Normal, Align=0.5, Color=MColor, CharSize=1.2, _EXTRA=e

   ; Take a 2-D "snapshot" of everything in the Z-buffer
   SnapShot = TvRd()

   ; Close Z-buffer
   Close_Device

   ;====================================================================
   ; Display isopleth map on screen or save to PostScript plot
   ;====================================================================

   ; Open another X-window
   Open_Device, WinParam=WinParam
   
   ; Display 2-D "snapshot"
   TvImage, SnapShot, /Keep

   ; Advance to next MULTIPANEL frame
   MultiPanel, /Advance, /NoErase

   ; Quit
   return
end
