
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; purpose of this program : calculate and plot the grid frequency of LST>315K and AOD>0.5.      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  n = 11
  m = 7000
  filedir  = '/home/bruce/data/modis/arslab4/results/as2lst/as2lst_monthly/'
  filelist = '04as2lstlist'
  date     = '04as2lst'

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
  tmpc   = 0

  t_month = FLTARR(m,n)
  t_count = FLTARR(m,n)
  FOR i = 0, n-1 DO BEGIN
    OPENR, lun, filedir + filename(i), /get_lun
    FOR j = 0, m-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmplst, tmpc
      lat(j) = tmplat
      lon(j) = tmplon
      lst(j) = tmplst
      t_month(j, i) = tmplst
      t_count(j, i) = tmpc
    ENDFOR
    FREE_LUN, lun
  ENDFOR

  y_count = FLTARR(n)
  FOR i = 0, n-1 DO BEGIN
   c_lst = 0
   index1 = WHERE(t_month(*,i) gt 315, c_lst)
   y_count(i) = c_lst
  ENDFOR

  count = INTARR(n)
  years = INDGEN(n) + 2000
  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + date + '_as2_fq.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  MyCt, /Verbose, /WhGrYlRd
  PLOT, [years(0),years(0)], [count(0),y_count(0)], color = 1, $
        xrange = [1999, 2011], xminor = 1 ,xtitle = 'Year', $
        yrange = [0, 200], yminor = 2, ytitle = 'Frequency', $
        thick = 50.0, $
        title = 'Grid Frequency Total (LST>315K and AOD<0.2) April'
  FOR i = 1, n-1 DO BEGIN
  OPLOT, [years(i),years(i)], [count(i),y_count(i)], color = 1, $
         thick = 50.0
  ENDFOR

  DEVICE, /close

  END



