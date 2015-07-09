PRO GET_CORR_REFL, FIL_1KM, FIL_HKM, FIL_QKM, DATA_TYPE, START, COUNT, TAG, $
  DEBUG=DEBUG

;- Get corrected reflectance data for bands 1, 3, 4
;- at 1km, 500m, or 250m resolution from output file(s)
;- produced by 'corr_refl.c' by Jacques Descloitres

;-------------------------------------------------------------------------------
;- 1KM or HKM RESOLUTION (requires either 1KM *or* HKM resolution files)
;-------------------------------------------------------------------------------

if (data_type eq '1KM' or data_type eq 'HKM') then begin

  ;- Open the 1km or 500m HDF file and set scale factor
  if (data_type eq '1KM') then begin
    hdfid = hdf_sd_start(fil_1km)
    scale = 1L
    this_file = fil_1km
  endif else begin
    hdfid = hdf_sd_start(fil_hkm)
    scale = 2L
    this_file = fil_hkm
  endelse
    
  ;- Get array information and check dimensions
  info = hdf_sd_varinfo(hdfid, 'CorrRefl_01')
  if (info.ndims eq -1) then message, 'CorrRefl_01 was not found'
  ncol = info.dims[0]
  nrow = info.dims[1]
  if (ncol ne (1354L * scale)) then $
    message, 'CorrRefl_01 has wrong number of columns: ' + this_file
  
  ;-------------------------------------------------------------------------------
  ;- BAND 1
  ;-------------------------------------------------------------------------------

  ;- Get band 1
  if keyword_set(debug) then print, '(Reading band 1)'
  hdf_sd_varread, hdfid, 'CorrRefl_01', band01, $
    start=(start * scale), count=(count * scale)
  band01 = temporary(band01) * 0.0001
  
  ;- Write to flat file
  dims = size(band01, /dimensions)
  file = string(tag, 'band01', dims[0], dims[1], $
    format='(a, "_", a, 2("_", i5.5), ".dat")')
  openw, lun, file, /get_lun
  writeu, lun, temporary(band01)
  free_lun, lun
  
  ;-------------------------------------------------------------------------------
  ;- BAND 3
  ;-------------------------------------------------------------------------------

  ;- Get band 3
  if keyword_set(debug) then print, '(Reading band 3)'
  hdf_sd_varread, hdfid, 'CorrRefl_03', band03, $
    start=(start * scale), count=(count * scale)
  band03 = temporary(band03) * 0.0001

  ;- Write to flat file
  dims = size(band03, /dimensions)
  file = string(tag, 'band03', dims[0], dims[1], $
    format='(a, "_", a, 2("_", i5.5), ".dat")')
  openw, lun, file, /get_lun
  writeu, lun, temporary(band03)
  free_lun, lun
  
  ;-------------------------------------------------------------------------------
  ;- BAND 4
  ;-------------------------------------------------------------------------------

  ;- Get band 4
  if keyword_set(debug) then print, '(Reading band 4)'
  hdf_sd_varread, hdfid, 'CorrRefl_04', band04, $
    start=(start * scale), count=(count * scale)
  band04 = temporary(band04) * 0.0001

  ;- Write to flat file
  dims = size(band04, /dimensions)
  file = string(tag, 'band04', dims[0], dims[1], $
    format='(a, "_", a, 2("_", i5.5), ".dat")')
  openw, lun, file, /get_lun
  writeu, lun, temporary(band04)
  free_lun, lun
  
  ;- Close the HDF file
  hdf_sd_end, hdfid
  
endif

;-------------------------------------------------------------------------------
;- QKM RESOLUTION (requires both QKM *and* HKM resolution files)
;-------------------------------------------------------------------------------

if (data_type eq 'QKM') then begin

  ;- Open the QKM HDF file and set scale factor
  hdfid = hdf_sd_start(fil_qkm)
  scale = 4L

  ;- Get array information and check dimensions
  info = hdf_sd_varinfo(hdfid, 'CorrRefl_01')
  if (info.ndims eq -1) then message, 'CorrRefl_01 was not found'
  ncol = info.dims[0]
  nrow = info.dims[1]
  if (ncol ne (1354L * scale)) then $
    message, 'CorrRefl_01 has wrong number of columns: ' + fil_qkm

  ;-------------------------------------------------------------------------------
  ;- BAND 1 QKM NATIVE RESOLUTION
  ;-------------------------------------------------------------------------------

  ;- Get band 1
  if keyword_set(debug) then print, '(Reading band 1 @ 250 meter)'
  hdf_sd_varread, hdfid, 'CorrRefl_01', band01, $
    start=(start * scale), count=(count * scale)
  band01 = temporary(band01) * 0.0001
  
  ;- Write to flat file (but keep band01 in memory)
  dims = size(band01, /dimensions)
  file = string(tag, 'band01', dims[0], dims[1], $
    format='(a, "_", a, 2("_", i5.5), ".dat")')
  openw, lun, file, /get_lun
  writeu, lun, band01
  free_lun, lun

  ;- Close the QKM HDF file
  hdf_sd_end, hdfid
  
  ;-------------------------------------------------------------------------------
  ;- GET BANDS 3 AND 4 AT HKM RESOLUTION, CONVERT TO QKM RESOLUTION
  ;-------------------------------------------------------------------------------

  ;- Open the HKM HDF file and set scale factor
  hdfid = hdf_sd_start(fil_hkm)
  scale = 2L
  
  ;- Get array information and check dimensions
  info = hdf_sd_varinfo(hdfid, 'CorrRefl_01')
  if (info.ndims eq -1) then message, 'CorrRefl_01 was not found'
  ncol = info.dims[0]
  nrow = info.dims[1]
  if (ncol ne (1354L * scale)) then $
    message, 'CorrRefl_01 has wrong number of columns: ' + fil_hkm

  ;-------------------------------------------------------------------------------
  ;- BAND 1 HKM NATIVE RESOLUTION
  ;-------------------------------------------------------------------------------

  ;- Get band 1 at 500 meter resolution
  if keyword_set(debug) then print, '(Reading band 1 @ 500 meter)'
  hdf_sd_varread, hdfid, 'CorrRefl_01', band01_500, $
    start=(start * scale), count=(count * scale)
  band01_500 = temporary(band01_500) * 0.0001

  ;- Interpolate to 250 meter resolution
  if keyword_set(debug) then print, '(Interpolating band 1)'
  band01_250 = modis_level1b_hkm2qkm(temporary(band01_500))
  
  ;- Compute ratio of band 1 interpolated to band 1 native 250 meter resolution
  ratio = temporary(band01_250) / temporary(band01)

  ;-------------------------------------------------------------------------------
  ;- BAND 3 HKM NATIVE RESOLUTION; CONVERT TO QKM
  ;-------------------------------------------------------------------------------

  ;- Get band 3 at 500 meter resolution
  if keyword_set(debug) then print, '(Reading band 3 @ 500 meter)'
  hdf_sd_varread, hdfid, 'CorrRefl_03', band03_500, $
    start=(start * scale), count=(count * scale)
  band03_500 = temporary(band03_500) * 0.0001

  ;- Interpolate to 250 meter resolution
  if keyword_set(debug) then print, '(Interpolating band 3)'
  band03_250 = modis_level1b_hkm2qkm(temporary(band03_500))
  
  ;- Apply ratio to create pseudo band 3 data at 250 meter resolution
  band03_250 = temporary(band03_250) / ratio

  ;- Write to flat file
  dims = size(band03_250, /dimensions)
  file = string(tag, 'band03', dims[0], dims[1], $
    format='(a, "_", a, 2("_", i5.5), ".dat")')
  openw, lun, file, /get_lun
  writeu, lun, temporary(band03_250)
  free_lun, lun
  
  ;-------------------------------------------------------------------------------
  ;- BAND 4 HKM NATIVE RESOLUTION; CONVERT TO QKM
  ;-------------------------------------------------------------------------------

  ;- Get band 4 at 500 meter resolution
  if keyword_set(debug) then print, '(Reading band 4 @ 500 meter)'
  hdf_sd_varread, hdfid, 'CorrRefl_04', band04_500, $
    start=(start * scale), count=(count * scale)
  band04_500 = temporary(band04_500) * 0.0001

  ;- Interpolate to 250 meter resolution
  if keyword_set(debug) then print, '(Interpolating band 4)'
  band04_250 = modis_level1b_hkm2qkm(temporary(band04_500))
  
  ;- Apply ratio to create pseudo band 4 data at 250 meter resolution
  band04_250 = temporary(band04_250) / ratio

  ;- Write band 4 to flat file after applying ratio
  dims = size(band04_250, /dimensions)
  file = string(tag, 'band04', dims[0], dims[1], $
    format='(a, "_", a, 2("_", i5.5), ".dat")')
  openw, lun, file, /get_lun
  writeu, lun, temporary(band04_250)
  free_lun, lun

  ;- Close the HKM HDF file
  hdf_sd_end, hdfid

endif

END
