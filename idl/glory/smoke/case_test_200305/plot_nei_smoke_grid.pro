; purpose of this program : plot the raw emission data of NEI05 and NEI05+smoke emission


@/home/bruce/program/idl/smoke/plot_emission_subroutine_nei_smoke_grid.pro
@./color_contour.pro
@./set_legend.pro

  filedir    = '/home/bruce/data/smoke/nei_05/area4k_plus08/HR23/'
  filename   = 'PM25-PRI_ini'
  filenamea  = 'PM25-PRI'
  output     = strmid(filedir, 44, 4)
  PRINT, output
  filedir1   = '/home/bruce/data/smoke/nei_05/grid_loc/'
  filename1  = 'LAT_xrs.txt'
  filename2  = 'LON_xrs1.txt'

  nx = 12
  ny = 111888

  OPENR, lun, filedir + filename, /get_lun
  pm25 = FLTARR(nx,ny)
  READF, lun, pm25
  CLOSE, lun

  OPENR, lun, filedir + filenamea, /get_lun
  pm25a = FLTARR(nx,ny)
  READF, lun, pm25a
  CLOSE, lun
  
  OPENR, lun, filedir1 + filename1, /get_lun
  lat = FLTARR(nx,ny)
  READF, lun, lat
  CLOSE, lun

  OPENR, lun, filedir1 + filename2, /get_lun
  lon = FLTARR(nx,ny)
  READF, lun, lon
  CLOSE, lun
  
; calculate the difference between with emission data and without emission data
  pm25d = pm25a - pm25
  ;PRINT, pm25d

  SET_PLOT, 'ps'
  DEVICE, filename ='plot_NEI_SMOKE' + output + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
    
  plot_emission_subroutine_nei_smoke_grid, lat, lon, pm25a, stime, output
  
  DEVICE, /close
  CLOSE,2 


END
