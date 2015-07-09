PRO CREATE_SCR, FILE, COLS, SCANS, ROWSPERSCAN, TAG, LIST, XSIZE, YSIZE, $
  PROJFILE, MAXWEIGHT=MAXWEIGHT

;- Create a script to run ll2cr and fornav

;- On output, PROJFILE is an array of the projected file names

;- Check arguments
if (n_elements(file) eq 0) then message, 'Argument FILE is undefined'
if (n_elements(cols) eq 0) then message, 'Argument COLS is undefined'
if (n_elements(scans) eq 0) then message, 'Argument SCANS is undefined'
if (n_elements(rowsperscan) eq 0) then message, 'Argument ROWSPERSCAN is undefined'
if (n_elements(tag) eq 0) then message, 'Argument TAG is undefined'
if (n_elements(list) eq 0) then message, 'Argument LIST is undefined'
if (n_elements(xsize) eq 0) then message, 'Argument XSIZE is undefined'
if (n_elements(ysize) eq 0) then message, 'Argument YSIZE is undefined'

;- Check argument values
if (cols lt 2L) then message, 'COLS must be greater than 1'
if (scans lt 2L) then message, 'SCANS must be greater than 1'
if (rowsperscan lt 0L) then message, 'ROWSPERSCAN must be greater than 0'
if (xsize lt 2L) then message, 'XSIZE must be greater than 1'
if (ysize lt 2L) then message, 'YSIZE must be greater than 1'

;- Open script output file  
openw, lun, file, /get_lun

;- Set input gpd, lat, lon filenames
gpdfile = string(tag, format='(a, ".gpd")')
latfile = string(tag, cols, scans * rowsperscan, $
  format='(a, "_lat", 2("_", i5.5), ".dat")')
lonfile = string(tag, cols, scans * rowsperscan, $
  format='(a, "_lon", 2("_", i5.5), ".dat")')

;- Check read status of gpd, lat, lon files
gpdinfo = fileinfo(gpdfile)
if (gpdinfo.read eq 0) then message, 'GPDFILE cannot be read: ' + gpdfile
latinfo = fileinfo(latfile)
if (latinfo.read eq 0) then message, 'LATFILE cannot be read: ' + latfile
loninfo = fileinfo(lonfile)
if (loninfo.read eq 0) then message, 'LONFILE cannot be read: ' + lonfile

;- Check size of lat and lon files (bytes)
input_size = long(cols) * long(scans) * long(rowsperscan) * 4L
if (latinfo.size ne input_size) then $
  message, 'LATFILE is the wrong size: ' + latfile
if (loninfo.size ne input_size) then $
  message, 'LONFILE is the wrong size: ' + latfile

;- Write ll2cr command
printf, lun, cols, scans, rowsperscan, $
  format='("$MS2GT_DIR/ll2cr -f", 3(1x, i5), 1x, "\")'
printf, lun, latfile, lonfile, gpdfile, tag, $
  format='(1x, 4(1x, a))'

;- Set col and row filenames
scanfirst = 0L
colfile = string(tag, cols, scans, scanfirst, rowsperscan, $
  format='(a, "_cols", 3("_", i5.5), "_", i2.2, ".img")')
rowfile = string(tag, cols, scans, scanfirst, rowsperscan, $
  format='(a, "_rows", 3("_", i5.5), "_", i2.2, ".img")')

;- Set band (unremapped input) and proj (remapped output) file names
nbands = n_elements(list)
bandfile = strarr(nbands)
projfile = strarr(nbands)
for index = 0, n_elements(list) - 1L do begin
  bandfile[index] = string(tag, list[index], cols, scans * rowsperscan, $
    format='(a, "_", a, 2("_", i5.5), ".dat")')
  projfile[index] = string(tag, list[index], xsize, ysize, $
    format='(a, "_", a, "_proj", 2("_", i5.5), ".dat")')
endfor

;- Set fornav maximum weight keyword if requested
if keyword_set(maxweight) then maxtxt = "-m" else maxtxt = ""
  
;- Write fornav command
bandtype = strjoin(replicate('f4', nbands) + ' ')
printf, lun, nbands, maxtxt, bandtype, cols, scans, rowsperscan, $
  format='("$MS2GT_DIR/fornav", 1x, i2, 1x, a, 1x, "-t", 1x, a, 3(1x, i5), 1x, "\")'
printf, lun, colfile, rowfile, $
  format='(2x, 2(a, 1x), "\")'
printf, lun, strjoin(bandfile + ' '), $
  format='(2x, a, 1x, "\")'
printf, lun, xsize, ysize, $
  format='(2x, 2(i5, 1x), "\")'
printf, lun, strjoin(projfile + ' '), $
  format='(2x, a)'

;- Close script output file
free_lun, lun

END
