; read the grid emission data and plot 
@./color_contour.pro
@./set_legend.pro
@./plot_emission_subroutine.pro
; read the grid emission data

  m = 70
  n = 100


 ; time = 1L
 ; stime = ' '
 ; Infprefix = 'smoke_goes_'
 ; openr, 2, 'filename.txt'
 ; while ( not eof(2) ) do begin
  ; readf, 2, time, format=('(I12)')
  ;time = 200304301800
 ;  readf, 2, stime
   ;print, 'stime = ', stime
 
 
   dir = '/home/bruce/data/smoke/smoke_goes2005/smoke_goes_2005_monthly/'
;   dir = '/home/bruce/program/fortran/smoke/f90/'
  filename1 = dir + 'monthly_emission_200505_lat'
  filename2 = dir + 'monthly_emission_200505_lon'
  filename3 = dir + 'monthly_emission_200505_emission'
  
  READCOL, filename1, F = 'F', lat
  nlat = FLTARR(m, n)
  FOR j = 0, n-1 DO BEGIN
    FOR i = 0, m-1 DO BEGIN
      k = j*m + i
      nlat(i,j) = lat(k)
    ENDFOR
  ENDFOR
 
  ;PRINT, nlat
  READCOL, filename2, F = 'F', lon
  nlon = FLTARR(m, n)
  FOR j = 0, n-1 DO BEGIN
    FOR i = 0, m-1 DO BEGIN
      k = j*m + i
      nlon(i,j) = lon(k)
    ENDFOR
  ENDFOR

  READCOL, filename3, F = 'F', emission
  nemission = FLTARR(m, n)
  FOR j = 0, n-1 DO BEGIN
    FOR i = 0, m-1 DO BEGIN
      k = j*m + i
      nemission(i,j) = emission(k)
    ENDFOR
  ENDFOR

  ;PRINT, 'MAIN AA : ', emission
  semission = SORT(nemission) 
  FOR i = 0, n*m-1 DO BEGIN
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
  device, filename ='plot_emission_monthly_200505_v2' + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

;  if ( strmid(stime,8,2)  eq '18' or  strmid(stime,8,2) eq '18'  ) then begin

  plot_emission_subroutine, lat, lon, emission/(1e6), stime

;  endif

;  endwhile
  device, /close
  close,2
  
  END
; specify the minimam and maximum of color bar
;  bar_min = 3000
;  bar_max = 33000

; color bar coordinate
;  xa = 0.125 & ya    = 0.9
;  dx = 0.05  & dy    = 0.00
; ddx = 0.0   & ddy   = 0.03
;dddx = 0.05  & dddy  = -0.047
;dirinx = 0   & extrachar = 'Kg'

; color bar levels
;  n_levels = 12

; labelformat
;  FORMAT = '(f10.1)'

; region
;  region = [minlat, minlon, maxlat, maxlon]

; title
;  title = 'SMOKE EMISSION JAN/2001'

;set_plot, 'ps'
;device, filename = 'monthly_emission_200101.ps', xsize=7, ysize=10, $
;        xoffset=0.5, yoffset=0.5, /inches,/color
;!p.thick=3 
;!p.charthick=3
;!p.charsize=1.2 
;
;color_contour, nlat, nlon, nemission, maxemi, minemi, $
;                  n_levels , region, $
;                  xa, dx, ddx, dddx, $
;                 ya, dy, ddy, dddy, FORMAT, dirinx, extrachar, title

;device, /close


;END



; APPENDIX
; plot map over the interested region
  


;  PLOT, [minlon, maxlon], [minlat, maxlat], /nodata, $
;        xrange = [minlon, maxlon], yrange = [minlat, maxlat], $
;        xtitle = '!6LONGITUDE (DEG)', ytitle = '!6LATITUDE (DEG)', $
;	xthick=1,xticks=3, xminor=10, $
;	position= [0.10, 0.31, 0.85, 0.77], $
;	ythick=1, charsize=1.4, charthick=1, xstyle=1, ystyle=1, $
;	color = 1
  

;  MAP_SET, midlat, midlon, /cylindrical, /horizon, $
;           limit = [minlat, minlon, maxlat, maxlon], $
;	   xmargin = [2, 2], ymargin = [2, 4], $
;           color = 1
;
; plot emission data
  
;  image = MAP_IMAGE(nemission, minlon, minlat, compress = 1, $
;                    latmin = minlat, lonmin = minlon,     $
;		    latmax = maxlat, lonmax = maxlon )
;  rimage = ROTATE(image, 1)
;  TVSCL, rimage, minlon, minlat, xsize = 20, ysize = 20 
;  MAP_CONTINENTS
;  MAP_CONTINENTS, /usa, /countries, color =1
;  MAP_GRID, /box, latdel = 5, londel = 5, color = 1


; set legend
 
;  END
