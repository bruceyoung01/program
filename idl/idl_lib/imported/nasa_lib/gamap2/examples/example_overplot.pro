; $Id: example_overplot.pro,v 1.1.1.1 2007/07/17 20:41:37 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EXAMPLE_OVERPLOT
;
; PURPOSE:
;        Example program for overlay of data with model results.
;        This program is meant to provide a demonstration example
;        rather than a ready-to-use program, so please copy it
;        and adapt it to your needs.
;          For a try, just call EXAMPLE_OVERPLOT with no options.
;        Before you rewrite this code, try some of the keyword 
;        options to get a feel how it works.
;
; CATEGORY:
;        GAMAP Examples, GAMAP Utilities
;
; CALLING SEQUENCE:
;        EXAMPLE_OVERPLOT [,DATA [,ALTITUDE]] [,keywords]
;
; INPUTS:
;        DATA -> A vector with your vertical profile data. If nothing
;           is supplied, a dummy ozone profile is generated.
;
;        ALTITUDE -> Altitude vector correspondign to your data. If not
;           supplied, a vector will be created ranging from 0-12 km.
;
; KEYWORD PARAMETERS:
;        Keywords to select certain model results:
;        DIAGN -> Name (or number) of a diagnostic. Default is 'IJ-AVG-$'
;
;        TRACER -> A tracer number (default is 2 = 'Ox')
;
;        TAU0 -> A time step value. You can specify a date using the
;             NYMD2TAU function.
;
;        Keywords to select the geographical domain:
;        LONRANGE, LATRANGE -> 2-element vectors specifying the minimum
;             and maximum longitude and latitude for the model results
;             to be considered. Not that LONRANGE[1] < LONRANGE[0] is 
;             possible, denoting a region across the Pacific.
;
;        Keywords to change the appearance of the plot:
;        TITLE -> Give your plot a title. Default is 'EXAMPLE PLOT'
;             with longitude and latitude rang and date.
;             If you are sure that you select only one data record each
;             time, you can leave it up to CTM_PLOT to construct a title
;             (simply remove the TITLE keyword in the call to CTM_PLOT).
;             Note that you can take advantage of various "variables"
;             with the '%NAME%' notation (see GAMAP documentation for
;             details).
;
;        _EXTRA -> Look at the documentation of CTM_PLOT and add your
;             favorite keywords to the call to EXAMPLE_OVERPLOT. You are
;             likely to use XRANGE or XSTYLE. 
;
; OUTPUTS:
;        just a plot ;-)
;
; SUBROUTINES:
;        none
;
; REQUIREMENTS:
;        uses ctm_get_dat and ctm_plot as well as everything that is
;        needed by these to.
;
; NOTES:
;
; EXAMPLE:
;        EXAMPLE_OVERPLOT
;
;        data = your_fancy_reading_routine(filename)
;        EXAMPLE_OVERPLOT,data,tau0=nymd2tau(940601L)
;
; MODIFICATION HISTORY:
;        mgs, 21 May 1999: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine example_overplot"
;-----------------------------------------------------------------------


pro example_overplot,data,altitude,diagn=diagn,tracer=tracer,tau0=tau0, $
           lonrange=lonrange,latrange=latrange,title=title,  $
           ps=ps,_EXTRA=e
 
 
   ; Set defaults:
   ; if nothing is specified we create a dummy ozone profile and 
   ; plot it
   if (n_elements(data) eq 0) then begin
       data = [ 20., 30., 35., 40., 42., 50., 90. ]
       demo = 1
   endif else $
       demo = 0
 
   if (n_elements(altitude) eq 0) then $
       altitude = findgen(n_elements(data))/(n_elements(data)-1)*12.
 
   if (n_elements(diagn) ne 1) then $
       diagn='IJ-AVG-$'
 
   if (n_elements(tracer) ne 1) then $
       tracer = 2
; print,'## TRACER=',tracer
 
   if (n_elements(lonrange) ne 2) then $
      lonrange = [ -180, 180 ]
 
   if (n_elements(latrange) ne 2) then $
      latrange = [30,40]
 
   ; optional set-up for multipanel plotting 
   ; and postscript plotting
   ; (better to do it outside this routine though)
   ; multipanel,rows=2,cols=3
   ; open_device,ps=ps,/landscape,/color
 
 
   ; retrieve data (model) records that match selection
   ctm_get_data,datainfo,diagn,tracer=tracer,tau0=tau0, _EXTRA=e
 
   ctm_print_datainfo,datainfo

   ; construct plot title 
   if (n_elements(title) ne 1) then begin
      title = 'EXAMPLE PLOT ('
      if (n_elements(datainfo) eq 1) then $
         title = title+'%DATE%,'
      title = title+' %LON%, %LAT%)'
   endif
 
 
   ; produce plot with first record found
   ctm_plot,diagn,use_datainfo=datainfo[0],  $
       tracer=datainfo[0].tracer,tau0=datainfo[0].tau0, $
       lev=[1,14],lon=lonrange,lat=latrange,  $
       color=1, average=3, title=title,  _EXTRA=e
 
 ; ctm_plot,diagn,tracer=71,tau0=tau0,  $
 ;     lev=[1,14],lon=lonrange,lat=latrange,  $
 ;     color=1, average=3, unit='pptv',  $
 ;     ytitle='Altitude [km]',xtitle='CH!L3!NI [pptv]', $
 ;     xrange=[0.,1.5]
 
 
   ; overlay all other model records
   for i=1,n_elements(datainfo)-1 do begin
      ctm_plot,diagn,use_datainfo=datainfo[i],  $
          tracer=datainfo[i].tracer,tau0=datainfo[i].tau0, $
          lev=[1,14],lon=lonrange,lat=latrange,  $
          color=(i mod 15), average=3, /OVERPLOT
   endfor
 
 
   ; if demo rescale data to fit to model results
   if (demo) then $
      data = data/100. * (!X.crange[1]-!X.crange[0]) + !X.crange[0]
 
   ; overplot the "real" data
   oplot,data,altitude,psym=-sym(1),color=1,thick=2
 
 
   ; Don't forget to close these if you used them !
   ; close_device
   ; multipanel,/off
 
   return
end
 
