; $ID : modis_fire_count_monthly.ncl V01 10/04/2012 11:00 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM modis_fire_count_monthly READS MODIS THERMAL ANOMALIES, FIRES, & 
;  BIOMASS BURNING PRODUCT (MOD14/MYD14), GRIDS MODIS AOD, PLOTS GRIDED MODIS 
;  FIRE COUNTS WITH CONTOUR.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED FROM modis_aod_ncep_wind_monthly.ncl. (07/29/2012)
;  (2 ) ORIGINALLY WRITTEN BY BRUCE. (10/04/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/int2string.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/ne_ks/ydn2md.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/ne_ks/process_day_mod14.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/ne_ks/read_modis_mod14_1day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/ne_ks/pixel_to_grid_degree_1day_mod14.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/ne_ks/plot_modis_contour_fire_count.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/ne_ks/plot_modis_contour_fire_count_monthly.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_modis_fire_count_monthly_terra_v01_2005")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"

;  SET DIRECTORY ADN FILE NAME FOR MODIS AOD
   mdir       = "/home/bruce/sshfs/tw/parallel/data/satellite/modis/ne_ks/mod14/2005/"
   mflist     = "2005mod14"
   mfname     = asciiread(mdir + mflist, -1, "string")
   nmfname    = dimsizes(mfname)

;  SET UP LIMITED REGION
;                     NE_KS
   minlat     = 35.0  ;35.0
   maxlat     = 45.0  ;45.0
   minlon     =-105.0 ;-105.0
   maxlon     =-90.0  ;-90.0
;  GRID INTERVAL
   lat_interval = 0.1
   lon_interval = 0.1
;  CALCULATE GRID SIZE DEPENDING ON GRID INTERVAL AND REGION LIMIT
   nlat       = floattoint((maxlat-minlat)/lat_interval) + 1
   nlon       = floattoint((maxlon-minlon)/lon_interval) + 1

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod14
   tmpnday    = 400
   nday       = new(1, integer, bv1)
   startinx   = new(tmpnday, integer, bv1)
   endinx     = new(tmpnday, integer, bv1)
   year       = new(tmpnday, integer, bv1)
   mon        = new(tmpnday, integer, bv1)
   date       = new(tmpnday, integer, bv1)
   times      = new(tmpnday, string,  bv0)
   timee      = new(tmpnday, string,  bv0)
   dayname    = new(tmpnday, string,  bv0)
   daynum     = new(tmpnday, integer, bv1)

;  CALL SUBROUTINE process_day_mod14.ncl TO READ OUT INFO FROM MODIS FILE NAME
   process_day_mod14(mdir, mflist, logic_leap,         \
                     nday, startinx, endinx, year, mon,\
                     date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl FOR PER DAY
   mnp        = 5000
   mlat       = new((/mnp/), float, bv2)
   mlon       = new((/mnp/), float, bv2)
   mfp        = new((/mnp/), float, bv2)

;  DECLARE VARIABLES FOR SUBROUTINE pixel_to_grid_degree_1day.ncl
   grid_lat   = new((/nlat, nlon/), float, bv2)
   grid_lon   = new((/nlat, nlon/), float, bv2)
   grid_fp    = new((/nlat, nlon/), float, bv2)

;  DECLARE TOTAL FIRE COUNTS WITH LATITUDE AND LONGITUDE FOR ALL DAYS
   tgrid_fp   = new((/nlat, nlon/), float, bv2)

;  DO DAY LOOP
   maod     = 0.0
   icount   = 0
   tgrid_fp = 0.0
   do iday = 0, nday-1

    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_modis_mod14_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE.
    read_modis_mod14_1day \
    (mdir, bv0, iday, startinx, endinx, mfname, mlat, mlon, mfp)

;  CALL SUBROUTINE pixel_to_grid_degree_1day_mod14.ncl TO GRID AOD DATA
    pixel_to_grid_degree_1day_mod14 \
    (lat_interval, lon_interval, minlat, maxlat, minlon, maxlon, \
     nlat, nlon, mlat, mlon, mfp, grid_lat, grid_lon, grid_fp)

    grid_fp@lat2d = grid_lat
    grid_fp@lon2d = grid_lon

;  CALL SUBROUTINE plot_modis_contour_fire_count.ncl TO PLOT 
;  FIRE COUNTS CONTOUR
    plot_modis_contour_fire_count  \
    (wks, minlat, maxlat, minlon, maxlon, grid_fp, date_display)

;  CALCULATE TOTAL DATA
    tgrid_fp = tgrid_fp + grid_fp

    delete([/date_display/])
    icount = icount + 1
   end do

   print(max(tgrid_fp))
   print("=========================================================")
   print("              START TO PROCESS MONTHLY DATA")
   month_display = int2string(year(0));+ "-" + mon(0)
;  START TO PLOT MONTHLY AVERAGE AOD AND WIND
   tgrid_fp@lat2d = grid_lat
   tgrid_fp@lon2d = grid_lon
;  CALL SUBROUTINE plot_modis_contour_fire_count_monthly.ncl TO PLOT 
;  FIRE COUNTS CONTOUR
    plot_modis_contour_fire_count_monthly  \
    (wks, minlat, maxlat, minlon, maxlon, tgrid_fp, month_display)
end
