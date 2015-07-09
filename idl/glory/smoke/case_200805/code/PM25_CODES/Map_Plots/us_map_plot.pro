;  $ID: us_map_plot.pro
; 
; 
   @./sym.pro

;  open plot device

   ;SET_PLOT, 'X'
   ;WINDOW, 1, xsize = 600, ysize =400

   SET_PLOT, 'PS'
   DEVICE,FILENAME='./us_map.ps', $
          XSIZE=8.5, YSIZE=10, $
          XOFFSET=0.5, YOFFSET=0.5,$
          /INCHES,/color,BITS=8

   LOADCT, 33, ncolor = 80, bottom = 20

;  define the map range, and plot the map
;  note the color you would like to draw

   map_range = [25,-130,50,-70]

   MAP_SET, /CONTINENT, MLINETHICK = 1, LIMIT = map_range, $
            color = 1, /usa, /horizon, position = [0.2,0.5,0.8,0.75]

;  define color tables for the PM data

;  !!! to be filled....


;  plot the PM value for each station
;  ----------------------------------

   ; station info & PM values for each station
   N_total_station = 80
   lon_station     = FINDGEN(80)*0.6 - 125
   lat_station     = FINDGEN(80)*0   + 40
   PM_value        = FINDGEN(80) + 20

   FOR i = 0, N_total_station -1 DO BEGIN

    ; color index for the scatter is a function of PM values
    color_index     = PM_value[i] * 1.
   
    oplot,[lon_station[i]], [lat_station[i]], $
          psym = sym(1), symsize = 0.5, color = color_index
   
   ENDFOR

;  plot the color bar

   ; !!! to be filled...

;  close plot device

   DEVICE,/CLOSE

;  end of program

   END
