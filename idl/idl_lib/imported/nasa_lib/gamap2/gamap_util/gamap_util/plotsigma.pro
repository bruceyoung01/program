; $Id: plotsigma.pro,v 1.2 2008/05/30 14:02:02 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PLOTSIGMA
;
; PURPOSE:
;        PLOTSIGMA plots the sigma level extent of various CTM's
;        (including GISS-II, GISS-II', GEOS-1, GEOS-STRAT, GEOS-2,
;        and FSU) side by side for comparison.  Useful for making
;        viewgraphs.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Models & Grids
;
; CALLING SEQUENCE:
;        PLOTSIGMA, MODELNAME [, keywords ]
;
; INPUTS:
;        MODELNAME -> A string (or array of strings) containing the 
;             names of the models to be plotted.  Default is [ 'GEOS1' ].
;
; KEYWORD PARAMETERS:
;        /PLEFT -> Will cause pressure to be plotted (with regular
;             spacing) along the left Y-axis.  Default is to plot 
;             altitude (with regular spacing) along the left Y-axis).  
;
;        /PS -> Causes output to be sent to the PostScript Device.
;
;        SURFP -> The surface pressure in mb used to convert sigma
;             levels into absolute pressures.  Default is 1010.
;
;        YRANGE -> Specifies the plotting range [Ymin, Ymax]
;             along the left Y-axis.  Default is [ 0, 32 ] km.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External subroutines required:
;        --------------------------------------------
;        CTM_TYPE   (function)   CTM_GRID (function)
;        USSA_PRESS (function)   USSA_ALT (function)
;        MYCT_DEFAULTS (function) 
;
; REQUIREMENTS:
;        None
;         
; NOTES:
;        None
;        
; EXAMPLE:
;        PLOTSIGMA, /PLEFT, $
;            ['GISS_II', 'GEOS1', 'GEOS_STRAT', 'FSU' ], $
;            YRANGE=[1010, 150], SURFP=1010.0
;
;            ; plots sigma levels for GISS-II, GEOS-1, GEOS-STRAT,
;            ; and FSU models, with pressure on the left Y-axis,
;            ; assuming a surface pressure of 1010 mb, for the range
;            ; of 1010 mb to 150 mb.
;
;        PLOTSIGMA, $
;            ['GISS_II', 'GEOS1', 'GEOS_STRAT', 'FSU' ], $
;            YRANGE=[0, 16], SURFP=1010.0
;
;            ; Same as above, but plots with altitude on left Y-axis,
;            ; and for the range 0 km - 16 km.
;
;
; MODIFICATION HISTORY:
;        bmy, 15 Aug 1997: VERSION 1.00
;        bmy, 30 Oct 1997: VERSION 1.01
;        bmy, 15 Jun 1998: VERSION 1.10
;                          - now uses CTM_TYPE, CTM_GRID
;        bmy, 17 Jun 1998: GAMAP VERSION 1.20
;        bmy, 19 Jun 1998: - add array for color indices
;                          - also supports FSU model
;        bmy, 03 Jan 2000: GAMAP VERSION 1.44
;                          - eliminate call to MYCT and keywords
;                          - cosmetic changes
;        bmy, 06 Sep 2000: GAMAP VERSION 1.46
;                          - added text string for GEOS-3     
;        bmy, 26 Jun 2001: GAMAP VERSION 1.48
;                          - now pass _EXTRA=e to PLOT command
;                          - added extra error checking
;        bmy, 23 Jul 2001: - now use MYCT_DEFAULTS() to set up
;                            MYCT color information
;        bmy, 28 Sep 2002: GAMAP VERSION 1.51
;                          - now gets color information from the 
;                            !MYCT system variable
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Modified for GEOS-4 and GEOS-5
;
;-
; Copyright (C) 1997-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine plotsigma"
;-----------------------------------------------------------------------


pro PlotSigma, ModelName,                    $
               PS=PS,         SurfP=SurfP,   $
               YRange=YRange, PLeft=PLeft,   $
               _EXTRA=e

   ; Pass External Functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, USSA_Alt, USSA_Press

   ; Set Keyword Defaults
   if ( N_Elements( ModelName ) eq 0 ) then ModelName = [ 'GEOS1' ]
   if ( N_Elements( SurfP     ) eq 0 ) then SurfP     = 1010.0
   if ( N_Elements( YRange    ) eq 0 ) then YRange    = [ 0,  31.5 ]

   PLeft = Keyword_Set( PLeft )
   PS    = Keyword_Set( PS    )
 
   ; Color indices and plot keywords
   C_Ind    = [ !MYCT.RED, !MYCT.BLUE, !MYCT.MAGENTA, $
                !MYCT.LIGHTRED, !MYCT.LIGHTGREEN ]
   !P.MULTI = [0, 1, 1, 0, 0]
   LThick   = 3
   XMargin  = [5, 5]
   XRange   = [0, n_elements( ModelName ) ]

   ;====================================================================
   ; If Plotting PRESSURE on the Left AXIS...
   ;====================================================================
   if ( PLeft ) then begin

      ; Pressure values for LEFT AXIS
      YRange1 = YRange
      YTickV1 = [ 1000, 900, 800, 700, 600, 500, 400, $
                   300, 200, 150, 100,  50,  10 ]
      Ind     = where( YTickV1 le YRange[0] and $
                       YTickV1 ge YRange[1], C )
      if ( C gt 0 ) then YTickV1 = YTickV1[Ind]

      YTicks1 = N_elements( YTickV1 ) - 1
      YMinor1 = 4
      YTitle1 = 'Pressure (mb)'
      
      ; Altitude values for RIGHT axis.  Define Altitude values for
      ; tickmarks, but convert them to Pressures so that they can be
      ; plotted by the AXIS command.   Also, each tick will be relabeled
      ; with the correct pressure value.
      YRange2 = YRange1 
      Alt     = [  0,  2,  4,  6,  8, 10, 12, 14, $
                  16, 18, 20, 22, 24, 26, 28, 30 ]
      YTickN  = strtrim( string( Alt ), 2 )
      YTickV2 = USSA_Press( Alt )
      YTicks2 = n_elements( YTickV2 )
      YMinor2 = 2
      YTitle2 = 'Altitude (km)'

   ;====================================================================
   ; If Plotting ALTITUDE on the Left AXIS...
   ;====================================================================
   endif else begin

      YRange1 = YRange

      YTickV1 = [  0,  2,  4,  6,  8, 10, 12, 14, 16, 18, 20, $
                  22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 45, $
                  50, 55, 60, 65, 70, 75, 80, 85, 90 ]

      Ind     = where( YTickV1 ge YRange[0] and $
                       YTickV1 le YRange[1], C )
      if ( C gt 0 ) then YTickV1 = YTickV1[Ind]

      YTicks1 = N_elements( YTickV1 ) - 1
      YMinor1 = 2
      YTitle1 = 'Altitude (km)'

      ; Pressure values for RIGHT axis.  Define Pressure values for
      ; tickmarks, but convert them tbo Altitudes so that they can be
      ; plotted by the AXIS command.  Also, each tick will be relabeled
      ; with the correct pressure value.
      YRange2 = YRange1
      Press   = [ 1000, 900, 800, 700, 600, 500, 400, 300, 250, $
                   200, 150, 100,  75,  50,  40,  30,  20,  10, $
                     1,  0.5, 0.1, 0.05, 0.01 ]
      YTickN  = strtrim( string( Press ), 2 )
      YTickV2 = USSA_Alt( Press )
      YTicks2 = n_elements( YTickV2 ) - 1
      YMinor2 = 4
      YTitle2 = 'Pressure (mb)'

   endelse

   ;====================================================================
   ; Open the X window or the PS device and establish plot coordinates
   ;====================================================================
   Open_Device, PS=PS, /Color, Bits=8, _EXTRA=e

   Plot, XRange, YRange1, /NoData,                                     $
      XRange=XRange,          XStyle=1,          XTicks=1,             $
      XTickName=[ ' ', ' ' ], XMargin=XMargin,                         $       
      YRange=YRange1,         YStyle=8,          YTicks=YTicks1,       $
      YTickV=YtickV1,         YMinor=YMinor1,    YTitle=YTitle1,       $
      YTick_Get=YTickG,       Color=!MYCT.BLACK, Title='Sigma Levels', $
      _EXTRA=e

   ;====================================================================
   ; Loop over each model
   ;====================================================================
   NMax = n_elements( ModelName )

   for N = 0, NMax - 1 do begin
      MInfo = CTM_Type( ModelName(N), PSurf=SurfP )
      GInfo = CTM_Grid( MInfo )
      
      ;### debug
      ;print
      ;for II=0, MInfo.NLAYERS do begin
      ;   print, II, GInfo.PEDGE(II)
      ;endfor

      ; X-vector for the sigma levels
      X = [ N + 0.2, N + 0.8 ]

      ; If Pressure is being plotted on the right axis...
      if ( PLeft ) then begin

         ; Get pressure edges...
         Ind = where( GInfo.PEDGE le YRange[0] and $
                      Ginfo.PEDGE ge YRange[1], EE )
         if ( EE gt 0 ) then Edge = GInfo.PEDGE[Ind]

         ; And pressure centers...
         Ind = where( GInfo.PMID  le YRange[0] and $
                      Ginfo.PMID  ge YRange[1], CC )
         if ( CC gt 0 ) then Center = GInfo.PMID[Ind]

      endif else begin
         
         ; Otherwise, get altitude edges...
         Ind = where( GInfo.ZEDGE ge YRange[0] and $
                      Ginfo.ZEDGE le YRange[1], EE )
         if ( EE gt 0 ) then Edge = GInfo.ZEDGE[Ind]

         ; And altitude centers
         Ind = where( GInfo.ZMID  ge YRange[0] and $
                      Ginfo.ZMID  le YRange[1], CC )
         if ( CC gt 0 ) then Center = GInfo.ZMID[Ind]

      endelse

      ; Color index for the lines (= BLACK if using B&W colortable)
      ; Skip yellow (color 3) and turquoise (color 7) since they 
      ; don't plot very well.
      ;case ( ColorTable ) of 
      ;   0    : LColor = BLACK
      ;   else : LColor = C_Ind[ N mod n_elements( C_Ind ) ]
      ;endcase                                   
 
      LColor = C_Ind[ N mod n_elements( C_Ind ) ]

      ;=================================================================
      ; Loop over the sigma levels
      ;=================================================================
      for L = 0, CC-1 do begin
                 
         ; If edge is the tropopheric top, plot it as a thick black 
         ; line.  Otherwise plot it with the normal color & thickness.

         if ( L le N_Elements( Edge ) -1L ) then begin
            ;------------------------------------------------
            ;if ( L eq MInfo.NTROP ) then begin
            ;   oplot, X, [ Edge(L), Edge(L) ], Line=0, $
            ;      Thick=5, Color=!MYCT.BLACK
            ;endif else begin
            ;------------------------------------------------
               oplot, X, [ Edge(L), Edge(L) ], Line=0, $
                  Thick=LThick, Color=LColor
            ;------------------------------------------------
            ;endelse
            ;------------------------------------------------
         endif

         ; Plot the sigma center as a dotted line
         oplot, X, [ Center(L), Center(L) ], Line=1, $
            Thick=LThick, Color=LColor
      endfor

      ; Plot the last edge (if necessary)
      if ( EE ne CC ) then begin
         oplot, X, [ Edge(EE-1), Edge(EE-1) ], $
            Line=0, Thick=LThick, Color=LColor
      endif

      ;=================================================================
      ; Plot the model names
      ;=================================================================

      ; X and Y Coords in DATA Space
      Xd = [ N + 0.1, N + 0.9 ]
      Yd = [ 0.0, 0.0 ]

      ; Convert X-coords to NORMAL space
      Xn = Convert_Coord( Xd, Yd, /Data, /To_Normal )

      ; Make Xn a vector (since CONVERT_COORD returns an array!)
      Xn = [ Xn[0, 0], Xn[0, 1] ]

      ; Y-Coordinates in Normal Space
      Yn = [ 0.89, 0.93 ]
      
      ; Convert X-normal and Y-normal coords back to Data Space
      Xy = Convert_Coord( Xn, Yn, /Normal, /To_Data )

      ; X1 contains X-Data coords...these are Xy[ 0, * ]
      ; Y1 contains Y-Data coords...these are Xy[ 1, * ]
      X1 = [ Xy[0, 0], Xy[0, 1], Xy[0, 1], Xy[0, 0], Xy[0, 0] ]
      Y1 = [ Xy[1, 0], Xy[1, 0], Xy[1, 1], Xy[1, 1], Xy[1, 0] ]

      ; Make the plot area white
      PolyFill, X1, Y1, Color=!MYCT.WHITE, /Data
      
      ; Plot a black border around the white area
      PlotS, X1, Y1, Color=!MYCT.BLACK, /Data
      
      ; Coordinates for the text string
      Xc = ( Xy[0, 1] + Xy[0, 0] ) / 2.0
      Yc = ( Xy[1, 1] + Xy[1, 0] ) / 2.0 - 0.07
 
      ; Define a "prettier" text string for printing
      case ( Minfo.NAME ) of 
         'GCAP'          : Text = "GCAP"
         'GISS_II'       : Text = "GISS-II"
         'GISS_II_PRIME' : Text = "GISS-II-Prime"
         'GEOS1'         : Text = "GEOS-1"
         'GEOS2'         : Text = "GEOS-2"
         'GEOS_STRAT'    : Text = "GEOS-STRAT"
         'GEOS3'         : Text = "GEOS-3"
         'GEOS4'         : Text = "GEOS-4"
         'GEOS5'         : Text = "GEOS-5"
         'FSU'           : Text = "FSU"
         else            : Text = "GENERIC"
      endcase

      ; Default CHARSIZE = 1.0
      ; Set CHARSIZE = 0.9 if there are more than 4 plots on the page
      CharSize = 1.0 - ( 0.1 * ( Nmax gt 4 ) )
 
      ; Plot the text!!!!!
      XYOutS, Xc, Yc, Text, Color=!MYCT.BLACK, $
         /Data, Align=0.5, CharSize=CharSize

      ; Replot the major tick marks of the 
      ; left axis in between the sigma levels 
      if ( N ne NMax - 1 ) then begin
         X = [ N + 0.95, N + 1.05 ]
         for L=0, YTicks1 do begin
            oplot, X, [ YTickG(L), YTickG(L) ], Line=0, $
               Color=!MYCT.BLACK, Thick=1
         endfor
      endif

   endfor

   ;====================================================================
   ;  Plot the Right Axis
   ;====================================================================
   Axis, YAxis=1,        YTicks=YTicks2,    YMinor=YMinor2, $
         YTickV=YTickV2, YTickName=YTickN,  Yrange=YRange1, $
         YTitle=YTitle2,  /YStyle,          /Data,          $
         Color=!MYCT.BLACK  

   ;====================================================================
   ;  Close device and quit
   ;====================================================================
print_n_quit:

   Close_Device, _EXTRA=e
      
end
 
