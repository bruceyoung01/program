;  $ID: viirs_contour_pixel_dnb_epa_liu_nfile_day_point_number.ncl V01 
;  01/08/2013 15:05 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_dnb_epa_liu_nfile_day_point_number READS VIIRS 
;  PIXEL DATA (.h5 FILE), AND PLOT IT AND SELCTED POINTS WITH NUMBER ON THE 
;  PIXEL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2013)
;  (2 ) MODIFIED FROM viirs_contour_pixel_dnb_epa_liu_nfile_day_point.ncl BY
;       ADDING POINT NUMBER ON THE PLOT. (01/28/2014)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/int2string.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/int2string_format.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/convert_local_to_utc_all.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/process_day_svdnb.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_liu_pm_hourly.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/select_region.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/select_viirs_epa_liu_hourly_pixel_point_number.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_viirs_pixel_rad_epa_liu_point_number.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/write_viirs_epa_site_4hr_point.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png" 
   wks  = gsn_open_wks(type, "1plt_viirs_contour_pixel_dnb_sza_epa_liu_day_700nm_v04_2012_DEL")
   gsn_define_colormap(wks, "gsdtol")
   setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 100000000
   end setvalues

; INPUT
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/NPP/atlanta/all_data/night/"
   gdnbolist  = "GDNBO_list_2012"
   svdnblist  = "SVDNB_list_2012"
   slat       = "Latitude"
   slon       = "Longitude"
   saot       = "Radiance"
   nfactor    =  10000000

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
;  FOR A POINT
;  minlat     =  33.85 
;  maxlat     =  34.2 
;  minlon     = -84.3
;  maxlon     = -83.9
;  FOR B POINT
;  minlat     =  33.2
;  maxlat     =  33.5 
;  minlon     = -85.3
;  maxlon     = -84.8
;  FOR C POINT
;  minlat     =  33.3
;  maxlat     =  33.8 
;  minlon     = -84.5
;  maxlon     = -84.0
;  FOR D, E, L POINTS
   minlat     =  33.66
   maxlat     =  33.85
   minlon     = -84.45
   maxlon     = -84.15
   time_lag   = -5

;  SETUP SITE OBERVATION INFO
   sdir       = "/shared/aerosol/bruceyoung01/data/atlanta/epa/"
   sfname     = "AQS_PM25_hourly.txt"
;  site_id    = (/"131350002", "130630091", "130670003", "132230003", \
;                 "130890002", "130892001", "131210032", "131210039", \
;                 "131210055", "130670004", "130770002", "131510002"/)
;                     A            B            C            D
;                     E            L
   site_id    = (/"131350002", "130770002", "131510002", "131210055", \
                  "130890002", "liu"/)
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
   tmpnday    = 153
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
   stmnp      = 100
   smnl       = 100
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

;  DECLARE ARRAY FOR PROCEDURE select_region.ncl TO SELECT STUDY REGION
   smlat      = new((/stmnp, smnl/), float, bv2)
   smlon      = new((/stmnp, smnl/), float, bv2)
   smrad      = new((/stmnp, smnl/), float, bv2)
   smrad_qf   = new((/stmnp, smnl/), integer, bv1)
   smsza      = new((/stmnp, smnl/), float, bv2)
   smsaa      = new((/stmnp, smnl/), float, bv2)
   smmp       = new((/stmnp, smnl/), float, bv2)
   smlza      = new((/stmnp, smnl/), float, bv2)
   smlaa      = new((/stmnp, smnl/), float, bv2)

;  DECLARE FINAL OUPUT FOR PLOT FOR SUBROUTINE select_viirs_epa_hourly_pixel_point_number.ncl
   pointn_lat    = new((/nsite, 16, tmpnday/), float, bv2)
   pointn_lon    = new((/nsite, 16, tmpnday/), float, bv2)
   pointn_rad    = new((/nsite, 16, tmpnday/), float, bv2)
   select_date   = new((/nsite, 4,  tmpnday/), integer, bv1)
   site_lat      = new((/nsite, tmpnday/), float, bv2)
   site_lon      = new((/nsite, tmpnday/), float, bv2)
   point_lat     = new((/nsite, tmpnday/), float, bv2)
   point_lon     = new((/nsite, tmpnday/), float, bv2)
   select_rad    = new((/nsite, tmpnday/), float, bv2)
   select_radstd = new((/nsite, tmpnday/), float, bv2)
   select_pm     = new((/nsite, 4, tmpnday/), float, bv2)
   select_pmstd  = new((/nsite, tmpnday/), float, bv2)
   select_sza    = new((/nsite, tmpnday/), float, bv2)
   select_saa    = new((/nsite, tmpnday/), float, bv2)
   select_mp     = new((/nsite, tmpnday/), float, bv2)
   select_lza    = new((/nsite, tmpnday/), float, bv2)
   select_laa    = new((/nsite, tmpnday/), float, bv2)

   do iday = 0, nday-1
    mlat = 0.0
    mlon = 0.0
    mrad = 0.0
    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
    read_viirs_rad_1day \
   (dir, bv0, iday, startinx, endinx, filename1, filename2, \
    date_title, mlat, mlon, mrad_qf, mrad, msza, msaa, mmp, mlza, mlaa)
    mrad = mrad*nfactor

;  CALL SUBROUTINE select_region.ncl TO SELECT STUDY REGION FROM THE WHOLE REGION
    select_region \
    (minlat, maxlat, minlon, maxlon, mlat, mlon, mrad_qf, mrad, msza, msaa, mmp, mlza, mlaa, \
     smlat, smlon, smrad_qf, smrad, smsza, smsaa, smmp, smlza, smlaa)

    do isite = 0, nsite-1

;  CALL SUBROUTINE select_viirs_epa_liu_hourly_pixel_point_number.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
     select_viirs_epa_liu_hourly_pixel_point_number \
    (iday, bv1, bv2, isite, site_id(isite), site_name, site_geo, year(iday), mon(iday), date(iday),  \
     times(iday), site_date, site_pm, llat, llon, udate, lpm, smlat, smlon, smrad, smsza, smsaa, smmp, \
     smlza, smlaa, site_lat(isite, iday), site_lon(isite, iday), point_lat(isite, iday), point_lon(isite, iday), \
     pointn_lat(isite, :, iday), pointn_lon(isite, :, iday), select_date(isite, :, iday), select_rad(isite, iday), \
     select_radstd(isite, iday), select_sza(isite, iday), select_saa(isite, iday), select_mp(isite, iday), \
     select_lza(isite, iday), select_laa(isite, iday), select_pm(isite, :, iday), pointn_rad(isite, :, iday))

    end do

    print("=========================================PLOTTING=============================================")
;  CALL SUBROUTINE plot_viirs_pixel_rad_epa_liu_point_number.ncl TO PLOT WHITE-BLACK IMAGE.
    plot_viirs_pixel_rad_epa_liu_point_number \
   (wks, date_title, nsite, minlat, maxlat, minlon, maxlon, site_lat(:, iday), site_lon(:, iday), \
    point_lat(:, iday), point_lon(:, iday), pointn_lat(:, :, iday), pointn_lon(:, :, iday), avg(select_sza), avg(select_mp), \
    avg(select_lza), dim_avg_n(select_pm(:, :, iday), 1), mrad, pointn_rad(:, :, iday))

  end do

   print("==========================================WRITING TO FILE======================================")
;  CALL SUBROUTINE write_viirs_epa_site_4hr_point.ncl TO WRITE SELECTED DATA
   ncycle = 16
   do icycle = 0, ncycle-1
      groupname = "GROUP" + int2string_format(icycle, False, 2, 2) + "_"
      do isite = 0, nsite - 1
         write_viirs_epa_site_4hr_point \
        (groupname, site_id(isite), site_lat(isite, icycle:nday-1:ncycle), site_lon(isite, icycle:nday-1:ncycle), \
         select_date(isite, :, icycle:nday-1:ncycle), pointn_lat(isite, :, icycle:nday-1:ncycle), \
         pointn_lon(isite, :, icycle:nday-1:ncycle), select_sza(isite, icycle:nday-1:ncycle), \
         select_saa(isite, icycle:nday-1:ncycle), select_mp(isite, icycle:nday-1:ncycle), \
         select_lza(isite, icycle:nday-1:ncycle), select_laa(isite, icycle:nday-1:ncycle), \
         select_pm(isite, :, icycle:nday-1:ncycle), pointn_rad(isite, :, icycle:nday-1:ncycle))
      end do
   end do

;  CALL SUBROUTINE write_viirs_epa_site_4hr_point.ncl TO WRITE SELECTED DATA ALL

   allname = "ALL_"
   do isite = 0, nsite - 1
      write_viirs_epa_site_4hr_point \
     (allname, site_id(isite), site_lat(isite, :), site_lon(isite, :), \
      select_date(isite, :, :), pointn_lat(isite, :, :), \
      pointn_lon(isite, :, :), select_sza(isite, :), \
      select_saa(isite, :), select_mp(isite, :), \
      select_lza(isite, :), select_laa(isite, :), \
      select_pm(isite, :, :), pointn_rad(isite, :, :))
   end do

end
