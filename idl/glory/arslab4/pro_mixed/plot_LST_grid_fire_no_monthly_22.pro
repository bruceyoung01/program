; purpose of this program : plot the LST with fire
@/home/bruce/program/idl/arslab4/plot_emission_subroutine_LST_fire_no_monthly_22.pro


  filedir  = '/home/bruce/data/modis/arslab4/results/2003/'
  filename = '200304nlst22'
  filename1= '200304lst22' 
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

  gridsize_lat = CEIL((maxlat-minlat)/0.2)
  gridsize_lon = CEIL((maxlon-minlon)/0.2)
  grid_lst     = FLTARR(gridsize_lat*gridsize_lon)

  OPENR, lun, filedir + filename, /get_lun
  grid_lat1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lon1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lst1 = FLTARR(gridsize_lat*gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  FOR i = 0L, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst
    grid_lat1(i) = tmplat
    grid_lon1(i) = tmplon
    grid_lst1(i) = tmplst
  ENDFOR
  CLOSE, lun

  OPENR, lun1, filedir + filename1, /get_lun
  grid_lat2 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lon2 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lst2 = FLTARR(gridsize_lat*gridsize_lon)
  tmplat2 = 0.0
  tmplon2 = 0.0
  tmplst2 = 0.0
  FOR i = 0L, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun1, tmplat2, tmplon2, tmplst2
    grid_lat2(i) = tmplat2
    grid_lon2(i) = tmplon2
    grid_lst2(i) = tmplst2
  ENDFOR
  CLOSE, lun1

  grid_lst = grid_lst1 - grid_lst2

  sgrid_lst = WHERE(grid_lst gt 0.0, nsgrid_lst)
  ;PRINT, grid_lst(sgrid_lst)
  ;PRINT, 'DDDDD : ', grid_lst
  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + filename + '_d22v.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  plot_emission_subroutine_LST_fire_no_monthly_22, grid_lat1, grid_lon1,  maxlat, minlat, maxlon, minlon, grid_lst, filename

  DEVICE, /close
  CLOSE, 2

  END

