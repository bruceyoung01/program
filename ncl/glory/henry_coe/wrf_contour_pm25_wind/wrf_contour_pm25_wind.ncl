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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/henry_coe/plot_wrf_contour_vector_pm25_marker.ncl"


begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11" 
;  type      = "pdf"
   type      = "png"
   wks       = gsn_open_wks(type, "1plt_contour_pm25_wind_henry_coe_v01_d02_flambe")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/home/bruce/sshfs/tw/model/wrfchem33_5/WRFV3/test/em_real/wrfout/"
   filelist  = "2011_wrfout_d02"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
;                         HENRY_COE HENRY_COE_D02
   minlat    =  36.0     ; 30.0     ; 36.0
   maxlat    =  38.0     ; 45.0     ; 38.0
   minlon    =-123.0     ;-126.0    ;-123.0
   maxlon    =-120.0     ;-110.0    ;-120.0

; SET UP SITE INFO
;              HENRY_COE
  slat       = (/37.207/)
  slon       = (/-121.541/)
  nsite      = dimsizes(slat)

;  SPECIFY SURFACE AND HIGH LEVEL
;  surface   : 0
;  700mba    : 8
   level     = 0
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    a    = addfile(dir + filename(i) + ".nc", "r")
    time = charactertostring(a->Times(0, :))
    print("NOW WORKING ON : " + time)
    lat  = a->XLAT
    lon  = a->XLONG
    pm25 = a->PM2_5_DRY(0, :, :, :)
    u    = wrf_user_getvar(a, "ua", 0)
    v    = wrf_user_getvar(a, "va", 0)
    pm25@lat2d = a->XLAT(0,:,:)
    pm25@lon2d = a->XLONG(0,:,:)
    u@lat2d    = a->XLAT(0,:,:)
    u@lon2d    = a->XLONG(0,:,:)
    v@lat2d    = a->XLAT(0,:,:)
    v@lon2d    = a->XLONG(0,:,:)

;  CALL SUBROUTINE plot_wrf_contour_vector_pm25_marker.ncl TO PLOT CONTOUR 
;  AND VECTOR
    plot_wrf_contour_vector_pm25_marker \
             (wks, minlat, maxlat, minlon, maxlon, slat, slon, time, \
              u(level, :, :), v(level, :, :), pm25(level, :, :), \
              plot)

   end do
end
