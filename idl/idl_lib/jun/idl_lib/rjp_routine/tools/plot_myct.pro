; $Id: plot_myct.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        PLOT_MYCT
;
; PURPOSE:
;        plot a color bar containing the first 16 colors of MYCT
;
; CATEGORY:
;        color handling
;
; CALLING SEQUENCE:
;        PLOT_MYCT [,/PS]
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;        PS --> produce a file named colortable.ps that can be cutted and
;             pasted onto your monitor
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        procdure MYCT should be performed first
;
; NOTES:
;        not very elegant but fulfills its purpose
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 03 Aug 1997: VERSION 1.00
;
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine plot_myct"
;-------------------------------------------------------------


pro plot_myct,ps=ps
 
 
if(keyword_set(ps)) then begin
   olddev = !d.name
   set_plot,'ps'
   device,/color,bits=8,/portrait,/inch,ysize=6,filename='colortable.ps'
endif
 
x=findgen(10)*0.1
y=x*0.
 
!p.position=[0.1,0.1,0.15,0.8]
 
!x.style=4
!y.style=1
!y.range=[0.,16.]
!y.ticks=8
plot,x,y,color=1
for i=1,15 do begin
  y=y+1.
  oplot,x,y,color=i,thick=40
end
 
 
if(keyword_set(ps)) then begin
   device,/close
   set_plot,olddev
endif
 
end
 
