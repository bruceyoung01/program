

; purpose of this program : plot the monthly average MODIS AOD

@/home/bruce/program/idl/arslab4/plot_emission_subroutine_AOD_grid_monthly_plot.pro

  n = 30
  m = 7000
  filedir  = '/home/bruce/data/modis/arslab4/results/2003/'
  filelist = '200304aod_list'
  date     = '200304aod'    
  
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  filename = STRARR(n)
  READCOL, filedir + filelist, F = 'A', filename   

  lat = FLTARR(m)
  lon = FLTARR(m)
  aod = FLTARR(m)
  tmplat = 0.0
  tmplon = 0.0
  tmpaod = 0.0
  count  = 0

  aod_month = FLTARR(m,n)
  FOR i = 0, n-1 DO BEGIN
    PRINT, filename(i)
    OPENR, lun, filedir + filename(i), /get_lun
    FOR j = 0, m-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmpaod, count
      lat(j) = tmplat
      lon(j) = tmplon
      aod(j) = tmpaod
      aod_month(j, i) = tmpaod
    ENDFOR
    FREE_LUN, lun
  ENDFOR


  OPENW, lun, filedir + date, /get_lun
  ncount = INTARR(m)
  aodmean  = FLTARR(m)
  FOR j = 0, m-1 DO BEGIN
      index = WHERE(aod_month(j, 0:n-1) gt 0.0, count)
      ;PRINT, 'TTTTT : ', index
      IF (count gt 0) THEN BEGIN
      aodmean(j) = mean(aod_month[j,index])
      ;PRINT, aodmean(j)
      ncount(j)= count
      ;PRINT,'AAAAAAA : ', lat(j), lon(j), tmean(j), ncount(j)
      PRINTF, lun, lat(j), lon(j), aodmean(j), ncount(j)
      ENDIF ELSE BEGIN
      ;PRINT,'BBB : ', lat(j), lon(j), tmean(j), ncount(j)
      PRINTF, lun, lat(j), lon(j), aodmean(j), ncount(j)
      ENDELSE
  ENDFOR
  FREE_LUN, lun


  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_200304_aod.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  plot_emission_subroutine_AOD_grid_monthly_plot, lat, lon,  maxlat, minlat, maxlon, minlon, aodmean, date

  DEVICE, /close
  CLOSE, 2

  END

