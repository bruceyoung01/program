;
; Purpose: this code will plot the contour of the PM over the texas
;           regions 
;

; read PM data over different stations.
  pro  read_pm, datatype, filelist, datadir, np, day, time, monchar, $
           flat, flon,  data , dailyavg 
   
   nouse = ' '
   stationidchar = ' '
;   datadir = '/s1/data/wangjun/s4/Proj/texis_aqi/pmdat/2003_processed/'
;   np = 31
   maxnl = 90
   maxsta = 500
   oneline = fltarr(np)
   onemonth = fltarr(np, maxnl)
   tmpdata = fltarr(maxsta)
   tmplat = fltarr(maxsta)
   tmplon = fltarr(maxsta)
   tmptmp = fltarr(24)
   tmpavg = fltarr(maxsta)


   epaid = 0L

   k = 0    ;index of how many stations in the data  
   
   ; read the data station by station
     
     ; open filelist
       openr, 1, filelist
       readf, 1, nouse
       while (not eof(1) ) do begin
          readf, 1, stationidchar
          stationidchar = strcompress(stationidchar, /remove_all)
          onemonth = fltarr(np, maxnl)+999
	  
	  ; get the filename corresponding to id and month
	    stationfile = datadir + monchar + '_'+stationidchar + '.dat.asc'
          
	  ; read data (US and TX dataformat is slightly different)
	  ;  print, 'open file ', stationfile
	    openr, 2, stationfile
	    if ( strmid(datatype, 0, 2) eq 'TX') then begin
	    readf, 2, nouse
	    readf, 2, stateid, countyid, stanum, camsid, lat, lon, height, regionbox
            readf, 2, nouse
	    readf, 2, nouse
	    endif else begin
               readf, 2, nouse
	       readf, 2, epaid, lon, lat
	       readf, 2, nouse
	    endelse   
          
	 ; print, 'epaid = ', epaid, ' lat = ', lat, ' lon = ', lon
         ; print, 'np = ', np

	  ; read the measurements datasets
	    nl = 0
	    while  not eof(2) do begin
	      readf, 2, oneline
	 ;     print, 'oneline = ',  oneline
	      onemonth(0:np-1, nl) = oneline(0:np-1)
	      nl = nl + 1
	    endwhile
           
	  ; print, 'one month', onemonth(0:np-1, 0:nl-1)

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

               ; calculate daily mean
                 tmptmp(0:23) = onemonth(1:24, i)
		 result = where(tmptmp lt 999 and tmptmp gt 0, count)
		 if ( count gt 1 ) then begin
		   result1 =  moment(tmptmp(result))
		   tmpavg(k) = result1(0)
		 endif else begin
		   tmpavg(k) = 999
		 endelse  
	       
	       k = k  + 1
	     endif 

	   close,2
       endwhile   
       close,1

    ; return values
     result = where(tmpdata lt 999 and tmpdata gt 0, count)
    ;  result = where(tmpavg lt 999 and tmpavg gt 0, count)
      if ( count gt 0 ) then begin
        flat = tmplat(result)
        flon = tmplon(result)
	dailyavg = tmpavg(result)
	data = tmpdata(result)
      endif
      
      
       
      
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
  if ( nl gt 1 ) then begin 
  for i = 0, nl-1 do begin  
    j = 0

    if  ( pm(i) gt pmstd(5) ) then begin
          j = 6
    endif else begin	  
      while ( pm(i) gt pmstd(j) and j le 5) do begin
        j = j +1
      endwhile
    endelse
    pmcolors(i) = aqicolors(j-1)
  endfor  
  endif
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
;OpenR, 3, '~/idl_lib/US/contus.ovl'

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
PlotS, bnd[0,0:numpts-1], bnd[1,0:numpts-1], Color=0, $
      Thick=6
      
      
; classify west, central, south and east texas

plots, [-100, -100], [28, 35], color=0, thick=6, linestyle=2
plots, [-100, -97], [28, 28], color=0, thick=6, linestyle=2
plots, [-96, -96], [28.52, 33.9], color=0, thick=6, linestyle=2
      
      
      
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
;print, 'county #  is', conum

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
device,filename='daily_avg_southern_us.ps',/portrait,xsize=6, ysize=8,$
xoffset=1,yoffset=1.5,/inches, /color, bits=8
Load_Color_Table

; texax measurements
 txdatadir = '/s1/data/wangjun/s4/Proj/texis_aqi/pmdat/2003_processed/'
 txnp = 31
 txfilelist = './filelist'
 
; airs measurements
 usdatadir =  '/s1/data/wangjun/s7/pm_10/PM_OBS/processed/'  
 usnp = 25
 ;usfilelist =  '/s1/data/wangjun/s7/pm_10/PM_OBS/valid_stationid.txt'
 usfilelist =  '/s1/data/wangjun/s7/pm_10/PM_OBS/VALID_ID.txt'


; define time
 monchararry = ['April', 'May']
 dayarrystat = [20, 1]
 dayarryends = [30, 30]

 
 for mon = 0, 1 do begin
 for dd  = dayarrystat(mon), dayarryends(mon) do begin 
 for kk = 0, 0 do begin

  day = dd 
  time =kk 
  timechar = strcompress(string(time, format = '(I2)'), /remove_all)+':00 CST'
  daychar = strcompress(string(day, format = '(I2)'), /remove_all) 
  monchar = monchararry(mon) 
  usflat = 0.0
  usflon = 0.0
  usdata = 0.0
  txflat = 0.0
  txdata = 0.0
  txflon = 0.0
  txdailyavg=0.0
  usdailyavg = 0.0 

  ; read data from texas
    
    read_pm, 'TXDATA',txfilelist, txdatadir, txnp, day, time, monchar, $
           txflat, txflon,  txdata, txdailyavg 
    
  ; read data from US measurements, cst utc in summer is 5hr, winter is
  ;6hr
    if mon eq 0 then monchar = 'Apr'
    utcday = day
    utctime = time+5
    if ( utctime ge 24 ) then begin
      utctime = utctime-24
      utcday = utcday+1
    endif 
    print, 'txnp = ', usnp, ' day = ', utcday, ' utctime', utctime, ' monchar=', monchar
    read_pm, 'USDATA', usfilelist, usdatadir, usnp, utcday, utctime, monchar, $
           usflat, usflon,  usdata, usdailyavg 
    

; set title
outtitle = 'PM!d2.5!n AQI Category, ' + $
           daychar + ' ' + monchar + ' , 2003'

; start to plot (regin limit) [ north, west, south, east] 
;region_limit = [25,-108,38,-92]
;region_limit = [20,-120,45,-70]
region_limit = [20,-113,45,-65]

; start mapping
xl = region_limit(1)
xr = region_limit(3)
yb = region_limit(0)
yt = region_limit(2)
xcenter = 0

; grid the data
; Grid the irregularly spaced data.
; gridData= SPH_SCAT(flon, flat, data, $
;       BOUNDS=[xl, yb, xr, yt], GS=[0.25,0.25], BOUT=bout)
          
; Calculate xlon and ylat vectors corresponding to gridded
 ; s = SIZE(gridData)
 ; xlon = FINDGEN(s(1))*((bout(2) - bout(0))*1.0/(s(1)-1)) + bout(0) 
 ; ylat = FINDGEN(s(2))*((bout(3) - bout(1))*1.0/(s(2)-1)) + bout(1)


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
color=0, xthick=5,xticks = 6, xminor = 8,$ 
ythick=3, charsize=1.2, charthick=3, xstyle=1, ystyle=1,$
title = outtitle


; texas data
cal_aqicate, txdailyavg, pmtxcolors
plots, txflon, txflat, psym=sym(1, 1), color=pmtxcolors, symsize=1.5

; aqi data, should narrow to the US region only
cal_aqicate, usdailyavg, pmuscolors
results = where ( usflon gt xl and usflon lt xr and $
                  usflat gt yb and usflat lt yt, count)
if ( count gt 0 ) then begin 
plots, usflon(results), usflat(results), psym=sym(1, 1), color=pmuscolors(results), symsize=1.2
endif

; plot map
map_set, 0, xcenter, londel = 360, $
/grid, charsize=1, mlinethick = 1, color=15,con_color=15,$ 
/mer, limit = region_limit,$ 
/CYLINDRICAL, position=[0.0775, 0.31, 0.90, 0.8725],$ 
/noerase, /noborder, /us, xmargin=[-10, 0] 

; add second grids
plots, [-109.893, -90.934, -90.934, -109.893, -109.893], $
       [24.378,   24.378,  38.137, 38.137, 24.378], color=0,$
      linestyle=4, thick=6

for kkk = 0, 5 do begin
plots, [-73-kkk*8, -73-kkk*8], [20, 45], linestyle=1 
endfor

; add mark for the locaiton of ARM site
plots, -97.5, 36.55, psym = sym(5, 1), color=0, symsize=1.2

;Add_County_Boundaries, 2
Add_texas_Boundary


; set AQI legend
  set_legend, 0.99, 0.07, 0.82, 0.085
endfor
endfor
endfor
device, /close
end
