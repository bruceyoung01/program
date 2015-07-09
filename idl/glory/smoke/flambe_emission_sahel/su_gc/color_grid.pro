
pro color_grid, rnp, rnl, rlat, rlon, var, geo,  maxvalue, minvalue, $
                  N_Levels , region, $
		  xa, dx, ddx, dddx, $
                  ya, dy, ddy, dddy, dirinx, extrachar, outtitle 
 
		  
barticks = minvalue + (findgen(N_levels+1))*(maxvalue-minvalue)/(n_levels)

;set colors
; r=bytarr(64) & g = r & b =r
; r(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
;           0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
;           230,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,$
;       255,255,255,255,255,255,255,255,255,255]

;      g(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
;           0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
;           251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
;           26,0,0,0,0,0,0,0,0,0]

;      b(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,36,$
;           72,109, 130, 150, 218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
;           0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]

colors = [ 0, -16,   -14,  -13,  -12, -11,  -10,  -9,  -8, -7,  -6,  -5, -4, -3, -2, -1]+16
;colors = [ 0, -16,   -13,  7,  12, 13,  17,  19,  21, 25,  32,  34, 36, 39, 42, 45]+16

ccolors = colors(1:n_levels+2)


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

       for i = 0, rnp - 2 do begin
         for j = 0, rnl - 2 do begin
        if(rlon(i,j) ge xl and rlon(i,j) le xr and $
	      rlat(i,j) ge yb and rlat(i,j) le yt  ) then begin   
	      color = colors(newtemp(i,j))

	      if (color eq 16 or color eq 17) then stop  
	    polyfill, [rlon(i,j), rlon(i+1,j), rlon(i+1,j), rlon(i,j), rlon(i,j)],$
	         [rlat(i,j), rlat(i,j), rlat(i,j+1), rlat(i,j+1), rlat(i,j)],$
		  color = colors(newtemp(i,j)), thick=3
                  ;color = colors(newtemp(i,j)), thick=3
	endif
         endfor
       endfor

; set legend
set_legend, minvalue, maxvalue, n_levels , ccolors, $
                xa, dx, ddx, dddx, $
                ya, dy, ddy, dddy, dirinx, extrachar

end	
	

