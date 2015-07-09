
pro color_contour_uneven, rlat, rlon, var, geo,  maxvalue, minvalue, $
                  intervals,  N_Levels , region, $
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
     minresult = where ( var lt minvalue, mincount)
     maxresult = where ( var gt maxvalue, maxcount)
     newtemp = var * 0
     barticks = intervals
     for i = 0, n_elements(barticks)-2 do begin
       result = where(var ge barticks(i) and $
                      var lt barticks(i+1), count)   
       if ( count gt 0 ) then newtemp(result) = 2+i + $
        (var(result)-barticks(i))/(barticks(i+1)-barticks(i))
     endfor  
     
     if (mincount gt 0 ) then newtemp(minresult)=1
     if (maxcount gt 0) then newtemp(maxresult) = N_levels+2


; contour plot
levels = findgen(n_levels+2)+1


contour, NEWtemp,   rlon, $
        rlat, /irregular, nlevels=N_levels+2,  $
        xrange=[xl, xr], yrange=[yb, yt],  /fill, $
        levels=levels,$
        c_colors=ccolors,xstyle=1, ystyle=1,$
        color=16, xtitle = '!6Longitude (deg) ', $
        ytitle='Latitude (deg) ', $ 
        position= [0.0775, 0.3075, 0.9035, 0.8725], $
        xthick=3,xticks = 5, xminor = 5,$ 
        ythick=3, charsize=1.2, charthick=3, $
        title = outtitle +'!c!c!c' 
	

; plot geopotential heights
if ( min(geo) gt 0 ) then begin 
contour, geo/10., rlon, rlat, c_labels = (fltarr(20)+1), /irregular,$
         position = pos, levels = [296,  298, 300, 302, 304, 306, 308, 310, 312,  314,  $
	          316,  318, 320, 322, 324, 326 ], c_charthick=2, $
         c_thick=2, c_charsize=1.2, C_color=fltarr(20)+63, $
	 c_annotation = ['296', '298', '300', '302', '304', '306', '310', '312', '314',  '316', $
	                 '318',  '320', '322', '324', '326'],   /overplot

endif	
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
set_legend_uneven, barticks, n_levels , ccolors, $
                xa, dx, ddx, dddx, $
                ya, dy, ddy, dddy, dirinx, extrachar

;plot_daily_epa, day, time, monchar, region
;print, 'day = ', day, 'time = ', time, ' monchar = ', monchar

end	
	

