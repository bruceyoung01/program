PRO GET_GEODATA, FIL_GEO, DATA_TYPE, START, COUNT, TAG, $
  DEBUG=DEBUG

;- Get MODIS geolocation data at 1km, 500m, or 250m resolution

;- Open the MOD03 HDF file
hdfid = hdf_sd_start(fil_geo)

;- Get array information and check dimensions
info = hdf_sd_varinfo(hdfid, 'Latitude')
if (info.ndims eq -1) then message, 'Latitude was not found: ' + fil_geo
ncol = info.dims[0]
nrow = info.dims[1]
if (ncol ne 1354L) then $
  message, 'Latitude has wrong number of columns: ' + fil_geo

;- Get latitude, longitude, and solar zenith
if keyword_set(debug) then print, '(Reading lat, lon, zen)'
hdf_sd_varread, hdfid, 'Latitude', lat, start=start, count=count
hdf_sd_varread, hdfid, 'Longitude', lon, start=start, count=count
hdf_sd_varread, hdfid, 'SolarZenith', zen, start=start, count=count
zen = temporary(zen) * 0.01

;- Close the HDF file
hdf_sd_end, hdfid

;- Print message if geolocation interpolation is required)
if (keyword_set(debug) and data_type ne '1KM') then $
  print, '(Interpolating geolocation data)'

;- Interpolate latitude if required
if (data_type eq 'HKM') then lat = modis_geo_interp_500(temporary(lat))
if (data_type eq 'QKM') then lat = modis_geo_interp_250(temporary(lat))

;- Write latitude to flat file
dims = size(lat, /dimensions)
file = string(tag, 'lat', dims[0], dims[1], $
  format='(a, "_", a, 2("_", i5.5), ".dat")')
openw, lun, file, /get_lun
writeu, lun, temporary(lat)
free_lun, lun

;- Interpolate longitude if required
if (data_type eq 'HKM') then lon = modis_geo_interp_500(temporary(lon))
if (data_type eq 'QKM') then lon = modis_geo_interp_250(temporary(lon))

;- Write longitude to flat file
dims = size(lon, /dimensions)
file = string(tag, 'lon', dims[0], dims[1], $
  format='(a, "_", a, 2("_", i5.5), ".dat")')
openw, lun, file, /get_lun
writeu, lun, temporary(lon)
free_lun, lun

;- Interpolate solar zenith if required
if (data_type eq 'HKM') then zen = modis_geo_interp_500(temporary(zen))
if (data_type eq 'QKM') then zen = modis_geo_interp_250(temporary(zen))

;- Write solar zenith to flat file
dims = size(zen, /dimensions)
file = string(tag, 'zen', dims[0], dims[1], $
  format='(a, "_", a, 2("_", i5.5), ".dat")')
openw, lun, file, /get_lun
writeu, lun, temporary(zen)
free_lun, lun

END
