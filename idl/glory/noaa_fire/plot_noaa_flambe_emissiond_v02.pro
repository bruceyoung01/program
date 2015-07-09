

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; purpose of this program : read and plot the NOAA and FLAMBE emission data
;                           calculate and plot their difference.(time)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  month = 4
  day   = 1
  time  = 1 

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
  OPENW, lun1, filedir + siyear + simonth + 'noaa', /get_lun
  OPENW, lund, filedir + siyear + simonth + 'noaaemi', /get_lun
  OPENW, lun2, filedir + siyear + simonth + 'flambe', /get_lun
  OPENW, lun3, filedir + siyear + simonth + 'flambe_noaa', /get_lun

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
  FOR itime = 1, time DO BEGIN
  sitime = STRING(itime, FORMAT = '(I2.2)')
  ffilename(itime-1, iday-1) = 'smoke_goes_' + siyear + simonth + siday + sitime + '00'
  nf_lines = FILE_LINES(ffiledir + ffilename(itime-1, iday-1))
  IF (nf_lines ne 0) THEN BEGIN
  tmpffile = READ_ASCII(ffiledir + ffilename(itime-1, iday-1))
  ffile = tmpffile.(0)

; find the same day, longitude, latitude of the NOAA fire emission and FLAMBE fire emission
  ;num = 0
  FOR i = 0L, nn_lines-1  DO BEGIN
   PRINT, i, jday, nfile(3, i)
   IF(nfile(3, i) eq jday) THEN BEGIN
   tmpfire_noaah54 = 0.0
   tmpfire_noaah56 = 0.0
   tmpfire_noaah58 = 0.0
   IF(nfile((2*itime + 4), i) le 0.0 and nfile((2*itime + 5), i) le 0.0) THEN BEGIN
   ;GOTO, a
   ENDIF
   IF(nfile((2*itime + 4), i) gt 0.0 and nfile((2*itime + 5), i) gt 0.0) THEN BEGIN
    tmpfire_noaah54 = nfile(54, i)*((nfile((2*itime + 4), i) + nfile((2*itime + 5), i))/nfile(52, i))
    tmpfire_noaah56 = nfile(56, i)*((nfile((2*itime + 4), i) + nfile((2*itime + 5), i))/nfile(52, i))
    tmpfire_noaah58 = nfile(58, i)*((nfile((2*itime + 4), i) + nfile((2*itime + 5), i))/nfile(52, i))
   ENDIF
   IF(nfile((2*itime + 4), i) gt 0.0 and nfile((2*itime + 5), i) le 0.0) THEN BEGIN
    tmpfire_noaah54 = nfile(54, i)*((nfile((2*itime + 4), i))/nfile(52, i))
    tmpfire_noaah56 = nfile(56, i)*((nfile((2*itime + 4), i))/nfile(52, i))
    tmpfire_noaah58 = nfile(58, i)*((nfile((2*itime + 4), i))/nfile(52, i))
   ENDIF
   IF(nfile((2*itime + 5), i) gt 0.0 and nfile((2*itime + 4), i) le 0.0) THEN BEGIN
    tmpfire_noaah54 = nfile(54, i)*((nfile((2*itime + 5), i))/nfile(52, i))
    tmpfire_noaah56 = nfile(56, i)*((nfile((2*itime + 5), i))/nfile(52, i))
    tmpfire_noaah58 = nfile(58, i)*((nfile((2*itime + 5), i))/nfile(52, i))
   ENDIF
   FOR j = 0L, nf_lines-1  DO BEGIN
    IF(STRMID(nfile(0, i), 5, 5) eq STRMID(ffile(1, j), 5, 5) and $
       STRMID(nfile(1, i), 5, 5) eq STRMID(ffile(0, j), 5, 5)) THEN BEGIN
       PRINT, i, j, jday, nfile(3, i)
       PRINT, STRMID(nfile(0, i), 5, 5), STRMID(ffile(1, j), 5, 5)
       PRINT, STRMID(nfile(1, i), 5, 5), STRMID(ffile(0, j), 5, 5)
       PRINTF, lun1, nfile(1, i), nfile(0, i), nfile((2*itime + 4), i), nfile((2*itime + 5), i), nfile(52, i), nfile(56, i)
       PRINTF, lund, nfile(1, i), nfile(0, i), tmpfire_noaah54, tmpfire_noaah56, tmpfire_noaah58
       PRINTF, lun2, ffile(0, j), ffile(1, j), ffile(5, j), ffile(6, j), STRING(ffile(8, j), FORMAT = '(I8.4)')
; calculate the differences bwtween the NOAA fire emission and FLAMBE fire emission
       flambe_noaa = ffile(5, j)*ffile(6, j) - nfile(56, i)
       PRINTF, lun3, nfile(1, i), nfile(0, i), flambe_noaa
       ;PRINT, nfile(1, i), nfile(0, i), flambe_noaa
       num = num + 1
       PRINT, 'Number : ', num
    ENDIF
   ENDFOR
   ENDIF
  ENDFOR

  ENDIF
  ENDFOR   ;end for itime
  ENDFOR   ;end for iday
  FREE_LUN, lun1
  FREE_LUN, lund
  FREE_LUN, lun2
  FREE_LUN, lun3

; read the file of the differences bwtween the NOAA fire emission and FLAMBE fire emission
  nfa_lines = FILE_LINES(filedir + siyear + simonth + 'flambe')
  lat_flambe = FLTARR(nfa_lines)
  lon_flambe = FLTARR(nfa_lines)
  fire_flambe= FLTARR(nfa_lines)
  OPENR, luna, filedir + siyear + simonth + 'flambe', /get_lun
  FOR i = 0, nfa_lines-1 DO BEGIN
  tmplat_flambe = 0.0
  tmplon_flambe = 0.0
  tmpfire_flambe= 0.0
  READF, luna, tmplat_flambe, tmplon_flambe, tmpfire_flambearea, tmpfire_flambeflux
  lat_flambe(i) = tmplat_flambe
  lon_flambe(i) = tmplon_flambe
  fire_flambe(i)= tmpfire_flambearea*tmpfire_flambeflux
  ENDFOR
  FREE_LUN, luna

  fire_flambeemi= FLTARR(nfa_lines)
  OPENW, lunc, filedir + siyear + simonth + 'flambeemi', /get_lun
  FOR i = 0, nfa_lines-1 DO BEGIN
   c = 0
   index1 = WHERE(lat_flambe eq lat_flambe(i) and lon_flambe eq lon_flambe(i), c)
   fire_flambeemi(i) = TOTAL(fire_flambe(index1))
   PRINTF, lunc, lat_flambe(i), lon_flambe(i), fire_flambeemi(i)
  ENDFOR
  FREE_LUN, lunc

  nna_lines = FILE_LINES(filedir + siyear + simonth + 'noaaemi')
  lat_noaa = FLTARR(nna_lines)
  lon_noaa = FLTARR(nna_lines)
  fire_noaa54emi= FLTARR(nna_lines)
  fire_noaa56emi= FLTARR(nna_lines)
  fire_noaa58emi= FLTARR(nna_lines)
  OPENR, lunb, filedir + siyear + simonth + 'noaaemi', /get_lun
  FOR i = 0, nna_lines-1 DO BEGIN
  tmplat_noaa = 0.0
  tmplon_noaa = 0.0
  tmpfire_noaa54= 0.0
  tmpfire_noaa56= 0.0
  tmpfire_noaa58= 0.0
  READF, lunb, tmplat_noaa, tmplon_noaa, tmpfire_noaa54, tmpfire_noaa56, tmpfire_noaa58
  lat_noaa(i) = tmplat_noaa
  lon_noaa(i) = tmplon_noaa
  fire_noaa54emi(i)= tmpfire_noaa54
  fire_noaa56emi(i)= tmpfire_noaa56
  fire_noaa58emi(i)= tmpfire_noaa58
  ENDFOR
  FREE_LUN, lunb

  re_flambe_noaa = REGRESS(fire_flambeemi, fire_noaa56emi, SIGMA = sigma, CONST = const, CORRELATION = correlation)
  PRINT, 'Regress : ', re_flambe_noaa
  PRINT, 'Constant : ', const
  PRINT, 'Correlation : ', correlation
  cre_flambe_noaa = STRMID(STRING(re_flambe_noaa), 6, 4)
  cconst = STRMID(STRING(const), 4, 8)
  ccorrelation = STRMID(STRING(correlation), 5, 4)
  ;cscount = STRMID(STRING(scount), 10, 2)

; plot the scatter plot of the NOAA fire emission and FLAMBE fire emission

  SET_PLOT, 'ps'
  DEVICE, filename =filedir + 'plot_' + siyear + simonth + '_flambe_noaa_scatter.ps', /portrait, xsize = 5.5, ysize=6, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  PLOT, fire_flambeemi, fire_noaa56emi, psym = sym(1), symsize = 0.5, color = 1, $
        xrange = [0, 30000], yrange = [0, 30000]

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
