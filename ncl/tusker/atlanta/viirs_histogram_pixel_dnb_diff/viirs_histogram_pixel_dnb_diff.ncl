;  $ID: viirs_histogram_pixel_dnb_diff.ncl V01 02/24/2013 11:22 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_histogram_pixel_dnb_diff READS VIIRS PIXEL DATA AND PLOT 
;  HISTOGRAMS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/24/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/process_day_viirs.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/select_viirs_region.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_viirs_histogram_rad_diff.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_viirs_histogram_pixel_dnb_diff_v03")
   gsn_define_colormap(wks,"gsdtol")

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

;  SET UP LIMITED REGION FOR ATLANTA
   minlat     = 33.0
   maxlat     = 34.5
   minlon     =-85.1
   maxlon     =-83.5

;  DECLARE VARIABLES FOR SUBROUTINE process_day_viirs
   tmpnday    = 1
   nday       = new(1, integer, bv1)
   startinx1  = new(tmpnday, integer, bv1)
   endinx1    = new(tmpnday, integer, bv1)
   year1      = new(tmpnday, integer, bv1)
   mon1       = new(tmpnday, integer, bv1)
   date1      = new(tmpnday, integer, bv1)
   times1     = new(tmpnday, integer, bv1)
   timee1     = new(tmpnday, integer, bv1)
   dayname1   = new(tmpnday, string,  bv0)
   daynum1    = new(tmpnday, integer, bv1)

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
                     nday, startinx1, endinx1, year1, mon1, \
                     date1, times1, timee1, dayname1, daynum1)

   process_day_viirs(dir, gflist2, logic_leap,              \
                     nday, startinx2, endinx2, year2, mon2, \
                     date2, times2, timee2, dayname2, daynum2)

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

;  DECLARE ARRAY FOR SUBROUTINE select_viirs_region.ncl
   nfinal     = 150000
   final_aod  = new((/nfinal/), float, bv2)
   final_lat1 = new((/nfinal/), float, bv2)
   final_lon1 = new((/nfinal/), float, bv2)
   final_aod1 = new((/nfinal/), float, bv2)
   final_lat2 = new((/nfinal/), float, bv2)
   final_lon2 = new((/nfinal/), float, bv2)
   final_aod2 = new((/nfinal/), float, bv2)

;  DO DAY LOOP
   do iday = 0, 0;nday-1
    maod      = 0.0
    maod1     = 0.0
    maod2     = 0.0
    final_aod = 0.0
    final_aod1= 0.0
    final_aod2= 0.0

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

;  CALL SUBROUTINE select_viirs_region.ncl TO SELECT DATA IN THE STUDY REGION
    select_viirs_region \
   (minlat, maxlat, minlon, maxlon, mlat1, mlon1, maod1, final_lat1, final_lon1, final_aod1)
    select_viirs_region \
   (minlat, maxlat, minlon, maxlon, mlat2, mlon2, maod2, final_lat2, final_lon2, final_aod2)

;  CALL SUBROUTINE plot_viirs_histogram_rad_diff.ncl TO PLOT AOD CONTOUR
    plot_viirs_histogram_rad_diff \
    (wks, bv0, bv2, final_aod1, final_aod2)

   end do

end
