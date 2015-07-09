;  $ID: viirs_contour_pixel_dnb_epa_nfile_site_4hr.ncl V01 01/08/2013 15:05 
;       BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_dnb_epa_nfile_site READS VIIRS PIXEL DATA 
;  (.h5 FILE) AND EPA SITE PM DATA, SELECTS COORESPONDING VIIRS RADIANCE AND 
;  SATELLITE INFO, EPA PM2.5 DATA, AND FINALLY WRITE TO A FILE IN TEXT FORMAT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2013)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/process_day_svdnb.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/select_viirs_epa_hourly_pixel_site_4hr.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/write_viirs_epa_site_4hr.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
;  type = "pdf"
;  type = "png" 
;  wks  = gsn_open_wks(type, "1plt_viirs_contour_pixel_dnb_sza_epa_site_v01")
;  gsn_define_colormap(wks, "gsdtol")

; INPUT
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/NPP/atlanta/all_data/night/"
   gdnbolist  = "GDNBO_list"
   svdnblist  = "SVDNB_list"
   nfactor    =  10000000
;  nfactor    =  100000/7.

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   minlat     =  33.0
   maxlat     =  34.5
   minlon     = -85.5
   maxlon     = -83.5

;  SETUP SITE OBERVATION INFO
;  sdir       = "/shared/aerosol/bruceyoung01/data/atlanta/epa/"
   sdir       = "/shared/aerosol/bruceyoung01/data/atlanta/epa/"
   sfname     = "AQS_PM25_hourly.txt"
;  site_id    = (/"131350002", "130630091", "130670003", "132230003", \
;                 "130890002", "130892001", "131210032", "131210039", \
;                 "131210055", "130670004", "130770002", "131510002"/)
   site_id    = (/"130770002", "130890002", "131210055", "131350002", \
                  "131510002"/)
   backg_lat  = (/33.545/)
   backg_lon  = (/-84.078/)
;  backg_id   = (/"bakground"/)
   backg_id   = (/" "/)
   nsite      = dimsizes(site_id)
;  DEFINE THE DEGREE RANGE AROUND EPA SITES
   thre_lat   = 0.0332
   thre_lon   = 0.0332
   npixel     = 81

;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename1  = asciiread(dir + gdnbolist, -1, "string")
   filename2  = asciiread(dir + svdnblist, -1, "string")
   nfile      = dimsizes(filename1)

   logic_leap = "leap"

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
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

;  CALL process_day_svdnb.ncl TO GET FILE INFO FROM FILE NAME
   process_day_svdnb \
   (dir, svdnblist, logic_leap, nday, startinx, endinx, \
    year, mon, date, times, timee, dayname, daynum)

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

   print("TOTAL DAYS : " + nday)

;  DECLARE FINAL OUPUT FOR PLOT FOR SUBROUTINE select_viirs_epa_hourly.ncl
    bsite_lat     = new((/nday/), float, bv2)
    bsite_lon     = new((/nday/), float, bv2)
    bselect_date  = new((/nday, 4/), integer, bv1)
    bselect_aod   = new((/nday, npixel/), float, bv2)
    bselect_aodstd= new((/nday/), float, bv2)
    bselect_pm    = new((/nday, 4/), float, bv2)
    bselect_pmstd = new((/nday/), float, bv2)
    bselect_sza   = new((/nday/), float, bv2)
    bselect_saa   = new((/nday/), float, bv2)
    bselect_mp    = new((/nday/), float, bv2)
    bselect_lza   = new((/nday/), float, bv2)
    bselect_laa   = new((/nday/), float, bv2)

;  DECLARE FINAL OUPUT FOR PLOT FOR SUBROUTINE select_viirs_epa_hourly.ncl
    site_lat      = new((/nsite, nday/), float, bv2)
    site_lon      = new((/nsite, nday/), float, bv2)
    select_date   = new((/nsite, nday, 4/), integer, bv1)
    select_aod    = new((/nsite, nday, npixel/), float, bv2)
    select_aodstd = new((/nsite, nday/), float, bv2)
    select_pm     = new((/nsite, nday, 4/), float, bv2)
    select_pmstd  = new((/nsite, nday/), float, bv2)
    select_sza    = new((/nsite, nday/), float, bv2)
    select_saa    = new((/nsite, nday/), float, bv2)
    select_mp     = new((/nsite, nday/), float, bv2)
    select_lza    = new((/nsite, nday/), float, bv2)
    select_laa    = new((/nsite, nday/), float, bv2)

    do iday = 0, nday-1

     system("date")
     date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
     print("DATE : " + date_display)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_rad_1day.ncl
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

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
     read_viirs_rad_1day \
    (dir, bv0, iday, startinx, endinx, filename1, filename2, \
     date_title, mlat, mlon, maod_qf, maod, msza, msaa, mmp, mlza, mlaa)
     maod = maod*nfactor

;  CALL SUBROUTINE select_viirs_epa_hourly_pixel_site_4hr.ncl TO SELECT AND CALCULATE BACKGROUND VIIRS DATA 
;  AND SITE OBSERVED DATA
      if (backg_id .eq. "background") then
       print("PREPAIRING BACKGROUND RADIANCE INFO")
       select_viirs_epa_hourly_pixel_site_4hr \
      (iday, bv1, bv2, backg_id, site_name, site_geo, year(iday), mon(iday), date(iday), times(iday), \
       thre_lat, thre_lon, npixel, site_date, site_pm, mlat, mlon, maod, msza, msaa, mmp, mlza, mlaa, \
       bsite_lat(iday), bsite_lon(iday), bselect_date(iday, :), \
       bselect_aod(iday, :), bselect_aodstd(iday), \
       bselect_sza(iday), bselect_saa(iday), \
       bselect_mp(iday), bselect_lza(iday), bselect_laa(iday), bselect_pm(iday, :))
      end if

    do isite = 0, nsite-1
;  CALL SUBROUTINE select_viirs_epa_hourly_pixel_site_4hr.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
      select_viirs_epa_hourly_pixel_site_4hr \
     (iday, bv1, bv2, site_id(isite), site_name, site_geo, year(iday), mon(iday), date(iday), times(iday), \
      thre_lat, thre_lon, npixel, site_date, site_pm, mlat, mlon, maod, msza, msaa, mmp, mlza, mlaa, \
      site_lat(isite, iday), site_lon(isite, iday), select_date(isite, iday, :), \
      select_aod(isite, iday, :), select_aodstd(isite, iday), \
      select_sza(isite, iday), select_saa(isite, iday), \
      select_mp(isite, iday), select_lza(isite, iday), select_laa(isite, iday), select_pm(isite, iday, :))

;  HERE NOTICE, IN ORDER TO REMOVE THE INFLUENCE OF MOON LIGHT, ONE BACKGROUND RADIANCE PIONT IS SELECTED, 
;  WITH SIMILAR SURFACE INFO, LIKE SURFACE REFLECTANCE, VEGETATION COVERY
      if (backg_id .eq. "background") then
       select_aod(isite, iday, :) = select_aod(isite, iday, :) - bselect_aod(iday, :)
      end if
     end do
    end do

    do isite = 0, nsite-1
;  CALL SUBROUTINE write_viirs_epa_site_4hr.ncl TO WRITE OUTPUT INTO A FILE
     write_viirs_epa_site_4hr \
    (site_id(isite), site_lat(isite, :), site_lon(isite, :), select_date(isite, :, :),         \
     select_sza(isite, :), select_saa(isite, :), select_mp(isite, :), select_lza(isite, :), \
     select_laa(isite, :), select_pm(isite, :, :), select_aod(isite, :, :))
    end do
end
