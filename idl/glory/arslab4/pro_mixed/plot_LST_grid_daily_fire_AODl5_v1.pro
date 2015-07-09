@/home/bruce/program/idl/arslab4/sub_read_mod04.pro
@/home/bruce/program/idl/arslab4/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/sub_read_mod14.pro
@/home/bruce/program/idl/arslab4/sub_read_mod14_judge.pro
@/home/bruce/program/idl/arslab4/process_day.pro
@/home/bruce/program/idl/arslab4/process_day_fire.pro



; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.
  
  filedir     = '/mnt/sdc/data/modis/arslab4/mod11/2000/'
  filelist    = '200004lstlist_afl'
  ffiledir    = '/mnt/sdc/data/modis/arslab4/mod14/2000/'
  ffilelist   = '200004firelist_afl' 
  afiledir    = '/mnt/sdc/data/modis/arslab4/mod04/2000/'
  afilelist   = '200004aodlist_afl'
  filedirres   = '/home/bruce/data/modis/arslab4/results/2000/'
  
  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  process_day_fire, ffiledir + ffilelist, fNday, fAllFileName, fStartInx, fEndInx, $
                  YEAR= fyear, Mon= fmon, Date= fDate, TimeS = fTimeS, $
                  TimeE = fTimeE, fDayname, fDAYNUM

  process_day, afiledir + afilelist, aNday, aAllFileName, aStartInx, aEndInx, $
                  YEAR= ayear, Mon= amon, Date= aDate, TimeS = aTimeS, $
                  TimeE = aTimeE, aDayname, aDAYNUM

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

  anp = 135
  anl = 203
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
  meananl5lst = FLTARR(gridsize_lon,gridsize_lat)
  meanfl5lst  = FLTARR(gridsize_lon,gridsize_lat)
  meanal5     = FLTARR(gridsize_lon,gridsize_lat)

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

  OPENW, lun, filedirres + 'anl5lst_' + date(0), /get_lun
  filename = Allfilename(startinx(j):endinx(j))

  OPENW, lun1, filedirres + 'afl5lst_' + date(0), /get_lun
  ffilename= fAllfilename(fstartinx(j):fendinx(j))

  OPENW, lun2, filedirres + 'aodl5_' + date(0), /get_lun
  afilename= aAllfilename(fstartinx(j):fendinx(j))

  alat    = FLTARR(anp,anl)
  alon    = FLTARR(anp,anl)
  aaod    = FLTARR(anp,anl)
  anl5lat = FLTARR(np, nl*(n+1))
  anl5lon = FLTARR(np, nl*(n+1))
  anl5lst = FLTARR(np, nl*(n+1))
  firelat = FLTARR(5000, 5000)
  firelon = FLTARR(5000, 5000)
  firelst = FLTARR(5000, 5000)
  nfire_total = 0


  PRINT, 'AAAA'
  FOR i = 0, n-1 DO BEGIN
    PRINT, 'IIII : ', i
    sub_read_mod11, filedir, filename(i), np, nl, rlat, rlon, rlst
    sub_read_mod04, afiledir, afilename(i), alat, alon, aaod, anp, anl
    tmpanlat = FLTARR(np,nl)
    tmpanlon = FLTARR(np,nl)
    tmpanlst = FLTARR(np,nl)
    xlat = FLTARR(np,nl)
    xlon = FLTARR(np,nl)
    xaod = FLTARR(np,nl)
    xlat = congrid(alat, np, nl, /interp)
    xlon = congrid(alon, np, nl, /interp)
    xaod = congrid(aaod, np, nl, /interp)
    al5  = FLTARR(np,nl)
    aodindex = WHERE(xaod ge 0.5, acount)
    PRINT, 'AOD>0.5 : ', acount
    IF (acount gt 0) THEN BEGIN
    al5(aodindex) = xaod(aodindex)
    sub_read_mod14_judge, ffiledir, ffilename(i), fire_mask
    nfire = WHERE (fire_mask ge 7, firecount)
    PRINT, 'FIRE COUNT : ', firecount
    IF (firecount gt 0) THEN BEGIN

    sub_read_mod14, ffiledir, ffilename(i), nfire, flat, flon, fire_sample, fire_line
    nfire_total = nfire_total + nfire
    
    FOR ni = 0, nfire-1 DO BEGIN
      IF (xaod(fire_sample(ni),fire_line(ni)) ge 0.5) THEN BEGIN
      firelat((nfire_total+ni): (nfire_total+(ni+1)-1), (nfire_total+ni): (nfire_total+(ni+1)-1)) = rlat(fire_sample(ni),fire_line(ni))
      firelon((nfire_total+ni): (nfire_total+(ni+1)-1), (nfire_total+ni): (nfire_total+(ni+1)-1)) = rlon(fire_sample(ni),fire_line(ni))
      firelst((nfire_total+ni): (nfire_total+(ni+1)-1), (nfire_total+ni): (nfire_total+(ni+1)-1)) = rlst(fire_sample(ni),fire_line(ni))
      ;PRINT, 'BBBBBCCCCCC : ', firelst((nfire_total*ni): (nfire_total*(ni+1)-1), (nfire_total*ni): (nfire_total*(ni+1)-1))
      ENDIF
      rlst(fire_sample(ni),fire_line(ni)) = 0.0
    ENDFOR
      ;PRINT, '11111111 : ', rlst(aodindex)
      tmpanlat(aodindex) = rlat(aodindex)
      tmpanlon(aodindex) = rlon(aodindex)
      tmpanlst(aodindex) = rlst(aodindex)
      anl5lat(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpanlat
      anl5lon(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpanlon
      anl5lst(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpanlst
      ;PRINT, 'AAAAAAAAA : ', tmpanlst
    ENDIF ELSE BEGIN
      ;PRINT, '22222222 : ', rlst(aodindex)
      tmpanlat(aodindex) = rlat(aodindex)
      tmpanlon(aodindex) = rlon(aodindex)
      tmpanlst(aodindex) = rlst(aodindex)
      anl5lat(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpanlat
      anl5lon(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpanlon
      anl5lst(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpanlst
    ENDELSE
    ENDIF
    ;PRINT,'CCCCCC : ', firelst
  ENDFOR

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            ncount = 0
            index01 = where(anl5lat ge grid_lat(k)-0.25 $
                        and anl5lat le grid_lat(k)+0.25 $
                        and anl5lon ge grid_lon(l)-0.25 $
                        and anl5lon le grid_lon(l)+0.25 $
                        and anl5lst  gt 0.0, ncount )

           IF (ncount gt 0) THEN BEGIN
           meananl5lst(l,k) = mean(anl5lst[index01])
           ENDIF ELSE BEGIN
           meananl5lst(l,k) =  0
           ENDELSE
           PRINTF, lun, grid_lat(k), grid_lon(l), meananl5lst(l,k), ncount
         ENDFOR
       ENDFOR

  FREE_LUN, lun


        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            fcount = 0
            index01 = where(firelat ge grid_lat(k)-0.25 $
                        and firelat le grid_lat(k)+0.25 $
                        and firelon ge grid_lon(l)-0.25 $
                        and firelon le grid_lon(l)+0.25 $
                        and firelst  gt 0.0, fcount )

           IF (fcount gt 0) THEN BEGIN
           meanfl5lst(l,k) = mean(firelst[index01])
           ENDIF ELSE BEGIN
           meanfl5lst(l,k) =  0
           ENDELSE
           PRINTF, lun1, grid_lat(k), grid_lon(l), meanfl5lst(l,k), fcount
         ENDFOR
       ENDFOR

  FREE_LUN, lun1

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            acount = 0
            index01 = where(xlat ge grid_lat(k)-0.25 $
                        and xlat le grid_lat(k)+0.25 $
                        and xlon ge grid_lon(l)-0.25 $
                        and xlon le grid_lon(l)+0.25 $
                        and al5  gt 0.0, acount )

           IF (acount gt 0) THEN BEGIN
           meanal5(l,k) = mean(al5[index01])
           ENDIF ELSE BEGIN
           meanal5(l,k) =  0
           ENDELSE
           PRINTF, lun2, grid_lat(k), grid_lon(l), meanal5(l,k), acount
         ENDFOR
       ENDFOR
  FREE_LUN, lun2

  ENDFOR
END
