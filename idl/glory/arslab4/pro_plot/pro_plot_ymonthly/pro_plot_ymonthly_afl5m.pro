

; purpose of this program : calculate the monthly average LST without fire of 11 years (2000-2010)

; June 30, 2010



  n = 11
  m = 7000
  filedir  = '/home/bruce/data/modis/arslab4/results/afl5lst/afl5lst_monthly/'
  filelist = '04afl5lstlist'
  date     = '04afl5lst'

  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.
  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  filename = STRARR(n)
  READCOL, filedir + filelist, F = 'A', filename

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
  PRINT, 'T_MONTH : ', t_month

  OPENW, lun, filedir + date, /get_lun
  ncount = INTARR(m)
  tmean  = FLTARR(m)
  FOR j = 0, m-1 DO BEGIN
      index = WHERE(t_month(j, 0:n-1) gt 0.0, count)
      ;PRINT, 'TTTTT : ', index
      IF (count gt 0) THEN BEGIN
      tmean(j) = mean(t_month[j,index])
      PRINT, tmean(j)
      ncount(j)= count
      ;PRINT,'AAAAAAA : ', lat(j), lon(j), tmean(j), ncount(j)
      PRINTF, lun, lat(j), lon(j), tmean(j), ncount(j)
      ENDIF ELSE BEGIN
      ;PRINT,'BBB : ', lat(j), lon(j), tmean(j), ncount(j)
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

  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + STRMID(date, 0, 13) + 'fl5m.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, 33, ncolors = 333, /rev
  TVMAP, transpose(grid_lst), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, /sample, $
         title = 'MODIS LST With Fire  AOD>0.5 April (2000-2010)', $
         /cbar,DIVISIONS = 7, maxdata = 330, mindata = 300, FORMAT='(I3)' ,$
         CBMIN = 300, CBMAX = 330, /COUNTRIES, /COAST, $
         MIN_VALID = 300, MAX_VALID = 330.1
  XYOUTS, 7.5, 1.985, 'K', color = 1

  DEVICE, /close

  END


