;  $ID: viirs_contour_pixel_dnb_epa_liu_nfile_16day.ncl V01 01/08/2013 15:05 
;  BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_dnb_epa_liu_nfile_16day READS VIIRS PIXEL DATA 
;  (.h5 FILE), AND PLOT IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2013)
;  (2 ) MODIFIED FROM viirs_contour_pixel_dnb_epa_liu_nfile_day.ncl BY ADDING 
;       PANEL PLOT FOR 16-DAY EVERY PANEL DEPENDING ON VIIRS SCANNING CYCLE.
;       BRUCE. (01/22/2014)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/convert_local_to_utc_all.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/createLabelBar.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/process_day_svdnb.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_liu_pm_hourly.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/select_viirs_epa_liu_hourly_pixel.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_viirs_pixel_rad_epa_liu_16day.ncl"

begin
;  SETUP WORKSTATION
   type = "x11"
;  type = "pdf"
;  type = "png" 
   wks  = gsn_open_wks(type, "1plt_viirs_contour_pixel_dnb_sza_epa_liu_16day_700nm_v01")
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
   nfactor    =  1000000

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   minlat     =  33.5 ;33.0
   maxlat     =  33.8 ;34.5
   minlon     = -84.5
   maxlon     = -84.1
   time_lag   = -5

;  SETUP SITE OBERVATION INFO
   sdir       = "/shared/aerosol/bruceyoung01/data/atlanta/epa/"
   sfname     = "AQS_PM25_hourly.txt"
;  site_id    = (/"131350002", "130630091", "130670003", "132230003", \
;                 "130890002", "130892001", "131210032", "131210039", \
;                 "131210055", "130670004", "130770002", "131510002"/)
   site_id    = (/"131350002", "130890002", "131210055", "130770002", \
                  "131510002", "liu"/)
;  site_id    = (/"130770002"/)
   nsite      = dimsizes(site_id)

;  SETUP LIU'S OBSERVATION INFO
   ldir       = "/shared/aerosol/bruceyoung01/data/atlanta/liu/"
   lfname1    = "Hourly_average.txt"
   lfname2    = "hourly_GRIMM_PM25_concentration.csv"
   llat       = (/ 33.7975/)
   llon       = (/-84.3239/)

;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename1  = asciiread(dir + gdnbolist, -1, "string")
   filename2  = asciiread(dir + svdnblist, -1, "string")
   nfile      = dimsizes(filename1)

   logic_leap = "leap"

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   tmpnday    = 190
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

;  DECLARE ARRAY FOR SUBROUTINE read_liu_pm_hourly.ncl TO LIU'S DATA
   nrows1     = 600
   udate1     = new((/nrows1, 4/), integer, bv1)
   ldate1     = new((/nrows1, 4/), integer, bv1)
   lpm1       = new((/nrows1, 4/), float,   bv2)
   nrows2     = 635
   udate2     = new((/nrows2, 4/), integer, bv1)
   ldate2     = new((/nrows2, 4/), integer, bv1)
   lpm2       = new((/nrows2, 1/), float,   bv2)
   nrows3     = 1235
   udate      = new((/nrows3, 4/), integer, bv1)
   ldate      = new((/nrows3, 4/), integer, bv1)
   lpm        = new((/nrows3, 1/), float,   bv2)

;  DECLARE ARRAY FOR FINAL PLOT OUTPUTS
   lbidh      = new((/1/), graphic)
   lbidv      = new((/1/), graphic)
   ncycle     = 16
   nplot      = 12
   plot       = new((/nplot/), graphic)

;  CALL SUBROUTINE read_liu_pm_hourly.ncl TO READ LIU'S DATA
   read_liu_pm_hourly \
   (ldir, lfname1, ldate1, lpm1)

   read_liu_pm_hourly \
   (ldir, lfname2, ldate2, lpm2)
;  MERGE TWO PM ARRAY INTO ONE ARRAY
   lpm(0:nrows1-1, 0)      = lpm1(:, 0)
   lpm(nrows1:nrows3-1, 0) = lpm2(:, 0)

;  CALL SUBROUTINE convert_local_to_utc_all.ncl TO CONVERT LOCAL TIME TO UTC TIME
   convert_local_to_utc_all \
   (ldate1(:, 0), ldate1(:, 1), ldate1(:, 2), ldate1(:, 3), time_lag, \
    udate1(:, 0), udate1(:, 1), udate1(:, 2), udate1(:, 3))

   convert_local_to_utc_all \
   (ldate2(:, 0), ldate2(:, 1), ldate2(:, 2), ldate2(:, 3), time_lag, \
    udate2(:, 0), udate2(:, 1), udate2(:, 2), udate2(:, 3))
;  MERGE TWO DATE ARRAY INTO ONE ARRAY
   udate(0:nrows1-1, :)      = udate1
   udate(nrows1:nrows3-1, :) = udate2

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

;  DO icycle LOOP TO PLOT THE SAME PHASE SATELLITE IMAGES INTO ONE PANEL
   do icycle = 0, 1;nplot-1
   iplot = 0
   do iday = icycle, 18, ncycle ;nday-1, nplot
    mlat  = 0.0
    mlon  = 0.0
    maod  = 0.0
    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
    read_viirs_rad_1day \
   (dir, bv0, iday, startinx, endinx, filename1, filename2, \
    date_title, mlat, mlon, maod_qf, maod, msza, msaa, mmp, mlza, mlaa)

    do isite = 0, nsite-1

;  CALL SUBROUTINE select_viirs_epa_liu_hourly_pixel.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
     select_viirs_epa_liu_hourly_pixel \
    (iday, bv2, site_id(isite), site_name, site_geo, year(iday), mon(iday), date(iday), times(iday), \
     site_date, site_pm, llat, llon, udate, lpm, mlat, mlon, maod, msza, mmp, mlza,                  \
     site_lat(isite), site_lon(isite), select_aod(isite), select_aodstd(isite), select_sza(isite),   \
     select_mp(isite), select_lza(isite), select_pm(isite))

    end do ; isite

    maod = maod*nfactor
;  CALL SUBROUTINE plot_viirs_pixel_rad_epa_liu_16day.ncl TO PLOT WHITE-BLACK IMAGE.
    plot_viirs_pixel_rad_epa_liu_16day \
   (wks, date_title, nsite, minlat, maxlat, minlon, maxlon, site_lat, site_lon, \
    avg(select_sza), avg(select_mp), avg(select_lza), select_pm, maod, lbidh, lbidv, \
    plot(iplot))

  end do ; iday

;  CREATE PANEL
   draw(lbidh)
   draw(lbidv)
   gsn_panel(wks, plot, (/2, 6/), False)
   frame(wks)

  end do ; icycle
end
