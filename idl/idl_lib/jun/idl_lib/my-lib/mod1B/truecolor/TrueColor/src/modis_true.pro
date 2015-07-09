PRO MODIS_TRUE

;- Set input file names
fil_1km = 'crefl.1km.hdf'
fil_hkm = 'crefl.hkm.hdf'
fil_qkm = 'crefl.qkm.hdf'
fil_geo = 'MOD03.hdf'

;- Get map parameters
print, '(Reading map parameters from map_parameters.in)'
latcen = 0.0 & loncen = 0.0 & res = 0.0 & data_type = ''
xsize = 0L & ysize = 0L & tag = ''
openr, lun, 'map_parameters.in', /get_lun
readf, lun, latcen
readf, lun, loncen
readf, lun, res
readf, lun, data_type, format='(a)'
readf, lun, xsize
readf, lun, ysize
readf, lun, tag, format='(a)'
free_lun, lun
help, latcen, loncen, res, data_type, xsize, ysize, tag
  
;- Create the remapped band 1, 3, 4 arrays
remap_corr_refl, fil_1km, fil_hkm, fil_qkm, fil_geo, latcen, loncen, $
  res, data_type, xsize, ysize, tag, band01, band03, band04
  
;- Create the true color image
print, '(Creating TIFF image)'
true = enhance(temporary(band01), temporary(band03), temporary(band04))
write_tiff, 'true.tif', true, 1, planarconfig=2

END
