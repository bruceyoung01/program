; purpose of this program : plot the LST with fire
@/home/bruce/program/idl/arslab4/plot_emission_subroutine_LST_firenum.pro


  filedir  = '/home/bruce/data/modis/arslab4/results/2003/'
  filename = 'fire_MOD11_L2.A2003120'
;  filelist    = 'slist'
  
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
  grid_firenum = INTARR(gridsize_lat*gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  tmpfirenum = 0
  FOR i = 0, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst, tmpfirenum
    grid_lat1(i) = tmplat
    grid_lon1(i) = tmplon
    grid_lst1(i) = tmplst
    grid_firenum(i) = tmpfirenum
  ENDFOR
  CLOSE, lun

  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + filename + 'firenum.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  plot_emission_subroutine_LST_firenum, grid_lat1, grid_lon1,  maxlat, minlat, maxlon, minlon, grid_firenum, filename

  DEVICE, /close
  CLOSE, 2

  END

