;  $ID: viirs_contour_pixel_dnb_point_polyline_direc.ncl V01 02/19/2014 23:14 
;       BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_dnb_point_polyline_direc READS VIIRS PIXEL DATA, 
;  PLOTS IT AS CONTOUR AND ADD A POINT AND POLYLINE WITH SCANNING DIRECTION 
;  ON IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/19/2014)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/process_day_viirs.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/select_viirs_point_hourly_pixel_polyline.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/plot_viirs_pixel_rad_point_polyline_direc.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
;  type       = "pdf"
   type       = "png"
   wks        = gsn_open_wks(type,"1plt_viirs_contour_pixel_dnb_point_polyline_direc_v02")
   gsn_define_colormap(wks,"gsdtol")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"
   nfactor    = 100000000

;  SET DIRECTORY AND FILE NAME FOR VIIRS RADIANCE
   dir        = "/Volumes/TOSHIBA_3B/iproject/atlanta/viirs/night/"
   gflist     = "GDNBO_list_jun"
   vflist     = "SVDNB_list_jun"
   gfname     = asciiread(dir + gflist, -1, "string")
   vfname     = asciiread(dir + vflist, -1, "string")
   ngfname    = dimsizes(gfname)
   nvfname    = dimsizes(vfname)

;  SET UP LIMITED REGION FOR ATLANTA
   minlat     = 25.0
   maxlat     = 45.0
   minlon     =-110.0
   maxlon     =-65.0

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

;  DECLARE VARIABLES FOR SUBROUTINE read_viirs_rad_1day.ncl
   mnp        = 768
   mnl        = 4064
   mfactor    = 1
   tmnp       = mnp*mfactor
   date_title = new((/1/), string, bv0)
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   mrad       = new((/tmnp, mnl/), float, bv2)
   mrad_qf    = new((/tmnp, mnl/), integer, bv1)
   msza       = new((/tmnp, mnl/), float, bv2)
   msaa       = new((/tmnp, mnl/), float, bv2)
   mmp        = new((/tmnp, mnl/), float, bv2)
   mlza       = new((/tmnp, mnl/), float, bv2)
   mlaa       = new((/tmnp, mnl/), float, bv2)
   mlatn      = new((/tmnp/), float, bv2)
   mlonn      = new((/tmnp/), float, bv2)
   mradn      = new((/tmnp/), float, bv2)
   mlatl      = new((/mnl/), float, bv2)
   mlonl      = new((/mnl/), float, bv2)
   mradl      = new((/mnl/), float, bv2)

;  ATLANTA INFO
   nsite         = 1
   site_lat      = new((/nsite/), float, bv2)
   site_lon      = new((/nsite/), float, bv2)
   select_rad    = new((/nsite/), float, bv2)
   select_radstd = new((/nsite/), float, bv2)
   select_pm     = new((/nsite/), float, bv2)
   select_pmstd  = new((/nsite/), float, bv2)
   select_sza    = new((/nsite/), float, bv2)
   select_mp     = new((/nsite/), float, bv2)
   select_lza    = new((/nsite/), float, bv2)
   site_lat      =  33.745
   site_lon      = -84.390

;  DO DAY LOOP
   mrad     = 0.0
   do iday = 0, nday-1

    system("date") 
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
    read_viirs_rad_1day \
   (dir, bv0, iday, startinx, endinx, gfname, vfname, \
    date_title, mlat, mlon, mrad_qf, mrad, msza, msaa, mmp, mlza, mlaa)
    mrad = mrad*nfactor

    do isite = 0, nsite-1

;  CALL SUBROUTINE select_viirs_point_hourly_pixel_polyline.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
       select_viirs_point_hourly_pixel_polyline \
      (iday, bv2, site_lat(isite), site_lon(isite), mlat, mlon, mrad, msza, mmp, mlza, \
       mlatn, mlonn, mlatl, mlonl, \
       select_rad(isite), select_radstd(isite), select_sza(isite), select_mp(isite), select_lza(isite), \
       mradn, mradl)

    end do

;  CALL SUBROUTINE plot_viirs_pixel_rad_point_polyline_direc.ncl TO PLOT RADIANCE CONTOUR
    plot_viirs_pixel_rad_point_polyline_direc  \
    (wks, date_title, nsite, minlat, maxlat, minlon, maxlon, site_lat, site_lon, \
     mlatn, mlonn, mlatl, mlonl, avg(select_sza), avg(select_mp), avg(select_lza), mrad)

    delete([/date_display/])
   end do

end
