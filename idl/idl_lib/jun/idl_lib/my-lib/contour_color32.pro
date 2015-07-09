pro contour_color32, rlat, rlon, var, maxvalue, minvalue, $
                  N_Levels , region,  $
                  xa, dx, ddx, dddx, $
                  ya, dy, ddy, dddy, FORMAT, dirinx, extrachar, outtitle


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

;colors = [ 0, -16,   4,  7,  12, 13,  17,  19, 21, 25,  32,  34, 36, 39, 42, 45]+16
colors = findgen(35) + 20
colors(0) = 0
colors(1) = -16  
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

     NEWtemp = 2+(var - minvalue)/(maxvalue - minvalue) * N_levels
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
        xthick=3, $
        ythick=3, charsize=1.2, charthick=3, $
        title = outtitle +'!c!c!c'

map_set, 0, (xl+xr)/2, londel=360,latdel=180,   /cont, /noerase,  $
        lonalign=4,glinethick=1, color = 16, con_color=16, $
        ymargin=[0,1.5],   xmargin=[0,0], $
        limit=[yb, xl, yt, xr], mlinethick=2, $
        mlinestyle=0, /noborder, $
        position = [0.0775, 0.3075, 0.9035, 0.8725], /USA

map_continents, /countries, color = 16, /reivers, /coasts

; set legend
set_legend, minvalue, maxvalue, n_levels , ccolors, $
                xa, dx, ddx, dddx, $
                ya, dy, ddy, dddy, FORMAT, dirinx, extrachar

END
