; purpose of this program : plot the monthly average LST without fire


  filedir  = '/home/bruce/data/modis/arslab4/results/2000/'
  filename = 'as5lst_MOD11_L2.A2000109'
  filename1= 'ans5lst_MOD11_L2.A2000109'
  filedirres  = '/home/bruce/data/modis/arslab4/results/plot/2000/'

  
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
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  FOR i = 0, gridsize_lat-1 DO BEGIN
   FOR j = 0, gridsize_lon-1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst
    grid_lat1(i,j) = tmplat
    grid_lon1(i,j) = tmplon
    grid_lst1(i,j) = tmplst
   ENDFOR
  ENDFOR
  FREE_LUN, lun

  OPENR, lun1, filedir + filename1, /get_lun
  grid_lat2 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lon2 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lst2 = FLTARR(gridsize_lat, gridsize_lon)
  tmplat2 = 0.0
  tmplon2 = 0.0
  tmplst2 = 0.0
  FOR i = 0, gridsize_lat-1 DO BEGIN
   FOR j = 0, gridsize_lon-1 DO BEGIN
    READF, lun1, tmplat2, tmplon2, tmplst2
    grid_lat2(i,j) = tmplat2
    grid_lon2(i,j) = tmplon2
    grid_lst2(i,j) = tmplst2
   ENDFOR
  ENDFOR
  FREE_LUN, lun1

  grid_lst = grid_lst1 - grid_lst2


  SET_PLOT, 'ps'
  DEVICE, filename =filedirres + 'plot_' + filename + '_ds5_ns5.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits = 8
  MYCT,/BuWhRd,ncolors = 233, /midc
  TVMAP, transpose(grid_lst), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, /sample, $
         ;title = 'LST(AOD>0.5-AOD<0.5) ' + STRMID(filename, 17, 7),$
         title = 'MODIS LST Difference(Total-Fire Free) AOD<0.5  April 19 2000', $
         /cbar,DIVISIONS = 5, maxdata = 0.05, mindata = -0.05, $
         CBMIN = -0.05, CBMAX = 0.05, /COUNTRIES, /COAST, $
         MIN_VALID = -0.05, MAX_VALID = 0.05
  XYOUTS, 8.5, 1.985, 'K', color = 1
              
  DEVICE, /close

  END

