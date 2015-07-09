;  $ID: viirs_contour_pixel_dnb_epa_nfile_day.ncl V01 01/08/2013 15:05 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_dnb_epa_nfile_day READS VIIRS PIXEL DATA 
;  (.h5 FILE), AND PLOT IT.
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
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/select_viirs_epa_hourly_pixel.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_viirs_pixel_rad_epa.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png" 
   wks  = gsn_open_wks(type, "1plt_viirs_contour_pixel_dnb_sza_epa_day_700nm_v07")
   gsn_define_colormap(wks, "gsdtol")
   setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 100000000
   end setvalues

; INPUT
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/NPP/atlanta/all_data/night/"
   gdnbolist  = "GDNBO_list"
   svdnblist  = "SVDNB_list"
   slat       = "Latitude"
   slon       = "Longitude"
   saot       = "Radiance"
   nfactor    =  10000000

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   minlat     =  33.0
   maxlat     =  34.5
   minlon     = -85.1
   maxlon     = -83.5

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

   do iday = 0, nday-1
    mlat = 0.0
    mlon = 0.0
    maod = 0.0
    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
    read_viirs_rad_1day \
   (dir, bv0, iday, startinx, endinx, filename1, filename2, \
    date_title, mlat, mlon, maod_qf, maod, msza, msaa, mmp, mlza, mlaa)

    do isite = 0, nsite-1

;  CALL SUBROUTINE select_viirs_site_hourly_pixel.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
     select_viirs_epa_hourly_pixel \
    (iday, bv2, site_id(isite), site_name, site_geo, year(iday), mon(iday), date(iday), times(iday), \
     site_date, site_pm, mlat, mlon, maod, msza, mmp, mlza, site_lat(isite), site_lon(isite),        \
     select_aod(isite), select_aodstd(isite), select_sza(isite), select_mp(isite), select_lza(isite),\
     select_pm(isite))

    end do

    maod = maod*nfactor
;  CALL SUBROUTINE plot_viirs_pixel_rad_epa.ncl TO PLOT WHITE-BLACK IMAGE.
    plot_viirs_pixel_rad_epa \
   (wks, date_title, nsite, minlat, maxlat, minlon, maxlon, site_lat, site_lon, \
    avg(select_sza), avg(select_mp), avg(select_lza), select_pm, maod)

  end do
end
