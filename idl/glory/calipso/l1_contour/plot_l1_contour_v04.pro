

; purpose of this program : plot the CALIPSO Lidar Level 1 data

@./read_hdf_l1.pro
@./sub/color_contour.pro
@./sub/process_day.pro

  filedir = '/media/disk/data/calipso/seas_small/2006/CAL_LID_L1-ValStage1-V3-01/'
  filelist = 'CAL_LID_L1-ValStage1-V3-01_10D'
  fileres = '/mnt/sdb/data/CALIPSO/2006/seas/CAL_LID_L1-ValStage1-V3-01/'


  process_day, filedir + filelist, filename

  nfile = 36
  FOR k = 0, nfile-1 DO BEGIN
  read_hdf_l1, filedir, filename(k), num, lat, lon, alt, tbks, ttmp, pratio, datetime
  ttbks = TRANSPOSE(tbks)

  np = N_ELEMENTS(alt) 
  nl = num
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


; label format
  FORMAT = '(f6.4)'

; title
; time
  title = STRMID(filename(k), 0, 48)
  time  = STRMID(filename(k), 27, 19)
  
; region
  region = [95.0, -10.0, 125.0, 10.0]
  

; set regions
  xl = region(1)
  xr = region(3)
  yb = region(0)
  yt = region(2)

; processing values
     minresult = where ( ttbks lt minvalue, mincount)
     maxresult = where ( ttbks gt maxvalue, maxcount)

     ntbks = 2+(ttbks - minvalue)/(maxvalue - minvalue) * N_levels
     if (mincount gt 0 ) then ntbks(minresult)=1
     if (maxcount gt 0) then ntbks(maxresult) = N_levels+2

; contour plot
  levels = findgen(n_levels+2)+1

; plot the profile
  SET_PLOT, 'ps'
  DEVICE, filename =fileres + '/' + title + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  MyCt, 33

  CONTOUR, ntbks, lat, alt, nlevels=N_levels+2,  $
        xrange=[xl, xr], yrange=[yb, yt],  /fill, $
        levels=levels,$
        c_colors=FIX(ntbks),xstyle=1, ystyle=1, color=16, $
        ytitle='!6Altitude (km) ', $
        position= [0.0775, 0.3075, 0.9035, 0.8725], $
        xthick=3, $
        ythick=3, charsize=1.2, charthick=3, $
        title = '!6 532nm Total Attenuated Backscatter '+ time + '!c!c!c'
  XYOUTS, 7, -3.5, 'lat', color = 16, charsize=1.2, charthick = 3
  XYOUTS, 7, -5, 'lon', color = 16, charsize=1.2, charthick = 3
  FOR i = 1, nlon-2 DO BEGIN
  XYOUTS, i*5+4.5, -5, slon(i), color = 16, charsize=1.2, charthick = 3
  ENDFOR
  COLORBAR, Position=[0.32, 0.65, 0.65, 0.67], Bottom=20, NColors=230, $
           Divisions=6, Minor=0, YTicklen=1, Range=[0,1], $
           /Right, Format='(I3)'

; set legend
  set_legend, minvalue, maxvalue, n_levels , ccolors, $
                xa, dx, ddx, dddx, $
                ya, dy, ddy, dddy, FORMAT, dirinx, extrachar

  DEVICE, /close 

  ENDFOR  
END
