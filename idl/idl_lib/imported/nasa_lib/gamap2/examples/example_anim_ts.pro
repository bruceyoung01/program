; $Id: example_anim_ts.pro,v 1.1 2007/11/20 20:15:41 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EXAMPLE_ANIM_TS
;
; PURPOSE:
;        Illustrates how to use XINTERANIMATE with GAMAP 
;        timeseries routine GC_COMBINE_ND49.
;
; CATEGORY:
;        GAMAP Examples, GAMAP Utilities
;
; CALLING SEQUENCE:
;        EXAMPLE_ANIM_TS [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================================
;        GC_COMBINE_ND49         MULTIPANEL
;        MYCT                    PROGRAM_DIR (function)
;        TAU2YYMMDD (function)   TVMAP
;
; REQUIREMENTS:
;        Requires routines from the GAMAP package.
;
; NOTES:
;        None
;
; EXAMPLE:
;        EXAMPLE_ANIM_TS
;             ; Creates sample animation from timeseries data.
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
; or phs@io.as.harvard.edu with subject "IDL routine example_anim_ts"
;-----------------------------------------------------------------------


pro Example_Anim_TS

   ; Reference external functions
   ;
   FORWARD_FUNCTION Tau2YYMMDD


   ; Locate the directory with the timeseries data files
   ;
   DataDir = Program_Dir( 'combts_NOx.bpch' )


   ; Save original color table
   ;
   TvLct, R, G, B, /Get


   ; Load MYCT White-Green-Yellow-Red colortable w/ 12 colors
   ;
   MyCt, /WhGrYlRd, NColors=12


   ; Read data from timeseries files and return in the TS array
   ;
   GC_Combine_ND49, 2,           'ij-avg-$',  indir=datadir, $
                    /nosave,      /verbose,   data=ts,       $
                    outtime=time, outlon=lon, outlat=lat

   ; DIM is the number of timeseries "frames"
   ;
   Dim     = Size( ts, /Dim )


   ; Limit the animation to 100 frames and 12 colors  
   ;
   NFrames = Dim[3] < 100


   ; Call XINTERANIMATE to initialize the animation
   ;
   XInterAnimate, Set=[ 480, 320, NFrames ], /ShowLoad


   ; Select surface data, and get min and max value
   ;
   SData   = Reform( Ts[*,*,0,*] )
   MinData = Min( SData, Max=MaxData )


   ; Create the lon & lat limit vector for the map
   ;
   Limit = [ min(lat)-2., min(lon)-2.5, max(lat)+2., max(lon)+2.5 ]


   ; Load each animation frame into XINTERANIMATE
   ;
   for I = 0L, NFrames-1L do begin

      ; Title string
      Title = 'Surface Ozone ' + StrDate( Tau2YYMMDD( Time[I] ) ) 

      ; Plot the surface data
      TvMap, SData[*,*,i], Lon, Lat,                             $
         /Cbar,       Title=Title,   Limit=Limit,  /Grid,        $
         /Continents, /Hires,        Div=7,        Min=MinData,  $
         Max=MaxData, CbMin=MinData, CbMax=MaxData

      ; Screengrab the window and place into XINTERANIMATE
      XINTERANIMATE, FRAME=i, window=!d.window

   endfor

   ; Show the animation!
   ; 
   XInterAnimate, /Keep_PixMaps


   ; Restore original color table
   ;
   TvLct, R, G, B

end
