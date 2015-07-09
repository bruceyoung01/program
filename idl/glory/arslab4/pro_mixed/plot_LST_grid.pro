

; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.

  filedir   = '/home/bruce/data/modis/arslab4/mod11/2000/'
  filename  = 'MOD11_L2.A2000131.1720.005.2007184183413.hdf'
  date      = strmid(filename, 37, 21)

  sub_read_mod11, filedir, filename, np, nl, rlat, rlon, lst
  ;PRINT, lst

  rlat = congrid(rlat, np, nl, /interp)
  rlon = congrid(rlon, np, nl, /interp)

  maxlat = max(rlat)
  minlat = min(rlat)
  maxlon = max(rlon)
  minlon = min(rlon)

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)
  
  imaxlat = minlat + 0.5*gridsize_lat
  imaxlon = minlon + 0.5*gridsize_lon

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

  OPENW, lun, date, /get_lun

  FOR k = 28, gridsize_lat-1 DO BEGIN
    FOR l =0, gridsize_lon-1 DO BEGIN
      tmplst = 0.0
      count  = 0
      FOR i = 0, np-1 DO BEGIN
        FOR j = 0, nl-1 DO BEGIN
          ;PRINT, 'AAA : ', i, j, rlat(i,j)
          IF (rlat(i,j) ge grid_lat(k)-0.25   and $
              rlat(i,j) le grid_lat(k)+0.25 and $
              rlon(i,j) ge grid_lon(l)-0.25   and $
              rlon(i,j) le grid_lon(l)+0.25 and $
              lst(i,j) gt 0.0 ) THEN BEGIN

            ;PRINT, 'BBBBB : ',lst(i,j)
            tmplst = tmplst + lst(i,j)
            count = count + 1
          ENDIF
        ENDFOR
      ENDFOR
      IF (count ne 0) THEN BEGIN
      PRINT, 'CCCCCC : ', count
      PRINT, 'DDDDDD : ', tmplst
      meanlst(l,k) = tmplst/count
      PRINT, grid_lat(k), grid_lon(l), meanlst(l,k)
      PRINTF, lun, grid_lat(k), grid_lon(l), meanlst(l,k)
      ENDIF
    ENDFOR
  ENDFOR
  CLOSE, lun

  SET_PLOT, 'ps'
  DEVICE, filename ='plot_' + date + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8


  plot_emission_subroutine, grid_lat, grid_lon, meanlst, date

  DEVICE, /close
  CLOSE, 2

  END

