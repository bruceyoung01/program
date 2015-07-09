
; purpose of this program : plot the relationship between Land Surface Temperature and fire number in 0.5*0.5 degree
;@/home/bruce/idl/IDLLIB/my-lib/oploterror.pro

  filedir  = '/home/bruce/data/modis/arslab4/results/afs2lst/afs2lst_monthly/'
  filename  = '04afs2lst'
  filedirres = '/home/bruce/data/modis/arslab4/results/plot/monthly/'

;  filename = STRARR(n)
;  READCOL, filedir + filelist, F = 'A', filename

;  date = STRARR(n)
;  For i = 0, n-1 DO BEGIN
  date = STRMID(filename, 0, 6)
;  ENDFOR

  n  = 20
  np = 1354
  nl = 2030
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)
  
  OPENR, lun, filedir + filename, /get_lun
  grid_lat1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lon1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lst1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_count= FLTARR(gridsize_lat*gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  tmpcount = 0
  FOR i = 0, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst, tmpcount
    grid_lat1(i) = tmplat
    grid_lon1(i) = tmplon
    grid_lst1(i) = tmplst
    grid_count(i)= tmpcount
  ENDFOR 
  FREE_LUN, lun

  stdfn   = FLTARR(n)
  firenum = INDGEN(n)
  meanlst = FLTARR(n)
  stdlst  = FLTARR(n)
  FOR i = 1, n-1 DO BEGIN
    fnindex = WHERE(grid_count eq i, ncount)
    IF(ncount GT 0)THEN BEGIN
    meanlst(i) = mean(grid_lst1(fnindex))
    stdlst(i)  = stddev(grid_lst1(fnindex))
    PRINT, meanlst(i), i
    ENDIF
  ENDFOR
  PRINT, '# of fire : ', i
  
  x = [306.24, 324.89]
  y = [0, 20]
  smf = WHERE(meanlst GT 0.0 AND firenum GT 0, scount)
  smeanlst = meanlst(smf)
  sfirenum = firenum(smf)
  re_mlst_fn = REGRESS(smeanlst, sfirenum, SIGMA = sigma, CONST = const, CORRELATION = correlation)
  PRINT, 'Regress : ', re_mlst_fn
  PRINT, 'Constant : ', const
  PRINT, 'Correlation : ', correlation
  cre_mlst_fn = STRMID(STRING(re_mlst_fn), 6, 4)
  cconst = STRMID(STRING(const), 5, 7)
  ccorrelation = STRMID(STRING(correlation), 5, 4)
  cscount = STRMID(STRING(scount), 10, 2)
  SET_PLOT, 'ps'
  DEVICE, filename =filedirres + 'plot_' + filename + '_firenum_f.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  MyCt, /Verbose, /WhGrYlRd
  PLOT, smeanlst, sfirenum, psym = sym(5), color = 1, symsize=1, $
        xrange = [290, 330], yrange = [0, 20], position = [0.1, 0.2, 0.9, 0.7], $
        title = 'Relationship between LST and fire number ' + date, $
        xtitle = 'Fire LST (K)', ytitle = 'Fire Number'
  OPLOT, x, y, color = 4
  OPLOTERROR, smeanlst, sfirenum, stdlst, stdfn, psym=1, color = 2, $
              HATLENGTH = 100, ERRCOLOR = 2
;  XYOUTS, 282,18, 'y = 1.8618x - 552.09', color = 1
;  XYOUTS, 282,16, 'R!u2!n = 0.5651', color = 1
  XYOUTS, 292,18, 'Y = ' + cre_mlst_fn + 'X ' + cconst, color = 1
  XYOUTS, 292,17, 'R = ' + ccorrelation, color = 1
  XYOUTS, 292,16, 'N = ' + cscount, color = 1

  DEVICE, /close
  CLOSE, 2

END
