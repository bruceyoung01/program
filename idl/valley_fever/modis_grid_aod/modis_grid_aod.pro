;******************************************************************************
;  $ID: modis_grid_aod.pro V01 BRUCE 03/25/2014 17:05 EXP$
;
;******************************************************************************
;  PROGRAM modis_grid_aod READS MODIS MOD04/MYD04 AEROSOL PRODUCT, GRID THE 
;  DATA INTO GRIDED DATA, AND PLOT 
;  DAILY MODIS AOD.
;
;  VARIABALES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/25/2014)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
@/Users/bruce/Documents/A/program/idl/idl_lib/procedure/universal/sub_read_mod04.pro
@/Users/bruce/Documents/A/program/idl/idl_lib/procedure/universal/sub_LST_grid.pro
@/Users/bruce/Documents/A/program/idl/idl_lib/procedure/universal/process_day_aod.pro
@/Users/bruce/Documents/A/program/idl/idl_lib/procedure/universal/plot_emission_subroutine.pro


; SETUP DIRECTARY INFO
  filedir     = '/Volumes/TOSHIBA_3B/iproject/valley_fever/modis/mod04/'
  filelist    = 'mod04_list'

  process_day_aod, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

; DEFINE WHICH MODIS (TERRA OR AQUA)
  sate = STRMID(Allfilename(0), 1, 1)
  IF (sate EQ "O") THEN sate = "Terra"
  IF (sate EQ "Y") THEN sate = "Aqua"

  np     = 135L
  nl     = 204L
  maxlat = 45.
  minlat = 25.
  maxlon =-95.
  minlon =-125.
  latint = 0.5
  lonint = 0.5

  nlat   = CEIL((maxlat-minlat)/0.5)
  nlon   = CEIL((maxlon-minlon)/0.5)
  grid_lat = FLTARR(nlat)
  grid_lon = FLTARR(nlon)
  meanaod  = FLTARR(nlon, nlat)

  FOR i = 0, nlat-1 DO BEGIN
    grid_lat(i) = minlat + 0.5*i
  ENDFOR

  FOR i = 0, nlon-1 DO BEGIN
    grid_lon(i) = minlon + 0.5*i
  ENDFOR

  FOR j = 0, Nday-1 DO BEGIN
  n = endinx(j) - startinx(j) + 1
  date = STRARR(n)
  FOR nc = 0, n-1 DO BEGIN
  date(nc) = STRMID(Allfilename(startinx(j)), 0, 17)
  ENDFOR

  file = date(0)
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
    aod(0:(np-1), (nl*i):(nl*(i+1)-1))   = raod
  ENDFOR

        FOR k = 0, nlat-1 DO BEGIN
          FOR l =0, nlon-1 DO BEGIN
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
  DEVICE, filename ='1plt_modis_grid_aod_' + date(0) + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, 33, ncolors =  180, range = [0.0, 1]
  TVMAP, transpose(aaod), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, sample = 4, $
         title = 'AOD(' + sate + ') 2012 '+STRMID(dayname(j),0,4),$
         /cbar,DIVISIONS = 6, maxdata = 1.0, mindata = 0, $
         CBMIN = 0, CBMAX = 1.0, /COUNTRIES, /COAST, /USA, $
         MIN_VALID = 0.00001

  DEVICE, /close

  FREE_LUN, lun
  ENDFOR
END
