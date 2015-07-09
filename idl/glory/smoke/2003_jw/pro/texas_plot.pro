;
; Purpose: this code will plot the contour of the PM over the texas
;           regions 
;

; read PM data over different stations.
  pro  read_pm, filelist, day, time, monchar, $
           flat, flon,  data, dailyavg  
   
   nouse = ' '
   stationidchar = ' '
   datadir = '/s1/data/wangjun/s4/Proj/texis_aqi/pmdat/2003_processed/'
   np = 31
   maxnl = 90
   maxsta = 200
   oneline = fltarr(np)
   onemonth = fltarr(np, maxnl)
   tmpdata = fltarr(maxsta)
   tmplat = fltarr(maxsta)
   tmplon = fltarr(maxsta)
    
   

   k = 0    ;index of how many stations in the data  
   
   ; read the data station by station
     
     ; open filelist
       openr, 1, filelist
       readf, 1, nouse
       while (not eof(1) ) do begin
          readf, 1, stationidchar

	  ; get the filename corresponding to id and month
	    stationfile = datadir + monchar + '_'+stationidchar + '.dat.asc'
          
	  ; read data
	    openr, 2, stationfile
	    readf, 2, nouse
	    readf, 2, stateid, countyid, stanum, camsid, lat, lon, height, regionbox
            readf, 2, nouse
	    readf, 2, nouse
	    nl = 0
	    while  not eof(2) do begin
	      readf, 2, oneline
	      onemonth(0:np-1, nl) = oneline(0:np-1)
	      nl = nl + 1
	    endwhile
          
	  ; assign the corresponding value based on day and time
	     i = 0 
	     while ( onemonth(0, i) ne  day and i lt nl ) do begin
	       i = i + 1
	     endwhile 
             
	     if ( (i eq 0 and onemonth(0, i) eq  day) or i gt 0 ) $
	            then begin
	     
	       tmpdata(k) = onemonth(1+time, i)
	       tmplat(k) = lat
	       tmplon(k) = lon
	       k = k  + 1
	     endif 

	   close,2
       endwhile   
       close,1

    ; return values
      result = where(tmpdata lt 999 and tmpdata gt 0)
      data = tmpdata(result)
      flat = tmplat(result)
      flon = tmplon(result)
    END


; plot each stations
  pro plot_stations, inx
   
   np = 4
   nl = 61 
   stadata = fltarr(np, nl) 
   openr, 1, '/s1/data/wangjun/s4/Proj/texis_aqi/pmdat/site_location.dat'
   nouse = ' '
   readf, 1, nouse
   readf, 1, stadata
   close,1
    
   xyouts, stadata(2, inx), stadata(1, inx), $
     strcompress(string(stadata(0, inx)),/remove_all), /data, color = 0 
  
  end

pro cal_aqicate, pm, pmcolors
  pmstd = [ 0, 15.5, 40.5, 65.5, 150.5, 250.5]
  aqicolors = [1, 2, 3, 4, 5, 6]
  nl = n_elements(pm)
  pmcolors = fltarr(nl)
  for i = 0, nl-1 do begin  
    j = 0
    while ( pm(i) gt pmstd(j) and j le 5) do begin
     j = j +1
    endwhile
    pmcolors(i) = aqicolors(j-1)
  endfor  
end   

;
;set legend
  pro set_legend, xa, dx, ya, dy
  
   AQIcategory = ['Good', 'Moderate', 'Unhealthy!c Sens. Group', $
                  'Unhealthy', 'Very!cUnhealty', 'Hazardous']  
   for i = 0, 5 do begin
    plots, xa, ya-i*dy, color=i+1, psym=sym(1, 1), symsize=1.5, /normal
    xyouts, xa, ya-i*dy-dy/3, AQIcategory(i), color=0, charthick=3, /normal, align=0.5
   endfor
  end 

Pro Add_texas_Boundary

; Purpose: To add the TEXAS boundary to the plot.

bnd = FltArr(2,1085)

OpenR, 3, '~/idl_lib/US/TX_state.ovl'
ReadF, 3, lon, lat
i = 0
WHILE lon NE 909.9 DO BEGIN
   bnd[0,i] = lon
   bnd[1,i] = lat
   ReadF, 3, lon, lat
   i = i + 1
ENDWHILE
Close, 3
numpts = i
;PolyFill, bnd[0,0:numpts-1], bnd[1,0:numpts-1], Color=12  
PlotS, bnd[0,0:numpts-1], bnd[1,0:numpts-1], Color=6, $
      Thick=4
END ; Add_TEXAS_Boundary


Pro Add_County_Boundaries, index

; Purpose: To addd the boundaries of texas counties so that the
;          relative location Jefferson County will be more apparent in
;          the map plot.

bnd = FltArr(2,3133)

OpenR, 4, '~/idl_lib/US/TX_counties.ovl'
ReadF, 4, lon, lat
conum = 0
WHILE lon NE 999.9  DO BEGIN
   i = 0
   WHILE lon NE 909.9 DO BEGIN
     bnd[0,i] = lon
     bnd[1,i] = lat
     ReadF, 4, lon, lat
      i = i + 1
   ENDWHILE
   numpts = i
   conum = conum + 1
   IF conum EQ 24 THEN BEGIN
     if index eq 0 then begin
;      PolyFill, bnd[0,0:numpts-1], bnd[1,0:numpts-1], Color=module2
     endif else begin
;      PolyFill, bnd[0,0:numpts-1], bnd[1,0:numpts-1], Color=12
     endelse 
   ENDIF
   Plots, bnd[0,0:numpts-1], bnd[1,0:numpts-1], Color=14, $
      Thick=2
   ReadF, 4, lon, lat
ENDWHILE
Close, 4
print, 'county #  is', conum

END ; Add_County_Boundaries

;----------------------------------------------------------------------
Pro Load_Color_Table


red   = intarr(15)
green = intarr(15)
blue  = intarr(15)
;         0    1   2     3     4    5   6    7   8    9    10   11   12    13   14
;red   = [0,  255, 0,   200,   0,   0, 145,  10, 20, 175, 100, 170,  255, 200, 255]
;green = [0,    0, 220,   0, 240,   0, 90,  150, 150, 10,  30, 170,  100, 200, 255]
;blue  = [0,    0, 255, 180,   0, 255,  10,  30, 250, 80, 200, 10,   220, 200, 255]
        ;   GOOD  YELLO ORANGE RED PURPLE Maroon     
red   = [0,    0, 255, 255,    255,  153, 76]
green = [0,  228, 255, 126,      0,    0,  0 ]
blue  = [0,    0,   0,   0,      0,   76, 38 ]


TVLCT, red, green, blue

END ; Load_Color_Table
;----------------------------------------------------------------------


;;;;;;;;;;;;;;;;;;;;;
; Main begins
;;;;;;;;;;;;;;;;;;;;;

; set output device and filenname

set_plot,'ps'
device,filename='texas.ps',/portrait,xsize=6, ysize=8,$
xoffset=1,yoffset=1.5,/inches, /color, bits=8
Load_Color_Table

; read data, get right lat, lon, and time.
  filelist = './filelist'

 for dd  = 21, 26 do begin 
 for kk = 0, 23 do begin
  day = dd 
  time =kk 
  timechar = strcompress(string(time, format = '(I2)'), /remove_all)+':00 CST'
  daychar = strcompress(string(day, format = '(I2)'), /remove_all) 
  monchar = 'April' 
  read_pm, filelist, day, time, monchar, $
           flat, flon,  data  

; set title
outtitle = 'PM!d2.5!n AQI Category, ' + $
           timechar + ' ' + monchar + ' '+ daychar + ', 2003'

; start to plot (regin limit) [ north, west, south, east] 
region_limit = [25,-108,38,-92]

; start mapping
xl = region_limit(1)
xr = region_limit(3)
yb = region_limit(0)
yt = region_limit(2)
xcenter = 0

; grid the data
; Grid the irregularly spaced data.
 gridData= SPH_SCAT(flon, flat, data, $
       BOUNDS=[xl, yb, xr, yt], GS=[0.25,0.25], BOUT=bout)
          
; Calculate xlon and ylat vectors corresponding to gridded
  s = SIZE(gridData)
  xlon = FINDGEN(s(1))*((bout(2) - bout(0))*1.0/(s(1)-1)) + bout(0) 
  ylat = FINDGEN(s(2))*((bout(3) - bout(1))*1.0/(s(2)-1)) + bout(1)


!p.multi=[0, 1, 2]


; plot coordinate
maxvalue = 100
minvalue = 0 
nlevels = 11
levels = minvalue + findgen(nlevels)*(maxvalue - minvalue)/(nlevels-1)
ccolors = findgen(nlevels)+1

;contour, gridData, xlon, ylat,  xrange=[xl, xr], $ 
;yrange=[yb, yt], xtitle = '!6Longitude (deg) ', $
;ytitle='Latitude (deg) ', $ 
;position= [0.0975, 0.3075, 0.9235, 0.8725], $
;color=0, xthick=5,xticks = 4, xminor = 4,$ 
;ythick=3, charsize=1.8, charthick=3, xstyle=1, ystyle=1,$
;nlevels = nlevels, $
;c_colors = ccolors, levels = levels, /fill, /normal
plot, [0, 1], [0, 2],  /nodata,   xrange=[xl, xr], $ 
yrange=[yb, yt], xtitle = '!6Longitude (deg) ', $
ytitle='Latitude (deg) ', $ 
position= [0.0775, 0.3075, 0.9035, 0.8725], $
color=0, xthick=5,xticks = 4, xminor = 4,$ 
ythick=3, charsize=1.2, charthick=3, xstyle=1, ystyle=1,$
title = outtitle

cal_aqicate, data, pmcolors
plots, flon, flat, psym=sym(1, 1), color=pmcolors, symsize=1.5

; plot map
map_set, 0, xcenter, $
/grid, charsize=1, mlinethick = 1, color=15,con_color=15,$ 
/mer, limit = region_limit,$ 
/noborder, /CYLINDRICAL, position=[0.08, 0.31, 0.90, 0.87],$ 
/noerase 
Add_County_Boundaries, 2
Add_texas_Boundary

; set AQI legend
  set_legend, 0.99, 0.07, 0.82, 0.085
endfor
endfor
device, /close
end
