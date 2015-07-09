; $Id: arrowmap.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ARROWMAP
;
; PURPOSE:
;        Plots a vector field atop a world map.
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        ARROWMAP, U, V, X, Y [, Keywords ]
;
; INPUTS:
;        U, V -> The X and Y components of the two-dimensional vector
;             field.  U and V must be two-dimensional arrays.
;
;             The vector at point (i,j) has a magnitude of:             
;             
;                       ( U(i,j)^2 + V(i,j)^2 )^0.5             
;             
;             and a direction of:             
;             
;                       ATAN2( V(i,j), U(i,j) ).             
;             
;        X, Y -> Longitude (X) and latitude (Y) values corresponding to 
;             the U and V arrays.  X must be a vector with a length equal 
;             to the 1st dimension of U and V.  Y must be a vector
;             with length equal to the 2nd dimension of U and V.
;
; KEYWORD PARAMETERS:
;        UNIT -> String containing the units for the plot legend.
;             Default is '' (the null string).
;
;        FORMAT -> Format string for the arrow legend.  Default
;             is '(f10.3)'.
;
;        TITLE -> Top title for the map panel.  
;             Default is '' (the null string).
;
;        CSFAC -> Character size for the map labels and X, Y titles. 
;             Default settings for CSFAC vary according to the number 
;             of plots per page and type of plot device.
;
;        TCSFAC -> Character size for the top title.  Default
;             settings for TCSFAC vary according to the number 
;             of plots per page and type of plot device.
;
;        _EXTRA=e -> Picks up extra keywords (not listed below) for
;             ARROW, MAP_SET, MAP_GRID, MAP_CONTINENTS, VELOCITY_FIELD.
;
;    Keywords for MAP_SET:
;    =====================
;        MPARAM -> A 3 element vector containing values for
;             [ P0Lat, P0Lon, Rot ].  Default is [ 0, 0, 0 ].
;             Elements not specified are automatically set to zero.
;
;             NOTE: If X contains positive longitudes (i.e. in the 
;             range 0-360), then set MPARAM = [0, 180, 0].  This will
;             ensure that the map is displayed correctly.
;
;        LIMIT -> A four-element vector which specifies the latitude
;             and longitude extent of the map.  The elements of LIMIT
;             are arranged thus: [ LatMin, LonMin, LatMax, LonMax ].
;             Default is to set LIMIT = [ -90, -180, 90, 180 ] (i.e.
;             to include the entire globe). P0Lon will be computed
;             to fit into the LIMIT range unless it is explicitely
;             requested in MParam.
;
;             If LIMIT is not passed explicitly, then LIMIT will be
;             computed from the maximum and minimum values of the 
;             X and Y vectors.
;
;        COLOR -> Color index of the map outline and flow vectors.
;             Defaults is 1 (MYCT black color).
;
;        /POLAR -> Plot a polar stereographic projection. 
;             NOTE: Polar is not yet supported (bmy, 5/26/00)
;
;        POSITION -> A four-element array of normalized coordinates
;             that specifies the location of the map.  POSITION has
;             the same form as the POSITION keyword on a plot.
;             Default is [0.0, 0.15, 1.0, 1.0].
;
;        MARGIN -> specify a margin around the plot in normalized 
;            coordinates. This keyword does not change any IDL
;            system variables and will thus only become "visible" 
;            if you use the POSITION returned by MULTIPANEL in
;            subsequent plot commands.  MARGIN can either be one value 
;            which will be applied to all four margins, or a 2-element 
;            vector which results in equal values for the left and
;            right and equal values for the bottom and top margins, 
;            or a 4-element vector with [left,bottom,right,top].  The
;            default MARGIN setting is [ 0.05, 0.04, 0.03, 0.07 ].
;
;        /ISOTROPIC  -> If set, will produce a map with the same scale
;             in the X and Y directions.  Default is not to plot an
;             isotropic-scale map. Note, however, that if TVMAP is 
;             called from CTM_PLOT, the default is to plot a map that
;             keeps the aspect ratio (which is about the same as 
;             isotropic).
;
;
;    Keywords for MAP_CONTINENTS:
;    ============================
;        /CONTINENTS -> If set, will call MAP_CONTINENTS to plot
;             continent outlines or filled boundaries.  Default is 0.
;
;        CCOLOR -> The color index of the continent outline or fill
;             region.  Default is 1 (MYCT black color).
;
;        CFILL -> Value passed to FILL_CONTINENTS keyword of MAP_CONTINENTS.
;             If CFILL=1 then will fill continents with a solid color
;             (as specified in CCOLOR above).  If CFILL=2 then will fill
;             continents with hatching.
;
;    Keywords for MAP_GRID:
;    ======================
;        /GRID -> If set, will call MAP_GRID to plot grid lines and
;             labels.  Default is NOT to plot grid lines and labels.
;
;        GCOLOR -> The color index of the grid lines. Default is
;             BLACK (see above).
;
;    Keywords for VELOCITY_FIELD:
;    ============================
;        ACOLOR -> Specifies the color of the arrows.  Default is black.
; 
;        HSIZE -> The length of the lines used to draw the arrowhead.
;             If HSIZE is positive, then the arrow head will be the
;             same regardless of the length of each vector.  (Default
;             size is !D.X_SIZE / 100).  If HSIZE is negative, then
;             the arrowhead will be 1/HSIZEth of the total arrow length.
;
;        THICK -> Thickness factor for the arrows.  Default is 2.0.
;
;        MAXMAG -> Returns to the calling program the magnitude of the
;             longest vector. 
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =====================================
;        MULTIPANEL   MYCT_DEFAULTS (function)
;        MAP_LABELS   VELOCITY_FIELD
;
; REQUIREMENTS:
;        References routines from GAMAP and TOOLS packages.
;
; NOTES:
;        (1) The U and V arrays may contain either CTM winds or 
;            flux quantities.  However, when plotting fluxes, it is 
;            STRONGLY RECOMMENDED that you double-check the units of
;            U and V before passing them to ARROWMAP.  Some unit 
;            conversion may be required in order to display fluxes
;            properly.
;
;        (2) If your map spans the date line, then do the following:
;
;              (a) Make sure that your longitudes are in the range 
;                  0 - 360 degrees
;
;              (b) Call ARROWMAP with MPARAM=[0,180,0] in order to 
;                  have MAP_SET accept longitudes in the range 0-360.
;
; EXAMPLE:
;        ARROWMAP, U, V, X, Y, $
;            /GRID, /CONTINENTS, THICK=3, CFILL=2, GCOLOR=1, UNIT='m/s'
;
;            ; Plots a vector flow pattern over a world map.  Continents 
;            ; are filled to a solid red color (assuming a MYCT colortable).  
;            ; Arrows have a thickness factor of 3.
;
; MODIFICATION HISTORY:
;        bmy, 26 May 2000: GAMAP VERSION 1.45
;        bmy, 24 Jul 2000: GAMAP VERSION 1.46
;                          - added X_STEP, Y_STEP, and MAXMAG keywords
;                          - now print the longest vector as the arrow
;                            legend below the plot.  
;                          - added MARGIN keyword for MULTIPANEL 
;                          - added ISOTROPIC keyword for MAP_SET
;        bmy, 23 Jul 2002: GAMAP VERSION 1.51
;                          - now default HSIZE to a device pixel length
;                          - added LEGENDLEN keyword
;                          - now call VELOCITY_FIELD using new LEGENDLEN,
;                            LEGENDNORM, and LEGENDMAG keywords
;                          - Now use MYCT_DEFAULTS for default BLACK
;                          - added COUNTRIES and COASTS keywords
;                          - removed HANGLE keyword -- it's obsolete!
;                          - renamed ARRLEN to LEGENDNORM
;                          - renamed MAXMAG to LEGENDMAG
;        bmy, 28 Sep 2002: - Now reference MYCT colors from the !MYCT
;                            system variable
;
;-
; Copyright (C) 2000, 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine arrowmap"
;-----------------------------------------------------------------------


pro ArrowMap, U, V, X, Y,                                   $
              Unit=Unit,             Format=FFormat,        $
              Title=TTitle,          CsFac=CsFac,           $
              TCsFac=TCsFac,         MParam=MParam,         $
              Limit=Limit,           Color=MColor,          $  
              Polar=Polar,           Position=MPosition,    $
              Margin=Margin,         Continents=Continents, $ 
              CColor=CColor,         CFill=CFill,           $
              IsoTropic=IsoTropic,   Grid=Grid,             $
              GColor=GColor,         HSize=HSize,           $
              Thick=Thick,           AColor=AColor,         $
              LegendLen=LegendLen,   LegendMag=LegendMag,   $
              Countries=Countries,   Coasts=Coasts,         $
              _EXTRA=e

   ; External Functions
   FORWARD_FUNCTION MyCt_Defaults

   ;====================================================================
   ; Error checking / parameters
   ;====================================================================
 
   ; Sizes of the U, V, X, Y arrays
   Su = Size( U, /Dim )
   Sv = Size( V, /Dim )
   Sx = Size( X, /Dim )
   Sy = Size( Y, /Dim )
 
   ; U must a be a 2-D array
   if ( N_Elements( Su ) ne 2 ) then begin
      Message, 'U must be a 2-D array!', /Continue
      return
   endif
 
   ; V must be a 2-D array
   if ( N_Elements( Sv ) ne 2 ) then begin
      Message, 'V must be a 2-D array!', /Continue
      return
   endif
 
   ; X must be a 1-D vector
   if ( N_Elements( Sx ) ne 1 ) then begin
      Message, 'X must be a 1-D vector!', /Continue
      return
   endif
 
   ; Y must be a 1-D vector
   if ( N_Elements( Sy ) ne 1 ) then begin
      Message, 'Y must be a 1-D vector!', /Continue
      return
   endif
 
   ; Make Sx and Sy into scalars for convenience
   Sx = Sx[0]
   Sy = Sy[0]
 
   ; U and V arrays must conform to each other in longitude
   if ( Su[0] ne Sv[0] ) then begin
      Message, 'U and V do not have the same number of longitude elements!', $
         /Continue
      return
   endif
 
   ; U and V arrays must conform to each other in latitude
   if ( Su[1] ne Sv[1] ) then begin
      Message, 'U and V do not have the same number of latitude elements!', $
         /Continue
      return
   endif
      
   ; X must have the same # of elements as the 1st dim of U
   if ( Sx ne Su[0] ) then begin
      Message, 'X is incompatible with the longitude dimension of U and V!', $
         /Continue
      return
   endif
     
   ; YARR must have the same # of elements as the 2nd dim of DATA
   if ( Sy ne Sv[1] ) then begin
      Message, 'Y is incompatible with the latitude dimension of U and V!', $
         /Continue
      return
   endif
 
   ; Determine NPANELS = number of plots per page
   NPanels = !P.Multi[1] * !P.Multi[2]

   ;====================================================================
   ; Error checking / keywords
   ;====================================================================
 
   ; Default settings for LIMIT
   if ( N_Elements( Limit ) eq 0 ) then begin
 
      ; If XMID and YARR are passed, use them to determine LIMIT
      if ( N_Elements( X ) gt 3 AND N_Elements( Y ) gt 3 ) then begin
 
         ; Compute the 1/2 width of a grid box in X and Y
         ; Do not consider polar boxes since they could be half-size 
         HalfX = 0.5 * ( X[3] - X[2] )
         HalfY = 0.5 * ( Y[3] - Y[2] )
 
         ; XMID, YARR are box centers, so subtract or add HALFX 
         ; and HALFY to get box edges, which define the limit
         Limit = [ ( Y[0]    - HalfY ) > ( -90.0 ),  $
                   ( X[0]    - HalfX ),              $
                   ( Y[Sy-1] + HalfY ) < (  90.0 ),  $
                   ( X[Sx-1] + HalfX ) ]
      endif $
 
      ; Otherwise use the default limit for the entire globe
      else begin
         Limit = [ -90, -180, 90, 180 ]
      endelse
   endif
 
   ; Set P0LON from MPARAM or LIMIT
   if ( N_Elements( MParam ) ge 2 )      $
      then P0Lon = MParam[1]             $
      else P0Lon = total( LIMIT[ [1,3] ] ) / 2. ; make sure it's at 
                                                ; the map center
 
   ; Only take the first 3 elements of MPARAM if it's passed
   ; Otherwise set MPARAM to [0,0,0]
   if ( N_Elements( MParam ) eq 0 )       $
      then MParam = [ 0,0,0 ]             $
      else MParam = ([Mparam,0,0,0])[0:2]
 
   ; Set P0LAT and ROT from MPARAM 
   P0Lat = Mparam[0]
   Rot   = MParam[2]
 
   ; Default for MPOSITION
   PSOffset = 0.02
   if ( N_Elements( MPosition ) eq 0 ) then begin
      MPosition = [ 0.0, 0.15 + PSOffset, 1.0, 1.0 ]  
   endif else begin
      Print,'% ARROWMAP: Position passed: ',MPosition
   endelse
 
   ; Default value for TCSFAC -- title character size
   if ( N_Elements( TCsFac ) eq 0 ) then TCsFac = 1.2

   ; Default value for CSFAC -- character size
   if ( N_Elements( CsFac ) eq 0 ) then begin
      CsFac = 1.0
      if ( NPanels gt   1  ) then CsFac = 0.9
      if ( NPanels gt   4  ) then CsFac = 0.75
      if ( NPanels gt   9  ) then CsFac = 0.6
      if ( !D.name ne 'PS' ) then CsFac = CsFac * 1.2
   endif

   ; Other keyword defaults
   Continents = Keyword_Set( Continents )
   Countries  = Keyword_Set( Countries  )
   Coasts     = Keyword_Set( Coasts     )
   Grid       = Keyword_Set( Grid       )
   Polar      = Keyword_Set( Polar      )
   IsoTropic  = Keyword_Set( IsoTropic  )

   if ( N_Elements( AColor  ) ne 1 ) then AColor  = !MYCT.BLACK
   if ( N_Elements( CColor  ) ne 1 ) then CColor  = !MYCT.BLACK
   if ( N_Elements( CFill   ) ne 1 ) then CFill   = 0
   if ( N_Elements( HAngle  ) ne 1 ) then HAngle  = 30.0
   if ( N_Elements( HSize   ) ne 1 ) then HSize   = !D.X_SIZE / 100
   if ( N_Elements( GColor  ) ne 1 ) then GColor  = !MYCT.BLACK
   if ( N_Elements( MColor  ) ne 1 ) then MColor  = !MYCT.BLACK
   if ( N_Elements( TTitle  ) ne 1 ) then TTitle  = ''
   if ( N_Elements( Unit    ) ne 1 ) then Unit    = ''
   if ( N_Elements( FFormat ) ne 1 ) then FFormat = '(f10.3)'

   ;====================================================================
   ; Calculate true window position from POSITION and MPOSITION
   ;====================================================================   
   if ( N_Elements( Margin ) eq 0 ) then Margin = [ 0.05, 0.04, 0.03, 0.07 ]
   MultiPanel, Position=position, Margin=Margin
 
   ; get width of plot window
   Wx = ( Position[2] - Position[0] )
   Wy = ( Position[3] - Position[1] )
 
   ; Scale the relative MPOSITION values to the actual 
   ; screen position as given by POSITION
   MPosition[0] = Position[0] + ( Wx * MPosition[0] )
   MPosition[1] = Position[1] + ( Wy * MPosition[1] )
   MPosition[2] = Position[0] + ( Wx * MPosition[2] )
   MPosition[3] = Position[1] + ( Wy * MPosition[3] )

   ;====================================================================
   ; Draw the map!
   ;====================================================================
   Map_Set, P0lat, P0Lon, Rot, Position=MPosition,             $
      Continents=0,        Grid=0,       /NoErase,             $
      /NoBorder,           XMargin=0,    YMargin=0,            $
      Color=MColor,        Limit=Limit,  StereoGraphic=Polar,  $
      IsoTropic=IsoTropic, _EXTRA=e 
 
   ; Call MAP_CONTINENTS to plot (or fill in) the continents
   if ( Continents OR Countries OR Coasts ) then begin
      Map_Continents, Color=CColor, Fill=CFill, $
         Countries=Countries, Coasts=Coasts, _EXTRA=e
   endif

   ;====================================================================
   ; If /GRID is set, then call MAP_LABELS to construct the latitude 
   ; and longitude labels for each grid line, and also the normalized 
   ; coordinates (NORM_XLAT, NORM_YLAT, NORM_XLON, and NORM_YLON) 
   ; that will be used to plot the labels.  
   ; 
   ; Also call MAP_GRID to plot the grid lines, and print the labels 
   ; next to each grid line.
   ;====================================================================
   if ( Grid ) then begin
      LatRange = [ Limit[0], Limit[2] ]
      LonRange = [ Limit[1], Limit[3] ]
 
      Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e
 
      ;=================================================================
      ; For Polar plots, do the following:
      ; (1) Only keep the 0-degree longitude label
      ; (2) If the latitude range spans more than 60 degrees,
      ;     just use print out labels for [30, 60, 90] degrees.
      ;=================================================================
      if ( Polar ) then begin
         OKInd = Where( StrPos( LonLabel, '0' ) eq 0 )
         ; print,'####',lonlabel,format='(20(A,"::"))'
         if ( OKInd[0] ge 0 ) then begin
            LonLabel = LonLabel[ OKInd ]
            NormLons = NormLons[ *, OKInd ]
         endif
            
         if ( Min( Abs( Latrange ) ) lt 30 ) then begin
            OKInd = Where( StrPos( LatLabel, '30' ) ge 0 OR $
                           StrPos( LatLabel, '60' ) ge 0 OR $               
                           StrPos( LatLabel, '90' ) ge 0 )
 
            ; print,'####',latlabel,format='(20(A,"::"))'
            if ( OKInd[0] ge 0 ) then begin
               LatLabel = LatLabel[ OKInd ]
               NormLats = NormLats[ *, OKInd ]
            endif
         endif
      endif
 
      ; Print latitude labels
      XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
         Align=1.0, Color=GColor, /Normal, CharSize=CsFac 
 
      ; Print longitude labels
      XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
         Align=0.5, Color=GColor, /Normal, CharSize=CsFac
 
      ; Print grid lines
      Map_Grid, Color=GColor, Lats=Lats, Lons=Lons, _EXTRA=e
   endif
 
   ;====================================================================
   ; Call VELOCITY_FIELD to draw the arrows over the map
   ;====================================================================
   Velocity_Field, U, V, X, Y,                                         $
      Color=AColor,        HSize=HSize,         Thick=Thick,           $
      LegendLen=LegendLen, LegendMag=LegendMag, LegendNorm=LegendNorm, $
      _EXTRA=e

   ;====================================================================
   ; Draw a solid border around the map
   ;====================================================================
   NewPosition = [ !X.Window[0], !Y.Window[0], $
                   !X.Window[1], !Y.Window[1] ]
 
   Rectangle, NewPosition, XPoints, YPoints
   PlotS, XPoints, YPoints, Thick=2, Color=1, /Normal
   
   ;====================================================================
   ; Print top title
   ;====================================================================
   XpMid = ( !X.Window[1] + !X.Window[0] ) / 2.0

   ; Place a little higher, for carriage return lines (bmy, 3/25/99)
   if ( NPanels lt 2 )                   $
      then YpTop = !Y.Window[1] + 0.025  $
      else YpTop = !Y.Window[1] + 0.030

      ; place title yet higher if it has two lines
   if ( StrPos( TTitle,'!C' ) ge 0 ) then begin
      if ( NPanels le 4 )          $
         then YpTop = YpTop + 0.02 $
         else YpTop = YpTop + 0.01
   endif

   ; Plot title
   XYouts, XpMid, YpTop, Ttitle,$
      Color=MColor, /Normal, Align=0.5, CharSize=TCsFac*CsFac
   
   ;====================================================================
   ; Print the legend arrow below the map with the unit string
   ;====================================================================
   X0 = NewPosition[0]
   X1 = NewPosition[0] + LegendNorm
   Y0 = NewPosition[1] - 0.05
   Y1 = Y0
 
   ; Print the default arrow
   Arrow, X0 + 0.05, Y0, X1 + 0.05, Y1, $
      /Normal, Color=MColor, Hsize=HSize, Thick=Thick, _EXTRA=e
 
   ; Define & print the legend text
   Str = StrTrim( String( LegendMag, Format=FFormat ), 2 ) + ' ' + $
         StrTrim( Unit, 2 )
 
   XYOutS, X1 + 0.06, Y0 - 0.005, Str, $
      Color=MColor, /Normal, _EXTRA=e
 
   ;====================================================================
   ; Advance to next MULTIPANEL frame
   ;====================================================================
   MultiPanel, /Advance, /NoErase
end
 
 
