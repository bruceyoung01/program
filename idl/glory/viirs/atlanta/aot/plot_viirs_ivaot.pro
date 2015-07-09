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
@/home/bruce/program/idl/idl_lib/color_imagemap.pro
@/home/bruce/program/idl/idl_lib/plot_single_gradule_mod04.pro

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
   maxaod = 0.8

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

;  DO LOOP OF # OF FILE NAMES
   FOR i = 0, Nday-1 DO BEGIN
    n = endinx(i) - startinx(i) + 1
;  EXTRACT DATE FROM FILE NAME
    date = STRARR(n)
    FOR nc = 0, n-1 DO BEGIN
     date(nc) = STRMID(Allfilename(startinx(i)), 0, 19)
    ENDFOR
;  OPEN A NEW FILE TO WRITE GRIDED LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
    file = date(0) + '.txt'
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
     PRINT, 'NOW WORKING ON : ', j + 1
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

;  PLOT THE AOD GRID ONTO MAP
    SET_PLOT, 'ps'
    DEVICE, filename = 'plot_viirs_' +                          $
            STRMID(AllFileName(StartInx(i)), 0, 19) + '.ps',    $
            xsize = 7., ysize=10, xoffset = 0.5, yoffset = 0.5, $
            /inches, /color, bits=8
;  LOAD COLOR TABLE
    load_clt, colors
;  coordinate for ploting
    xa = 0.2    & xb  = 0.85  & ya = 0.5    & yb  = 0.90
    dx = -0.014 & ddx = 0.007 & dy = +0.008 & ddy = 0.005
    title = 'AOD(VIIRS IVAOT 550nm) ' +                $
            STRMID(AllFileName(StartInx(i)), 11, 17) + $
            STRMID(AllFileName(EndInx(i)), 28, 9)

    plot_mod04_ref, aod, maxaod, minaod,                  $
                    lat, lon, np, nl*(n), region, colors, $
                    xa,xb,ya,yb,dx,dy,ddx,ddy, title

    DEVICE, /close

   ENDFOR

END
