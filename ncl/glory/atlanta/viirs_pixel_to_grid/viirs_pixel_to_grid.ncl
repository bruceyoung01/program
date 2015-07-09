;  $ID: viirs_pixel_to_grid.ncl V01 01/31/2013 15:48 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_pixel_to_grid READS VIIRS PIXEL DATA AND GRID IT INTO 
;  DIFFERENT GRID BOX SIZE IN DEGREE, AND CALCULATES A TIME PERIOD AVERAGE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/31/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/process_day_viirs.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/read_viirs_aod_1day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/pixel_to_grid_degree_1day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/plot_viirs_contour_aod.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_viirs_grid_atlanta_v01")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"

;  SET DIRECTORY AND FILE NAME FOR VIIRS AOD
   dir        = "/home/bruce/sshfs/shw/data/satellite/NPP/atlanta/all_data/day/"
   gflist     = "GAERO_list_201208"
   vflist     = "VAOOO_list_201208"
   gfname     = asciiread(dir + gflist, -1, "string")
   vfname     = asciiread(dir + vflist, -1, "string")
   ngfname    = dimsizes(gfname)
   nvfname    = dimsizes(vfname)
   
;  SET UP LIMITED REGION FOR ATLANTA
   minlat     = 33.0
   maxlat     = 34.5
   minlon     =-85.5
   maxlon     =-83.5
;  GRID INTERVAL
   lat_interval = 0.1
   lon_interval = 0.1
;  CALCULATE GRID SIZE DEPENDING ON GRID INTERVAL AND REGION LIMIT
   nlat       = floattoint((maxlat-minlat)/lat_interval) + 1
   nlon       = floattoint((maxlon-minlon)/lon_interval) + 1

;  DECLARE VARIABLES FOR SUBROUTINE process_day_viirs
   tmpnday    = 31
   nday       = new(1, integer, bv1)
   startinx   = new(tmpnday, integer, bv1)
   endinx     = new(tmpnday, integer, bv1)
   year       = new(tmpnday, integer, bv1)
   mon        = new(tmpnday, integer, bv1)
   date       = new(tmpnday, integer, bv1)
   times      = new(tmpnday, integer, bv1)
   timee      = new(tmpnday, integer, bv1)
   dayname    = new(tmpnday, string,  bv0)
   daynum     = new(tmpnday, integer, bv1)

;  CALL SUBROUTINE process_day_viirs.ncl TO READ OUT INFO FROM VIIRS FILE NAME
   process_day_viirs(dir, gflist, logic_leap,          \
                     nday, startinx, endinx, year, mon,\
                     date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_viirs_aod_1day.ncl
   minpixel   = 0
   mnp        = 96
   mnl        = 400
   mfactor    = 5
   tmnp       = mnp*mfactor
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   maod       = new((/tmnp, mnl/), float, bv2)
   maod_qf    = new((/tmnp, mnl/), integer, bv1)

;  DECLARE VARIABLES FOR SUBROUTINE pixel_to_grid_degree_1day.ncl
   grid_lat   = new((/nlat, nlon/), float, bv2)
   grid_lon   = new((/nlat, nlon/), float, bv2)
   grid_aod   = new((/nlat, nlon/), float, bv2)
   grid_aod_monthly = new((/nlat, nlon/), float, bv2)

;  DO DAY LOOP
   maod     = 0.0
   grid_aod = 0.0
   icount   = 0
   grid_aod_monthly = 0.0
   do iday = 0, nday-1

    system("date") 
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_aod_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  AOD QUALITY FLAG, AND AOD FOR ONE DAY.
    read_viirs_aod_1day \
    (dir, bv0, iday, startinx, endinx, gfname, vfname, \
     mlat, mlon, maod_qf, maod)

;  CALL SUBROUTINE pixel_to_grid_degree_1day.ncl TO GRID AOD DATA
    pixel_to_grid_degree_1day \
    (lat_interval, lon_interval, minlat, maxlat, minlon, maxlon, \
     nlat, nlon, mlat, mlon, maod_qf, maod, grid_lat, grid_lon, grid_aod)

    grid_aod@lat2d = grid_lat
    grid_aod@lon2d = grid_lon

;  CALL SUBROUTINE plot_viirs_contour_aod.ncl TO PLOT AOD CONTOUR
    plot_viirs_contour_aod  \
    (wks, minlat, maxlat, minlon, maxlon, \
     date_display, grid_aod)

     icount = icount + 1
     grid_aod_monthly = grid_aod_monthly + grid_aod
    delete([/date_display/])
   end do

   print("=========================================================")
   print("              START TO PROCESS MONTHLY DATA")
   month_display = year(0) + "-" + mon(0)
   print("MONTH : " + month_display)
   grid_aod_monthly = grid_aod_monthly/icount

   grid_aod_monthly@lat2d = grid_lat
   grid_aod_monthly@lon2d = grid_lon

;  CALL SUBROUTINE plot_viirs_contour_aod.ncl TO PLOT AOD CONTOUR
    plot_viirs_contour_aod  \
    (wks, minlat, maxlat, minlon, maxlon, \
     month_display, grid_aod_monthly)


end
