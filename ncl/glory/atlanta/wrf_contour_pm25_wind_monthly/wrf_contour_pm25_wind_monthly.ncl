; $ID: wrf_contour_pm25_wind_monthly.ncl V01 09/11/2012 20:42 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_pm25_wind_monthly READS AND PLOTS PM2.5 MASS 
;  CONCENTRATION CONTOUR AND OVERLAID WITH WIND.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/11/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/plot_wrf_contour_vector_pm25_marker_month_hourly.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/plot_wrf_contour_vector_pm25_marker_monthly.ncl"


begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11" 
;  type      = "pdf"
   type      = "png"
   wks       = gsn_open_wks(type, "1plt_contour_pm25_wind_monthly_atlanta_v01_d01_surface")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/home/bruce/sshfs/tw/model/wrfchem33_1/WRFV3/test/em_real/wrfout_atlanta_v01/"
   filelist  = "2012_wrfout_d01"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
;                          WA       CA     SAHEL  ATLANTA  A-CITY  A-SMALL
   minlat    =  25.0     ; 30.0    ;10    ;-15.0  ; 25.0   ; 32.0  ; 33.0
   maxlat    =  40.0     ; 45.0    ;45    ; 35.0  ; 40.0   ; 34.5  ; 34.5
   minlon    = -95.0     ;-130.0   ;-115  ;-25.0  ;-95.0   ;-86.5  ; 85.0
   maxlon    = -75.0     ;-110.0   ;-65   ; 45.0  ;-75.0   ;-82.5  ; 83.5

; SET UP SITE INFO
   slat      = (/33.76/)
   slon      = (/-84.4/)

;  SPECIFY SURFACE AND HIGH LEVEL
;  surface   : 0
;  700mba    : 8
   level     = 0
   plot      = new(1, graphic)

   b         = addfile(dir + filename(0) + ".nc", "r")
   pm25      = b->PM2_5_DRY(0, :, :, :)
   lat       = b->XLAT
   lon       = b->XLONG
   ndim      = dimsizes(pm25)
   nlevel    = ndim(0)
   nlat      = ndim(1)
   nlon      = ndim(2)
   ntime     = 24
   nday      = 60
   pm25_month= new((/nday, ntime, nlevel, nlat, nlon/), float)
   u_month   = new((/nday, ntime, nlevel, nlat, nlon/), float)
   v_month   = new((/nday, ntime, nlevel, nlat, nlon/), float)
   pm25_month_hourly= new((/ntime, nlevel, nlat, nlon/), float)
   u_month_hourly   = new((/ntime, nlevel, nlat, nlon/), float)
   v_month_hourly   = new((/ntime, nlevel, nlat, nlon/), float)
   pm25_month!0 = "day"
   pm25_month!1 = "time"
   u_month!0    = "day"
   u_month!1    = "time"
   v_month!0    = "day"
   v_month!1    = "time"
   pm25_month_hourly!0 = "time"
   u_month_hourly!0    = "time"
   v_month_hourly!0    = "time"

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   iday  = 0
   itime = 0
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
    if (itime .lt. ntime) then
     pm25_month(iday, itime, :, :, :) = pm25
     u_month(iday, itime, :, :, :)    = u
     v_month(iday, itime, :, :, :)    = v
     itime = itime + 1
    else if (itime .ge. ntime) then
     iday  = iday +1
     itime = 0
     pm25_month(iday, itime, :, :, :) = pm25
     u_month(iday, itime, :, :, :)    = u
     v_month(iday, itime, :, :, :)    = v
    end if
    end if
   end do

   pm25_month_hourly = dim_avg_n_Wrap(pm25_month, 0)
   u_month_hourly    = dim_avg_n_Wrap(u_month, 0)
   v_month_hourly    = dim_avg_n_Wrap(v_month, 0)

;  PLOT HOURLY AVERAGE IMAGE
   do j = 0, ntime-1

;  CALL SUBROUTINE plot_wrf_contour_vector_pm25_marker_month_hourly.ncl TO PLOT CONTOUR 
;  AND VECTOR
    plot_wrf_contour_vector_pm25_marker_month_hourly \
             (wks, minlat, maxlat, minlon, maxlon, slat, slon, j,             \
              u_month_hourly(j, level, :, :), v_month_hourly(j, level, :, :), \
              pm25_month_hourly(j, level, :, :), \
              plot)
   end do

;  PLOT MONTHLY AVERAGE IMAGE
    pm25_monthly      = dim_avg_n_Wrap(pm25_month_hourly, 0)
    u_monthly         = dim_avg_n_Wrap(u_month_hourly, 0)
    v_monthly         = dim_avg_n_Wrap(v_month_hourly, 0)

;  CALL SUBROUTINE plot_wrf_contour_vector_pm25_marker_monthly.ncl TO PLOT CONTOUR 
;  AND VECTOR
    plot_wrf_contour_vector_pm25_marker_monthly \
             (wks, minlat, maxlat, minlon, maxlon, slat, slon, \
              u_monthly(level, :, :), v_monthly(level, :, :),  \
              pm25_monthly(level, :, :), \
              plot)

end
