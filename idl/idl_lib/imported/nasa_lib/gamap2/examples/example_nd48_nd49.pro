; $Id: example_nd48_nd49.pro,v 1.2 2007/11/20 21:36:54 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EXAMPLE_ND48_ND49
;
; PURPOSE:
;        Creates several example plots to illustrate the use of GAMAP
;        timeseries routines GC_COMBINE_ND48 and GC_COMBINE_ND49.
;
; CATEGORY:
;        GAMAP Examples, GAMAP Utilities, Time Series
;
; CALLING SEQUENCE:
;        EXAMPLE_ND48_ND49 [, Keywords ]
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
;        =========================================
;        GC_COMBINE_ND48   GC_COMBINE_ND49
;        MULTIPANEL        PROGRAM_DIR (function)
;        SCREEN2PNG
;
; REQUIREMENTS:
;        Requires routines from the GAMAP package.
;
; NOTES:
;        None
;
; EXAMPLE:
;        EXAMPLE_ND48_ND49, /PNG
;             ; Create example plots and save to PNG file.
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
; or phs@io.as.harvard.edu with subject "IDL routine example_nd48_nd49"
;-----------------------------------------------------------------------


pro Example_ND48_ND49, PNG=PNG, _EXTRA=e

   ; Locate the directory with the timeseries data files
   DataDir = Program_Dir( 'combts_NOx.bpch' )

   ; Open the window
   Open_Device, WinParam=[ 0, 800, 600 ] 

   ; Print 4 plots per page
   MultiPanel, 4

   ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ; %%% 1st station timeseries %%%
   ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   ; Get the data from the ND48 stations into the TS data array
   gc_combine_nd48, indir=datadir, /verbose, /nosave,        $
                    station=1,     data=ts,  lon=lon,        $
                    lat=lat,       lev=lev,  time=time 
   
   ; Get the data from all ND49 stations into the TS2 data array
   gc_combine_nd49, indir=datadir, /verbose,    /nosave,     $
                    1,             'ij-avg-$',  lon=-68.3,   $
                    lat=40.2,      lev=1,       data=ts2,    $
                    outtime=time2, outlon=lon2, outlat=lat2 

   ; Display stuff
   help, ts2, lon2, lat2, time2
   help, ts, lon, lat, lev, time

   ; Print min & max
   print, min(ts2-ts, max=mx),mx

   ; Plot the ND48 station data, and overplot the ND49 data
   plot,  time, ts, /ynozero, title='Series 1'
   oplot, time2, ts2, line=2, thick=4


   ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ; %%% Comparing the 2nd station series            %%%
   ; %%% NOTE: 4 timeseries are return in both cases %%%
   ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   ; Get the data from the ND48 stations into the TS data array
   gc_combine_nd48, indir=datadir, /verbose, /nosave,        $
                    station=2,     data=ts,  lon=lon,        $
                    lat=lat,       lev=lev,  time=time

   ; Get the data from all ND49 stations into the TS2 data array
   gc_combine_nd49, indir=datadir,  /verbose,    /nosave,    $
                    44,             'ij-avg-$',  lon=-71.9,  $
                    lat=43.7,       lev=[1,4],   data=ts2,   $
                     outtime=time2, outlon=lon2, outlat=lat2

   ; Display info
   help, ts2, lon2, lat2, time2
   help, ts, lon, lat, lev, time

   ; print min & max
   print, min(ts2-ts, max=mx),mx

   ; Plot the data from 1st ND48 station; Overplot the ND49 station data
   plot, time, (reform(ts))[0,*], /ynozero, title='Series 2-a'
   oplot, time2, (reform(ts2))[0,*], line=2, thick=4

   ; Plot the data from 4th ND48 station; Overplot the ND49 station data
   plot, time, (reform(ts))[3,*], /ynozero, title='Series 2-d'
   oplot, time2, (reform(ts2))[3,*], line=2, thick=4

   ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ; %%% Comparing the 3rd station series %%%
   ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   ; Get the data from the ND48 stations into the TS data array
   gc_combine_nd48, indir=datadir, /verbose,    /nosave,    $ 
                    station=3,     data=ts,     lon=lon,    $
                    lat=lat,       lev=lev,     time=time

   ; Get the data from all ND49 stations into the TS2 data array
   gc_combine_nd49, indir=datadir, /verbose,    /nosave,    $
                    3,             'dao-3d-$',  lon=-62.7,  $
                    lat=51.2,      lev=1,       data=ts2,   $
                    outtime=time2, outlon=lon2, outlat=lat2
   
   ; Display info
   help, ts2, lon2, lat2, time2
   help, ts, lon, lat, lev, time
   
   ; Print min & max
   print, min(ts2-ts, max=mx),mx
   
   ; Plot ND48 station data; Overplot ND49 station data
   plot, time, ts, /ynozero, title='Series 3'
   oplot, time2, ts2, line=2, thick=4
   
   ; Save screen output to PNG format if necessary
   if ( Keyword_Set( PNG ) ) then Screen2Png, 'nd48_nd49'

   ; Cancel previous MULTIPANEL settings
   MultiPanel, /Off

end
