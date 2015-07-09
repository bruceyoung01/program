; $ID: plot_viirs_aot.pro V01 04/15/2012 23:54 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_aot READS AND PLOTS NPP VIIRS AOT DATA.
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
@/home/bruce/program/idl/idl_lib/read_viirs_h5_sds.pro
@/home/bruce/program/idl/idl_lib/read_filelist.pro

;  SET UP NPP VIIRS DATA DIRECTORY AND FILE NAMES LIST
   dir   = '/home/bruce/sshfs/pfw/satellite/SeaWiFS/'
   flist = 'dbseawifs_list'

;  SET UP STUDY REGION
;  SAHEL
;  maxlat = 35.0
;  minlat =-10.0
;  maxlon = 45.0
;  minlon =-25.0
;  GLOBAL
   maxlat = 90.0
   minlat =-90.0
   maxlon = 180.0
   minlon =-180.0

;  CALL SUBROUTINE read_filelist.rpo TO READ FILE NAMES FROM FILELIST
   read_filelist, dir+flist, filename, nfile

;  DO LOOP OF # OF FILE NAMES
   FOR i = 0, nfile-1 DO BEGIN

;  CALL SUBROUTINE read_viirs_h5_sds.pro TO READ VARIABLES FROM NPP DATA
    saod  = 'aerosol_optical_thickness_550_land_ocean'
    aod   = read_viirs_h5_sds(dir + filename(i), saod)
    slat  = 'latitude'
    lat   = read_viirs_h5_sds(dir + filename(i), slat)
    nlat  = N_ELEMENTS(lat)
    slon  = 'longitude'
    lon   = read_viirs_h5_sds(dir + filename(i), slon)
    nlon  = N_ELEMENTS(lon)
;  READ YEAR, MONTH FROM FILE NAME
    year  = STRMID(filename(i), 25, 4)
    month = STRMID(filename(i), 29, 2)
;  CONVERT TO 2-DIMENSIONAL ARRAY
    alat  = FLTARR(nlon, nlat)
    alon  = FLTARR(nlon, nlat)
    FOR j = 0, nlon-1 DO BEGIN
     FOR k = 0, nlat-1 DO BEGIN
      alon(j, k) = lon(j)
      alat(j, k) = lat(k)
     ENDFOR
    ENDFOR

;  PLOT THE AOD GRID ONTO MAP
    SET_PLOT, 'ps'
    DEVICE, filename = 'plot_seawifs_aod' + year + month + '.ps', $
            xsize = 7., ysize=10, xoffset = 0.5, yoffset = 0.5, $
            /inches, /color, bits=8
;  LOAD COLOR TABLE
    MYCT, 33, ncolors = 102, range = [0.0, 1]
    TVMAP, aod, /grid,$
           LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, sample = 4, $
           title = 'AOD(SeaWiFS 550nm) '+  year + month, $ 
           /cbar,DIVISIONS = 6, maxdata = 1.0, mindata = 0.1, $
           CBMIN = 0.0, CBMAX = 1.00, /COUNTRIES, /COAST,  $
           MIN_VALID = 0.00001
    DEVICE, /close

   ENDFOR

END
