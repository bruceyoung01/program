;  $ID: pm25_map_plot.pro
; 
; 
   PRO PM25_map_plot, lat_station, lon_station, pm_value, title

;  open plot device

   ;SET_PLOT, 'PS'
   ;DEVICE,FILENAME= ps_filename+'.ps', $
   ;       XSIZE=8.5, YSIZE=10, $
   ;       XOFFSET=0.5, YOFFSET=0.5,$
   ;       /INCHES,/color,BITS=8

   ;LOADCT, 33, ncolor = 50, bottom = 20

;  define the map range, and plot the map
;  note the color you would like to draw

   map_range = [25,-130,50,-70]
   position = [0.2,0.5,0.8,0.75]

   xl = map_range[1]
   yb = map_range[0]
   xr = map_range[3]
   yt = map_range[2]

   
   MAP_SET, /CONTINENT, MLINETHICK = 1, LIMIT = map_range, $
            color = 1, /usa, /horizon, position = position

;  plot the PM value for each station
;  ----------------------------------

   ; station info & PM values for each station
   N_total_station = n_elements(pm_value)

   plot, [xl, xr], [yb, yt], /nodata, xrange = [xl, xr], $
         yrange = [yb, yt], position =position,          $
         ythick = 1, charsize = 1.0, charthick=1,        $
         xstyle=1, ystyle=1, xminor = 1, yminor=1,       $
         title=title, xtitle= 'Longitude [Degree]',      $
         ytitle = 'Latitude [Degree]', color=1, /noerase

   FOR i = 0, N_total_station -1 DO BEGIN

    ; color index for the scatter is a function of PM values
    color_index     = PM_value[i] *2 + 20
   
    oplot,[lon_station[i]], [lat_station[i]], $
          psym = sym(1), symsize = 0.5, color = color_index
   
   ENDFOR

;  plot the color bar

   colorbar, bottom=20, ncolor=50, maxrange=25, minrange=0, divisions=5, $
             position=[0.2,0.40,0.8,0.43], color=1, title = '!6PM!d2.5!n (!4l!6g/m!u3!n)'
   

;  close plot device

   ;DEVICE,/CLOSE

;  end of program

   END
