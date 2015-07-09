;  $ID: viirs_contour_grid_dnb_epa_diff.ncl V01 01/31/2013 15:48 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_grid_dnb_epa_diff READS VIIRS PIXEL DATA AND GRID IT 
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
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_viirs_contour_rad_epa_diff.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_viirs_contour_grid_dnb_epa_diff_v04")
   gsn_define_colormap(wks,"BlueWhiteOrangeRed")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"
   nfactor    = 10000000

;  SET DIRECTORY AND FILE NAME FOR VIIRS AOD
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/NPP/atlanta/all_data/night/"
   gflist1    = "GDNBO_list_20120925"
   vflist1    = "SVDNB_list_20120925"
   gfname1    = asciiread(dir + gflist1, -1, "string")
   vfname1    = asciiread(dir + vflist1, -1, "string")
   ngfname1   = dimsizes(gfname1)
   nvfname1   = dimsizes(vfname1)

   gflist2    = "GDNBO_list_20121025"
   vflist2    = "SVDNB_list_20121025"
   gfname2    = asciiread(dir + gflist2, -1, "string")
   vfname2    = asciiread(dir + vflist2, -1, "string")
   ngfname2   = dimsizes(gfname2)
   nvfname2   = dimsizes(vfname2)

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
   minlon     =-85.1
   maxlon     =-83.5
;  GRID INTERVAL
   lat_interval = 0.1
   lon_interval = 0.1
;  CALCULATE GRID SIZE DEPENDING ON GRID INTERVAL AND REGION LIMIT
   nlat       = floattoint((maxlat-minlat)/lat_interval) + 1
   nlon       = floattoint((maxlon-minlon)/lon_interval) + 1

;  DECLARE VARIABLES FOR SUBROUTINE process_day_viirs
   tmpnday    = 1
   nday1      = new(1, integer, bv1)
   startinx1  = new(tmpnday, integer, bv1)
   endinx1    = new(tmpnday, integer, bv1)
   year1      = new(tmpnday, integer, bv1)
   mon1       = new(tmpnday, integer, bv1)
   date1      = new(tmpnday, integer, bv1)
   times1     = new(tmpnday, integer, bv1)
   timee1     = new(tmpnday, integer, bv1)
   dayname1   = new(tmpnday, string,  bv0)
   daynum1    = new(tmpnday, integer, bv1)

   nday2      = new(1, integer, bv1)
   startinx2  = new(tmpnday, integer, bv1)
   endinx2    = new(tmpnday, integer, bv1)
   year2      = new(tmpnday, integer, bv1)
   mon2       = new(tmpnday, integer, bv1)
   date2      = new(tmpnday, integer, bv1)
   times2     = new(tmpnday, integer, bv1)
   timee2     = new(tmpnday, integer, bv1)
   dayname2   = new(tmpnday, string,  bv0)
   daynum2    = new(tmpnday, integer, bv1)

;  CALL SUBROUTINE process_day_viirs.ncl TO READ OUT INFO FROM VIIRS FILE NAME
   process_day_viirs(dir, gflist1, logic_leap,              \
                     nday1, startinx1, endinx1, year1, mon1,\
                     date1, times1, timee1, dayname1, daynum1)

   process_day_viirs(dir, gflist2, logic_leap,              \
                     nday2, startinx2, endinx2, year2, mon2,\
                     date2, times2, timee2, dayname2, daynum2)

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
   date_title1= new((/1/), string, bv0)
   mlat1      = new((/tmnp, mnl/), float, bv2)
   mlon1      = new((/tmnp, mnl/), float, bv2)
   maod1      = new((/tmnp, mnl/), float, bv2)
   maod_qf1   = new((/tmnp, mnl/), integer, bv1)
   msza1      = new((/tmnp, mnl/), float, bv2)
   msaa1      = new((/tmnp, mnl/), float, bv2)
   mmp1       = new((/tmnp, mnl/), float, bv2)
   mlza1      = new((/tmnp, mnl/), float, bv2)
   mlaa1      = new((/tmnp, mnl/), float, bv2)

   date_title2= new((/1/), string, bv0)
   mlat2      = new((/tmnp, mnl/), float, bv2)
   mlon2      = new((/tmnp, mnl/), float, bv2)
   maod2      = new((/tmnp, mnl/), float, bv2)
   maod_qf2   = new((/tmnp, mnl/), integer, bv1)
   msza2      = new((/tmnp, mnl/), float, bv2)
   msaa2      = new((/tmnp, mnl/), float, bv2)
   mmp2       = new((/tmnp, mnl/), float, bv2)
   mlza2      = new((/tmnp, mnl/), float, bv2)
   mlaa2      = new((/tmnp, mnl/), float, bv2)

;  DECLARE VARIABLES FOR SUBROUTINE pixel_to_grid_degree_1day.ncl
   grid_lat   = new((/nlat, nlon/), float, bv2)
   grid_lon   = new((/nlat, nlon/), float, bv2)
   grid_aod1  = new((/nlat, nlon/), float, bv2)
   grid_aod2  = new((/nlat, nlon/), float, bv2)

;  DECLARE FINAL OUPUT FOR PLOT FOR SUBROUTINE select_viirs_epa_hourly.ncl
   site_lat      = new((/nsite/), float, bv2)
   site_lon      = new((/nsite/), float, bv2)
   select_aod1   = new((/nsite/), float, bv2)
   select_aodstd1= new((/nsite/), float, bv2)
   select_pm1    = new((/nsite/), float, bv2)
   select_pmstd1 = new((/nsite/), float, bv2)
   select_sza1   = new((/nsite/), float, bv2)
   select_mp1    = new((/nsite/), float, bv2)
   select_lza1   = new((/nsite/), float, bv2)

   select_aod2   = new((/nsite/), float, bv2)
   select_aodstd2= new((/nsite/), float, bv2)
   select_pm2    = new((/nsite/), float, bv2)
   select_pmstd2 = new((/nsite/), float, bv2)
   select_sza2   = new((/nsite/), float, bv2)
   select_mp2    = new((/nsite/), float, bv2)
   select_lza2   = new((/nsite/), float, bv2)

;  DEFINE ARRAY FOR FINAL DIFFERENCE PLOT
   grid_aod      = new((/nlat, nlon/), float, bv2)
   select_pm     = new((/nsite/),      float, bv2)

;  DO DAY LOOP
   do iday = 0, 0;nday-1
    maod1      = 0.0
    maod2      = 0.0
    grid_aod1  = 0.0
    grid_aod2  = 0.0
    select_pm1 = 0.0
    select_pm2 = 0.0
    

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  AOD QUALITY FLAG, AND AOD FOR ONE DAY.
    read_viirs_rad_1day \
   (dir, bv0, iday, startinx1, endinx1, gfname1, vfname1, \
    date_title1, mlat1, mlon1, maod_qf1, maod1, msza1, msaa1, mmp1, mlza1, mlaa1)

    read_viirs_rad_1day \
   (dir, bv0, iday, startinx2, endinx2, gfname2, vfname2, \
    date_title2, mlat2, mlon2, maod_qf2, maod2, msza2, msaa2, mmp2, mlza2, mlaa2)
    maod1 = maod1*nfactor
    maod2 = maod2*nfactor

    do isite = 0, nsite-1
   
;  CALL SUBROUTINE select_viirs_site_hourly_pixel.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
     select_viirs_epa_hourly_pixel \
    (iday, bv2, site_id(isite), site_name, site_geo, year1(iday), mon1(iday), date1(iday), times1(iday),  \
     site_date, site_pm, mlat1, mlon1, maod1, msza1, mmp1, mlza1, site_lat(isite), site_lon(isite),       \
     select_aod1(isite), select_aodstd1(isite), select_sza1(isite), select_mp1(isite), select_lza1(isite),\
     select_pm1(isite))

     select_viirs_epa_hourly_pixel \
    (iday, bv2, site_id(isite), site_name, site_geo, year2(iday), mon2(iday), date2(iday), times2(iday),  \
     site_date, site_pm, mlat2, mlon2, maod2, msza2, mmp2, mlza2, site_lat(isite), site_lon(isite),       \
     select_aod2(isite), select_aodstd2(isite), select_sza2(isite), select_mp2(isite), select_lza2(isite),\
     select_pm2(isite))
    end do

;  CALL SUBROUTINE pixel_to_grid_degree_1day.ncl TO GRID AOD DATA
    pixel_to_grid_degree_1day \
    (lat_interval, lon_interval, minlat, maxlat, minlon, maxlon, \
     nlat, nlon, mlat1, mlon1, maod_qf1, maod1, grid_lat, grid_lon, grid_aod1)

    pixel_to_grid_degree_1day \
    (lat_interval, lon_interval, minlat, maxlat, minlon, maxlon, \
     nlat, nlon, mlat2, mlon2, maod_qf2, maod2, grid_lat, grid_lon, grid_aod2)

    grid_aod@lat2d = grid_lat
    grid_aod@lon2d = grid_lon
    select_pm      = select_pm1 - select_pm2
    grid_aod       = grid_aod1  - grid_aod2
;  CALL SUBROUTINE plot_viirs_contour_rad_epa_diff.ncl TO PLOT AOD CONTOUR
    plot_viirs_contour_rad_epa_diff  \
    (wks, nsite, minlat, maxlat, minlon, maxlon, \
     site_lat, site_lon, select_pm, grid_aod)

   end do

end
