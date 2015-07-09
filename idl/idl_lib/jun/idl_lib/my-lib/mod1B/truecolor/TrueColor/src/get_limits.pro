PRO GET_LIMITS, LATCEN, LONCEN, XSIZE, YSIZE, RES, LAT, LON, START, COUNT

;- Get the column and row limits for a specified map projection within
;- an array of MODIS 1km lat/lon data
; LATCEN    center latitude of map projection (degrees)
; LONCEN    center longitude of map projection (degrees)
; XSIZE     width of map projection (pixels)
; YSIZE     resolution of map projection (kilometers)
; LAT       array of MODIS 1km latitude data (degrees)
; LON       array of MODIS 1km longitude data (degrees)
; START     on output, the starting column and row within the map projection
; COUNT     on output, the number of columns and rows within the map projection

;- Save device and window settings on entry
entry_device = !d.name
entry_window = !d.window

;- Configure Z-buffer
set_plot, 'Z'
device, set_resolution=[xsize, ysize], set_colors=256, z_buffering=0, $
  set_character_size=[10, 12]

;- Create map projection
scale = res * 4.0e6
map_set, latcen, loncen, scale=(scale * (!d.x_px_cm / 40.0)), $
  /lambert, position=[0.0, 0.0, 1.0, 1.0], /noerase, /noborder

;- Get map limits
map_limits, latmin, latmax, lonmin, lonmax

;- Revert to entry device and window
set_plot, entry_device
if (!d.window gt 0) then wset, entry_window

;- Get indices within lat/lon data
image_bounds, lat, lon, latmin, latmax, lonmin, lonmax, x1, x2, y1, y2

;- Convert to start, count values
start = [x1, (y1 / 10L) * 10L]
count = [x2 - x1, ((y2 - y1) / 10L) * 10L + 10L]

END
