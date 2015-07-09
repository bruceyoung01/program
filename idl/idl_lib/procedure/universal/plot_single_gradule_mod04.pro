
;@load_clt
;@plot_cldopt
;@plot_opt
PRO plot_mod04_ref, tmpcldopt, maxcldopt,  mincldopt, flat, flon, np, nl, $
              region_limit, colors, xa, xb, ya, yb, dx, dy, ddx, ddy,$
	      titlename
  
  ;  start mapping
        xl = region_limit(1)
        xr = region_limit(3)
        ybb = region_limit(0)
        ytt = region_limit(2)
        xcenter = 0

        nag = 2 

  ; find tau max, min	
	result = where (tmpcldopt lt 0  , count)
	if ( count gt 0 ) then tmpcldopt(result) = 0.
        minresult = where ( tmpcldopt lt mincldopt and tmpcldopt gt 0 , mincount)
        maxresult = where ( tmpcldopt ge maxcldopt , maxcount)

  ; set up color levels
        N_levels = 46
        tmptau = 17 + (tmpcldopt - mincldopt)/(maxcldopt - mincldopt) * $
	             (N_levels-1)
         
	if (mincount gt 0 ) then tmptau(minresult)=16
	if (maxcount gt 0 ) then tmptau(maxresult) = 17+N_levels
        ; if it is clear sky 
	if ( count gt 0 ) then tmptau(result) = 16

        barticks = mincldopt + findgen(N_levels+1)*(maxcldopt-mincldopt)/(n_levels)

 
     plot, [xl, xr], [ybb, ytt], /nodata, xrange=[xl, xr], $
             yrange=[ybb, ytt], xtitle = '!6Longitude (deg) ', $
             ytitle='Latitude (deg) ', $
             position= [xa, ya, xb, yb], color=16, xthick=3,$
             ythick=3, charsize=1.0, charthick=3, xstyle=1, ystyle=1,$
             xticks=7, xminor=5
      
      xyouts, (xa+xb)/2, yb+0.03, titlename, /normal, color=16,$
              align=0.5 
      
      map_set, 0, xcenter,  /continents, $
       /grid, charsize=1, mlinethick = 4, color=16,con_color=16,$
       /mer, limit = region_limit,$
       /CYLINDRICAL,  position=[xa, ya, xb, yb],$
       /noerase, /noborder

    ;  plot_china, 16, 16
   
    ;  stop
    ; congrid
    ;   tmptmptau = congrid(tmptau,np,nl)
    ;   tmplat =  congrid(flat, np, nl, /interp )
    ;   tmplon =  congrid(flon, np, nl, /interp)
        tmptau = congrid(tmptau,np*nag,nl*nag)
    	tmplat =  congrid(flat, np*nag, nl*nag, /interp )
    	tmplon =  congrid(flon, np*nag, nl*nag, /interp)


       color_imagemap,tmptau, tmplat, tmplon,missing = 0, /current
	
      map_set, 0, xcenter,  /continents, $
       /grid, charsize=1, mlinethick = 4, color=16,con_color=16,$
       /mer, limit = region_limit,$
        /CYLINDRICAL,  position=[xa, ya, xb, yb],$
       /noerase, /noborder
       ;plot_china, 16, 16

; 
       oplot, [xl, xr], [ybb, ybb], thick=5, color=15
       oplot, [xl, xr], [ytt, ytt], thick=5, color=15
       oplot, [xl, xl], [ytt, ytt], thick=5, color=15
       oplot, [xr, xr], [ybb, ybb], thick=5, color=15


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
        polyfill, y, x, color=colors(n_levels-i+1), /normal

        for i = 0, n_levels, 9 do begin
;	 xyouts, xb+dx+ddx, yb+i*dy,  '!6'+string(barticks(n_levels-i),$
;	 format='(f6.2)'),  color=16,/normal, charsize=1.5,  charthick=5
;         xyouts, xb+dx+ddx, yb+i*dy, '!6-', charsize=1, /normal, $
;	 color=16, charthick=5
	
	if barticks(n_levels-i) ge 1.0 then begin 
	 xyouts, xb+i*dx+ddx+dx, yb+dy+ddy,  '!6'+ strcompress(string(barticks(n_levels-i),$
	 format='(f3.1)'), /REMOVE_ALL),  color=16,/normal, charsize=1.0,  charthick=3,$
	 align=0.5
	endif

	if barticks(n_levels-i) lt 1.0 then begin 
	 xyouts, xb+i*dx+ddx+dx, yb+dy+ddy,  '!6'+ string(barticks(n_levels-i),$
	 format='(f5.2)'),  color=16,/normal, charsize=1.0,  charthick=3,$
	 align=0.5
	endif

    endfor

;         xyouts, xb+dx+ddx, yb+i*dy, '!6-', charsize=1, /normal, $
;	 color=16, charthick=5

       ; loat hail data
    if (strmatch (titlename, '*Radius*129*' )) then begin 
       openr, 1, '/data/jun/Hail_data/May9.txt' 
       location = fltarr(4, 163)
       readf, 1, location
       close, 1
       
       for i = 0, 162 do begin
        plotsym, 0, location(3)*2.54/2.54/500., /fill
        scolor = 16
        plots, location(1, i), location(0, i), psym=8, color=0, /data 
       endfor 
     
     ;  plotsym, 0, 1.0, /fill
     ;  plots, -91, 25, psym = 8, color=scolor
     ;  xyouts,  -91, 20, '2.54 cm', color=scolor, /data, align=0.5
       xyouts, xb-3*dx, yb+dy+ddy, '!4l!6m', charsize=1.0,  $
            charthick=3, align=0.5, color = 16, /normal   
     
   endif 
end


pro load_clt, colors

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
colors = indgen(48) +16
tvlct, r, g, b
end
