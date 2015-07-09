; read the grid emission data and plot 
@./color_contour.pro
@./set_legend.pro
@./plot_emission_subroutine_smoke_grid.pro


; read the grid emission data
  l = 7000
  m = 7
  n = 1000


  dir = '/home/bruce/data/smoke/smoke_goes2003/smoke_goes_2003_grid/'
  filename1 = 'grid_emission_20030510170'
  date =  strmid(filename1, 14, 12)
 
  ; read the data
  OPENR, lun, dir + filename1, /get_lun
  lat      = FLTARR(l)
  lon      = FLTARR(l)
  emission = FLTARR(l)
  tmplat   = 0
  tmplon   = 0
  tmpemission = 0

  FOR i = 0L, l-1 DO BEGIN
    READF, lun, tmplat, tmplon, tmpemission, FORMAT = '(F7.2, F7.2, F15.5)'
    lat(i) = tmplat
    lon(i) = tmplon
    emission(i) = tmpemission
    PRINT, i, lat(i), lon(i), emission(i)
  ENDFOR
  CLOSE, lun
  ;READCOL, filename1, F = 'F', lat
  nlat = FLTARR(m, n)
  FOR j = 0L, n-1 DO BEGIN
    FOR i = 0L, m-1 DO BEGIN
      k = j*m + i
      nlat(i,j) = lat(k)
    ENDFOR
  ENDFOR
 
  ;PRINT, nlat
  ;READCOL, filename2, F = 'F', lon
  nlon = FLTARR(m, n)
  FOR j = 0L, n-1 DO BEGIN
    FOR i = 0L, m-1 DO BEGIN
      k = j*m + i
      nlon(i,j) = lon(k)
    ENDFOR
  ENDFOR

  ;READCOL, filename3, F = 'F', emission
  nemission = FLTARR(m, n)
  FOR j = 0L, n-1 DO BEGIN
    FOR i = 0L, m-1 DO BEGIN
      k = j*m + i
      nemission(i,j) = emission(k)
    ENDFOR
  ENDFOR

  ;PRINT, 'MAIN AA : ', emission
  semission = SORT(nemission) 
  FOR i = 0L, n*m-1 DO BEGIN
      IF (semission(i) eq 0.0) THEN BEGIN
      ENDIF ELSE BEGIN
         minemi = semission(i)
      ENDELSE
  ENDFOR

  mminemi = -10
  maxemi = MAX(nemission)
  minlat = MIN(nlat(*,*))
  maxlat = MAX(nlat(*,*))
  minlon = MIN(nlon(*,*))
  maxlon = MAX(nlon(*,*))
  midlat = (minlat + maxlat)/2.
  midlon = (minlon + maxlon)/2.

  PRINT, 'MINIMAM OF EMISSION : ', minemi
  PRINT, 'MAXIMUM OF EMISSION : ', maxemi



  set_plot, 'ps'
  device, filename ='plot_' + date + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  plot_emission_subroutine, lat, lon, emission/(1e6), stime, date

  device, /close
  close,2


  
  END
