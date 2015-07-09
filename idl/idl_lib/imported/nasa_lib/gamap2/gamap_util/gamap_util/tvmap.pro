; $Id: tvmap.pro,v 1.17 2008/07/17 14:08:52 bmy Exp $
;-----------------------------------------------------------------------
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
;        GAMAP Utilities, GAMAP Plotting
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
;        /CONUS -> a Lambert's azimuthal equal area projection for
;             CONtiguous U.S., w/ specific LIMIT and P0lat, P0lon, Rot.
;
;        MAX_VALID -> maximum valid data value for color-pixel plots
;             Data above MAX_VALID will be shown in white, unless
;             TOPOUTOFRANGE is set to another color index.
;
;        MIN_VALID -> minimum valid data value for color-pixel plots.  
;             (or minimum contour level for contour plots).  Data 
;             below MIN_VALID will be shown in white, unless
;             BOTOUTOFRANGE is set to another color index.
;
;        TOPOUTOFRANGE ( BOTOUTOFRANGE ) -> color index to indicate
;             data above MAX_VALID (below MIN_VALID). Default is
;             white. The color is also shown with a box (or TRiangle)
;             near the colorbar (if any). If negative, the box is not
;             shown.
;
;        /NOERASE -> This keyword prevents erasing the screen (or page)
;            when setting a multi-panel environment or after a page was
;            filled.  /NOERASE is automatically turned ON when the /OFF
;            keyword is given.  NOTE: On the PostScript device, when
;            the page is filled, it automatically places the next plot
;            on the next page.  You can use the /NOERASE keyword to
;            suppress this behavior, especially if you are manually
;            placing plots on the page.
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
;        /RECTANGLE -> to plot a rectangle around the map. Default is
;             to have one for non-polar projection, and none for polar 
;             projection. Set to 0 or 1 to override default.  NOTE:
;             setting the /HORIZON keyword will disable this option.
;
;        /HORIZON -> Set this switch to call IDL routine MAP_HORIZON
;             to draw a horizon line around the boundaries of the map.
;             Use this feature if the map projection you are using is
;             elliptical or interrupted.  NOTE: /HORIZON will override
;             override the /RECTANGLE keyword setting.
;
;        WINDOWPOSITION -> Returns the position of the plot window
;             in normal coordinates to the calling program.  This can
;             be used by a subsequent call to PLOT if you want to
;             overplot symbols atop the contour or pixel plot created
;             by TVMAP.
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
;    Additional keywords passed to COLORBAR:
;    =======================================
;        /CBAR -> If set, will plot a horizontal colorbar below the
;             map in the position specified by CBPOSITION.  Default is
;             to NOT plot a colorbar.
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
;        CBVERTICAL -> If set, will plot a vertical bar on the right
;             side of the map.
;
;        DIVISIONS -> Number of labels for the colorbar.  Default is 4.
;
;        /TRIANGLE -> to replace box that indicate Out Of Range data 
;             with a triangle.
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
;        POLAR -> Plot a polar stereographic projection. If set and
;             equal 1 then the plot goes from the pole to a latitude
;             defined by either the extend of the data or by the user
;             through the LIMIT keyword. If set and equal to 2, then
;             the full hemisphere is plot, regardless of the data or
;             LIMIT settings.
;              Note that setting the /STEREOGRAPHIC keyword wouldn't
;             work.
;
;        POSITION -> A four-element array of normalized coordinates
;             that specifies the location of the map.  POSITION has
;             the same form as the POSITION keyword on a plot.
;             Default is [0.0, 0.15, 1.0, 1.0] with Horizontal Color
;             Bar, and [0., 0., 0.82, 1.0] with Vertical CBar.
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
;        SCALEMAPSET -> To pass the SCALE keyword to MAP_SET.
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
;        /USA -> Set this switch to turn on US State boundaries.
;
;    Keywords passed to MAP_GRID:
;    ============================
;        /BOX_AXES -> If set, then MAP_GRID will print alternating
;             light & dark regions with the lon & lat labels around
;             the border of the plot.  This is passed directly to
;             MAP_GRID.  NOTE: BOX_AXES is the default for the CONUS
;             option.
;
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
;    Keywords passed to MAP_IMAGE (prior: to REBIN):
;    ==============================================
;        /SAMPLE -> Used to rebin the byte-scaled image array to a
;             larger size.  If /SAMPLE is set, then MAP_IMAGE will use
;             nearest-neighbor sampling rather than bilinear
;             interpolation. 
;
;    Keyword passed to TVIMAGE:
;    ===============================================
;        SCALEMAPIMAGE -> Sets the number of pixels per graphic coordinate
;             in PostScript and other devices with scalable
;             pixels. Larger values produce better resolution output,
;             but much larger file sizes. The default value is
;             0.04. Use a larger number for higher resolution if your 
;             image does not exactly fit on the map projection. 
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
;        (4) For contour plots, contour labels will be specified
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
;        (5) Now references the !MYCT system variable.  This should
;        be defined at the start of your IDL session when "myct.pro"
;        is called from "idl_startup.pro".
;
; LIMITATIONS:
;
;       (1) The case of plot over the dateline is working fine only if
;       LIMIT[3] is negative and LIMIT[1] is positive. Other cases are
;       not specifically handled and results may not be reliable.
;
;
;       (2) Since we are using MAP_IMAGE, pixel plots do start and end
;        at longitude and latitude centers of the grid by default,
;        like contour plots. More map coverage is done in three cases:
;
;          (2a) Data sets that cover the globe will fill the map with
;          coarse pixel plots.
;         
;          (2b) Data sets that cover the globe will fill the map only
;          in the longitude direction with smooth pixel and contour
;          plot. Plots start and stop at the first and last latitudes
;          centers.
;         
;          (2c) Data sets that do not cover the globe will start and
;          end at grid edges with coarse pixels, only if the limit of
;          the map is less than half grid size away from the the
;          first/last latitude and longitude centers. This limitation
;          is due to the method used to pad the data outside the
;          domain delimited by X/Y arrays.
;
;       (3) MAP_IMAGE assumes that an evenly spaced data set is
;       passed. If X or Y array is not evenly spaced, pixels plots are
;       flawed and not reliable. Contour plots are ok.
;
;        
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
;        bmy, 23 Aug 2005: GAMAP VERSION 2.04
;                          - added MAX_VALID keyword
;                          - now adjust MINDATA to MIN_VALID and
;                            MAXDATA to MAX_VALID internally
;                          - Now pass _EXTRA=e to XYOUTS
;  tmf & bmy, 04 Oct 2006: GAMAP VERSION 2.05
;                          - Replace /ERASE keyword with /NOERASE
;                            to facilitate manual positioning of
;                            plots.  Pass /NOERASE to MULTIPANEL.
;  bmy & phs, 18 Sep 2007: GAMAP VERSION 2.10
;                          - Don't reset data below MIN_VALID to 
;                            MIN_VALID for contour plots
;                          - fix MAX_VALID for contour plots.
;                          - fix CBar behavior when C_LEVELS is passed
; cdh/phs/bmy 26 Nov 2007: GAMAP VERSION 2.11
;                          - do not modify input DATA & X/YARR
;                          - add support for VERTICAL COLORBAR
;                          - add support for CONUS projection
;                          - now all map projections are supported for
;                            all 4 types of plots.
;                          - now data Latitudes and Longitudes (X/Yarr)
;                            are taken into account in Pixel
;                            plot: no more need to clip the data
;                            before plotting, TVMAP will do it, like
;                            it already does for Contour plots.
;                          - added Full Hemisphere Polar plot option,
;                            regardless of DATA range and LIMIT keyword
;                          - added RECTANGLE keyword to overwrite
;                            default behavior
;                          - map plotting coordinate system active at
;                            exit, allowing for easy oplot
;                          - default LIMIT for small data set corrected
;                          - various fixes for across-the-dateline plots
;                          - remove obsolete KEEP_ASPECT_RATIO keyword
;                          - add /HORIZON keyword to call MAP_HORIZON
;                          - updated comments
;        phs, 19 Dec 2007: - new default map limit in case of
;                            non-global smooth pixel and contour
;                            plots.
;                          - plots start and end at box edges in few 
;                            new cases.
;                          - replace /CENTER with /MINUS_ONE in call
;                            to CONGRID
;        phs, 12 Feb 2008: GAMAP VERSION 2.12
;                          - Fixes for MIN_VALID and MAX_VALID 
;                          - The test for the LIMIT keyword is now to check
;                            "if ( n_elements(limit) ne 4 )".  This allows you
;                            to disable the LIMIT keyword by also setting
;                            LIMIT=0.
;        phs, 28 Feb 2008: - Couple of small padding improvements
;                          - added SCALEMAPSET and SCALEMAPIMAGE to pass
;                            their respective SCALE keyword to MAP_SET and
;                            MAP_IMAGE.
;                          - LONS and LATS keyword added, so the grid can
;                            be specified. Work with DLAT and DLON, the
;                            grid spacings that can be passed to MAP_LABELS
;                            thru the _extra keyword.
;  cdh & phs, 21 Mar 2008: - added minimum support for LIMIT input as
;                            8-elements vector
;        phs, 17 Apr 2008: - Added the TopOutOfRange and BotOutOfRange
;                            keywords, so default color (white) for Out-Of
;                            -Range data can be overwritten.
;        phs,  6 May 2008: - Added the GXLABELS and GYLABELS keywords
;                            to specify which grid line to label.
;        phs, 19 Jun 2008: - Set default SCALE value for MapImage
;                            (ScaleMapImage keyword) to 0.04 if PS device.
;
;-
; Copyright (C) 1998-2008, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes. This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine tvmap"
;-----------------------------------------------------------------------


pro TVMap, Data, XArr, YArr,                                               $
           BLACK=BLACK,               NoErase=NoErase,                     $
           MaxData=M_MaxData,         MinData=M_MinData,                   $
           NColors=NColors,           Bottom=Bottom,                       $
           Log=Log,                   CBar=CBar,                           $
           CBPosition=CBPosition,     CBColor=CBColor,                     $
           CBUnit=CBUnit,             Divisions=Divisions,                 $
           CBFormat=CBFormat,         CBMin=CBMin,                         $
           CBMax=CBMax,               CBTickLen=CBTickLen,                 $
           CBVertical=CBVertical,     Color=MColor,                        $
           MParam=MParam,             Title=MTitle,                        $
           Position=MPosition,        Isotropic=Isotropic,                 $
           Sample=Sample,             Horizon=Horizon,                     $
           Limit=Limit,               Margin=Margin,                       $
           OMargin=OMargin,           Continents=Continents,               $
           Countries=Countries,       Coasts=Coasts,                       $
           CColor=CColor,             CFill=CFill,                         $
           Grid=Grid,                 GColor=GColor,                       $
           NoGXLabels=NoGXLabels,     NoGYLabels=NoGYLabels,               $
           GXLabels=GXLabels,         GYLabels=GYLabels,                   $
           Contour=MContour,          FContour=FContour,                   $
           C_Levels=C_Levels,         C_Colors=C_Colors,                   $
           C_Annotation=C_Annotation, C_Format=C_Format,                   $
           C_Labels=C_Labels,         C_Lines=C_Lines,                     $
           NoLabels=NoLabels,         OverLayColor=OverLayColor,           $
           Polar=Polar,               Min_Valid=Min_Valid,                 $
           CsFac=CsFac,               TCsFac=TitleCsFac,                   $
           NoAdvance=NoAdvance,       WindowPosition=WindowPosition,       $
           Max_Valid=Max_Valid,       CONUS=CONUS,                         $
           Rectangle=RRectangle,      USA=USA,                             $
           Debug=Debug,               Box_Axes=Box_Axes,                   $
           BotOutOfRange=BOOR,        TopOutOfRange=TOOR,                  $
           ScaleMapSet=ScaleMS,       ScaleMapImage=ScaleMI,               $
           Lats=Lats,                 Lons=Lons,                           $
           latlab=latlab,             lonlab=lonlab,                       $
           _EXTRA=e

   ;====================================================================
   ; Pass external functions
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

      ; Compute the 1/2 width of a grid box in X (phs. 11/16/07)
      HalfX = 0.5 * Max( ( Shift(XArr, -1) - XArr )[0:SXArr-2] )

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

      ; Compute the 1/2 width of a grid box in Y (phs. 11/16/07)
      ; Do not consider polar boxes since they could be half-size
      HalfY = 0.5 * Max( ( Shift( YArr, -1) - YArr )[0:SYArr-2] )

   endif

   ;====================================================================
   ; determine NPANELS = number of plots per page
   ;====================================================================
   npanels = !p.multi[1]*!p.multi[2]

   ;====================================================================
   ; Check if MYCT colortable exist
   ;====================================================================
   ; Test if the !MYCT system variable was created before we reference it
   DefSysV, '!MYCT', Exists=IS_MYCT

   ;====================================================================
   ; Keywords for TVMAP -- assume a MYCT colortable (bmy, 7/23/01)
   ;====================================================================
   if ( N_Elements( BLACK  ) eq 0 ) then BLACK = Is_MyCT ? !MYCT.BLACK : 0

   Debug   = Keyword_Set( Debug )
   Advance = 1 - Keyword_Set( NoAdvance )
   Sample  = Keyword_Set( Sample )

   ;====================================================================
   ; Keywords for BYTSCL and COLORBAR
   ;====================================================================
   if ( N_Elements( Bottom  ) eq 0 ) then Bottom  = Is_MyCT ? !MYCT.BOTTOM  : 0
   if ( N_Elements( NColors ) eq 0 ) then NColors = Is_MyCT ? !MYCT.NCOLORS : !D.Table_size

   Log = Keyword_Set( Log )

   ; Flags to denote if MIN_VALID & MAX_VALID are passed (bmy, 8/9/05)
   Is_Min_Valid_Used = ( N_Elements( Min_Valid ) eq 1 )
   Is_Max_Valid_Used = ( N_Elements( Max_Valid ) eq 1 )
   
   ; Default Top/BotOutOfRange colors (phs, 4/17/08)
   If ( Is_Min_Valid_Used ) AND ( n_elements( BOOR ) eq 0L ) then $         
      BOOR = Is_MyCT ? !MYCT.WHITE : !D.Table_size-1L
   If ( Is_Max_Valid_Used ) AND ( n_elements( TOOR ) eq 0L ) then $         
      TOOR = Is_MyCT ? !MYCT.WHITE : !D.Table_size-1L

   ;====================================================================
   ; Keywords for CONTOUR
   ;====================================================================
   MContour = Keyword_Set( MContour )
   FContour = Keyword_Set( FContour )

   ;====================================================================
   ; Keywords for COLORBAR
   ;====================================================================
   if ( N_Elements( CBColor   ) eq 0 ) then CBColor   = BLACK
   if ( N_Elements( Divisions ) eq 0 ) then Divisions = 2
   if ( N_Elements( CBUnit    ) eq 0 ) then CBUnit    = ''

   CBVertical = Keyword_Set( CBVertical )
   CBar       = CBVertical or Keyword_Set( CBar )
   NCBPos     = N_Elements( CBPosition )

   ; Default Colorbar Position
   if ( NCBPos eq 0 ) then begin

      ; Vertical Colorbar on right of plot area
      if ( CBVertical ) then begin

         ;-----------------------------------
         ; Position for vertical colorbar 
         ;-----------------------------------
         CBPosition = [ 0.86, 0.20, 0.89, 0.80]

      endif else begin
        
        ;-----------------------------------
        ; Position for horizontal colorbar
        ;-----------------------------------

         ; Default settings for Contour plots
         if ( MContour OR FContour  ) then begin

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

         ; Standard colorbar position for pixel plots
         endif else CBPosition = [ 0.20, 0.11, 0.80, 0.14 ]

      endelse

   endif

   ;====================================================================
   ; Keywords for MAP_SET, etc.
   ;====================================================================
   Isotropic = Keyword_Set( Isotropic )
   Is_Polar  = Keyword_Set( Polar     )
   CONUS     = Keyword_Set( CONUS     )
   Horizon   = Keyword_Set( Horizon   )
   Box_Axes  = Keyword_Set( Box_Axes  )

   ; Enforce isotropic for stereographic and polar plots
   if ( Is_Polar or ChkStru( e, 'STEREOGRAPHIC' ) ) then Isotropic = 1

   if ( N_Elements( MColor ) eq 0 ) then MColor = !MYCT.BLACK
   if ( N_Elements( MTitle ) eq 0 ) then MTitle = ''

   ; PSOFFSET will raise the plot window a little for
   ; PostScript plots so that we have room for the colorbar
   if (!D.Name eq 'PS') then psoffset = 0.02 else psoffset = 0.
   if ( ( MContour + FContour eq 0 ) AND NPanels gt 4 ) then PSOffset = 0.0
   
   ; ==== Default MAP position setting: just leave room for colorbar
   if ( N_Elements( MPosition  ) eq 0) then begin
      MPosition = CBVertical ? [ 0.0, 0.0,           0.82-psoffset, 1.0 ] : $
                               [ 0.0, 0.15+psoffset, 1.0,           1.0 ]
   endif else begin
      print,'% TVMAP: Position passed: ',Mposition
   endelse

   ;====================================================================
   ; Default settings for LIMIT & Padding (bmy, 5/10/00)
   ;====================================================================
   NeedPadding = 0b             ; flag to expand plot up to box edges
   NLimit = N_Elements( Limit )

   ; case LIMIT is not provided
   if ( NLimit ne 4 ) and ( NLimit ne 8 ) then begin

      ; If XARR and YARR are passed, use them to determine LIMIT
      if ( N_Elements( XArr ) ge 1   AND $
           N_Elements( YArr ) ge 1 ) then begin

         ; XARR, YARR are box centers, so subtract or add HALFX
         ; and HALFY to get box edges, which define the limit.
         Limit = [ ( YArr[0] - HalfY       ) > ( -90.0 ),  $
                   ( XArr[0] - HalfX       ),              $
                   ( Yarr[SYArr-1] + HalfY ) < 90.0,       $
                   ( XArr[SXArr-1] + HalfX ) ]

         ;-------------------------------------------------------
         ; Enforce Custom behavior for global map that 
         ; starts/ends on the dateline:
         ;
         ; For global maps of some grids, the preceeding method
         ; generates limits that exceed +/- 180 longitude
         ; (e.g. [-182.5,177.5]), but maps customarily clip 
         ; at +/- 180. (cdh, phs, 11/14/07)
         ;-------------------------------------------------------

         ; Check if data cover the whole world or not, and ...
         AllLon = ( XArr[SXArr-1] - XArr[0] + 2*HalfX ) EQ 360.

         ;...if Array of Longitude Center starts or ends on the dateline
         DLine = ( Xarr[0] eq -180 ) or ( XArr[SXArr-1] eq 180. )

         ;; if both are true then shift LIMIT
         If ( DLine ) AND ( AllLon ) Then Limit[[1,3]] = [-180.,180.]
         

         ;--------------------------------------------------------       
         ;; If plot does not cover the entire globe (phs, 12/13/07)
         ;--------------------------------------------------------
         if not(AllLon) then begin

            ;; Put default LIMIT on grid centers if not coarse pixel
            ;; plot, since data cannot be extrapolated outside the X/Y
            ;; area
            if (MContour OR FContour or not(sample)) then $
              Limit = [ YArr[0],       XArr[0],        $
                        Yarr[SYArr-1], XArr[SXArr-1] ] $

            ;; pad data set if coarse plot
            else NeedPadding = 1

         endif
            
      endif $

      ; Otherwise use the default limit for the entire globe
      else begin
         Limit = [ -90, -180, 90, 180 ]

      endelse

   ;; case of LIMIT is provided as 4-elements
   endif else if ( NLimit ne 8 ) then begin      

      ;; X/Yarr not passed: will be set from non-default
      ;; limit and will pad data (phs, 12/12/07)
      ;; NeedPadding will be set to 0 below if global data
      if n_elements( Xarr ) eq 0 then NeedPadding = 1b $

      ;; X/YARR are provided: pad only if map area is not
      ;; larger than the boxes area defined by X/Yarr (phs, 12/19/07)
      else begin

         ; Latitude padding
         PadBottom = ( limit[0] ge yarr[0]-HalfY ) and $
                     ( limit[0] lt yarr[0]       ) ? 1 : 0

         PadTop = ( limit[2] ge yarr[0]-HalfY  ) and $
                  ( limit[2] le yarr[0]        ) ? 1 : 0

         ; Longitude padding

     ;;-----------------------------------------------------------------
     ;;         ; If we had a better padding technic we would simply 
     ;;         ; decide if we need padding like that:
     ;;         if ( LIMIT[1] lt limit[3] ) then begin
     ;;            if ( Xarr[0] ge limit[1] ) AND $
     ;;               ( Xarr[0] le limit[3] ) then PadLeft = 1
     ;;            if ( Xarr[SXArr-1] ge limit[1] ) AND $
     ;;               ( Xarr[SXArr-1] lt limit[3] ) then PadRight = 1
     ;;         endif else begin
     ;;            ; Over-the-dateline plots
     ;;            if ( Xarr[0] ge limit[1] ) OR $
     ;;               ( Xarr[0] le limit[3] ) then PadLeft = 1
     ;;            if ( Xarr[SXArr-1] ge limit[1] ) OR $
     ;;               ( Xarr[SXArr-1] lt limit[3] ) then PadRight = 1
     ;;         endelse
     ;;-----------------------------------------------------------------
     
         ; For now, do padding when LIMIT is no more than half box
         ; away from box centers
         if ( limit[1] ge xarr[0]-HalfX  ) and  $
            ( limit[1] le xarr[0]        ) then PadLeft = 1 $
         else PadLeft = 0

         if ( limit[3] ge xarr[SXArr-1]       ) and  $
            ( limit[3] le xarr[SXArr-1]+HalfX ) then PadRight = 1 $
         else PadRight = 0

         ; quick fix for now. Should work fine with most of old codes
         ; that zoom on data set. Ideally padding should be done
         ; separately for each sides (next development cycle?)
         ; NeedPadding will be set to 0 below if global data 
         NeedPadding = (PadBottom + PadTop + PadLeft + PadRight) gt 0

      endelse
   endif


   ;====================================================================
   ; Now X/Y vectors are needed for both Contour and Map_Image, i.e.,
   ; pixel plot (phs, 11/14/07)
   ;
   ; NOTE: here we assume that LIMIT gives the EDGES of the grid.
   ; This is purely a convention choice, but this is the one used
   ; above when LIMIT is determined from X/Yarr. It is also intuitively
   ; what user may expect when neither LIMIT nor Yarr is passed, since
   ; then LIMIT=[-90,-180,90,180]. It also centers the plot on the map.
   ;
   ; Could override that w/ a keyword.... 
   ;   if users really ask for it ## later ##
   ;
   ; Thus, for GC at 4x5, setting limit=[-88, -182.5, 88., 177.5] allow
   ; to not pass XYarr (but you still need to take off the polar
   ; boxes from the data).
   ;
   ; Also require bug fix in CONVERT_LON for across-the-dateline plots
   ; to be correct when Xarr is determined here (phs, 11/19/07)
   ;====================================================================
   ; If XARR, YARR are not explicitly passed, then construct
   ; them from LIMIT and SData (dimensional information)
   ;====================================================================

   if ( N_Elements( XArr ) eq 0 ) then begin
      XA0   = LIMIT[1]
      XA1   = LIMIT[3]
      DLine = ( XA1 lt 0 AND XA0 gt 0 ) 
      if ( Dline ) then Convert_Lon, XA1, /Pacific

      XARR = findgen( SData[0] ) / SData[0] * ( XA1 - XA0 ) + XA0

      ; do the following before going back to /Atlantic
      HalfX = 0.5 * ( Xarr[1] - Xarr[0] ) ; 1/2 width of a grid box in X
      Xarr  = Xarr + HalfX                ; center everything

      if ( DLine ) then Convert_Lon, XARR, /Atlantic

      if ( MContour OR FContour ) then $
         Message, $
            'Warning: XARR should be specified for CONTOUR plot!', /INFO

      ; number of longitudes
      SXarr = SData[0]                    

   endif

   if ( N_Elements( YArr ) eq 0 ) then begin
      YA0  = LIMIT[0]
      YA1  = LIMIT[2]
      YARR = findgen(SData[1])/SData[1]*(YA1-YA0) + YA0

      if ( MContour OR FContour ) then $
         Message, $
            'Warning: YARR should be specified for CONTOUR plot!', /INFO

      SYarr = SData[1]                    ; number of latitudes
      HalfY = 0.5 * ( Yarr[1] - Yarr[0] ) ; 1/2 width of a grid box in Y

      Yarr = Yarr + HalfY

   endif

   ;====================================================================
   ;    Set P0Lat, P0Lon, Rot from MPARAM or LIMIT
   ;
   ; Note: this needs to happen after defining X/Yarr because
   ;       if POLAR is set, LIMIT is overwritten (phs, 11/16/07)
   ;====================================================================
   if ( N_Elements( MParam ) ge 2 )      $
      then P0Lon = MParam[1]             $
   else begin
      if limit[3] gt limit[1] then P0Lon = total(LIMIT[[1,3]])/2.  $
      else P0Lon = ( LIMIT[3]+360 - Limit[1] )/2. + Limit[1]
   endelse

   if ( N_Elements( MParam ) eq 0 )       $
      then MParam = [ 0,0,0 ]             $
      else MParam = ([Mparam,0,0,0])[0:2]

   P0Lat = Mparam[0]
   Rot   = MParam[2]


   ; Overwrite settings for POLAR = 1 or 2.
   ; If POLAR is set, then P0Lat needs to be either +90
   ; (for NH plot) or -90 (for SH plot). (bmy, 5/26/99)
   if ( Is_Polar ) then begin
      Limit[1] = -180.0         ; could be commented (phs)
      Limit[3] =  180.0         ; could be commented (phs)

      SH = Limit[0] lt 0
      NH = Limit[2] gt 0

      if NH then begin
         if ( Polar eq 2 )                              $
            then Limit = [0.0,          -180, 90, 180 ] $
            else Limit = [Limit[0] > 0, -180, 90, 180 ]
         P0Lat =  90.0
      endif else begin
         if ( Polar eq 2 )                               $
            then Limit = [-90, -180,            0, 180 ] $
            else Limit = [-90, -180, Limit[2] < 0, 180 ]
         P0Lat =  -90.0
      endelse

      ;if ( Limit[0] lt 0 ) then P0Lat = -90.0  ; SH
      ;if ( Limit[2] gt 0 ) then P0Lat =  90.0  ; NH

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
   if n_elements(GXLabels) eq 0 then GXLabels = 1 - Keyword_Set( NoGXLabels )
   if n_elements(GYLabels) eq 0 then GYLabels = 1 - Keyword_Set( NoGYLabels )

   if ( N_Elements( GColor ) eq 0 ) then GColor = BLACK

   ;====================================================================
   ; These keywords are for MAP_CONTINENTS
   ;====================================================================
   Continents      = Keyword_Set( Continents )
   Countries       = Keyword_Set( Countries  )
   Coasts          = Keyword_Set( Coasts     )
   USA             = Keyword_Set( USA        )
   Draw_Continents = ( Continents OR Countries OR Coasts OR USA )

   if ( N_Elements( CColor ) eq 0 ) then CColor = BLACK
   if ( N_Elements( CFill  ) eq 0 ) then CFill  = 0

   ;====================================================================
   ; Get actual position of current plot panel
   ;====================================================================

   ; Default MARGIN value
   if ( N_Elements( Margin ) eq 0 ) then Margin = [ 0.05, 0.04, 0.03, 0.07 ]

   ; If MARGIN only has 2 elements, then pad it to 4 values
   if ( N_Elements( Margin ) eq 2 ) then Margin = [ Margin, Margin ]

   ; Get actual position of plot panel
   MultiPanel, Position=Position, Margin=Margin, $
               OMargin=OMargin,   NoErase=NoErase

   ;=================================================================
   ; Calculate true Map and CBar positions from POSITION,
   ; MPosition, and CBPosition
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
      print, '### TVMAP: P0Lat      = ', P0Lat
      print, '### TVMAP: P0Lon      = ', P0Lon
      print, '### TVMAP: Rot        = ', Rot
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
   ; MANIPULATE INPUT DATA
   ; (1) Copy data is to prevent the progam from passing back modified
   ; input data to the calling function (cdh,11/7/2007)
   ;
   ; (2) Wrap data around the world or expand them in all four directions
   ; if needed
   ;
   ; (3) Demarcate values < MIN_VALID and values > MAX_VALID
   ; These data points will be set to !MYCT.WHITE color index
   ;====================================================================
   TmpData = reform(Data)

   ; Wrap data around the world. This is needed for Contour and for
   ; smooth pixels. Map_image does the same thing, which works fine
   ; with coarse pixel, but not with smooth pixels since we blow up
   ; the image before calling TVImage (cdh,phs,11/16/2007)
   if ( ( XArr[SXArr-1] - XArr[0] + 2.*HalfX ) Eq 360. ) then begin

      TmpData =  [ TmpData,  TmpData[0, *]            ]
      XArr    =  [ XArr,     XArr[SXArr-1] + 2.*HalfX ]
      SXArr   =  SXArr + 1

      ; flag for GLobal Data
      EntireGlobe = 1B

      ; Commented now (phs,2/28/08)
      ; NeedPadding = 0
      
   endif else EntireGlobe = 0B

   ;====================================================================
   ; Case of X/Y determined from a user supplied LIMIT: Expand in both
   ; direction, and both sides (phs, 11/16/2007).  Apply also if LIMIT
   ; is not provided but computed from X/Yarr, and ends up covering a
   ; small area of the globe (phs, 12/12/07), or both LIMIT and X/Yarr
   ; are passed and LIMIT is not larger than dataset area by half box
   ; size on each size (phs, 12/19/07).
   ;
   ; We assumed the LIMIT defines the edges of the grid covered by
   ; data. Note that the case of both X/Y and LIMIT choosen by the
   ; program is a global case and is already handled above.
   ; NOTE: this expansion makes sense only if coarse pixel, and
   ; its effect are visible with small data set.
   ; ## for now do not expand if is IS_POLAR        ##
   ;====================================================================
   if ( IS_POLAR ) then NeedPadding = 0

   if (     ( NeedPadding * sample )   AND $
         not( fcontour or Mcontour ) ) then begin

      ; prevent from padding longitudes twice (phs,2/28/08) 
      if ( not EntireGlobe ) then begin
         TmpData =  [ TmpData[0, *],       TmpData,  TmpData[Sdata[0]-1, *]    ]
         XArr    =  [ XArr[0] - 2.*HalfX,  XArr,     XArr[SXArr-1] + 2.*HalfX  ]
         SXArr   =  SXArr + 2
      endif


      TmpData =  [ [ TmpData[*, 0] ], [ TmpData ], [TmpData[*, Sdata[1]-1]] ]
      YArr    =  [ ( YArr[0]       - 2.*HalfY ) ,  YArr,  $
                   ( YArr[SYArr-1] + 2.*HalfY )           ]
      SYArr   =  SYArr + 2

      expanded = 1b

   endif else expanded = 0b

   ;=====================================================================
   ; MIN & MAX of useful DATA
   ;=====================================================================

   ; Save value from M_MINDATA keyword var into MINDATA local var
   ; If M_MINDATA is not passed, then take min of TMPDATA array
   if ( N_Elements( M_MinData ) gt 0 ) $
      then MinData = M_MinData         $
      else MinData = Min( TmpData )

   ; Save value from M_MAXDATA keyword var into MAXDATA local var
   ; If M_MAXDATA is not passed, then take MAX of TMPDATA array
   if ( N_Elements( M_MaxData ) gt 0 ) $
      then MaxData = M_MaxData         $
      else MaxData = Max( TmpData )

   ; Identify values < MIN_VALID and reset MINDATA
   if ( Is_Min_Valid_Used ) then begin
      MinVInd = Where( TmpData lt Min_Valid )
      if ( MinVInd[0] ge 0 ) then begin
         if ( ~( MContour OR FContour ) and Sample ) $
            then TmpData[MinVInd] = Min_Valid
         MinData = Min_Valid
      endif
   endif else begin
      MinVInd = -1L
   endelse

   ; Identify values > MAX_VALID and reset MAXDATA
   if ( Is_Max_Valid_Used ) then begin
      MaxVInd = Where( TmpData gt Max_Valid )
      if ( MaxVInd[0] ge 0 ) then begin
         if ( MContour OR FContour )           $ 
            then TmpData[MaxVInd] = MinData-1. $
            else if ( Sample ) then TmpData[MaxVInd]=Max_Valid
         MaxData = Max_Valid
      endif
   endif else begin
      MaxVInd = -1L
   endelse

   ;====================================================================
   ; Return if TMPDATA is not a 2-D array
   ;====================================================================
   sd = size( TmpData, /Dimensions )
   if ( n_elements(sd) ne 2 ) then begin
      Message, 'No valid 2-D data to plot!', /Continue
      return
   endif


   ;====================================================================
   ;====================================================================
   ;
   ;                            START PLOTTING
   ;
   ;====================================================================
   ;====================================================================

   ;====================================================================
   ; (1) Set up the Map Projection for all plot types
   ;
   ; Default map projection is "cylindrical".
   ; If /POLAR is set, then will plot a "stereographic" projection.
   ;
   ; [Obsolete] Note that the Isoptropic keyword is only needed for 
   ; contour plots and must not be set for pixel plots which are sized
   ; with the position keyword.
   ;====================================================================
   if ( CONUS ) then begin
   
      ;---------------------------------------
      ; Special handling for CONUS region
      ;---------------------------------------

      ; If the user specified labels, then turn on box-axes.  This
      ; is the simplest way to plot labels w/ CONUS. (bmy, 12/3/07)
      if ( GxLabels OR GYLabels ) then Box_Axes = 1
   
      ; Now turn off default map labels and define CONUS_LON & CONUS_LAT
      ; arrays for use with MAP_GRID below (bmy, phs, 12/3/07)
      GXLabels  = 0
      GYLabels  = 0
      ConUS_Lon = -130 + ( Indgen(8) * 10 )
      ConUS_Lat =   20 + ( Indgen(8) * 5  )

      ; Define limit to fit entire continental US in window
      Limit     = [ 25, -122, 50, -72 ]
      ConUS_Y   = 0.5 * ( Limit[0] + Limit[2] )
      ConUS_X   = 0.5 * ( Limit[1] + Limit[3] )

      ; Plot the continental US map -- Lambert projection
      Map_Set, Conus_Y, Conus_X, 0,                                   $
         Position=MPosition, Grid=0,     Continents=0, Limit=Limit,   $
         /Lambert,           /Isotropic, /NoErase,     /NoBorder,     $
         Color=MColor,       /Horizon,   USA=0,        _EXTRA=e

   endif else begin

      ;---------------------------------------
      ; All other map projections
      ;---------------------------------------

      ; Turn off default lon & lat labels for /BOX_AXES (bmy, 12/3/07)
      if ( Box_Axes ) then begin
         GXLabels = 0
         GYLabels = 0
      endif

      ; General Mapping Options
      Map_Set, P0lat, P0lon, Rot,                                     $
         Position=MPosition,     Continents=0, Grid=0,                $
         /NoErase,               /NoBorder,    XMargin=0,             $
         YMargin=0,              Color=MColor, Limit=Limit,           $
         StereoGraphic=Is_Polar, USA=0,        Isotropic=Isotropic,   $
         Scale=ScaleMS,          _EXTRA=e

   endelse

   ; Read the window Position of the map from system variables
   ; This was previously defined withing the IF statement below, but
   ; the plot position doesn't change after MAP_SET, immediately above
   MapPosition = [ !X.Window[0], !Y.Window[0], $
                   !X.Window[1], !Y.Window[1] ]

   ; Adjust position of colorbar so that it is placed 0.05 below or
   ; 0.02 right to the plot. This account for /isotropic consequences.
   ; Broad assumption that we are using below/right plot: so, do
   ; nothing if CB was first set by input keyword.
   ; NOTE: Add a little extra space for the /BOX_AXES option
   ; (phs, bmy, 12/3/07)
   if ( NCBPos NE 4 ) then begin
      if ( CBVertical ) then begin
         cwy           = CBPosition[2]  -CBPosition[0]
         CBPosition[0] = MapPosition[2] + 0.02
         if ( Box_Axes ) then CBPosition[0] = CBPosition[0] + 0.03
         CBPosition[2] = CBPosition[0]  + cwy
      endif else begin
         cwy           = CBPosition[3]  - CBPosition[1]
         CBPosition[3] = MapPosition[1] - 0.05
         CBPosition[1] = CBPosition[3]  - cwy
      endelse
   endif

   ;====================================================================
   ; Switches for different types of plots
   ;====================================================================

   if ( MContour OR FContour ) then begin

      ;=================================================================
      ; Call MAP_CONTINENTS for filled continents at this point
      ; (they only make sense in contour plots)
      ;=================================================================
      if ( Draw_Continents AND CFill ge 1 ) then begin
         Map_Continents, Color=CColor, Fill=CFill, USA=USA, _EXTRA=e
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
      NCL  = N_Elements( C_Levels )

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
      ; If /FCONTOUR is set, then create a filled-contour
      ; plot atop the world map created above.
      ;=================================================================
      if ( FContour ) then begin
         Contour, TmpData, XArr, YArr,           $
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
      ; FOR SMOOTH PIXEL PLOTS ONLY -- do the smoothing
      ;=================================================================
      if ( not Sample ) then begin

         ; Compute dithering factor (10 to 200)
         ; Formula may need to be improved (later on...)
         S      = Size( TmpData, /Dim )
         BlowUp = 10 * ( ( Fix( 50/Min(S) ) > 1 ) < 20 )

         ; If the image has more than 200,000 pixels, then don't blow
         ; it up, since we will probably run out of memory (bmy, 5/8/02)
         if ( N_Elements( TmpData ) gt 200000L ) then BlowUp = 1

         ; Although MAP_IMAGE will use bilinear interpolation, pixels
         ; are still too coarse, and we need to increase the
         ; resolution for all devices. Use CONGRID instead of REBIN,
         ; because we can use /MINUS_ONE to ensure evenly spaced
         ; output (phs, 19/12/07)
         TmpData = Congrid( TmpData, S[0]*BlowUp, S[1]*BlowUp, $
                                     /Minus_one,  /Interp )

         ; Need to find WHERE values < MIN_VALID and > MAX_VALID again
         ; (phs, 12/21/07)
         if ( Is_Min_Valid_Used ) then MinVInd = Where( TmpData lt Min_Valid )
         if ( Is_Max_Valid_Used ) then MaxVInd = Where( TmpData gt Max_Valid )

      endif     

      ;=================================================================
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

      ; Missing data values -- set to Top/BotOutOfRange color index
      if ( MinVInd[0] ge 0 ) then Image[ MinVInd ] = abs(BOOR) 
      if ( MaxVInd[0] ge 0 ) then Image[ MaxVInd ] = abs(TOOR) 

      ; If negative Top/BotOutOfRange, do not plot the box for Out of
      ; range data (phs, 4/17/08)
      If ( Is_defined( BOOR ) ) then If ( BOOR lt 0L ) then undefine, BOOR
      If ( Is_defined( TOOR ) ) then If ( TOOR lt 0L ) then undefine, TOOR

      ; Now wrap the Image on the Map and then call TV
      ; MAP_IMAGE can use nearest-neighbor or bilinear interpolation
      ; to fill the image map
      Bilinear = 1 - Sample

      ; Make sure that LonMax > LonMin for plots over the dateline to
      ; be correct (phs, 11/15/07)
      LonMin = XArr[0]
      LonMax = XArr[SXArr-1]
      Latmin = YArr[0]
      LatMax = YArr[SYArr-1]

      while ( lonMax le LonMin ) do LonMax = LonMax + 360.
      
      ; Wrap the image onto the map.  NOTE: The default SCALE value
      ; for MAP_IMAGE is 0.02 pixels/device coordinate.  You may 
      ; pass a different value for SCALE via the SCALEMapImage keyword.
      ; (phs, bmy, 2/28/08)
      ; Set 0.04 pixels/device coordinate as default for PS (phs,6/13/08)
      if n_elements(scaleMI) eq 0 and !d.name eq 'PS' then scaleMI=0.04

      MappedImage = Map_Image( Image, Startx, Starty, Xsize, Ysize, $
                               LonMin=LonMin, LonMax=LonMax,        $
                               LatMin=LatMin, LatMax=LatMax,        $
                               Compress=1,    Bilinear=Bilinear,    $
                               Scale=ScaleMI, _EXTRA=e )

      ; Requires a newer version of TVIMAGE that accept the TV
      ; keyword. By setting /TV, KEEP_ASPECT_RATIO and POSITION
      ; are ignored. Needs /overplot to keep Map Projection active.
      TVImage, MappedImage, StartX, StartY, $
         XSize=XSize, YSize=YSize, /TV, /OverPlot, _EXTRA=e

;------------------------------------------------------------------------------
; Prior to 11/19/07:
;         ; Alternatively, you can display the warped data image using
;         ; TV. May not be device independent...
;         TV, MappedImage, StartX, StartY, XSize=XSize, YSize=YSize
;------------------------------------------------------------------------------


   ;====================================================================
   ;====================================================================
   ;
   ;                            END PLOTTING
   ;
   ;====================================================================
   ;====================================================================
   endelse

   ;====================================================================
   ; Overlay title on the plot
   ;====================================================================
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

   ; Plot the title!
   xyouts,xpmid,yptop,mtitle,color=MColor,/norm,align=0.5,  $
         charsize=TitleCsFac*csfac, _EXTRA=e

   ;====================================================================
   ; Call MAP_CONTINENTS to plot (or fill in) the continents
   ;====================================================================
   if ( Draw_Continents AND $
        ( not MContour OR ( MContour AND CFill eq 0 ) ) ) then begin
          Map_Continents, Color=CColor,  Fill=CFill,            $
                          Coasts=Coasts, Countries=Countries,   $
                          USA=USA,       Continents=Continents, $
                          _EXTRA=e
   endif

   ;====================================================================
   ; Call MAP_HORIZON to add a horizon line to the map.  Use this 
   ; feature if the map projection is ellptical or interrupted.
   ; (cdh, phs, bmy, 11/27/07)
   ;====================================================================
   if ( Horizon ) $
      then Map_Horizon, Position=MapPosition, Color=CColor, _EXTRA=e

   ;====================================================================
   ; For non-polar plots, plot a rectangular border around the edge of 
   ; the map, without inserting any "cushion" space.  Override default 
   ; behavior thru RECTANGLE keyword. (phs, 11/13/07)
   ;
   ; NOTE: Use the variable RRECTANGLE internally for the /RECTANGLE
   ; keyword to avoid namespace confusion with the "rectangle.pro" 
   ; routine. (bmy, 11/19/07)
   ;
   ; ALSO NOTE: If /HORIZON is set then don't draw the rectangle,
   ; since HORIZON is meant to be used for map projections whose
   ; boundaries are not rectangular (cdh, phs, bmy, 11/19/07)
   ;====================================================================
   if ( N_Elements( RRectangle ) ne 0 )           $
      then RRectangle = Keyword_Set( RRectangle ) $
      else RRectangle = 1 - Is_Polar
   
   if ( RRectangle and not Horizon ) then begin
       Rectangle, MapPosition, XPoints, YPoints
       PlotS, XPoints, YPoints, Thick=2, Color=MColor, /Normal
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

      ; now account for LIMIT passed with 8-elements (cdh, 3/20/08)
      If n_elements( LIMIT ) eq 8 then begin
         LatRange = [ min( Limit[[0, 2, 4, 6]] ), max(Limit[[0, 2, 4, 6]] ) ]
         LonRange = [ min( Limit[[1, 3, 5, 7]] ), max(Limit[[1, 3, 5, 7]] ) ]
      endif else begin
         LatRange = [ Limit[0], Limit[2] ]
         LonRange = [ Limit[1], Limit[3] ]
      endelse 
      
      ;### Debug output
      if ( Debug ) then begin
         print, '### TVMAP : Limit    : ', Limit
         print, '### TVMAP : LatRange : ', LatRange
         print, '### TVMAP : LonRange : ', LonRange
      endif

      Map_Labels, LatLabel, LonLabel,                $
         Lats=Lats,         LatRange=LatRange,       $
         Lons=Lons,         LonRange=LonRange,       $
         NormLats=NormLats, NormLons=NormLons,       $
         /MapGrid,          MapPosition=MapPosition, $
         _EXTRA=e

      ;=================================================================
      ; For Polar plots, do the following:
      ; (1) Only keep the 0-degree longitude label
      ; (2) If the latitude range spans more than 60 degrees,
      ;     just use print out labels for [30, 60, 90] degrees.
      ;=================================================================
      if ( Is_Polar ) then begin
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
      ; Now print every nth label (phs, 5/6/08)
      if ( GYLabels gt 0 ) then begin
         nl = (size(NormLats))[2]
         IndSelect = lindgen( nl/gylabels + $
                              ((nl-1) mod gylabels eq 0 and gylabels ne 1) ) $
                     * gylabels
         XYOutS, NormLats[0, IndSelect], NormLats[1, IndSelect], LatLabel[IndSelect], $
                 Align=1.0, Color=MColor, /Normal, charsize=csfac, _EXTRA=e
      endif

      ; Print X-axis labels unless /NOGXLABELS is set (bmy, 7/2/01)
      ; Now print every nth label (phs, 5/6/08)
      if ( GXLabels gt 0 ) then begin
         nl = (size(NormLons))[2]
         IndSelect = lindgen( nl/gxlabels + $
                              ((nl-1) mod gxlabels eq 0 and gxlabels ne 1) ) $
                     * gxlabels
         XYOutS, NormLons[0, IndSelect], NormLons[1, IndSelect], LonLabel[IndSelect], $
                 Align=0.5, Color=MColor, /Normal, charsize=csfac, _EXTRA=e
      endif

   endif

   ; Only print out grid lines if /GRID is set.  
   ; Special treatment for CONUS projection (bmy, 12/3/07)
   if ( Grid ) then begin
      if ( CONUS ) then begin
         Map_Grid, Color=GColor,   Box_Axes=Box_Axes,        $
                   Lats=ConUS_Lat, Lons=ConUS_Lon,   _EXTRA=e 
      endif else begin
         Map_Grid, Color=GColor,   Box_Axes=Box_Axes,        $
                   Lats=Lats,      Lons=Lons,        _EXTRA=e
 
      endelse
   endif

   ;====================================================================
   ; Call COLORBAR to plot the colorbar below the map
   ; Otherwise, just print the unit string below the X-axis labels
   ;====================================================================
   if ( CBar ) then begin

      ; if C_LEVELS is defined then add 1 element for CBar (phs,7/27/07)
      if ( n_elements( C_Levels) gt 0 ) then $
         C_Levels2 = [ C_Levels, 2*C_Levels[ncl-1]-C_Levels[ncl-2] ]

      if ( N_Elements( CBMin ) eq 0 ) then CBMin = MinData
      if ( N_Elements( CBMax ) eq 0 ) then CBMax = MaxData

      ; CB range if Out-of-Range data (Max/Min_Valid) are defined 
      if ( Is_Min_Valid_Used )        then CBMin = Min_Valid
      if ( Is_Max_Valid_Used )        then CBMax = Max_Valid
      
      ; Draw the colorbar.  You can now specify a different color than
      ; white for bottom-out-of-range or top-out-of-range (phs, 4/18/08)
      ColorBar, BotOutOfRange=BOOR,  TopOutOfRange=TOOR,                       $
                Max=CBMax,           Min=CBMin,           NColors=NColors,     $
                Bottom=Bottom,       Color=CBColor,       Position=CBPosition, $
                Unit=CBUnit,         Divisions=Divisions, Log=Log,             $
                Format=CBFormat,     Charsize=csfac,      TickLen=CBTickLen,   $
                C_Colors=CC_Colors,  C_Levels=C_Levels2,  Vertical=CBVertical, $
                _EXTRA=e

   endif else begin
      XPos = ( MPosition[2]  + MPosition[0]  ) * 0.5
      YPos = ( CBPosition[3] + CBPosition[1] ) * 0.5

      XYOutS, XPos, YPos, CBUnit, /Normal, $
         Align=0.5, Color=MColor, CharSize=CsFac, _EXTRA=e
   endelse

   ;====================================================================
   ; At this point, the plotting coordinates in the display window are
   ; determined by COLORBAR.  Re-establish the mapping coordinates so 
   ; that data can be plotted on the map, rather than on the colorbar, 
   ; after TVMAP returns. (cdh, 11/7/2007)
   ;====================================================================
   if ( CONUS ) then begin

      ; The CONUS Projection has a defined region and parameters
      Map_Set, Conus_Y, Conus_X, 0,      $ ; Standard_Parallels=ConUs_Sp, $
         Position=MPosition, Grid=0,     Continents=0,    Limit=Limit,   $
         /Lambert,           /Isotropic, /NoErase,        /NoBorder,     $
         Color=MColor,       USA=0,      Scale=ScaleMS, _EXTRA=e

   endif else begin

      ; General Mapping Options 
      ; Set Color = MColor instead of 0 (phs, 1/4/08)
      Map_Set, P0lat, P0Lon, Rot,                                     $
         Position=MPosition,     Continents=0,        Grid=0,         $
         /NoErase,               /NoBorder,           XMargin=0,      $
         YMargin=0,              Color=MColor,        Limit=Limit,    $
         StereoGraphic=Is_Polar, Isotropic=Isotropic, USA=0,          $
         Scale=ScaleMS,          _EXTRA=e

   endelse

   ;====================================================================
   ; Advance to the next plot position for the next plot
   ; Use NoErase so that we still see the results when the page is full
   ; (will be erased when we do next plot after page is full)
   ;====================================================================
   WindowPosition = MapPosition

   ; Now only advance to the next frame if NOADVANCE=0 (bmy, 10/31/01)
   if ( Advance ) then MultiPanel, Advance=Advance, /NoErase

   ; Return C_Colors back to the calling program (bmy, 5/21/04)
   if ( N_Elements( CC_Colors ) gt 0 ) then C_Colors = CC_Colors

   ; Reset input XARR if wrapped around the globe (phs, 11/27/07)
   if ( EntireGlobe ) then begin
      Xarr  = Xarr[0:SXArr-2]
      SxArr = SxArr - 1
   endif

   ; Reset input XARR/YARR if it has been expanded. (phs, 11/27/07)
   if ( Expanded ) then begin
      if ( not EntireGlobe ) then Xarr  = XArr[1:SXArr-2]
      Yarr  = YArr[1:SYArr-2]
   endif

   return
end
