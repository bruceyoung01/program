; $Id: example_polar.pro,v 1.2 2008/03/24 13:52:18 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EXAMPLE_POLAR
;
; PURPOSE:
;        Quick and dirty examples of polar plots made with CTM_PLOT.
;
; CATEGORY:
;        GAMAP Examples, GAMAP Utilities
;
; CALLING SEQUENCE:
;        EXAMPLE_POLAR
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        /PS -> Set this switch to write output to a PostScript file.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================
;        MYCT     CTM_PLOT   MULTIPANEL
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        none
;
; EXAMPLE:
;        EXAMPLE_POLAR, /PS
;             ; Create polar plots and save to PostScript file.
;
; MODIFICATION HISTORY:
;        mgs, 20 Aug 1998: INITIAL VERSION
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - now uses FILE_WHICH to find ctm.bpch.examples
;                          - rewritten for clarity
;        bmy, 14 Mar 2008: GAMAP VERSION 2.12
;                          - Bug fix: save output from FILE_WHICH to
;                            FILE (instead of FILENAME)
;                                
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
; or phs@io.as.harvard.edu with subject "IDL routine example_polar"
;-----------------------------------------------------------------------


pro Example_Polar, PS=PS, _EXTRA=e
 
   ; Save original colortable
   TvLct, R, G, B, /Get

   ; Keywords
   PS = Keyword_Set( PS )
 
   ; Use PostScript or X-window device
   if ( PS )                                             $
      then Open_Device, /PS, /Color, Bits=8, /LandScape  $
      else Open_Device, WinParam=[ 0, 900, 600 ]

   ; Set font for PostScript output
   if ( PS ) then XYoutS, 0, 0,'!6', /norm

   ; File name to open.  We will use the FILE_WHICH routine in IDL
   ; to first look in the current directory, and failing that, in
   ; all of the other directories specified in the !PATH variable.
   ;
   ; The EXPAND_PATH function will expand the path from a relative
   ; to an absolute path name (e.g. from ~/IDL/gamap2/data_files to
   ; /users/ctm/bmy/IDL/gamap2/data_files).
   ; 
   File = File_Which( 'ctm.bpch.examples', /Include_Current_Dir )
   File = Expand_Path( File )

   ; Turn off multi-panel plots
   Multipanel, /Off

   ;---------------------------
   ; 1st plot: surface
   ;---------------------------

   ; Load modified spectral colortable
   MyCt, /ModSpec

   ; Ox tracer at surface (L=1)
   CTM_Plot, 'IJ-AVG-$', $    ; Select diagnostic category
      FileName=File,     $    ; Select file name
      Tracer=2,          $    ; Select Ox tracer
      /Polar,            $    ; Select polar plot type
      /Isotropic,        $    ; Make lat & lon the same scale on the map
      Lon=[-180,180],    $    ; Select longitudes (must be -180..180)
      Lat=[0,90],        $    ; Select latitude range
      Lev=1,             $    ; Select level
      /FContour               ; Select filled contours
      
   ; Pause to allow user to look at plot
   Pause
   
   ;---------------------------
   ; 2nd plot: 500 hPa
   ;---------------------------

   ; Load one of the custom colortables from MYCT
   MyCt, /BuYlRd

   ; Ox tracer at 500 HPa (L=8)
   CTM_Plot, 'IJ-AVG-$', $    ; Select diagnostic category
      FileName=File,     $    ; Select file name
      Tracer=2,          $    ; Select Ox tracer
      /Polar,            $    ; Select polar plot type
      /Isotropic,        $    ; Make lat & lon the same scale on the map
      Lon=[-180,180],    $    ; Select longitudes (must be -180..180)
      Lat=[45,90],       $    ; Select latitude range
      Lev=8,             $    ; Select level
      /FContour,         $    ; Select filled contours
      Skip=2                  ; Skip every other colorbar label

   ; Pause to allow user to look at plot
   Pause

   ;---------------------------
   ; 3rd plot: 300hPa arctic
   ;---------------------------

   ; Load one of the custom colortables from MYCT
   MyCt, /WhRd

   ; OX tracer at 300 HPa (L=11)
   CTM_Plot, 'IJ-AVG-$', $    ; Select diagnostic category 
      FileName=File,     $    ; Select file name
      Tracer=2,          $    ; Select Ox tracer
      /Polar,            $    ; Select polar plot type
      /Isotropic,        $    ; Make lat & lon the same scale on the map
      Lon=[-180,180],    $    ; Select longitudes (must be -180..180)
      Lat=[60,90],       $    ; Select latitude range
      Lev=11,            $    ; Select level
      /FContour,         $    ; Select filled contours
      /C_Lines,          $    ; Also plot black contour lines for contrast
      /NoLabels               ; Suppress the line labels

   ; Pause to allow user to look at plot
   Pause

   ;---------------------------
   ; 4th plot: antarctic sfc
   ;---------------------------

   ; Load one of the custom colortables from MYCT
   MyCt, /BuYlRd

   ; Ox tracer at sfc (L=1)
   CTM_Plot, 'IJ-AVG-$', $    ; Select diagnostic category 
      FileName=File,     $    ; Select file name    
      Tracer=2,          $    ; Select Ox tracer   
      /Polar,            $    ; Select polar plot type    
      /Isotropic,        $    ; Make lat & lon the same scale on the map    
      Lon=[-180,180],    $    ; Select longitudes (must be -180..180)    
      Lat=[-90,-45],     $    ; Select latitude range
      Lev=1,             $    ; Select level
      /FContour,         $    ; Select filled contours
      /C_Lines,          $    ; Also plot black contour lines for contrast
      /NoLabels               ; Suppress the line labels

   ;---------------------------
   ; Cleanup & quit
   ;---------------------------

    ; close device and turn multipanel environment off
   Close_Device
   MultiPanel, /Off

   ; Restore original color table
   TvLct, R, G, B

   return
end
 
 
