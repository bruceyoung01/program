; $ID: plot_AOD_grid_daily.pro V01 04/12/2012/ 15:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_AOD_grid_daily INTERPLATE MODIS AOD TO A NEW RESOLUTION AND
;  PLOT IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/13/2012)
;******************************************************************************

;  LOAD PROCEDURES AND FUNCTIONS
@/home/bruce/program/idl/arslab4/pro_mixed/sub_read_mod04.pro
@/home/bruce/program/idl/arslab4/pro_mixed/plot_emission_subroutine.pro
@/home/bruce/program/idl/arslab4/pro_mixed/sub_LST_grid.pro
@/home/bruce/program/idl/arslab4/pro_mixed/process_day_aod.pro

;  DEFINE DATA DIRECTORY, RESULT DIRECTORY AND FILE NAMES LIST FOR MODIS
;  AOD DATA (TERRA OR AQUA)
   filedir    = '/home/bruce/sshfs/pfw/data/satellite/MODIS/sahel/myd04/'
   filedirres = '/home/bruce/program/idl/modis/code/aod/aod_grid/'
   filelist   = 'MYD04_200802'
;  LOAD COLOR TABLE
   MYCT, 33, ncolors = 102, range = [0.0, 1]

;  CALL SUBROUTINE process_day_aod TO READ FILE INFO FROM FILE NAMES
   process_day_aod, filedir + filelist, Nday, AllFileName, StartInx, EndInx,    $
                    YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, TimeE = TimeE,$
                    Dayname, DAYNUM

   PRINT, 'Nday : ', Nday
   PRINT, 'AllFileName : ', AllFileName
   PRINT, 'StartInx : ', StartInx
   PRINT, 'EndInx : ', EndInx
   PRINT, 'TimeS : ', TimeS
   PRINT, 'TimeE : ', TimeE
   PRINT, 'Dayname : ', Dayname
   PRINT, 'DAYNUM : ', DAYNUM

;  DEFINE THE GRID NUMBER IN EACH GRANULE
   np     = 135L
   nl     = 203L
   minaod = 0.0
   maxaod = 1.0
;  SET UP NEW RESOLUTION
   new_grid = 0.2

;  SET UP STUDY REGION
;                  ;TEXAS    ; WA     ; SAHEL   GLOBAL
   maxlat = 35.0   ;40.0     ; 45.0   ; 35.0     90.0
   minlat =-15.0   ;25.0     ; 30.0   ;-15.0    -90.0
   maxlon = 45.0   ;-90.0    ;-110.0  ; 45.0    180.0
   minlon =-25.0   ;-115.0   ;-130.0  ;-25.0   -180.0 

;  GRID SIZE 
   gridsize_lat = CEIL((maxlat-minlat)/new_grid)
   gridsize_lon = CEIL((maxlon-minlon)/new_grid)
;  DEFINE 1-DIMENSIONAL ARRAY FOR LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
   grid_lat = FLTARR(gridsize_lat)
   grid_lon = FLTARR(gridsize_lon)
   meanaod  = FLTARR(gridsize_lon,gridsize_lat)
;  ASSIGN VALUE TO GRIDED LATITUDE AND LONGITUDE
   FOR i = 0, gridsize_lat-1 DO BEGIN
    grid_lat(i) = minlat + new_grid*i
   ENDFOR
   FOR i = 0, gridsize_lon-1 DO BEGIN
    grid_lon(i) = minlon + new_grid*i
   ENDFOR

   alat     = FLTARR(gridsize_lat, gridsize_lon)
   alon     = FLTARR(gridsize_lat, gridsize_lon)
   aaod     = FLTARR(nday, gridsize_lat, gridsize_lon)

;  DO LOOP OF DAY
   FOR j = 0, Nday-1 DO BEGIN
    n = endinx(j) - startinx(j) + 1
;  EXTRACT DATE FROM FILE NAME
    date = STRARR(n)
    FOR nc = 0, n-1 DO BEGIN
     date(nc) = STRMID(Allfilename(startinx(j)), 0, 17)
    ENDFOR
    PRINT, 'NOW WORKING ON : ', date(0)
;  OPEN A NEW FILE TO WRITE GRIDED LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
    file = filedirres + date(0); + "db"
    OPENW, lun, file, /get_lun
    filename = Allfilename(startinx(j):endinx(j))
    zcount = 0
;  DO LOOP OF FILES IN ONE DAY TO READ LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD INTO ONE 1-DIMENSIONAL ARRAY
    lat   = FLTARR(np, nl*(n+1))
    lon   = FLTARR(np, nl*(n+1))
    aod   = FLTARR(np, nl*(n+1))
    FOR i = 0L, n-1 DO BEGIN
     sub_read_mod04, filedir, filename(i), rlat, rlon, raod, np, nl
     lat(0:(np-1), (nl*i):(nl*(i+1)-1))   = rlat
     lon(0:(np-1), (nl*i):(nl*(i+1)-1))   = rlon
;  FOR FINE MODE AOD
;    aod(0:(np-1), (nl*i):(nl*(i+1)-1))   = AVG(raod, 2)
;  FOR AOD
     aod(0:(np-1), (nl*i):(nl*(i+1)-1))   = raod
    ENDFOR
;  TO AVERAGE THE AOD IN ONE GRID BOX
    FOR k = 0, gridsize_lat-1 DO BEGIN
     FOR l =0, gridsize_lon-1 DO BEGIN
      tmplst = 0.0
      ccount = 0
      index01 = where(lat ge grid_lat(k)-new_grid/2.0 $
                  and lat le grid_lat(k)+new_grid/2.0 $
                  and lon ge grid_lon(l)-new_grid/2.0 $
                  and lon le grid_lon(l)+new_grid/2.0 $
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
;  CONVERT TO 2 DIMENSION DATA
    OPENR, lun, file, /get_lun
    tmplat   = 0.0
    tmplon   = 0.0
    tmpaod   = 0.0
    FOR m = 0, gridsize_lat-1 DO BEGIN
     FOR k = 0, gridsize_lon-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmpaod, count
      alat(m, k) = tmplat
      alon(m, k) = tmplon
      IF (tmpaod lt 0.001) THEN BEGIN
       tmpaod   = -9999.
      ENDIF
      aaod(j, m, k) = tmpaod
     ENDFOR
    ENDFOR
;  PLOT THE DAILY AOD GRID ONTO MAP
    SET_PLOT, 'ps'
    DEVICE, filename =filedirres + 'plot_' + date(0)+ '.ps',    $
            xsize = 7., ysize=10, xoffset = 0.5, yoffset = 0.5, $
            /inches, /color, bits=8
    TVMAP, transpose(aaod(j, *, *)), /grid,$
           LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, sample = 4, $
           title = 'AOD(Aqua) 2008 '+STRMID(dayname(j),0,4),        $
           /cbar,DIVISIONS = 6, maxdata = maxaod, mindata = minaod,  $
           CBMIN = minaod, CBMAX = maxaod, /COUNTRIES, /COAST, /USA, $
           MIN_VALID = minaod
    DEVICE, /close
    FREE_LUN, lun
   ENDFOR

;  CALCULATE MONTHLY AOD AVERAGE FROM DAILY
   maod     = FLTARR(gridsize_lat, gridsize_lon)
   FOR m = 0, gridsize_lat-1 DO BEGIN
    FOR k =0, gridsize_lon-1 DO BEGIN
     index1 = WHERE(aaod(*, m, k) GT 0.0, count1)
     IF (count1 GT 0) THEN BEGIN
      maod(m, k) = TOTAL(aaod(index1, m, k))/count1
     ENDIF
    ENDFOR
   ENDFOR
   index2 = WHERE(maod LE 0.0, count2)
   IF (count2 GT 0) THEN BEGIN
    maod(index2) = -9999.0
   ENDIF

;  PLOT THE MONTHLY AOD GRID ONTO MAP
    SET_PLOT, 'ps'
    DEVICE, filename =filedirres + 'plot_2008' + STRMID(dayname(0),0,2) + '.ps', $
            xsize = 7., ysize=10, xoffset = 0.5, yoffset = 0.5, $
            /inches, /color, bits=8
    TVMAP, transpose(maod), /grid,$
           LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, sample = 4, $
           title = 'AOD(Aqua) 2008 '+STRMID(dayname(0),0,2),        $
           /cbar,DIVISIONS = 6, maxdata = maxaod, mindata = minaod,  $
           CBMIN = minaod, CBMAX = maxaod, /COUNTRIES, /COAST, /USA, $
           MIN_VALID = minaod
    DEVICE, /close

END
