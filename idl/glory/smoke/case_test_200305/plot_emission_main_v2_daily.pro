; read the grid emission data and plot 
@./color_contour.pro
@./set_legend.pro
@./plot_emission_subroutine.pro
; read the grid emission data

  l = 1342656
  m = 12
  n = 111888


 ; time = 1L
 ; stime = ' '
 ; Infprefix = 'smoke_goes_'
 ; openr, 2, 'filename.txt'
 ; while ( not eof(2) ) do begin
  ; readf, 2, time, format=('(I12)')
  ;time = 200304301800
 ;  readf, 2, stime
   ;print, 'stime = ', stime
 
 
  dir = '/home/bruce/data/smoke/smoke_goes2003/smoke_goes_2003_monthly/'
  filename1 = dir + 'grid_emission_200303'
  ;filename2 = dir + 'monthly_emission_200505_lon'
  ;filename3 = dir + 'monthly_emission_200505_emission'
  
  ; read the data
  OPENR, lun, filename1, /get_lun
  lat      = FLTARR(l)
  lon      = FLTARR(l)
  emission = FLTARR(l)
  tmplat   = 0
  tmplon   = 0
  tmpemission = 0

  FOR i = 0L, l-1 DO BEGIN
    READF, lun, tmplat, tmplon, tmpemission;, FORMAT = '(F10.5, F13.5, F15.5)'
    lat(i) = tmplat
    lon(i) = tmplon
    emission(i) = tmpemission
    ;PRINT, i, lat(i), lon(i), emission(i)
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
  device, filename ='plot_emission_monthly_200303_v2_daily' + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

;  if ( strmid(stime,8,2)  eq '18' or  strmid(stime,8,2) eq '18'  ) then begin

  plot_emission_subroutine, lat, lon, emission/(1e6), stime

;  endif

;  endwhile
  device, /close
  close,2


  
  END
