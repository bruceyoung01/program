; $Id: map_labels.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        MAP_LABELS
;
; PURPOSE:
;        Constructs map labels from numerical values, in either
;        numerical format (e.g. "-90", "0", "90" ), or in
;        directional format ( e.g. "90S, "0", "90N" ).
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        MAP_LABELS, LatLabel, LonLabel [ , Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        LATRANGE, LONRANGE -> The range of latitudes (longitudes)
;            for the map or plot area.
;
;        LATS, LONS  -> Returns to the calling program the array of
;            latitudes (longitudes) used to construct the map labels.
;
;        DLAT, DLON -> Returns to the calling program the latitude
;            (longitude) interval between grid lines.
;
;        /MAPGRID -> If set, will assume that latitude and longitude
;            labels are for grid lines on a world map.  Also compute
;            normal coordinates which can be used for placing the
;            labels next to the map.
;
;        NORMLATS -> 2D Array containing normal X and Y
;            coordinates for placing latitude labels outside map
;            boundaries.  These are computed only if /MAPGRID is set.
;
;        NORMLONS -> 2D-Array containing normal X and Y
;            coordinates for placing latitude labels outside map
;            boundaries.  These are computed only if /MAPGRID is set.
;
;     Keywords Passed to CONSTRUCT_MAP_LABELS:
;     ========================================
;        FORMAT -> Format descriptor string used in converting the
;            values from DATA into string representation.  The
;            default value is '(i10)'.
;
;        /NUMERIC -> If set, will return latitude or longitude
;            labels in numerical format (e.g. "-90", "0", "+90").
;            If not set, will return latitude or longitude labels
;            in directional format (e.g. "90S, "0", "90N")
;
;        /NODEGREE -> If set, will prevent the raised degree symbol
;            from being appended to MAPLABEL.  Default is to add the
;            raised degree symbol to MAPLABEL.
;
; OUTPUTS:
;        LATLABEL -> String array of latitude labels
;
;        LONLABEL -> String array of longitude labels
;
; SUBROUTINES:
;        Internal Subroutines:
;        ---------------------
;        CONSTRUCT_MAP_LABELS (function)
;        GET_GRIDSPACING (function)
;
;        External Subroutines:
;        ---------------------
;        STRREPL (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) LATLABEL and LONLABEL are in the range of -180..180 degrees.
;
;        (2) We should at some point allow the user to supply individual values
;            that override the default spacing.
;
; EXAMPLE:
;        (1) For use in conjunction with the PLOT command...
;
;         MAP_LABELS, YTickName, XTickName,           $    ; call MAP_LABELS
;            LatRange=[ -90,90], LonRange=[-180,180], $    ; to get the
;            Lats=Lats,          Lons=XTickV,         $    ; lat and lon
;            _EXTRA=e                                      ; tick labels
;
;         PLOT, XArr, YArr, XTickV=XTickV,            $    ; call PLOT,
;             XTickName=XTickName,                    $    ; using the
;             XTicks=N_Elements( XTickV )-1,          $    ; labels as
;             _EXTRA=e                                     ; tick names
;
;
;        (2) For use in conjunction with MAP_SET and MAP_GRID
;
;        Limit    = [ -90, -180, 90, 180 ]                 ; set up the
;        MAP_SET, Limit=Limit, _EXTRA=e                    ; world map
;
;        LatRange = [ Limit[0], Limit[2] ]                 ; define lat and
;        LonRange = [ Limit[1], Limit[3] ]                 ; lon ranges
;
;        MAP_LABELS, LatLabel,    LonLabel,            $   ; call MAP_LABELS
;           Lats=Lats,            LatRange=LatRange,   $   ; to return
;           Lons=Lons,            LonRange=LonRange,   $   ; the lat/lon
;           NormLats=NormLats,    NormLons=NormLons,   $   ; values, labels
;           /MapGrid,             _EXTRA=e                 ; normal coordinates
;
;      Map_Grid, Lats=Lats, Lons=Lons, _EXTRA=e
;            ; Plots the grid lines on the map
;
;      XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, Align=1.0, /Normal
;            ; Plots latitude labels using normal coordinates
;
;      XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, Align=0.5, /Normal
;            ; Plots longitude labels using normal coordinates
;
; MODIFICATION HISTORY:
;        mgs, 19 Feb 1999: VERSION 1.00
;        bmy, 26 Feg 1999: VERSION 1.10
;                          - now works for maps that are smaller
;                            than global size.
;        bmy, 04 Mar 1999: VERSION 1.11
;                          - added DEBUG keyword for output
;                          - now computes NORM_XLAT correctly for
;                            grids that are centered on -180 degrees
;        mgs, 17 Mar 1999: - cleaned up
;                          - replaced Norm[XY]... by two dimensional
;                            NormLons and NormLats
;                          - Longitude conversion now done in CONSTRUCT_...
;                          - calls MAP_SET if /MAPGRID is set and no
;                            map has been established.
;        bmy, 25 Mar 1999: - double default DLON if more than 2 plots
;                            per page
;        mgs, 23 Apr 1999: - bug fix for LON labels in Pacific mode
;        mgs & bmy, 03 Jun 1999: - fix for Pacific ranges in GET_GRIDSPACING
;
;-
; Copyright (C) 1999, Bob Yantosca, Martin Schultz,Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine map_labels"
;-------------------------------------------------------------

function Construct_Map_Labels, Data,                                    $
                               Latitude=Latitude,  Longitude=Longitude, $
                               NoDegree=NoDegree,  Numeric=Numeric,     $
                               Format=Format,      _EXTRA=e

   ;===================================================================
   ; Function CONSTRUCT_MAP_LABELS constructs map labels in either
   ; numeric format (e.g. "-90") or directional format ( "90S" )
   ;
   ; CALLING SEQUENCE:
   ;     Result =  CONSTRUCT_MAP_LABELS( Data, /Lat|Lon, [, Keywords ] )
   ;
   ; EXAMPLES:
   ;        (0) Default is to return degree symbols and directional
   ;            format. If neither LON nor LAT is given the numeric
   ;            format is used.
   ;
   ;        (1) Construct numerical lon labels, suppressing the
   ;            superscripted degree symbols as well as the E/W suffixes.
   ;
   ;        Data     = [ -180, -120, -60, 0, +60, +120, +180 ]
   ;        MapLabel = CONSTRUCT_MAP_LABELS( Data, /Numeric, /NoDegree, /Lon )
   ;        print, MapLabel
   ;                180 -120 -60 0 60 120 180
   ;
   ;        (2) Returns numerical lat labels, with the
   ;            superscripted degree symbols.
   ;
   ;        Data     = [ -90, -45, 0, 45, 90 ]
   ;        MapLabel = CONSTRUCT_MAP_LABELS( Data, /Numeric, /Lat )
   ;        print, MapLabel
   ;               -90!Uo!N -45!Uo!N 0!Uo!N 45!Uo!N 90!Uo!N
   ;
   ;        (3) Returns directional lon labels, suppressing the
   ;            superscripted degree symbols.
   ;
   ;        Data     = [ -180, -120, -60, 0, 60, 120, 180 ]
   ;        MapLabel = CONSTRUCT_MAP_LABELS( Data, /NoDegree, /Lon )
   ;        print, MapLabel
   ;               180 120W 60W 0 60E 120E 180
   ;---
   ; Pass external functions
   ;===================================================================
   FORWARD_FUNCTION StrRepl

   ;===================================================================
   ; Error checking / Set Defaults
   ;===================================================================
   if ( N_Elements( Data ) eq 0 ) then begin
      Message, 'DATA must be passed to CONSTRUCT_MAP_LABELS!', /Continue
      return, -1
   endif

   Latitude  = Keyword_Set( Latitude  )
   Longitude = Keyword_Set( Longitude )
   Numeric   = Keyword_Set( Numeric   )
   NoDegree  = Keyword_Set( NoDegree  )

   ; Format string for string conversion
   if ( N_Elements( Format ) eq 0 ) then Format = '(i10)'

   ; Superscripted degree symbol
   if ( NoDegree ) then Deg = '' else Deg = '!Uo!N'

   ; Define directional strings for latitude and longitude
   SuffixStr = [ '', '' ]
   if ( not Numeric ) then begin
      if ( Latitude  ) then SuffixStr = [ 'N', 'S' ]
      if ( Longitude ) then SuffixStr = [ 'E', 'W' ]
   endif

   ;==================================================================
   ; Make sure DATA range spans -180, 180
   ;==================================================================

   TmpData = Data
   if (Longitude) then Convert_Lon,TmpData,/Atlantic

   ;===================================================================
   ; Locate the elements of DATA that are negative, positive,
   ; equal to zero, and equal to +/- 180
   ;===================================================================
   Minus     = Where( TmpData        lt 0   )
   Plus      = Where( TmpData        gt 0   )
   Zero      = Where( Abs( TmpData ) eq 0   )
   OneEighty = Where( Abs( TmpData ) eq 180 )


   ;==================================================================
   ; Convert DATA to string representation and store in MAPLABEL
   ;==================================================================
   MapLabel = Strtrim( String( Abs(TmpData), Format=Format ), 2 )

   ;==================================================================
   ; Handle the negative values of DATA
   ;==================================================================
   if ( Minus[0] ge 0 ) then begin
      MapLabel[ Minus ] = MapLabel[ Minus ] + Deg + SuffixStr[1]

      ; Add '-' signs for numeric format
      if (Numeric) then MapLabel[Minus] = '-' + MapLabel[Minus]
   endif

   ;==================================================================
   ; Handle the positive values of DATA
   ;==================================================================
   if ( Plus[0] ge 0 ) then begin
      MapLabel[ Plus ] = MapLabel[ Plus ] + Deg + SuffixStr[0]
   endif

   ;==================================================================
   ; Handle the values of DATA that are zero degrees
   ;==================================================================
   if ( Zero[0] ge 0 ) then MapLabel[ Zero ] = '0' + Deg

   ;==================================================================
   ; Handle the values of DATA that are 180 degrees
   ;==================================================================
   if ( OneEighty[0] ge 0 ) then MapLabel[ OneEighty ] = '180' + Deg

   ;==================================================================
   ; Return vector of map labels to the calling program.
   ;==================================================================
   return, StrTrim( MapLabel, 2 )
end

;----------------------------------------------------------------------------

function get_gridspacing,range,delta=delta,n=n, Scale=Scale

   ;===================================================================
   ; Function GET_GRIDSPACING returns 5, 10, 15, 30 depending on
   ; the input range (mgs, 2/99).
   ;===================================================================

   ; If RANGE[0] > RANGE[1] then this is a Pacific range that
   ; straddles the date line.  Add 360 to RANGE[1] so that RANGE[1]
   ; will be greater than RANGE[0].
   if ( range[0] gt range[1] ) then range[1] = range[1] + 360.

   dist = range[1]-range[0]
;print,dist,range
;stop
   if (dist gt 150.) then delta = 30. $
   else if (dist gt 80.) then delta = 15. $
   else if (dist gt 45.) then delta = 10. $
   else delta = 5.

   ; Multiply the DELTA spacing by SCALE (bmy, 3/25/99)
   if ( N_Elements( Scale ) gt 0 ) then Delta = Delta * Scale

   ; set up mega grid and truncate to actual range
   ; range shouldn't exceed -180 or +720 in any case
   ; therefore we start with a grid of 900/5 = 150 entries
   grid = findgen(150)*delta - 180.

   keep = where(grid ge range[0] AND grid le range[1])
   if (keep[0] eq -1) then begin
      message,'Invalid parameters for grid??',/INFO
      keep = [ 0,1 ]
   endif

   grid = grid[keep]
   n = n_elements(keep)

   return,grid
end

;----------------------------------------------------------------------------

pro Map_Labels, LatLabel, LonLabel,                             $
                DLat=DLat,             DLon=DLon,               $
                Lats=Lats,             LatRange=LatRange,       $
                Lons=Lons,             LonRange=LonRange,       $
                NormLons=NormLons,     NormLats=NormLats,       $
                MapGrid=MapGrid,       Debug=Debug,             $
                _EXTRA=e

   ;===================================================================
   ; Pass external functions
   ;===================================================================
   FORWARD_FUNCTION Construct_Map_Labels, Get_GridSpacing

   ;===================================================================
   ; Default Settings
   ;===================================================================
   if ( N_Elements( LatRange ) ne 2 ) then LatRange = [  -90.0,  90.0 ]
   if ( N_Elements( LonRange ) ne 2 ) then LonRange = [ -182.5, 177.5 ]

   MapGrid = Keyword_Set( MapGrid )
   Debug   = Keyword_Set( Debug   )

   ;===================================================================
   ; GET_GRIDSPACING returns the latitudes to be labeled.
   ;===================================================================
   Lats = Get_GridSpacing( LatRange, N=NLat, Delta=DLat )

   ;===================================================================
   ; GET_GRIDSPACING returns the longitudes to be labeled.
   ;
   ; If LONRANGE[0] > LONRANGE[1] then we are straddling the date
   ; line, so call CONVERT_LON to convert LONRANGE into the range
   ; 0..360 degrees.
   ;
   ; Increase spacing between grid lines if more than one panel is
   ; plotted per page
   ;===================================================================
   if ( LonRange[0] gt LonRange[1] ) then Convert_Lon, LonRange, /Pacific

   Scale_DLon = 1.
   if ( !P.MULTI[1] * !P.MULTI[2] gt 1 ) then Scale_DLon = 2.

   Lons = Get_GridSpacing( LonRange, N=NLon, Delta=DLon, Scale=Scale_DLon )

   ; Debug output (bmy, 3/4/99)
   if ( Debug ) then begin
      print, '### MAP_LABELS : Lats      : ', Lons
      print, '### MAP_LABELS : Lons      : ', Lons
   endif

   ;===================================================================
   ; If /MAPGRID is set, then there is some extra steps we need
   ; to follow, in order to print the labels correctly for maps that
   ; do not span the entire globe.
   ;===================================================================
   if ( MapGrid ) then begin

      ;================================================================
      ; Add the endpoints of the latitude and longitude ranges to
      ; LATS and LONS.  This will cause the grid lines to cover the
      ; entire map area, even if the map doesn't span the whole globe.
      ;
      ; Eliminate duplicate values in LATS and LONS.
      ;
      ; NOTE: LON0 is needed to keep the labels being printed to
      ;       the left of the map, even when LONRANGE[0] = -182.5,
      ;       which is the case for GEOS and GISS-CTM-II grids.
      ;================================================================
      Lon0 = ( LonRange[0] > ( -180.0 ) )

      Lats = [ LatRange[0], Lats, LatRange[1] ]
      Lons = [ Lon0,        Lons, LonRange[1] ]

      Lats = Lats[ Uniq( Lats ) ]
      Lons = Lons[ Uniq( Lons ) ]

      ;================================================================
      ; Compute normal coordinates of each grid line
      ;================================================================
      ; make sure a map projection is active
      if (!MAP.projection eq 0) then map_set
      DumLats  = FltArr( N_Elements( Lons ) ) + LatRange[0]
      DumLons  = FltArr( N_Elements( Lats ) ) + Lon0
      NormLats = Convert_Coord( DumLons, Lats,    /Data, /To_Normal )
      NormLons = Convert_Coord( Lons,    DumLats, /Data, /To_Normal )

      ;================================================================
      ; Estimated character height
      ;================================================================
      CharHeight = 0.010

      ;================================================================
      ; CONSTRUCT_MAP_LABELS will return the labels to be plotted
      ; next to each grid line.  Only return those latitude labels
      ; that are integer multiples of the latitude increment DLAT,
      ; DLON (unless there are none).
      ;
      ; NORMLATS contains the Normal X and Y coordinates
      ; that are needed for the placement of the latitude labels
      ; Likewise NORMLONS for longitude labels.
      ;
      ; Force the minimum of NORM_LAT to be 0.08 in normal coords
      ;
      ; Make sure that the longitude labels are returned in the
      ; range of -180..180 degrees.
      ;================================================================

      LatLabel = Construct_Map_Labels( Lats, /Latitude, _EXTRA=e )
      NormLats = NormLats[0:1,*]
      ; latitude X coordinates (left map boundary)
      NormLats[0,*] = ( NormLats[0,*] - 0.008 ) > 0.008
      ; latitude Y coordinates
      NormLats[1,*] = NormLats[1,*] - CharHeight/2.
      Ind      = Where( Lats mod DLat eq 0 )
      if ( Ind[0] ge 0 ) then begin
         NormLats = NormLats[*,Ind]
         LatLabel = LatLabel[Ind]
      endif

      LonLabel = Construct_Map_Labels( Lons, /Longitude, _EXTRA=e )
      NormLons = NormLons[0:1,*]
      NormLons[1,*] = NormLons[1,*] - 2.2*CharHeight
      Ind      = Where( Lons mod DLon eq 0 )
      if ( Ind[ 0 ] ge 0 ) then begin
         NormLons = NormLons[*,Ind]
         LonLabel  = LonLabel[Ind]
      endif

      ;**** Debug output (bmy, 3/4/99)
      if ( Debug ) then begin
         print, '### MAP_LABELS : DumLons   : ', DumLats
         print, '### MAP_LABELS : NormLats  : ', NormLats
         print, '### MAP_LABELS : DumLats   : ', DumLats
         print, '### MAP_LABELS : NormLons  : ', NormLons
      endif

   endif else begin

      ;================================================================
      ; If MAPGRID = 0, then just call CONSTRUCT_MAP_LABELS to
      ; compute the lat and lon labels, and then return
      ;
      ; Make sure to return the labels in the range of -180..180 deg
      ;================================================================
      LatLabel = Construct_Map_Labels( Lats, /Latitude,  _EXTRA=e )
      LonLabel = Construct_Map_Labels( Lons, /Longitude, _EXTRA=e )

      NormLats = fltarr(1,1)
      NormLons = fltarr(1,1)
   endelse

   return
end

