; $ID: wrf_contour_pm25_wind.ncl V01 05/18/2012 10:36 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_pm25_wind READS AND PLOTS PM2.5 MASS CONCENTRATION 
;  CONTOUR AND OVERLAID WITH WIND.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/ne/plot_wrf_contour_vector_pm25_marker.ncl"


begin
;  SET UP THE PLOT PLATFORM
   type      = "x11" 
;  type      = "pdf"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_contour_pm25_wind_ne_v01_d01_FLAMBE")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/home/bruce/sshfs/tw/model/wrfchem33_1/WRFV3/test/em_real/wrfout_ne_nei_flambe/"
   filelist  = "2011_wrfout_d01"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
;                        OMALINK  NE_NEST2     NE_NEST1    NE      WA       CA     SAHEL 
   minlat    = 25.0      ;40.5    ;39.5       ; 30.0    ; 25.0   ; 30.0    ; 10    ;-15.0
   maxlat    = 45.0      ;41.5    ;42.0       ; 43.0    ; 45.0   ; 45.0    ; 45    ; 35.0
   minlon    =-115.0     ;-97.0   ;-99.0      ;-115.0   ;-115.0  ;-130.0   ;-115   ;-25.0
   maxlon    =-90.0      ;-95.5   ;-94.5      ;-93.0    ;-90.0   ;-110.0   ;-65    ; 45.0

; SET UP SITE INFO
   slat      = (/-41.27, -40.85/)
   slon      = (/-95.92, -96.6/)

;  DEFINE SCALE FACTOR
   factor    = 1
;  SPECIFY SURFACE AND HIGH LEVEL
;  surface   : 0
;  700mba    : 8
   level     = 0
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    ;wks       = gsn_open_wks(type, "1plt_contour_pm25_wind_ne_v01_d03_small" + sprinti("%0.4i", i))
    ;gsn_define_colormap(wks,"WhGrYeOrReVi200")
    a    = addfile(dir + filename(i) + ".nc", "r")
    time = charactertostring(a->Times(0, :))
    print("NOW WORKING ON : " + time)
    lat  = a->XLAT
    lon  = a->XLONG
    pm25 = a->PM2_5_DRY(0, :, :, :)
    pm25 = pm25*factor
    u    = wrf_user_getvar(a, "ua", 0)
    v    = wrf_user_getvar(a, "va", 0)
    pm25@lat2d = a->XLAT(0,:,:)
    pm25@lon2d = a->XLONG(0,:,:)
    u@lat2d    = a->XLAT(0,:,:)
    u@lon2d    = a->XLONG(0,:,:)
    v@lat2d    = a->XLAT(0,:,:)
    v@lon2d    = a->XLONG(0,:,:)
    print(max(pm25))
    print(min(pm25))

;  CALL SUBROUTINE plot_wrf_contour_vector_pm25_marker.ncl TO PLOT CONTOUR 
;  AND VECTOR
    plot_wrf_contour_vector_pm25_marker \
             (wks, minlat, maxlat, minlon, maxlon, slat, slon, time, \
              u(level, :, :), v(level, :, :), pm25(level, :, :),     \
              plot)

   end do
end
