; $ID: wrf_polymarker_dust_smoke_wind_2dct.ncl V01 04/16/2013 10:16 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_polymarker_dust_smoke_wind_2dct READS AND PLOTS DUST AND SMOKE 
;  MASS CONCENTRATION WITH POLYMARKER AND OVERLAID WITH WIND.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/16/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_polymarker_vector_dust_smoke.ncl"


begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11" 
   type      = "pdf"
;  type      = "ps"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_wrf_polymarker_dust_smoke_wind_2dct_700mba_v04")
   gsn_define_colormap(wks,"color_map_2d_200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF SMOKE OUTPUT DIRECTORY
   dir1      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_650/wrfout/"
   filelist1 = "2008_wrfout_d01_select"
   filename1 = asciiread(dir1 + filelist1, -1, str)
   nfile     = dimsizes(filename1)

;  SPECIFY WRF SMOKE AND DUST OUTPUT DIRECTORY
   dir2      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_dust_650/wrfout/"
   filelist2 = "2008_wrfout_d01_select"
   filename2 = asciiread(dir2 + filelist2, -1, str)

;  SET UP LIMITED REGION
   minlat    = -15.0
   maxlat    =  35.0
   minlon    = -25.0
   maxlon    =  45.0
;  SPECIFY SURFACE AND HIGH LEVEL
;  surface   : 0
;  700mba    : 8
   level     = 8
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    a     = addfile(dir1 + filename1(i) + ".nc", "r")
    b     = addfile(dir2 + filename2(i) + ".nc", "r")
    time  = charactertostring(a->Times(0, :))
    print("NOW WORKING ON : " + time)
    lat   = a->XLAT(0, :, :)
    lon   = a->XLONG(0, :, :)
    u     = wrf_user_getvar(a, "ua", 0)
    v     = wrf_user_getvar(a, "va", 0)
    smoke = a->PM2_5_DRY(0, level, :, :)
    aird  = a->ALT(0, level, :, :)
    dust1 = b->DUST_1(0, level, :, :)
    dust2 = b->DUST_2(0, level, :, :)
    dust3 = b->DUST_3(0, level, :, :)
    dust4 = b->DUST_4(0, level, :, :)
    dust5 = b->DUST_5(0, level, :, :)
    dust  = (dust1 + dust2 + dust3 + dust4 + dust5)*aird
    pm    = smoke + dust
    smoke@lat2d= lat
    smoke@lon2d= lon
    dust@lat2d = lat
    dust@lon2d = lon
    pm@lat2d   = lat
    pm@lon2d   = lon
    u@lat2d    = lat
    u@lon2d    = lon
    v@lat2d    = lat
    v@lon2d    = lon

;  CALL SUBROUTINE plot_wrf_polymarker_vector_dust_smoke.ncl TO PLOT POLYMARKER
;  AND VECTOR
    plot_wrf_polymarker_vector_dust_smoke \
   (wks, bv2, minlat, maxlat, minlon, maxlon, time, \
    lat, lon, u(level, :, :), v(level, :, :), smoke, pm)

   end do
end
