
; purpose of this program : plot the relationship between Land Surface Temperature and fire number in 0.5*0.5 degree

  filedir     = '/home/bruce/data/modis/arslab4/results/ans5lst/ans5lst_monthly/'
  filedir1    = '/home/bruce/data/modis/arslab4/results/afs5lst/afs5lst_monthly/'
  filename    = '04ans5lst'
  filename1   = '04afs5lst'
  filedirres  = '/home/bruce/data/modis/arslab4/results/plot/monthly/'

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
  grid_count1= FLTARR(gridsize_lat*gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  tmpcount = 0
  FOR i = 0, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst, tmpcount
    grid_lat1(i) = tmplat
    grid_lon1(i) = tmplon
    grid_lst1(i) = tmplst
    grid_count1(i)= tmpcount
  ENDFOR 
  FREE_LUN, lun

  OPENR, lun, filedir1 + filename1, /get_lun
  grid_lat2 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lon2 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lst2 = FLTARR(gridsize_lat*gridsize_lon)
  grid_count= FLTARR(gridsize_lat*gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  tmpcount = 0
  FOR i = 0, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst, tmpcount
    grid_lat2(i) = tmplat
    grid_lon2(i) = tmplon
    grid_lst2(i) = tmplst
    grid_count(i)= tmpcount
  ENDFOR
  FREE_LUN, lun

  stdfn   = FLTARR(n)
  firenum = INDGEN(n)
  meanlst = FLTARR(n)
  stdlst  = FLTARR(n)
  lstcount= INTARR(n)
  FOR i = 0, n-1 DO BEGIN
    fnindex = WHERE(grid_count EQ i AND grid_lst1 GT 0.0 AND grid_lat1 LE 30.0, ncount)
    IF(ncount GT 0)THEN BEGIN
    meanlst(i) = mean(grid_lst1(fnindex))
    stdlst(i)  = stddev(grid_lst1(fnindex))
    lstcount(i)= ncount
    PRINT, meanlst(i), i
    ENDIF
  ENDFOR
  PRINT, '# of fire : ', i
  
  x = [-5, 20]
  y = [304.38, 311.88]
  smf = WHERE(meanlst GT 0.0, scount)
  smeanlst = meanlst(smf)
  sfirenum = firenum(smf)
  sstdlst  = stdlst(smf)
  slstcount= lstcount(smf)
  re_mlst_fn = REGRESS(sfirenum, smeanlst, SIGMA = sigma, CONST = const, CORRELATION = correlation)
  PRINT, 'Regress : ', re_mlst_fn
  PRINT, 'Constant : ', const
  PRINT, 'Correlation : ', correlation
  cre_mlst_fn = STRMID(STRING(re_mlst_fn), 5, 4)
  cconst = STRMID(STRING(const), 4, 8)
  ccorrelation = STRMID(STRING(correlation), 5, 4)
  cscount = STRMID(STRING(scount), 10, 2)
  SET_PLOT, 'ps'
  DEVICE, filename =filedirres + 'plot_' + filename + '_firenum_bgm_ca.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  MyCt, 33
  PLOT, x, y, psym = sym(1), color = 1, symsize=0.01, $
        xrange = [-1, 20], yrange = [290, 330], position = [0.1, 0.2, 0.9, 0.7], $
        title = 'Background LST and Fire Number(AOD<0.5) April (2000-2010) CA', $
        xtitle = 'Fire Number', ytitle = 'Background LST (K)'
  PLOTS, sfirenum, smeanlst, psym = sym(1), symsize = 1, color = FIX(slstcount + 10)
  OPLOT, x, y, color = 1
  OPLOTERROR, sfirenum, smeanlst, stdfn, sstdlst, psym=1, color = 2, $
              HATLENGTH = 200, ERRTHICK = 3, ERRCOLOR = 2
  XYOUTS, 10, 304, 'BLST = ' + cre_mlst_fn + 'FN +' + cconst, color = 1
  XYOUTS, 10, 302, 'R = ' + ccorrelation, color = 1
  XYOUTS, 10, 300, 'N = ' + cscount, color = 1
  XYOUTS, 13, 324.6, 'Grid #', color = 1

  COLORBAR, Position=[0.32, 0.65, 0.65, 0.67], Bottom=20, NColors=230, $
           Divisions=6, Minor=0, YTicklen=1, Range=[0,1], $
           /Right, Format='(I3)'

  OPLOTERROR, sfirenum, smeanlst, stdfn, sstdlst, psym=1, color = 2, $
              HATLENGTH = 200, ERRTHICK = 3, ERRCOLOR = 2

  DEVICE, /close
  CLOSE, 2

END
