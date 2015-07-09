PRO plot_mod04_opt, tmpcldopt, maxcldopt,  mincldopt, flat, flon, np, nl, $
              region_limit, colors, xa, xb, ya, yb, dx, dy, ddx, ddy,$
	      titlename, $
              truecolor =truecolor, red=red, green=green, blue=blue, $
              nag = nag, china = china, fformat=fformat 
  
  ;  start mapping
        xl = region_limit(1)
        xr = region_limit(3)
        ybb = region_limit(0)
        ytt = region_limit(2)
        xcenter = 0

      ;  nag = 24 
      ;  nag = 24

      if (not keyword_set(nag)) then nag = 2 

  ; find tau max, min	
	result = where (tmpcldopt lt 0  , count)
	if ( count gt 0 ) then tmpcldopt(result) = 0.
        minresult = where ( tmpcldopt lt mincldopt and tmpcldopt gt 0 , mincount)
        maxresult = where ( tmpcldopt ge maxcldopt , maxcount)

  ; set up color levels
        N_levels = 45
        tmptau = 17 + (tmpcldopt - mincldopt)/(maxcldopt - mincldopt) * $
	             N_levels
         
	if (mincount gt 0 ) then tmptau(minresult)=16
	if (maxcount gt 0 ) then tmptau(maxresult) = 17+N_levels+1
        ; if it is clear sky 
	if ( count gt 0 ) then tmptau(result) = 8

        barticks = mincldopt + findgen(N_levels+1)*(maxcldopt-mincldopt)/(n_levels)

    
       BWINX = 16 
       if (keyword_set(truecolor)) then $
           BWINX = red(16) + 256L * (green(16) + 256L * blue(16))
        
      map_set,  /continent, $
       /grid, charsize=0.8, mlinethick = 4, color=BWINX,con_color=BWINX,$
       limit = region_limit,$
       /CYLINDRICAL,  position=[xa, ya, xb, yb],$
       /noerase, /usa, /noborder
   
        tmptau = congrid(tmptau,np*nag,nl*nag)
    	tmplat =  congrid(flat, np*nag, nl*nag, /interp )
    	tmplon =  congrid(flon, np*nag, nl*nag, /interp)


       if (keyword_set(truecolor)) then begin 
       color_imagemap,tmptau, tmplat, tmplon, /truecolor, red=red, $
              green=green, blue = blue, missing = 0, /current
       endif 	
       
       if (not keyword_set(truecolor)) then begin 
       color_imagemap,tmptau, tmplat, tmplon, $
              missing = 0, /current
       endif 	
       
      map_set, /continent, $
       /grid, charsize=0.8, mlinethick = 4, color=BWINX,con_color=BWINX,$
       limit = region_limit,$
       /CYLINDRICAL,  position=[xa, ya, xb, yb],$
       /noerase, /usa, /noborder
      
      if ( keyword_set(china)) then begin
       plot_china,  16, 16
      endif 

     plot, [xl, xr], [ybb, ytt], /nodata, xrange=[xl, xr], $
             yrange=[ybb, ytt], $
             position= [xa, ya, xb, yb], color=BWINX, xthick=1,$
             ythick=1, charthick=1, xstyle=1, ystyle=1,$
             xminor=1, yminor=1 

     xyouts, (xa+xb)/2, yb+0.03, titlename, /normal, color=BWINX,$
              align=0.5,charsize=1.0 

	;set table legend
        i = 0

;	x = [xb, xb+dx, xb+dx, xb, xb]+ddx
;	y = [yb, yb, yb+dy, yb+dy, yb]

        x =  [xb, xb, xb+dx, xb+dx, xb]+ddx
        y = [ yb, yb+dy, yb+dy, yb, yb]+ddy
        polyfill, x, y, color=colors(n_levels-i), /normal

        for i = 1, n_levels do begin
;           x = [xb, xb+dx, xb+dx, xb, xb]+ddx
;	   y = [yb, yb, yb+dy, yb+dy, yb]+i*dy
        x =  [xb, xb, xb+dx, xb+dx, xb]+ddx + i*dx
        y = [ yb, yb+dy, yb+dy, yb, yb]+ddy
	   polyfill, x, y, color=colors(n_levels-i+1), /normal
        endfor

        i = n_levels+1
;        x = [xb, xb+dx, xb+dx, xb, xb]+ddx
;	y = [yb, yb, yb+dy, yb+dy, yb]+i*dy
        
	x =  [xb, xb, xb+dx, xb+dx, xb]+ddx + i*dx
        y = [ yb, yb+dy, yb+dy, yb, yb]+ddy
        polyfill,  x, y, color=colors(n_levels-i+1), /normal

        for i = 0, n_levels, 9 do begin
	
;	if barticks(n_levels-i) ge 1.0 then begin 
;	 xyouts, xb+i*dx+ddx+dx, yb+dy+ddy,  '!6'+ strcompress(string(barticks(n_levels-i),$
;	 format='(I4)'), /REMOVE_ALL),  color=16,/normal, charsize=1.2,  charthick=1,$
;	 align=0.5
;	endif

;	if barticks(n_levels-i) lt 1.0 then begin 
	 xyouts, xb+i*dx+ddx+dx, yb+dy+ddy,  '!6'+ string(barticks(n_levels-i),$
	 format=fformat),  color=16,/normal, charsize=1.0,  charthick=1,$
	 align=0.5
;	endif
        endfor
end


pro load_clt, colors, truecolor= truecolor, red=red, green=green, blue=blue

r=bytarr(64) & g = r & b =r
 r(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
           230,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,$
       255,255,255,255,255,255,255,255,255,255]

      g(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
           251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
           26,0,0,0,0,0,0,0,0,0]

      b(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,36,$
           72,109,145,182,218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
           0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]

;colors = [ 0, 25,   36,  50,  65,  85,  115,  135,  160, 173,  180, 195, 210, 225]/5+16
if ( not keyword_set(truecolor) ) then begin 
colors = indgen(48) +16
tvlct, r, g, b
endif

if ( keyword_set(truecolor) ) then begin 
colors = indgen(48) +16
colors = r(colors) + 256L * ( g(colors) + 256L * b(colors))
red = r
green = g
blue = b
endif

end
