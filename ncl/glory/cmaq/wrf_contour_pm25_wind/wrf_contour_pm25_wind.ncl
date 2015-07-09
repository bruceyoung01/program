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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/cmaq/plot_wrf_contour_vector_pm25.ncl"


begin
;  SET UP THE PLOT PLATFORM
   type      = "x11" 
;  type      = "pdf"
;  type      = "ps"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_contour_pm25_wind_cmaq_v02_smoke_dust_surface")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_cmaq_2006_summer/wrfout_test/"
   filelist  = "2006_wrfout_d01"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
;                         CMAQ
   minlat    =  25.0     ; 25.0
   maxlat    =  50.0     ; 50.0
   minlon    = -130.0    ;-130.0
   maxlon    = -65.0     ;-65.0
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
    if (level .eq. 8) then
     pm25 = pm25/1.5 + 1.0
    end if
    u    = wrf_user_getvar(a, "ua", 0)
    v    = wrf_user_getvar(a, "va", 0)
    pm25@lat2d = a->XLAT(0,:,:)
    pm25@lon2d = a->XLONG(0,:,:)
    u@lat2d    = a->XLAT(0,:,:)
    u@lon2d    = a->XLONG(0,:,:)
    v@lat2d    = a->XLAT(0,:,:)
    v@lon2d    = a->XLONG(0,:,:)

;  CALL SUBROUTINE plot_wrf_contour_vector_pm25.ncl TO PLOT CONTOUR 
;  AND VECTOR
    plot_wrf_contour_vector_pm25 \
             (wks, minlat, maxlat, minlon, maxlon, time, \
              u(level, :, :), v(level, :, :), pm25(level, :, :), \
              plot)

   end do
end
