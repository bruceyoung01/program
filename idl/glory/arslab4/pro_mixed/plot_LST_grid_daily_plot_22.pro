

; purpose of this program : plot the monthly average MODIS LST 

@/home/bruce/program/idl/arslab4/plot_emission_subroutine_LST_grid_monthly_plot_22.pro

  n = 30
  m = 43750L
  filedir  = '/home/bruce/data/modis/arslab4/results/2003/'
  filelist = '200304lstlist22'
  date     = '200304lst'    
  
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

  FOR i = 0, n-1 DO BEGIN
    OPENR, lun, filedir + filename(i), /get_lun
    FOR j = 0L, m-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmplst
      lat(j) = tmplat
      lon(j) = tmplon
      lst(j) = tmplst
    ENDFOR
    FREE_LUN, lun

    SET_PLOT, 'ps'
    DEVICE, filename =filedir + filename(i) + '_lst_22.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

    plot_emission_subroutine_LST_grid_monthly_plot_22, lat, lon,  maxlat, minlat, maxlon, minlon, lst, date

    DEVICE, /close
    CLOSE, 2

  ENDFOR

  END

