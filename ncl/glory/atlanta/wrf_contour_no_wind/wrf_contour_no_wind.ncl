; $ID: wrf_contour_no_wind.ncl V01 05/18/2012 10:36 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_no_wind READS AND PLOTS no CONCENTRATION 
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/plot_wrf_contour_vector_no_marker.ncl"


begin
;  SET UP THE PLOT PLATFORM
   type      = "x11" 
;  type      = "pdf"
;  type      = "png"
;  wks       = gsn_open_wks(type, "1plt_contour_no_wind_atlanta_v01_d03")
;  gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/home/bruce/sshfs/tw/model/wrfchem33_1/WRFV3/test/em_real/wrfout/"
   filelist  = "2012_wrfout_d03"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
;                          WA       CA     SAHEL  ATLANTA  A-CITY  A-SMALL
   minlat    =  33.0     ; 30.0    ;10    ;-15.0  ; 25.0   ; 32.0  ; 33.0
   maxlat    =  34.5     ; 45.0    ;45    ; 35.0  ; 40.0   ; 34.5  ; 34.5
   minlon    = -85.0     ;-130.0   ;-115  ;-25.0  ;-95.0   ;-86.5  ; 85.0
   maxlon    = -83.5     ;-110.0   ;-65   ; 45.0  ;-75.0   ;-82.5  ; 83.5

; SET UP SITE INFO
   slat      = (/33.76/)
   slon      = (/-84.4/)

;  DEFINE SCALE FACTOR
   factor    = 1000
;  SPECIFY SURFACE AND HIGH LEVEL
;  surface   : 0
;  700mba    : 8
   level     = 0
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    wks       = gsn_open_wks(type, "1plt_contour_no_wind_atlanta_v01_d03_small" + sprinti("%0.4i", i))
    gsn_define_colormap(wks,"WhGrYeOrReVi200")
    a    = addfile(dir + filename(i) + ".nc", "r")
    time = charactertostring(a->Times(0, :))
    print("NOW WORKING ON : " + time)
    lat  = a->XLAT
    lon  = a->XLONG
    no   = a->no(0, :, :, :)
    no   = no*factor
    u    = wrf_user_getvar(a, "ua", 0)
    v    = wrf_user_getvar(a, "va", 0)
    no@units   = "ppbv"
    no@lat2d   = a->XLAT(0,:,:)
    no@lon2d   = a->XLONG(0,:,:)
    u@lat2d    = a->XLAT(0,:,:)
    u@lon2d    = a->XLONG(0,:,:)
    v@lat2d    = a->XLAT(0,:,:)
    v@lon2d    = a->XLONG(0,:,:)


;  CALL SUBROUTINE plot_wrf_contour_vector_no_marker.ncl TO PLOT CONTOUR 
;  AND VECTOR
    plot_wrf_contour_vector_no_marker \
             (wks, minlat, maxlat, minlon, maxlon, slat, slon, time, \
              u(level, :, :), v(level, :, :), no(level, :, :),     \
              plot)

   end do
end
