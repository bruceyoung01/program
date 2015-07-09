@/home/bruce/program/idl/arslab4/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/sub_read_mod04.pro
@/home/bruce/program/idl/arslab4/sub_read_mod14.pro
@/home/bruce/program/idl/arslab4/sub_read_mod14_judge.pro
@/home/bruce/program/idl/arslab4/process_day.pro
@/home/bruce/program/idl/arslab4/process_day_fire.pro



; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.
  
  filedir     = '/home/bruce/data/modis/arslab4/mod11/2003/'
  filelist    = '2003lstlist_case'
  afiledir    = '/home/bruce/data/modis/arslab4/mod04/2003/5min/'
  afilelist   = '2003aodlist_case'
  ffiledir    = '/home/bruce/data/modis/arslab4/mod14/2003/'
  ffilelist   = '2003firelist_case'
  filedirres  = '/home/bruce/data/modis/arslab4/results/2003/'


  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  process_day, afiledir + afilelist, aNday, aAllFileName, aStartInx, aEndInx, $
                  YEAR= ayear, Mon= amon, Date= aDate, TimeS = aTimeS, $
                  TimeE = aTimeE, aDayname, aDAYNUM

  process_day_fire, ffiledir + ffilelist, fNday, fAllFileName, fStartInx, fEndInx, $
                  YEAR= fyear, Mon= fmon, Date= fDate, TimeS = fTimeS, $
                  TimeE = fTimeE, fDayname, fDAYNUM


  PRINT, 'Nday : ', aNday
  PRINT, 'StartInx : ', aStartInx
  PRINT, 'EndInx : ', aEndInx
  PRINT, 'TimeS : ', aTimeS
  PRINT, 'TimeE : ', aTimeE
  PRINT, 'Dayname : ', aDayname
  PRINT, 'DAYNUM : ', aDAYNUM

  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)
  meanlst  = FLTARR(gridsize_lon,gridsize_lat)
  al5meanlst  = FLTARR(gridsize_lon,gridsize_lat)
  afl5meanlst = FLTARR(gridsize_lon,gridsize_lat)
  as5meanlst  = FLTARR(gridsize_lon,gridsize_lat)
  afs5meanlst = FLTARR(gridsize_lon,gridsize_lat)

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


  OPENW, lun1, filedirres + 'al5lst_' + date(0), /get_lun
  filename = Allfilename(startinx(j):endinx(j))

  OPENW, lun2, filedirres + 'afl5lst_' + date(0), /get_lun
  ffilename = fAllfilename(startinx(j):endinx(j))


  date_slat = STRARR(n)
  date_slon = STRARR(n)
  date_saod = STRARR(n)
  nfire_total  = 0
  snfire_total = 0
  
  FOR i = 0, n-1 DO BEGIN
    PRINT, 'IIII : ', i
    sub_read_mod04, afiledir, afilename(i), alat, alon, aaod, anp, anl
    PRINT, 'OPEN HDF FILE  : ', afilename(i)
    sub_read_mod11, filedir, filename(i), np, nl, rlat, rlon, rlst
  rlat    = FLTARR(np, nl)
  rlon    = FLTARR(np, nl)
  rlst    = FLTARR(np, nl)
  tmpalat = FLTARR(np, nl)
  tmpalon = FLTARR(np, nl)
  tmpalst = FLTARR(np, nl)
  tmpaflat = FLTARR(np, nl)
  tmpaflon = FLTARR(np, nl)
  tmpaflst = FLTARR(np, nl)
  al5lat = FLTARR(np, nl*(n+1))
  al5lon = FLTARR(np, nl*(n+1))
  al5lst = FLTARR(np, nl*(n+1))
  afl5lat = FLTARR(np, nl*(n+1))
  afl5lon = FLTARR(np, nl*(n+1))
  afl5lst = FLTARR(np, nl*(n+1))
    xlat = FLTARR(np,nl)
    xlon = FLTARR(np,nl)
    xaod = FLTARR(np,nl)
    xlat =  congrid(alat, np, nl, /interp)
    xlon =  congrid(alon, np, nl, /interp)
    xaod =  congrid(aaod, np, nl, /interp)
    aodindex = WHERE(xaod ge 0.5, acount)
    IF(acount gt 0) THEN BEGIN 
    tmpalat(aodindex) = rlat(aodindex)
    tmpalon(aodindex) = rlon(aodindex)
    tmpalst(aodindex) = rlst(aodindex)
    rlst(aodindex) = 0.0
    sub_read_mod14_judge, ffiledir, ffilename(i), fire_mask
    nfire = WHERE (fire_mask ge 7, firecount)
    PRINT, 'FIRE COUNT : ', firecount
    IF (firecount gt 0) THEN BEGIN
    sub_read_mod14, ffiledir, ffilename(i), nfire, flat, flon, fire_sample, fire_line
    PRINT, 'OPEN HDF FILE  :  ', ffilename(i)
    nfire_total = nfire_total + nfire


    FOR ni = 0, nfire-1 DO BEGIN
      tmpaflat(fire_sample(ni),fire_line(ni)) = tmpalat(fire_sample(ni),fire_line(ni))
      tmpaflon(fire_sample(ni),fire_line(ni)) = tmpalon(fire_sample(ni),fire_line(ni))
      tmpaflst(fire_sample(ni),fire_line(ni)) = tmpalst(fire_sample(ni),fire_line(ni))
      tmpalst(fire_sample(ni),fire_line(ni)) = 0.0
      afl5lat(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpaflat(0:(np-1), 0:(nl-1))
      afl5lon(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpaflon(0:(np-1), 0:(nl-1))
      afl5lst(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpaflst(0:(np-1), 0:(nl-1))
    ENDFOR
      al5lat(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpalat(0:(np-1), 0:(nl-1))
      al5lon(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpalon(0:(np-1), 0:(nl-1))
      al5lst(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpalst(0:(np-1), 0:(nl-1))

    ENDIF ELSE BEGIN
      al5lat(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpalat(0:(np-1), 0:(nl-1))
      al5lon(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpalon(0:(np-1), 0:(nl-1))
      al5lst(0:(np-1), (nl*i):(nl*(i+1)-1)) = tmpalst(0:(np-1), 0:(nl-1))
    ENDELSE
    ENDIF ELSE BEGIN
    ENDELSE
  ENDFOR

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            al5count = 0
            al5index01 = where(al5lat ge grid_lat(k)-0.25 $
                           and al5lat le grid_lat(k)+0.25 $
                           and al5lon ge grid_lon(l)-0.25 $
                           and al5lon le grid_lon(l)+0.25 $
                           and al5lst  gt 0.0, al5count )

           IF (al5count gt 0) THEN BEGIN
           al5meanlst(l,k) = mean(al5lst[al5index01])
           ENDIF ELSE BEGIN
           al5meanlst(l,k) =  0
           ENDELSE
           PRINTF, lun1, grid_lat(k), grid_lon(l), al5meanlst(l,k), al5count
         ENDFOR
       ENDFOR

  FREE_LUN, lun1

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            afl5count = 0
            afl5index01 = where(afl5lat ge grid_lat(k)-0.25 $
                            and afl5lat le grid_lat(k)+0.25 $
                            and afl5lon ge grid_lon(l)-0.25 $
                            and afl5lon le grid_lon(l)+0.25 $
                            and afl5lst  gt 0.0, afl5count )

           IF (afl5count gt 0) THEN BEGIN
           afl5meanlst(l,k) = mean(afl5lst[afl5index01])
           ENDIF ELSE BEGIN
           afl5meanlst(l,k) =  0
           ENDELSE
           PRINTF, lun2, grid_lat(k), grid_lon(l), afl5meanlst(l,k), afl5count
         ENDFOR
       ENDFOR

  FREE_LUN, lun2

END
