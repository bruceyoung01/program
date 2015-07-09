; $Id: example_tvmap.pro,v 1.6 2007/12/03 21:39:21 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EXAMPLE_TVMAP
;
; PURPOSE:
;        Generates several example plots using CTM_PLOT and TVMAP.
;
; CATEGORY:
;        GAMAP Examples, GAMAP Utilities
;
; CALLING SEQUENCE:
;        EXAMPLE_TVMAP [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        /PNG -> Set this switch to save screen output
;             Portable Network Graphics (PNG) format.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ====================================
;        CTM_PLOT     MULTIPANEL
;        MYCT         NYMD2TAU  (function)
;        SCREEN2PNG   TVMAP
;
; REQUIREMENTS:
;        Requires routines from the GAMAP package.
;
; NOTES:
;        None
;
; EXAMPLE:
;        EXAMPLE_TVMAP, /PNG
;             ; Create example plots and save to a PNG file.
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.11
;
;-
; Copyright (C) 2002-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine example_tvmap"
;-----------------------------------------------------------------------


pro Example_TvMap, PNG=PNG, _EXTRA=e

   ;====================================================================
   ; Define variables for use by examples below
   ;====================================================================

   ; Reference external functions
   ;
   FORWARD_FUNCTION Nymd2Tau


   ; Save original colortable in RGB vectors
   TvLct, R, G, B, /Get


   ; Shall we save screen output to PNG format?
   PNG     =  Keyword_Set( PNG )


   ; Ox tracer number
   ;
   Tracer  = 2                 


   ; TAU0 value (hours since 1985) that is used to index the
   ; data block that we will read from the file
   ;
   Tau0    = Nymd2Tau( 20010701 )
   

   ; File name to open.  We will use the FILE_WHICH routine in IDL
   ; to first look in the current directory, and failing that, in
   ; all of the other directories specified in the !PATH variable.
   ;
   ; The EXPAND_PATH function will expand the path from a relative
   ; to an absolute path name (e.g. from ~/IDL/gamap2/data_files to
   ; /users/ctm/bmy/IDL/gamap2/data_files).
   ;
   FileName = File_Which( 'ctm.bpch.examples', /Include_Current_Dir )
   FileName = Expand_Path( FileName )


   ; Load the White-Green-Yellow-Red colortable w/ 9 colors
   MyCt, /WhGrYlRd, NColors=9, /Verbose


   ;====================================================================
   ;                 %%%%% POLAR PLOT EXAMPLES %%%%%
   ; 
   ; In these examples, we call TVMAP via CTM_PLOT.  CTM_PLOT is a
   ; wrapper for the TVMAP (and also TVPLOT) routines.  The difference
   ; is that TVMAP will just plot a data array that is passed to it,
   ; while CTM_PLOT will read in the data for the given tracer from
   ; the given filename, and then pass that information to TVMAP.
   ;====================================================================

   ; Open the X-window device at 600x600 pixels for plotting
   ;
   Open_Device, WinParam=[ 0,  600,  600 ]


   ; Define a plot page with 2 rows & 2 columns 
   ;
   MultiPanel, Rows=2, Cols=2

   ; 1st Panel: Create a "coarse pixel" polar plot of Ox.
   ; The /SAMPLE keyword will cause TVMAP to plot pixel boxes
   ; corresponding to the lon & lat extent of each model grid box.
   ; The COLORBAR_NDIV function ensures that the colorbar tickmarks
   ; will be placed between color gradations on the colorbar.
   ;
   CTM_Plot, 'IJ-AVG-$',                                             $
      FileName=FileName,  Tracer=Tracer, Tau0=Tau0,                  $
      /Sample,            /Isotropic,    /CBar,                      $
      /Grid,              /Continents,   Lon=[-180,180],             $
      Lat=[50.,88],       Lev=1,         Div=ColorBar_NDiv( Max=5 ), $
      /Polar,             Title='POLAR 1 - pixel',                   $
      _EXTRA=e


   ; 2nd panel: Similar to 1st panel, but this time, place a vertical
   ; colorbar.  Also POLAR=2 will cause the map for the entire hemisphere
   ; to be displayed, regardless of what the plot limits are.
   ;
   CTM_Plot, 'IJ-AVG-$',                                             $
      FileName=FileName,  Tracer=Tracer, Tau0=Tau0,                  $
      /Sample,            /Isotropic,    /CBar,                      $
      /Grid,              /Continents,   Lon=[-180,180],             $ 
      Lat=[50., 88.],     Lev=1,         Div=ColorBar_NDiv( Max=5 ), $
      Polar=2,            /CbVertical,   Title='POLAR 2 - pixel',    $
      NoBorder=0,         _EXTRA=e


   ; 3rd panel: Same as 1st panel, but this time create a "smooth"
   ; pixel plot.  This does not have the "boxy" quality of the
   ; coarse pixel plot.
   ;
   CTM_Plot, 'IJ-AVG-$', $
      FileName=FileName, Tracer=Tracer,  Tau0=Tau0,                  $  
      /Isotropic,        /CBar,          /Grid,                      $
      /Continents,       Lon=[-180,180], Lat=[15.,88],               $
      Lev=1,             /Polar,         Div=ColorBar_NDiv( Max=5 ), $
      title='POLAR 1 - smooth pixel',    _EXTRA=e


   ; 4th panel: Similar to 3rd panel, but this time, place a vertical
   ; colorbar.  Also POLAR=2 will cause the map for the entire hemisphere
   ; to be displayed, regardless of what the plot limits are.
   ;
   CTM_Plot, 'IJ-AVG-$', $
      FileName=FileName, Tracer=Tracer,  Tau0=Tau0,                  $
      /Isotropic,        /CBar,          /Grid,                      $
      /continents,       Lon=[-180,180], lat=[15., 88.],             $
      Lev=1,             Polar=2,        Div=ColorBar_NDiv( Max=5 ), $
      title='POLAR 2 - smooth pixel',    /CbVertical,                $
      _extra=e


   ; Save the screen output to PNG format
   ;
   if ( PNG ) then Screen2Png, 'tvmap_page1'


   ; Pause to allow user to look at the screen
   ;
   Pause

   
   ; Cancel previous MULTIPANEL settings
   ;
   MultiPanel, /Off


   ;====================================================================
   ;                 %%%%% LON-LAT MAP EXAMPLES %%%%%
   ; 
   ; In these examples, we call TVMAP via CTM_PLOT.  CTM_PLOT is a
   ; wrapper for the TVMAP (and also TVPLOT) routines.  The difference
   ; is that TVMAP will just plot a data array that is passed to it,
   ; while CTM_PLOT will read in the data for the given tracer from
   ; the given filename, and then pass that information to TVMAP.
   ;====================================================================


   ; Resize the window to 755 x 900 pixels
   ;
   Open_Device, WinParam=[ 0, 755, 900 ]


   ; Set up for 3 rows and 2 columns per page
   ; 
   MultiPanel, rows=3, cols=2


   ; 1st panel: Plot a "coarse pixel" lon-lat plot for the whole globe.
   ; NOTE: Exclude GEOS-Chem half-sized polar boxes.  Uses the default
   ; cylindrical map projection.
   ;
   CTM_Plot, 'IJ-AVG-$',                                            $
      FileName=FileName, Tracer=Tracer, Tau0=Tau0,                  $
      /Sample,           /Isotropic,    /CBar,                      $
      /Grid,             /Continents,   Lon=[-180,180],             $
      Lat=[-88,88],      Lev=1,         Div=ColorBar_NDiv( Max=5 ), $
      title='DEFAULT PLOT',             _EXTRA=e


   ; 2nd panel: Similar to 1st panel, but zoom in onto the
   ; region bounded by corners at (10S,40S) and (40N,160E).
   ;
   CTM_Plot, 'IJ-AVG-$',                                            $
      FileName=FileName, Tracer=Tracer, Tau0=Tau0,                  $
      /Sample,           /Isotropic,    /CBar,                      $
      /Grid,             /Continents,   Lon=[-10,160],              $
      Lat=[-40,40],      Lev=1,         Div=ColorBar_NDiv( Max=5 ), $
      title='DEFAULT PLOT ZOOM',        _EXTRA=e


   ; 3rd panel: Similar to 1st panel, but in this case, use the
   ; Mollweide map projection.  Also suppress X-axis labels
   ; with the /NOGXLABELS keyword.  Use the new /HORIZON feature
   ; to draw a map horizon around the globe, since the Mollweide
   ; map projection is not rectangular.
   ;
   CTM_Plot, 'IJ-AVG-$',                                            $
      FileName=FileName, Tracer=Tracer, Tau0=Tau0,                  $
      /Sample,           /Isotropic,    /CBar,                      $
      /Grid,             /Continents,   Lon=[-180,180],             $
      Lat=[-88.,88],     Lev=1,         Div=ColorBar_NDiv( Max=5 ), $
      title='Mollweide', /Mollweide,    /NoGXLabels,                $
      /Horizon,          _EXTRA=e

   
   ; 4th panel: Similar to 3rd panel, but this time let's plot 
   ; the map across the International Date Line
   ;
   CTM_Plot, 'IJ-AVG-$',                                            $
      FileName=FileName, Tracer=Tracer, Tau0=Tau0,                  $
      /Sample,           /Isotropic,    /CBar,                      $
      /Grid,             /Continents,   Lon=[90,-100],              $
      Lat=[-40.,40],     Lev=1,         Div=ColorBar_NDiv( Max=5 ), $
      /Mollweide,        Rectangle=0,   _EXTRA=e,                   $
      Title='Mollweide ZOOM & across date line - COARSE' 


   ; 5th panel: Similar to 4th panel, but this time create a "smooth"
   ; pixel plot.  The plot doesn't look as boxy as the "coarse" pixel
   ; plot.  
   ;
   CTM_Plot, 'IJ-AVG-$',                                            $
      FileName=FileName, Tracer=Tracer, Tau0=Tau0,                  $
      /Isotropic,        /CBar,         /Grid,                      $
      /continents,       Lon=[90,-100], Lat=[-40,40],               $
      Lev=1,             Rectangle=0,   Div=ColorBar_NDiv( Max=5 ), $
      /Mollweide,        _EXTRA=e,                                  $
      Title='Mollweide ZOOM & across date line - SMOOTH'


   ; 6th panel: Create a plot over the continental US domain,
   ; using the Lambert map projection.   NOTE: The default map
   ; label for CONUS is the IDL Box Axes.
   ;
   CTM_Plot, 'IJ-AVG-$',                                            $
      FileName=FileName, Tracer=Tracer, Tau0=Tau0,                  $
      /Sample,           /Isotropic,    /CBar,                      $
      /Grid,             /Continents,   Lon=[-180,180],             $
      lat=[-88, 88],     Lev=1,         Div=ColorBar_NDiv( Max=5 ), $
      /CONUS,            /CbVertical,   Title='Default CONUS',      $
      _EXTRA=e


   ; Save the screen output to PNG format
   ;
   if ( PNG ) then Screen2Png, 'tvmap_page2'


   ; Pause to allow user to look at the screen
   ;
   Pause

   
   ; Cancel previous MULTIPANEL settings
   ;
   MultiPanel, /Off


   ;====================================================================
   ;            %%%%% EXAMPLES USING TVMAP DIRECTLY %%%%%
   ; 
   ; In these examples, we call TVMAP directly instead of using the
   ; higher-level routine CTM_PLOT.
   ;====================================================================

   ; Select the Blue-Yellow-Red MYCT colortable with 9 colors
   ;
   MyCt, /BuYlRd, Ncolors=9


   ; Create a Random data array
   ;
   Nx   = 3
   Ny   = 3
   Data = RandomN( Seed, Nx, Ny )


   ; Manually create a longitude array
   ; 
   Xarr =  -180. + FIndGen( Nx )*360./Nx
   print,  'Longitudes: ', xarr


   ; Manually create a latitude array
   ; 
   Yarr =  -90. + FIndGen( Ny )*180./Nx + 90./ny
   print,  'Latitudes ', yarr


   ; Open the X-window device at 600x600 pixels for plotting
   ;
   Open_Device, WinParam=[ 0,  600,  600 ]


   ; Create 4 plot s per page
   ;
   MultiPanel, 4


   ; 1st panel: Create a plot passing X and Y arrays
   ;
   TvMap, Data, Xarr, Yarr,                       $
      /Isotropic,  /CBar,  /Grid,                 $
      /continents, Div=ColorBar_NDiv( Max=5 ),    $
      _EXTRA=e,    Title='X/Y set - no Limit'


   ; 2nd panel: Same as above, but don't pass X and Y arrays
   ;
   TvMap, Data,                                   $
      /Isotropic,  /CBar,         /Grid,          $
      /continents, Div=ColorBar_NDiv( Max=5 ),    $
      _EXTRA=e,    Title='no X/Y - no Limit'


   ; 3rd panel: Same as 1st panel, but this time we shall
   ; manually specify the limit via the LIMIT keyword to TVMAP
   ;
   TvMap, Data,  Xarr, Yarr,                      $
      limit=[-10., -20., 40., 120.],              $
      Isotropic=0,    /CBar,         /Grid,       $
      /continents,    Div=ColorBar_NDiv( Max=5 ), $
      _EXTRA=e,       title='X/Y set - Limit'


   ; 4th panel: Same as 2nd panel, but this time we shall
   ; manually specify the limit via the LIMIT keyword to TVMAP
   ;
   TvMap, Data,                                   $
      Limit=[-90., 120., 40., -20.],              $
      /Isotropic,    /CBar,         /Grid,        $
      /continents,   Div=ColorBar_NDiv( Max=5 ),  $
      _EXTRA=e,      title='no X/Y -  Limit'


   ; Save the screen output to PNG format
   ;
   if ( PNG ) then Screen2Png, 'tvmap_page3'


   ; Cancel previous MULTIPANEL settings
   ; 
   MultiPanel, /Off


   ; Restore original colortable
   TvLct, R, G, B

end
