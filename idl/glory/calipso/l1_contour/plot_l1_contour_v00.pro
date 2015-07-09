

; purpose of this program : plot the CALIPSO Lidar Level 1 data

@./read_hdf_l1.pro
@./sub/color_contour.pro
@./read_hdf_l2_aerprf.pro


  filedir = '/mnt/sdb/data/CALIPSO/2009/CALIPSO/data/CAL_LID_L1-ValStage1-V3-01/'
  filename1 = 'CAL_LID_L1-ValStage1-V3-01.2009-04-30T23-31-50ZN.hdf'
  fileres = '/mnt/sdb/data/CALIPSO/2009/CALIPSO/data/result/CAL_LID_L1-ValStage1-V3-01/'

   read_hdf_l1, filedir, filename1, num, lat, lon, alt, tbks, ttmp, pratio
;  PRINT, 'LATITUDE : ', lat
;  PRINT, 'LONGITUDE : ', lon
;  PRINT, 'Spacecraft Altitude : ', alt
;  PRINT, 'Total_Attenuated_Backscatter_532 : ', tbks

  np = 583
  nl = 56220
  minvalue = 0.0
  maxvalue = 2
  n_levels = 12

; color bar coordinate
  xa = 0.125      &  ya = 0.9
  dx = 0.05       &  dy = 0.00
  ddx = 0.0       &  ddy = 0.03
  dddx = 0.05     &  dddy = -0.047
  dirinx = 0      &  extrachar = ' '

; label format
  FORMAT = '(f6.3)'

; title
  title = STRMID(filename1, 0, 52)

; region

  region = [-1.0, 25.0, 30.0, 40.0]
  
  ;lat = CONGRID(lat, np, nl)
  ;lon = CONGRID(lon, np, nl)

  alat = FLTARR(nl)
  FOR i = 0L, nl-1 DO BEGIN
    alat(i) = lat(0,i)
  ENDFOR


; plot the profile
  SET_PLOT, 'ps'
  DEVICE, filename =fileres + '/' + title + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8


  COLOR_CONTOUR,    alt, alat, tbks,       $
                    maxvalue, minvalue,    $
                    n_levels, region,      $
                    xa, dx, ddx, dddx,     $
                    ya, dy, ddy, dddy,     $
                    format, dirinx,        $
                    extrachar, title

  DEVICE, /close 
  
END
