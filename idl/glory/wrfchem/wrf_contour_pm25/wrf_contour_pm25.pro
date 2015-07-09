; $ID: wrf_contour_pm25.pro V01 04/12/2012 11:30 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_pm25 READ WRF OUTPUT AND PLOT IT IN ONE LAYER.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY CUI GE. (NOT QUITE CLEAR)
;  (2 ) MODIFIED BY BRUCE. (04/12/2012)
;******************************************************************************

;  LOAD PROCEDURES AND FUNCTIONS
   @/home/bruce/program/idl/idl_lib/plot_wrf_contour.pro
   @/home/bruce/program/idl/idl_lib/color_contour.pro
   @/home/bruce/program/idl/idl_lib/ncdfread.pro

   filedir  = '/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/'
   filelist = 'wrfout_d01_2008'

   readcol, filedir + filelist, filename, format='A'  
   fn       = N_ELEMENTS(filename)  

;  SET UP STUDY REGION
   minlat   = -15.0
   maxlat   =  35.0
   minlon   = -25.0
   maxlon   =  45.0
   region   = [minlat, minlon, maxlat, maxlon]

;  SET UP VERTIVAL LAYER
   layer    = 0

;  SET UP COLOR BAR VALUE
   minval   = 2.0
   maxval   = 42.0

;  DEFINE COLOR TABLE
   myct, 33, ncolor=102

;  SET UP WORKSTATION
   SET_PLOT, 'PS'
   DEVICE, file='plot_wrf_pm25.ps', xsize = 7, ysize= 10, $
           xoffset = 0.5, yoffset = 0.5, /inches, /color, bits=8

   FOR i=0, fn-1 DO BEGIN
    nc_file = filedir+filename(i)
;  READ OUT LATITUDE, LONGITUDE, PM2.5, AND AOD
    ncdfread, nc_file, 'XLAT', xlat, xlat_dim
    ncdfread, nc_file, 'XLONG', xlon, xlong_dim
    ncdfread, nc_file, 'PM2_5_DRY',pm25,pm25_dim
    ncdfread, nc_file, 'Times', times,times_dim
    ncdfread, nc_file, 'TAUAER1',pm25,pm25_dim  

    lpm25 = pm25(*,*,layer)
    llat  = xlat(*,*,layer)
    llon  = xlon(*,*,layer)
    date  = string(times)

;  CALL SUBROUTINE plot_wrf_contour TO PLOT CONTOUR
    plot_wrf_contour, lpm25, llat, llon, minaod=minval, maxaod=maxval, $
                      region_limit=region, title = date,               $
                      unit = '!4l!6gm!u-3!n'
    PRINT, 'NOW WORKING ON : ', date
   ENDFOR

;  CLOSE PLOT DEVICE
   device, /close

;  End of program
   End
   
  

