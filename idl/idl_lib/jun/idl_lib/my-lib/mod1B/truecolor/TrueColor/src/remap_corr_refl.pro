PRO REMAP_CORR_REFL, FIL_1KM, FIL_HKM, FIL_QKM, FIL_GEO, LATCEN, LONCEN, $
  RES, DATA_TYPE, XSIZE, YSIZE, TAG, BAND01, BAND03, BAND04, $
  MAXWEIGHT=MAXWEIGHT

;+
; Create remapped MODIS band 1, 3, 4 images given corrected reflectance
;
; Usage:
;   REMAP_CORR_REFL, FIL_1KM, FIL_HKM, FIL_QKM, FIL_GEO, LATCEN, LONCEN, $
;     RES, DATA_TYPE, XSIZE, YSIZE, TAG, BAND01, BAND03, BAND04
;
; Input:
;   FIL_1KM    Name of 1000 m resolution corrected reflectance file
;   FIL_HKM    Name of  500 m resolution corrected reflectance file
;   FIL_QKM    Name of  250 m resolution corrected reflectance file
;   FIL_GEO    Name of geolocation file (MOD03 format)
;   LATCEN     Center latitude for remapped image (degrees)
;   LONCEN     Center longitude for remapped image (degrees)
;   RES        Resolution for remapped image (kilometers)
;   DATA_TYPE  Resolution to use for input ('1KM', 'HKM', or 'QKM')
;   XSIZE      Width of output image (pixels)
;   YSIZE      Height of output image (pixels)
;   TAG        String used to tag output images (arbitrary)
;
; Output:
;   BAND01     Remapped band 1 image (corrected reflectance)
;   BAND03     Remapped band 3 image (corrected reflectance)
;   BAND04     Remapped band 4 image (corrected reflectance)
;-

;- Check arguments
if (n_elements(fil_1km) eq 0) then message, 'Argument FIL_1KM is undefined'
if (n_elements(fil_hkm) eq 0) then message, 'Argument FIL_HKM is undefined'
if (n_elements(fil_qkm) eq 0) then message, 'Argument FIL_QKM is undefined'
if (n_elements(fil_geo) eq 0) then message, 'Argument FIL_GEO is undefined'
if (n_elements(latcen) eq 0) then message, 'Argument LATCEN is undefined'
if (n_elements(loncen) eq 0) then message, 'Argument LONCEN is undefined'
if (n_elements(res) eq 0) then message, 'Argument RES is undefined'
if (n_elements(data_type) eq 0) then message, 'Argument DATA_TYPE is undefined'
if (n_elements(xsize) eq 0) then message, 'Argument XSIZE is undefined'
if (n_elements(ysize) eq 0) then message, 'Argument YSIZE is undefined'
if (n_elements(tag) eq 0) then message, 'Argument TAG is undefined'

;- Get lat/lon data (used to determine boundaries of map projection)
print, '(Reading geolocation data)'
hdfid = hdf_sd_start(fil_geo)
hdf_sd_varread, hdfid, 'Latitude', lat
hdf_sd_varread, hdfid, 'Longitude', lon
hdf_sd_end, hdfid

;- Get map projection boundaries
get_limits, latcen, loncen, xsize, ysize, res, $
  temporary(lat), temporary(lon), start, count
if (start[0] eq -1) then $
  message, 'Requested lat/lon was not found in the geolocation data'
start[0] = 0L
count[0] = 1354L

;- Get corrected reflectance within map boundaries
get_corr_refl, fil_1km, fil_hkm, fil_qkm, data_type, start, count, tag, /debug

;- Get geolocation within map boundaries
get_geodata, fil_geo, data_type, start, count, tag, /debug

;- Create remap GPD file
gpdfile = tag + '.gpd'
create_gpd, gpdfile, latcen, loncen, res, xsize, ysize

;- Create remap script file
scrfile = tag + '.scr'
list = ['band01', 'band03', 'band04']
case data_type of
  '1KM' : scale = 1L
  'HKM' : scale = 2L
  'QKM' : scale = 4L
endcase
ncol = count[0] * scale
nscan = count[1] / 10L
rowsperscan = 10L * scale
create_scr, scrfile, ncol, nscan, rowsperscan, tag, list, xsize, ysize, projfile, $
  maxweight=keyword_set(maxweight)

;- Execute the remap script
print, '(Running remap script)'
cmd = 'source ' + scrfile
spawn, cmd

;- Read the projected image files
print, '(Reading projected image files)'
band01 = read_binary(projfile[0], data_dims=long([xsize, ysize]), data_type=4)
band03 = read_binary(projfile[1], data_dims=long([xsize, ysize]), data_type=4)
band04 = read_binary(projfile[2], data_dims=long([xsize, ysize]), data_type=4)

END
