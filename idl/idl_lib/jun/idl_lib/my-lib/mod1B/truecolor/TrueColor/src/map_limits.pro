PRO MAP_LIMITS_FINDMIN, X, Y, LATMIN, LONMIN, LATMAX, LONMAX

result = convert_coord(x, y, /normal, /to_data)
lon = result[0, *]
lat = result[1, *]
latmin = min(lat) < latmin
lonmin = min(lon) < lonmin
latmax = max(lat) > latmax
lonmax = max(lon) > lonmax

END

PRO MAP_LIMITS, LATMIN, LATMAX, LONMIN, LONMAX

;- Check for existing map projection
if (!x.type ne 3) then message, 'Map coordinates have not been established'

;- Get map limits in normal coordinates
x0 = !x.window[0]
x1 = !x.window[1]
y0 = !y.window[0]
y1 = !y.window[1]

;- Set return values
latmin =   90.0
lonmin =  180.0
latmax =  -90.0
lonmax = -180.0

;- Set number of points to compute along each edge
np = 100

;- Find minimum and maximum lat/lon values along bottom edge
x = (findgen(np) / float(np - 1)) * (x1 - x0) + x0
y = replicate(y0, np)
map_limits_findmin, x, y, latmin, lonmin, latmax, lonmax

;- Find minimum and maximum lat/lon values along bottom edge
x = (findgen(np) / float(np - 1)) * (x1 - x0) + x0
y = replicate(y0, np)
map_limits_findmin, x, y, latmin, lonmin, latmax, lonmax

;- Find minimum and maximum lat/lon values along top edge
x = (findgen(np) / float(np - 1)) * (x1 - x0) + x0
y = replicate(y1, np)
map_limits_findmin, x, y, latmin, lonmin, latmax, lonmax

;- Find minimum and maximum lat/lon values along left edge
x = replicate(x0, np)
y = (findgen(np) / float(np - 1)) * (y1 - y0) + y0
map_limits_findmin, x, y, latmin, lonmin, latmax, lonmax

;- Find minimum and maximum lat/lon values along right edge
x = replicate(x1, np)
y = (findgen(np) / float(np - 1)) * (y1 - y0) + y0
map_limits_findmin, x, y, latmin, lonmin, latmax, lonmax

END
