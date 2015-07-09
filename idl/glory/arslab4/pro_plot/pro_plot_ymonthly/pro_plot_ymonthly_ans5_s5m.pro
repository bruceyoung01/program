
; purpose of this program : calculate the MODIS LST difference between l5 and anl5

  n = 11
  m = 7000 
  filedir  = '/home/bruce/data/modis/arslab4/results/as5lst/as5lst_monthly/'
  filelist = '04as5lstlist'
  date     = '04as5lst'

  filedir1  = '/home/bruce/data/modis/arslab4/results/ans5lst/ans5lst_monthly/'
  filelist1 = '04ans5lstlist'
  date1     = '04ans5lst'

  filedirres = '/home/bruce/data/modis/arslab4/results/plot/monthly/'


  maxlat = 30.
  minlat = 10.
  maxlon = -65. 
  minlon = -115.
  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  filename = STRARR(n)
  READCOL, filedir + filelist, F = 'A', filename

  filename1 = STRARR(n)
  READCOL, filedir1 + filelist1, F = 'A', filename1

  lat = FLTARR(m)
  lon = FLTARR(m)
  lst = FLTARR(m)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  
  ;lun = 97
  t_month = FLTARR(m,n)
  FOR i = 0, n-1 DO BEGIN
    OPENR, lun, filedir + filename(i), /get_lun
    FOR j = 0, m-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmplst
      ;PRINT, 'LST : ', i, tmplst
      lat(j) = tmplat
      lon(j) = tmplon
      lst(j) = tmplst
      t_month(j, i) = tmplst
    ENDFOR
    FREE_LUN, lun
  ENDFOR


  OPENW, lun, filedir + date, /get_lun
  ncount = INTARR(m)
  tmean  = FLTARR(m)
  FOR j = 0, m-1 DO BEGIN
      index = WHERE(t_month(j, 0:n-1) gt 0.0, count)
      IF (count gt 0) THEN BEGIN
      tmean(j) = mean(t_month[j,index])
      ncount(j)= count
      PRINTF, lun, lat(j), lon(j), tmean(j), ncount(j)
      ENDIF ELSE BEGIN
      PRINTF, lun, lat(j), lon(j), tmean(j), ncount(j)
      ENDELSE
  ENDFOR
  FREE_LUN, lun


  OPENR, lun, filedir + date, /get_lun
  grid_lat = FLTARR(gridsize_lat, gridsize_lon)
  grid_lon = FLTARR(gridsize_lat, gridsize_lon)
  grid_lst = FLTARR(gridsize_lat, gridsize_lon)
  grid_c   = FLTARR(gridsize_lat, gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  tmpc   = 0
  FOR i = 0, gridsize_lat-1 DO BEGIN
   FOR j = 0, gridsize_lon-1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst, tmpc
    grid_lat(i,j) = tmplat
    grid_lon(i,j) = tmplon
    grid_lst(i,j) = tmplst
    grid_c(i, j)  = tmpc
   ENDFOR
  ENDFOR
  FREE_LUN, lun

  OPENR, lun, filedir1 + date1, /get_lun
  grid_lat1 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lon1 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lst1 = FLTARR(gridsize_lat, gridsize_lon)
  grid_c1   = FLTARR(gridsize_lat, gridsize_lon)
  tmplat1 = 0.0
  tmplon1 = 0.0
  tmplst1 = 0.0
  tmpc1   = 0
  FOR i = 0, gridsize_lat-1 DO BEGIN
   FOR j = 0, gridsize_lon-1 DO BEGIN
    READF, lun, tmplat1, tmplon1, tmplst1, tmpc1
    grid_lat1(i,j) = tmplat1
    grid_lon1(i,j) = tmplon1
    grid_lst1(i,j) = tmplst1
    grid_c1(i, j)  = tmpc1
   ENDFOR
  ENDFOR
  FREE_LUN, lun

  d_grid_lst = grid_lst - grid_lst1
  SET_PLOT, 'ps'
  DEVICE, filename =filedirres + 'plot_' + STRMID(date, 0, 13) + 's5_ans5m.ps', xsize = 7.5, ysize=9, $
          xoffset = 1, yoffset = 1, /inches, /color, bits=8
  MYCT, /BuWhRd,ncolors = 233, /midc
  TVMAP, transpose(d_grid_lst), /grid,$
         LIMIT=[minlat, minlon, maxlat-0.5, maxlon-0.5], /ISOTROPIC, /sample, $
         title = 'MODIS LST Difference(Total-Fire Free) AOD<0.5 April (2000-2010)', $
         /cbar,DIVISIONS = 5, maxdata = 0.1, mindata = -0.1, FORMAT='(F6.2)' ,$
         CBMIN = -0.1, CBMAX = 0.1, /COUNTRIES, /COAST, $
         MIN_VALID = -0.1, MAX_VALID = 0.1
  XYOUTS, 7.5, 3.14, 'K', color = 1

  DEVICE, /close

  END

