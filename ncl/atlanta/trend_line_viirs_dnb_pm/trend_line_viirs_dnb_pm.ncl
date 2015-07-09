;  $ID: trend_line_viirs_dnb_pm.ncl V01 01/16/2013 16:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_viirs_dnb_pm READS VIIRS DAY-NIGHT BAND RADIANCE DATA AT 
;  700nm AND OBSERVED PM DATA OF ATLANTA CITY. AND PLOT THE TREND LINE OF THEM.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/16/2013)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/function/correlation.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/universal/marker_map.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/atlanta/process_day_svdnb.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/atlanta/read_site_pm_hourly.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/atlanta/select_viirs_site.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/atlanta/plot_trend_daily2_aod.ncl"


begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type,"1plt_trend_line_viirs_dnb_pm_v01_excellent_std")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.

;  SETUP INFO FOR VIIRS, INCLUDING DIRECTORY, FILE NAME
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/NPP/atlanta/svdnb/"
   gdnbolist  = "GDNBO_list"
   svdnblist  = "SVDNB_list"

;  SETUP INFO FOR SITE INFO
   site_dir   = "/shared/aerosol/bruceyoung01/data/atlanta/site/"
   site_file  = "Hourly_average_201209_excellent.txt"
   site_name  = (/"Atlanta"/)
   site_lat   = (/33.76/)
   site_lon   = (/-84.4/)
   minlat     = 33.0
   maxlat     = 34.5
   minlon     = -85.5
   maxlon     = -83.5

;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename1  = asciiread(dir + gdnbolist, -1, "string")
   filename2  = asciiread(dir + svdnblist, -1, "string")
   nfile      = dimsizes(filename1)

   logic_leap = "leap"

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   tmpnday    = 35
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

;  DECLARE FINAL OUPUT FOR PLOT
   select_aod    = new((nday), float, bv2)
   select_aodstd = new((nday), float, bv2)
   select_pm     = new((nday), float, bv2)
   select_pmstd  = new((nday), float, bv2)
   select_sza    = new((nday), float, bv2)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl
   mnp        = 768
   mnl        = 4064
   mfactor    = 5
   tmnp       = mnp*mfactor
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   maod       = new((/tmnp, mnl/), float, bv2)
   maod_qf    = new((/tmnp, mnl/), integer, bv1)
   msza       = new((/tmnp, mnl/), float, bv2)

;  DECLARE VARIABLES FOR SUBSOURINTE read_site_pm_hourly.ncl
   nrows      = 600
   site_date  = new((/nrows, 4/), integer, bv1)
   site_pm    = new((/nrows, 4/), float, bv2)

;  CALL SUBROUTINE read_site_pm_hourly.ncl TO GET SITE OBSERVED PM
   read_site_pm_hourly(site_dir, site_file, site_date, site_pm)

   mpplot     = new(1, graphic)
   plot       = new(1, graphic)
   awplot     = new(1, graphic)

;  DO # OF SITE LOOP
   do isite = 0, 0
;  DO # OF DAY LOOP
    do iday = 0, nday-1

     system("date")
     date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
     print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
     read_viirs_rad_1day \
     (dir, bv0, iday, startinx, endinx, filename1, filename2, \
      mlat, mlon, maod_qf, maod, msza)

;  CALL SUBROUTINE select_viirs_site.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
     select_viirs_site \
    (iday, bv2, site_lat, site_lon, year(iday), mon(iday), date(iday),          \
     times(iday), site_date, site_pm, mlat, mlon, maod, msza, select_aod(iday), \
     select_aodstd(iday), select_sza(iday), select_pm(iday))

    end do

;  CALCULATE AVERAGE
    avg_aod = avg(select_aod)
    avg_pm  = avg(select_pm)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, minlat, maxlat, minlon, maxlon, \
               site_lon, site_lat, mpplot, plot)

;print(avg_aod)
;print(avg_pm)
;print(select_aod)
;print(select_pm)
;print(select_aodstd)
;print(select_pmstd)
;print(select_sza)
;print(cos((select_sza/180.)*3.14159))
;  CALL SUBROUTINE plot_trend_daily2_aod.ncl TO PLOT THE TREND LINE
    plot_trend_daily2_aod(wks, site_name, date, select_aod, select_pm,   \
                          select_aodstd, select_pmstd, avg_aod, avg_pm,  \
                          nday, bv1, bv2, mpplot, awplot)

   end do

end
