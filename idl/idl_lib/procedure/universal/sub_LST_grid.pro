
; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.

  PRO sub_LST_grid, filename, np, nl, rlat, rlon, lst, grid_lat1, grid_lon1, grid_meanlst1


  date      = strmid(filename, 0, 22)
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

  FOR k = 0, gridsize_lat-1 DO BEGIN
    FOR l =0, gridsize_lon-1 DO BEGIN
      tmplst = 0.0
      index01 = where(rlat ge grid_lat(k)-0.25 $
                  and rlat le grid_lat(k)+0.25 $
                  and rlon ge grid_lon(l)-0.25 $
                  and rlon le grid_lon(l)+0.25 $
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

  END

