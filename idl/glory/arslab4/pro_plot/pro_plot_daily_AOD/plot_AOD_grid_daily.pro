@/home/bruce/program/idl/arslab4/sub_read_mod04.pro
@/home/bruce/program/idl/arslab4/plot_emission_subroutine.pro
@/home/bruce/program/idl/arslab4/sub_LST_grid.pro
@/home/bruce/program/idl/arslab4/process_day_aod.pro


; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.
  
  filedir     = '/home/bruce/sshfs/pfw/satellite/MODIS/sahel/myd04/'
  filedirres  = '/home/bruce/data/modis/sahel/myd04/'
  filelist    = 'MYD04_200802'

  process_day_aod, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  PRINT, 'Nday : ', Nday
  PRINT, 'AllFileName : ', AllFileName
  PRINT, 'StartInx : ', StartInx
  PRINT, 'EndInx : ', EndInx
  PRINT, 'TimeS : ', TimeS
  PRINT, 'TimeE : ', TimeE
  PRINT, 'Dayname : ', Dayname
  PRINT, 'DAYNUM : ', DAYNUM

  nlat   = 90
  nlon   = 140
  np     = 135L
  nl     = 203L
  maxlat = 35.
  minlat =-10.
  maxlon = 45.
  minlon =-25.

  gridsize_lat = CEIL((maxlat-minlat)/0.5)
  gridsize_lon = CEIL((maxlon-minlon)/0.5)

  grid_lat = FLTARR(gridsize_lat)
  grid_lon = FLTARR(gridsize_lon)
  meanaod  = FLTARR(gridsize_lon,gridsize_lat)

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

  file = filedirres + date(0) + "fm"
  OPENW, lun, file, /get_lun
  filename = Allfilename(startinx(j):endinx(j))
  zcount = 0

  lat   = FLTARR(np, nl*(n+1))
  lon   = FLTARR(np, nl*(n+1))
  aod   = FLTARR(np, nl*(n+1))
  FOR i = 0L, n-1 DO BEGIN
    sub_read_mod04, filedir, filename(i), rlat, rlon, raod, np, nl
    lat(0:(np-1), (nl*i):(nl*(i+1)-1))   = rlat
    lon(0:(np-1), (nl*i):(nl*(i+1)-1))   = rlon
    aod(0:(np-1), (nl*i):(nl*(i+1)-1))   = AVG(raod, 2)
  ENDFOR

        FOR k = 0, gridsize_lat-1 DO BEGIN
          FOR l =0, gridsize_lon-1 DO BEGIN
            tmplst = 0.0
            ccount = 0
            index01 = where(lat ge grid_lat(k)-0.25 $
                        and lat le grid_lat(k)+0.25 $
                        and lon ge grid_lon(l)-0.25 $
                        and lon le grid_lon(l)+0.25 $
                        and aod gt 0.0, ccount )

           IF (ccount gt 0) THEN BEGIN
           meanaod(l,k)   = mean(aod[index01])
           ENDIF ELSE BEGIN
           meanaod(l,k) =  0
           ENDELSE
           PRINTF, lun, grid_lat(k), grid_lon(l), meanaod(l,k), ccount
         ENDFOR
       ENDFOR
  FREE_LUN, lun
; CONVERT TO 2 DIMENSION DATA
  OPENR, lun, file, /get_lun
  alat     = FLTARR(nlat, nlon)
  alon     = FLTARR(nlat, nlon)
  aaod     = FLTARR(nlat, nlon)
  tmplat   = 0.0
  tmplon   = 0.0
  tmpaod   = 0.0
    FOR m = 0, nlat-1 DO BEGIN
     FOR k = 0, nlon-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmpaod, count
      alat(m,k) = tmplat
      alon(m,k) = tmplon
      aaod(m,k) = tmpaod
     ENDFOR
    ENDFOR

  SET_PLOT, 'ps'
  DEVICE, filename =filedirres + 'plot_' + date(0) + 'fm.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, 33, ncolors =  180, range = [0.0, 1]
  TVMAP, transpose(aaod), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, sample = 4, $
         title = 'AOD(Aqua) 2008 '+STRMID(dayname(j),0,4),$
         /cbar,DIVISIONS = 6, maxdata = 1.0, mindata = 0, $
         CBMIN = 0, CBMAX = 1.0, /COUNTRIES, /COAST, $
         MIN_VALID = 0.00001

  DEVICE, /close

  FREE_LUN, lun
  ENDFOR
END
