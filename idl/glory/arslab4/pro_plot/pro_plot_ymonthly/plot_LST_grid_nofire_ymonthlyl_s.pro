; purpose of this program : plot the monthly average LST of fire


  filedir    = '/home/bruce/data/modis/arslab4/results/anl5lst/anl5lst_monthly/'
  filedir1   = '/home/bruce/data/modis/arslab4/results/ans2lst/ans2lst_monthly/'
  filename   = '04anl5lst'
  filename1  = '04ans2lst'
  filedirres = '/home/bruce/data/modis/arslab4/results/plot/monthly/'

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
  grid_lst     = FLTARR(gridsize_lat, gridsize_lon)

  OPENR, lun, filedir + filename, /get_lun
  grid_lat1 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lon1 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lst1 = FLTARR(gridsize_lat, gridsize_lon)
  ncount1   = FLTARR(gridsize_lat, gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  tmpcount1 = 0
  FOR i = 0, gridsize_lat-1 DO BEGIN
   FOR j = 0, gridsize_lon-1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst, tmpcount1
    grid_lat1(i,j) = tmplat
    grid_lon1(i,j) = tmplon
    grid_lst1(i,j) = tmplst
    ncount1(i,j)   = tmpcount1
   ENDFOR
  ENDFOR
  FREE_LUN, lun

  OPENR, lun1, filedir1 + filename1, /get_lun
  grid_lat2 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lon2 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lst2 = FLTARR(gridsize_lat, gridsize_lon)
  ncount2   = FLTARR(gridsize_lat, gridsize_lon)
  tmplat2 = 0.0
  tmplon2 = 0.0
  tmplst2 = 0.0
  tmpcount2 = 0
  FOR i = 0, gridsize_lat-1 DO BEGIN
   FOR j = 0, gridsize_lon-1 DO BEGIN
    READF, lun1, tmplat2, tmplon2, tmplst2, tmpcount2
    grid_lat2(i,j) = tmplat2
    grid_lon2(i,j) = tmplon2
    grid_lst2(i,j) = tmplst2
    ncount2(i,j)   = tmpcount2
   ENDFOR
  ENDFOR
  FREE_LUN, lun1

  grid_lst = grid_lst1 - grid_lst2

  ;PRINT, grid_lst(sgrid_lst)
  ;PRINT, 'DDDDD : ', grid_lst

  SET_PLOT, 'ps'
  DEVICE, filename =filedirres + 'plot_' + filename + '_dl5_s2.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits = 8
;  MYCT, 127, ncolors =  6580, range = [0.0, 0.929], /midc
;  MYCT, 63, ncolors =  580, range = [0.14, 0.77], /midc, /rev, /USE_CURRENT, /BRIGHT_COLORS
;  MYCT, 63, ncolors = 101, /midc, /rev
   MYCT,/BuWhRd,ncolors = 233, /midc
  TVMAP, transpose(grid_lst), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, /sample, $
         title = 'LST(AOD>0.5)-LST(AOD<0.2) Fire Pixel Free April(2000~2010)',$
         /cbar,DIVISIONS = 5, maxdata = 10, mindata = -10, $
         CBMIN = -10, CBMAX = 10, /COUNTRIES, /COAST, $
         MIN_VALID = -10.00001, MAX_VALID = 10.00001
  XYOUTS, 7.4, 1.985, 'K', color = 1
              
  DEVICE, /close

  END

