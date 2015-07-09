; $ID: wrf_contour_pm25_wind_mixed.ncl V01 05/18/2012 10:36 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_pm25_wind_mixed READS AND PLOTS PM2.5 MASS CONCENTRATION 
;  CONTOUR AND OVERLAID WITH WIND. PM2.5 IS FROM WRFCHEM3.1.1, WHILE WIND IS 
;  FROM WRFCHEM3.3. THAT'S WHY CALL IT mixed.
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_vector_pm25.ncl"


begin
;  SET UP THE PLOT PLATFORM
   type      = "x11" 
;  type      = "pdf"
;  type      = "ps"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_contour_pm25_wind_sahel_v01_smoke_dust_surface")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir1      = "/home/bruce/sshfs/tw/model/wrfchem33_3/WRFV3/test/em_real/wrfout/"
   filelist1 = "2008_wrfout_d01"
   filename1 = asciiread(dir1 + filelist1, -1, str)
   nfile1    = dimsizes(filename1)

   dir2      = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/"
   filelist2 = "2008_wrfout_d01"
   filename2 = asciiread(dir2 + filelist2, -1, str)
   nfile2    = dimsizes(filename2)

;  SET UP LIMITED REGION
;                          WA       CA     SAHEL 
   minlat    = -15.0     ; 30.0    ;10    ;-15.0
   maxlat    =  35.0     ; 45.0    ;45    ; 35.0
   minlon    = -25.0     ;-130.0   ;-115  ;-25.0
   maxlon    =  45.0     ;-110.0   ;-65   ; 45.0
;  SPECIFY SURFACE AND HIGH LEVEL
;  surface   : 0
;  700mba    : 8
   level     = 0
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile1-1
    a    = addfile(dir1 + filename1(i) + ".nc", "r")
    b    = addfile(dir2 + filename2(i) + ".nc", "r")
    time = charactertostring(a->Times(0, :))
    print("NOW WORKING ON : " + time)
    lat  = a->XLAT
    lon  = a->XLONG
    pm25 = a->PM2_5_DRY(0, :, :, :)
    u    = wrf_user_getvar(b, "ua", 0)
    v    = wrf_user_getvar(b, "va", 0)
    pm25@lat2d = a->XLAT(0,:,:)
    pm25@lon2d = a->XLONG(0,:,:)
    u@lat2d    = b->XLAT(0,:,:)
    u@lon2d    = b->XLONG(0,:,:)
    v@lat2d    = b->XLAT(0,:,:)
    v@lon2d    = b->XLONG(0,:,:)


;  CALL SUBROUTINE plot_wrf_contour_vector_pm25.ncl TO PLOT CONTOUR 
;  AND VECTOR
    plot_wrf_contour_vector_pm25 \
             (wks, minlat, maxlat, minlon, maxlon, time, \
              u(level, :, :), v(level, :, :), pm25(level, :, :), \
              plot)

   end do
end
