

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; purpose of this program : read and plot the NOAA and FLAMBE emission data
;                           calculate and plot their difference. (grid)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  month = 4
  day   = 1
  time  = 23

; set the directory of NOAA fire emission and FLAMBE fire emission
  filedir  = '/home/bruce/data/smoke/results/noaa_flambe/'
  nfiledir = '/mnt/sdc/data/noaa/fire/data/'
  FOR iyear = 2003, 2003 DO BEGIN
   siyear = STRTRIM(iyear, 1)
   ffiledir = '/mnt/sdc/data/smoke/smoke_goes' + siyear +'/'
   FOR jl = 1, 365 DO BEGIN
    sjl = STRING(jl, FORMAT = '(I3.3)')
    yjl = iyear*1000d + jl
    ymd = DATE_CONV(yjl, 'F')
    jimonth = FIX(STRMID(ymd, 5, 2))
    ;PRINT, jimonth
   ENDFOR
   FOR imonth = 4, month DO BEGIN
    tmpc = 0
    simonth = STRING(imonth, FORMAT = '(I2.2)')
    nfilename = siyear + '-fire-filt-' + simonth + '_fited_name11h3_LST_ascii'

; open two file to save the same location of fire emission of NOAA and FLAMBE
  OPENW, lun1, filedir + siyear + simonth + 'flambe_v03', /get_lun
  OPENW, lun2, filedir + siyear + simonth + 'noaa_v03', /get_lun

; read the NOAA fire emission
  nn_lines = FILE_LINES(nfiledir + nfilename)
  tmpnfile = READ_ASCII(nfiledir + nfilename)
  nfile = tmpnfile.(0)

; read the FLAMBE fire emission
  ffilename = STRARR(time, day)
  FOR iday = 1, day DO BEGIN
  num = 0
  siday = STRING(iday, FORMAT = '(I2.2)')
  jday  = YMD2DN(iyear, imonth, iday)
  sjday = STRING(jday, FORMAT = '(I3.3)')
  FOR i = 0, nn_lines-1 DO BEGIN
  IF(nfile(3, i) eq jday) THEN BEGIN
   PRINTF, lun2, nfile(1, i), nfile(0, i), nfile(52, i), nfile(54, i), nfile(56, i), nfile(58, i)
  ENDIF
  ENDFOR

  FOR itime = 1, time DO BEGIN
  sitime = STRING(itime, FORMAT = '(I2.2)')
  ffilename(itime-1, iday-1) = 'smoke_goes_' + siyear + simonth + siday + sitime + '00'
  nf_lines = FILE_LINES(ffiledir + ffilename(itime-1, iday-1))
  IF (nf_lines ne 0) THEN BEGIN
  tmpffile = READ_ASCII(ffiledir + ffilename(itime-1, iday-1))
  ffile = tmpffile.(0)

  FOR i = 0, nf_lines-1 DO BEGIN
   PRINTF, lun1, ffile(0, i), ffile(1,i), ffile(5,i), ffile(6,i)
  ENDFOR
  ENDIF
  ENDFOR   ;end for itime
  ENDFOR   ;end for iday
  FREE_LUN, lun1
  FREE_LUN, lun2

; read the file of the differences bwtween the NOAA fire emission and FLAMBE fire emission
  nfa_lines = FILE_LINES(filedir + siyear + simonth + 'flambe_v03')
  lat_flambe = FLTARR(nfa_lines)
  lon_flambe = FLTARR(nfa_lines)
  fire_area  = FLTARR(nfa_lines)
  fire_flambe= FLTARR(nfa_lines)
  OPENR, luna, filedir + siyear + simonth + 'flambe_v03', /get_lun
  FOR i = 0, nfa_lines-1 DO BEGIN
  tmplat_flambe = 0.0
  tmplon_flambe = 0.0
  tmpfire_flambe= 0.0
  READF, luna, tmplat_flambe, tmplon_flambe, tmpfire_flambearea, tmpfire_flambeflux
  lat_flambe(i) = tmplat_flambe
  lon_flambe(i) = tmplon_flambe
  fire_area(i)  = tmpfire_flambearea
  fire_flambe(i)= tmpfire_flambearea*tmpfire_flambeflux
  ENDFOR
  FREE_LUN, luna

  nna_lines = FILE_LINES(filedir + siyear + simonth + 'noaa_v03')
  lat_noaa = FLTARR(nna_lines)
  lon_noaa = FLTARR(nna_lines)
  fire_noaatarea = FLTARR(nna_lines)
  fire_noaa54= FLTARR(nna_lines)
  fire_noaa56= FLTARR(nna_lines)
  fire_noaa56emi = FLTARR(nna_lines)
  fire_noaa58= FLTARR(nna_lines)
  OPENR, lunb, filedir + siyear + simonth + 'noaa_v03', /get_lun
  FOR i = 0, nna_lines-1 DO BEGIN
  tmplat_noaa = 0.0
  tmplon_noaa = 0.0
  tmpfire_noaatarea = 0.0
  tmpfire_noaa54= 0.0
  tmpfire_noaa56= 0.0
  tmpfire_noaa58= 0.0
  READF, lunb, tmplat_noaa, tmplon_noaa, tmpfire_noaatarea, tmpfire_noaa54, tmpfire_noaa56, tmpfire_noaa58
  lat_noaa(i) = tmplat_noaa
  lon_noaa(i) = tmplon_noaa
  fire_noaatarea(i) = tmpfire_noaatarea
  fire_noaa54(i)= tmpfire_noaa54
  fire_noaa56(i)= tmpfire_noaa56
  fire_noaa58(i)= tmpfire_noaa58
  ENDFOR
  FREE_LUN, lunb

; calculate the grid of 0.5*0.5 degree
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)

  FOR i = 0, gridsize_lat-1 DO BEGIN
    grid_lat(i) = minlat + 0.5*i
  ENDFOR
  PRINT, grid_lat
  HELP, grid_lat

  FOR i = 0, gridsize_lon-1 DO BEGIN
    grid_lon(i) = minlon + 0.5*i
  ENDFOR
  PRINT,grid_lon
  HELP, grid_lon

  OPENW, lun5, filedir + siyear + simonth + 'flambe_grid_v03', /get_lun
  OPENW, lun6, filedir + siyear + simonth + 'noaa_grid_v03', /get_lun
  
  grid_fire_flambe = FLTARR(gridsize_lat, gridsize_lon)
  grid_fire_noaa = FLTARR(gridsize_lat, gridsize_lon)
        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            ccount = 0
            index01 = where(lat_flambe ge grid_lat(k)-0.25 $
                        and lat_flambe le grid_lat(k)+0.25 $
                        and lon_flambe ge grid_lon(l)-0.25 $
                        and lon_flambe le grid_lon(l)+0.25 $
                        and fire_flambe gt 0.0, ccount )
           IF(ccount gt 0) THEN BEGIN
           grid_fire_flambe(k, l) = TOTAL(fire_flambe(index01))
           PRINTF, lun5, grid_lat(k), grid_lon(l), grid_fire_flambe(k, l), ccount
           ENDIF ELSE BEGIN
           PRINTF, lun5, grid_lat(k), grid_lon(l), grid_fire_flambe(k, l), ccount
           ENDELSE
         ENDFOR
       ENDFOR
  FREE_LUN, lun5


        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l = 0, gridsize_lon-1 DO BEGIN
            ccount2 = 0
            index02 = where(lat_noaa ge grid_lat(k)-0.25 $
                        and lat_noaa le grid_lat(k)+0.25 $
                        and lon_noaa ge grid_lon(l)-0.25 $
                        and lon_noaa le grid_lon(l)+0.25 $
                        and fire_noaa56 gt 0.0, ccount2 )
           IF(ccount2 gt 0) THEN BEGIN
           grid_fire_noaa(k, l) = TOTAL(fire_noaa56(index02))
           PRINTF, lun6, grid_lat(k), grid_lon(l), grid_fire_noaa(k, l), ccount2
           ENDIF ELSE BEGIN
           PRINTF, lun6, grid_lat(k), grid_lon(l), grid_fire_noaa(k, l), ccount2
           ENDELSE
         ENDFOR
       ENDFOR
  FREE_LUN, lun6

  agrid_fire_flambe = FLTARR(gridsize_lat*gridsize_lon)
  agrid_fire_noaa = FLTARR(gridsize_lat*gridsize_lon)
  FOR k = 0, gridsize_lat-1 DO BEGIN
   FOR l = 0, gridsize_lon-1 DO BEGIN
   agrid_fire_flambe(k*gridsize_lon + l) = grid_fire_flambe(k, l)
   agrid_fire_noaa(k*gridsize_lon + l)   = grid_fire_noaa(k, l)
   ENDFOR
  ENDFOR

;  re_flambe_noaa = REGRESS(fire_flambeemi, fire_noaa56emi, SIGMA = sigma, CONST = const, CORRELATION = correlation)
  re_flambe_noaa = REGRESS(agrid_fire_flambe, agrid_fire_noaa, SIGMA = sigma, CONST = const, CORRELATION = correlation)
  PRINT, 'Regress : ', re_flambe_noaa
  PRINT, 'Constant : ', const
  PRINT, 'Correlation : ', correlation
  cre_flambe_noaa = STRMID(STRING(re_flambe_noaa), 6, 4)
  cconst = STRMID(STRING(const), 4, 8)
  ccorrelation = STRMID(STRING(correlation), 5, 4)
  ;cscount = STRMID(STRING(scount), 10, 2)

; plot the scatter plot of the NOAA fire emission and FLAMBE fire emission

  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + siyear + simonth + '_flambe_noaa_scatter_v03.ps', /portrait, xsize = 5.5, ysize=6, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  MyCt, /Verbose, /WhGrYlRd
  PLOT, grid_fire_flambe, grid_fire_noaa, psym = sym(1), symsize = 0.5, color = 1;, $
        ;xrange = [0, 30000], yrange = [0, 30000]

  DEVICE, /close

; plot the fire emission map of FLAMBE
  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + siyear + simonth + '_flambe.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, /BuWhRd, ncolors = 233 
  TVMAP, transpose(grid_fire_flambe), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, /sample, $
         title = 'Fire Emission (FLAMBE)  ' + siyear + simonth + siday, $
         /cbar,DIVISIONS = 5, maxdata = 10000, mindata = 0, $
         CBMIN = 0, CBMAX = 10000, /COUNTRIES, /COAST, $
         MIN_VALID = 0.1, MAX_VALID = 10000.1, FORMAT='(I6)'
  XYOUTS, 7.5, 1.6, 'kg/h', color = 1
  
  DEVICE, /close

; plot the fire emission map of NOAA
  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + siyear + simonth + '_noaa.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, /BuWhRd, ncolors = 233  
  TVMAP, transpose(grid_fire_noaa), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, /sample, $
         title = 'Fire Emission (NOAA)  ' + siyear + simonth + siday, $
         /cbar,DIVISIONS = 5, maxdata = 10000, mindata = 0, $
         CBMIN = 0, CBMAX = 10000, /COUNTRIES, /COAST, $
         MIN_VALID = 0.1, MAX_VALID = 10000.1, FORMAT='(I6)'
  XYOUTS, 7.5, 1.6, 'kg/h', color = 1

  DEVICE, /close

; set plot for the differences bwtween the NOAA fire emission and FLAMBE fire emission in grid of 0.5*0.5 degree
; read the file of the differences bwtween the NOAA fire emission and FLAMBE fire emission
  nd_lines = FILE_LINES(filedir + siyear + simonth + 'flambe_noaa')
  lat = FLTARR(nd_lines)
  lon = FLTARR(nd_lines)
  dfn = FLTARR(nd_lines)
  OPENR, lun4, filedir + siyear + simonth + 'flambe_noaa', /get_lun
  FOR i = 0, nd_lines-1 DO BEGIN
  tmplat = 0.0
  tmplon = 0.0
  tmpdfn = 0.0
  READF, lun4, tmplat, tmplon, tmpdfn
  lat(i) = tmplat
  lon(i) = tmplon
  dfn(i) = tmpdfn
  ENDFOR
  FREE_LUN, lun4

; open a new file to save the grid of the differences bwtween the NOAA fire emission $
; and FLAMBE fire emission in grid of 0.5*0.5 degree
  OPENW, lun5, filedir + siyear + simonth + 'flambe_noaa_grid', /get_lun

; calculate the grid of 0.5*0.5 degree
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)

  FOR i = 0, gridsize_lat-1 DO BEGIN
    grid_lat(i) = minlat + 0.5*i
  ENDFOR
  PRINT, grid_lat
  HELP, grid_lat

  FOR i = 0, gridsize_lon-1 DO BEGIN
    grid_lon(i) = minlon + 0.5*i
  ENDFOR
  PRINT,grid_lon
  HELP, grid_lon

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            tmpdfn1 = 0.0
            ccount = 0
            index01 = where(lat ge grid_lat(k)-0.25 $
                        and lat le grid_lat(k)+0.25 $
                        and lon ge grid_lon(l)-0.25 $
                        and lon le grid_lon(l)+0.25 $
                        , ccount )
           IF(ccount gt 0) THEN BEGIN
           tmpdfn1 = TOTAL(dfn(index01))
           PRINTF, lun5, grid_lat(k), grid_lon(l), tmpdfn1, ccount
           ENDIF ELSE BEGIN
           PRINTF, lun5, grid_lat(k), grid_lon(l), tmpdfn1, ccount
           ENDELSE
         ENDFOR
       ENDFOR
  FREE_LUN, lun5

; plot the grid fire emission difference between NOAA and FLAMBE
  OPENR, lun6, filedir + siyear + simonth + 'flambe_noaa_grid', /get_lun
  grid_lat1 = FLTARR(gridsize_lat, gridsize_lon)
  grid_lon1 = FLTARR(gridsize_lat, gridsize_lon)
  grid_dfn1 = FLTARR(gridsize_lat, gridsize_lon)
  grid_count= FLTARR(gridsize_lat, gridsize_lon)
  FOR i = 0, gridsize_lat-1 DO BEGIN
   FOR j = 0, gridsize_lon-1 DO BEGIN
   tmplat1 = 0.0
   tmplon1 = 0.0
   tmpdfn1 = 0.0
   tmpc1   = 0
   READF, lun6, tmplat1, tmplon1, tmpdfn1, tmpc1
   grid_lat1(i,j) = tmplat1
   grid_lon1(i,j) = tmplon1
   grid_dfn1(i,j) = tmpdfn1
   grid_count(i,j)= tmpc1
   ENDFOR
  ENDFOR
  FREE_LUN, lun6

  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + siyear + simonth + '_flambe_noaa.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, /BuWhRd, ncolors = 233
  TVMAP, transpose(grid_dfn1), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, /sample, $
         title = 'Fire Emission Difference (FLAMBE - NOAA)  ' + siyear + simonth + siday,$
         /cbar,DIVISIONS = 5, maxdata = 10000, mindata = -10000, $
         CBMIN = 10000, CBMAX = 10000, /COUNTRIES, /COAST, $
         MIN_VALID = -10000.1, MAX_VALID = 10000.1, FORMAT='(I6)'
  XYOUTS, 7.5, 1.6, 'k', color = 1

  DEVICE, /close

  ENDFOR   ;end for imonth
  ENDFOR   ;end for iyear
END
