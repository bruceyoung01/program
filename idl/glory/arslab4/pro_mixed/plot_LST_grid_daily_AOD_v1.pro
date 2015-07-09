@/home/bruce/program/idl/arslab4/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/sub_read_mod04.pro
@/home/bruce/program/idl/arslab4/process_day.pro
@/home/bruce/program/idl/arslab4/process_day_fire.pro



; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.
  
  filedir     = '/home/bruce/data/modis/arslab4/mod11/2003/'
  filelist    = '2003lstlist_case'
  afiledir    = '/home/bruce/data/modis/arslab4/mod04/2003/5min/'
  afilelist   = '2003aodlist_case'
  filedirres  = '/home/bruce/data/modis/arslab4/results/2003/aodlst/'


  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  process_day, afiledir + afilelist, aNday, aAllFileName, aStartInx, aEndInx, $
                  YEAR= ayear, Mon= amon, Date= aDate, TimeS = aTimeS, $
                  TimeE = aTimeE, aDayname, aDAYNUM

  PRINT, 'Nday : ', aNday
;  PRINT, 'AllFileName : ', AllFileName
  PRINT, 'StartInx : ', aStartInx
  PRINT, 'EndInx : ', aEndInx
  PRINT, 'TimeS : ', aTimeS
  PRINT, 'TimeE : ', aTimeE
  PRINT, 'Dayname : ', aDayname
  PRINT, 'DAYNUM : ', aDAYNUM


;  OPENR, lun, filedir + filename, /get_lun
;  READF, lun, mod11name
;  CLOSE, lun

  np = 1354
  nl = 2030
  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)
  meanlst  = FLTARR(gridsize_lon,gridsize_lat)
  meanlaodlst  = FLTARR(gridsize_lon,gridsize_lat)

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

  FOR j = 0, Nday-1 DO BEGIN
  n = endinx(j) - startinx(j) + 1
  date = STRARR(n)
  FOR nc = 0, n-1 DO BEGIN
  date(nc) = STRMID(Allfilename(startinx(j)), 0, 17)
  ENDFOR

  lun = 95
  lun1= 96
  OPENW, lun, filedirres + 'aodlstl5_' + date(0), /get_lun
  filename = Allfilename(startinx(j):endinx(j))

  OPENW, lun1, filedirres + 'aodlsts5_' + date(0), /get_lun
  afilename= aAllfilename(astartinx(j):aendinx(j))
  
  date_slat = STRARR(n)
  date_slon = STRARR(n)
  date_saod = STRARR(n)
  lat = FLTARR(np, nl*(n+1))
  lon = FLTARR(np, nl*(n+1))
  lst = FLTARR(np, nl*(n+1))
  aodlat = FLTARR(np, nl*(n+1))
  aodlon = FLTARR(np, nl*(n+1))
  aodlst = FLTARR(np, nl*(n+1))
  llat = FLTARR(np, nl*(n+1))
  llon = FLTARR(np, nl*(n+1))
  llst = FLTARR(np, nl*(n+1))
  laodlat = FLTARR(np, nl*(n+1))
  laodlon = FLTARR(np, nl*(n+1))
  laodlst = FLTARR(np, nl*(n+1))


  PRINT, 'AAAA'
  FOR i = 0, n-1 DO BEGIN
    PRINT, 'IIII : ', i
    sub_read_mod11, filedir, filename(i), np, nl, rlat, rlon, rlst
    sub_read_mod04, afiledir, afilename(i), aflat, aflon, aaod, anp, anl
    tmpaodlat = FLTARR(np, nl)
    tmpaodlon = FLTARR(np, nl)
    tmpaodlst = FLTARR(np, nl)
    flat = FLTARR(np,nl)
    flon = FLTARR(np,nl)
    aod  = FLTARR(np,nl)
    flat =  congrid(aflat, np, nl, /interp)
    flon =  congrid(aflon, np, nl, /interp)
    aod  =  congrid(aaod, np, nl, /interp)

    aodindex = WHERE( aod gt 0.0 and aod le 0.5, acount)
    IF(acount gt 0) THEN BEGIN
    tmpaodlat(aodindex) = rlat(aodindex)
    tmpaodlon(aodindex) = rlon(aodindex)
    tmpaodlst(aodindex) = rlst(aodindex)
    aodlat(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpaodlat
    aodlon(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpaodlon
    aodlst(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpaodlst
    rlst(aodindex) = 0.0
    lat(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlat(0:(np-1), 0:(nl-1))
    lon(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlon(0:(np-1), 0:(nl-1))
    lst(0:(np-1), (nl*i):(nl*(i+1)-1)) = rlst(0:(np-1), 0:(nl-1))
    ENDIF ELSE BEGIN
    ENDELSE
  ENDFOR

    FOR i = 0, n-1 DO BEGIN
    PRINT, 'IIII : ', i
    sub_read_mod11, filedir, filename(i), np, nl, lrlat, lrlon, lrlst
    sub_read_mod04, afiledir, afilename(i), laflat, laflon, laaod, anp, anl
    ltmpaodlat = FLTARR(np, nl)
    ltmpaodlon = FLTARR(np, nl)
    ltmpaodlst = FLTARR(np, nl)
    lflat = FLTARR(np,nl)
    lflon = FLTARR(np,nl)
    laod  = FLTARR(np,nl)
    lflat =  congrid(laflat, np, nl, /interp)
    lflon =  congrid(laflon, np, nl, /interp)
    laod  =  congrid(laaod, np, nl, /interp)
    laodindex = WHERE(laod ge 0.5, lacount)
    IF (lacount gt 0) THEN BEGIN
    ltmpaodlat(laodindex) = lrlat(laodindex)
    ltmpaodlon(laodindex) = lrlon(laodindex)
    ltmpaodlst(laodindex) = lrlst(laodindex)
    laodlat(0:(np-1), (nl*i):(nl*(i+1)-1)) = ltmpaodlat
    laodlon(0:(np-1), (nl*i):(nl*(i+1)-1)) = ltmpaodlon
    laodlst(0:(np-1), (nl*i):(nl*(i+1)-1)) = ltmpaodlst
    lrlst(laodindex) = 0.0
    llat(0:(np-1), (nl*i):(nl*(i+1)-1)) = lrlat(0:(np-1), 0:(nl-1))
    llon(0:(np-1), (nl*i):(nl*(i+1)-1)) = lrlon(0:(np-1), 0:(nl-1))
    llst(0:(np-1), (nl*i):(nl*(i+1)-1)) = lrlst(0:(np-1), 0:(nl-1))
    ENDIF ELSE BEGIN
    ENDELSE
  ENDFOR 

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            tmplst = 0.0
            account = 0
            index01 = where(laodlat ge grid_lat(k)-0.25 $
                        and laodlat le grid_lat(k)+0.25 $
                        and laodlon ge grid_lon(l)-0.25 $
                        and laodlon le grid_lon(l)+0.25 $
                        and laodlst  gt 0.0, account )

           IF (account gt 0) THEN BEGIN
           meanlaodlst(l,k) = mean(laodlst[index01])
           ENDIF ELSE BEGIN
           meanlaodlst(l,k) =  0
           ENDELSE
           PRINTF, lun, grid_lat(k), grid_lon(l), meanlaodlst(l,k), account
         ENDFOR
       ENDFOR

  FREE_LUN, lun


        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            tmplst = 0.0
            ccount = 0
            index01 = where(aodlat ge grid_lat(k)-0.25 $
                        and aodlat le grid_lat(k)+0.25 $
                        and aodlon ge grid_lon(l)-0.25 $
                        and aodlon le grid_lon(l)+0.25 $
                        and aodlst  gt 0.0, ccount )

           IF (ccount gt 0) THEN BEGIN
           meanlst(l,k) = mean(aodlst[index01])
           ENDIF ELSE BEGIN
           meanlst(l,k) =  0
           ENDELSE
           PRINTF, lun1, grid_lat(k), grid_lon(l), meanlst(l,k), ccount
         ENDFOR
       ENDFOR

  FREE_LUN, lun1
  ENDFOR

END
