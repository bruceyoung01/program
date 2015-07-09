

; purpose of this program : calculate and plot the day with average MODIS LST>315K with AOD<0.5 (Total)

@/home/bruce/program/idl/arslab4/pro_plot/pro_plot_monthly/plot_emission_subroutine_LST_grid_monthly_plot_fs5.pro

  n = 30
  m = 7000

  filedir  = '/home/bruce/data/modis/arslab4/results/2003/'
  filelist = '200304as5lstlist'
  date     = '200304as5lst'
  
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.
  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)
  grid_lst     = FLTARR(gridsize_lat, gridsize_lon)

  filename = STRARR(n)
  READCOL, filedir + filelist, F = 'A', filename   

  lat = FLTARR(m)
  lon = FLTARR(m)
  lst = FLTARR(m)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0

  t_month = FLTARR(m,n)
  FOR i = 0, n-1 DO BEGIN
    OPENR, lun, filedir + filename(i), /get_lun
    FOR j = 0, m-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmplst
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
      index = WHERE(t_month(j, 0:n-1) gt 315.0, count)
      IF (count gt 0) THEN BEGIN
      tmean(j) = mean(t_month[j,index])
      PRINT, tmean(j)
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

  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + STRMID(date, 0, 13) + 's5_day.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, 15,ncolors = 333, /rev
  TVMAP, transpose(grid_c), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, /sample, $
         title = 'Day Total LST>315K and AOD<0.5 ' + STRMID(date(0), 0, 6),$
         /cbar,DIVISIONS = 6, maxdata = 10, mindata = 0, FORMAT='(I3)' ,$
         CBMIN = 0, CBMAX = 10, /COUNTRIES, /COAST, $
         MIN_VALID = 0, MAX_VALID = 10
  XYOUTS, 7.9, 1.985, 'Day', color = 1

  DEVICE, /close

  END

