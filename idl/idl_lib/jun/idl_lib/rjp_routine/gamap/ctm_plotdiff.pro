; $Id: ctm_plotdiff.pro,v 1.4 2005/03/24 18:03:11 bmy Exp $
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
; CATEGORY:
;        CTM Tools
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
;        TRACER -> Tracer number(s) for which differences will be plotted.  
;
;        TAU0 -> TAU value(s) (hours since 0 GMT 1 Jan 1985) at the start
;             of the diagnostic data block to plot.
;
;        _EXTRA=e -> Picks up extra keywords for CTM_DIFF.
;
; OUTPUTS:
;        none
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==========================================
;        CTM_CLEANUP   CTM_GET_DATABLOCK (function)
;        CTM_DIFF      MULTIPANEL    
;        OPEN_DEVICE   CLOSE_DEVICE
;
; REQUIREMENTS:
;        References routines from both the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) CTM_PLOTDIFF calls CTM_CLEANUP each time to remove
;            previously read datablock info from the GAMAP common
;            block.
;
; EXAMPLE:
;        FILE1 = 'ctm.bpch.v4-30'
;        FILE2 = 'ctm.bpch.v4-31'
;        CTM_PLOTDIFF, 'IJ-AVG-$', $
;             FILE1=FILE1, FILE2=FILE2, TRACER=1
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
;
;-
; Copyright (C) 2002-2005, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_plotdiff"
;-----------------------------------------------------------------------


pro CTM_PlotDiff, DiagN, File1, File2,                     $
                  Tracer=Tracer,  Lev=Lev,                 $
                  Lon=Lon,        Lat=Lat,                 $
                  PS=PS,          OutFileName=OutFileName, $
                  Tau0=Tau0,      Min_Valid=Min_Valid,     $
                  YRange=YRange,  _EXTRA=e      
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Get_DataBlock, Extract_FileName

   ; Arguments -- must be passed
   if ( N_Elements( DiagN ) ne 1 ) then Message, 'DIAGN not passed!'
   if ( N_Elements( File1 ) ne 1 ) then Message, 'FILE1 not passed!'
   if ( N_Elements( File2 ) ne 1 ) then Message, 'FILE2 not passed!'

   ; Set keyword defaults
   PS = Keyword_Set( PS ) 
   if ( N_Elements( Lon         ) eq 0 ) then Lon         = [ -180, 180 ]  
   if ( N_Elements( Lat         ) eq 0 ) then Lat         = [  -86,  86 ]
   if ( N_Elements( OutFileName ) ne 1 ) then OutFileName = 'idl.ps'

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

   ; Be able to handle two different tracer numbers
   case ( N_Elements( Tau0 ) ) of 
      0    : TTau0 = [ 0d0,  0d0  ]
      1    : TTau0 = [ Tau0, Tau0 ]
      2    : TTau0 = Tau0
      else : Message, 'Invalid number of elements for TRACER!'
   endcase
  
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
   
   ; Save into YRANGE keyword
   YRange = [ MinData, MaxData ]
   
   ;====================================================================
   ; Initialize the plot
   ;====================================================================
   MultiPanel, 4
   Open_Device, /Color, Bits=8, PS=PS, OutFileName=OutFileName, _EXTRA=e
 
   ;====================================================================
   ; Panel 1: 1st file
   ;====================================================================

   ; Clean up all files
   CTM_CleanUp

   Title = '%MODEL%: ' + Extract_Filename( File1 ) + $
      '!C!C%TRACERNAME% %DATE% %LEV% (%ALT%)'

   CTM_Plot, DiagN,                                                         $
      FileName=File1, /Sample, /CBar, Div=3, /Grid, /Countries, /Coasts,    $
      tracer=TTracer[0], Lon=Lon, Lat=Lat, Lev=LLev[0], Title=Title,        $
      Tau0=TTau0[0], YRange=YRange, Min_Valid=Min_Valid,                    $
      /Quiet, /NoPrint

   ;====================================================================
   ; Panel 2: 2nd file
   ;====================================================================
   Title = '%MODEL%: ' + Extract_Filename( File2 ) + $
         '!C!C%TRACERNAME% %DATE% %LEV% (%ALT%)'
 
   CTM_Plot, DiagN,                                                         $
      FileName=File2, /Sample, /CBar, Div=3, /Grid, /Countries, /Coasts,    $
      tracer=TTracer[1], Lon=Lon, Lat=Lat, Lev=LLev[1], Title=Title,        $
      Tau0=TTau0[1], YRange=YRange, Min_Valid=Min_Valid,                    $
      /Quiet, /NoPrint
 
   ;====================================================================
   ; Call CTM_DIFF -- compute abs & percent diff ( File2 - File1 )
   ;====================================================================
   CTM_Diff, DiagN, Tracer=TTracer, File=[ File1, File2 ], $
      Tau0=TTau0, Lev=LLev[0], /Quiet, _EXTRA=e

   CTM_Diff, DiagN, Tracer=TTracer, File=[ File1, File2 ], $
      Tau0=TTau0, Lev=LLev[1], /Quiet, /Percent, _EXTRA=e
 
   ;====================================================================
   ; Absolute difference
   ;====================================================================
   Title = Extract_Filename( File2 ) + ' - ' + $
           Extract_Filename( File1 ) + '!C!CAbsolute Difference'
 
   CTM_Plot, DiagN, $
      Ilun=-1, /Sample, /CBar, Div=3, /Grid, /Countries, /Coasts,    $
      tracer=TTracer[0], Lon=Lon, Lat=Lat, Lev=LLev[0], Title=Title, $
      /Quiet, /NoPrint
 
   ;====================================================================
   ; % difference
   ;====================================================================
   Title = Extract_Filename( File2 ) + ' - ' + $
           Extract_Filename( File1 ) + '!C!CPercent Difference'
 
   CTM_Plot, DiagN, $
      Ilun=-2, /Sample, /CBar, Div=5, /Grid, /Countries, /Coasts,    $
      tracer=TTracer[0], Lon=Lon, Lat=Lat, Lev=LLev[1], Title=Title, $
      /Quiet, /NoPrint  ;, YRange=[-100, 100], Min_Valid=-100
 
   ;====================================================================
   ; Close the device & quit
   ;====================================================================
Quit:
   Close_Device
 
   return
end
 
 
