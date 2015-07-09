;  $ID: pm25_map_plot.pro
; 
; 
   PRO plot_clock, lat_station, lon_station, pm_value, pm_stddev, $
       pm_min, pm_max, pm_min_hour, pm_max_hour, title

;  open plot device

   SET_PLOT, 'PS'
   DEVICE,FILENAME= 'clock_v0.ps', $
          XSIZE=8.5, YSIZE=10, $
          XOFFSET=0.5, YOFFSET=0.5,$
          /INCHES,/color,BITS=8

   LOADCT, 33, ncolor = 50, bottom = 20

;  define the map range, and plot the map
;  note the color you would like to draw

   map_range = [25,-130,50,-70]
   position = [0.15,0.5,0.8,0.75]

   MAP_SET, /CONTINENT, MLINETHICK = 1, LIMIT = map_range, $
            color = 1, /usa, /horizon, position = position
   MAP_GRID, /box_axes, glinestyle=1, color =1, /no_grid

;  plot the PM value for each station
;  ----------------------------------

   ; station info & PM values for each station
   N_total_station = n_elements(pm_value)

   FOR i = 0, N_total_station -1 DO BEGIN

    ; color index for the scatter is a function of PM values
    color_index     = PM_value[i] *2 + 20
   
    ; 
    r_scale = 0.05
    r_mean = PM_value[i] * r_scale 
    POLYFILL, CIRCLE(lon_station[i], lat_station[i], r_mean), Color=color_index
    
    ; draw arrows: maximum value 
    r_max  = pm_max[i] * r_scale 
    dx_max = r_max * sin(pm_max_hour[i] * 15./180.*!PI)
    dy_max = r_max * cos(pm_max_hour[i] * 15./180.*!PI)

    ARROW,  lon_station[i], lat_station[i], $
            lon_station[i]+dx_max, lat_station[i]+dy_max, $
            hsize = -0.40, color=1, thick=2.5, /data, /solid

    ; draw arrows: minimum value 
    r_min  = pm_min[i] * r_scale
    dx_min = r_min * sin(pm_min_hour[i] * 15./180.*!PI)
    dy_min = r_min * cos(pm_min_hour[i] * 15./180.*!PI)
    ARROW,  lon_station[i], lat_station[i], $
            lon_station[i]+dx_min, lat_station[i]+dy_min, $
            hsize = -0.40, color=0, thick=3.0, hthick=3.0, /data

   ENDFOR

;  plot the color bar

   colorbar, bottom=20, ncolor=50, maxrange=25, minrange=0, divisions=5, $
             position=[0.25,0.45,0.7,0.47], color=1, title = '!6PM!d2.5!n (!4l!6g/m!u3!n)'

;  close plot device

   DEVICE,/CLOSE

;  end of program

   END
