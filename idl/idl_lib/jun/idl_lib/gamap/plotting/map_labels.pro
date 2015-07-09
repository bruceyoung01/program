; $Id: map_labels.pro,v 1.2 2008/03/24 14:51:19 bmy Exp $
;-----------------------------------------------------------------------
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
;        Plotting
;
; CALLING SEQUENCE:
;        MAP_LABELS, LATLABEL, LONLABEL [ , Keywords ]
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
;            Can also be use as input: if LATS has one element, the
;            LATS vector is build with LATS+n*DLAT; if it has more
;            than one element, it is not modified and is the final
;            grid.
;
;        DLAT, DLON -> Returns to the calling program the latitude
;            (longitude) interval between grid lines.
;            Now, can also be used as input so the user can specify
;            the grid spacing.
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
;        Internal Subroutines Used:
;        =================================
;        CONSTRUCT_MAP_LABELS (function)
;        GET_GRIDSPACING
;
;        External Subroutines Required:
;        =================================
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
; EXAMPLES:
;        (1) For use in conjunction with the PLOT command...
;
;         MAP_LABELS, YTICKNAME, XTICKNAME,           $    ; Call MAP_LABELS
;            LATRANGE=[ -90,90], LONRANGE=[-180,180], $    ; to get the
;            LATS=LATS,          LONS=XTICKV,         $    ; lat and lon
;            _EXTRA=e                                      ; tick labels
;
;         PLOT, XARR, YARR, XTICKV=XTICKV,            $    ; call PLOT,
;             XTICKNAME=XTICKNAME,                    $    ; using the
;             XTICKS=N_ELEMENTS( XTICKV )-1,          $    ; labels as
;             _EXTRA=e                                     ; tick names
;
;
;        (2) For use in conjunction with MAP_SET and MAP_GRID
;
;        LIMIT    = [ -90, -180, 90, 180 ]                 ; set up the
;        MAP_SET, LIMIT=Limit, _EXTRA=e                    ; world map
;
;        LATRANGE = [ Limit[0], Limit[2] ]                 ; define lat and
;        LONRANGE = [ Limit[1], Limit[3] ]                 ; lon ranges
;
;        MAP_LABELS, LATLABEL,    LONLABEL,            $   ; call MAP_LABELS
;           LATS=LATS,            LATRANGE=LATRANGE,   $   ; to return
;           LONS=LONS,            LONRANGE=LONRANGE,   $   ; the lat/lon
;           NORMLATS=NORMLATS,    NORMLONS=NORMLONS,   $   ; values, labels
;           /MAPGRID,             _EXTRA=e                 ; normal coordinates
;
;        MAP_GRID, LATS=LATS, LONS=LONS, _EXTRA=e
;            ; Plots the grid lines on the map
;
;        XYOUTS, NORMLATS[0,*], NORMLATS[1,*], $
;           LATLABEL, ALIGN=1.0, /NORMAL
;            ; Plots latitude labels using normal coordinates
;
;        XYOUTS, NORMLONS[0,*], NORMLONS[1,*], $
;            LONLABEL, ALIGN=0.5, /NORMAL
;            ; Plots longitude labels using normal coordinates
;
;
;        (2) For use in conjunction with TVMAP to control grid
;     
;        TVMAP, DIST(42)
;
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
;  mgs & bmy, 03 Jun 1999: - fix for Pacific ranges in GET_GRIDSPACING
;        bmy, 17 Nov 2005: GAMAP VERSION 2.04
;                          - Now allows for a spacing of 1 degree
;                            if the plot range is smaller or equal to
;                            10 degrees
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        phs, 29 Feb 2008: GAMAP VERSION 2.12
;                          - Grid spacing can be set by user with
;                            DLON and DLAT
;                          - LONS/LATS can be use as input to specify
;                            the start (if 1 element) or the entire
;                            grid (more than 1 element)
;                          - GET_GRIDSPACING is now a procedure
;        phs, 14 Mar 2008: - Added a new method to find the Labels
;                            position. This can be used to overwrite
;                            the old position with two new keywords,
;                            NEWLONLAB and NEWLATLAB. Useful for map
;                            projection defined with SCALE instead
;                            of LIMIT. Need to pass MapPosition to work.
;
;-
; Copyright (C) 1999-2008, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine map_labels"
;-----------------------------------------------------------------------

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

pro find_labels_pos, LL, MapPosition=MapPosition, longitudes=longitudes, $
                     normlls=normlls, labels=Labels

   debug = 0

   ;===================================================================
   ; New Method to get normal position of labels
   ; Used only if the NewLonLab or NewLatLab kwrd is used when
   ; calling Map_Labels (phs, 3/10/08)
   ;
   ; LL           (input)   : vector of longitude or latitude that 
   ;                           could be labelled
   ; MapPosition  (input)   : map position in normal coordinates
   ; longitudes (keyword)   : set to tell we are dealing w/ longitudes
   ; Normlls (input/output) : normal location of the labels
   ; Labels  (input/output) : the labels themselves
   ;===================================================================

   ; check if user has called MAP_LABELS w/ NewLonLab or NewLatLab but
   ; forget the Map_Position
   if ( N_Elements( MapPosition ) ne 4 ) then begin
      message, /info,  'Map Position missing for positioning labels.' + $
               ' Returning.....'
      return
   endif


   ; make a copy of LL for manipulation, and make sure that it is in
   ; the [-180., +180] range
   LLin = LL
   toobig = where(LL gt 180., count)
   if count gt 0 then LLin[toobig] -= 360.

   ; debug
   if ( Debug ) then begin
      print, '### MAP_LABELS : LL      : ', LL
      print, '### MAP_LABELS : normlls : ', normlls
   endif
   

   ; X or Y axis 
   longi = keyword_set(longitudes)
   if longi then begin
      kx = 0
      ky = 1
   endif else begin
      kx = 1
      ky = 0
   endelse

   ; Define the point along one border of the map in data coordinates
   PossibleNormPosX = MapPosition[kx] + $
                      findgen(1001) * ( MapPosition[kx+2] - MapPosition[kx] )/1000.
   PossibleNormPosY = fltarr(1001) + MapPosition[ky]

   PossibleDataPos = longi ? $
                     Convert_Coord( PossibleNormPosX, PossibleNormPosY, $
                                    /NOrm, /To_data ) : $
                     Convert_Coord( PossibleNormPosY, PossibleNormPosx, $
                                    /NOrm, /To_data )
                     
   ; and see which one of the input is inside
   aa = PossibleDataPos[kx, 0]
   bb = PossibleDataPos[kx, 1000]

   If aa gt bb then $
      ; this case of over the date line for lon.
      inside = where(LLin ge aa or LLin le bb, count) $

   else inside = where(LLin ge aa and LLin le bb, count, $
                       ncomplement=nc, complement=badguys)
   

   ; for those inside
   if count ne 0 then begin

      ; assign positions
      for i=0l, count-1l do begin
         index = inside[i]
         dummy = min( LLin[index] - PossibleDataPos[kx,*], WhereMin, /abs)

         NormLLs[0, index] = longi ? PossibleNormPosX[WHereMin]: $
                                PossibleNormPosY[WHereMin]

         NormLLs[1, index] = longi ? PossibleNormPosY[WHereMin]: $
                                PossibleNormPosX[WHereMin]
      endfor

      ; trim, i.e. disregard others
      NormLLs = NormLLs[*,inside]
      Labels = Labels[inside]

   ; no label for those outside
   endif else labels[*] = ''


   ; Debug output 
   if ( Debug ) then begin
      print, '### MAP_LABELS : normlls #2 : '
      print,  normlls
   endif

   return
end

;----------------------------------------------------------------------------

pro get_gridspacing, INgrid=ingrid, range,delta=delta,n=n, Scale=Scale

   ;===================================================================
   ; Procedure GET_GRIDSPACING returns 5, 10, 15, 30 depending on
   ; the input range (mgs, 2/99).
   ; 
   ; NOTES: 
   ; (1) Made it a procedure. Added input/output INGRID. 
   ;      DELTA can be input now. (phs, 2/29/08)
   ;===================================================================

   ; If RANGE[0] > RANGE[1] then this is a Pacific range that
   ; straddles the date line.  Add 360 to RANGE[1] so that RANGE[1]
   ; will be greater than RANGE[0].
   if ( range[0] gt range[1] ) then range[1] = range[1] + 360.

   dist = range[1]-range[0]

   ; delta is now output and input (phs, 2/28/08)
   if ( N_Elements( Delta ) eq 0 ) then begin

      if (dist gt 150.) then delta = 30. $
      else if (dist gt 80.) then delta = 15. $
      else if (dist gt 45.) then delta = 10. $
      else if (dist le 10.) then delta = 1.  $  ; (bmy, 11/17/05)
      else delta = 5.

   endif
   
   ; Multiply the DELTA spacing by SCALE (bmy, 3/25/99)
   if ( N_Elements( Scale ) gt 0 ) then Delta = Delta * Scale

   ; set up mega grid and truncate to actual range
   ; range shouldn't exceed -180 or +720 in any case
   ; therefore we start with a grid of 900/5 = 150 entries

   ; new for using LATS/LONS as input if wanted (phs, 2/29/08)
   case n_elements( Ingrid ) of
      0    : grid = findgen(500)*delta - 180.
      1    : grid = findgen(500)*delta + float(Ingrid[0])
      else : grid = float(ingrid)
   endcase


   keep = where(grid ge range[0] AND grid le range[1])
   if (keep[0] eq -1) then begin
      message,'Invalid parameters for grid??',/INFO
      keep = [ 0,1 ]
   endif

   ingrid = grid[keep]
   n = n_elements(keep)

;---------------------
; Prior to 2/29/08:
;   return,grid
;---------------------
end

;----------------------------------------------------------------------------

pro Map_Labels, LatLabel, LonLabel,                                $
                DLat=DLat,                DLon=DLon,               $
                Lats=Lats,                LatRange=LatRange,       $
                Lons=Lons,                LonRange=LonRange,       $
                NormLons=NormLons,        NormLats=NormLats,       $
                MapGrid=MapGrid,          Debug=Debug,             $
                MapPosition=MapPosition,  NewLonLab=NewLonLab,     $
                NewLatLab=NewLatLab,      _EXTRA=e

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
   scaleIt = n_elements( DLon ) le 0

   ;===================================================================
   ; GET_GRIDSPACING returns the latitudes to be labeled.
   ;===================================================================
   Get_GridSpacing, InGrid=Lats, LatRange, N=NLat, Delta=DLat

   ;===================================================================
   ; GET_GRIDSPACING returns the longitudes to be labeled.
   ;
   ; If LONRANGE[0] > LONRANGE[1] then we are straddling the date
   ; line, so call CONVERT_LON to convert LONRANGE into the range
   ; 0..360 degrees.
   ;
   ; Increase spacing between grid lines if more than one panel is
   ; plotted per page. Unless user specified DLon (phs).
   ;===================================================================
   if ( LonRange[0] gt LonRange[1] ) then Convert_Lon, LonRange, /Pacific

   Scale_DLon = 1.
   if ( !P.MULTI[1] * !P.MULTI[2] gt 1 ) then Scale_DLon += scaleIt

   Get_GridSpacing, LonRange, N=NLon, Delta=DLon, Scale=Scale_DLon, ingrid=lons

   ; Debug output (bmy, 3/4/99)
   if ( Debug ) then begin
      print, '### MAP_LABELS : Lats      : ', Lats
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

      NLat = N_Elements(lats)
      NLon = N_Elements(lons)

      ;================================================================
      ; CONSTRUCT_MAP_LABELS will return the labels to be plotted
      ; next to each grid line.
      ;================================================================
      LatLabel = Construct_Map_Labels( Lats, /Latitude, _EXTRA=e )
      LonLabel = Construct_Map_Labels( Lons, /Longitude, _EXTRA=e )

      ;================================================================
      ; Compute normal coordinates of each grid line
      ;================================================================
      ; make sure a map projection is active
      if (!MAP.projection eq 0) then map_set, Position=MapPosition

      ; Note: these labels are not necessarily nice with all
      ; projections...
      DumLats  = FltArr( N_Elements( Lons ) ) + LatRange[0]
      DumLons  = FltArr( N_Elements( Lats ) ) + Lon0
      NormLats = Convert_Coord( DumLons, Lats,    /Data, /To_Normal )
      NormLons = Convert_Coord( Lons,    DumLats, /Data, /To_Normal )

      ; ...so we try something else using the Map Position (phs, 3/14/08)
      if ( Keyword_Set( NewLonLab ) ) then begin         
         Normlons[*] = -1
         Find_Labels_Pos, Lons, MapPosition=MapPosition, /longi, $
                          normlls=NormLons, labels=LonLabel
      endif

      if ( Keyword_Set( NewLatLab ) ) then begin
         Normlats[*] = -1
         Find_Labels_Pos, Lats, MapPosition=MapPosition, $
                          normlls=NormLats, labels=LatLabel
      endif


      ;================================================================
      ; Estimated character height
      ;================================================================
      CharHeight = 0.010

      ;================================================================
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

; Moved above (phs)
;      LatLabel = Construct_Map_Labels( Lats, /Latitude, _EXTRA=e )

      NormLats = NormLats[0:1,*]

      ; latitude X coordinates (left map boundary)
      NormLats[0,*] = ( NormLats[0,*] - 0.008 ) > 0.008

      ; latitude Y coordinates
      NormLats[1,*] = NormLats[1,*] - CharHeight/2.

;--- commented out for now. Should account for LATS[0] or all LATS
;    if they are specified in input.  (phs, 2/29/08)
;      Ind      = Where( Lats mod DLat eq 0 )
;      if ( Ind[0] ge 0 ) then begin
;      	print,'sub lat'
;         NormLats = NormLats[*,Ind]
;         LatLabel = LatLabel[Ind]
;      endif
;--- instead use the following:

      ; do not label first and last grid lines not part of the grid
      ; that is, map limit is not aligned with the grid (phs,)
      if ( not Keyword_Set( NewLatLab ) ) then begin
         if abs( lats[1]-lats[0]          ) ne dlat then Latlabel[0] = ' '
         if abs( lats[Nlat-1]-lats[nlat-2]) ne dlat then Latlabel[Nlat-1] = ' '
      endif

; Moved above (phs)
;      LonLabel = Construct_Map_Labels( Lons, /Longitude, _EXTRA=e )

      NormLons = NormLons[0:1,*]
      NormLons[1,*] = NormLons[1,*] - 2.2*CharHeight

;--- commented out for now. Should account for lon[0]. (phs, 2/29/08)
;     Ind      = Where( Lons mod DLon eq 0 )
;     if ( Ind[ 0 ] ge 0 ) then begin
;       print,'sub lon'
;        NormLons = NormLons[*,Ind]
;        LonLabel  = LonLabel[Ind]
;     endif
;--- instead use the following:

      ; do not label first and last grid lines not part of the grid
      ; that is, map limit is not aligned with the grid (phs,)
      if ( not Keyword_Set( NewLonLab ) ) then begin
         if abs(lons[1]-lons[0]          ) ne dlon then lonlabel[0] = ' '
         if abs(lons[Nlon-1]-lons[nlon-2]) ne dlon then lonlabel[Nlon-1] = ' '
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


   ; Debug output (bmy, 3/4/99)
   if ( Debug ) then begin
      print, '### MAP_LABELS : Lats      : ', Lats
      print, '### MAP_LABELS : Lons      : ', Lons
   endif

   return
end

