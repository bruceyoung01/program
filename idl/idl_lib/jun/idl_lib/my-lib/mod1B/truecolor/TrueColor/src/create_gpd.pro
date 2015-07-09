PRO CREATE_GPD, FILE, LAT, LON, RES, XSIZE, YSIZE

;- Create a Grid Parameter Definition (GPD) file

;- Check arguments
if (n_elements(file) eq 0) then message, 'Argument FILE is undefined'
if (n_elements(lat) eq 0) then message, 'Argument LAT is undefined'
if (n_elements(lon) eq 0) then message, 'Argument LON is undefined'
if (n_elements(res) eq 0) then message, 'Argument RES is undefined'
if (n_elements(xsize) eq 0) then message, 'Argument XSIZE is undefined'
if (n_elements(ysize) eq 0) then message, 'Argument YSIZE is undefined'

;- Check argument values
if (lat lt -90.0) or (lat gt 90.0) then message, 'LAT is out of range -90 to 90'
if (lon lt -180.0) or (lon gt 180.0) then message, 'LON is out of range -180 to 180'
if (res le 0.0) then message, 'RES must be greater than 0'
if (xsize lt 2L) then message, 'XSIZE must be greater than 1'
if (ysize lt 2L) then message, 'YSIZE must be greater than 1'

;- Get projection name (only one choice currently)
projection = 'Azimuthal Equal-Area'

;- Open the GPD output file
openw, lun, file, /get_lun

;- Compute map origin (center of grid)
xcen = (xsize * 0.5) - 0.5
ycen = (ysize * 0.5) - 0.5

;- Write the output file
printf, lun, projection, format='("Map Projection: ", a)'
printf, lun, lat, format='("Map Reference Latitude: ", f8.3)'
printf, lun, lon, format='("Map Reference Longitude: ", f8.3)'
printf, lun, res, format='("Grid Map Units per Cell: ", f8.3)'
printf, lun, xsize, format='("Grid Width: ", f8.1)'
printf, lun, xcen, format='("Grid Map Origin Column: ", f8.1)'
printf, lun, ysize, format='("Grid Height: ", f8.1)'
printf, lun, ycen, format='("Grid Map Origin Row: ", f8.1)'

;- Close the GPD file
free_lun, lun

END
