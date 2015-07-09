;
; plot FLAME data
;

; procedure for plotting flames emission data
 pro plot_flame, lat1, lon1, flux, area, possibility, stime
 
 ; set up color scheme
  r=bytarr(65) & g = r & b =r
  r(0:64)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
  0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
  230,255,255,255,255,255,255,255,255,255,255,255,255,255,255, 255,$
  255,255,255,255,255,255,255,255,255,255, 200]

   g(0:64)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
   0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
   251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
   26,0,0,0,0,0,0,0,0,0,  0]

   b(0:64)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,36,$
   72,109,145,182,218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255, 180]

    colors = indgen(48) +20
    tvlct, r, g, b
  
 
 !p.multi=[0, 1, 2]
;  region_limit = [0, -130, 50, -40]
  region_limit = [10, -115, 45, -65]
  xl = region_limit(1) 
  xr = region_limit(3) 
  yb = region_limit(0) 
  yt = region_limit(2)
 !p.thick=3

  plot, [xl, xr], [yb, yt], /nodata, xrange=[xl, xr], $
         yrange=[yb, yt], xtitle = '!6Longitude (deg) ', $
	 ytitle='Latitude (deg) ', $
	 position= [0.10, 0.31, 0.85, 0.77], color=15,$
	 xthick=3,xticks=5, xminor=10, $
	 ythick=3, charsize=1.4, charthick=3, xstyle=1, ystyle=1
	 
   map_set, 0, 25, /continent, $
          charsize=1.4, mlinethick = 4, color=16,con_color=16,$
	 /mer, limit = region_limit,$
	 position=[0.10, 0.31, 0.85, 0.77],$
	 /noerase, /usa,/noborder
   PRINT, 'AA : ',flux 
   flux = flux*area 

   PRINT, 'BB : ',flux

   ; normalize flux data
     result = where(flux gt 0, count)
     if ( count gt 0 ) then begin
        flux = alog10 (flux(result))
        PRINT, 'CC : ', flux
        minvalue = 0.
        maxvalue = 4. 
        n_levels = 4 
        flux = 21+fix((flux-minvalue)/((maxvalue - minvalue)/(n_levels)))*10
      endif

   for i = 0, count-1 do begin
    if ( area(result(i)) gt 0 and lon1(result(i)) gt xl and $
         lon1(result(i)) lt xr and lat1(result(i)) gt yb and $
	 lat1(result(i)) lt yt and possibility(i) gt 0 )  then begin
      plots, lon1(result(i)), lat1(result(i)), symsize=0.3, $
              psym = sym(5), color = flux(i)
    endif
   endfor

 ; set legend
    ya = 0.78
    dy = 0.015
    xa = 0.18
    dx = 0.1
    barticks = minvalue +  findgen(N_levels+1)*(maxvalue-minvalue)/n_levels
    barticks = string(barticks, format='(I3)') 
    for i = 0, n_levels-1  do begin
     y = [ya, ya, ya+dy, ya+dy, ya ]
     x = [xa+i*dx, xa+i*dx+dx, xa+i*dx+dx, xa+i*dx, xa+i*dx]
     polyfill,  x, y, color = colors(1+i*10),/normal
     xyouts,  xa+i*dx, ya+dy+0.005, barticks(i), charthick=3,color=16,/normal,$
             align=0.5
    endfor
     xyouts, xa+i*dx, ya+dy+0.005, barticks(i),charthick=3,color=16,/normal,$
             align=1.0
     xyouts, xa +i*dx+0.01, ya+dy-0.005, ' Log!d10!n(kghr!u-1!n)',/normal,$
              color=16, charthick=3, charsize=1.4 
     
     xyouts, 0.19, 0.84, 'SMOKE Emission Flux   ' + stime, /normal,charsize=1.4,color=16,charthick=3 
     ;xyouts, 0.19, 0.32, stime,/normal, charsize=1.4,color=16, charthick=3

end

; procedure for reading the data
 pro read_flame, inf, lat1, lon1, lat2, lon2, area, flux, $
                 possibility, nl
		 
   nouse = ' '
 
 ; initialize the array 
   MaxL = 10000
   lat1 = fltarr(MaxL)
   lon1 = fltarr(MaxL)
   lat2 = fltarr(MaxL)
   lon2 = fltarr(MaxL)
   area = fltarr(MaxL)
   flux = fltarr(MaxL)
   possibility = fltarr(MaxL) 
   i = 0L

 ; start to read file
   openr, 1, inf
   while (not eof(1) ) do begin
      readf, 1, tmplat1, tmplon1, tmplat2, tmplon2, sat, tmparea,$
                tmpflux, tmpposs, nouse 
     lat1(i) =  tmplat1
     lon1(i) =  tmplon1
     lat2(i) = tmplat2
     lon2(i) = tmplon2
     area(i) = tmparea
     flux(i) = tmpflux
     possibility(i) = tmpposs
     i = i +1
   endwhile
   close,1
   nl = i-1
 end


;
; Main begins
;
;
; set MAPS
;
;  set_plot, 'ps'
;  device, filename ='flame.ps', /portrait, xsize = 7.5, ysize=9, $
;          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8


; start to read all files
  time = 1L
  stime = ' '
  Infprefix = 'smoke_goes_' 
  openr, 2, 'filename.txt'
  while ( not eof(2) ) do begin
  ; readf, 2, time, format=('(I12)')
  ;time = 200304301800
   readf, 2, stime 
   print, 'stime = ', stime

  ;stime = string (time, format = '(I12)')
  Inf = '../data/' +Infprefix + stime + '.dat'

; set MAPS
;
  set_plot, 'ps'
  device, filename ='plot_flux_hour' + stime + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  
  ;if ( strmid(stime,8,2) eq '00' or  strmid(stime,8,2) eq '06' or $
  ;      strmid(stime,8,2)  eq '12' or  strmid(stime,8,2) eq '18'  ) then begin
  

  if ( strmid(stime,8,2)  eq '18' or  strmid(stime,8,2) eq '18'  ) then begin
  read_flame, inf, lat1, lon1, lat2, lon2, area, flux, $
              possibility, nl

  
  plot_flame, lat1, lon1, flux, area, possibility, stime
 endif

 endwhile
 device, /close   
 close,2
end 



     


