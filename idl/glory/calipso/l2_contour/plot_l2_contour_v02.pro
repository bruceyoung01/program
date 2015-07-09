

; purpose of this program : plot the CALIPSO Lidar Level 1 data

@./read_hdf_l2_aerprf.pro
@./sub/color_contour.pro
@./sub/process_day.pro

  filedir = '/mnt/sdb/data/CALIPSO/2008/CALIPSO/data/CAL_LID_L2_05kmAPro-Prov-V3-01/'
  filelist = '2008CAL_LID_L2_05kmAPro-Prov-V3-01'
  fileres = '/mnt/sdb/data/CALIPSO/2008/CALIPSO/data/result/CAL_LID_L2_05kmAPro-Prov-V3-01/'


  process_day, filedir + filelist, filename

  nfile = 1
  FOR k = 0, nfile-1 DO BEGIN
  read_hdf_l2_aerprf, filedir, filename(k), lat, lon, alt, aod, kext_532,tbks
  ttbks = TRANSPOSE(tbks)

  np = N_ELEMENTS(alt)
  nl = N_ELEMENTS(aod)
  minvalue = 0.0
  maxvalue = 0.0006
  n_levels = 12
  nlon = 11

  xlon = FLTARR(nlon)
  slon = STRARR(nlon)
  alat = FLTARR(nl)
  alon = FLTARR(nl)
  FOR i = 0L, nl-1 DO BEGIN
    alat(i) = lat(0,i)
    alon(i) = lon(0,i)
  ENDFOR
  
  ilon = -1
  FOR j = 5, 50, 5 DO BEGIN
    index = WHERE(alat gt j-0.0015 and alat lt j+0.0015, count)
    IF(count gt 0) THEN BEGIN
      ilon = ilon+1
      PRINT, 'ILON', ilon
      a = alon(index)
      xlon(ilon) = a(0)
      PRINT, a
    ENDIF
  ENDFOR

  slon = STRING(xlon, FORMAT = '(F7.2)')

; color bar coordinate
  xa = 0.125      &  ya = 0.9
  dx = 0.05       &  dy = 0.00
  ddx = 0.0       &  ddy = 0.03
  dddx = 0.05     &  dddy = -0.047
  dirinx = 0      &  extrachar = 'T'

; label format
  FORMAT = '(f6.4)'

; title
; time
  title = STRMID(filename(k), 0, 52)
  time  = STRMID(filename(k), 31, 19)
  
; region
  region = [-2.0, 10.0, 30.0, 45.0]
  

; set regions
  xl = region(1)
  xr = region(3)
  yb = region(0)
  yt = region(2)

; processing values
     minresult = WHERE( ttbks lt minvalue, mincount)
     maxresult = WHERE( ttbks gt maxvalue, maxcount)

     ntbks = 2+(ttbks - minvalue)/(maxvalue - minvalue) * N_levels
     if (mincount gt 0 ) then ntbks(minresult)=1
     if (maxcount gt 0) then ntbks(maxresult) = N_levels+2

; contour plot
  levels = FINDGEN(n_levels+2)+1

; plot the profile
  SET_PLOT, 'ps'
  DEVICE, filename =fileres + '/' + title + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, 33, ncolors =  180, range = [0.0, 1]

  CONTOUR, ntbks, alat, alt, nlevels=N_levels+2,  $
        xrange=[xl, xr], yrange=[yb, yt],  /fill, $
        levels=levels,$
        c_colors=FIX(ntbks*10),xstyle=1, ystyle=1, color=1, $
        ytitle='!6Altitude (km) ', $
        position= [0.0775, 0.2575, 0.9035, 0.8725], $
        xthick=3, $
        ythick=3, charsize=1.2, charthick=3, $
        title = '!6 532nm Total Backscatter Coefficient '+ time + '!c!c!c'
  XYOUTS, 7, -3.5, 'lat', color = 1, charsize=1.2, charthick = 3
  XYOUTS, 7, -5.0, 'lon', color = 1, charsize=1.2, charthick = 3
  FOR i = 1, nlon-2 DO BEGIN
  XYOUTS, i*5+4.5, -5, slon(i), color = 1, charsize=1.2, charthick = 3
  ENDFOR
  COLORBAR, Position=[0.1275, 0.1075, 0.8535, 0.1425], Bottom=20, NColors=180, $
           Divisions=6, Minor=0, YTicklen=1, Range=[0,1], $
           /Right, Format='(I3)'

; set legend
;  set_legend, minvalue, maxvalue, n_levels, , $
;                xa, dx, ddx, dddx, $
;                ya, dy, ddy, dddy, FORMAT, dirinx, extrachar

  DEVICE, /close 

  ENDFOR  
END
