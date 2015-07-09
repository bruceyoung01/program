
pro velo, np, nl, rlat, rlon, uvar, vvar,  $
                  region, position, title 
 
		  
; set regions
xl = region(1)
xr = region(3)
yb = region(0)
yt = region(2)

WSpL = 3.      ; wind speed per unit lengh in the plot



plot, [0, 1], [0, 1], /nodata, $
      xrange=[xl, xr], yrange=[yb, yt], $
        color=16, xtitle = '!6Longitude (deg) ', $
        ytitle='Latitude (deg) ', $ 
        position= position, $
        xthick=3,xticks = 5, xminor = 5,$ 
        ythick=3, charsize=1.2, charthick=3, $
        title = title +'!c!c!c', xstyle=1, ystyle=1 

  for i = 0, np-1, 2 do begin
   for j = 0, nl-1, 2 do begin
       u = uvar(i,j)
       v = vvar(i,j)
       x0 = rlon(i,j)
       y0 = rlat(i,j)
      
      if ( x0 gt xl+1 and x0 lt xr-1 and  y0 gt yb+1 and y0 lt yt-1) then begin
;       if (u^2 + v^2 gt 0.1) then begin 
       arrow, x0, y0, x0+u/wspl, y0+v/wspl, hsize=300., /data, color=16,  thick=3
       print, 'u ', u, '  v ', v, ' u/v', u/v
;       plots, [x0, y0], [x0+u*5, y0+v*5], /data, color=16, thick=3
;       endif
      endif   
 endfor
 endfor

 xa = xl + (xr-xl)*0.15 
 dx = 2. 
 arrow, xa, 41., xa+dx, 41, thick=3, hsize = 300, /data, color = 16
 xyouts, xa+dx+0.5, 41, strcompress(string(dx*wspl, format='(I2)'), /remove_all)  + $
        'ms!u-1', /data, color=16
 

map_set, 0, (xl+xr)/2, londel=360,latdel=5,   /cont, /usa, /noerase,  $
        lonalign=4,glinethick=1, color = 16, con_color=16, $
        ymargin=[0,1.5],   xmargin=[0,0], $
        limit=[yb, xl, yt, xr], mlinethick=2, $
        mlinestyle=0, $ 
	position = [0.0775, 0.3075, 0.9035, 0.8725],/noborder

for kkk = 0, 4 do begin
plots, [-75-kkk*10, -75-kkk*10], [10, 45], linestyle=1, color=16,$
               thick=1
endfor

end	
	

