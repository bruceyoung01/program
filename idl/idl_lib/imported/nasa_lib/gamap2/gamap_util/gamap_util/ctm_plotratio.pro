; $Id: ctm_plotratio.pro,v 1.1.1.1 2007/07/17 20:41:27 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_PLOTRATIO
;
; PURPOSE:
;        Plots the ratio of two CTM data fields.  This is one way
;        to see if two model versions produce identical results.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Plotting
;
; CALLING SEQUENCE:
;        CTM_PLOTRATIO, DIAGN [, Keywords ]
;
; INPUTS:
;        DIAGN -> A diagnostic number or category to restrict
;             the record selection.  Default is "IJ-AVG-$". 
;
; KEYWORD PARAMETERS:
;        FILE1 -> Name of the first CTM output file (containing the
;             "old" data).  If FILE1 is not given, or if it contains 
;             wildcard characters (e.g. "*"), then the user will be 
;             prompted to supply a file name via a pickfile dialog box.
;
;        FILE2 ->  Name of the second CTM output file.  If FILE2
;             is not given, or if it contains wildcard characters
;             (e.g. "*"), then the user will be prompted to supply
;             a file name via a pickfile dialog box.
;
;        LON -> A 2-element vector specifying the longitude range that
;             will be used to make the plot.  Default is [-180,180].
;
;        LAT -> A 2-element vector specifying the latitude range that
;             will be used to make the plot.  Default is [-88,88].
;
;        LEV -> Vertical level for which to plot data.  Default is 1.
;
;        TITLE -> Title string for the plot.  If not specified, a
;             generic title string will be generated.
;
;        TRACER -> Number of the tracer for which differences
;             will be plotted.  Default is 1.
;
;        _EXTRA=e -> Picks up extra keywords for CTM_DIFF.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==========================================
;        CTM_CLEANUP   CTM_GET_DATABLOCK (function)
;        CTM_DIFF      EXTRACT_FILENAME  (function)
;        OPEN_DEVICE   CLOSE_DEVICE
;        MULTIPANEL
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) The ratio plotted will be DATA2 / DATA1, where DATA2
;            is contained in FILE2, and DATA1 is contained in FILE1.
;
;        (2) For places where DATA1 = 0, DATA2 will also be set to 0.
;            This avoids division by zero errors.
;
;        (3) CTM_PLOTRATIO calls CTM_CLEANUP each time to remove
;            previously read datablock info from the GAMAP common
;            block.
;
; EXAMPLE:
;        FILE1 = 'ctm.bpch.v4-30'
;        FILE2 = 'ctm.bpch.v4-31'
;        CTM_PLOTRATIO, 'IJ-AVG-$', $
;             FILE1=FILE1, FILE2=FILE2, TRACER=1, LEV=1
;
;             ; Plots the ratio of NOx data at the surface:
;             ;   ctm.bpch.v4-31 / ctm.bpch.v4-30
;
; MODIFICATION HISTORY:
;        bmy, 24 Apr 2002: GAMAP VERSION 1.50
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.harvard.edu with subject "IDL routine ctm_plotratio"
;-----------------------------------------------------------------------


pro CTM_PlotRatio, DiagN,                              $
                   File1=File1,   File2=File2,         $
                   Lon=Lon,       Lat=Lat,             $
                   Lev=Lev,       Tracer=Tracer,       $
                   Title=Title,   _EXTRA=e
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Get_DataBlock, Extract_FileName

   if ( N_Elements( DiagN  ) eq 0 ) then DiagN  = 'IJ-AVG-$'
   if ( N_Elements( Lon    ) eq 0 ) then Lon    = [ -180, 180 ]  
   if ( N_Elements( Lat    ) eq 0 ) then Lat    = [  -88,  88 ]
   if ( N_Elements( Lev    ) eq 0 ) then Lev    = 1
   if ( N_Elements( Tracer ) ne 1 ) then Tracer = 1

   ;====================================================================
   ; Read data from both files
   ;====================================================================

   ; Delete previously read data in the IDL common blocks
   CTM_CleanUp

   ; Read first file
   Success = CTM_Get_DataBlock( Data1, DiagN,           $
                                XMid=XXMid, YMid=YYMid, $
                                FileName=File1,         $
                                Tracer=Tracer,          $
                                Lon=Lon,                $
                                Lat=Lat,                $
                                Lev=Lev )

   ; Error check
   if ( not Success ) then begin
      Message, 'DATA1 not found!', /Continue
      return
   endif

   ; Read second file
   Success = CTM_Get_DataBlock( Data2, DiagN,   $
                                FileName=File2, $
                                Tracer=Tracer,  $
                                Lon=Lon,        $
                                Lat=Lat,        $
                                Lev=Lev )

   ; Error check
   if ( not Success ) then begin
      Message, 'DATA2 not found!', /Continue
      return
   endif

   ; Size of DATA1, DATA2
   SD1 = Size( Data1, /Dim )
   SD2 = Size( Data2, /Dim )

   ; Make sure data arrays are compatible 
   if ( N_Elements( SD1 ) ne 2 ) then Message, 'DATA1 must be 2-D!'
   if ( N_Elements( SD2 ) ne 2 ) then Message, 'DATA2 must be 2-D'
   if ( SD1[0] ne SD2[0]       ) then Message, 'X-dimensions incompatible!'
   if ( SD1[1] ne SD2[1]       ) then Message, 'Y-dimensions incompatible!'
   
   ;====================================================================
   ; Plot ratio data
   ;====================================================================

   ; Create Ratio array for this level
   Ratio = FltArr( SD1[0], SD1[1] )  

   ; IND0 = the zero elements of DATA1
   Ind0 = where( Data1 eq 0.0 )

   ; IND1 = the nonzero elements of DATA1
   Ind1 = where( Data1 ne 0.0 )

   ; If all points of DATA1 are zero, then stop, 
   ; since we cannot compute ratios.
   if ( Ind1[0] lt 0 ) then Message, 'DATA1 contains all zeroes!'

   ; Where DATA1 = 0, also set DATA2 = 0, so that we 
   if ( Ind0[0] ge 0 ) then Data2[Ind0] = 0e0
   
   ; Compute ratio data: avoid divide-by-zero
   Ratio[Ind1] = Data2[Ind1] / Data1[Ind1]
 
   ; Define title string if one isn't passed
   if ( N_Elements( Title ) ne 1 ) then begin
      Title = StrTrim( Extract_FileName( File2 ), 2 ) + '/'     + $
              StrTrim( Extract_FileName( File1 ), 2 ) + ', L=' + $
              StrTrim( String( Lev ), 2 ) 
   endif

   ; Plot the map
   TvMap, Ratio, XXMid, YYMid, $
      /Sample, /Countries, /Coasts, /Grid, /Iso, $
      /CBar, Div=4, Title=Title, _EXTRA=e

   ; Quit
   return
end
 
 
