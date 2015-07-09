; read the grid emission data and plot 

; read the grid emission data

  m = 100
  n = 70
  
  dir = '/home/bruce/data/smoke/smoke_goes2001/smoke_goes_2001_daily/'
  filename1 = dir + 'daily_emission_20010101_lat'
  filename2 = dir + 'daily_emission_20010101_lon'
  filename3 = dir + 'daily_emission_20010101_emission'


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
  map_set, midlat, midlon, limit = [minlat, minlon, maxlat, maxlon], $
           color = 1
  map_continents, color =1
  map_grid

; plot emission data
  

  contour, emission, lat, lon, color = 1, $
           title = 'FLAMBE SMOKE EMISSION'


  end
