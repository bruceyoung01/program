; read the grid emission data and plot 

; read the grid emission data

  m = 1
  n = 3
  
  dir = '/home/bruce/program/idl/arslab4/'
  filename1 = dir + 'MOD14.A2000366.1655.005.2006342072113.hdf_lat.txt'
  filename2 = dir + 'MOD14.A2000366.1655.005.2006342072113.hdf_lon.txt'
  filename3 = dir + 'MOD14.A2000366.1655.005.2006342072113.hdf_fire.txt'


  openr, lun, filename1, /get_lun
  lat = fltarr(m, n)
  readu, lun, lat
  close
  print, lat(0,*)


  openr, lun, filename2, /get_lun
  lon = fltarr(m, n)
  readu, lun, lon
  close

  openr, lun, filename3, /get_lun
  emission = fltarr(m, n)
  readu, lun, emission
  close
  help, emission

; plot map over the interested region
  
  minlat = min(lat(*))
  maxlat = max(lat(*))
  minlon = min(lon(*))
  maxlon = max(lon(*))
  midlat = (minlat + maxlat)/2.
  midlon = (minlon + maxlon)/2.
  PRINT, midlat
  PRINT, midlon
  map_set, midlat, midlon, limit = [15.0, -95.0, 25, -85], $
           color = 1
  map_continents, color =1
  map_grid

; plot emission data
  

  contour, emission, lat, lon, color = 1, $
           title = 'FLAMBE SMOKE EMISSION'


  end
