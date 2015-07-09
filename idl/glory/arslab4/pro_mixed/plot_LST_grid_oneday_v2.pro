@/home/bruce/program/idl/arslab4/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/plot_emission_subroutine.pro
@/home/bruce/program/idl/arslab4/sub_LST_grid.pro
@/home/bruce/program/idl/arslab4/process_day.pro


; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.

  n = 5
  filedir     = '/home/bruce/data/modis/arslab4/mod11/2000/'
  filelist    = 'slist'

;  OPENR, lun, filedir + filelist, /get_lun
;  READF, lun, filename
;  CLOSE, lun
  filename = STRARR(n)
  READCOL, filedir + filelist, F = 'A', filename

  date = STRARR(n)
  For i = 0, n-1 DO BEGIN
  date(i) = STRMID(filename(i), 0, 17)
  ENDFOR

  np = 1354
  nl = 2030
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.
  date_slat = STRARR(n)
  date_slon = STRARR(n)
  date_slst = STRARR(n)

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)
  meanlst  = FLTARR(gridsize_lon,gridsize_lat)

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

  lat = FLTARR(np*n, nl*n)
  lon = FLTARR(np*n, nl*n)
  lst = FLTARR(np*n, nl*n)

  OPENW, lun, date(0), /get_lun
  zcount = 0
  FOR i = 0, n-2 DO BEGIN
    IF (date(i) eq date(i+1)) THEN BEGIN
       zcount = zcount + 1
    ENDIF
    sub_read_mod11, filedir, filename(i), np, nl, rlat, rlon, rlst
    lat((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlat(0:(np-1), 0:(nl-1))
    lon((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlon
    lst((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlst
  ENDFOR

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            tmplst = 0.0
            ccount = 0
            index01 = where(lat ge grid_lat(k)-0.25 $
                        and lat le grid_lat(k)+0.25 $
                        and lon ge grid_lon(l)-0.25 $
                        and lon le grid_lon(l)+0.25 $
                        and lst  gt 0.0, ccount )

           IF (ccount gt 0) THEN BEGIN
           meanlst(l,k) = mean(lst[index01])
           ENDIF ELSE BEGIN
           meanlst(l,k) =  0
           ENDELSE
           PRINTF, lun, grid_lat(k), grid_lon(l), meanlst(l,k)
         ENDFOR
       ENDFOR

  CLOSE, lun
  OPENR, lun, date, /get_lun
  grid_lat1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lon1 = FLTARR(gridsize_lat*gridsize_lon)
  grid_lst1 = FLTARR(gridsize_lat*gridsize_lon)
  tmplat = 0.0
  tmplon = 0.0
  tmplst = 0.0
  FOR i = 0, gridsize_lat*gridsize_lon - 1 DO BEGIN
    READF, lun, tmplat, tmplon, tmplst
    grid_lat1(i) = tmplat
    grid_lon1(i) = tmplon
    grid_lst1(i) = tmplst
  ENDFOR
  CLOSE, lun

  SET_PLOT, 'ps'
  DEVICE, filename ='plot_' + date + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  plot_emission_subroutine, grid_lat1, grid_lon1,  maxlat, minlat, maxlon, minlon, grid_lst1, date

  DEVICE, /close
  CLOSE, 2

  END

