
; this program will read the AQI derived from MODIS and PM
;  measurements at each station 3. Then will plot time series
; based on the AQI derivations.


pro read_data, inf, Jday, date, AQI, DAQI, npt
  nouse = ' '
  openr, 1, inf
  readf, 1, nouse
  i = 0
   while ( not eof(1) ) do begin
     readf, 1, a, b, c,d
     Jday(i)= a
     date(i) = b
     DAQI(i) =c
     AQI(i) = d
     i = i +1
   endwhile
  close,1
  npt= i
end     


pro plot_station, Jday, date, AQI, DAQI, npt, syminx
    
    
    for i = 0, npt-1 do begin
      if ( jday(i) gt 180 and jday(i) le 304 ) then begin
      ; measured AQI
       usersym, cos(findgen(16)/15.*!pi*2), sin(findgen(16)/15.*!pi*2), /fill
       plots, Jday(i), AQI(i), psym = 8, symsize = 0.6

      ; derived AQI
       usersym, cos(findgen(16)/15.*!pi*2), sin(findgen(16)/15.*!pi*2)
       if syminx eq 1 then begin
       plots, Jday(i), DAQI(i), psym = syminx,symsize = 1.5, thick=3
       endif else begin
        plots, Jday(i), DAQI(i), psym = syminx,symsize = 1.0, thick=3
       endelse
       
      endif 
    endfor   
end


; main begins
TerraF = 'AQI_STATION_Final_Terra_collocate.dat'
AquaF = 'AQI_STATION_Final_Aqua_collocate.dat'
Jday = fltarr(400)
date = fltarr(400)
DAQI = fltarr(400)
AQI = fltarr(400)
npt= 0



set_plot, 'ps'
device, filename = 'AQI_STA.ps', xoffset=0.5, yoffset=0.5, $
         xsize = 7, ysize = 10, /inches

plot, [180, 304], [0, 3], xthick=3, ythick=3,$
	 xstyle=1, ystyle=1, charsize=1.2, charthick=3, $
	 position = [0.1, 0.2, 0.99, 0.5], $
	 /nodata, yticks = 3, xtitle = '!6Julian Day (2002)',$
	 ytitle = 'Air Quality !c!c   Good   Moderate  Unhealthy!n', $
	 ytickname = [' ', ' ', ' ', ' '], yticklen = -0.02, xticklen=-0.03
	 
	 ;ytickname = $
	 ;         ['Good', 'Moderate', 'Unhealthy', ' ']

	 
  read_data, TerraF, Jday, date, AQI, DAQI, npt
  plot_station,  Jday, date, AQI+0.5, DAQI+0.5, npt, 8
  
  read_data, AquaF, Jday, date, AQI, DAQI, npt
  plot_station,  Jday, date, AQI+0.5, DAQI+0.5, npt, 1
  
  xa = 270
  ya = 2.5
  dx = 5
  dy = 0.2
  plots, xa, ya, psym = 1, thick=3, symsize=1.2
  xyouts, xa+dx, ya, 'AQUA AQI', charsize = 1.2, charthick=3
  
  plots, xa, ya-dy, psym = 8, thick=3
  xyouts, xa+dx, ya-dy, 'TERRA AQI', charsize = 1.2, charthick=3
  
  usersym, cos(findgen(16)/15.*!pi*2), sin(findgen(16)/15.*!pi*2), /fill
  plots, xa, ya-2*dy, psym = 1, thick=8, symsize=0.6
  xyouts, xa+dx, ya-2*dy, 'Measured AQI', charsize = 1.2, charthick=3
  
  xyouts,  xa, ya+dy,'Station: NO. BHA', charsize = 1.2, charthick=3
  
  
device, /close
end  
  
  
  
  
  
  
  
