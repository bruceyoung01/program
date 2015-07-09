@/home/bruce/program/idl/arslab4/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/plot_emission_subroutine.pro
@/home/bruce/program/idl/arslab4/sub_LST_grid.pro
@/home/bruce/program/idl/arslab4/process_day.pro


; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.
  
  filedir     = '/home/bruce/data/modis/arslab4/mod11/2003/'
  filelist    = '2003lstlist22'

  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  PRINT, 'Nday : ', Nday
;  PRINT, 'AllFileName : ', AllFileName
  PRINT, 'StartInx : ', StartInx
  PRINT, 'EndInx : ', EndInx
  PRINT, 'TimeS : ', TimeS
  PRINT, 'TimeE : ', TimeE
  PRINT, 'Dayname : ', Dayname
  PRINT, 'DAYNUM : ', DAYNUM


;  OPENR, lun, filedir + filename, /get_lun
;  READF, lun, mod11name
;  CLOSE, lun

  np = 1354L
  nl = 2030L
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.2)
  gridsize_lon = CEIL((maxlon-minlon)/0.2)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)
  meanlst  = FLTARR(gridsize_lon,gridsize_lat)

  FOR i = 0, gridsize_lat-1 DO BEGIN
    grid_lat(i) = minlat + 0.2*i
  ENDFOR
  PRINT, grid_lat
  HELP, grid_lat

  FOR i = 0, gridsize_lon-1 DO BEGIN
    grid_lon(i) = minlon + 0.2*i
  ENDFOR
  PRINT,grid_lon
  HELP, grid_lon

  FOR j = 0, Nday-1 DO BEGIN
  n = endinx(j) - startinx(j) + 1
  date = STRARR(n)
  FOR nc = 0, n-1 DO BEGIN
  date(nc) = STRMID(Allfilename(startinx(j)), 0, 17)
  ENDFOR

  OPENW, lun, date(0), /get_lun
  filename = Allfilename(startinx(j):endinx(j))
  zcount = 0

  date_slat = STRARR(n)
  date_slon = STRARR(n)
  date_slst = STRARR(n)
  lat = FLTARR(np*n, nl*n)
  lon = FLTARR(np*n, nl*n)
  lst = FLTARR(np*n, nl*n)
  PRINT, 'AAAA'
  FOR i = 0L, n-1 DO BEGIN
    ;IF (date(i) eq date(i+1)) THEN BEGIN
    ;   zcount = zcount + 1
    ;ENDIF
    sub_read_mod11, filedir, filename(i), np, nl, rlat, rlon, rlst
    lat((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlat(0:(np-1), 0:(nl-1))
    lon((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlon
    lst((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlst
  ENDFOR

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            tmplst = 0.0
            ccount = 0
            index01 = where(lat ge grid_lat(k)-0.1 $
                        and lat le grid_lat(k)+0.1 $
                        and lon ge grid_lon(l)-0.1 $
                        and lon le grid_lon(l)+0.1 $
                        and lst  gt 0.0, ccount )

           IF (ccount gt 0) THEN BEGIN
           meanlst(l,k) = mean(lst[index01])
           ENDIF ELSE BEGIN
           meanlst(l,k) =  0
           ENDELSE
           PRINTF, lun, grid_lat(k), grid_lon(l), meanlst(l,k), ccount
         ENDFOR
       ENDFOR

  CLOSE, lun
  ENDFOR
END
