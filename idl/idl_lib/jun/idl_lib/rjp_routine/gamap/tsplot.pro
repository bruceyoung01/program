; $Id: tsplot.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        TSPLOT
;
; PURPOSE:
;        Create a plot of station data time series using the
;        data structure as returned from TSDIAG.PRO. This routine
;        is a simple outline for how to use this structure and 
;        not meant to produce publisheable plots. Tip: use
;        MULTIPANEL.PRO to save paper.
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        TSPLOT, TSSTRU, INDEX, SCALE=SCALE
;
; INPUTS:
;        TSSTRU -> The data structure as returned from TSDIAG.PRO
;
;        INDEX -> A vector with station indices that are to be plotted.
;            If no index is given, the program will loop through all 
;            records.
;
; KEYWORD PARAMETERS:
;        SCALE -> A scaling factor to be applied to the dat abefore plotting.
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        ; read station data
;        tsdiag,tsstru,file='ctm.ts'
;        ; set page for 16 panels
;        multipanel,16
;        ; plot data from all stations as pptv
;        tsplot,tsstru,scale=1.e12
;        ; turn multipanel off
;        multipanel,/OFF
;
; MODIFICATION HISTORY:
;        mgs, 30 Jun 1999: VERSION 1.00
;
;-
; Copyright (C) 1999, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine tsplot"
;-------------------------------------------------------------


pro tsplot,tsstru,index,scale=scale
 
 
    if (not ChkStru(tsstru,['LON','LAT','TRACER','TIME','DATA'])) then begin
       message,'Need a result structure from TSDIAG as input!',/Continue
       return
    endif
 
    ; set default scale
    if (n_elements(scale) ne 1) then $
       scale = 1.
 
 
    ; get number of stations
    nstations = n_elements(tsstru.tracer)
 
    ; prepare default index array
    if (n_elements(index) eq 0) then $
       index = lindgen(nstations)
 
 
    ; loop through index array and plot respective station
    for i=0L,n_elements(index)-1 do begin
 
       if (index[i] ge nstations) then begin
          message,'Invalid index '+strtrim(index[i],2)+'! Skip...',/Continue
       endif else begin
          plot,tsstru.time,tsstru.data[*,index[i]]*SCALE,  $
             color=1
          cx = total(!x.window)/2.
          cy = !y.window[1]-0.03
          xyouts,cx,cy,string([tsstru.lon[index[i]],tsstru.lat[index[i]], $
                               tsstru.alt[index[i]],tsstru.tracer[index[i]] ], $
                               format='(4i4)'),/NORM,color=1, $
                 align=0.5,charsize=0.8
 
       endelse
 
    endfor
 
    return
end
 
 
    
