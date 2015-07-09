

; purpose of this program : calculate and plot the monthly average MODIS LST with AOD<0.2

@/home/bruce/program/idl/arslab4/pro_plot/pro_plot_monthly/plot_emission_subroutine_LST_grid_monthly_plot_s2.pro

  n = 14
  m = 7000
  filedir  = '/home/bruce/data/modis/arslab4/results/2010/'
  filelist = '201004as2lstlist'
  date     = '201004as2lst'    
  
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

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


  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + date + 's2.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  plot_emission_subroutine_LST_grid_monthly_plot_s2, lat, lon,  maxlat, minlat, maxlon, minlon, tmean, date

  DEVICE, /close
  CLOSE, 2

  END

