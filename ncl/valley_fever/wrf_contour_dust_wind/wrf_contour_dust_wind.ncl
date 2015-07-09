; $ID: wrf_contour_dust_wind.ncl V01 05/18/2012 10:36 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_dust_wind READS AND PLOTS DUST MASS CONCENTRATION 
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
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/valley_fever/plot_wrf_contour_vector_dust.ncl"


begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11" 
;  type      = "pdf"
;  type      = "ps"
   type      = "png"
   wks       = gsn_open_wks(type, "1plt_contour_dust_wind_700_v01")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/Volumes/TOSHIBA_3B/iproject/valley_fever/wrf_output/dust_1d/"
   filelist  = "wrfout_d01_list"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
   minlat    =  25.0
   maxlat    =  45.0
   minlon    = -125.0
   maxlon    = -95.0
;  SPECIFY SURFACE AND HIGH LEVEL
;  surface   : 0
;  700mba    : 8
   level     = 8
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    a     = addfile(dir + filename(i) + ".nc", "r")
    time  = charactertostring(a->Times(0, :))
    print("NOW WORKING ON : " + time)
    lat   = a->XLAT
    lon   = a->XLONG
    dust1 = a->DUST_1(0, :, :, :)
    dust2 = a->DUST_2(0, :, :, :)
    dust3 = a->DUST_3(0, :, :, :)
    dust4 = a->DUST_4(0, :, :, :)
    dust5 = a->DUST_5(0, :, :, :)
    dust  = dust1 + dust2 + dust3 + dust4 + dust5
    u     = wrf_user_getvar(a, "ua", 0)
    v     = wrf_user_getvar(a, "va", 0)
    dust@lat2d = a->XLAT(0,:,:)
    dust@lon2d = a->XLONG(0,:,:)
    u@lat2d    = a->XLAT(0,:,:)
    u@lon2d    = a->XLONG(0,:,:)
    v@lat2d    = a->XLAT(0,:,:)
    v@lon2d    = a->XLONG(0,:,:)


;  CALL SUBROUTINE plot_wrf_contour_vector_dust.ncl TO PLOT CONTOUR 
;  AND VECTOR
    plot_wrf_contour_vector_dust \
             (wks, minlat, maxlat, minlon, maxlon, time, \
              u(level, :, :), v(level, :, :), dust(level, :, :), \
              plot)

   end do
end
