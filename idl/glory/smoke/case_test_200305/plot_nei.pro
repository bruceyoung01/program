; purpose of this program : plot the raw emission data of NEI05 and NEI05+smoke emission

@/home/bruce/idl/Williwaw/task/superior/MOD11T/set_legend.pro
@/home/bruce/program/idl/arslab4/color_contour.pro

  filedir    = '/home/bruce/data/smoke/nei_05/area4k/HR20/'
  filename   = 'PM25-PRI'
  filenamea  = 'PM25-PRIA'
  output     = strmid(filedir, 37, 4)
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
; define the max and min for your color bar 
; make your own choice here
maxvalue= 0.001
minvalue= 0

; color bar coordinate
    xa = 0.125       &   ya = 0.9
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.03
      dddx = 0.05    &   dddy = -0.047
      dirinx = 0     &   extrachar='   ton/hr'
; color bar levels
n_levels = 12

;labelformat
FORMAT = '(f8.4)' 

; region
region = [min(lat)-2, min(lon)-2, max(lat)+2, max(lon)+2]
;region =[45.2, -93, 50.5, -83]
;region =[10, -115, 45, -65]


; title
title = ' SMOKE EMISSION'

set_plot, 'ps'
device, filename =  output + filename + 'D.ps', xsize=7, ysize=10, $
        xoffset=0.5, yoffset=0.5, /inches,/color, bits = 8
!p.thick=3
!p.charthick=3
!p.charsize=1.2

color_contour, lat, lon, pm25d, maxvalue, minvalue, $
                  N_Levels , region, $
                  xa, dx, ddx, dddx, $
                  ya, dy, ddy, dddy, FORMAT, dirinx, extrachar, title
device, /close


END
