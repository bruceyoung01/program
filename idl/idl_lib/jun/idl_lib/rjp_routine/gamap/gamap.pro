; $Id: gamap.pro,v 1.6 2005/03/24 18:03:12 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        GAMAP
;
; PURPOSE:
;        Menu-driven user interface for creating plots with
;        the GAMAP package subroutines. The actual data retrieval
;        and plotting is done with ctm_plot.pro. This routine
;        mainly collects all user requests and passes them on to
;        CTM_PLOT.
;
; CATEGORY:
;        Plotting / CTM Tools
;
; CALLING SEQUENCE:
;        GAMAP, [ DiagN [, Keywords ] ]
;
; INPUTS:
;        DIAGN -> A diagnostic number or category to restrict
;             the record selection (default is: use all).
;
; KEYWORD PARAMETERS:
;        General keywords:
;        -----------------------------------------------------------------
;        FILENAME -> CTM output file name. Default is to display a
;             pickfile dialog and let the user select. You can have
;             wildcards ('*', '?') in your filename which restricts
;             the file selection.
;
;        /NOFILE -> Don't query for filename but display all records that
;             have already been loaded. This can save you a couple of
;             mouse clicks when you want to create several plots with
;             data from one file, and it also useful when you want
;             to plot data from 'external' files that were converted
;             with ctm_make_datainfo. If a filename is given or no
;             data were loaded, the file selection dialog will appear
;             anyhow.
;
;        /RESETDEFAULTS -> If set, will reset all GAMAP values to their
;             defaults.
;
;        /HELP -> Displays a help page.
;
;        RESULT -> Returns a structure with the data subset as plotted and
;             the respective X and Y coordinates. Returns only one data
;             record though.
;
;        TOPTITLE -> Add a specific title centered on top of each page
;             of output.
;
;        Keywords to restrict the number of records displayed for selection:
;        -----------------------------------------------------------------
;        TRACER -> A tracer number to restrict record selection
;
;        TAU0 -> Time value (at beginning of record)
;
;        DATE -> 6 digit date (e.g. 940101) at the beginning of the
;             output record (this gets translated into a TAU0
;             value via the function nymd2tau). You can specify more
;             than one date at a time using a vector (e.g. [940101, 940301]).
;             For the GISS model(s), you also have to specify /GISS_Date in
;             order to get correct tau values. The time is assumed to
;             be 00 GMT. For other times use the TAU0 keyword as
;             TAU0=nymd2tau(dates,times).
;
;        /GISS_Date -> set this flag if you are using the DATE keyword
;             with GISS model output.
;
;        Keywords defining output options (these override defaults in
;        gamap.defaults)
;        -----------------------------------------------------------------
;        /PS -> If set, will directly send output to the 'idl.ps' file.
;             If not set, GAMAP will prompt the user whether to create
;             the 'idl.ps' file.
;
;        OUTFILENAME -> Name of file to send PostScript output to.
;
;        /NOTIMESTAMP -> Do not include a user ID and time stamp
;             on the postscript plot. Unnecessary if the TIMESTAMP value
;             in gamap.defaults is set to 0.
;
;        XSIZE, YSIZE, XOFFSET, YOFFSET -> GAMAP will pass these
;             keywords to routine OPEN_DEVICE, for setting the size
;             and margins of PostScript output.  
;
;        /DO_BMP -> If set, GAMAP will save animation frames as BMP
;             files.  If not set, GAMAP will prompt the user whether
;             to save animation frames to BMP files.  DO_BMP overrides
;             the default setting in "gamap.defaults".
;
;        BMPFILENAME -> Name of BMP file to save animation frames to.
;             If the token %N% is used in BMPFILENAME, then GAMAP
;             will replace %N% with the actual frame number.  If
;             BMPFILENAME is not set, or if DO_BMP is set to *QUERY in
;             "gamap.defaults", GAMAP will prompt user to supply
;             BMPFILENAME.
;
;        /DO_GIF -> If set, GAMAP will save animation frames as GIF
;             files.  If not set, GAMAP will prompt the user whether
;             to save animation frames to GIF files.  DO_GIF overrides
;             the default setting in "gamap.defaults".
;
;        GIFFILENAME -> Name of GIF file to save animation frames to.
;             If the token %N% is used in GIFFILENAME, then GAMAP
;             will replace %N% with the actual frame number.  If
;             GIFFILENAME is not set, or if DO_GIF is set to *QUERY in
;             "gamap.defaults", GAMAP will prompt user to supply
;             GIFFILENAME.
;
;        /DO_JPEG -> If set, GAMAP will save animation frames as BMP
;             files.  If not set, GAMAP will prompt the user whether
;             to save animation frames to JPEG files.  DO_JPEG overrides
;             the default setting in "gamap.defaults".
;
;        JPEGFILENAME -> Name of JPEG file to save animation frames to.
;             If the token %N% is used in JPEGFILENAME, then GAMAP
;             will replace %N% with the actual frame number.  If
;             JPEGFILENAME is not set, or if DO_JPEG is set to *QUERY in
;             "gamap.defaults", GAMAP will prompt user to supply
;             JPEGFILENAME.
;
;        /DO_PNG -> If set, GAMAP will save animation frames as PNG
;             files.  If not set, GAMAP will prompt the user whether
;             to save animation frames to PNG files.  DO_PNG overrides
;             the default setting in "gamap.defaults".
;
;        PNGFILENAME -> Name of PNG file to save animation frames to.
;             If the token %N% is used in PNGFILENAME, then GAMAP
;             will replace %N% with the actual frame number.  If
;             PNGFILENAME is not set, or if DO_PNG is set to *QUERY in
;             "gamap.defaults", GAMAP will prompt user to supply
;             PNGFILENAME.
;
;        /DO_TIFF -> If set, GAMAP will save animation frames as TIFF
;             files.  If not set, GAMAP will prompt the user whether
;             to save animation frames to TIFF files.  DO_TIFF overrides
;             the default setting in "gamap.defaults".
;
;        TIFFFILENAME -> Name of TIFF file to save animation frames to.
;             If the token %N% is used in TIFFFILENAME, then GAMAP
;             will replace %N% with the actual frame number.  If
;             TIFFFILENAME is not set, or if DO_PNG is set to *QUERY in
;             "gamap.defaults", GAMAP will prompt user to supply
;             TIFFFILENAME.
;
;        /POLAR -> Set this keyword for polar pots. This forces latitude
;             ranges to extend to one pole and longitude ranges to span
;             the globe. Polar plots only work for global (at least 
;             longitudinally) data sets.  Currently, polar plots are 
;             supported only for contour plots.
;
;        _EXTRA=e -> Picks up extra keywords for CTM_PLOT, etc...
;
; OUTPUTS:
;
; SUBROUTINES:
;        Internal subroutines:
;        ------------------------------------------------------
;        GAMAP_CheckDataBlockConsistency (function)
;        GAMAP_FindNearestCenters        (function)
;        GAMAP_GetDataBlockRanges        (function)
;        GAMAP_GetDefaultRanges
;        GAMAP_AutoYRange                (function)
;        GAMAP_PrintDimInfo
;        GAMAP_QueryAnimationOptions
;        GAMAP_QueryAverageOrTotal
;        GAMAP_QueryPostScriptOptions
;        GAMAP_SelectDataBlocks          (function)
;        GAMAP_SelectPlotType
;        GAMAP_QueryIsoPleth
;        GAMAP_StoreGridInfo
;        GAMAP_UserRangeEntry            (function)
;        GAMAP_GetFrameFileName          (function)
;
;
;        Also uses external subroutines:
;        ------------------------------------------------------
;        CHOICE        (function)    CLOSE_DEVICE
;        CTM_PLOT                    OPEN_DEVICE
;        STRREPL       (function)    STRWHERE    (function)
;        DEFAULT_RANGE (function)    CHKSTRU     (function)
;        REPLACE_TOKEN (function)    CTM_GRID    (function)
;        MAKE_SELECTION(function)    TVREAD      (function)
;
; REQUIREMENTS:
;        Uses GAMAP package subroutines.
;
; NOTES:
;        (1) GAMAP can read ASCII punch files with GEOS or GISS, model II
;            diagnostics, binary punch files (as defined in Jan 1999),
;            and GEOS-CTM binary restart files. Binary punch files
;            are processed much faster and allow "windowing" of output.
;
;        (2) For pixel plots, GAMAP can only plot cylindrical maps
;            with rectangular projections.  Arbitrary map projections
;            should be possible with any type of contour plot. For 
;            polar plots, use the /POLAR keyword. Other projections 
;            have not been tested and may lead to unexpected results.
;
;        (3) GAMAP forces map ranges to coincide with the grid box
;            edges, so that the map and pixel plot will be aligned.
;            Each "pixel" size corresponds to one full grid box.
;            For grids with half-polar boxes, it is therefore recommended
;            not to plot the polar latitudes, since those boxes will
;            show up as full-size boxes and shift the rest of the plot
;            accordingly.
;
;        (4) When the user selects multiple data blocks, GAMAP will produce
;            a multi-panel plot if !p.multi indicates more than one panel
;            on the screen (use the MULTIPANEL procedure to turn it on).
;            If you plot only one panel per screen, GAMAP will automatically
;            start XInterAnimate to present your own movie to you. Be
;            aware that XInterAnimate is limited by your system resources.
;            With default window sizes, we can usually display at least
;            30 frames.  ADDENDUM: 3-D isopleth maps will not be
;            animated. (bmy, 1/22/01)
;
;        (5) Animation frames can also be written to GIF or MPEG
;            files.  Defaults can be set in "gamap.defaults", or
;            specified via the command line. You can also save individual
;            GAMAP plots as GIF files. If you want to animate them later
;            (e.g. using ULead's GIF-Animator), make sure to specify the
;            RANGE keyword to get identical color schemes (or use contours).
;
;        (6) The GAMAP authors wish to point out that it is still relatively
;            expensive to produce color plots on the printer. We encourage
;            you to try out contour plots and make a test print on a black
;            and white printer before you make a color print.
;
;        (7) The 3-D isopleth maps do not quite work with MULTIPANEL, since
;            they are produced with screen capture in the Z-Buffer.  Hence  
;            Hence, the X window device has to be re-initialized each time, 
;            which negates the MULTIPANEL utility.  PostScript plots of 3-D
;            isopleth maps will print one plot per page.  We can live with
;            this for the time being.  Isopleth maps can also be written
;            to GIF files.
;
;        (8) Now uses D. Fanning's TVREAD function to perform better
;            device-independent screen capture. (cf. www.dfanning.com)
;
; EXAMPLES:
;        (1)
;        GAMAP
;            ; operates fully interactively
;
;        MULTIPANEL,nplots=6       ; turn on multi-panel environment
;        GAMAP
;            ; same as above, but produce multi-panel plots with
;            ; 6 plots per page
;
;        (2)
;        GAMAP, 'IJ-AVG-$', tra=4
;            ; Will create a CO (tracer=4) plot for the ND45 diagnostic.
;            ; GAMAP will display dialog pickfile box and will scan the
;            ; file for all records with ND45 and tracer 4. Those will be
;            ; displayed and the user can then select a record to be plotted.
;
;        (3)
;        GAMAP, [ 45, 28 ], tra=[2,4], date=[940601, 940801], $
;            FileName='~bmy/terra/CTM4/ctm.pch',/ps
;            ; In this example the file is fully specified, hence no file
;            ; selection dialog will be displayed. GAMAP scans the file
;            ; for all records of 'IJ-AVG-$' and 'BIOBSRCE' and tracers
;            ; 2 (OX) and 4 (NOX) and it seelcts only those records that
;            ; begin on the first of JUNE or AUGUST 1994. Because the ps
;            ; flag is set, the output will be directed to the postscript
;            ; file 'idl.ps' without first being displayed on the screen.
;
;
; MODIFICATION HISTORY:
;        mgs, 12 Nov 1998: VERSION 1.00
;        bmy, 16 Nov 1998: - added defaults for LAT, LEV, LON, PTYPE
;                          - now prompts for PS
;                          - now prompts user for /PS output
;        bmy, 17 Nov 1998: - now call DEFAULT_RANGE to ensure that
;                            that LAT, LON, LEVEL have two elements,
;                            even if there is only one unique value.
;                          - now uses N_UNIQ.PRO to test for the number
;                            of unique elements in LON, LAT, and LEVEL.
;        mgs, 17 Nov 1998: - finishing touches for first release.
;                          - added NOFILE keyword
;                          - added plot type b/w contours
;        mgs, 18 Nov 1998: - added timestamp as default when closing
;                            postscript files
;        bmy, 08 Jan 1999: - Will also prompt for totaling (if
;                            averaging is not selected)
;        bmy, 13 Jan 1999: - now prompt user for OUTFILENAME
;        bmy, 15 Jan 1999: VERSION 1.02
;                          - add support for 3-D data slices
;                          - clean up user interface so that the user
;                            menu of plotting options is only invoked
;                            when plotting a 2-D map.
;        bmy, 19 Jan 1999: - added binary flag masking
;                          - added defaults for averaging and selection
;                          - improved echoback of information to user
;        bmy, 20 Jan 1999: - prompts user again if data block selection
;                            or averaging selection is out of range
;                          - fixed bug: now default data block
;                            selection is saved.
;                          - Reset PS to 0 and OUTFILENAME to '' if we
;                            are plotting a 0-D or 3-D data block
;                          - updated comments
;        mgs, 21 Jan 1999: - dimensional information now in subroutine
;                          - improved binary masking
;                          - added several Quit options
;                          - Postscript options now controlled from
;                            gamap.defaults
;                          - removed NoTimeStamp keyword (now set in
;                            gamap.defaults)
;        bmy, 12 Feb 1999: VERSION 1.03
;                          - now works with data blocks that are
;                            sub-regions of the globe
;                          - added functions GAMAP_GetDataBlockRanges
;                            GAMAP_SelectDataBlock, and
;                            GAMAP_QueryAverageOrTotal
;                          - updated comments
;        bmy, 17 Feb 1999: VERSION 1.20
;                          - Replace DATAINFO.OFFSET by DATAINFO.FIRST,
;                            which contains the I, J, L indices of
;                            the first grid box
;                          - Animation facility added
;                          - added functions GAMAP_GetModelInfo,
;                            GAMAP_CheckDataBlockConsistency,
;                            GAMAP_SelectPlotType, and
;                            GAMAP_QueryPostScriptOptions.
;                          - Also renamed function GAMAP_SelectDataBlock to
;                            GAMAP_SelectDataBlocks, since one can now
;                            select multiple data blocks
;        bmy, 18 Feb 1999: - added /RESETDEFAULTS keyword
;                          - removed /ANIMATE keyword
;        bmy, 19 Feb 1999: - added NOAUTOYRANGE keyword
;                          - added function GAMAP_AutoYRange
;                          - added GIFFILENAME keyword
;                          - added GIF_SAV to common block SAVEVALUES
;                          - call REPLACE_TOKEN to replace token text
;                            in DEFAULTGIFFILENAME
;        bmy, 22 Feb 1999: - added more animation options
;                          - added DO_GIF, DO_MPEG, DO_ANIMATE, and
;                            MPEGFILENAME keywords
;                          - added GAMAP_QueryAnimationOptions routine
;        bmy, 23 Feb 1999: - small bug fixes
;        bmy, 04 Mar 1999: - added internal routines GAMAP_FindNearestEdges
;                            and GAMAP_GetDefaultRanges
;                          - now force lat/lon ranges to coincide with
;                            grid box edges
;                          - warn user if lat range contains half-polar
;                            boxes, since TVIMAGE will treat them as
;                            whole boxes and the map overlay will be
;                            inaccurate!
;        bmy, 05 Mar 1999: - Clean up FILEINFO/DATAINFO matching process
;                          - renamed/reorganized internal functions\
;        bmy, 20 Mar 1999: - bug fix for default ranges (may need more
;                            fixing later on)
;        mgs, 22 Mar 1999: - added ALREADY_PS flag for multi-panel use
;                          - animation now only if !p.multi does not
;                            have more than 1 panel to display
;        mgs, 23 Mar 1999: - improved comments and examples
;                          - removed unnecessary function MatchFileInfo...
;                            (easier with make_selection)
;                          - changed all "string booleans" to booleans
;                          - Do_Animation now an entirely local variable
;        mgs, 25 Mar 1999: - few minor bug fixes
;                          - improved handling of default ranges
;                          - detect out of range in record selection
;                          - now allows for 2D field plots
;        bmy, 17 May 1999: - now resolve DEFAULT_RANGE explicitly and
;                            call DEFRANGE_STR2NUM separately
;                          - few minor fixes in GAMAP_UserRangeEntry for
;                            data blocks that straddle the date line.
;        mgs, 19 May 1999: - some more cleaning
;                          - implemented SAVE option after data record
;                            selection
;                          - user selection for longitudes greatly improved
;                          - some adjustments in FindNearestEdges, notably
;                            for range 0..360. Unfortunately, the 0 meridian
;                            gridline will be omitted in such plots. If we
;                            wanted to include it we would need to carry
;                            an extra GLOBAL flag because lower and upper
;                            edges (grid box indices) are identical.
;        mgs, 20 May 1999: - added option to save record seelction to file.
;        mgs, 24 May 1999: - yet more work had to be done to make lon/lat
;                            selection as user would expect it to work.
;                          - renamed FindNearestEdges to ..Centers
;        mgs, 25 May 1999: - still more fiddling. Yuck!
;
;                          RELEASE OF GAMAP VERSION 1.40
;
;        bmy, 26 May 1999: - Added polar plot capabilities
;                          - fixed reset of plot ranges when latitude is +-90
;        mgs, 27 May 1999: - already_ps flag now also prevents user query.
;                          - default lat range for global fields now back
;                            to -88..88 only for "reset" conditions. Otherwise
;                            -90..90 is recognized and remembered.
;        mgs, 28 May 1999: - added RESULT keyword.
;                          - added TOPTITLE keyword.
;        bmy, 28 May 1999: - restrict plot type menu for polar plots
;  bmy & mgs, 02 Jun 1999: - add /NOERASE to MULTIPANEL call when
;                            testing for last plot on page
;                          - updated some comments
;        mgs, 30 Jun 1999: - make sure to return only one lat/lon box
;                            if user enters single value (even on edges).
;        bmy, 07 Jul 1999: - small bug fixes
;        bmy, 15 Sep 1999: GAMAP VERSION 1.43
;                          - changes for 23L GISS-II-PRIME model
;                          - minor bug fixes
;        bmy, 25 Oct 1999: GAMAP VERSION 1.44
;                          - added /MULTIPLE keyword -- option to
;                            write to a GIF file w/ multiple frames
;        bmy, 23 Nov 1999: - /SMALLCHEM now works correctly!
;        bmy, 26 Apr 2000: GAMAP VERSION 1.45
;                          - now make sure tracer numbers are mod 100L
;                            when saving data blocks to disk
;        bmy, 19 Jun 2000: - now create NS string array by concatenating 
;                            smaller arrays of < 1024 elements
;        bmy, 20 Jun 2000: - bug fix -- set NS[0] blank for string output
;        bmy, 03 Oct 2000: GAMAP VERSION 1.46
;        bmy, 22 Jan 2001: GAMAP VERSION 1.47
;                          - removed obsolete code
;                          - now produce a 3-D isopleth map instead of
;                            calling the volume slicer routine
;                          - added ISOPLETH keyword
;                          - added internal subroutine GAMAP_QueryIsopleth
;                          - allow PostScript output for 3-D maps, and
;                            suppress animation for 3-D maps.
;        bmy, 13 Mar 2001: - remove a couple more instances of the 
;                            obsolete STR_SEP routine.  Replaced with
;                            STRSPLIT( /EXTRACT ).  
;        bmy, 28 Jun 2001: GAMAP VERSION 1.48
;                          - bug fix in GAMAP_StoreDataInfo: for
;                            GENERIC grids with NLAYERS=0, be sure to
;                            call CTM_GRID with the /NO_VERTICAL flag.
;        bmy, 29 Aug 2001: - added XSIZE, YSIZE, XOFFSET, YOFFSET 
;                            keywords to pass to OPEN_DEVICE 
;  mje & bmy, 17 Dec 2001: GAMAP VERSION 1.49
;                          - add _EXTRA=e in call to CTM_WRITEBPCH, 
;                            so that we can pass the /APPEND keyword 
;        bmy, 17 Jan 2002: GAMAP VERSION 1.50
;                          - now call STRBREAK wrapper routine from
;                            the TOOLS subdirectory for backwards
;                            compatiblity for string-splitting
;                          - use FORWARD_FUNCTION to declare STRBREAK
;        bmy, 24 Jan 2002: - deleted obsolete code
;        bmy, 06 Dec 2002: GAMAP VERSION 1.52
;                          - removed /DO_MPEG and MPEGFILENAME keywords
;                          - now use D. Fanning's TVREAD for better
;                            device-independent screen capture
;                          - removed /MULTIPLE keyword for GIF output
;                          - added /DO_PNG, /DO_BMP, /DO_JPEG,
;                            /DO_TIFF keywords
;                          - added internal function GAMAP_GetFrameFileName
;        bmy, 13 Nov 2003: GAMAP VERSION 2.01
;                          - comment out XINTERANIMATE options
;        bmy, 27 Aug 2004: GAMAP VERSION 2.03
;                          - now call CTM_PLOT_TIMESERIES to plot data
;                            from bpch files containing GEOS-CHEM station
;                            timeseries output (e.g. ND48 diagnostic)
;        bmy, 27 Oct 2004: - now pass /QUIET keyword to GAMAP_AUTOYRANGE,
;                            CTM_PLOT_TIMESERIES, and CTM_PLOT
;                          - hardwire QUIET=1 in to suppress extra printing
;
;-
; Copyright (C) 1998-2004,
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine gamap"
;-----------------------------------------------------------------------

function GAMAP_CheckDataBlockConsistency, D, FileInfo, FileIndex

   ;=================================================================
   ; GAMAP_CheckDataBlockConsistency checks data blocks selected
   ; for animation to make sure they meet the following criteria:
   ;
   ;    (1) All data blocks have the same dimensions
   ;        Since old ASCII punch files do not contain dimensional
   ;        information we need to supplement it by using the grid
   ;        information
   ;    (2) All data blocks start with the same grid box
   ;    (3) All data blocks were produced by the same model with
   ;        identical resolution.
   ;=================================================================

   ; Index array of data blocks that match criteria
   GoodDataBlocks    = IntArr( N_Elements( D ) )

   ; Get the MODELINFO structure corresponding to D[0]
   RefModelInfo = FileInfo[ FileIndex[0] ].ModelInfo

   ; Get the max # of elements in D[0].DIM, D[0].FIRST,
   ; REFMODELINFO.NAME, and REFMODELINFO.RESOLUTION.
   ; The  equivalence tests will produce a match for each
   ; element of these fields.
   DimSize   = N_Elements( D[0].Dim                )
   FirstSize = N_Elements( D[0].First              )
   NameSize  = N_Elements( RefModelInfo.Name       )
   ResSize   = N_Elements( RefModelInfo.Resolution )

   ; ### debug
   ; print,'### DIMSIZE, FIRSTSIZE, NAMESIZE, RESSIZE'
   ; print,DIMSIZE, FIRSTSIZE, NAMESIZE, RESSIZE
   ; print,'D[0].dim = ',D[0].Dim

   ; Loop over the records of D, skipping D[0]
   for N = 0, N_Elements( D ) - 1 do begin

      ; Get the MODELINFO structure for this data block
      ThisModelInfo = FileInfo[ FileIndex[N] ].ModelInfo
      ThisGridInfo = * (FileInfo[ FileIndex[N] ].GridInfo )

      if ( FileInfo[ FileIndex[N] ].FileType eq 0 ) then begin
         if ( Total( D[N].Dim ) le 0 ) then begin
            D[N].Dim[0] = ThisGridInfo.IMX
            D[N].Dim[1] = ThisGridInfo.JMX
            D[N].Dim[2] = ThisModelInfo.NTROP
            print,'### CheckConsistency: dimensions set from grid info !'
         endif
         if ( Total( D[N].First ) eq 0 ) then D[N].First = [1, 1, 1]
      endif

      ; Check dimensions of this data block
      if (D[N].Dim[2] lt 0) then D[N].Dim[2] = max(D.Dim[2])
      Ind0 = Fix( Total( D[N].Dim eq D[0].Dim ) )

      ; Check the indices of the first grid box of this data block
      Ind1 = Fix( Total( D[N].First eq D[0].First ) )

      ; Check model name against that of first data block
      Ind2 = Fix( ThisModelInfo.Name  eq RefModelInfo.Name )

      ; Check model resolution against that of first data block
      Ind3 = Fix( Total( ThisModelInfo.Resolution eq $
                         RefModelInfo.Resolution ) )

      ; Require dimension, offset, model name, model res to match
      if ( Ind0 eq DimSize  AND Ind1 eq FirstSize AND $
           Ind2 eq NameSize AND Ind3 eq ResSize ) then GoodDataBlocks[N] = 1

      ; ### debug
      ; print,'### ind0,ind1,ind2,ind3'
      ; print,ind0,ind1,ind2,ind3
      ; print,'D[N].dim = ',D[N].Dim

   endfor

   ; Return data blocks that match the criteria
   Ind0 = Where( GoodDataBlocks eq 1 )
   D    = D[ Ind0 ]

   ; Print warning messages for those data blocks that
   ; did not meet the criteria and were eliminated.
   ; Will get more sophisticated later...
   Ind1 = Where( GoodDataBlocks eq 0 )
   if ( Ind1[0] ge 0 ) then begin
      for N = 0, N_Elements( Ind1 ) - 1 do begin
         S = StrTrim( String( N, Format='(i10)' ), 2 )
         S = 'Data Block ' + S + ' has been eliminated from animation...'
         Message, S, /Info, /NoName
      endfor
   endif

   ; Successful Return!
   return, 1

end

;----------------------------------------------------------------------------

function GAMAP_FindNearestCenters, $
              F, Range, Latitude=Latitude, Longitude=Longitude, $
              Polar=Polar

   ;=================================================================
   ; Function GAMAP_FindNearestCenters converts an
   ; input range for lat or lon to the nearest grid box center.
   ; This function is called for one individual data block.
   ; LATITUDE and LONGITUDE are boolean keywords that determine
   ; whether to return latitude or longitude centers.
   ; If the POLAR keyword is set, the "halfpolar warning" is disabled.
   ;
   ; mgs, 23 Mar 1999: - de-hardwired half polar check and streamlined
   ;      operation.
   ; bmy, 25 Mar 1999: - bug fix (gt instead of ge)
   ; mgs, 19 May 1999: - extra care for lon range 0..360
   ; mgs, 25 May 1999: - bug fix for single boxes
   ;                   - renamed to FindNearestCenters because that's
   ;                     what we really need!
   ; bmy, 26 May 1999: - added Polar keyword
   ;=================================================================

   ; Get structures from FILEINFO
   ModelInfo = F.ModelInfo
   GridInfo  = *( F.GridInfo )

   ; Grid box edge arrays for latitude or longitude
   Longitude = Keyword_Set( Longitude )
   Latitude  = Keyword_Set( Latitude  )
   Polar     = Keyword_set( Polar     )

   if ( Longitude ) then begin
      Edges   = [ GridInfo.XEdge, GridInfo.XEdge[1:*]+360. ]
      Centers = [ GridInfo.XMid , GridInfo.XMid+360. ]

   ; ### DEBUG
   ; print,'edges=',edges,format='(A,100f7.1)'
   ; print
   ; print,'centers=',centers,format='(A,100f7.1)'
   ; stop

   endif
   if ( Latitude  ) then begin
      Edges = GridInfo.YEdge
      Centers = GridInfo.YMid
   endif
   NEdges = n_elements(Edges)

   ; Half-Polar box warning
   if ( Latitude AND ModelInfo.HalfPolar AND not Polar) then begin
      if ( Range[0] lt Edges[1] OR Range[1] gt Edges[NEdges-2] ) then begin
         S = StrTrim( Replicate( Byte( '=' ), 70 ), 2 )

         print
         Message, S, /Info, /NoName
         Message, 'WARNING!!! TVIMAGE will display Half-Polar Boxes' + $
                  ' as full boxes', /Info, /NoName
         Message, 'You might want to exclude the poles from your lat range!',$
                  /Info, /NoName
         Message, S, /Info, /NoName
         print
      endif
   endif

   ; print,'### RANGE=',range,'  longitude=',longitude

   ; handle special case for longitude range 0..360
   ; (global across dateline)
   if ( Longitude AND (Range[1] eq 360.) ) then begin
      LowerEdge = min( Centers[ where(Edges ge 0.) ] )
      UpperEdge = max( Centers[ where(Edges lt 0.) ] )
      return,[LowerEdge, UpperEdge]
   endif 

   ; return nearest left/bottom edge
   Ind = where(Edges le Range[0])
   if (Ind[0] ge 0) $
      then LowerEdge = Centers[Ind[n_elements(Ind)-1] < (NEdges-2)]  $
      else LowerEdge = Centers[0]     ; can't go beyond first edge

   Ind = where(Edges ge Range[1] )
   if (Ind[0] ge 0)                                      $
      then UpperEdge = Centers[(Ind[0]-1) < (NEdges-2)]  $
      else UpperEdge = Centers[NEdges-2]     ; can't go beyond last edge

   ; print,'### Range=',range

   ; *** behaviour fix: return two identical values if user requested
   ; *** only one value. Always choose LowerEdge even though it is 
   ; *** ambiguous on edges.

   if (range[0] eq range[1]) then UpperEdge = LowerEdge

   ; Return the nearest grid box centers
   return, [ LowerEdge, UpperEdge ]

end

;----------------------------------------------------------------------------

function GAMAP_GetDataBlockRanges, D, F, Lon_Range, Lat_Range, Lev_Range, $
               Polar=Polar, First=First

   ;=================================================================
   ; GAMAP_GETDATABLOCKRANGES computes the extent of the data block
   ; in longitude, latitude, and altitude (bmy, 3/5/99
   ;
   ; NOTES:
   ; (1) D and F are the DATAINFO and FILEINFO structures that
   ;     correspond to theh first data block.  Thus we pass
   ;     D[0] and FILEINFO[ FILEINDEX[0] ] from GAMAP.PRO.
   ;
   ; (2) **** This function should be moved to ctm_retrieve_data at
   ;     **** some point, storing the coordinate information in the
   ;     **** datainfo structure as soon as we read the file header
   ;          (mgs, 03/23/99)
   ;
   ; (3) I don't like clipping to -88 .. 88 here! If the data does
   ;     contain the polar latitudes, the associated range info should
   ;     reflect this!! ... it does now so at least for polar plots.
   ; *** ### temporary disabled clipping altogether ! mgs, 05/26/99
   ;
   ; bug fix to prevent crash in multitracer diag (mgs, 05/21/99)
   ; added FIRST keyword to set global default to -88 .. 88 instead 
   ; of -90 .. 90. 
   ;=================================================================

   ; Common blocks
   @gamap_cmn

   ; Get the MODELINFO and GRIDINFO fields that correspond to D[0]
   ModelInfo = F.ModelInfo
   GridInfo  = *( F.GridInfo )

   ; For ASCII punch files (FILEINFO.FILETYPE = 0), the dimensions
   ; don't become visible until after each data block is read in.
   ; If D[0].DIM or D[0].FIRST are all zero, then get the dimensions
   ; from the GRIDINFO structure.
   if ( F.FileType eq 0 ) then begin
      if ( Total( D.Dim ) le 0 ) then begin
         D.Dim[0] = GridInfo.IMX
         D.Dim[1] = GridInfo.JMX
         D.Dim[2] = 1  ;ModelInfo.NTROP
         print,'### GetDataBlockRanges: dimensions set from grid info!'
      endif

      if ( Total( D.First ) eq 0 ) then D.First = [1, 1, 1]
   endif

   ;-----------------------------------------------------------------
   ; Longitude extent of the current data block
   ; Take care of longitudes that wrap around the date line
   ;
   ; NOTE: Convert from FORTRAN notation to IDL notation by
   ;       subtracting 1 from D[0].FIRST and D[0].DIM
   ;-----------------------------------------------------------------
   I0        = D.First[0] - 1
   I1        = ( D.First[0] + D.Dim[0] - 2 ) mod GridInfo.IMX
   Lon_Range = [ GridInfo.XEdge[I0], GridInfo.XEdge[I1+1] ]

   ;-----------------------------------------------------------------
   ; Latitude extent of the current data block
   ; Truncate lat range at -88 and +88, since TVIMAGE can't handle
   ; half polar boxes -- it can't print half a pixel!! (bmy, 3/19/99)
   ;-----------------------------------------------------------------
   I0        = D.First[1] - 1
   I1        = D.First[1] + D.Dim[1] - 2
   Lat_Range = [ GridInfo.YEdge[I0], GridInfo.YEdge[I1+1] ]

   ; ###$%%%%*****
   ;  If (not keyword_set(Polar)) then begin
   If (keyword_Set(First)) then begin
      If ( Lat_Range[0] lt -89 ) then Lat_Range[0] = GridInfo.YEdge[I0+1]
      If ( Lat_Range[1] gt  89 ) then Lat_Range[1] = GridInfo.YEdge[I1  ]
   endif

   ;-----------------------------------------------------------------
   ; Vertical extent of the current data block
   ; Set the range correctly for data blocks that only have 1 level
   ;-----------------------------------------------------------------
   if (ChkStru(GridInfo,'LMX')) then begin
   ; stop ; #########
      LevInd  = Indgen( GridInfo.LMX ) + 1
      I0      = D.First[2] - 1
      I1      = D.First[2] + D.Dim[2] - 2

      if ( I1 ge 0 ) then begin
         ; *@#!$%@^ extra twist to handle these stupid multitracer diags ***
         if (I1 ge GridInfo.LMX) then $
            Lev_Range = [ 1, I1+1 ]   $
         else  $ 
            Lev_Range = [ LevInd[I0], LevInd[I1] ]
      endif else begin
         Lev_Range = [ LevInd[I0], LevInd[I0] ]
      endelse
   endif else begin    ; 2D gridinfo structure
      LevInd = 1
      Lev_Range = [ 1, 1 ]
   endelse

   ; Successful return!
   return, 1
end

;----------------------------------------------------------------------------

function GAMAP_AutoYRange, $
              D, AvMode, TotalMode, Lon, Lat, Level, Quiet=Quiet

   ;=================================================================
   ; Function GAMAP_AutoYRange computes the absolute
   ; minimum and maximum values for all of the animation frames.
   ; This is needed so that the colorbars of the individual
   ; animation frames will all have the same range. (bmy, 2/19/99)
   ; This routine is also called for multi-panel plots if keyword
   ; /AUTORANGE is set.
   ;
   ; NOTE: Added QUIET keyword to suppress printing of tracer info
   ;       in routine CTM_GET_DATA (bmy, 10/27/04)
   ;=================================================================

   ; Common blocks (DEBUG flag)
   @gamap_cmn

   ; Local arrays to hold min and max values.
   MinData = FltArr( N_Elements( D ) )
   MaxData = FltArr( N_Elements( D ) )

   ; Loop over all selected data blocks...
   for N = 0, N_Elements( D ) - 1 do begin
      Success = CTM_Get_DataBlock( Data, D[N].Category,              $
                                   ILun=D[N].Ilun,                   $
                                   Tracer=D[N].Tracer,               $
                                   Tau0=D[N].Tau0,                   $
                                   Average=AvMode,  Total=TotalMode, $
                                   Lev=Level,       Lat=Lat,         $
                                   Lon=Lon,         /NoPrint,        $
                                   Quiet=Quiet )

      ; For each data block found, compute its max and min
      ; values, and store them in the MAXDATA and MINDATA arrays.
      if ( Success ) then begin
         TmpMin       = Min( Data, Max=TmpMax )
         MinData[ N ] = TmpMin
         MaxData[ N ] = TmpMax

         ; Set status of that record to read
         D[N].status = 1

         ;### Debug output (bmy, 2/19/99)
         ;if ( DEBUG ) then begin
         ;  print, '### GAMAP.PRO: N, MINDATA, MAXDATA: ', N, TmpMin, TmpMax
         ;endif
      endif
   endfor

   ; AUTOYRANGE contains the "global" min and max values
   AutoYRange = [ Min( MinData ), Max( MaxData ) ]

   ; Undefine the data array so that we don't take up resources
   Undefine, Data

   ; Return the "global" Min and Max values
   return, AutoYRange
end


;----------------------------------------------------------------------------

pro GAMAP_PrintDimInfo,Arr,Ind,NDim=NDim,Message=MStr

   ;=================================================================
   ; GAMAP_PRINTDIMINFO prints the current number of dimensions and
   ; their labels.
   ;
   ; Arr contains flags as Arr = [ NLon, NLat, NLevel ]
   ;   Nxxx = 0 : dimension was averaged/totaled
   ;        = 1 : dimension contains single value
   ;        = 2 : is a multi element vector
   ;
   ; Ind is a selection array which dimensions to print by name
   ; (default: all dimensions with Arr=2)
   ;
   ; NDim returns the number of "active" dimensions
   ;=================================================================
   DimStr = [ 'Longitude', 'Latitude', 'Altitude' ]

   DimInd = Where( Arr gt 1 )
   if (n_elements(Ind) eq 0) then Ind  = DimInd
   NDim = n_elements(DimInd) * ( DimInd[0] ge 0 )

   if (n_elements(Mstr) eq 0) then MStr = '' $
   else MStr = '. ' + MStr

   MesgStr = 'Selected data is ' + $
      StrTrim( String( NDim, format='(i4)'), 2 ) + '-D'

   if ( NDim gt 0 ) then begin
      MesgStr = MesgStr + MStr + ' [ ' + $
         string(DimStr[Ind],format='(3(A,:,","))' ) + ' ].'
   endif else begin
      MesgStr = MesgStr + '.'
   endelse

   if (not !QUIET) then print
   Message, MesgStr, /Info, /NoName

   return
end

;----------------------------------------------------------------------------

pro GAMAP_QueryAnimationOptions, NDim, Do_Animation,   $
         Do_BMP,  BMPFileName,  Do_GIF,  GifFileName,  $
         Do_JPEG, JPEGFileName, Do_PNG,  PNGFileName,  $
         Do_TIFF, TIFFFileName, Do_MPEG, MPEGFileName, $
         Quit=Quit

   ;====================================================================
   ; Subroutine GAMAP_QueryAnimationOptions queries the user for
   ; animation options. (bmy, 2/22/99)
   ;
   ; mgs, 23 Mar 1999: - now uses yesno function and is streamlined
   ;                   - doesn't tamper with animation status any more
   ;                   - Do_XX are always returned as boolean values
   ;                     although they may have been passed in as 
   ;                     strings
   ; bmy, 06 Dec 2002: GAMAP VERSION 1.52
   ;                   - Removed MPEG, added BMP, JPEG, PNG, TIFF
   ; bmy, 13 Nov 2003: GAMAP VERSION 2.01
   ;                   - Re-added MPEG animation option
   ;====================================================================

   FORWARD_FUNCTION yesno


   ; Common blocks
   common SaveValues,    Sel_Sav, Lev_Sav,   Lon_Sav, $
                         Lat_Sav, PType_Sav, Avg_Sav, $
                         Iso_Sav

   Quit = 0

   ; For 0-D data, no plots are possible
   if ( NDim eq 0 ) then begin
      Do_BMP  = 0
      Do_GIF  = 0
      Do_JPEG = 0
      Do_PNG  = 0
      Do_TIFF = 0
      Do_MPEG = 0
      return
   endif
 
   ;====================================================================
   ; Query user for the BMP file name
   ;====================================================================

   ; First ask user if he/she wants to save BMP files
   if ( String( Do_BMP ) eq '*QUERY' ) then begin
      print
      Do_BMP = YesNo( 'Save frames to BMP files?', Default=0, /QUIT )
      if ( Do_BMP lt 0 ) then begin
         Quit = 1
         return
      endif
   endif else begin
      Do_BMP = fix( Do_BMP )
   endelse

   ; If so, then ask for the BMP file name.  The file name can 
   ; contain a replaceable token for the frame number.
   if ( Do_BMP eq 1 ) then begin
      if ( StrUpCase( BMPFileName ) eq '*QUERY' ) then begin
         LStr        = ''
         LStrDefault = 'frame%NNN%'
         Read, LStr, Prompt='BMP File Name (default : ' + $
            LStrDefault + ', Q=Quit) >> '

         LStr = StrTrim( LStr, 2 )

         ; Quit if 'Q'
         if ( StrUpCase( LStr ) eq 'Q' ) then begin
            Quit = 1
            return
         endif

         if ( LStr eq '' ) then LStr = LStrDefault
         BMPFileName = LStr
      endif
   endif

   ;====================================================================
   ; Query user for the GIF file name
   ;====================================================================

   ; First ask user if he/she wants to save GIF files
   if ( String( Do_GIF ) eq '*QUERY' ) then begin
      print
      Do_GIF = YesNo( 'Save frames to GIF files?', Default=0, /QUIT )
      if ( Do_GIF lt 0 ) then begin
         Quit = 1
         return
      endif
   endif else begin
      Do_GIF = fix( Do_GIF )
   endelse

   ; If so, then ask for the GIF file name.  The file name can 
   ; contain a replaceable token for the frame number.
   if ( Do_GIF eq 1 ) then begin
      if ( StrUpCase( GIFFileName ) eq '*QUERY' ) then begin
         LStr        = ''
         LStrDefault = 'frame%NNN%'
         Read, LStr, Prompt='GIF File Name (default : ' + $
            LStrDefault + ', Q=Quit) >> '

         LStr = StrTrim( LStr, 2 )

         ; Quit if 'Q'
         if ( StrUpCase( LStr ) eq 'Q' ) then begin
            Quit = 1
            return
         endif

         if ( LStr eq '' ) then LStr = LStrDefault
         GIFFileName = LStr
      endif
   endif

   ;====================================================================
   ; Query user for the JPEG file name
   ;====================================================================

   ; First ask user if he/she wants to save JPEG files
   if ( String( Do_JPEG ) eq '*QUERY' ) then begin
      print
      Do_JPEG = YesNo( 'Save frames to JPEG files?', Default=0, /QUIT )
      if ( Do_JPEG lt 0 ) then begin
         Quit = 1
         return
      endif
   endif else begin
      Do_JPEG = fix( Do_JPEG )
   endelse

   ; If so, then ask for the JPEG file name.  The file name can 
   ; contain a replaceable token for the frame number.
   if ( Do_JPEG eq 1 ) then begin
      if ( StrUpCase( JPEGFileName ) eq '*QUERY' ) then begin
         LStr        = ''
         LStrDefault = 'frame%NNN%'
         Read, LStr, Prompt='JPEG File Name (default : ' + $
            LStrDefault + ', Q=Quit) >> '

         LStr = StrTrim( LStr, 2 )

         ; Quit if 'Q'
         if ( StrUpCase( LStr ) eq 'Q' ) then begin
            Quit = 1
            return
         endif

         if ( LStr eq '' ) then LStr = LStrDefault
         JPEGFileName = LStr
      endif
   endif

   ;====================================================================
   ; Query user for the PNG file name
   ;====================================================================

   ; First ask user if he/she wants to save PNG files
   if ( String( Do_PNG ) eq '*QUERY' ) then begin
      print
      Do_PNG = YesNo( 'Save frames to PNG files?', Default=0, /QUIT )
      if ( Do_PNG lt 0 ) then begin
         Quit = 1
         return
      endif
   endif else begin
      Do_PNG = fix( Do_PNG )
   endelse

   ; If so, then ask for the PNG file name.  The file name can 
   ; contain a replaceable token for the frame number.
   if ( Do_PNG eq 1 ) then begin
      if ( StrUpCase( PNGFileName ) eq '*QUERY' ) then begin
         LStr        = ''
         LStrDefault = 'frame%NNN%'
         Read, LStr, Prompt='PNG File Name (default : ' + $
            LStrDefault + ', Q=Quit) >> '

         LStr = StrTrim( LStr, 2 )

         ; Quit if 'Q'
         if ( StrUpCase( LStr ) eq 'Q' ) then begin
            Quit = 1
            return
         endif

         if ( LStr eq '' ) then LStr = LStrDefault
         PNGFileName = LStr
      endif
   endif

   ;====================================================================
   ; Query user for the TIFF file name
   ;====================================================================

   ; First ask user if he/she wants to save TIFF files
   if ( String( Do_TIFF ) eq '*QUERY' ) then begin
      print
      Do_TIFF = YesNo( 'Save frames to TIFF files?', Default=0, /QUIT )
      if ( Do_TIFF lt 0 ) then begin
         Quit = 1
         return
      endif
   endif else begin
      Do_TIFF = fix( Do_TIFF )
   endelse

   ; If so, then ask for the TIFF file name.  The file name can 
   ; contain a replaceable token for the frame number.
   if ( Do_TIFF eq 1 ) then begin
      if ( StrUpCase( TIFFFileName ) eq '*QUERY' ) then begin
         LStr        = ''
         LStrDefault = 'frame%NNN%'
         Read, LStr, Prompt='TIFF File Name (default : ' + $
            LStrDefault + ', Q=Quit) >> '

         LStr = StrTrim( LStr, 2 )

         ; Quit if 'Q'
         if ( StrUpCase( LStr ) eq 'Q' ) then begin
            Quit = 1
            return
         endif

         if ( LStr eq '' ) then LStr = LStrDefault
         TIFFFileName = LStr
      endif
   endif

   ;====================================================================
   ; Query user for the MPEG file name
   ;====================================================================

   ; Safety check: turn off MPEG if there isn't more than one frame to plot
   if ( not Do_Animation ) then Do_MPEG = '0'

   ; First ask user if he/she wants to save MPEG files
   if ( String( Do_MPEG ) eq '*QUERY' ) then begin

      ; ask user whether or not to create MPEG
      print
      Do_MPEG = YesNo( 'Create MPEG animation?', Default=0, /QUIT )
      if ( Do_MPEG lt 0 ) then begin
         Quit = 1
         return
      endif

   endif else begin

      ; If DO_MPEG is '0' or '1', convert from string to number
      Do_MPEG = fix( Do_MPEG )

   endelse
   
   ; If there are animation frames to plot, ask for the MPEG filename 
   if ( Do_MPEG eq 1 ) then begin
      if ( StrUpCase( MPEGFileName ) eq '*QUERY' ) then begin
         LStr        = ''
         LStrDefault = 'gamap.mpg'
         Read, LStr, Prompt='MPEG File Name (default : ' + $
            LStrDefault + ', Q=Quit) >> '
         
         LStr = StrTrim( LStr, 2 )
         
         ; Quit if 'Q'
         if ( StrUpCase( LStr ) eq 'Q' ) then begin
            Quit = 1
            return
         endif
            
         if ( LStr eq '' ) then LStr = LStrDefault
         MPEGFileName = LStr
      endif
   endif

   return
end

;----------------------------------------------------------------------------

pro GAMAP_QueryAverageOrTotal, Arr, NDim, AvMode, TotalMode, Quit=Quit

   ;====================================================================
   ; Procedure GAMAP_QueryAverageOrTotal queries the user as to
   ; averaging or totaling options (bmy, 2/12/99)
   ;====================================================================

   ; GAMAP common blocks
   @gamap_cmn
   common SaveValues,    Sel_Sav, Lev_Sav,   Lon_Sav, $
                         Lat_Sav, PType_Sav, Avg_Sav, $
                         Iso_Sav

   ; Initialize variables
   AvMode    = 0
   TotalMode = 0

   ;--------------------------------------------------------------------
   ; If at least one dimension contains more than one value,
   ; query user for averaging (or totaling)
   ;--------------------------------------------------------------------
   if ( NDim ge 1 ) then begin

      LStr        = ''
      LStrDefault = StrTrim( String( Avg_Sav, Format='(i4)' ), 2 )

      if (NDim eq 3) then Str0 = 'Visualize 3D' $
      else Str0 = 'No averaging'

      Print

Repeat_AvMode_Selection:
      print,'Do you want to average or total the data?'
      Read, LStr,  $
         prompt='(0='+Str0+', 1=lon, 2=lat, 4=alt, ' + $
                '8=Total, Q=Quit, Default=' + LStrDefault +  ') >> '

      LStr = StrTrim(Lstr,2)
      if ( StrUpcase(StrMid(LStr,0,1)) eq 'Q' ) then begin
         Quit = 1
         return
      endif

      if ( LStr eq '' ) then LStr = LStrDefault

      ;-----------------------------------------------------------------
      ; Ask user again if AVMODE is out of range
      ;-----------------------------------------------------------------
      AvMode  = Fix( LStr )
      if ( AvMode lt 0 OR AvMode gt 15 ) then begin
         Message, 'Selection must be >= 0 and <= 15. Choose again...', $
            /Info, /NoName
         goto, Repeat_AvMode_Selection
      endif

      ; Save for next time...
      Avg_Sav = AvMode

      ;-----------------------------------------------------------------
      ; Binary masking.  Make sure that the dimension(s) selected
      ; for averaging or totaling each have more than one point.
      ; Reduce  NDim by one for each dimension that is to be
      ; averaged or totaled.
      ;
      ; If a dimension contains a single point, then we cannot
      ; average or total along that dimension.  Use a Hexadecimal bit
      ; mask for a bitwise AND operation to clear AVMODE and
      ; TOTALMODE.  This will assure that CTM_PLOT will select the
      ; proper plot labels.
      ;
      ; A refresher course:
      ;  Decimal:      0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
      ;  Hexadecimal:  0 1 2 3 4 5 6 7 8 9  A  B  C  D  E  F
      ;
      ; See the IDL manual for info about the Bitwise AND operation.
      ;-----------------------------------------------------------------

      ; Clear averaging flag for all dimensions with only one value
      mask = 'F8'x + 4*(Arr[2] gt 1) + 2*(Arr[1] gt 1) + (Arr[0] gt 1)

      ;### Debug output (bmy, 2/19/99)
      if ( DEBUG ) then print,'### AVERAGING MASK = ',mask

      AvMode = (AvMode AND mask)

      ;-----------------------------------------------------------------
      ; Set dimensions to be averaged to zero and reduce NDim
      ; Ind contains 1 for each dimenson *not* to be averaged
      ;-----------------------------------------------------------------
      Ind = ( (AvMode AND [1,2,4]) eq 0 )
      Arr = Arr * Ind   ; sets averaged dimensions to zero

      ; Settings for total
      TotalMode = 0
      if ( (AvMode AND 8) gt 0 ) then begin
         TotalMode = ( AvMode AND 'F7'x )
         AvMode    = 0
      endif

      ;-----------------------------------------------------------------
      ; Echo back information about which dimensions will be
      ; averaged or totaled by GAMAP (those for which ARR[i] = 0)
      ; NDIM is adjusted in GAMAP_PrintDimInfo
      ;-----------------------------------------------------------------
      Ind = Where( Arr eq 0, Count )

      if (Count gt 0) then begin
         if (AvMode gt 0) then $
            Gamap_PrintDimInfo,Arr,Ind,NDim=NDim, $
               Message='Data averaged over'  $
         else if (TotalMode gt 0 ) then $
            Gamap_PrintDimInfo,Arr,Ind,NDim=NDim, $
               Message='Data totaled over'
      endif
   endif
end

;----------------------------------------------------------------------------


pro GAMAP_QueryPostScriptOptions, $
          Do_PS, TimeStamp, OutFileName

   ;=================================================================
   ; Subroutine GAMAP_QueryPostScriptOptions queries the user for
   ; PostScript options (bmy, 2/16/99)
   ;
   ; mgs, 23 Mar 1999: - removed all animation related parameters.
   ;       This routine is only called if no animation is active.
   ;                   - removed "double" keywords (Bob's bad day ;-)
   ;                   - removed PScrLabel, since it was equivalent
   ;       to the default in close_device
   ;                   - Do_PS will always return numeric value. -1
   ;       if user shall be queried after plot
   ;=================================================================

   FORWARD_FUNCTION yesno


   ; Set or query postscript options if Do_PS
   if ( Do_PS eq string(1) ) then begin

      ; Query user for PostScript file name
      if (strupcase(OutfileName) eq '*QUERY') then begin
         LStr        = ''
         LStrDefault = 'idl.ps'
         Read, LStr, Prompt='Postscript File Name (default : ' + $
            LStrDefault + ') >> '

         LStr = StrTrim(LStr,2)
         if ( LStr eq '' ) then LStr = LStrDefault
         OutFileName = LStr
      endif

      ; Query User to add a time stamp to the PostScript plot
      if (strupcase(TimeStamp) eq '*QUERY') then begin
         TimeStamp = yesno('Add time stamp to plot?',default=1)
      endif else $
         TimeStamp = fix(TimeStamp)    ; either '0' or '1'
   endif

   if ( StrUpCase(Do_PS) eq '*QUERY' ) then $
       Do_PS = -1 $
   else  $
       Do_PS = fix(Do_PS)


   return
end

;----------------------------------------------------------------------------

function GAMAP_InterpreteSel, S

   ;=================================================================
   ; Interprete a selection string of the form N1,N2-N3,...
   ;=================================================================

   ; First try to seperate Sel by blanks. This form can be used
   ; to list individual records. Then seperate each term by ','
   ; which is an alternative method. Each comma (or blank) seperated
   ; term can then contain a '-' to indicate a range.
   res = -1L

   S = StrTrim(S,2)

   on_ioerror,bad_format

   ; Now call STRBREAK routine to do the string-splitting 
   ; for all versions of IDL (bmy, 1/17/02)
   csel = StrBreak( S, ',' )

   for j=0,n_elements(csel)-1 do begin

      ; Now call STRBREAK routine to do the string-splitting 
      ; for all versions of IDL (bmy, 1/17/02)
      dsel = StrTrim( StrBreak( csel[j], '-' ), 2 )

      for i=0, n_elements(dsel)-1 do  $
         if (strpos(dsel[i], ' ') gt 0) then $
            goto, Bad_Format
      if (n_elements(dsel) eq 1) then $
         dsel = [ dsel, dsel ]

      rec0=-1
      rec1=-1
      reads,dsel,rec0,rec1
      res = [ res, indgen(rec1-rec0+1)+rec0 ]
   endfor
   on_ioerror,NULL

   ; remove dummy
   if (n_elements(res) gt 1) then res = res[1:*]

   ; everything seems OK: return res-1 as sel for proper indexing
   return,res-1

Bad_Format:
   message,'Bad numerical format in selection string!',/Continue,/NoName
   message,'Allowed syntax is N[-M][,N2[-M2]][,...] (example: 1,3,6-10)', $
          /NoName,/INFO

   return,res-1
end

;----------------------------------------------------------------------------

function GAMAP_SelectDataBlocks, Max_Sel, Quit=Quit, Save=Save

   ;=================================================================
   ; GAMAP_SelectDataBlocks prompts the user to select a a data
   ; block (for simple plotting) or range of data blocks (for
   ; (timeseries animation).  (bmy, 2/17/99)
   ; - added SAVE option (mgs, 05/20/99)
   ;=================================================================

   ; GAMAP Common blocks
   common SaveValues,    Sel_Sav, Lev_Sav,   Lon_Sav, $
                         Lat_Sav, PType_Sav, Avg_Sav, $
                         Iso_Sav

   ; Initialize variables
   Sel  = -1
   Quit = 0

Repeat_Selection:
   print

   ; set default string: make sure it does not exceed allowed range
   LStrDefault = StrTrim(Sel_Sav,2)
   saved = GAMAP_InterpreteSel(LStrDefault)
   if (max(saved) gt Max_Sel) then LStrDefault = '1'

   print,'Enter S as first character to save data blocks.'
   print,'Select data records. Example: 1,3-9,20'
   LStr = ''
   Read, LStr, Prompt='(default : ' + LStrDefault+', Q=Quit, S=Save) >> '

   LStr = strtrim(LStr,2)

   ; Check if user wants to save
   Save = StrPos(strupcase(LStr),'S') eq 0
   if (Save) then begin
      LStr = strmid(LStr,1,255)   ; delete 'S'
      LStr = strtrim(LStr,2)      ; and eliminate leading blanks
   endif

   if ( LStr eq '' ) then LStr = LStrDefault
   if ( StrUpcase( LStr ) eq 'Q' ) then begin
      Quit = 1
      return,-1
   endif

   sel = GAMAP_InterpreteSel(LStr)

   ; already complained about syntax errors
   if (min(Sel) lt -1) then goto,Repeat_Selection

   ; complain about selections out of range
   test = where(sel lt 0 OR sel ge Max_Sel)
   if (test[0] ge 0) then begin
      message,'Record number(s) out of range! Try again!',  $
            /Continue,/NoName
      goto,Repeat_Selection
   endif

   ; everything seems OK: return res-1 as sel for proper indexing
   print,'Selected records : ',sel+1,format='(A,512I4)'

   ; Save default for next time and return
   Sel_Sav = LStr
   return, Sel

end

;----------------------------------------------------------------------------

pro GAMAP_SelectPlotType, $
         NDim, NLon, NLat, NLevel, AvMode, TotalMode, PType,  $
         Polar=Polar,  Quit=Quit

   ;=================================================================
   ; GAMAP_SelectPlotType (bmy, 2/17/99) does the following:
   ;
   ;   (1) For a 2-D plot (NDIM=2), query the user for plot options
   ;   (2) For 0-D, 1-D, and 3-D plots, print informational message
   ;
   ; NOTES: PTYPE is returned as -1 unless otherwise assigned here.
   ;
   ;        If QUIT=1 is returned to the calling program, then this
   ;        denotes that the user aborted the selection process,
   ;        and wishes to quit GAMAP.
   ;=================================================================

   ; Common blocks
   common SaveValues,    Sel_Sav, Lev_Sav,   Lon_Sav, $
                         Lat_Sav, PType_Sav, Avg_Sav, $
                         Iso_Sav

   ; Initialize variables
   Quit  = 0
   Polar = keyword_set(Polar)

   ; Case Statement for selecting plot type based on # of dimensions
   case ( NDim ) of

      ;---------------------------
      ; 0 Dimensions: 
      ; Print value of data
      ;---------------------------
      0: begin
         if ( NLon eq 1 AND NLat eq 1 AND NLevel eq 1 ) then begin
            DimStr = ''
         endif else begin
            if ( AvMode gt 0 )           $
               then DimStr = 'average ' $
               else DimStr = 'total '
         endelse

         DimStr = 'GAMAP will print the ' + DimStr + 'value of the data.'
         Message, DimStr, /Info, /NoName
         PType = -1
      end

      ;----------------------------
      ; 1 Dimension: 
      ; Create a line plot
      ;----------------------------
      1: begin
         Message, 'GAMAP will create a line plot.', /Info, /NoName
         Ptype = -1
      end

      ;-----------------------------
      ; 2 Dimensions: 
      ; query user for contour plot 
      ; or pixel plot options
      ;-----------------------------
      2: begin
         print
         Menu =  [ 'B/W Contour lines',     $
                   'Colored contour lines', $
                   'Filled contours',       $
                   'Smooth Pixel Plot',     $
                   'Coarse Pixel Plot' ]

         if ( Polar ) then begin
            Menu = Menu[ 0:2 ]
            if ( PType_Sav gt 2 ) then Ptype_Sav = 2
         endif

         PType = Choice( Menu,  Title='Select 2-D plot type:',  $
                         Default=Ptype_Sav, /BY_INDEX)


         if ( PType lt 0 ) then begin
            Quit = 1
            return
         endif

         ; Store for next iteration
         Ptype_Sav = Ptype
      end

      ;-----------------------------
      ; 3 Dimensions: 
      ; Show 3-D Isopleth map 
      ; (bmy, 1/22/01)
      ;-----------------------------
      3: begin
         Message, 'GAMAP will plot a 3-D isopleth surface.', /Info, /NoName
         PType = -1
      end

   endcase

   return
end

;----------------------------------------------------------------------------

pro GAMAP_QueryIsoPleth, IsoPleth, N_Blocks, Quit=Quit

   ;====================================================================
   ; Procedure GAMAP_QueryIsoPleth (bmy, 1/22/01) asks the user to
   ; supply an array of isopleth values for the 3-D map, if none has
   ; been supplied via the ISOPLETH keyword.
   ;====================================================================

   ; Common blocks
   common SaveValues,    Sel_Sav, Lev_Sav,   Lon_Sav, $
                         Lat_Sav, PType_Sav, Avg_Sav, $
                         Iso_Sav

   ; Compute ISOPLETH if it the keyword hasn't been specified
   if ( N_Elements( IsoPleth ) eq 0 ) then begin

      ; Initialize strings 
      LStr = ''

      if ( N_Elements( Iso_Sav ) gt 0 )                                       $
         then LStrDefault = StrTrim( String( Iso_Sav, Format='(f10.3)' ), 2 ) $
         else LStrDefault = ''

      Print
      Print, 'Default Isopleths: ', LStrDefault
      Read, LStr, Prompt='Enter isopleth value(s) (Q=Quit): >> '
      if ( LStr eq '' ) then LStr = LStrDefault

      ; Quit if 'Q' was selected
      if ( StrUpcase( StrTrim( LStr[0], 2 ) ) eq 'Q' ) then begin
         Quit = 1
         return
      endif 

      ; Convert to floating point
      IsoPleth = Float( LStr )

      ; If ISOPLETH has less values than there are data blocks,
      ; then replicate the last element of ISOPLETH 
      if ( N_Elements( IsoPleth ) lt N_Blocks ) then begin
         N_I       = N_Elements( IsoPleth )
         N_Missing = N_Blocks - N_I
         Tmp       = Replicate( IsoPleth[ N_I - 1L ], N_Missing )
         IsoPleth  = [ IsoPleth, Tmp ]
      endif

      ; Display selected values of ISOPLETH
      S = 'Selected Isopleths: ' 
      for N = 0L, N_Elements( IsoPleth ) - 1L do begin
         S = S + StrTrim( String( IsoPleth[N], Format='(f14.3)' ), 2 ) + ' '
      endfor
      Message, S, /Info, /NoName

      ; Save Isopleths for next time
      Iso_Sav = IsoPleth
   endif

   return
end

;----------------------------------------------------------------------------

pro GAMAP_StoreGridInfo, FileInfo, FileIndex, Quit=Quit

   ;====================================================================
   ; Procedure GAMAP_StoreGridInfo (bmy, 3/5/99) computes the
   ; GRIDINFO structure those elements of FILEINFO that correspond to
   ; elements of DATAINFO (contained in index array FILEINDEX).
   ;====================================================================
   FORWARD_FUNCTION ChkStru, CTM_Grid

   ; First find the unique elements of FILEINDEX.
   ; This prevents re-storing the GRIDINFO structure
   ; for the same FILEINFO multiple times.
   F = FileIndex( Uniq( FileIndex, Sort( FileIndex ) ) )

   ; Loop over the unique elements of FILEINDEX
   for N = 0, N_Elements( F ) - 1 do begin

      ; Get the MODELINFO structure from FILEINFO
      ModelInfo = FileInfo[ F[ N ] ].ModelInfo

      ; Check to make sure MODELINFO is a valid structure
      if ( not ChkStru( ModelInfo, [ 'NAME', 'RESOLUTION' ] ) ) then begin
         Message, 'Invalid MODELINFO structure!!', /Continue
         Quit = 1
         return
      endif

      ; Use MODELINFO to construct the GRIDINFO structure
      ; if none has been previously defined (**** mgs, 03/30/99)
      if (not Ptr_Valid( FileInfo[ F[ N ] ].GridInfo ) ) then begin

         ; NOTE: If MODELINFO.NLAYERS = 0, then CTM_TYPE will
         ; automatically return a structure w/ no vertical level
         ; information (bmy, 7/3/01)
         GridInfo  = CTM_Grid( ModelInfo )

         ; Check to make sure GRIDINFO is a valid structure
         if ( not ChkStru( GridInfo, [ 'IMX', 'JMX' ] ) ) then begin
            Message, 'Invalid GRIDINFO structure!!', /Continue
            Quit = 1
            return
         endif

         ; Make a new pointer to the GRIDINFO structure in FILEINFO
         FileInfo[ F[ N ] ].GridInfo = Ptr_New( GridInfo )
      endif
   endfor

   return
end

;----------------------------------------------------------------------------

function GAMAP_UserRangeEntry, $
              Name, Default, Range=Range, IsGlobal=IsGlobal,  $
              Quit=Quit, Format=FFormat, _EXTRA=e

   ;=================================================================
   ; GAMAP_USERRANGEENTRY prompts the user to enter a value or
   ; range for a dimension of CTM data (e.g. longitude, latitude,
   ; levels).  If the user hits return, then default values are used.
   ;
   ; IsGlobal prevents equal lower and upper boundaries for longitudes 
   ;=================================================================

   ; Pass External Functions
   FORWARD_FUNCTION Default_Range, DefRange_Str2Num

   ; Error checking
   if ( N_Elements( FFormat ) eq 0 ) then FFormat = '(f10.2)'
   IsLongitude = ( StrUpCase( StrTrim( Name, 2 ) ) eq 'LONGITUDE' )
   IsGlobal = keyword_set(IsGlobal)   ; needed only for longitudes

   ; Initialize variables
   Quit = 0

   ; Construct default string
   LStrDefault = StrTrim( String( default[0], Format=FFormat ), 2 ) + $
          '..' + StrTrim( String( default[1], Format=FFormat ), 2 )

   ; check if range spans dateline. If so, convert numeric default 
   ; value to 0..360
   IsPacific = IsLongitude AND ( ( default[1] lt default[0] ) OR $
                ( default[1] gt 180 ) )
   if (IsPacific) then begin
      Convert_Lon,Default,/Pacific
      Convert_Lon,Range,/Pacific
      if (IsGlobal) then Range = [ 0., 360. ]
   endif

   ; Query user
   LStr = ''
   print
   Read, LStr, Prompt='Enter '+name+' or '+name+' range (default : ' + $
      LStrDefault+', Q=Quit) >> '

   if ( LStr eq '' ) then LStr = LStrDefault
   if ( StrUpcase(LStr) eq 'Q' ) then begin
      Quit = 1
      return,-1
   endif

   ; Convert input string to numeric 2-element vector
   numl = DefRange_Str2Num( Lstr, Default )
   ; and convert values to 0..360 if range spans dateline
   tmp = numl[0]
   if (IsPacific) then Convert_Lon,numl,/Pacific
   if (tmp eq -180.) then numl[0] = tmp   ; wouldn't work otherwise.

   ; Convert input to sorted numeric 2 element vector
   ; but do not sort longitudes(!)
;  print,'## numl, default, range = ',numl,default,range
   result = Default_Range( numl, default, /Limit2, NOSORT=IsLongitude, $
                           _EXTRA=e )

   ; Convert everything back to -180..180 if it had been converted before
   if (IsPacific) then begin
      Convert_Lon,Default,/Atlantic
      Convert_Lon,Range,/Atlantic
      if (result[1] ne 360.) then $
         Convert_Lon,Result,/Atlantic
   endif

   ; Store for next iteration
   default = [ result[0], result[1] ]

   return,result
end

;----------------------------------------------------------------------------

function GAMAP_GetFrameFileName, FileName, FrameN
   
   ;====================================================================
   ; Internal function GAMAP_GetFrameFileName replaces number tokens
   ; in file names for individual animation frames (bmy, 12/10/02)
   ;====================================================================
   NumText     = StrTrim( String( FrameN, Format='(i5.5)' ), 2 )
   TmpFileName = Replace_Token( FileName, '%NNNNN%', NumText )
   
   if (FrameN lt 10000) then begin
      NumText     = StrTrim( String( FrameN, Format='(i4.4)' ), 2 )
      TmpFileName = Replace_Token( TmpFileName, '%NNNN%', NumText )
   endif
            
   if (FrameN lt 1000) then begin
      NumText     = StrTrim( String( FrameN, Format='(i3.3)' ), 2 )
      TmpFileName = Replace_Token( TmpFileName, '%NNN%', NumText )
   endif

   if (FrameN lt 100) then begin
      NumText     = StrTrim( String( FrameN, Format='(i2.2)' ), 2 )
      TmpFileName = Replace_Token( TmpFileName, '%NN%', NumText )
   endif

   if (FrameN lt 10) then begin
      NumText     = StrTrim( String( FrameN, Format='(i1.1)' ), 2 )
      TmpFileName = Replace_Token( TmpFileName, '%N%', NumText )
   endif

   return, TmpFileName

end

;----------------------------------------------------------------------------


pro GAMAP, DiagN,                                                   $
           FileName=FileName,          NoFile=NoFile,               $
           Tracer=Tracer,              Tau0=Tau0,                   $
           Date=Date,                  GISS_Date=GISS_Date,         $
           PS=Do_PS,                   TimeStamp=TimeStamp,         $
           OutFileName=OutFileName,    IsoPleth=IsoPleth,           $
           Do_BMP=Do_BMP,              BMPFileName=BMPFileName,     $
           Do_GIF=Do_GIF,              GIFFileName=GIFFileName,     $
           Do_JPEG=Do_JPEG,            JPEGFileName=JPEGFileName,   $
           Do_PNG=Do_PNG,              PNGFileName=PNGFileName,     $
           Do_TIFF=Do_TIFF,            TIFFFileName=TIFFFileName,   $
           Frame0=Frame0,              Do_MPEG=Do_MPEG,             $
           MPEGFileName=MPEGFileName,  ResetDefaults=ResetDefaults, $
           AutoRange=AutoRange,        YRange=YRange,               $
           Help=Help,                  Polar=Polar,                 $
           Result=Result,              TopTitle=TopTitle,           $
           TTSize=TTSize,              XSize=XSize,                 $
           YSize=YSize,                XOffset=XOffset,             $
           YOffset=YOffset,            _EXTRA=e 

   ;=================================================================
   ; GAMAP: Main program
   ; User-interface for ctm_plot
   ; Allows menu driven interactive plotting
   ;=================================================================

   ; Pass internal and external functions
   FORWARD_FUNCTION ChkStru,  Choice,   Make_Selection,  $
                    NYMD2Tau, StrBreak, Replace_Token

   ; Common blocks
   @gamap_cmn
   common FirstTimeFlag, FirstTime
   common SaveValues,    Sel_Sav, Lev_Sav,   Lon_Sav,  $
                         Lat_Sav, PType_Sav, Avg_Sav,  $
                         Iso_Sav

   ; First-time initializations, etc
   if ( N_Elements( FirstTime ) eq 0 ) then FirstTime = 1
   ResetDefaults = Keyword_Set( ResetDefaults )
   if (ResetDefaults) then FirstTime = 1

   if (FirstTime) then begin
      print,'============================================================='
      print
      print,'   WELCOME  TO  G A M A P  -----  Version 2.03, Apr 2005'
      print
      print,'   Global Atmospheric Modeling (output) Analysis Package'
      print,'   Martin Schultz and Bob Yantosca, Harvard University'
      print,'============================================================='
      print

      ; Set defaults for user selections
      Lev_Sav    = [  -999 , 999   ]
      Lon_Sav    = [ -999.0, 999.0 ]
      Lat_Sav    = [ -999.0, 999.0 ]
      PType_Sav  = 4     ; Coarse pixel plot is now the default (bmy, 1/22/01)
      Avg_Sav    = 0
      Sel_Sav    = '1'
      Iso_Sav    = 35.0  ; (bmy, 1/23/01)

      FirstTime  = 0
      ResetDefaults = 1

      ; make sure Default_Range gets compiled
      help,/ROUTINES,output=o
      i=where(strpos(o,'DEFRANGE_STR2NUM') ge 0) 
      if (i[0] lt 0) then resolve_routine,'default_range',/IS_FUNCTION

   endif

   Do_Animation  = 0
   Do_MultiPanel = 0 ; not really used (but set correctly just in case ...)


   if ( Keyword_Set( Help ) ) then begin
      print,'Usage: gamap [,OPTIONS]'
      print
      print,' OPTIONS:'
      print
      print,' DIAGN         : Diagnostic number or category name'
      print,' TRACER        : Tracer number'
      print,' TAU0, DATE    : Start time of the data record'
      print,' GISS_DATE     : Start time of the data record for GISS output'
      print,' FILENAME      : CTM output file name'
      print,' /NOFILE       : Use previously read records only'
      print,' /PS           : Create postscript file without prompt.'
      print,' OUTFILENAME   : Name of postscript output file'
      print,' /DO_BMP       : Save animation frames as BMP files'
      print,' BMPFILENAME   : Name of BMP output file '
      print,' /DO_GIF       : Save animation frames as GIF files'
      print,' GIFFILENAME   : Name of GIF output file '
      print,' /DO_JPEG      : Save animation frames as JPEG files'
      print,' JPEGFILENAME  : Name of JPEG output file '
      print,' /DO_PNG       : Save animation frames as PNG files'
      print,' PNGFILENAME   : Name of PNG output file '
      print,' /DO_TIFF      : Save animation frames as TIFF files'
      print,' TIFFFILENAME  : Name of TIFF output file '
      print,' /DO_MPEG      : Save animation frames into a MPEG file'
      print,' MPEGFILENAME  : Name of MPEG animation file'
      print,' FRAME0        : Specify number of first frame of output'
      print,' /RESETDEFAULTS: Start GAMAP all over but keep data'
      print,' YRANGE=[Y0,Y1]: Specify scale'
      print,' /AUTORANGE    : Scale all records equally'
      print,' /POLAR        : Polar map plots (only contours)' 
      print,' TOPTITLE      : Specify a title for the top of the page'
      print,' TTSIZE        : Specify the charsize for TOPTITLE'
      print,' RESULT        : Structure containing data, X & Y coordinates'
      print,' /HELP         : Display this help page.'

      print
      print,'For more information consult the GAMAP reference guide', $
            ' gamap.pdf.'
      return
   endif

   ;====================================================================
   ; set defaults
   ; Use defaults from gamap.defaults
   ; Command line options override defaults
   ;====================================================================
   if ( n_elements( diagn    ) eq 0 ) then diagn = 0     ; all diagnostics

   ; input filename:
   ; - if nothing was read and no filename is given, use entry from  
   ;   gamap.defaults
   ; - otherwise ignore filename argument if NOFILE is set and there
   ;   are entries in the global list
   if (keyword_set(NoFile) AND ptr_valid(pGlobalFileInfo) ) $
      then undefine,FileName $
      else if (n_elements(FileName) eq 0) then FileName = ''

   ;---------------------
   ; PostScript defaults
   ;---------------------
   if ( N_Elements( Do_PS ) gt 0 )              $
      then Do_PS = Keyword_Set( Do_PS )         $
      else Do_PS = CreatePostscript

   if ( N_Elements( TimeStamp ) gt 0 )          $
      then TimeStamp = Keyword_Set( TimeStamp ) $
      else TimeStamp = AddTimeStamp

   if ( N_Elements( OutFileName ) eq  0  )      $
      then OutFileName = DefaultPSFilename

   ;---------------------
   ; BMP defaults
   ;---------------------
   if ( N_Elements( Do_BMP ) gt 0 )             $
      then Do_BMP = Keyword_Set( Do_BMP )       $
      else Do_BMP = CreateBMP

   if ( N_Elements( BMPFileName  ) eq 0 )       $
      then BMPFileName = DefaultBMPFileName

   ;---------------------
   ; GIF defaults
   ;---------------------
   if ( N_Elements( Do_GIF ) gt 0 )             $
      then Do_GIF = Keyword_Set( Do_GIF )       $
      else Do_GIF = CreateGIF

   if ( N_Elements( GIFFileName  ) eq 0 )       $
      then GIFFileName = DefaultGIFFileName

   ;---------------------
   ; JPEG defaults
   ;---------------------
   if ( N_Elements( Do_JPEG ) gt 0 )            $
      then Do_JPEG = Keyword_Set( Do_JPEG )     $
      else Do_JPEG = CreateJPEG

   if ( N_Elements( JPEGFileName  ) eq 0 )      $
      then JPEGFileName = DefaultJPEGFileName

   ;---------------------
   ; PNG defaults
   ;---------------------
   if ( N_Elements( Do_PNG ) gt 0 )             $
      then Do_PNG = Keyword_Set( Do_PNG )       $
      else Do_PNG = CreatePNG

   if ( N_Elements( PNGFileName  ) eq 0 )       $
      then PNGFileName = DefaultPNGFileName

   ;---------------------
   ; TIFF defaults
   ;---------------------
   if ( N_Elements( Do_TIFF ) gt 0 )            $
      then Do_TIFF = Keyword_Set( Do_TIFF )     $
      else Do_TIFF = CreateTIFF

   if ( N_Elements( TIFFFileName  ) eq 0 )      $
      then TIFFFileName = DefaultTIFFFileName

   ;---------------------
   ; MPEG defaults
   ;---------------------
   if ( N_Elements( Do_MPEG ) gt 0 )            $
      then Do_MPEG = Keyword_Set( Do_MPEG )     $
      else Do_MPEG = CreateMPEG

   if ( N_Elements( MPEGFileName  ) eq 0 )      $
      then MPEGFileName = DefaultMPEGFileName

   ; First frame number
   if ( N_Elements( Frame0 ) eq 0 ) then Frame0 = 1
   Frame0 = Frame0[0] > 1

   ; auto-range: set to -1 if GAMAP shall decide itself
   ; force to zero if YRange is given
   if (n_elements(AutoRange) gt 0) $
      then AutoRange  = Keyword_Set( AutoRange ) $
      else AutoRange = -1

   if (n_elements(YRange) eq 2) $
      then AutoRange = 0  $
      else undefine,YRange   ; make sure it doesn't interfere with anything

   ; see if tau value was passed or date
   if (n_elements(tau0) eq 0 AND n_elements(date) gt 0) then $
      tau0 = nymd2tau(date,GISS=GISS_Date)

   Polar = keyword_Set(Polar)

   if ( n_elements( TopTitle ) ne 1 ) then TopTitle = ''
   if ( n_elements( TTSize   ) ne 1 ) then TTSize   = 2.0

   ; Hardwire QUIET flag for CTM_GET_DATA.  This reduces a lot of
   ; printing to the screen. (bmy, 10/27/04)
   Quiet = 1L

   ;=================================================================
   ; get all data records (but don't read data yet)
   ;=================================================================
   CTM_Get_Data, DataInfo, DiagN, File=FileName,  $
      Tracer=Tracer, Tau0=Tau0, Status=2, Quiet=Quiet, _EXTRA=e 

   if (n_elements(datainfo) eq 0) then begin
      message,'No matching records found !',/Continue
      return
   endif

   ;=================================================================
   ; List available diagnostics with item number on the screen
   ;=================================================================
   ctm_print_datainfo,datainfo,output=r,/NOPRINT

   ; The STRING commmand can only handle 1024 lines at a time,
   ; so concatenate arrays of 1024 elements each (bmy, 6/19/00)
   for I = 0L, N_Elements( R ) / 1024L do begin
      Tmp = String( SIndGen( 1024 ) + ( I * 1024L ), Format='(i4," : ")' ) 

      if ( I eq 0L )          $
         then NS = [ Tmp ]    $
         else NS = [ NS, Tmp ]
   endfor

   ; Truncate so that NS has the same # of elements as R (bmy, 6/19/00)
   NS = NS[ 0:N_Elements(R)-1L ] 

   ; Set NS[0] blank, since that corresponds to the header line
   NS[0] = '       '

   ; Print data block info
   for i=0,n_elements(r)-1 do print,ns[i],r[i]

   ;=================================================================
   ; Prompt user to select a data block or data block range
   ; If more than one data block is selected GAMAP switches to
   ; either multipanel or animation mode depending on the value
   ; of !p.multi.
   ;=================================================================
   Sel = GAMAP_SelectDataBlocks( N_Elements( R ), Quit=Quit, Save=Save )

   if ( Quit ) then return

   ; *** NEW! If user wanted to save data blocks, do so and quit
   if ( Save ) then begin
      message,'Saving '+strtrim(n_elements(sel),2)+' data records...', $
          /INFO

      ; NOTE: Tracer numbers will be adjusted so that they are
      ;       mod 100 in "ctm_writebpch.pro" (bmy, 6/7/00)
      CTM_WriteBPCH, DataInfo[sel], Filename=DefaultPath, _EXTRA=e
      return       
   endif

   ; If we have selected multiple data blocks, then if MULTIPANEL
   ; has been called, this will generate a multi-panel plot.  If 
   ; MULTIPANEL has not been called, then create an animation.  
   if (n_elements(Sel) gt 1) then begin
      if ( !P.MULTI[1] * !P.MULTI[2] gt 1 ) $
         then Do_MultiPanel = 1             $
         else Do_Animation  = 1
   endif

   ;=================================================================
   ; For the diagnostic selected, access the proper records from
   ; the DATAINFO structure, and store them in D.   Also access
   ; the global FILEINFO structure from the common block.
   ;=================================================================
   D        = DataInfo[ Sel ]
   FileInfo = *( pGlobalFileInfo )

   ;=================================================================
   ; For each element of D, find the corresponding element of
   ; FILEINFO.  Return an index array of matches, FILEINDEX.
   ; Also store a pointer to the GRIDINFO structure for each of
   ; the matching elements of FILEINFO.
   ;=================================================================
   FileIndex = Make_Selection(FileInfo.Ilun, D.Ilun, /REQUIRED)
   if ( FileIndex[0] lt 0 ) then return

   GAMAP_StoreGridInfo, FileInfo, FileIndex, Quit=Quit
   if ( Quit ) then return

   ;=================================================================
   ; For animation, check to make sure that all of the data
   ; blocks have the same dimensions and model grids
   ;=================================================================
   if ( Do_Animation ) then begin
      Success = GAMAP_CheckDataBlockConsistency( D, FileInfo, FileIndex )
      if ( not Success ) then return
   endif

   ; get number of final records to plot
   NRec = N_Elements(D)

   ;=================================================================
   ; Compute the "natural" extent of the data block in longitude,
   ; latitude and vertical levels.  Since all elements of D now
   ; must have the same range, pass the DATAINFO and FILEINFO
   ; structures corresponding to the first data block.
   ;=================================================================
   Success = GAMAP_GetDataBlockRanges( D[0], FileInfo[ FileIndex[0] ], $
                           TmpLon_Range, TmpLat_Range, TmpLev_Range ,  $
                           Polar=Polar, First=( max(Lat_Sav) gt 100. ) )
   if ( not Success ) then return

   ;### Debug output (bmy, 2/19/99)
   ;* DEBUG=1
   if ( Debug ) then begin
      print, '### GAMAP.PRO: internal Lon_Range: ', TmpLon_Range
      print, '### GAMAP.PRO: internal Lat_Range: ', TmpLat_Range
      print, '### GAMAP.PRO: internal Lev_Range: ', TmpLev_Range
   endif
   ;* DEBUG=0

   ;=================================================================
   ; Check consistency of xyz_Sav fields for geographical domain
   ; If there is any change in either LONs or LATs reset both
   ; Longitude ranges are somewhat tricky because of the possibility
   ; of datablocks spanning the dateline and the fact that global
   ; fields have identical left and right boundaries in normalized
   ; longitude coordinates (i.e. mod 360).
   ;=================================================================

   ; level: just need to crop Lev_Sav if data records contain less
   if (Lev_Sav[0] lt TmpLev_Range[0] OR $
       Lev_Sav[1] gt TmpLev_Range[1]) then Lev_Sav = TmpLev_Range

   RangeNeedsChange = 0
   ; latitude: likewise
   if (Lat_Sav[0] lt TmpLat_Range[0]) then RangeNeedsChange = 1
   if (Lat_Sav[1] gt TmpLat_Range[1]) then RangeNeedsChange = 1

   ; longitude: need to reset if data is WE and ranges are EW or 
   ; vice versa
   ; check if data block spans whole globe
   IsGlobal = 0
   if (TmpLon_Range[1]-TmpLon_Range[0] eq 360.) then IsGlobal=1

   ; see if datablock spans dateline or last user entry spans dateline
   isEW = Lon_Sav[0] gt Lon_Sav[1]
   isTmpEW = TmpLon_Range[0] gt TmpLon_Range[1]
   IsConverted = 0

   ; if data block is global, any range will do
   if (not IsGlobal) then begin
 ;    if (isEW + isTmpEW eq 1) then $
 ;        RangeNeedsChange = 1  $       ; only one vector spans dateline
 ;    else begin
      if (isEW or isTmpEW) then begin
         ; if both vectors span dateline, convert to 0..360
         IsConverted = 0
      ;  if (isEW) then begin
            Convert_Lon,Lon_Sav,/Pacific
            Convert_Lon,TmpLon_Range,/Pacific
            IsConverted = 1
      ;  endif
      endif
         ; check if data block fits in saved ranges
         if (Lon_Sav[0] lt TmpLon_Range[0]) then RangeNeedsChange = 1
         if (Lon_Sav[1] gt TmpLon_Range[1]) then RangeNeedsChange = 1
         ; convert back if necessary
         if (IsConverted) then begin
            Convert_Lon,Lon_Sav,/Atlantic
            Convert_Lon,TmpLon_Range,/Atlantic
         endif
 ;    endelse
   endif

; print,'##gamap.pro: isglobal, lon_sav,tmplon_range:',isglobal, lon_sav,tmplon_range,format='(A,i2,4f8.1)'
   if (RangeNeedsChange) then begin
      Lon_Sav = TmpLon_Range
      Lat_Sav = TmpLat_Range
   endif


   ;### Debug output (bmy, 2/19/99)
   ;* DEBUG=1
   if ( Debug ) then begin
      print, '### GAMAP.PRO: Lon_Sav          : ', Lon_Sav
      print, '### GAMAP.PRO: Lat_Sav          : ', Lat_Sav
      print, '### GAMAP.PRO: Lev_Sav          : ', Lev_Sav
   endif
   ;* DEBUG=0

   ;=================================================================
   ; select geographical region
   ;
   ; Enter level, longitude, and latitude range
   ; If user presses return, use default range
   ;
   ; NOTE: Use floating point format for LON and LAT (bmy, 2/19/99)
   ;=================================================================
Try_Again:

   ; Get vertical levels
   Level = fix( GAMAP_UserRangeEntry( 'level', Lev_Sav, Format='(i10)', $
                                      Range=[1,100], Quit=Quit ) )
   if ( Quit ) then return
   Print, Level, Format='("  Vertical Levels: ",2i10 )'

   ;=================================================================
   ; Get longitudes.  If /POLAR is set, then set lon = [-180,180]
   ; automatically.  Otherwise have user enter data.
   ;=================================================================
   if ( Polar ) then begin
      Lon     = [ -180, 180 ]
      Lon_Sav = Lon
      print
      Message, 'LON is automatically set to [-180, 180] for polar plot', $
         /Continue
   endif else begin
Try_Lon_Again:
      Lon = GAMAP_UserRangeEntry( 'longitude', Lon_Sav, Range=TmpLon_Range, $
                                  IsGlobal=IsGlobal, Quit=Quit )
      if ( Quit ) then return

      ; Reset LON to the nearest grid box longitude centers
      Lon = GAMAP_FindNearestCenters( FileInfo[ FileIndex[0] ], Lon,  $
                                      /Longitude )
      Print, Lon, Format='("  Nearest Grid Box Longitude Centers: ",2f10.2 )'
   endelse

   ;=================================================================
   ; Get latitudes.  If /POLAR is set, make sure that the lat range
   ; does not straddle the equator (polar plots are only for one
   ; hemisphere!!!).  Also suppress polar box warning for TVIMAGE.
   ;=================================================================
Try_Lat_Again:
   Lat = GAMAP_UserRangeEntry( 'latitude', Lat_Sav,$
                               Range=TmpLat_Range, Quit=Quit )
   if ( Quit ) then return

   ; Reset LAT to the nearest grid box latitude centers
   ; Polar keyword suppresses warning for half-polar boxes (bmy, 5/26/99)
   Lat = GAMAP_FindNearestCenters( FileInfo[ FileIndex[0] ], Lat, $
                                   /Latitude, Polar=Polar )

   ; For polar plots, restrict lat range to one hemisphere only
   if ( Polar ) then begin
      LatMin = Min( Lat, Max=LatMax )
      IsNH   = ( LatMin ge 0 ) AND ( LatMax ge 0 )
      IsSH   = ( LatMin lt 0 ) AND ( LatMax lt 0 )

      ; Lat range straddles equator!
      ; Get user to re-enter data
      if ( not IsNH AND not IsSH ) then begin
         S = 'For a polar plot, the latitude range ' + $
             'must only span one hemisphere!'
         Message, S, /Continue
         goto, Try_Lat_Again

      endif

      if (IsNH) then LatMax =  90.
      if (IsSH) then LatMin =  -90.
      Lat     = [ LatMin, LatMax ]
      Lat_Sav = Lat
   endif

   Print, Lat, Format='("  Nearest Grid Box Latitude Centers: ",2f10.2 )'

   ;=================================================================
   ; Check the number of unique elements in LON, LAT, and LEVEL.
   ; Here, NLON, NLAT, NLEVEL will either be 1 or 2
   ;
   ; NOTE the following weakness: If a user enters two different
   ; values that belong to one grid box, GAMAP will think there
   ; will be more than one value for for this dimension and ask for
   ; averaging or totaling. The same may happen if index offsets
   ; are used (which will be supported in the next version).
   ;=================================================================
   NLon   = N_Uniq( Lon  )
   NLat   = N_Uniq( Lat  )
   NLevel = N_Uniq( Level )

   ;=================================================================
   ; DIMSTR contains descriptor strings for each dimension.
   ;
   ; ARR is an array of dimension information flags:
   ;    ARR[i] = 0 -> Dimension [i] has been averaged/totaled
   ;    ARR[i] = 1 -> There is a single point along Dimension [i]
   ;    ARR[i] > 1 -> There are multiple points along Dimension [i]
   ;
   ; NDIM is the number of dimensions of the plot.
   ;=================================================================
   Arr = [ NLon, NLat, NLevel ]

   GAMAP_PrintDimInfo, Arr, NDim=NDim

   ;====================================================================
   ; If at least one dimension contains more than one value,
   ; query user for averaging (or totaling).
   ;
   ; For safety...if multiple 3-D ata blocks are selected, make sure
   ; only to vizualize the first data block.  Print a message.
   ;====================================================================
   GAMAP_QueryAverageOrTotal, Arr, NDim, AvMode, TotalMode, Quit=Quit
   if ( Quit ) then return

   ;====================================================================
   ; For 0-D, 1-D and 3-D plots, print an informational message.
   ; For 2-D plots, ask user for type of plot (contour or pixel)
   ;
   ; NOTE: PTYPE is now returned as -1 unless redefined
   ;       QUIT = 1 is now the criteria for exiting GAMAP (bmy, 2/16/99)
   ;====================================================================
   GAMAP_SelectPlotType, $
      NDim, NLon, NLat, NLevel, AvMode, TotalMode, PType,  $
      Polar=Polar, Quit=Quit

   ; Selection was aborted
   if ( Quit ) then return

   ; Contour Plot Options
   if ( PType ge 0 ) then begin
      MContour = ( PType le 1 )
      FContour = ( PType eq 2 )
      Sample   = ( PType eq 4 )
      if ( PType eq 0 ) then C_Colors = 1
   endif

   ;=================================================================
   ; print units in D and query whether unit conversion shall be
   ; made. A unit conversion will attempt to convert the units of
   ; *ALL* seelcted records to the new unit.
   ;=================================================================
   print
   if (NRec gt 9) then sx =  '...' else sx =  ''
   tmps = string(strtrim(d[0:(nrec-1) < 9].unit,2), sx, format='(9(A,2X),A)')
   print, 'Units : ', tmps

   ustr = ''
   read,ustr,prompt='Enter new unit for all (Q=Quit, default : don''t touch) >> '
   ustr =  strtrim(ustr, 2)

   if (strupcase(ustr) eq 'Q') then return
   DoNot_ConvertUnit = (ustr eq '')

   ;=================================================================
   ; After converting units, ask user for the value of the isopleth
   ; for which to generate a 3-D map.
   ;=================================================================
   if ( NDim eq 3 ) then begin
      GAMAP_QueryIsoPleth, IsoPleth, N_Elements( D ), Quit=Quit
      if ( Quit ) then return

      ; Don't animate for now (bmy, 1/22/01)
      Do_Animation = 0
   endif

   ;====================================================================
   ; Get the minimum and maximum values over the entire set of animation 
   ; frames or panels. This is necessary if we are to ensure that the 
   ; color indices in each frame cover the same range of data values. 
   ; This option is forced by setting the AUTORANGE flag to 0 or 1.
   ;====================================================================
   if ( AutoRange lt 0 ) then AutoRange = Do_Animation

   if ( AutoRange ) then begin
      AutoYRange = GAMAP_AutoYRange( D,   AvMode, TotalMode, $
                                     Lon, Lat,    Level, Quiet=Quiet )

      ; update datainfo[sel] because data may have been read
      ; doesn't work but we should do something like this to
      ; prevent multiple reading of the same records !! ***** ####
; **  if (n_elements(d) eq n_elements(sel)) then DataInfo[Sel] = D
   endif

   ;====================================================================
   ; Prompt user for animation options and output file formats
   ;====================================================================
   GAMAP_QueryAnimationOptions, NDim, Do_Animation, $
      Do_BMP,  BMPFileName,  Do_GIF,  GIFFileName,  $
      Do_JPEG, JPEGFileName, Do_PNG,  PNGFileName,  $
      Do_TIFF, TIFFFileName, Do_MPEG, MPEGFileName, $
      Quit=Quit

   if ( Quit ) then return

   ;====================================================================
   ; Make sure that color 0 is WHITE and color 1 is BLACK
   ; This should be true w/ MYCT but let's make ABSOLUTELY sure!!!
   ;====================================================================
   TvLCT, R_Cur, G_Cur, B_Cur, /Get
   R_Cur[0] = 255  &  G_Cur[0] = 255  &  B_Cur[0] = 255
   R_Cur[1] =   0  &  G_Cur[1] =   0  &  B_Cur[1] =   0
   TVLct, R_Cur, G_Cur, B_Cur

   ;====================================================================
   ; Create the plot!  DO_PS controls whether or not to produce a 
   ; postscript file: '0'=never, '1'=always, '*QUERY'=ask user
   ; The /PS keyword overrides the default setting in gamap.defaults.
   ; No postscript output can be created from 0-D data, 3-D data,
   ; or timeseries animation.
   ;====================================================================
Do_The_Plot:
   
   ; Now allow for PostScript output for 3-D isopleth maps (bmy, 1/22/01)
   if ( Do_Animation OR NDim eq 0 ) $
      then Do_PS = 0                $
      else GAMAP_QueryPostScriptOptions, Do_PS, TimeStamp, OutFileName

   ;====================================================================
   ; Open output device (postscript file or window)
   ; _EXTRA options for example: /PORTRAIT, YSIZE, etc.
   ;====================================================================
   already_ps = (!D.Name eq 'PS')
   if (already_ps AND Do_Animation) then begin
      message,'Cannot do animation on postscript device! Reset to screen.',$
            /Continue
      Close_Device
      already_ps = 0
   endif
   if (not already_ps) then $

   Open_Device, PS=(Do_PS eq 1), FileName=OutFileName, /Color, $
      Xsize=XSize, YSize=YSize, XOffset=XOffset, YOffset=YOffset, _EXTRA=e

   ;====================================================================
   ; Loop over number of data blocks selected
   ;====================================================================

   ; Do all selected data blocks come from GEOS-CHEM station TS files?
   IndF  = Where( FileInfo[FileIndex].FileType eq 105, N_IndF )
   Is_TS = ( N_IndF eq N_Elements( FileIndex ) )

   ; If so, then we only have to loop once since we will
   ; pass all data blocks to CTM_PLOT_TIMESERIES
   if ( Is_TS )                         $
      then N_Selected = 1L              $
      else N_Selected = N_Elements( D )

   ; Loop over all selected data blocks
   for N = 0L, N_Selected-1L do begin

      ; Be careful -- assign an value for ISOPLETH to CTM_PLOT 
      if ( N_Elements( IsoPleth ) gt 0 ) $
         then TmpIsoPleth = IsoPleth[N]  $
         else TmpIsoPleth = 0            

      ; Use automatic range for min & max of data if AUTORANGE=1
      if ( AutoRange         ) then YRange = AutoYRange

      ; Use old unit string if DONOT_CONVERTUNIT =1
      if ( DoNot_ConvertUnit ) then ustr   = D[N].unit

      ; Select plotting program
      if ( Is_TS ) then begin
       
         ;-----------------------------------------------------------
         ; Call CTM_PLOT_TIMESERIES to plot timeseries data 
         ;-----------------------------------------------------------
         CTM_Plot_TimeSeries, D[0].Category,            $
            Tracer=D[0].Tracer,  Ilun=D[0].Ilun,        $
            Lev=Level,           YRange=YRange,         $
            Unit=UStr,           Use_DataInfo=DataInfo, $     
            Result=Result,       Quiet=Quiet,           $
            _EXTRA=e
      
      endif else begin

         ;-----------------------------------------------------------
         ; Call CTM_PLOT to plot individual data blocks sequentially
         ;-----------------------------------------------------------
         CTM_Plot, D[N].Category,                       $
            tracer=D[N].tracer,  use_datainfo=datainfo, $
            Tau0=D[N].Tau0,      Ilun=D[N].Ilun,        $
            lev=level,           lon=lon,               $
            lat=lat,             total=totalmode,       $
            average=avmode,      IsoPleth=TmpIsoPleth,  $
            contour=mcontour,    fcontour=fcontour,     $
            c_colors=c_colors,   sample=sample,         $
            unit=ustr,           YRange=YRange,         $
            Polar=Polar,         Result=Result,         $
            Quiet=Quiet,         _EXTRA=e

      endelse

      ;=================================================================
      ; Add top title for single (or animated) plots if user has 
      ; provided one and this is the last plot on the page
      ; (may actually be the second before last ...)
      ;
      ; We have to call MULTIPANEL with /NOERASE...otherwise we
      ; will advance by one panel too many.
      ;=================================================================
      if (Do_MultiPanel) then begin
         multipanel, last=LastPlotOnPage, /NoErase

         if (N eq n_elements(D)-1) $
            then LastPlotOnPage = 1    

      endif else $ 
         LastPlotOnPage = 1  

      if (LastPlotOnPage) then begin
         xyouts,0.5,0.98,toptitle,color=1,/norm,align=0.5, $
            charsize=TTSize,charthick=2 
      endif

      ;=================================================================
      ; Create BMP output
      ;=================================================================   
      if ( Do_BMP ) then begin

         ; Replace tokens in GIF file name w/ the frame number
         TmpFileName = GAMAP_GetFrameFileName( BMPFileName, Frame0 + N )

         ; Do the screen capture and write to BMP file
         ThisFrame   = TvRead( FileName=TmpFileName, /BMP )

      endif
       
      ;==============================================================
      ; Create GIF output
      ;==============================================================
      if ( Do_GIF ) then begin

         ; Replace tokens in GIF file name w/ the frame number
         TmpFileName = GAMAP_GetFrameFileName( GIFFileName, Frame0 + N )

         ; Do the screen capture and write to GIF file
         ThisFrame   = TvRead( FileName=TmpFileName, /GIF )

      endif
         
      ;=================================================================
      ; Create JPEG output
      ;=================================================================
      if ( Do_JPEG ) then begin

         ; Replace tokens in GIF file name w/ the frame number
         TmpFileName = GAMAP_GetFrameFileName( JPEGFileName, Frame0 + N )

         ; Do the screen capture and write to JPEG file
         ThisFrame   = TvRead( FileName=TmpFileName, /JPEG )

      endif

      ;=================================================================
      ; Create PNG output
      ;=================================================================
      if ( Do_PNG ) then begin

         ; Replace tokens in GIF file name w/ the frame number
         TmpFileName = GAMAP_GetFrameFileName( PNGFileName, Frame0 + N )

         ; Do the screen capture and write to JPEG file
         ThisFrame   = TvRead( FileName=TmpFileName, /PNG )

      endif

      ;=================================================================
      ; Create TIFF output
      ;=================================================================
      if ( Do_TIFF ) then begin

         ; Replace tokens in GIF file name w/ the frame number
         TmpFileName = GAMAP_GetFrameFileName( TIFFFileName, Frame0 + N )

         ; Do the screen capture and write to TIFF file
         ThisFrame   = TvRead( FileName=TmpFileName, /TIFF )

      endif

      ;=================================================================
      ; Create MPEG animation (only if there is more than one frame)
      ; NOTE: In IDL 6.0+ you need a separate license for MPEG.
      ;=================================================================
      if ( Do_MPEG ) then begin

         ; Open MPEG file on 1st frame
         if ( N eq 0 ) then begin
            mId = MPEG_Open( [!D.X_SIZE,!D.Y_SIZE], FileName=MPEGFileName )
         endif

         ; Store the image on the screen in a byte array
         ThisFrame = TvRead()

         ; Put this frame into the MPEG file
         MPEG_Put, mId, Frame=N, Image=ThisFrame, /Order

         ; Clear the byte array's memory
         UnDefine, ThisFrame
      endif

   endfor

   ; Close the MPEG file if necessary
   if ( DO_MPEG ) then begin
      MPEG_Save,  mId
      MPEG_Close, mId
   endif

   ;====================================================================
   ; Close the device, with timestamp, if needed.
   ;====================================================================
   if (not already_ps) then $
      Close_Device, TimeStamp=TimeStamp, _EXTRA=e

   ;====================================================================
   ; If we have just plotted a 0-D or 3-D data block, quit GAMAP.
   ;====================================================================
   if ( NDim eq 0 OR NDim eq 3 ) then return

   ;====================================================================
   ; If DO_PS has the *QUERY value, ask user whether to produce the
   ; same plot as postscript file. Otherwise quit
   ;====================================================================
   if (Do_PS lt 0 AND not already_ps) then begin
      Do_PS = yesno('Create postscript file?',default=0)
      if (Do_PS) then begin
         Do_GIF = 0
         Do_MPEG = 0
         goto,Do_The_Plot
      endif
   endif

   return
end

