; $Id: tvplot.pro,v 1.3 2004/06/03 17:58:12 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        TVPLOT
;
; PURPOSE:
;        TVPLOT produces one of the following plots:
;          (1) A color-pixel image,   overlaid atop X-Y plot axes
;          (2) A line-contour plot,   overlaid atop X-Y plot axes
;          (3) A filled-contour plot, overlaid atop X-Y plot axes
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        TVPLOT, Data, Xarr, Yarr, [, keywords ]
;
; INPUTS:
;        DATA -> 2-D array of values to be plotted.
;        
;        XARR -> array of X-axis (horizontal axis) values needed to
;             construct the plot.  The number of elements in XARR must
;             equal the number of elements of the first dimension of DATA.
;
;        ZARR -> ZARR is the array of Z-axis (vertical axis) values
;             needed to construct the plot.  The number of elements
;             in ZARR must equal the number of elements of the second
;             dimension of DATA.  If ZARR[0] > ZARR[N_Elements(ZARR)-1]
;             then TVPLOT will assume pressure is to be plotted on the
;             Y-axis.
;
; KEYWORD PARAMETERS:
;        BLACK -> The color index corresponding to black.
;             Default is !MYCT.BLACK (from !MYCT system variable.)
;
;        /ERASE -> If set, will erase the graphics device before plotting 
;             the color image (or contour plot) and world map.
; 
;        CSFAC -> Character size for the map labels and plot titles. 
;             Default settings for CSFAC vary according to the number 
;             of plots per page and type of plot device.
;
;        /NOADVANCE -> Set this switch to prevent TVMAP from advancing
;             to the next plot panel on the page.  This is useful if
;             you desire to overplot something atop the pixel plot or
;             contour plot.
;
;        _EXTRA=e -> Picks up extra keywords (not listed below) for
;             BYTSCL, COLORBAR, TVIMAGE, MAP_SET, MAP_GRID,
;             MAP_CONTINENTS, and CONTOUR.
;
;
;    Keywords for both BYTSCL and COLORBAR:
;    ======================================
;        MAXDATA -> Maximum value of the DATA array to use in the
;             byte scaling.  Default is max( DATA ).
;
;        MINDATA -> Minimum value of the DATA array to use in the
;             byte scaling.  Default is min( DATA ).
;
;        BOTTOM -> The lowest color index of the colors to be used
;             for byte-scaling the color map and colorbar.  Default 
;             is !MYCT.BOTTOM (from the !MYCT system variable).
;
;        NCOLORS -> This is the maximum color index that will be used.
;             Default is !MYCT.NCOLOR (from the !MYCT system variable).
;
;        /LOG -> Will create a color-pixel plot with logarithmic
;             scaling.  /LOG has no effect on line-contour or
;             filled-contour plots, since the default contour levels
;             are logarithmic.
;
;
;    Additional keywords for COLORBAR:
;    =================================
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
;             the colorbar range.  If not set, TVPLOT will set 
;             CBMIN = min( DATA ) and CBMAX = max( DATA ).
;
;        CBTICKLEN -> Specifies the color bar tick length as a
;             fraction of the colorbar height (for horizontal
;             colorbars) or width (for vertical colorbars).
;
;        DIVISIONS -> Number of labels for the colorbar.  Default is 4.
;
;
;    Keywords for REBIN:
;    ===================
;        /SAMPLE -> Used to rebin the byte-scaled image array to a 
;             larger size, for the PostScript printer.   If /SAMPLE is 
;             set, then REBIN will use nearest-neighbor sampling
;             rather than bilinear interpolation, which will result in
;             a coarse pixel plot.  
;
;
;    Keywords for PLOT:
;    ===================
;        POSITION -> A four-element array of normalized coordinates
;             that specifies the location of the map.  POSITION has
;             the same form as the POSITION keyword on a plot. 
;             Default is [0.1, 0.1, 0.9, 0.9]. 
;
;        TITLE -> The title string that is to be placed atop the
;             plot window.  TITLE is passed explicitly to avoid keyword
;             name duplication in the _EXTRA=e facility.
;  
;        COLOR -> Color index for the plot window outline and titles.  
;             Default is BLACK.
;
;        XSTYLE, YSTYLE -> Style settings for the X and Y axes.  See 
;             the "Graphics Keywords" settings man page for more info.
;             XSTYLE and YSTYLE are passed as explicit keywords to
;             avoid keyword name confusion in the _EXTRA=e facility. 
;
;        XRANGE, YRANGE -> Two-element vectors for the X-axis and Y-axis 
;             plot ranges, of the form [Xmin,Xmax] and [YMin,Ymax].
;             XRANGE and YRANGE are passed as explicit keywords to
;             avoid keyword name confusion in the _EXTRA=e facility. 
;
;        XTITLE, YTITLE -> Titles for the X and Y axes.  XTITLE and 
;             YTITLE are passed as explicit keywords to avoid keyword 
;             name confusion in the _EXTRA=e facility. 
;
;
;    Keywords for CONTOUR:
;    =====================
;        /CONTOUR -> Will produce a line-contour map instead of the 
;             default color-pixel image map.
;
;        /FCONTOUR -> Will produce a filled-contour map instead
;             of the default color-pixel image map.
;
;        C_LEVELS -> Vector containing the contour levels.  If not
;             specified, will use preset default levels (see below).
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
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==================================================
;        COLORBAR              GET_DEFAULTFORMAT (function)        
;        INV_INDEX (function)  LOGLEVELS (function)  
;        TVIMAGE          
;        
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) The _EXTRA facility picks extra keywords for BYTSCL,
;            TVIMAGE, PLOT and COLORBAR, etc...  This is a new 
;            feature in IDL v. 5.0+!! 
;
;        (2) For contour plots, contour labels will be specified
;            using the C_ANNOTATION keyword.  The downside is that
;            by using C_ANNOTATION, this disables the C_LABELS keyword
;            and so one cannot specify which contour lines will get
;            labels.  The solution would be to expand the C_LABELS
;            vector so that it has the same number of elements as
;            C_ANNOTATION, and then to individually zero the
;            corresponding elements of C_ANNOTATION before making
;            the contour plot.  Don't have enough time for this now,
;            but maybe can deal with this at a later time...
;
; EXAMPLE:
;        POSITION   = [0.1, 0.1,  0.9, 0.9 ] ; position for map
;        CBPOSITION = [0.1, 0.05, 0.9, 0.08] ; position for colorbar
;
;        TVPLOT, DATA, XARR, YARR,                           $
;               MAXDATA=MAXDATA,    MINDATA=MINDATA,         $
;               POSITION=POSITION,  CBPOSITION=CBPOSITION,   $
;               /ERASE,             TITLE='Avg O3',          $
;               XTITLE='Longitude', YTITLE='Altitude',       $
;               DIVISIONS=4,        FORMAT='(F6.2)'
;
; MODIFICATION HISTORY:
;        bmy, 27 Apr 1998:  VERSION 1.00
;        bmy, 04 Jun 1998:  - now can plot separate X or Y axes
;                             if [XY]STYLE = 4 or 8
;        mgs, 15 Jun 1998:  - bug fix n_elements instead of keyword_set
;                           - now does spline interpolation in the
;                             vertical in order to get correct
;                             altitudes
;        bmy, 21 Sep 1998:  - Rename EXTRA1, EXTRA2, etc, to names
;                             that have more meaning (e.g. E_BYT for
;                             BytScl, E_TV for TVImage, etc.)
;        bmy, 22 Sep 1998:  VERSION 1.10
;                           - now uses _EXTRA=e facility to pass extra
;                             keywords to BYTSCL, TVIMAGE, PLOT, and
;                             COLORBAR.
;                           - add PLOTTITLE (for PLOT) and UNIT (for
;                             COLORBAR) keywords to prevent keyword
;                             name duplication in _EXTRA=e.
;        mgs, 11 Nov 1998:  - added CBar keyword
;        bmy, 16 Nov 1998:  VERSION 2.00
;                           - now can produce line-contour and filled-
;                             contour plots as well as image plots
;                           - now calls REBIN to rebin the byte-scaled
;                             image array to higher resolution for
;                             PostScript output.
;                           - added the following keywords: /LOG,
;                             /SAMPLE, /CONTOUR, /FCONTOUR, C_ANNOTATION,
;                             C_LEVELS, C_LABELS, /NOLABELS, /NOLINES, 
;        bmy, 17 Nov 1998:  - For image plots, now only display plot axes
;                             AFTER the image plot has been made.  This
;                             reduces the "apparent" wait time for the 
;                             user.
;                           - renamed keywords to XA_TITLE, XA_RANGE, 
;                             XA_TICKNAME, etc to avoid keyword name
;                             duplication in the _EXTRA=e facility.
;        mgs, 17 Nov 1998:  - added CBFormat keyword
;        bmy, 18 Nov 1998:  - also added floating point format for 
;                             CBFORMAT when abs(max(Data)) < 10
;        mgs, 19 Nov 1998:  - CBFormat no whandled in colorbar.pro
;        bmy, 27 Jan 1999:  - added defaults for XRANGE and YRANGE
;        bmy, 08 Jan 1999:  - If /LOG is set, make sure that we don't
;                             take the log of zero and incur a math error
;                           - add call to function INV_INDEX  
;        mgs, 18 Mar 1999:  - cleaned up
;                           - now uses loglevels and has smarter default 
;                             contour levels
;        mgs, 22 Mar 1999:  - added multi-panel ability through use of
;                             the new MULTIPANEL routine. This alters the
;                             meaning of MPosition and CB_Position: they now
;                             refer to positions in the current plot panel!
;        mgs, 23 Mar 1999:  - fixed a few minor things
;                           - charsize is now adjusted according to number
;                             of panels on page
;        bmy, 25 Mar 1999:  - now use updated GET_DEFAULTFORMAT
;                           - if NPANELS >=2 then place the plot title
;                             higher above the window, to allow for 
;                             carriage-returned lines
;                           - updated comments
;        bmy, 27 Apr 1999:  - commented out !x.charsize=csfac and
;                             !y.charsize=csfac lines...these messed
;                             up the plot window sizes
;                           - updated comments
;        bmy, 28 Apr 1999:  - added CBMin and CBMax keywords for 
;                             tighter colorbar control
;        mgs, 19 May 1999: - title shifted a little higher if it has
;                            more than 1 line.
;        mgs, 21 May 1999: - variable name for TITLE now MTITLE as in
;                            TVMAP.
;        mgs, 27 May 1999: - changed default behaviour for filled contours:
;                            now plots "discrete" colorbar and no lines.
;                            Keyword NoLines changed to C_Lines.
;        bmy, 10 Jun 1999: - CBUnit defaults to '
;        mgs, 06 Jul 1999: - adjusted charsize for multipanel plots
;        bmy, 07 Jul 1999: - Save C_COLORS in a temp variable.  Also
;                            define C_COLORS so that grayscales won't
;                            appear in Postscript plots
;                          - multi-panel plots are now well-separated
;                            from each other (for PostScript output)
;        bmy, 08 Jul 1999: - more minor fixes
;        bmy, 18 Nov 1999: - increase default left margin by a little
;        bmy, 31 Mar 2000: GAMAP VERSION 1.45
;                          - made CSFAC a keyword
;        bmy, 23 Jul 2001: GAMAP VERSION 1.48
;                          - now call MYCT_DEFAULTS to specify default
;                            values for BLACK, BOTTOM, NCOLORS, etc
;                            if these keywords are not passed explicitly.
;        bmy, 07 Jul 2001: - removed obsolete code from 1998 and 1999
;        bmy, 31 Oct 2001: GAMAP VERSION 1.49
;                          - add /NOADVANCE keyword to prevent advancing
;                            to the next page (in case you want to overplot)
;        bmy, 28 Sep 2002: GAMAP VERSION 1.51
;                          - now gets MYCT default parameters from the
;                            !MYCT system variable
;        bmy, 15 Nov 2002: GAMAP VERSION 1.52
;                          - Added MIN_VALID keyword to skip missing
;                            data values for pixel plots
;        bmy, 18 Dec 2003: - For pixel plots, now linearly interpolate
;                            when creating NDATA instead of using a
;                            cubic spline.  This is more accurate.
;                          - Prevent NDATA from being extrapolated wildly
;                            due to the slope at the surface and top level
;                            of the plot.  
;        bmy, 06 Jan 2003: - Now interpolate NDATA correctly when pressure
;                            or altitude is on the Y-axis.
;                          - Removed obsolete keywords XA_TITLE, YA_TITLE,
;                          - XA_RANGE, YA_RANGE, XA_TICKNAME, YA_TICKNAME
;                          - Now define default YRANGE = [ ZBOT, ZTOP ]
;                            to make Y-axis labels correct for both pressure
;                            and altitude on the Y-axis.
;                          - Removed ZBOT, ZTOP from the keyword list; 
;                            these are now internal variables. 
;                          - updated comments
;        bmy, 02 Mar 2004: GAMAP VERSION 2.02
;                          - added MARGIN keyword a la TVMAP
;                          - added OMARGIN keyword
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
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine tvplot"
;-----------------------------------------------------------------------


pro TVPlot, Data,  XArr,  ZArr,                                   $
            BLACK=BLACK,               Erase=Erase,               $
            MaxData=MaxData,           MinData=MinData,           $
            NColors=NColors,           Bottom=Bottom,             $
            CBar=CBar,                 CBPosition=CBPosition,     $
            CBColor=CBColor,           CBUnit=CBUnit,             $
            CBFormat=CBFormat,         CBTickLen=CBTickLen,       $
            CBMin=CBMin,               CBMax=CBMax,               $
            Divisions=Divisions,       Log=Log,                   $
            Sample=Sample,             Position=MPosition,        $
            Margin=Margin,             OMargin=OMargin,           $
            Title=MTitle,              Color=MColor,              $
            XStyle=XStyle,             YStyle=YStyle,             $
            XRange=XRange,             YRange=YRange,             $
            XTitle=XTitle,             YTitle=YTitle,             $
            Contour=MContour,          FContour=FContour,         $
            C_Levels=C_Levels,         C_Colors=C_Colors,         $
            C_Annotation=C_Annotation, C_Format=C_Format,         $
            C_Labels=C_Labels,         C_Lines=C_Lines,           $
            NoLabels=NoLabels,         OverLayColor=OverLayColor, $
            CsFac=CsFac,               Min_Valid=Min_Valid,       $
            NoAdvance=NoAdvance,       _EXTRA=e

   ;====================================================================
   ; Pass external functions (bmy, 2/8/99)
   ;====================================================================
   FORWARD_FUNCTION Inv_Index, LogLevels, Get_DefaultFormat
 
   ;=================================================================
   ; NPANELS = number of plots per page
   ;
   ; PSOFFSET will raise the plot window a little for PostScript 
   ; plots so that we have room for the colorbar.
   ;
   ; Also, set PSOFFSET to a small number if NPLOTS gt 4 for non-
   ; PostScript plots.  This will keep the colorbar from interfering
   ; with the plot window on the screen.
   ;=================================================================
   npanels = !p.multi[1]*!p.multi[2]

   if ( !D.NAME eq 'PS' ) then begin
      psoffset = 0.02
      if ( NPanels ge 3    ) then PSOffset = PSOffset * 2.0
      if ( NPanels ge 9    ) then PSOffset = PSOffset * 3.0
   endif else begin
      PSOffset = 0.0
      if ( NPanels gt 4 ) then PSOffset = 0.02
   endelse
 
   ;====================================================================
   ; Error Checking: Arguments
   ;====================================================================
   TmpData = reform(Data)
   SData = Size( reform(TmpData), /Dimensions )
   if ( N_Elements(SData) ne 2 ) then begin
      Message, 'DATA must be a 2-D array!!!', /Continue
      return
   endif

   ; Index arrays for horizontal and vertical dimensions
   if ( N_Elements( XArr ) eq 0 ) then XArr = FindGen( SData[0] )
   if ( N_Elements( ZArr ) eq 0 ) then ZArr = FindGen( SData[1] )

   ; Number of elements of ZARR (bmy, 1/6/03)
   N_ZArr = N_Elements( ZArr )

   ;====================================================================
   ; Error Checking: Keywords
   ;====================================================================

   ; ZBOT and ZTOP should not be the max & min of ZARR, but rather the
   ; bottom and top elements of ZARR.  This will ensure that the interpolation
   ; is done correctly for pressure and altitude on the Y-axis. (bmy, 1/6/03)
   ZBot = ( ZArr[0] - 0.5 ) > 0
   ZTop = ZArr[N_ZArr-1L]

   ; Keywords for TVPLOT
   if ( N_Elements( BLACK      ) eq 0 ) then BLACK   = !MYCT.BLACK
   
   ; Keywords for BYTSCL and COLORBAR
   if ( N_Elements( MaxData    ) eq 0 ) then MaxData = max( TmpData )
   if ( N_Elements( MinData    ) eq 0 ) then MinData = min( TmpData )
   if ( N_Elements( Bottom     ) eq 0 ) then Bottom  = !MYCT.BOTTOM 
   if ( N_Elements( NColors    ) eq 0 ) then NColors = !MYCT.NCOLORS 
   Log = Keyword_Set( Log )

   ; Extra keywords for COLORBAR
   if ( N_Elements( CBar       ) eq 0 ) then CBar    = 0
   if ( N_Elements( CBColor    ) eq 0 ) then CBColor = BLACK

   ; Colorbar position vector
   if ( N_Elements( CBPosition ) eq 0 ) then begin

      ; Standard colorbar position
      CBPosition = [ 0.20, 0.01, 0.80, 0.04 ]   

      ; Small Y-offset for more than 4 contour plots per page
     if ( NPanels gt 4 ) then begin
         CBPosition[1] = CBPosition[1] - 0.03
         CBPosition[3] = CBPosition[3] - 0.03 
      endif

      ; Bigger Y-offset for more than 9 contour plots per page
      if ( NPanels gt 9 ) then begin
         CBPosition[1] = CBPosition[1] - 0.05
         CBPosition[3] = CBPosition[3] - 0.05 
      endif
   endif

   if ( N_Elements( Divisions ) eq 0 ) then Divisions = 4
   if ( N_Elements( CBUnit    ) eq 0 ) then CBUnit    = ''

   ; Keywords for CONTOUR
   MContour = Keyword_Set( MContour )
   FContour = Keyword_Set( FContour )

   ; Keywords for PLOT
   if ( N_Elements( MColor ) eq 0 ) then MColor = BLACK          
   if ( N_Elements( MTitle ) eq 0 ) then MTitle = ''
   if ( N_Elements( XStyle ) eq 0 ) then XStyle = 0
   if ( N_Elements( YStyle ) eq 0 ) then YStyle = 0
   if ( N_Elements( XRange ) eq 0 ) then XRange = [ Min( Xarr, Max=M ), M ]
   if ( N_Elements( YRange ) eq 0 ) then YRange = [ ZBot, ZTop ]

   ; If the MPOSITION keyword isn't specified, define a default
   ; position vector, leaving some room for the colorbar
   if ( N_Elements( MPosition  ) eq 0 )                  $
      then MPosition = [ 0.05, 0.15+psoffset, 1.0, 1.0 ] $ 
      else print,'Position passed: ', Mposition

   ; Add variable to advance to next page, if necessary (bmy, 10/31/01)
   Advance = 1 - Keyword_Set( NoAdvance )

   ; Get actual position of current plot panel
   ;-----------------------------------------------------------------------
   ; Now use MARGIN passed from the arg list (bmy, 3/2/04)
   ;MultiPanel, Position=position, Margin=[ 0.05, 0.04, 0.02, 0.07 ]
   ;-----------------------------------------------------------------------
   if ( N_Elements( Margin ) eq 0 ) then Margin = [ 0.05, 0.04, 0.03, 0.07 ]
   MultiPanel, Position=Position, Margin=Margin, OMargin=OMargin

   ;====================================================================
   ; Calculate true window position from position and MPosition
   ; Here we don't need to add a colorbar ...
   ;====================================================================

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

   ; save ![xy].charsize for later restore
   oldxcs = !x.charsize
   oldycs = !y.charsize

   ;=================================================================
   ; NPANELS = number of plots per page
   ;
   ; PSOFFSET will raise the plot window a little for PostScript
   ; plots so that we have room for the colorbar.
   ;
   ; Also, set PSOFFSET to a small number if NPLOTS gt 4 for non-
   ; PostScript plots.  This will keep the colorbar from interfering
   ; with the plot window on the screen.
   ;=================================================================
   npanels = !p.multi[1]*!p.multi[2]

   if ( !D.NAME eq 'PS' ) then begin
      psoffset = 0.02
      if ( NPanels ge 3    ) then PSOffset = PSOffset * 2.0
      if ( NPanels ge 9    ) then PSOffset = PSOffset * 3.0
   endif else begin
      PSOffset = 0.0
      if ( NPanels gt 4 ) then PSOffset = 0.02
   endelse
   
   ; CSFAC = scale factor for character sizes
   ; CSFAC is now a keyword -- use defaults if undefined (bmy, 3/31/00)
   if ( N_Elements( CsFac ) eq 0 ) then begin
      csfac = 1.0
      if (npanels gt 1) then csfac = 0.9
      if (npanels gt 4) then csfac = 0.75
      if (npanels gt 9) then csfac = 0.6
   endif

   plotcsfac = 1.0
   if (npanels gt 4) then plotcsfac = 1.0/0.62

   if (!D.name ne 'PS') then csfac = csfac*1.2

   if ( MContour OR FContour ) then begin

      ;=================================================================
      ; Here we are plotting a contour map!
      ;
      ; Set default values for some contour input quantities
      ;=================================================================
      
      ; Default C_LEVELS...use quasi-logarithmic contour levels
      if ( N_Elements( C_Levels ) eq 0 ) then  $
         C_Levels = loglevels([MinData,MaxData],coarse=4)
      if ( N_Elements( C_Levels ) lt 3 ) then  $
         C_Levels = (findgen(9)-1.)/9.*(MaxData-MinData) + MinData


      ; NCL is the number of elements in C_LEVELS
      NCL = N_Elements( C_Levels )

      ; Default C_FORMAT
      if ( N_Elements( C_Format ) eq 0 ) then  $
          C_Format = get_defaultformat(C_Levels[0],C_Levels[NCL-1],$
                                       DefaultLen=['14.2','8.1'], Log=Log)

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
      ; If C_COLORS is not passed, choose evenly spaced colors from
      ; the MYCT colortable for default colors. Make sure to use a local
      ; variable.
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
         if ( N_Elements( CC_Colors ) eq 1 ) $
            then CC_Colors = Replicate( CC_Colors[0], NCL )
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
      ; C_LABELS is superseded by the C_ANNOTATION keyword (which we
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
      ; Establish the plot coordinates with PLOT, /NODATA
      ;=================================================================
      Plot, XArr, ZArr,                               $
         /NoData,       /NoErase,      Color=MColor,  $
         XRange=XRange, YRange=Yrange,                $
         XStyle=XStyle, YStyle=YStyle, XTitle=XTitle, $
         YTitle=YTitle, Position=MPosition,   $
         charsize=plotcsfac*csfac, _EXTRA=e

      ;=================================================================
      ; Overlay title
      ;=================================================================
      xpmid = (!x.window[1]+!x.window[0])/2.

      ; Place a little higher, for carriage return lines (bmy, 3/25/99)
      if ( NPanels lt 2 )                 $
         then yptop = !y.window[1]+0.025  $
         else yptop = !y.window[1]+0.040

      ; place title yet a little higher if it has two lines
      if (strpos(mtitle,'!C') ge 0) then begin
         if ( NPanels le 4 ) $
            then yptop = yptop + 0.02 $
            else yptop = yptop + 0.01
      endif

      xyouts,xpmid,yptop,mtitle,color=MColor,/norm,align=0.5,  $
           charsize=1.2*csfac

      ;=================================================================
      ; If /FCONTOUR is set, then create a filled-contour 
      ; plot within the plot window created above.  
      ; Add CHARSIZE keyword to CONTOUR call (bmy, 4/27/99)
      ;=================================================================
      if ( FContour ) then begin
         Contour, TmpData, XArr, ZArr,             $
            Levels=C_Levels, C_Colors=CC_Colors,   $
            Fill=FContour,   /OverPlot,            $
            Charsize=CsFac,  _EXTRA=e
         
         ; If C_LINES=1, then overlay the filled-contour
         ; map with solid contour lines of color OVERLAYCOLOR
         ; Add CHARSIZE keyword to CONTOUR call (bmy, 4/27/99)
         if ( Keyword_Set( C_Lines ) ) then begin
            OverLayLines = Replicate( OverLayColor, NCL ) 
 
            Contour, TmpData, XArr, ZArr,                        $
               Levels=C_Levels,           C_Colors=OverLayLines, $
               C_Annotation=C_Annotation, /OverPlot,             $
               C_Labels=C_Labels,         CharSize=CsFac,        $
               _EXTRA=e
         endif 

        
         ; Recreate the plot window to make sure that the plot
         ; axes show up on top of the filled-contour plot.  
         Plot, XArr, ZArr,                               $
            /NoData,       /NoErase,      Color=MColor,  $
            XRange=XRange, YRange=Yrange,                $ 
            XStyle=XStyle, YStyle=YStyle, XTitle=XTitle, $
            YTitle=YTitle, Position=MPosition,  $
            charsize=plotcsfac*csfac, _EXTRA=e
 
      endif $

      ;=================================================================
      ; If /CONTOUR is set, then produce a line-contour plot 
      ; atop the current plot
      ;=================================================================
      else if ( MContour ) then begin
         Contour, TmpData, XArr, ZArr,                        $
            Levels=C_Levels,           C_Colors=CC_Colors,  $
            C_Annotation=C_Annotation, /OverPlot,          $
            C_Labels=C_Labels,         _EXTRA=e
      endif

   endif else begin

      ;=================================================================
      ; Here we are plotting a color-pixel image plot and overlaying 
      ; the plot axes atop it!!!  For better vertical resolution, 
      ; linearly interpolate the CTM levels to a fine grid of 100 
      ; evenly spaced vertical levels between ZBOT and ZTOP.  Then we
      ; call TVIMAGE with this finer-resolution vertical grid.
      ;
      ; Also make sure that we do not extrapolate wildly according to
      ; the slope at the surface or at the top layer. (bmy, 12/18/02)
      ;
      ; Now take care to correctly do the interpolation for both
      ; pressure and altitude on the Y-axis. (bmy, 1/6/03)
      ;=================================================================

      ; If ZBOT > ZTOP then we are plotting pressure on the Y-axis
      Is_Pressure = ( ZBot gt Ztop )

      ; NDATA is an array on the new "fine" vertical resolution
      NData   = FltArr( SData[0], 100 )

      ; NEWVERT is the vertical coordinates of the "fine" grid
      NewVert = FIndGen( 100 ) / 100. * ( ZTop - Zbot ) + Zbot

      for I = 0, SData[0] - 1 do begin
         ;-----------------------------------------------------
         ; Prior to 12/18/02:
         ; Replace spline w/ linear interpolation in vertical
         ;NData[I,*] = Spline( ZArr, TmpData[I,*], NewVert )
         ;-----------------------------------------------------
         NData[I,*] = InterPol( TmpData[I,*], Zarr, NewVert )
      endfor

      ; Now do not let NDATA go beyond the range of TMPDATA (bmy, 1/6/03)
      NData = ( NData > Min( TmpData ) ) < Max( TmpData )

      ; For levels of NEWVERT that fall below ZARR[0], we set NDATA
      ; at these levels to TMPDATA[*,0].  This prevents us from wildly
      ; extrapolating due to the slope near the surface (bmy, 1/6/03)
      if ( Is_Pressure )                        $
         then Ind = Where( NewVert gt ZArr[0] ) $
         else Ind = Where( NewVert lt ZArr[0] ) 

      if ( Ind[0] ge 0 ) then begin
         for I = 0L, N_Elements( Ind ) - 1L do begin
            NData[*,Ind[I]] = TmpData[*,0]
         endfor
      endif

      ; For levels of NEWVERT that fall above than ZARR[N_ZARR-1], we 
      ; set NDATA at these levels to TMPDATA[*,0].  This prevents us from 
      ; wildly extrapolating due to the slope there. (bmy, 1/6/03)
      if ( Is_Pressure )                                $
         then Ind = Where( NewVert lt ZArr[N_ZArr-1L] ) $
         else Ind = Where( NewVert gt ZArr[N_ZArr-1L] )

      if ( Ind[0] ge 0 ) then begin
         for I = 0L , N_Elements( Ind ) - 1L do begin
            NData[*,Ind[I]] = TmpData[*,L]
         endfor
      endif

      ; MVIND is the index array of points where NDATA < MIN_VALID
      ; Also reset MINDATA to MIN_VALID (bmy, 1/6/03)
      if ( N_Elements( Min_Valid ) gt 0 ) then begin        
         MVInd = Where( NData lt Min_Valid )
         if ( MVInd[0] ge 0 ) then begin
            NData[MVInd] = Min_Valid
            MinData      = Min_Valid 
         endif
      endif else begin
         MVInd = -1L
      endelse

      ;=================================================================
      ; If /LOG is set, then take the log10 of NDATA.  
      ; Store the extrema in LOGMINDATA and LOGMAXDATA, while 
      ; leaving MINDATA and MAXDATA unaltered.
      ;
      ; First Byte-Scale the NDATA array, using the appropriate 
      ; extrema for the byte scaling
      ;=================================================================
      if ( Log ) then begin

         ;==============================================================
         ; Make sure that we don't take the log10 of zero (bmy, 2/8/99)
         ;==============================================================
         Ind = Where( NData gt 0 )
         if ( Ind[0] ge 0 ) then begin
            ; Elements that don't equal zero...take the log10
            NData[ Ind ] = ALog10( NData[ Ind ] )
         endif

         if ( MinData gt 0 )                    $
            then LogMinData = ALog10( MinData ) $
            else LogMinData = 1e-30             

         if ( MaxData gt 0 )                    $
            then LogMaxData = ALog10( MaxData ) $
            else LogMaxData = 1e-30 


         Image = BytScl( NData, Min=LogMinData, Max=LogMaxData, $
                                Top=NColors-1,  _EXTRA=e ) + Bottom
      endif else begin 
         Image = BytScl( NData, Min=MinData,    Max=MaxData, $
                                Top=NColors-1,  _EXTRA=e ) + Bottom
      endelse
      
      ; Missing data values -- set to white
      if ( MVInd[0] ge 0 ) then Image[ MVInd ] = !MYCT.WHITE

      ;=================================================================
      ; Compute dithering factor (10 to ..)
      ; Formula may need to be improved (later on...)
      ;=================================================================
      S      = Size( Image, /Dim )
      BlowUp = 10 * ( ( Fix(50/Min(S) ) > 1 ) < 20 )

      ;=================================================================
      ; If /SAMPLE then rebin the data using nearest neighbor
      ; interpolation.  Otherwise use bilateral interpolation 
      ; (which takes longer but results in a finer grid).
      ;=================================================================
      if ( Keyword_Set( Sample ) ) then begin
         
         ; Screen (device with windows) needs rebin only if sample=1
         ; since this will force a lower resolution plot
         if ( ( !D.FLAGS AND 256 ) gt 0 ) then   $
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
      ; from the extent of the empty plot that was created above.
      ;=================================================================
      NewPosition = MPosition
      TVImage, Image, Position=NewPosition, _EXTRA=e   ; use /MULTI later???

      ;=================================================================
      ; We need to overlay the plot axes atop the color image.
      ;=================================================================
      Plot, XArr, ZArr, /NoData, /NoErase, Color=MColor, $
         XRange=XRange, YRange=YRange, $ 
         XStyle=XStyle, YStyle=YStyle, XTitle=XTitle,    $
         YTitle=YTitle, Position=NewPosition,   $
         charsize=plotcsfac*csfac, _EXTRA=e

      ;=================================================================
      ; Overlay title
      ;=================================================================
      xpmid = (!x.window[1]+!x.window[0])/2.

      ; Place a little higher, for carriage return lines (bmy, 3/25/99)
      if ( NPanels lt 2 )                 $
         then yptop = !y.window[1]+0.025  $
         else yptop = !y.window[1]+0.040

      ; place title yet a little higher if it has two lines
      if (strpos(mtitle,'!C') ge 0) then yptop = yptop+0.02

      xyouts,xpmid,yptop,mtitle,color=MColor,/norm,align=0.5,  $
            charsize=1.2*csfac

   endelse

   ;====================================================================
   ; Call COLORBAR to plot the colorbar below the map
   ; Otherwise, just print the unit string below the X-axis labels
   ;====================================================================
   if ( CBar ) then begin

      if ( N_Elements( CBMin ) eq 0 ) then CBMin = MinData
      if ( N_Elements( CBMax ) eq 0 ) then CBMax = MaxData

      if ( N_Elements( Min_Valid ) gt 0 ) then begin

         ; If MIN_VALID is passed, then also draw a white box
         ; to indicate values less than MIN_VALID (bmy, 11/15/02)
         ColorBar, BotOutOfRange=0,                                       $
            Max=CBMax,          Min=Min_Valid,       NColors=NColors,     $
            Bottom=Bottom,      Color=CBColor,       Position=CBPosition, $
            Unit=CBUnit,        Divisions=Divisions, Log=Log,             $
            Format=CBFormat,    Charsize=csfac,      TickLen=CBTickLen,   $
            C_Colors=CC_Colors, C_Levels=C_Levels,   _EXTRA=e

      endif else begin

         ; Otherwise, just draw the colorbar w/o the extra white box
         ColorBar, $
            Max=CBMax,          Min=CBMin,           NColors=NColors,     $
            Bottom=Bottom,      Color=CBColor,       Position=CBPosition, $
            Unit=CBUnit,        Divisions=Divisions, Log=Log,             $
            Format=CBFormat,    CharSize=CsFac,      TickLen=CBTickLen,   $
            C_Colors=CC_Colors, C_Levels=C_Levels,  _EXTRA=e

      endelse

   endif else begin
      XPos = ( MPosition[2] )
      YPos = ( CBPosition[3] + CBPosition[1] ) * 0.5

      XYOutS, XPos, YPos, CBUnit, /Normal, $
          Align=1.0, Color=MColor, CharSize=CsFac
   endelse 
      

   ;====================================================================
   ; Advance to the next plot position for the next plot
   ; Use NoErase so that we still see the results when the page is full
   ; (will be erased when we do next plot after page is full)
   ;====================================================================
   
   ; Now advance to the next plot only if NOADVANCE=0 (bmy, 10/31/01)
   MULTIPANEL, Advance=Advance, /NoErase

   ; restore old charsize for !x and !y
   !x.charsize = oldxcs
   !y.charsize = oldycs

   ; Return C_Colors back to the calling program (bmy, 5/21/04)
   if ( N_Elements( CC_Colors ) gt 0 ) then C_Colors = CC_Colors

   return
end
