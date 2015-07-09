; $Id: ctm_plotdiff.pro,v 1.9 2008/04/22 20:40:10 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_PLOTDIFF
;
; PURPOSE:
;        Prints a lat-lon map of 2 CTM fields, their absolute difference, 
;        and their percent difference.  This is a quick way of ensuring 
;        that two model versions are producing identical results.
;
;        The page will contain the following plot panels:
;
;             Panel #1               Panel #2
;             Data Block D1          Data Block D2
;
;             Panel #3               Panel #4
;             Abs Diff (D2 - D1)     % Diff (D2 - D1)
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Plotting
;
; CALLING SEQUENCE:
;        CTM_PLOTDIFF, DIAGN, FILE1, FILE2 [, Keywords ]
;
; INPUTS:
;        DIAGN -> A diagnostic number or category to restrict
;             the record selection (default is: "IJ-AVG-$"). 
;
;        FILE1 -> Name of the first CTM output file.  If FILE1
;             is not given, or if it contains wildcard characters
;             (e.g. "*"), then the user will be prompted to supply
;             a file name via a pickfile dialog box.
;
;        FILE2 ->  Name of the second CTM output file.  If FILE2
;             is not given, or if it contains wildcard characters
;             (e.g. "*"), then the user will be prompted to supply
;             a file name via a pickfile dialog box.
;
; KEYWORD PARAMETERS:
;        LON -> A 2-element vector specifying the longitude range that
;             will be used to make the plot.  Default is [-180,180].
;
;        LAT -> A 2-element vector specifying the latitude range that
;             will be used to make the plot.  Default is [-88,88].
;
;        LEV -> A scalar or 2-element vector which specifies the
;             level(s) that will be used to make the plot.  Default
;             is [ 1, 1 ].
;
;        /PS -> Set this switch to print to a PostScript file.
; 
;        OUTFILENAME -> Name of the PostScript file if the /PS option 
;             is set.  Default is "idl.ps".
;
;        TRACER -> Tracer number(s) for which differences will be plotted.  
;
;        TAU0 -> TAU value(s) (hours since 0 GMT 1 Jan 1985) at the start
;             of the diagnostic data block to plot.
;
;        DIVISIONS -> Specifies the number of colorbar divisions for 
;             the quantity plot (Panels #1 and #2).  Default is 5.
;             NOTE: The optimal # of divisions is !MYCT.NCOLORS/2 +1.
;
;        YRANGE -> Allows you to manually specify the min and max
;             values of the data that will appear on the plot (Panels
;             # 1 and #2).  The default is to automatically compute
;             the overall min and max of both data blocks.
;
;        MIN_VALID -> Specifies the minimum valid data for the plot. 
;             Data lower than MIN_VALID will be rendered with color
;             !MYCT.WHITE.  For example, MIN_VALID is useful for
;             plotting emissions which only occur on land.
;
;        DIFFDIV -> Specifies the number of colorbar divisions for 
;             the difference plots (Panels #3 and #4).  Default is 8.
;             NOTE: The optimal # of divisions is !MYCT.NCOLORS/2 +1.
;
;        DIFFNCOLORS -> Sets the # of colors used to create the
;             difference plots (Panels #3 and #4).  Default is 13.
;
;        DIFFRANGE -> Allows you to manually specify the min and max
;             values that will appear on the absolute difference
;             plot (Panel #3).  Default is to use the dynamic range of
;             the absolute difference data (symmetric around zero).
;
;        PCRANGE -> Allows you to manually specify the min and max
;             values that will appear on the percentage difference
;             plot (Panel #4).  Default is to use the dynamic range of
;             the percentage difference data (symmetric around zero).
;
;        _EXTRA=e -> Picks up extra keywords for CTM_DIFF and OPEN_DEVICE.
;
; OUTPUTS:
;        none
;
; SUBROUTINES:
;        External Subroutines Required:
;        =======================================================
;        CHKSTRU     (function)    CLOSE_DEVICE 
;        CTM_CLEANUP               COLORBAR_NDIV     (function)
;        CTM_DIFF                  CTM_GET_DATABLOCK (function) 
;        IS_DEFINED   (function)   EXTRACT_FILENAME  (function) 
;        MULTIPANEL                OPEN_DEVICE
;        
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) CTM_PLOTDIFF calls CTM_CLEANUP each time to remove
;            previously read datablock info from the GAMAP common
;            block.
;
;        (2) The default TAU0 value is 0, and is not suitable if your 
;            run has no output for 0 GMT 1 Jan 1985! You may have to 
;            gather tau0 before running and crashing CTM_PLOTDIFF.
;
; EXAMPLE:
;        FILE1 = 'ctm.bpch.v4-30'
;        FILE2 = 'ctm.bpch.v4-31'
;        CTM_PLOTDIFF, 'IJ-AVG-$', FILE1, FILE2, TRACER=1
;
;             ; Creates 4-panel plot w/ old data, new data,
;             ; new - old (abs diff), and new - old (% diff).
;
; MODIFICATION HISTORY:
;        bmy, 17 Apr 2002: GAMAP VERSION 1.50
;        bmy, 17 Jul 2002: GAMAP VERSION 1.51
;                          - added TAU0 keyword
;        bmy, 16 Dec 2002: GAMAP VERSION 1.52
;                          - now can handle 2 different tracer numbers
;                          - now can handle 2 different TAU0 values
;        bmy, 29 Jan 2004: GAMAP VERSION 2.01
;                          - Now pass LEV keyword to CTM_DIFF
;                          - Now plot both DATA1 and DATA2 on
;                            the same scale for easier comparison
;        bmy, 16 Feb 2005: GAMAP VERSION 2.03
;                          - Now use /QUIET and /NOPRINT keywords in
;                            CTM_GET_DATA and CTM_GET_DATABLOCK to
;                            suppress screen output
;        phs, 24 Oct 2006: GAMAP VERSION 2.05
;                          - Now use YRANGE if it is passed.  
;                          - Also use DIFFRANGE (for range of the 
;                            abs difference plot) if it is passed.
;                          - Now use PCRANGE (for range of the
;                            %age difference plot) if it is passed.
;        bmy, 15 Nov 2006: GAMAP VERSION 2.06
;                          - Now use blue-white-red color table
;                            for abs diff and % diff plots
;  bmy & phs, 04 Oct 2007: GAMAP VERSION 2.10
;                          - Added DIVISIONS keyword (default=5) 
;                          - Now make the default DIFFRANGE and
;                            PCRANGE symmetric around zero
;                          - Added DIFFDIV, DIFFNCOLORS keywords
;                          - Also restore original !MYCT structure
;                          - restore initial Color Table and !MyCt,
;                            and return, when crashes.
;                          - Now skip plotting % difference if
;                            DATA1 is zero everywhere
;                          - Add error trapping with CATCH
;        bmy, 16 Jan 2008: GAMAP VERSION 2.12
;                          - add _EXTRA=e to calls to CTM_PLOT, in order
;                            to pass extra variables to that routine
;        phs, 31 Jan 2008: - Add NODEVICE keyword, so device (like PS
;                            file) can be open outside this routine,
;                            allowing for multiple pages in a PS file
;                            for example.
;                          - Clipping of percentage difference range
;                            is indicated with triangle.
;        phs, 25 Feb 2008: - Improved error catcher
;
;-
; Copyright (C) 2002-2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_plotdiff"
;-----------------------------------------------------------------------


pro CTM_PlotDiff, DiagN, File1, File2,                        $
                  Tracer=Tracer,     Lev=Lev,                 $
                  Lon=Lon,           Lat=Lat,                 $
                  PS=PS,             OutFileName=OutFileName, $
                  Tau0=Tau0,         Min_Valid=Min_Valid,     $
                  YRange=YRange,     DiffRange=DiffRange,     $
                  PCRange=PCRange,   Divisions=Divisions,     $
                  DiffDiv=DiffDiv,   DiffNColors=DiffNColors, $
                  NoDevice=NoDevice, _EXTRA=e      

   ;====================================================================
   ; Error handling
   ;====================================================================

   ; Trap the error
   Catch, TheError

   ; If it's a true error, print err msg and quit
   if ( TheError ne 0 ) then begin
      help, /last_message, output=traceback
      print, traceback
      goto, Quit
   endif

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION ChkStru, CTM_Get_DataBlock, Extract_FileName, Is_Defined

   ; Arguments -- must be passed
   if ( N_Elements( DiagN ) ne 1 ) then Message, 'DIAGN not passed!'
   if ( N_Elements( File1 ) ne 1 ) then Message, 'FILE1 not passed!'
   if ( N_Elements( File2 ) ne 1 ) then Message, 'FILE2 not passed!'

   ; Set keyword defaults
   PS  = Keyword_Set( PS ) 
   Dev = 1L - Keyword_Set( NoDevice )
   if ( N_Elements( Lon         ) eq 0 ) then Lon         = [ -180, 180 ]  
   if ( N_Elements( Lat         ) eq 0 ) then Lat         = [  -86,  86 ]
   if ( N_Elements( OutFileName ) ne 1 ) then OutFileName = 'idl.ps'
   if ( N_Elements( Divisions   ) ne 1 ) $
      then Divisions = ColorBar_NDiv( MaxDiv=6 )

   ; Be able to handle 2 different levels (bmy, 1/29/04)
   case ( N_Elements( Lev ) ) of
      0    : LLev = [ 1, 1 ]
      1    : LLev = [ Lev, Lev ]
      2    : LLev = Lev
      else : Message, 'Invalid number of elements for LEV!'
   endcase

   ; Be able to handle two different tracer numbers
   case ( N_Elements( Tracer ) ) of 
      0    : TTracer = [1, 1]
      1    : TTracer = [ Tracer, Tracer ]
      2    : TTracer = Tracer
      else : Message, 'Invalid number of elements for TRACER!'
   endcase

   ; Be able to handle two different times
   case ( N_Elements( Tau0 ) ) of 
      0    : TTau0 = [ 0d0,  0d0  ]
      1    : TTau0 = [ Tau0, Tau0 ]
      2    : TTau0 = Tau0
      else : Message, 'Invalid number of elements for TAU0!'
   endcase
  
   ; Store original color table
   TvLct, R_Orig, G_Orig, B_Orig, /Get

   ; Store original !MYCT structure (phs, 8/16/07)
   MyCt_Orig = !MYCT

   ;====================================================================
   ; Put both data blocks on the same range
   ;====================================================================

   ; First data block
   Success = CTM_Get_DataBlock( Data1,          DiagN,             $
                                FileName=File1, Tracer=TTracer[0], $
                                Lon=Lon,        Lat=Lat,           $
                                Lev=LLev[0],    Tau0=TTau0[0],     $
                                /Quiet,         /NoPrint )

   ; Error check
   if ( not Success ) then Message, 'Could not read DATA1!'

   ; Second data block
   Success = CTM_Get_DataBlock( Data2,          DiagN,             $
                                FileName=File2, Tracer=TTracer[1], $
                                Lon=Lon,        Lat=Lat,           $
                                Lev=LLev[1],    Tau0=TTau0[1],     $
                                /Quiet,         /NoPrint )

   ; Error check
   if ( not Success ) then Message, 'Could not read DATA1!'

   ; Get min and max of both data blocks
   Min1    = Min( Data1, Max=Max1 )
   Min2    = Min( Data2, Max=Max2 )
   MinData = Min( [ Min1, Min2 ]  ) 
   MaxData = Max( [ Max1, Max2 ]  )
   
   ; If YRANGE isn't passed, use the min & max of the data (phs, 10/24/06)
   if ( N_Elements( YRange ) eq 0 ) then YRange = [ MinData, MaxData ]
   
   ;====================================================================
   ; Initialize the plot
   ;====================================================================

   ; 4 plot panels
   MultiPanel, 4

   ; Open window
   if ( Dev ) $
      then Open_Device, /Color, Bits=8, PS=PS, FileName=OutFileName, _EXTRA=e 

   ;====================================================================
   ; Panel 1: 1st file
   ;====================================================================

   ; Clean up all files
   CTM_CleanUp

   ; Plot title
   Title = '%MODEL%: ' + Extract_Filename( File1 ) + $
      '!C!C%TRACERNAME% %DATE% %LEV% (%ALT%)'

   ; 1st data block
   CTM_Plot, DiagN,                                                $
      FileName=File1,      /Sample,           /CBar,               $
      Divisions=Divisions, /Grid,             /Countries,          $
      /Coasts,             Tracer=TTracer[0], Lon=Lon,             $
      Lat=Lat,             Lev=LLev[0],       Title=Title,         $
      Tau0=TTau0[0],       YRange=YRange,     Min_Valid=Min_Valid, $
      /Quiet,              /NoPrint,          _EXTRA=e

   ;====================================================================
   ; Panel 2: 2nd file
   ;====================================================================

   ; Plot title
   Title = '%MODEL%: ' + Extract_Filename( File2 ) + $
         '!C!C%TRACERNAME% %DATE% %LEV% (%ALT%)'
 
   ; 2nd plot
   CTM_Plot, DiagN,                                                $
      FileName=File2,      /Sample,           /CBar,               $
      Divisions=Divisions, /Grid,             /Countries,          $
      /Coasts,             Tracer=TTracer[1], Lon=Lon,             $
      Lat=Lat,             Lev=LLev[1],       Title=Title,         $
      Tau0=TTau0[1],       YRange=YRange,     Min_Valid=Min_Valid, $
      /Quiet,              /NoPrint,          _EXTRA=e
 
   ;====================================================================
   ; Call CTM_DIFF -- compute abs & percent diff ( File2 - File1 )
   ;====================================================================

   ; Abs diff
   CTM_Diff, DiagN, Tracer=TTracer, File=[ File1, File2 ], $
      Tau0=TTau0, Lev=LLev[0], /Quiet, Range=DR, _EXTRA=e

   ; % diff
   CTM_Diff, DiagN, Tracer=TTracer, File=[ File1, File2 ], $
      Tau0=TTau0, Lev=LLev[1], /Quiet, Range=PR, /Percent, _EXTRA=e

   ;====================================================================
   ; Load the colortable for the difference plots
   ;====================================================================

   ; Default # of colors to use for difference plots
   if ( N_Elements( DiffNColors ) eq 0 ) then DiffNColors = 12

   ; Use difference colortable w/ doubled midrange color for even DiffNColors
   MyCt, /BuWhWhRd, NColors=DiffNColors
   
   ; Default # of colortable divisions 
   if ( N_Elements( DiffDiv ) eq 0 ) $
      then DiffDiv = ColorBar_NDiv( DiffNColors, MaxDiv=6 )

   ;====================================================================
   ; Absolute difference
   ;====================================================================

   ; If DIFFRANGE is not set, then compute default values
   if ( N_Elements( DiffRange ) eq 0 ) then begin

      ; Min and max from the abs diff plot
      Min1 = Min( DR, Max=Max1 )

      ; Make the range symmetric around zero
      if ( Abs( Min1 ) gt Abs( Max1 ) )                  $
         then DiffRange = [ -Abs( Min1 ), Abs( Min1 ) ]  $
         else DiffRange = [ -Abs( Max1 ), Abs( Max1 ) ]
   endif

   ; Abs diff plot title
   Title = Extract_Filename( File2 ) + ' - ' + $
           Extract_Filename( File1 ) + '!C!CAbsolute Difference'
 
   ; Abs diff plot
   CTM_Plot, DiagN,                                           $
      Ilun=-1,           /Sample,           /CBar,            $
      Divisions=DiffDiv, /Grid,             /Countries,       $
      /Coasts,           Tracer=TTracer[0], Lon=Lon,          $
      Lat=Lat,           Lev=LLev[0],       Title=Title,      $
      /Quiet,            /NoPrint,          YRange=DiffRange, $
     _EXTRA=e
 
   ;====================================================================
   ; % difference
   ;====================================================================

   ; Check if PR is defined in order to prevent the
   ; "DATA1 is undefined everywhere" error (phs, 10/4/07)
   if ( not Is_Defined( PR ) ) then goto, Quit

   ; Min and max from the % diff plot
   Min2 = Min( PR, Max=Max2 )

   ; If PCRANGE is not set, then compute default min/max values
   if ( N_Elements( PCRange ) eq 0 ) then begin

      ; Make the range symmetric around zero
      if ( Abs( Min2 ) gt Abs( Max2 ) )                $
         then PCRange = [ -Abs( Min2 ), Abs( Min2 ) ]  $
         else PCRange = [ -Abs( Max2 ), Abs( Max2 ) ]

   endif else begin

      ; use triangle to indicate clipping of data range
      if ( Min2 lt PCRange[0] or Max2 gt PCRange[1] ) then begin

         triangle = 1

         ; colored triangles indicate that data range is clipped 
         if ( Min2 lt PCRange[0] ) then BotOfRan = !MYCT.BOTTOM
         if ( Max2 le PCRange[1] ) then TopOfRan = 0

      endif

   endelse


   ; Title for the plot
   Title = Extract_Filename( File2 ) + ' - ' + $
           Extract_Filename( File1 ) + '!C!CPercent Difference'
 
   ; % difference
   CTM_Plot, DiagN,                                            $
      Ilun=-2,             /Sample,           /CBar,           $
      Divisions=DiffDiv,   /Grid,             /Countries,      $
      /Coasts,             Tracer=TTracer[0], Lon=Lon,         $
      Lat=Lat,             Lev=LLev[1],       Title=Title,     $
      /Quiet,              /NoPrint,          YRange=PCRange,  $
      Triangle=Triangle,   BotOut=BotOfRan,   TopOut=TopOfRan, $
      _EXTRA=e
 
   ;====================================================================
   ; Close the device & quit
   ;====================================================================
Quit:

   ; Close the device
   if ( N_Elements( Dev ) ne 0 ) then $
      if ( Dev ) then Close_Device
 
   ; Restore original color table
   if ( N_Elements( R_Orig ) ne 0 ) then TvLct, R_Orig, G_Orig, B_Orig

   ; Restore original !MYCT system variables
   if ( ChkStru( MyCT_Orig ) ) then !MYCT = MYCT_Orig 

   ; Turn off multipanel
   Multipanel, /Off

   ; Check error state
   If ( TheError ) then Catch, /Cancel

   return
end
 
 
