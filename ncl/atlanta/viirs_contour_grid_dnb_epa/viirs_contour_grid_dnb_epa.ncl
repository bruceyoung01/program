;  $ID: viirs_contour_grid_dnb_epa.ncl V01 01/31/2013 15:48 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_grid_dnb_epa READS VIIRS PIXEL DATA AND GRID IT 
;  INTO DIFFERENT GRID BOX SIZE IN DEGREE, AND CALCULATES A TIME PERIOD AVERAGE.
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
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/process_day_viirs.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/select_viirs_epa_hourly_pixel.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/pixel_to_grid_degree_1day.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_viirs_contour_rad_epa.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_viirs_contour_grid_dnb_epa_v01")
   gsn_define_colormap(wks,"gsdtol")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"
   nfactor    = 10000000

;  SET DIRECTORY AND FILE NAME FOR VIIRS AOD
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/NPP/atlanta/all_data/night/"
   gflist     = "GDNBO_list"
   vflist     = "SVDNB_list"
   gfname     = asciiread(dir + gflist, -1, "string")
   vfname     = asciiread(dir + vflist, -1, "string")
   ngfname    = dimsizes(gfname)
   nvfname    = dimsizes(vfname)

;  SETUP SITE OBERVATION INFO
   sdir       = "/shared/aerosol/bruceyoung01/data/atlanta/epa/"
   sfname     = "AQS_PM25_hourly.txt"
;  site_id    = (/"131350002", "130630091", "130670003", "132230003", \
;                 "130890002", "130892001", "131210032", "131210039", \
;                 "131210055", "130670004", "130770002", "131510002"/)
   site_id    = (/"131350002", "130890002", "131210055", "130770002", \
                  "131510002"/)
;  site_id    = (/"130770002"/)
   nsite      = dimsizes(site_id)

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
   tmpnday    = 182
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

;  DECLARE VARIABLES FOR SUBSOURINTE read_epa_pm_hourly_allsite.ncl
   nrows      = 60000
   site_name  = new((/nrows, 1/), string, bv0)
   site_geo   = new((/nrows, 2/), float, bv2)
   site_date  = new((/nrows, 4/), integer, bv1)
   site_pm    = new((/nrows, 1/), float, bv2)

;  DECLARE ARRAY FOR SUBROUTINE read_epa_pm_hourly_allsite.ncl TO READ 
;  EPA OBSERVED PM
   read_epa_pm_hourly_allsite \
   (sdir, sfname, site_name, site_geo, site_date, site_pm)

;  DECLARE VARIABLES FOR SUBROUTINE read_viirs_rad_1day.ncl
   mnp        = 768
   mnl        = 4064
   mfactor    = 5
   tmnp       = mnp*mfactor
   date_title = new((/1/), string, bv0)
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   maod       = new((/tmnp, mnl/), float, bv2)
   maod_qf    = new((/tmnp, mnl/), integer, bv1)
   msza       = new((/tmnp, mnl/), float, bv2)
   msaa       = new((/tmnp, mnl/), float, bv2)
   mmp        = new((/tmnp, mnl/), float, bv2)
   mlza       = new((/tmnp, mnl/), float, bv2)
   mlaa       = new((/tmnp, mnl/), float, bv2)

;  DECLARE VARIABLES FOR SUBROUTINE pixel_to_grid_degree_1day.ncl
   grid_lat   = new((/nlat, nlon/), float, bv2)
   grid_lon   = new((/nlat, nlon/), float, bv2)
   grid_aod   = new((/nlat, nlon/), float, bv2)

;  DECLARE FINAL OUPUT FOR PLOT FOR SUBROUTINE select_viirs_epa_hourly.ncl
   site_lat      = new((/nsite/), float, bv2)
   site_lon      = new((/nsite/), float, bv2)
   select_aod    = new((/nsite/), float, bv2)
   select_aodstd = new((/nsite/), float, bv2)
   select_pm     = new((/nsite/), float, bv2)
   select_pmstd  = new((/nsite/), float, bv2)
   select_sza    = new((/nsite/), float, bv2)
   select_mp     = new((/nsite/), float, bv2)
   select_lza    = new((/nsite/), float, bv2)

;  DO DAY LOOP
   maod     = 0.0
   grid_aod = 0.0
   do iday = 0, nday-1

    system("date") 
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  AOD QUALITY FLAG, AND AOD FOR ONE DAY.
    read_viirs_rad_1day \
   (dir, bv0, iday, startinx, endinx, gfname, vfname, \
    date_title, mlat, mlon, maod_qf, maod, msza, msaa, mmp, mlza, mlaa)
    maod = maod*nfactor

    do isite = 0, nsite-1
   
;  CALL SUBROUTINE select_viirs_site_hourly_pixel.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
     select_viirs_epa_hourly_pixel \
    (iday, bv2, site_id(isite), site_name, site_geo, year(iday), mon(iday), date(iday), times(iday), \
     site_date, site_pm, mlat, mlon, maod, msza, mmp, mlza, site_lat(isite), site_lon(isite),        \
     select_aod(isite), select_aodstd(isite), select_sza(isite), select_mp(isite), select_lza(isite),\
     select_pm(isite))
   
    end do

;  CALL SUBROUTINE pixel_to_grid_degree_1day.ncl TO GRID AOD DATA
    pixel_to_grid_degree_1day \
    (lat_interval, lon_interval, minlat, maxlat, minlon, maxlon, \
     nlat, nlon, mlat, mlon, maod_qf, maod, grid_lat, grid_lon, grid_aod)

    grid_aod@lat2d = grid_lat
    grid_aod@lon2d = grid_lon

;  CALL SUBROUTINE plot_viirs_contour_rad_epa.ncl TO PLOT AOD CONTOUR
    plot_viirs_contour_rad_epa  \
    (wks, date_title, nsite, minlat, maxlat, minlon, maxlon, site_lat, site_lon, \
     avg(select_sza), avg(select_mp), avg(select_lza), select_pm, grid_aod)

    delete([/date_display/])
   end do

end
