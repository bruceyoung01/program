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

   ncolor=50
   cbottom=20
   color_range = [0.1,0.9]
   cbottom = cbottom + ncolor*color_range[0]
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

    color_index     = pm_stddev[i]/PM_value[i] * 100 + cbottom
    if (color_index gt cbottom+ncolor*(color_range[1]-color_range[0])) then $
        color_index = cbottom+ncolor*(color_range[1]-color_range[0])

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

;  clock legends
   r_legend = 1.8
   PLOTS, CIRCLE(-73, 30, r_legend), Color=1
   ARROW, -73, 30, -73+r_legend, 30, hsize = -0.40, color=1, thick=2.5, /data, /solid
   ARROW, -73, 30, -73-r_legend, 30, hsize = -0.40, color=1, thick=2.5, /data, /solid
   ARROW, -73, 30, -73, 30+r_legend, hsize = -0.40, color=1, thick=2.5, /data, /solid
   ARROW, -73, 30, -73, 30-r_legend, hsize = -0.40, color=1, thick=2.5, /data, /solid
   XYOUTS, -73, 30+r_legend*1.2, '0', color = 1, alignment=0.5, charsize=0.7
   XYOUTS, -73, 30-r_legend*1.5, '12', color = 1, alignment=0.5, charsize=0.7
   XYOUTS, -73+r_legend*1.3, 29.7, '6', color = 1, alignment=0.5, charsize=0.7
   XYOUTS, -73-r_legend*1.5, 29.7, '18', color = 1, alignment=0.5, charsize=0.7
   XYOUTS, -73, 30-r_legend*1.5-1.5, 'Arrow: Hour', color=1, alignment=0.5, charsize=0.7
; circle radius legends

  PLOTS, CIRCLE(-128, 30,r_scale*5), Color=1
  PLOTS, CIRCLE(-125, 30,r_scale*10), Color=1
  PLOTS, CIRCLE(-122, 30,r_scale*15), Color=1
  PLOTS, CIRCLE(-119, 30,r_scale*20), Color=1
  XYOUTS, -128, 28, '5',  color = 1, alignment=0.5, charsize=0.7
  XYOUTS, -125, 28, '10', color = 1, alignment=0.5, charsize=0.7
  XYOUTS, -122, 28, '15', color = 1, alignment=0.5, charsize=0.7
  XYOUTS, -119, 28, '20', color = 1, alignment=0.5, charsize=0.7
  XYOUTS, -123.5, 26.5, '!6PM!d2.5!n (!4l!6g/m!u3!n)', color = 1, alignment=0.5, charsize=0.7
   

;  plot the color bar

   colorbar, bottom=cbottom, ncolor=40, maxrange=0.4, minrange=0, divisions=4, $
             position=[0.25,0.45,0.7,0.47], color=1, format='(F3.1)',     $
             title= '!6Normalized Std. Deviation'

;  close plot device

   DEVICE,/CLOSE

;  end of program

   END
