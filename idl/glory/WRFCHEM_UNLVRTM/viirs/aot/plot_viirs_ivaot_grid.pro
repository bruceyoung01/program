; $ID: plot_viirs_ivaot.pro V01 04/15/2012 23:54 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_ivaot READS AND PLOTS NPP VIIRS AOT DATA.
;  FILENAME :
;  IVAOT_npp_d20120401_t0000292_e0001534_b02208_c20120401022654193815_noaa_ops.h5
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/15/2012)
;******************************************************************************

;  LOAD PROCEDURES AND FUNCTIONS
@/home/bruce/program/idl/idl_lib/process_day_ivaot_npp.pro
@/home/bruce/program/idl/idl_lib/process_day_va_npp.pro
@/home/bruce/program/idl/idl_lib/read_viirs_h5_sds.pro

;  SET UP NPP VIIRS DATA DIRECTORY AND FILE NAMES LIST
   dir   = '/home/bruce/sshfs/pfw/satellite/NPP/sahel/'
   flist = 'ivaot_list'
   glist = 'gmtco_list'

;  CALL SUBROUTINE process_day_ivaot_npp TO READ FILE NAMES INFO FROM FILE LIST
   process_day_ivaot_npp, dir + flist, Nday, AllFileName, StartInx, EndInx, $
                          YEAR=year, Mon=mon, Date=Date, TimeS = TimeS,     $
                          TimeE = TimeE, Dayname, DAYNUM

   process_day_va_npp, dir + glist, gNday, gAllFileName, gStartInx, gEndInx, $
                          YEAR=gyear, Mon=gmon, Date=gDate, TimeS = gTimeS,  $
                          TimeE = gTimeE, gDayname, gDAYNUM

   PRINT, 'Nday : ', Nday
   PRINT, 'AllFileName : ', AllFileName
   PRINT, 'StartInx : ', StartInx
   PRINT, 'EndInx : ', EndInx
   PRINT, 'TimeS : ', TimeS
   PRINT, 'TimeE : ', TimeE
   PRINT, 'Dayname : ', Dayname
   PRINT, 'DAYNUM : ', DAYNUM

;  DEFINE THE GRID NUMBER IN EACH GRANULE
   np     = 3200L
   nl     = 768L
   minaod = 0.0
   maxaod = 0.5

;  SET UP STUDY REGION
;  SAHEL
   maxlat = 35.0
   minlat =-10.0
   maxlon = 45.0
   minlon =-25.0
;  GLOBAL
;  maxlat = 90.0
;  minlat =-90.0
;  maxlon = 180.0
;  minlon =-180.0
;  AUSTRALIA
;  maxlat =-20.0
;  minlat =-40.0
;  maxlon = 180.0
;  minlon = 130.0
   region = [minlat, minlon, maxlat, maxlon]

;  GRID SIZE 
   gridsize_lat = CEIL((maxlat-minlat)/0.5)
   gridsize_lon = CEIL((maxlon-minlon)/0.5)
;  DEFINE 1-DIMENSIONAL ARRAY FOR LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
   grid_lat = FLTARR(gridsize_lat)
   grid_lon = FLTARR(gridsize_lon)
   meanaod  = FLTARR(gridsize_lon,gridsize_lat)
;  ASSIGN VALUE TO GRIDED LATITUDE AND LONGITUDE
   FOR i = 0, gridsize_lat-1 DO BEGIN
    grid_lat(i) = minlat + 0.5*i
   ENDFOR
   FOR i = 0, gridsize_lon-1 DO BEGIN
    grid_lon(i) = minlon + 0.5*i
   ENDFOR

;  DO LOOP OF # OF FILE NAMES
   FOR i = 0, Nday-1 DO BEGIN
    n = endinx(i) - startinx(i) + 1
;  EXTRACT DATE FROM FILE NAME
    date = STRARR(n)
    FOR nc = 0, n-1 DO BEGIN
     date(nc) = STRMID(Allfilename(startinx(i)), 0, 19)
    ENDFOR
    PRINT, 'DAY : ', date(0)
;  OPEN A NEW FILE TO WRITE GRIDED LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
    file = date(0) + '_grid.txt'
    OPENW, lun, file, /get_lun
    filename  = Allfilename(startinx(i):endinx(i))
    gfilename = gAllfilename(startinx(i):endinx(i))
    zcount = 0
;  DO LOOP OF FILES IN ONE DAY TO READ LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD INTO ONE 1-DIMENSIONAL ARRAY
    lat   = FLTARR(np, nl*(n))
    lon   = FLTARR(np, nl*(n))
    aod   = FLTARR(np, nl*(n))
    FOR j = 0L, n-1 DO BEGIN
     PRINT, 'NOW WORKING ON GRANULE : ', j + 1
;  CALL SUBROUTINE read_viirs_h5_sds.pro TO READ VARIABLES FROM NPP DATA
     slat = '/All_Data/VIIRS-MOD-GEO-TC_All/Latitude'
     rlat = read_viirs_h5_sds(dir + gfilename(j), slat)
     slon = '/All_Data/VIIRS-MOD-GEO-TC_All/Longitude'
     rlon = read_viirs_h5_sds(dir + gfilename(j), slon)
     saod = '/All_Data/VIIRS-Aeros-Opt-Thick-IP_All/faot550'
     raod = read_viirs_h5_sds(dir + filename(j), saod)
     index1 = WHERE(rlat LT -90.0, nindex1)
     IF (nindex1 GT 0) THEN BEGIN
      rlat(index1) = 0.0
      raod(index1) = 0.0
     ENDIF
     index2 = WHERE(rlon LT -180.0, nindex2)
     IF (nindex2 GT 0) THEN BEGIN
      rlon(index2) = 0.0
      raod(index2) = 0.0
     ENDIF
     lat(0:(np-1), (nl*j):(nl*(j+1)-1))   = rlat
     lon(0:(np-1), (nl*j):(nl*(j+1)-1))   = rlon
     aod(0:(np-1), (nl*j):(nl*(j+1)-1))   = raod
    ENDFOR
;  TO AVERAGE THE AOD IN ONE GRID BOX
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
;  CONVERT TO 2 DIMENSION DATA
    OPENR, lun, file, /get_lun
    alat     = FLTARR(gridsize_lat, gridsize_lon)
    alon     = FLTARR(gridsize_lat, gridsize_lon)
    aaod     = FLTARR(gridsize_lat, gridsize_lon)
    tmplat   = 0.0
    tmplon   = 0.0
    tmpaod   = 0.0
    FOR m = 0, gridsize_lat-1 DO BEGIN
     FOR k = 0, gridsize_lon-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmpaod, count
      alat(m,k) = tmplat
      alon(m,k) = tmplon
      aaod(m,k) = tmpaod
     ENDFOR
    ENDFOR


;  PLOT THE AOD GRID ONTO MAP
    SET_PLOT, 'ps'
    DEVICE, filename = 'plot_viirs_' +                          $
            STRMID(AllFileName(StartInx(i)), 0, 19) + '_grid.ps',    $
            xsize = 7., ysize=10, xoffset = 0.5, yoffset = 0.5, $
            /inches, /color, bits=8
;  LOAD COLOR TABLE
    MYCT, 33, ncolors = 102, range = [0.0, 1]
    title = 'AOD(VIIRS IVAOT 550nm) ' +                $
            STRMID(AllFileName(StartInx(i)), 11, 17) + $
            STRMID(AllFileName(EndInx(i)), 28, 9)

;  LOAD COLOR TABLE
    TVMAP, transpose(aaod), /grid,$
           LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, sample = 4, $
           title = title, $
           /cbar,DIVISIONS = 7, maxdata = 1.0, mindata = 0.1, $
           CBMIN = 0.10, CBMAX = 1.00, /COUNTRIES, /COAST,    $
           MIN_VALID = 0.1
    DEVICE, /close
    FREE_LUN, lun
   ENDFOR

END
