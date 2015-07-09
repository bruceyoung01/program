;
; plot FLAME data
;

; procedure for plotting flames emission data
 pro plot_emission_subroutine_LST_fire, lat1, lon1, maxlat, minlat, maxlon, minlon, flux, date

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
  region_limit = [minlat, minlon, maxlat, maxlon]
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

   ;flux = flux*area
   flux = flux
   ;PRINT, 'AA : ', flux
   ; normalize flux data
     result = where(flux gt 0, count)
     if ( count gt 0 ) then begin
        flux = flux(result)
        ;PRINT, 'CC : ', flux
        minvalue = 270.
        maxvalue = 330.
        n_levels = 6
        flux = 21+fix((flux-minvalue)/((maxvalue - minvalue)/(n_levels)))*8
      endif
   ;PRINT, 'DD : ', flux
; set the value of flux to maxmum value of color, if the value of flux is larger than the 
; maximum of color
   for i = 0L, count-1 DO BEGIN
    IF ( flux(i) le 330 ) THEN BEGIN
        flux(i) = flux(i)
    ENDIF ELSE BEGIN
        flux(i) = 330
    ENDELSE
   END
   for i = 0L, count-1 do begin
    if ( lon1(result(i)) gt xl and lon1(result(i)) lt xr and $
         lat1(result(i)) gt yb and lat1(result(i)) lt yt ) THEN BEGIN
      plots, lon1(result(i)), lat1(result(i)), symsize=1, $
              psym = sym(5), color = flux(i)
    ;PRINT, 'EE : ', i
    ;PRINT, 'FF : ', colors(i)
    endif
    endfor
   ;PRINT, 'DD : ', n_levels
    MAP_CONTINENTS, /continents, /usa, color = 16
    
 ; set legend
    ya = 0.78
    dy = 0.015
    xa = 0.18
    dx = 0.1
    minvalue = 270.
    maxvalue = 330.
    n_levels = 6
    barticks = minvalue +  findgen(n_levels+1)*(maxvalue-minvalue)/n_levels
    barticks = string(barticks, format='(I8)')
    for i = 0, n_levels-1  do begin
     y = [ya, ya, ya+dy, ya+dy, ya ]
     x = [xa+i*dx, xa+i*dx+dx, xa+i*dx+dx, xa+i*dx, xa+i*dx]
     polyfill,  x, y, color = colors(1+i*8),/normal
     xyouts,  xa+i*dx - 0.03, ya+dy+0.005, barticks(i), charthick=3,color=16,/normal,$
             align=0.5
    endfor

     xyouts, xa+i*dx, ya+dy+0.005, barticks(i),charthick=3,color=16,/normal,$
             align=1.0
     xyouts, xa +i*dx+0.01, ya+dy-0.005, ' K ', /normal,$
              color=16, charthick=3, charsize=1.4

     xyouts, 0.20, 0.84, 'MODIS LST ' + date, /normal,charsize=1.4,color=16,charthick=3
     ;xyouts, 0.19, 0.32, stime,/normal, charsize=1.4,color=16, charthick=3

end

