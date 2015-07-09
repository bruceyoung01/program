
; purpose of this program : plot the relationship between Land Surface Temperature and fire number in 0.5*0.5 degree

  filedir  = '/home/bruce/data/modis/arslab4/results/2003/'
  filename = '200304lst_fireno'

;  filename = STRARR(n)
;  READCOL, filedir + filelist, F = 'A', filename

;  date = STRARR(n)
;  For i = 0, n-1 DO BEGIN
;  date(i) = STRMID(filename(i), 0, 17)
;  ENDFOR

  np = 1354
  nl = 2030
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)
  
  OPENR, lun, filedir + filename, /get_lun
  grid_lat1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lon1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lst1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_count= FLTARR(gridsize_lat*gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  tmpcount = 0
  FOR i = 0, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst, tmpcount
    grid_lat1(i) = tmplat
    grid_lon1(i) = tmplon
    grid_lst1(i) = tmplst
    grid_count(i)= tmpcount
  ENDFOR 
  FREE_LUN, lun

  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + filename + '_firenum_bg.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  MyCt, /Verbose, /WhGrYlRd
  PLOT, grid_lst1, grid_count, psym = sym(1), color = 1, symsize=0.5, $
        xrange = [270, 310], yrange = [0, 35], position = [0.1, 0.2, 0.9, 0.7], $
        title = 'Relationship between LST and fire number', $
        xtitle = 'Background LST (K)', ytitle = 'Fire Number'
  DEVICE, /close
  CLOSE, 2

END
