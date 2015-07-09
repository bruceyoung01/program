@/home/bruce/program/idl/arslab4/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/sub_read_mod14.pro
@/home/bruce/program/idl/arslab4/sub_read_mod14_judge.pro
@/home/bruce/program/idl/arslab4/process_day.pro
@/home/bruce/program/idl/arslab4/process_day_fire.pro



; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.
  
  filedir     = '/home/bruce/data/modis/arslab4/mod11/2003/'
  filelist    = '2003lstlist_case'
  ffiledir    = '/home/bruce/data/modis/arslab4/mod14/2003/'
  ffilelist   = '2003firelist_case' 
  filedirres  = '/home/bruce/data/modis/arslab4/results/2003/'

  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  process_day_fire, ffiledir + ffilelist, fNday, fAllFileName, fStartInx, fEndInx, $
                  YEAR= fyear, Mon= fmon, Date= fDate, TimeS = fTimeS, $
                  TimeE = fTimeE, fDayname, fDAYNUM

  PRINT, 'Nday : ', fNday
;  PRINT, 'AllFileName : ', AllFileName
  PRINT, 'StartInx : ', fStartInx
  PRINT, 'EndInx : ', fEndInx
  PRINT, 'TimeS : ', fTimeS
  PRINT, 'TimeE : ', fTimeE
  PRINT, 'Dayname : ', fDayname
  PRINT, 'DAYNUM : ', fDAYNUM


;  OPENR, lun, filedir + filename, /get_lun
;  READF, lun, mod11name
;  CLOSE, lun

  np = 1354
  nl = 2030
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.1)
  gridsize_lon = CEIL((maxlon-minlon)/0.1)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)
  meanlst  = FLTARR(gridsize_lon,gridsize_lat)

  FOR i = 0, gridsize_lat-1 DO BEGIN
    grid_lat(i) = minlat + 0.1*i
  ENDFOR
  PRINT, grid_lat
  HELP, grid_lat

  FOR i = 0, gridsize_lon-1 DO BEGIN
    grid_lon(i) = minlon + 0.1*i
  ENDFOR
  PRINT,grid_lon
  HELP, grid_lon

  FOR j = 0, Nday-1 DO BEGIN
  n = endinx(j) - startinx(j) + 1
  date = STRARR(n)
  FOR nc = 0, n-1 DO BEGIN
  date(nc) = STRMID(Allfilename(startinx(j)), 0, 17)
  ENDFOR

  lun = 95
  lun1= 96
  OPENW, lun, filedirres + 'lst_' + date(0)+ '_11', /get_lun
  filename = Allfilename(startinx(j):endinx(j))

  OPENW, lun1, filedirres + 'fire_' + date(0)+ '_11', /get_lun
  ffilename= fAllfilename(fstartinx(j):fendinx(j))
  
  date_slat = STRARR(n)
  date_slon = STRARR(n)
  date_slst = STRARR(n)
  ;lat = FLTARR(5000, 50000)
  ;lon = FLTARR(5000, 50000)
  ;lst = FLTARR(5000, 50000)
  lat = FLTARR(np, nl*(n+1))
  lon = FLTARR(np, nl*(n+1))
  lst = FLTARR(np, nl*(n+1))
  firelat = FLTARR(5000, 5000)
  firelon = FLTARR(5000, 5000)
  firelst = FLTARR(5000, 5000)
  nfire_total = 0
  ;firecount = INTARR(gridsize_lon,gridsize_lat)
  ;ccount    = INTARR(gridsize_lon,gridsize_lat)

  PRINT, 'AAAA'
  FOR i = 0, n-1 DO BEGIN
    PRINT, 'IIII : ', i
    sub_read_mod11, filedir, filename(i), np, nl, rlat, rlon, rlst
    sub_read_mod14_judge, ffiledir, ffilename(i), fire_mask
    nfire = WHERE (fire_mask ge 7, firecount)
    PRINT, 'FIRE COUNT : ', firecount
    IF (firecount gt 0) THEN BEGIN
    sub_read_mod14, ffiledir, ffilename(i), nfire, flat, flon, fire_sample, fire_line
    nfire_total = nfire_total + nfire
    FOR ni = 0, nfire-1 DO BEGIN
      firelat((nfire_total+ni): (nfire_total+(ni+1)-1), (nfire_total+ni): (nfire_total+(ni+1)-1)) = rlat(fire_sample(ni),fire_line(ni))
      firelon((nfire_total+ni): (nfire_total+(ni+1)-1), (nfire_total+ni): (nfire_total+(ni+1)-1)) = rlon(fire_sample(ni),fire_line(ni))
      firelst((nfire_total+ni): (nfire_total+(ni+1)-1), (nfire_total+ni): (nfire_total+(ni+1)-1)) = rlst(fire_sample(ni),fire_line(ni))
      ;PRINT, 'BBBBBCCCCCC : ', firelst((nfire_total*ni): (nfire_total*(ni+1)-1), (nfire_total*ni): (nfire_total*(ni+1)-1))
      rlst(fire_sample(ni),fire_line(ni)) = 0.0
    ENDFOR
      lat(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlat
      lon(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlon
      lst(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlst
    ENDIF ELSE BEGIN
      lat(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlat
      lon(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlon
      lst(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlst
    ENDELSE
    ;PRINT,'CCCCCC : ', firelst
  ENDFOR

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            tmplst = 0.0
            firecount = 0
            index01 = where(lat ge grid_lat(k)-0.05 $
                        and lat le grid_lat(k)+0.05 $
                        and lon ge grid_lon(l)-0.05 $
                        and lon le grid_lon(l)+0.05 $
                        and lst  gt 0.0, firecount )

           IF (firecount gt 0) THEN BEGIN
           meanlst(l,k) = mean(lst[index01])
           ENDIF ELSE BEGIN
           meanlst(l,k) =  0
           ENDELSE
           PRINTF, lun, grid_lat(k), grid_lon(l), meanlst(l,k), firecount
         ENDFOR
       ENDFOR

  FREE_LUN, lun


        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            tmplst = 0.0
            ccount = 0
            index01 = where(firelat ge grid_lat(k)-0.05 $
                        and firelat le grid_lat(k)+0.05 $
                        and firelon ge grid_lon(l)-0.05 $
                        and firelon le grid_lon(l)+0.05 $
                        and firelst  gt 0.0, ccount )

           IF (ccount gt 0) THEN BEGIN
           meanlst(l,k) = mean(firelst[index01])
           ENDIF ELSE BEGIN
           meanlst(l,k) =  0
           ENDELSE
           PRINTF, lun1, grid_lat(k), grid_lon(l), meanlst(l,k), ccount
         ENDFOR
       ENDFOR

  FREE_LUN, lun1
  ENDFOR

END
