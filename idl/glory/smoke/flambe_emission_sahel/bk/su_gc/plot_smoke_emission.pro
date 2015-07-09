; read smoke monthly emission

;set_plot, 'ps'
;device, filename = 'monthly_temp_diff.ps', xsize=7, ysize=10, $
;	xoffset=0.5, yoffset=0.5, /inches,/color
;!p.thick=3
;!p.charthick=3
;!p.charsize=1.2

pro plot_smoke_emission

; legend coordinate
      xa = 0.125       &   ya = 0.22
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.015
      dddx = 0.05    &   dddy = -0.035
      dirinx = 0     &   extrachar='!uo!nC '


dir = '/home/gecui/wrf/wj/plot_src/'
gnh = 24   ; 24 hours
fnp = 86 
fnl = 91
CompEmission = fltarr(fnp, fnl) 
FlambeLat = fltarr(fnp, fnl) 
FlambeLon = fltarr(fnp, fnl) 
FireNum = fltarr(fnp, fnl, gnh)
sumfirenum = fltarr(fnp, fnl)


openr, 1, dir + 'Flambe_Emission.dat'
readu, 1, CompEmission
close,1

openr, 1, dir + 'Flambe_lat.dat'
readu, 1, FlambeLat 
close,1

openr, 1, dir + 'Flambe_lon.dat'
readu, 1, FlambeLon 
close,1

openr, 1, dir + 'FIRE_Num.dat'
readu, 1, firenum
close,1

for i = 0, fnp-1 do begin
for j = 0, fnl-1 do begin
 for k = 0, gnh-1 do begin
    sumfirenum(i,j) = firenum(i,j,k) + sumfirenum(i,j)   
 endfor
endfor
endfor

; plot fire emissions
title = 'Composite Fire Emission (September -October, 2006)'
ymax = 30.0
tmp = CompEmission
extrachar = '   Gg'
result = where(CompEmission ge 0, count)
;print, 'total emission = ', total(tmp)/1.0e6
;if (count gt 0 ) then tmp(result) = (tmp(result))/1.0e6

print, 'total emission = ', total(tmp)/1.0e9
if (count gt 0 ) then tmp(result) = (tmp(result))/1.0e9

ymin = 0.0
color_grid, fnp, fnl, FlambeLat, FlambeLon, tmp, tmpgeo, ymax, ymin, $
	     12,  [-35, 70,   55 , 155],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx, extrachar, title 
;print,'tmp',tmp(90,90)

  xa = 0.125       &   ya = 0.22
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.015
      dddx = 0.05    &   dddy = -0.035
      dirinx = 0     &   extrachar='!uo!nC '
   

;device,/close
end



