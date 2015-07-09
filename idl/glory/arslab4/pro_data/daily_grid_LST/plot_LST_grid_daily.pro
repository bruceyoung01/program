@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST/subroutine/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST/subroutine/plot_emission_subroutine.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST/subroutine/sub_LST_grid.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST/subroutine/process_day.pro


; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.

; specify the directory and file name list 
  filedir     = '/mnt/sdc/data/modis/arslab4/mod11/2009/'
  filelist    = '200904lstlist_aflnn'
  filedirres  = '/home/bruce/data/modis/arslab4/results/1/'

; read the file name.
  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  PRINT, 'Nday : ', Nday
  PRINT, 'StartInx : ', StartInx
  PRINT, 'EndInx : ', EndInx
  PRINT, 'TimeS : ', TimeS
  PRINT, 'TimeE : ', TimeE
  PRINT, 'Dayname : ', Dayname
  PRINT, 'DAYNUM : ', DAYNUM

; specify the number of pixels through cross and swath
; the range of study area
; maxlat : maximum of latitude
; minlat : minimum of latitude
; maxlon : maximum of longitude
; minlon : minimum of longitude
  np = 1354L
  nl = 2030L
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

; the number of boxes(0.5*0.5) along latitude and longitude
; CEIL : The CEIL function returns the closest integer greater than or equal to its argument. 
  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)
  meanlst  = FLTARR(gridsize_lon,gridsize_lat)

; calculate the latitude of boxes
  FOR i = 0, gridsize_lat-1 DO BEGIN
    grid_lat(i) = minlat + 0.5*i
  ENDFOR
  PRINT, grid_lat
  HELP, grid_lat

; calculate the longitude of boxes
  FOR i = 0, gridsize_lon-1 DO BEGIN
    grid_lon(i) = minlon + 0.5*i
  ENDFOR
  PRINT,grid_lon
  HELP, grid_lon

; read the name of day
  FOR j = 0, Nday-1 DO BEGIN
  n = endinx(j) - startinx(j) + 1
  date = STRARR(n)
  FOR nc = 0, n-1 DO BEGIN
  date(nc) = STRMID(Allfilename(startinx(j)), 0, 17)
  ENDFOR

  OPENW, lun, filedirres + date(0), /get_lun
  filename = Allfilename(startinx(j):endinx(j))
  zcount = 0

; calculate the average LST in one 0.5*0.5 degree box
  date_slat = STRARR(n)
  date_slon = STRARR(n)
  date_slst = STRARR(n)
  lat = FLTARR(np*n, nl*(n+1))
  lon = FLTARR(np*n, nl*(n+1))
  lst = FLTARR(np*n, nl*(n+1))
  PRINT, 'AAAA'
  FOR i = 0L, n-1 DO BEGIN
    sub_read_mod11, filedir, filename(i), np, nl, rlat, rlon, rlst, rqc
    brqc = BINARY(rqc)
    lat((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlat(0:(np-1), 0:(nl-1))
    lon((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlon(0:(np-1), 0:(nl-1))
    lst((np*i):(np*(i+1)-1), (nl*i):(nl*(i+1)-1)) = rlst(0:(np-1), 0:(nl-1))
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
           PRINTF, lun, grid_lat(k), grid_lon(l), meanlst(l,k), ccount
         ENDFOR
       ENDFOR

  FREE_LUN, lun
  ENDFOR

END
