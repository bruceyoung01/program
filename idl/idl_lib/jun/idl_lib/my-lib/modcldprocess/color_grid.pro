
pro color_grid, rnp, rnl, rlat, rlon, var, geo,  maxvalue, minvalue, $
                  N_Levels , region, $
		  xa, dx, ddx, dddx, $
                  ya, dy, ddy, dddy, dirinx, extrachar, outtitle 
 
		  
; titlename
;TimeName =  string(Day, format= '(I2)') + ' ' + monchar + $
;          ' ' + string(time,   format = '(I2)')+'00UTC'

;timechar = strcompress(string(time, format = '(I2)'), /remove_all)+':00 CST'
;daychar = strcompress(string(day, format = '(I2)'), /remove_all) 
;outtitle = 'Modeled  Smoke, ' + $
;           timechar + ', ' + daychar + ' '+ monchar + ' 2003'


;print, 'day = ', day, 'time = ', time, 'monchar = ', monchar

barticks = minvalue + (findgen(N_levels+1))*(maxvalue-minvalue)/(n_levels)

;set colors
 r=bytarr(64) & g = r & b =r
 r(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
           230,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,$
       255,255,255,255,255,255,255,255,255,255]

      g(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
           251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
           26,0,0,0,0,0,0,0,0,0]

     ; b(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,36,$
     ;      72,109,145,182,218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
     ;      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]
      
      b(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,36,$
           72,109, 130, 150, 218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
           0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]

colors = [ 0, -16,   4,  7,  12, 13,  17,  19,  21, 25,  32,  34, 36, 39, 42, 45]+16
;colors = [ 0,   4,   7,  12, 14, 17,  19, -16, -16, 25,  32,  34, 34, 36, 39, 42, 45]+16
;colors = [ 0,   4,   7,  12, 14, 17,  19, 21, 25,  32,  34, 34, 36, 39, 42, 45]+16

ccolors = colors(1:n_levels+2)
tvlct, r, g, b


; set regions
xl = region(1)
xr = region(3)
yb = region(0)
yt = region(2)


; processing values
     minresult = where ( var le minvalue, mincount)
     maxresult = where ( var gt maxvalue, maxcount)

     
     NEWtemp = 2+(var - minvalue)*1.0/(maxvalue - minvalue) * (N_levels-1)
     if (mincount gt 0 ) then newtemp(minresult)=1
     if (maxcount gt 0) then newtemp(maxresult) = N_levels+2


; contour plot
levels = findgen(n_levels+2)+1

    plot, [xl, xr], [yb, yt], $
        color=16, xtitle = '!6Longitude (deg) ', $
        ytitle='Latitude (deg) ', $ 
        position= [0.0775, 0.3075, 0.9035, 0.8725], $
        xthick=3,xticks = 5, xminor = 5,$ 
        ythick=3, charsize=1.2, charthick=3, $
        title = outtitle +'!c!c!c',  $
	xrange=[xl, xr], yrange=[yb, yt], xstyle=1, $
	ystyle=1, /nodata

; plot geopotential heights
;if ( min(geo) gt 0 ) then begin 

       for i = 0, rnp - 2 do begin
         for j = 0, rnl - 2 do begin
;	    polyfill, [rlon(i,j), rlon(i+1,j), rlon(i+1,j), rlon(i,j), rlon(i,j)],$
;	         [rlat(i,j), rlat(i,j), rlat(i,j+1), rlat(i,j+1), rlat(i,j)],$
;                  color = ccolors(3) 
        if(rlon(i,j) gt xl and rlon(i,j) lt xr and $
	      rlat(i,j) gt yb and rlat(i,j) lt yt  ) then begin    
	    polyfill, [rlon(i,j), rlon(i+1,j), rlon(i+1,j), rlon(i,j), rlon(i,j)],$
	         [rlat(i,j), rlat(i,j), rlat(i,j+1), rlat(i,j+1), rlat(i,j)],$
                  color = colors(newtemp(i,j)), thick=3
;            print, rlon(i,j), rlon(i+1,j), rlon(i+1,j), rlon(i,j),  rlon(i,j)		  
;	    xyouts, rlon(i,j), rlat(i,j), 'X', color=ccolors(newtemp(i,j)-1)
;	    print, 'color = ', ccolors(5)	  
	endif
	    
;                  ;color = ccolors(NEWtemp(i,j)-1)
         endfor
       endfor
;endif	
	;ytickformat="(A1)", $
        ;xtickformat="(A1)",$
        ;xthick=2, ythick=2, charthick=3,/normal, $
	;position = [0.1, 0.2, 0.9, 0.8]


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

; set legend
print, 'call setlenget' 
print, 'ccolors = ', ccolors 
set_legend, minvalue, maxvalue, n_levels , ccolors, $
                xa, dx, ddx, dddx, $
                ya, dy, ddy, dddy, dirinx, extrachar

;plot_daily_epa, day, time, monchar, region
;print, 'day = ', day, 'time = ', time, ' monchar = ', monchar

end	
	

