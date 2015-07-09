; $ID: wrf_contour_pm25_height.ncl V01 05/19/2012 10:38 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_pm25_height READS AND PLOTS PM2.5 MASS CONCENTRATION 
;  CONTOUR AND OVERLAID WITH HEIGHT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/19/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_height.ncl"


begin
;  SET UP THE PLOT PLATFORM
   type      = "x11" 
;  type      = "pdf"
   wks       = gsn_open_wks(type, "1plt_contour_pm25_height_sahel_v01")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/"
   filelist  = "wrfout_d01_2008"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
;                          WA       CA     SAHEL 
   minlat    = -15.0     ; 30.0    ;10    ;-15.0
   maxlat    =  35.0     ; 45.0    ;45    ; 35.0
   minlon    = -25.0     ;-130.0   ;-115  ;-25.0
   maxlon    =  45.0     ;-110.0   ;-65   ; 45.0
   pressure  =  700.
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    a    = addfile(dir + filename(i) + ".nc", "r")
    time = charactertostring(a->Times(0, :))
    print("NOW WORKING ON : " + time)
    lat  = a->XLAT
    lon  = a->XLONG
    pm25 = a->PM2_5_DRY(0, 0, :, :)
    pm25@lat2d = a->XLAT(0,:,:)
    pm25@lon2d = a->XLONG(0,:,:)
    z          = wrf_user_getvar(a, "z",0)        ; grid point height
    z          = z/10.
    z@lat2d    = a->XLAT(0,:,:)
    z@lon2d    = a->XLONG(0,:,:)
    pa         = a->P(0,:,:,:)
    pb         = a->PB(0,:,:,:)
    p          = pa+pb
    p@lat2d    = a->XLAT(0,:,:)
    p@lon2d    = a->XLONG(0,:,:)
    z_plane    = gsn_csm_user_intrp3d( z,p,"h",pressure,0.,False)


;  CALL SUBROUTINE plot_wrf_contour_height.ncl TO PLOT CONTOUR 
;  AND HEIGHT
    plot_wrf_contour_height \
             (wks, minlat, maxlat, minlon, maxlon, \
              time, z_plane, pm25, \
              plot)

   end do
end
