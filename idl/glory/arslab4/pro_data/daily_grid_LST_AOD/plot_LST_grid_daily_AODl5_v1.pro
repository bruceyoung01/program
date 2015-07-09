@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_AOD/sub_read_mod04.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_AOD/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_AOD/process_day.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_AOD/process_day_aod.pro



; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution under the condition of AOD>0.5
  
  filedir     = '/mnt/sdc/data/modis/arslab4/mod11/2010/'
  filelist    = '201004lstlist_afl_al'
  afiledir    = '/mnt/sdc/data/modis/arslab4/mod04/2010/'
  afilelist   = '201004aodlist_afl_al'
  filedirres   = '/home/bruce/data/modis/arslab4/results/1/'
  
  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  process_day, afiledir + afilelist, aNday, aAllFileName, aStartInx, aEndInx, $
                  YEAR= ayear, Mon= amon, Date= aDate, TimeS = aTimeS, $
                  TimeE = aTimeE, aDayname, aDAYNUM

  PRINT, 'Nday : ', aNday
;  PRINT, 'AllFileName : ', aAllFileName
  PRINT, 'StartInx : ', aStartInx
  PRINT, 'EndInx : ', aEndInx
  PRINT, 'TimeS : ', aTimeS
  PRINT, 'TimeE : ', aTimeE
  PRINT, 'Dayname : ', aDayname
  PRINT, 'DAYNUM : ', aDAYNUM

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
  meanal5lst = FLTARR(gridsize_lon,gridsize_lat)

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

  OPENW, lun, filedirres + 'al5lst_' + date(0), /get_lun
  filename = Allfilename(startinx(j):endinx(j))
  afilename = aAllfilename(startinx(j):endinx(j))

  alat    = FLTARR(anp,anl)
  alon    = FLTARR(anp,anl)
  aaod    = FLTARR(anp,anl)
  al5lat = FLTARR(np, nl*(n+1))
  al5lon = FLTARR(np, nl*(n+1))
  al5lst = FLTARR(np, nl*(n+1))

   FOR i = 0, n-1 DO BEGIN
    sub_read_mod11, filedir, filename(i), np, nl, rlat, rlon, rlst
    sub_read_mod04, afiledir, afilename(i), alat, alon, aaod, anp, anl
    xlat = FLTARR(np,nl)
    xlon = FLTARR(np,nl)
    xaod = FLTARR(np,nl)
    xlat = CONGRID(alat, np, nl, /interp)
    xlon = CONGRID(alon, np, nl, /interp)
    xaod = CONGRID(aaod, np, nl, /interp)
    al5  = FLTARR(np,nl)
    aodindex = WHERE(xaod ge 0.5, acount)
    PRINT, 'AOD>0.5 : ', acount
    IF (acount gt 0) THEN BEGIN
    al5(aodindex) = rlst(aodindex)
    al5lat (0:(np-1), (nl*i):(nl*(i+1)-1)) = rlat
    al5lon (0:(np-1), (nl*i):(nl*(i+1)-1)) = rlon
    al5lst (0:(np-1), (nl*i):(nl*(i+1)-1)) = al5
    ENDIF
   ENDFOR

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            ncount = 0
            index01 = where(al5lat ge grid_lat(k)-0.25 $
                        and al5lat le grid_lat(k)+0.25 $
                        and al5lon ge grid_lon(l)-0.25 $
                        and al5lon le grid_lon(l)+0.25 $
                        and al5lst  gt 0.0, ncount )

           IF (ncount gt 0) THEN BEGIN
           meanal5lst(l,k) = mean(al5lst[index01])
           ENDIF ELSE BEGIN
           meanal5lst(l,k) =  0
           ENDELSE
           PRINTF, lun, grid_lat(k), grid_lon(l), meanal5lst(l,k), ncount
         ENDFOR
       ENDFOR

  FREE_LUN, lun

  ENDFOR
END
