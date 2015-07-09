; $Id: tvmap.pro,v 1.4 2004/06/03 17:58:11 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        TVMAP
;
; PURPOSE:
;        TVMAP produces one of the following plots:
;          (1) A color-pixel image,   overlaid with a world map
;          (2) A line-contour plot,   overlaid with a world map
;          (3) A filled-contour plot, overlaid with a world map
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        TVMAP, Data, [ Xarr, YArr [ [, keywords ] ]
;
; INPUTS:
;        DATA -> 2-D array of values to be plotted as a color map.
;             The first dimension is longitude, the second is latitude.
;
;        XARR, YARR -> If plotting a line-contour map or filled-contour map,
;             then XARR is the array of X-axis values, and YARR is the
;             array of Y-Axis values that are needed to construct the
;             the contours.  XARR and YARR are not needed to produce a
;             color-pixel image map; however, if XARR and YARR are
;             passed, TVMAP will be able to label the longitude and
;             latitude lines accordingly and set the proper default limits.
;
; KEYWORD PARAMETERS:
;        BLACK -> The color index corresponding to black.
;             Default is !MYCT.BLACK.
;
;        MIN_VALID -> minimum valid dat value for color-pixel plots.  
;             Data below MIN_VALID will be shown in white.
;
;        /ERASE -> If set, will erase the graphics device before plotting
;             the color image (or contour plot) and world map.
;
;        CSFAC -> Character size for the map labels and X, Y titles. 
;             Default settings for CSFAC vary according to the number 
;             of plots per page and type of plot device.
;
;        TCSFAC -> Character size for the top title.  Default
;             settings for TCSFAC vary according to the number 
;             of plots per page and type of plot device.
;
;        /NOADVANCE -> Set this switch to prevent TVMAP from advancing
;             to the next plot panel on the page.  This is useful if
;             you desire to overplot something atop the pixel map or
;             contour map.
;
;        _EXTRA=e -> Picks up extra keywords (not listed below) for
;             BYTSCL, COLORBAR, TVIMAGE, MAP_SET, MAP_GRID,
;             MAP_CONTINENTS, and CONTOUR.
;
;    Keywords passed to both BYTSCL and COLORBAR:
;    ============================================
;        MAXDATA -> Maximum value of the DATA array to use in the
;             byte scaling.  Default is max( DATA ).
;
;        MINDATA -> Minimum value of the DATA array to use in the
;             byte scaling.  Default is min( DATA ).
;
;        BOTTOM -> The lowest color index of the colors to be used
;             for byte-scaling the color map and colorbar.  Default
;             is 20 (or !D.N_COLORS-1 if 20 is too large).
;
;        NCOLORS -> This is the maximum color index that will be used.
;             Default is 120 (or !D.N_COLORS-BOTTOM, if 120 is too large).
;
;        /LOG -> Will create a color-pixel plot with logarithmic
;             scaling.  /LOG has no effect on line-contour or
;             filled-contour plots, since the default contour levels
;             are quasi-logarithmic.
;
;
;    Additional keywords passed to COLORBAR:
;    =======================================
;        /CBAR -> If set, will plot the colorbar below the map in the
;             position specified by CBPOSITION.  Default is to NOT
;             plot a colorbar.
;
;        CBCOLOR -> Color index of the colorbar outline and
;             characters.  Defaults to BLACK (see above).
;
;        CBPOSITION -> A four-element array of normalized coordinates
;             that specifies the location of the colorbar.  CBPOSITION
;             has the same form as the POSITION keyword on a plot.
;             Default is [0.1, 0.05, 0.9, 0.08].
;
;        CBUNIT -> Passes the Unit string to COLORBAR, which will be
;             plotted to the right of the color bar.
;
;        CBFORMAT -> format to use in call to colorbar. Default is I12
;             if abs(max(data)) < 1e4, else e12.2 (strings get trimmed)
;
;        CBMIN, CBMAX -> Explicitly sets the min and max values of
;             the colorbar range.  If not set, TVMAP will set 
;             CBMIN = min( DATA ) and CBMAX = max( DATA ).
;
;        CBTICKLEN -> Specifies the color bar tick length as a
;             fraction of the colorbar height (for horizontal
;             colorbars) or width (for vertical colorbars).
; 
;        DIVISIONS -> Number of labels for the colorbar.  Default is 4.
;
;    Keywords passed to TVIMAGE:
;    ===========================
;        KEEP_ASPECT_RATIO: -> Normally, the image will be resized to fit
;             the specified position in the window. If you prefer, you can
;             force the image to maintain its aspect ratio in the window
;             (although not its natural size) by setting this keyword.
;             The image width is fitted first. If, after setting the
;             image width, the image height is too big for the window,
;             then the image height is fitted into the window. The
;             appropriate values of the POSITION keyword are honored
;             during this fitting process. Once a fit is made, the
;             POSITION coordiates are re-calculated to center the image
;             in the window. You can recover these new position coordinates
;             as the output from the POSITION keyword.
;
;             NOTE: KEEP_ASPECT_RATIO is automatically switched on
;             if /ISOTROPIC is turned on.  This is necessary in order
;             to preserve the correct scaling of the image.
;
;    Keywords passed to MAP_SET:
;    ===========================
;        COLOR -> Color index of the map outline and title characters.
;             Defaults to BLACK (see above).
;
;        MPARAM -> A 3 element vector containing values for
;             [ P0Lat, P0Lon, Rot ].  Default is [ 0, 0, 0 ].
;             Elements not specified are automatically set to zero.
;
;        /ISOTROPIC  -> If set, will produce a map with the same scale
;             in the X and Y directions.  Default is not to plot an
;             isotropic-scale map. Note, however, that if TVMAP is 
;             called from CTM_PLOT, the default is to plot a map that
;             keeps the aspect ratio (which is about the same as 
;             isotropic).
;
;        LIMIT -> A four-element vector which specifies the latitude
;             and longitude extent of the map.  The elements of LIMIT
;             are arranged thus: [ LatMin, LonMin, LatMax, LonMax ].
;             Default is to set LIMIT = [ -90, -180, 90, 180 ] (i.e.
;             to include the entire globe). P0Lon will be computed
;             to fit into the LIMIT range unless it is explicitely
;             requested in MParam.
;
;        /POLAR -> Plot a polar stereographic projection. Note that
;             setting the /STEREOGRAPHIC keyword wouldn't work.
;             POLAR does not support pixel plots!
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
;        OMARGIN -> specify a page margin around all panels in normalized
;            coordinates. Works like MARGIN.
;
;        TITLE -> The title string that is to be placed atop the
;             plot window.  TITLE is passed explicitly to avoid keyword
;             name duplication in the _EXTRA=e facility.
;
;    Keywords passed to MAP_CONTINENTS:
;    ==================================
;        /CONTINENTS -> If set, will call MAP_CONTINENTS to plot
;             continent outlines or filled boundaries.  Default is 0.
;
;        /COUNTRIES -> If set, will call MAP_CONTINENTS to draw the
;             political boundaries of countries as of 1993.  
; 
;        /COASTS -> If set, will call MAP_CONTINENTS to draw the coast
;             lines of continental regions.
;
;        CCOLOR -> The color index of the continent outline or fill
;             region.  Default is BLACK (see above).
;
;        CFILL -> Value passed to FILL_CONTINENTS keyword of MAP_CONTINENTS.
;             If CFILL=1 then will fill continents with a solid color
;             (as specified in CCOLOR above).  If CFILL=2 then will fill
;             continents with hatching.
;
;    Keywords passed to MAP_GRID:
;    ============================
;        /GRID -> If set, will call MAP_GRID to plot grid lines and
;             labels. Labels can be turned off with /NOGLABELS.
;             Default is _not_ to plot grid lines.
;
;        GCOLOR -> The color index of the grid lines. Default is
;             BLACK (see above).
;
;        /NOGXLABELS -> If set, TVMAP will suppress printing longitude
;             labels for each grid line.
;
;        /NOGYLABELS -> If set, TVMAP will suppress printing latitude
;             labels for each grid line.
;
;    Keywords passed to CONTOUR:
;    ===========================
;        /CONTOUR -> Will produce a line-contour map instead of the
;             default color-pixel image map.
;
;        /FCONTOUR -> Will produce a filled-contour map instead
;             of the default color-pixel image map.
;
;        C_LEVELS -> Vector containing the contour levels.  If not
;             specified, will use preset default levels.
;
;        C_ANNOTATION -> Vector containing the contour labels.
;             Default is to use string representations of C_LEVELS.
;
;        C_FORMAT -> Format string used in converting C_LEVELS to
;             the default C_ANNOTATION values.  Default is '(f8.1)'.
;
;        C_COLORS -> Index array of color levels for contour lines or
;             fill regions.  If not specified then will use uniformly
;             spaced default color levels.  If C_COLORS is set to a
;             scalar value, then all contour lines will have the same
;             color value.
;
;        C_LABELS -> Specifies which contour levels should be labeled.
;             By default, every other contour level is labeled.  C_LABELS
;             allows you to override this default and explicitly
;             specify the levels to label. This parameter is a vector,
;             converted to integer type if necessary.  If the LEVELS
;             keyword is specified, the elements of C_LABELS
;             correspond directly to the levels specified, otherwise,
;             they correspond to the default levels chosen by the
;             CONTOUR procedure. Setting an element of the vector to
;             zero causes that contour label to not be labeled.  A
;             nonzero value forces labeling.
;
;        /C_LINES -> Will overplot a filled-contour map with contour lines
;             and labels instead of plotting a colorbar. This was the old
;             default behaviour but has been changed with the advent of
;             "discrete" colorbars. The old NOLINES keyword is kept
;             for compatibility reasons but doesn't do anything.
;
;        /NOLABELS -> Will suppress printing contour labels on both
;             line-contour and filled-contour maps.
;
;        OVERLAYCOLOR -> Color of the solid lines that will be
;             overlaid atop a filled contour map.  Default is BLACK.
;
;    Keywords passed to REBIN:
;    =========================
;        /SAMPLE -> Used to rebin the byte-scaled image array to a
;             larger size, for the PostScript printer.   If /SAMPLE is
;             set, then REBIN will use nearest-neighbor sampling
;             rather than bilinear interpolation.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External subroutines required:
;        ------------------------------
;        COLORBAR          ( by Martin Schultz & David Fanning )
;        TVIMAGE           ( by David Fanning                  )
;        RECTANGLE         ( by Martin Schultz                 )
;        CONVERT_LON       ( by Martin Schultz                 )
;        INV_INDEX         ( function, by Martin Schultz       )
;        MAP_LABELS        ( by Martin Schultz & Bob Yantosca  )
;        LOGLEVELS         ( by Martin Schultz                 )
;        GET_DEFAULTFORMAT ( by Martin Schultz                 )
;        MYCT_DEFAULTS     ( by Bob Yantosca                   )
;
; REQUIREMENTS:
;        Assumes that a MYCT colortable has been loaded.
;
; NOTES:
;        (1) The _EXTRA facility now picks up keywords for multiple
;        routines (this is a new feature in IDL v. 5.0+!!)
;
;        (2) Some keywords are saved in local variables with
;        slightly different names (e.g. MCONTOUR for /CONTOUR)
;        to prevent confusion with routine names and/or keywords
;        that are picked up by the _EXTRA=e facility.
;
;        (4) At present, TVMAP can only do a Cylindrical map over
;        pixel plots, since TVIMAGE plots contain an integral number
;        of pixels.  Later on we will implement a modified algorithm
;        to plot an arbitrary map projection. Note that contour plots
;        can be used with any projection.
;
;        (5) For contour plots, contour labels will be specified
;        using the C_ANNOTATION keyword.  The downside is that
;        by using C_ANNOTATION, this disables the C_LABELS keyword
;        and so one cannot specify which contour lines will get
;        labels.  The solution would be to expand the C_LABELS
;        vector so that it has the same number of elements as
;        C_ANNOTATION, and then to individually zero the
;        corresponding elements of C_ANNOTATION before making
;        the contour plot.  Don't have enough time for this now,
;        but maybe can deal with this at a later time...
;
;        (6) Now references the !MYCT system variable.  This should
;        be defined at the start of your IDL session when "myct.pro" 
;        is called from "idl_startup.pro".
;
; EXAMPLE:
;        (1)
;        MAXDATA = MAX( DATA, MIN=MINDATA )
;        TVMAP, DATA, XMID, YMID,                                  $
;               MAXDATA=MAXDATA, MINDATA=MINDATA, CBUNIT='v/v',    $  
;               /CBAR,           DIVISIONS=4,     FORMAT='(F6.2)', $
;               /CONTINENTS,     /GRID,           /ISOTROPIC
;               /SAMPLE,         TITLE='O3 at 10 km'
;
;        (2)
;        MAXDATA = MAX( DATA, MIN=MINDATA )
;        TVMAP, DATA, XMID, YMID,                                  $
;               MAXDATA=MAXDATA, MINDATA=MINDATA, CBUNIT='v/v',    $  
;               /CBAR,           DIVISIONS=4,     FORMAT='(F6.2)', $
;               /CONTINENTS,     /GRID,           /ISOTROPIC
;               TITLE='O3 at 10 km'
;
;             ; Plots a 2-D "smooth" pixel map.
;
;        (3)
;        MAXDATA = MAX( DATA, MIN=MINDATA )
;        TVMAP, DATA, XMID, YMID,                                  $
;               MAXDATA=MAXDATA, MINDATA=MINDATA, CBUNIT='v/v',    $  
;               /CBAR,           DIVISIONS=4,     FORMAT='(F6.2)', $
;               /CONTINENTS,     /GRID,           /ISOTROPIC       $
;               /FCONTOUR,       TITLE='O3 at 10 km',              $
;               C_LEVELS=[10,20,30,40,50,60,70,80,90,100]
;
;             ; Plots a 2-D filled contour map.
;
;        (4)
;        MAXDATA = MAX( DATA, MIN=MINDATA )
;        TVMAP, DATA, XMID, YMID,                                  $
;               MAXDATA=MAXDATA, MINDATA=MINDATA, CBUNIT='v/v',    $  
;               /CBAR,           DIVISIONS=4,     FORMAT='(F6.2)', $
;               /CONTINENTS,     /GRID,           /ISOTROPIC       $
;               /FCONTOUR,       TITLE='O3 at 10 km',              $
;               C_LEVELS=[10,20,30,40,50,60,70,80,90,100],         $
;               /NOGXLABELS,     /NOGYLABELS,     /BOX_AXES
;
;             ; Same as Example (3), but prints prints box-style
;             ; axes via the /BOX_AXES feature of MAP_GRID.
;
; MODIFICATION HISTORY:
;        bmy, 13 Apr 1998: VERSION 1.00
;        bmy, 11 Jun 1998: - now returns if there is
;                            nothing to plot
;        mgs, 15 Jun 1998: - bug fix: n_elements instead of
;                            keyword_set
;        bmy, 22 Sep 1998: VERSION 1.10
;                          - Now use _EXTRA=e to pass keywords to
;                            BYTSCL, TVIMAGE, MAP_SET, and COLORBAR
;                          - added MAPTITLE and UNIT keywords to
;                            avoid keyword name duplication in
;                            _EXTRA=e.
;        bmy, 25 Sep 1998: VERSION 2.00
;                          - now calls MAP_CONTINENTS and MAP_GRID
;                          - keywords renamed for consistency
;                          - reduced default size for CBPOSITION
;        bmy, 28 Sep 1998: VERSION 2.01
;                          - MPOSITION renamed to POSITION, MCOLOR to
;                            COLOR, MTITLE to TITLE for consistency
;                          - LONSHIFT renamed to LSHIFT to avoid
;                            problems with ambiguous keyword names
;        bmy, 07 Sep 1998: VERSION 3.00
;                          - now can plot contour map or color-pixel
;                            map (added CONTOUR and FCONTOUR keywords,
;                            and XARR and YARR parameters)
;                          - The colorbar is now optional, and is
;                            turned on via the /COLORBAR switch.
;        bmy, 12 Nov 1998: VERSION 3.01
;                          - added ISOTROPIC, SAMPLE, KEEP_ASPECT_RATIO,
;                            C_LABELS, and C_FORMAT keywords
;                          - now isotropic-scale color-image plots
;                            and isotropic-scale contour plots are
;                            handled correctly
;                          - Use mgs-style default levels & colors for
;                            contour and filled-contour maps.
;        bmy, 13 Nov 1998: - updated comments
;                          - renamed C_LEVELS to C_ANNOTATION to
;                            prevent keyword name confusion
;                          - added NOLINES, NOLABELS, C_LABELS,
;                            and OVERLAYCOLOR keywords
;                          - contour lines and labels can be
;                            suppressed correctly
;                          - added mgs fix so that PostScript
;                            pixel-maps appear smoother
;                          - a border is now plotted around the
;                            map window, without inserting any of that
;                            annoying "cushion" space.
;                          - added LOG keyword for logarithmic
;                            contours and/or pixel colors
;                          - use KEYWORD_SET more often
;        mgs, 17 Nov 1998: - re-arranged calls to map_set and tvimage
;                            in order to maximize size
;                          - output of title now seperate from map_set
;                          - added CBFormat keyword
;        mgs, 19 Nov 1998: - CBFormat now handled in colorbar.pro
;        mgs, 20 Nov 1998: - bug fix for map_set for contour plots
;        mgs, 03 Dec 1998: - filled continents now added before contours
;                          - CFILL keyword checked for consistency
;        bmy, 08 Feb 1999: - If /LOG is set, make sure that we don't
;                            take the log of zero and incur a math error
;                          - add call to function INV_INDEX
;        bmy, 23 Feb 1999: - added /GLABELS keyword to turn on/off printing
;                            of labels for each grid line on the map
;                          - added call to CONVERT_LON for longitudes
;                            that straddle the date line
;        bmy, 26 Feb 1999: - added LIMIT as an explicit keyword
;                          - now uses MAP_LABELS to construct grid labels
;                          - updated comments
;        bmy, 04 Mar 1999: - added DEBUG keyword for debug output
;        mgs, 17 Mar 1999: - some cleaning:
;                          - LSHIFT, DLON, and GLABELS made obsolete
;                          - new keyword NOGLABELS
;                          - P0Lon now computed from LIMIT information.
;                          - Updated call to map_labels
;                          - For contour plots: XArr, YArr no longer
;                            mandatory (although they should be provided)
;                          - much smarter default contour levels
;        mgs, 22 Mar 1999: - added multi-panel ability through use of
;                            the new MULTIPANEL routine. This alters the
;                            meaning of MPosition and CB_Position: they now
;                            refer to positions in the current plot panel!
;        mgs, 23 Mar 1999: - fixed a few minor things
;                          - charsize is now adjusted according to number
;                            of panels on page
;        bmy, 25 Mar 1999: - If CBAR=0, then print unit string below
;                            plot (formerly was done in CTM_PLOT)
;                          - now use updated GET_DEFAULTFORMAT
;                          - updated comments
;                          - if NPANELS >=2 then place the plot title
;                            higher above the window, to allow for
;                            carriage-returned lines
;        mgs, 23 Apr 1999: - added CBMin and CBMax keywords for 
;                            tighter colorbar control
;        mgs, 19 May 1999: - title shifted a little higher if it has
;                            more than 1 line.
;  bmy & mgs, 26 May 1999: - added POLAR keyword and respective support.
;        bmy, 27 May 1999: - bug fix for isotropic contour plots
;        mgs, 27 May 1999: - added support for discrete colorbars and
;                            changed default behaviour for filled
;                            contour plots: now plots a colorbar and
;                            no lines.
;        bmy, 03 Jun 1999: - For polar plots, if the latitude range
;                            spans more than 60 degrees, only plot
;                            labels for [ 30, 60, 90 ] degrees.
;        mgs, 03 Jun 1999: - CFill now also allowed for filled contours
;                            or pixel plots (data will be overplotted)
;        bmy, 09 Jun 1999: - Set CBUnit to '' if nothing passed
;        bmy, 21 Jun 1999: - Added MIN_VALID keyword.
;        bmy, 06 Jul 1999: - bug fix for min_valid: ge replaces gt.
;        bmy, 07 Jul 1999: - Save C_COLORS in a temp variable.  Also
;                            define C_COLORS so that grayscales won't
;                            appear in Postscript plots
;                          - multi-panel plots are now well-separated
;                            from each other (for PostScript output)
;        bmy, 08 Jul 1999: - more minor fixes
;        bmy, 18 Nov 1999: - increase default left margin by a little
;        bmy, 31 Mar 2000: GAMAP VERSION 1.45
;                          - make CSFAC and TITLECSFAC into keywords
;        bmy, 10 May 2000: - make sure XARR and YARR (if passed) are 1D vectors
;                          - now use XARR, YARR to set default limits
;                          - rearranged keyword settings code for clarity
;                          - added more debug output (when /DEBUG is set)
;        bmy, 26 May 2000: - updated comments
;        bmy, 13 Jun 2000: - added /COUNTRIES and /COASTS keywords.
;                            Setting /COUNTRIES, /COASTS, or /CONTINENTS
;                            will now invoke routine MAP_CONTINENTS
;        bmy, 30 Jan 2001: GAMAP VERSION 1.47
;                          - if NOGLABELS=0 and GRID=0, will print out
;                            grid labels w/o printing out grid lines
;                          - added MARGIN keyword for MULTIPANEL 
;                          - also allow coarse plots with /SAMPLE
;                            when using the Z-buffer device
;        bmy, 07 Jun 2001: - removed some obsolete code & comments
;        bmy, 02 Jul 2001: GAMAP VERSION 1.48
;                          - added /NOGXLABELS and /NOGYLABELS keywords
;                            to suppress printing either lon or lat
;                            grid labels, if so desired.
;        bmy, 13 Jul 2001: - bug fix: remove _EXTRA=e from MAP_SET call
;                            when making pixel plots.  This prevents extra
;                            grid lines from being drawn on the map.
;        bmy, 23 Jul 2001: - now call MYCT_DEFAULTS to specify default
;                            values for BLACK, BOTTOM, NCOLORS, etc
;                            if these keywords are not passed explicitly.
;        bmy, 31 Oct 2001: GAMAP VERSION 1.49
;                          - add /NOADVANCE keyword to prevent advancing
;                            to the next page (in case you want to overplot)
;        bmy, 08 May 2002: GAMAP VERSION 1.50
;                          - If the data array has more than 100,000 elements,
;                            then assign it a dithering factor of 1, so that 
;                            we don't run out of memory when trying to plot it
;        bmy, 20 Jun 2002: GAMAP VERSION 1.51
;                          - added WINDOWPOSITION keyword to return
;                            the position vector of the plot window
;                            region to the calling program
;        bmy, 28 Sep 2002: - now gets MYCT default parameters from the
;                            !MYCT system variable
;        bmy, 10 Oct 2002: - bug fix: MCOLOR=!MYCT.BLACK setting has
;                            now been restored (was left commented out)
;        bmy, 14 Nov 2002: GAMAP VERSION 1.52
;                          - If GLABELS=0, then this also sets GXLABELS=0
;                            and GYLABELS=0.
;                          - Removed obsolete keywords
;                          - Removed reference to MYCT_DEFAULTS.
;        bmy, 02 Mar 2004: GAMAP VERSION 2.02
;                          - added OMARGIN keyword so that we can put
;                            an outer margin around all plot panels
;        bmy, 28 May 2004: - Now returns the modified value of
;                            C_COLORS to the calling program
;                          - added CBTICKLEN keyword to specify the
;                            color bar tick length  
;
;-
; Copyright (C) 1998 - 2004, 
; Bob Yantosca and Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine tvmap"
;-------------------------------------------------------------


pro rjpmap, Data, XArr, YArr,                                               $
           BLACK=BLACK,               Erase=Erase,                         $
           MaxData=MaxData,           MinData=MinData,                     $
           NColors=NColors,           Bottom=Bottom,                       $
           Log=Log,                                                        $
           CBar=CBar,                 CBPosition=CBPosition,               $
           CBColor=CBColor,           CBUnit=CBUnit,                       $
           Divisions=Divisions,       CBFormat=CBFormat,                   $
           CBMin=CBMin,               CBMax=CBMax,                         $
           CBTickLen=CBTickLen,       Keep_Aspect_Ratio=Keep_Aspect_Ratio, $
           Color=MColor,              MParam=MParam,                       $
           Title=MTitle,              Position=MPosition,                  $
           Isotropic=Isotropic,       Sample=Sample,                       $
           Limit=Limit,               Margin=Margin,                       $
           OMargin=OMargin,           Continents=Continents,               $
           Countries=Countries,       Coasts=Coasts,                       $
           CColor=CColor,             CFill=CFill,                         $
           Grid=Grid,                 GColor=GColor,                       $
           NoGXLabels=NoGXLabels,     NoGYLabels=NoGYLabels,               $
           Contour=MContour,          FContour=FContour,                   $
           C_Levels=C_Levels,         C_Colors=C_Colors,                   $
           C_Annotation=C_Annotation, C_Format=C_Format,                   $
           C_Labels=C_Labels,         C_Lines=C_Lines,                     $
           NoLabels=NoLabels,         OverLayColor=OverLayColor,           $
           Polar=Polar,               Min_Valid=Min_Valid,                 $
           CsFac=CsFac,               TCsFac=TitleCsFac,                   $
           NoAdvance=NoAdvance,       WindowPosition=WindowPosition,       $
           Charthick=Charthick,                                            $
           _EXTRA=e                                              

   ;====================================================================
   ; Pass external functions (bmy, 2/25/99)
   ;====================================================================
   FORWARD_FUNCTION Inv_Index, LogLevels, Get_DefaultFormat

   ;====================================================================
   ; Error Checking: Arguments
   ;====================================================================
   SData = Size( reform(Data), /Dimensions )
   if ( N_Elements(SData) ne 2 ) then begin
      Message, 'DATA must be a 2-D array!!!', /Continue
      return
   endif

   ; Error check for XARR (bmy, 5/10/00)
   if ( N_Elements( XArr ) gt 0 ) then begin
      SXArr = Size( XArr, /Dimensions )

      ; XARR must be a 1-D vector
      if ( N_Elements( SXArr ) ne 1 ) then begin
         Message, 'XARR must be a 1-D vector!', /Continue
         return
      endif
     
      ; XARR must have the same # of elements as the 1st dim of DATA
      SXArr = SXArr[0]
      if ( SXArr ne SData[0] ) then begin
         Message, 'XARR is not compatible with DATA!', /Continue
         return
      endif
   endif

   ; Error check for YARR (bmy, 5/10/00)
   if ( N_Elements( YArr ) gt 0 ) then begin
      SYArr = Size( YArr, /Dimensions )

      ; YARR must be a 1-D vector
      if ( N_Elements( SYArr ) ne 1 ) then begin
         Message, 'YARR must be a 1-D vector!', /Continue
         return
      endif
     
      ; YARR must have the same # of elements as the 2nd dim of DATA
      SYArr = SYArr[0]
      if ( SYArr ne SData[1] ) then begin
         Message, 'YARR is not compatible with DATA!', /Continue
         return
      endif
   endif

   ;====================================================================
   ; determine NPANELS = number of plots per page
   ;====================================================================
   npanels = !p.multi[1]*!p.multi[2]

   ;====================================================================
   ; Keywords for TVMAP -- assume a MYCT colortable (bmy, 7/23/01)
   ;====================================================================
   if ( N_Elements( BLACK  ) eq 0 ) then BLACK = !MYCT.BLACK

   Debug   = Keyword_Set( Debug )
   Advance = 1 - Keyword_Set( NoAdvance )

   ;====================================================================
   ; Keywords for BYTSCL and COLORBAR
   ;====================================================================
   if ( N_Elements( MaxData ) eq 0 ) then MaxData = max( Data )
   if ( N_Elements( MinData ) eq 0 ) then MinData = min( Data )
   if ( N_Elements( Bottom  ) eq 0 ) then Bottom  = !MYCT.BOTTOM
   if ( N_Elements( NColors ) eq 0 ) then NColors = !MYCT.NCOLORS

   Log = Keyword_Set( Log )

   ;====================================================================
   ; Keywords for CONTOUR
   ;====================================================================
   MContour = Keyword_Set( MContour )
   FContour = Keyword_Set( FContour )

   ;====================================================================
   ; Keywords for COLORBAR
   ;====================================================================
   if ( N_Elements( CBar      ) eq 0 ) then CBar      = 0
   if ( N_Elements( CBColor   ) eq 0 ) then CBColor   = BLACK
   if ( N_Elements( CBColor   ) eq 0 ) then CBColor   = BLACK
   if ( N_Elements( Divisions ) eq 0 ) then Divisions = 2
   if ( N_Elements( CBUnit    ) eq 0 ) then CBUnit    = ''

   ; Default settings for CBPOSITION
   if ( MContour OR FContour  ) then begin
      if ( N_Elements( CBPosition ) eq 0 ) then begin

         ; Standard colorbar position for Contour plots
         CBPosition = [ 0.20, 0.01, 0.80, 0.04 ]

         ; Small Y-offset for more than 4 contour plots per page
         if ( NPanels gt 4 ) then begin
            CBPosition[1] = CBPosition[1] - 0.03
            CBPosition[3] = CBPosition[3] - 0.03 
         endif

         ; Bigger Y-offset for more than 9 contour plots per page
         if ( NPanels gt 9 ) then begin
            CBPosition[1] = CBPosition[1] - 0.10
            CBPosition[3] = CBPosition[3] - 0.10 
         endif
      endif
   endif else begin

      ; Standard colorbar position for pixel plots
      if ( N_Elements( CBPosition ) eq 0 ) $
         then CBPosition = [ 0.20, 0.11, 0.80, 0.14 ]
   endelse

   ;====================================================================
   ; Keywords for MAP_SET
   ;====================================================================
   Isotropic = Keyword_Set( Isotropic )
   Polar     = Keyword_Set( Polar     )

   if ( N_Elements( MColor ) eq 0 ) then MColor = !MYCT.BLACK
   if ( N_Elements( MTitle ) eq 0 ) then MTitle = ''

   ; PSOFFSET will raise the plot window a little for
   ; PostScript plots so that we have room for the colorbar
   if (!D.Name eq 'PS') then psoffset = 0.02 else psoffset = 0.
   if ( ( MContour + FContour eq 0 ) AND NPanels gt 4 ) then PSOffset = 0.0

   ; exit here if POLAR is requested for a pixel plot
   If (POLAR and (MContour+FContour eq 0)) then begin
      message,'PIXEL plots do not support /POLAR!',/Continue
      return
   endif

   ; Default position setting
   if ( N_Elements( MPosition  ) eq 0) then begin
      MPosition = [ 0.0, 0.15+psoffset, 1.0, 1.0 ]  ; leave room for colorbar
   endif else begin
      print,'% TVMAP: Position passed: ',Mposition
   endelse

   ; Default settings for LIMIT (bmy, 5/10/00)
   if ( N_Elements( Limit ) eq 0 ) then begin

      ; If XARR and YARR are passed, use them to determine LIMIT
      if ( N_Elements( XArr ) gt 3   AND $
           N_Elements( YArr ) gt 3 ) then begin

         ; Compute the 1/2 width of a grid box in X and Y
         ; Do not consider polar boxes since they could be half-size 
         HalfX = 0.5 * ( XArr[3] - XArr[2] )
         HalfY = 0.5 * ( YArr[3] - YArr[2] )

         ; XARR, YARR are box centers, so subtract or add HALFX 
         ; and HALFY to get box edges, which define the limit
         Limit = [ ( YArr[0] - HalfY       ) > ( -90.0 ),  $
                   ( XArr[0] - HalfX       ),              $
                   ( Yarr[SYArr-1] + HalfY ) < 90.0,       $
                   ( XArr[SXArr-1] + HalfX ) ]

      endif $

      ; Otherwise use the default limit for the entire globe
      else begin
         Limit = [ -90, -180, 90, 180 ]
      endelse
   endif

   ; Set P0Lat, P0Lon, Rot from MPARAM or LIMIT
   if ( N_Elements( MParam ) ge 2 )      $
      then P0Lon = MParam[1]             $
      else P0Lon = total(LIMIT[[1,3]])/2. ; make sure it's at the map center

   if ( N_Elements( MParam ) eq 0 )       $
      then MParam = [ 0,0,0 ]             $
      else MParam = ([Mparam,0,0,0])[0:2]

   P0Lat = Mparam[0]
   Rot   = MParam[2]

   ; If /POLAR is set, then P0Lat needs to be either +90
   ; (for NH plot) or -90 (for SH plot). (bmy, 5/26/99)
   if ( Polar ) then begin
      Limit[1] = -180.0
      Limit[3] =  180.0

      if ( Limit[0] lt 0 ) then P0Lat = -90.0  ; SH
      if ( Limit[2] gt 0 ) then P0Lat =  90.0  ; NH

      ; also need to "close" the contours
      Data =  [ Data,  Data[0, *] ]
      XArr =  [ XArr,  XArr[0]    ]

      ;### Debug output 
      if ( Debug ) then begin
         print, '### TVMAP: P0Lat, ', P0Lat
         print, '### TVMAP: LIMIT: ', Limit
      endif
   endif

   ;====================================================================
   ; Keywords for MAP_GRID
   ;====================================================================
   Grid     = Keyword_Set( Grid  )
   GXLabels = 1 - Keyword_Set( NoGXLabels )
   GYLabels = 1 - Keyword_Set( NoGYLabels )
   GLabels  = ( GXLabels OR GYLabels )

   if ( N_Elements( GColor ) eq 0 ) then GColor = BLACK

   ;====================================================================
   ; These keywords are for MAP_CONTINENTS
   ;====================================================================
   Continents = Keyword_Set( Continents )
   Countries  = Keyword_Set( Countries  )
   Coasts     = Keyword_Set( Coasts     )
   
   Draw_Continents = ( Continents OR Countries OR Coasts )

   if ( N_Elements( CColor ) eq 0 ) then CColor = BLACK
   if ( N_Elements( CFill  ) eq 0 ) then CFill  = 0

   ;====================================================================
   ; Keywords for TVIMAGE 
   ;====================================================================
   Keep_Aspect_Ratio = Keyword_Set( Keep_Aspect_Ratio )

   ; Make sure that KEEP_ASPECT_RATIO is also set if ISOTROPIC is set
   ; and vice versa.  This will make sure the isotropic map and image 
   ; plot will coincide.
   if ( Isotropic         ) then Keep_Aspect_Ratio = 1
   if ( Keep_Aspect_Ratio ) then Isotropic         = 1

   ;====================================================================
   ; Get actual position of current plot panel
   ;====================================================================
   if ( N_Elements( Margin ) eq 0 ) then Margin = [ 0.05, 0.04, 0.03, 0.07 ]
   MultiPanel, Position=Position, Margin=Margin, OMargin=OMargin

   ;=================================================================
   ; Calculate true window position from position and MPosition
   ; Here we don't need to add a colorbar ...
   ;=================================================================
   ; get width of plot window
   wx = (position[2]-position[0])
   wy = (position[3]-position[1])
   Mposition[0] = position[0]+wx*MPosition[0]
   Mposition[1] = position[1]+wy*MPosition[1]
   Mposition[2] = position[0]+wx*MPosition[2]
   Mposition[3] = position[1]+wy*MPosition[3]

   ; same with CBPosition
   CBPosition[0] = position[0]+wx*CBPosition[0]
   CBPosition[1] = position[1]+wy*CBPosition[1]
   CBPosition[2] = position[0]+wx*CBPosition[2]
   CBPosition[3] = position[1]+wy*CBPosition[3]

   ;### Debug output
   if ( Debug ) then begin
      print, '### TVMAP: Position   = ', Position
      print, '### TVMAP: MPosition  = ', MPosition
      print, '### TVMAP: CBPosition = ', CBPosition
      print, '### TVMAP: !P.MULTI   = ', !P.MULTI
   endif

   ;=================================================================
   ; CSFAC = scale factor for character sizes
   ; TITLECSFAC = scale factor for plot titles
   ;
   ; Now make CSFAC and TITLECSFAC keywords, so that you can pass
   ; values to them from the calling program (for special plots).
   ; If these aren't defined, use default values. (bmy, 3/31/00)
   ;=================================================================
   if ( N_Elements( CsFac ) eq 0 ) then begin
      csfac = 1.0
      if ( npanels gt 1 ) then csfac = 0.9
      if ( npanels gt 4 ) then csfac = 0.75
      if ( npanels gt 9 ) then csfac = 0.6

      if (!D.name ne 'PS') then csfac = csfac*1.2
      
      if ( ( MContour OR FContour ) AND !D.name ne 'PS' ) $
         then csfac = csfac*1.2
   endif

   if ( N_Elements( TitleCsFac ) eq 0 ) then begin
      TitleCsFac = 1.2
      if ( ( MContour + FContour eq 0 ) AND NPanels gt 4 ) $
         then TitleCsFac = 1.1
   endif

   ;====================================================================
   ; Make temporary copy of data   (still necessary ???)
   ; ... maybe to get rid of extra dimensions ?
   ;
   ; Set data points less than MIN_VALID to MIN_VALID
   ; This can be used to demarcate "missing" data points
   ;====================================================================
   TmpData = reform(Data)

   if ( N_Elements( Min_Valid ) gt 0 ) then begin
      MVInd = Where( TmpData lt Min_Valid )
      if ( MVInd[0] ge 0 ) then TmpData[MVInd] = Min_Valid
   endif else begin
      MVInd = -1L
   endelse

   ;====================================================================
   ; Return if TMPDATA is not a 2-D array
   ;====================================================================
   sd = size( TmpData, /Dimensions )
   if ( n_elements(sd) ne 2 ) then begin
      Message, 'No valid 2-D data to plot!', /Continue
      return
   endif
   
   if ( MContour OR FContour ) then begin

      ;=================================================================
      ; Here we are plotting a contour map!
      ;
      ; Make sure we have valid X and Y arrays
      ; Set default values for some contour input quantities
      ;
      ; Call MAP_SET to establish the map coordinates
      ; 
      ; Default map projection is "cylindrical"
      ; If /POLAR is set, will plot a "stereographic" projection
      ; 
      ; Note that the Isoptropic keyword is only needed for contour 
      ; plots and must not be set for pixel plots which are sized
      ; with the position keyword.
      ;=================================================================
      Map_Set, P0lat, P0Lon, Rot, Position=MPosition,       $
         Continents=0,  Grid=0,       /NoErase,             $
         /NoBorder,     XMargin=0,    YMargin=0,            $
         Color=MColor,  Limit=Limit,  StereoGraphic=Polar,  $
         Isotropic=Isotropic, _EXTRA=e

      ;=================================================================
      ; Call MAP_CONTINENTS for filled continents at this point
      ; (they only make sense in contour plots)
      ;=================================================================
      if ( Draw_Continents AND CFill ge 1 ) then begin
         Map_Continents, Color=CColor,  Fill=CFill, $
                         Coasts=Coasts, Countries=Countries, _EXTRA=e
      endif

      NewPosition = [ !X.Window[0], !Y.Window[0], $
                      !X.Window[1], !Y.Window[1] ]

      ;=================================================================
      ; If XARR, YARR are not explicitly passed, then construct 
      ; them from LIMIT and SD (dimensional information)
      ;=================================================================
      if ( N_Elements( XArr ) eq 0 ) then begin
         XA0 = LIMIT[1]
         XA1 = LIMIT[3]
         if (XA1 lt 0 AND XA0 gt 0) then Convert_Lon,XA1,/Pacific
         XARR = findgen(SD[0])/SD[0]*(XA1-XA0) + XA0
         if (XA1 lt 0 AND XA0 gt 0) then Convert_Lon,XARR,/Atlantic
         Message, 'Warning: XARR should be specified for CONTOUR plot!', $
                  /INFO
      endif

      if ( N_Elements( YArr ) eq 0 ) then begin
         YA0 = LIMIT[0]
         YA1 = LIMIT[2]
         YARR = findgen(SD[1])/SD[1]*(YA1-YA0) + YA0
         Message, 'Warning: YARR should be specified for CONTOUR plot!', $
                  /INFO
      endif

      ;=================================================================
      ; Default C_LEVELS...use quasi-logarithmic contour levels
      ; unless the range is very small
      ;=================================================================
      if ( N_Elements( C_Levels ) eq 0 ) then  $
         C_Levels = loglevels([MinData, MaxData],coarse=4)
      if ( N_Elements( C_Levels ) lt 3 ) then  $
         C_Levels = (findgen(9)-1.)/9.*(MaxData-MinData) + MinData

      ; NCL is the number of elements in C_LEVELS
      NCL = N_Elements( C_Levels )

      ; Default C_FORMAT
      if ( N_Elements( C_Format ) eq 0 ) then  $
          C_Format = get_defaultformat(C_Levels[0],C_Levels[NCL-1],$
                                       DefaultLen=['14.2','8.1'], Log=Log)

      ;### Debug output
      if ( Debug ) then begin
         print, '### TVMAP: C_Levels = ', C_Levels
         print, '### TVMAP: C_Format = ', C_Format
         print, '### TVMAP: MinData  = ', mindata
         print, '### TVMAP: MaxData  = ', maxdata
      endif

      ;=================================================================
      ; Default C_ANNOTATION...string representations of C_LEVELS
      ; Suppress printing labels by setting C_ANNOTATION(*) = ''
      ;=================================================================
      if ( Keyword_Set( NoLabels ) ) then begin
         C_Annotation = Replicate( '', NCL )
      endif else begin
         if ( N_Elements( C_Annotation ) eq 0 ) then begin
            C_Annotation = StrTrim( String( C_Levels, Format=C_Format ), 2 )
         endif
      endelse

      ;=================================================================
      ; Default C_LABELS...Set all elements to zero to suppress
      ; printing labels for each contour level, or one to enable
      ; printing labels for each contour level.
      ;
      ; Also, if C_LABELS is a scalar, then expand it so that
      ; it has the same number of elements as C_LEVELS
      ;
      ; ***** HERE IS A WEAKNESS!!! *****
      ; C_LABELS is superseeded by the C_ANNOTATION keyword (which we
      ; use to specify contour labels).  See above in the NOTES section
      ; of the documentation header.
      ;=================================================================
      if ( N_Elements( C_Labels ) eq 0 ) then begin
         if ( Keyword_Set( NoLabels ) )         $
            then C_Labels = Replicate( 0, NCL ) $
            else C_Labels = Replicate( 1, NCL )
      endif else begin
         if ( N_Elements( C_Labels ) eq 1 ) $
            then C_Labels = Replicate( C_Labels[0], NCL )
      endelse

      ; Default OVERLAYCOLOR = BLACK
      if ( N_Elements( OverLayColor ) eq 0 ) then OverLayColor = BLACK

      ;=================================================================
      ; If C_COLORS is not passed, choose evenly spaced colors from
      ; the MYCT colortable for default colors. Make sure to store 
      ; those in local variable (CC_Colors)
      ;
      ; Otherwise, if C_COLORS is a scalar, then expand so that it
      ; has the same number of elements as C_LEVELS.
      ;
      ; !!!! HERE IS A WEAKNESS !!!! 
      ; The use of C_ANNOTATION supersedes the C_LEVELS keyword
      ; (see note in documentation header above)
      ;=================================================================
      if ( N_Elements( C_Colors ) eq 0 ) then begin
         CC_Colors = Fix( ( IndGen( NCL ) / ( 1.0 * NCL ) ) * $
                         NColors + Bottom )
      endif else begin
         CC_Colors = C_Colors
         if ( N_Elements( CC_Colors ) eq 1 ) then $
             CC_Colors = Replicate( CC_Colors[0], NCL )
      endelse

      ;=================================================================
      ; Overlay title
      ;=================================================================
      xpmid = (!x.window[1]+!x.window[0])/2.

      ; Place a little higher for multipanel or cariage return lines
      if ( NPanels lt 2 )                 $
         then yptop = !y.window[1]+0.025  $
         else yptop = !y.window[1]+0.040

      ; place title yet higher if it has two lines
      if (strpos(mtitle,'!C') ge 0) then begin
         if ( NPanels le 4 ) $
            then yptop = yptop + 0.02 $
            else yptop = yptop + 0.01
      endif

      xyouts,xpmid,yptop,mtitle,color=MColor,/norm,align=0.5,  $
          charsize=TitleCsFac*csfac,charthick=charthick

      ;=================================================================
      ; For non-polar plots, plot a rectangular border around the
      ; edge of the map, without inserting any "cushion" space.
      ;=================================================================
      if ( not Polar ) then begin
         Rectangle, NewPosition, XPoints, YPoints
         PlotS, XPoints, YPoints, Thick=2, Color=MColor, /Normal
      endif

      ;=================================================================
      ; If /FCONTOUR is set, then create a filled-contour
      ; plot atop the world map created above.
      ;=================================================================
      if ( FContour ) then begin
         Contour, TmpData, XArr, YArr,          $
            Levels=C_Levels, C_Colors=CC_Colors, $
            ;----------------------------------------------------------
            ; NOTE: this should be /CELL_FILL?.  Also need to worry
            ; about how MIN_VALID fits into this plan. (bmy, 11/7/02)
            ;Fill=FContour,   /OverPlot,  _EXTRA=e
            ;----------------------------------------------------------
            Cell_Fill=FContour, /OverPlot,  _EXTRA=e

         ;==============================================================
         ; If C_LINES=1, then overlay the filled-contour
         ; map with solid contour lines of color OVERLAYCOLOR
         ;==============================================================
         if ( Keyword_Set( C_Lines ) ) then begin
            OverLayLines = Replicate( OverLayColor, NCL )

            Contour, TmpData, XArr, YArr,                        $
               Levels=C_Levels,           C_Colors=OverLayLines, $
               C_Annotation=C_Annotation, /OverPlot,             $
               C_Labels=C_Labels,         _EXTRA=e
         endif

      endif $

      ;=================================================================
      ; If /CONTOUR is set, then produce a
      ; line-contour plop atop the world map.
      ;=================================================================
      else if ( MContour ) then begin

         Contour, TmpData, XArr, YArr,                     $
            Levels=C_Levels,           C_Colors=CC_Colors,  $
            C_Annotation=C_Annotation, /OverPlot,          $
            C_Labels=C_Labels,         _EXTRA=e

      endif

   endif else begin

      ;=================================================================
      ; Here we are plotting a color-pixel image plot
      ; and overlaying a world map atop it!!!
      ;
      ; If /LOG is set, then take the log10 of TMPDATA.
      ; Store the extrema in LOGMINDATA and LOGMAXDATA,
      ; while leaving MINDATA and MAXDATA unaltered.
      ;
      ; First Byte-Scale the TMPDATA array, using the
      ; appropriate extrema for the byte scaling
      ;=================================================================
      if ( Log ) then begin

         ;==============================================================
         ; Make sure that we don't take the log10 of zero
         ;==============================================================
         Ind = Where( TmpData gt 0. )
         if ( Ind[0] ge 0 ) then begin
            ; Elements that don't equal zero...take the log10
            TmpData[ Ind ] = ALog10( TmpData[ Ind ] )
         endif

         if ( MinData gt 0 )                    $
            then LogMinData = ALog10( MinData ) $
            else LogMinData = 1e-30

         if ( MaxData gt 0 )                    $
            then LogMaxData = ALog10( MaxData ) $
            else LogMaxData = 1e-30

         Image = BytScl( TmpData, Min=LogMinData, Max=LogMaxData, $
                                  Top=NColors-1,  _EXTRA=e ) + Bottom

      endif else begin   ; (linear scale)

         Image = BytScl( TmpData, Min=MinData,    Max=MaxData, $
                                  Top=NColors-1,  _EXTRA=e ) + Bottom
      endelse

      ; Missing data values -- set to color white
      if ( MVInd[0] ge 0 ) then Image[ MVInd ] = !MYCT.WHITE

      ;=================================================================
      ; Compute dithering factor (10 to ..)
      ; Formula may need to be improved (later on...)
      ;=================================================================
      S      = Size( Image, /Dim )
      BlowUp = 10 * ( ( Fix( 50/Min(S) ) > 1 ) < 20 )

      ; If the image has more than 200,000 pixels, then don't blow
      ; it up, since we will probably run out of memory (bmy, 5/8/02)
      if ( N_Elements( Image ) gt 200000L ) then BlowUp = 1

      ;=================================================================
      ; If /SAMPLE then rebin the data using nearest neighbor
      ; interpolation.  Otherwise use bilateral interpolation
      ; (which takes longer but results in a finer grid).
      ;=================================================================
      if ( Keyword_Set( Sample ) ) then begin

         ; Screen (device with windows) needs rebin only if sample=1
         ; since this will force a lower resolution plot
         ; Also need to allow rebinning for the Z-buffer device (bmy, 1/30/01)
         if ( ( !D.FLAGS AND 256    ) ne 0   OR    $
              ( !D.FLAGS AND 131072 ) ne 0 ) then  $
            Image = Rebin( Image, S[0]*BlowUp, S[1]*BlowUp, /Sample )
      endif else begin

         ; PostScript needs rebin only for smoothing, since
         ; this will force a higher resolution plot
         if ( !D.NAME eq 'PS' ) then  $
            Image = Rebin( Image, S[0]*BlowUp, S[1]*BlowUp, Sample=0 )
      endelse

      ;=================================================================
      ; Call David Fanning's TVIMAGE routine to draw a color
      ; scale plot.  Use the NEWPOSITION values as defined
      ; from the extent of the map that was created above.
      ;=================================================================
      NewPosition = MPosition
      TVImage, Image, Position=NewPosition, $
         Keep_Aspect_Ratio=Keep_Aspect_Ratio,/NoErase, _EXTRA=e

      ; Adjust position of colorbar so that it is placed 0.05 below plot
      cwy = CBPosition[3]-CBPosition[1]
      CBPosition[3] = NewPosition[1] - 0.05
      CBPosition[1] = CBPosition[3] - cwy

      ;=================================================================
      ; We need to overlay the world map atop the color image.
      ; Also draw a frame around the map border, using the
      ; position vector from the window coordinates.
      ;=================================================================
      Map_Set, P0lat, P0Lon, Rot, Position=NewPosition, $
         Continents=0,  Grid=0,       /NoErase,   $
         /NoBorder,     XMargin=0,    YMargin=0,  $
         Color=MColor,  Limit=Limit

      ;=================================================================
      ; Overlay title
      ;=================================================================
      xpmid = (!x.window[1]+!x.window[0])/2.

      ; Place a little higher, for carriage return lines (bmy, 3/25/99)
      if ( NPanels lt 2 )                 $
         then yptop = !y.window[1]+0.025  $
         else yptop = !y.window[1]+0.030

      ; place title yet higher if it has two lines
      if (strpos(mtitle,'!C') ge 0) then begin
         if ( NPanels le 4 ) $
            then yptop = yptop + 0.02 $
            else yptop = yptop + 0.01
      endif

      xyouts,xpmid,yptop,mtitle,color=MColor,/norm,align=0.5,  $
            charsize=TitleCsFac*csfac,charthick=charthick

      ;=================================================================
      ; Plot a border around the edge of the map,
      ; without inserting any "cushion" space.
      ;=================================================================
      Rectangle, NewPosition, XPoints, YPoints

      PlotS, XPoints, YPoints, Thick=2, Color=MColor, /Normal

   endelse

   ;====================================================================
   ; Call MAP_CONTINENTS to plot (or fill in) the continents
   ;====================================================================
   if ( Draw_Continents AND $
        ( not MContour OR ( MContour AND CFill eq 0 ) ) ) then begin
          Map_Continents, Color=CColor,  Fill=CFill,          $
                          Coasts=Coasts, Countries=Countries, _EXTRA=e 
   endif


   ;====================================================================
   ; If GRID=1 or GXLABELS=1 or GYLABELS=1 then call MAP_LABELS to 
   ; construct the latitude and longitude labels for each grid line, 
   ; and also the normalized coordinates (NORMLATS, NORMLONS) that 
   ; will be used to plot the labels. (bmy, 1/16/01)
   ;
   ; If /GRID is set, then also print out the grid lines (bmy, 1/16/01)
   ;====================================================================
   if ( GXLabels OR GYLabels OR Grid ) then begin

      LatRange = [ Limit[0], Limit[2] ]
      LonRange = [ Limit[1], Limit[3] ]

      ;### Debug output
      if ( Debug ) then begin
         print, '### TVMAP : Limit    : ', Limit
         print, '### TVMAP : LatRange : ', LatRange
         print, '### TVMAP : LonRange : ', LonRange
      endif
         
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
      
      ; Print Y-axis labels unless /NOGYLABELS is set (bmy, 7/2/01)
      if ( GYLabels ) then begin
         XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
            Align=1.0, Color=MColor, /Normal, charsize=csfac, charthick=charthick 
      endif

      ; Print X-axis labels unless /NOGXLABELS is set (bmy, 7/2/01)
      if ( GXLabels ) then begin
         XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
            Align=0.5, Color=MColor, /Normal, charsize=csfac, charthick=charthick
      endif

   endif
   
   ; Only print out grid lines if /GRID is set (bmy, 1/16/01)
   if ( Grid ) then Map_Grid, Color=GColor, Lats=Lats, Lons=Lons, _EXTRA=e

   ;====================================================================
   ; Call COLORBAR to plot the colorbar below the map
   ; Otherwise, just print the unit string below the X-axis labels
   ;====================================================================
   if ( CBar ) then begin

      if ( N_Elements( CBMin ) eq 0 ) then CBMin = MinData
      if ( N_Elements( CBMax ) eq 0 ) then CBMax = MaxData

      if ( N_Elements( Min_Valid ) gt 0 ) then begin
 
         ; If MIN_VALID is passed, then also draw a white box
         ; to indicate values less than MIN_VALID
         ColorBar, BotOutOfRange=0,                                       $
            Max=CBMax,          Min=Min_Valid,       NColors=NColors,     $
            Bottom=Bottom,      Color=CBColor,       Position=CBPosition, $
            Unit=CBUnit,        Divisions=Divisions, Log=Log,             $
            Format=CBFormat,    Charsize=csfac,      TickLen=CBTickLen,   $
            C_Colors=CC_Colors, C_Levels=C_Levels,   _EXTRA=e,            $
            charthick=charthick

      endif else begin
                  
         ; Otherwise, just draw the colorbar w/o the extra white box
         ColorBar, $
            Max=CBMax,          Min=CBMin,           NColors=NColors,     $
            Bottom=Bottom,      Color=CBColor,       Position=CBPosition, $
            Unit=CBUnit,        Divisions=Divisions, Log=Log,             $
            Format=CBFormat,    Charsize=csfac,      TickLen=CBTickLen,   $
            C_Colors=CC_Colors, C_Levels=C_Levels,   _EXTRA=e,            $
            charthick=charthick
     
      endelse


   endif else begin
      XPos = ( MPosition[2]  + MPosition[0]  ) * 0.5
      YPos = ( CBPosition[3] + CBPosition[1] ) * 0.5

      XYOutS, XPos, YPos, CBUnit, /Normal, $
         Align=0.5, Color=MColor, CharSize=CsFac, charthick=charthick
   endelse


   ;====================================================================
   ; Advance to the next plot position for the next plot
   ; Use NoErase so that we still see the results when the page is full
   ; (will be erased when we do next plot after page is full)
   ;====================================================================
   WindowPosition = NewPosition

   ; Now only advance to the next frame if NOADVANCE=0 (bmy, 10/31/01)
;   MULTIPANEL, Advance=Advance, /NoErase

   ; Return C_Colors back to the calling program (bmy, 5/21/04)
   if ( N_Elements( CC_Colors ) gt 0 ) then C_Colors = CC_Colors
   
   return
end
