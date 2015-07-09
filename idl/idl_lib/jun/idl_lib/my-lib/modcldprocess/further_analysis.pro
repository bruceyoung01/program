
;
; Further analysis
;

SENSOR = 'Aqua'
LatB = -10
LatT = 60
LonL = -120
LonR = -50
GridSize=0.5
NLon = (LonR - LonL)/GridSize+1
NLat = (LatT - LatB)/GridSize+1

gcldreff =  fltarr(NLon, NLat)
gcldreffn =  fltarr(NLon, NLat)
gcldreffavg =  fltarr(NLon, NLat)

glat  =  fltarr(NLon, NLat)
gflon  =  fltarr(NLon, NLat)


;  output
openw, 1, 'Reff_AVG_' + SENSOR +'May8_14.dat'
readu, 1,  gcldreff, gcldreffn, gcldreffavg, gflat, gflon
close, 1




;set start at the end
set_plot,'ps'
device,filename=sensor + '.ps',/portrait,xsize=7.5, ysize=9,$
      xoffset=0.5,yoffset=1,/inches, /color, bits=8

      ;!p.multi = [0, 1, 2]
      load_clt, colors


;
; start to plot
;
title = 'Monthly Mean Cloud REFF'
; legend coordinate     
      xa = 0.125       &   ya = 0.9
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.015
      dddx = 0.05    &   dddy = -0.035
     dirinx = 0     &   extrachar='!4l!6m '

color_contour, gflat, gflon, gcldreffavg, -1.,  29, 5, $
             12,  [10, -115,   45 , -65],  $
	     xa, dx, ddx, dddx,  $
	     ya, dy, ddy, dddy, dirinx,$
	     extrachar, title

device, /close

end



