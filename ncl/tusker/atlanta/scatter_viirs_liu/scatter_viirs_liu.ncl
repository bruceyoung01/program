;  $ID: scatter_viirs_liu.ncl V01 04/02/2013 09:29 BUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter_viirs_liu READS PM SAMPLE FROM LIU'S OBSERVATION OVER 
;  ATLANTA AND PICKS UP THE POINTS IN VIIRS BASED ON SITE INFO AND TIME.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/05/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/process_day_viirs.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/read_site_pm_raw.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/select_viirs_site.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/plot_scatter_viirs_site.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_scatter_viirs_liu_v01")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")
   
;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"

;  SETUP VIIRS DATA INFO
   vdir       = "/home/bruce/sshfs/shw/data/satellite/NPP/atlanta/all_data/night/"
   vgflist    = "GDNBO_list_201301"
   vrflist    = "SVDNB_list_201301"
;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename1  = asciiread(vdir + vgflist, -1, "string")
   filename2  = asciiread(vdir + vrflist, -1, "string")
   nfile      = dimsizes(filename1)

;  SETUP SITE OBERVATION INFO
   sdir       = "/home/bruce/sshfs/shw/data/atlanta/liu/"
   sfname     = "NASA_003_2013-01-05_11-11-M.dat"
   site_name  = (/"Atlanta"/)
   site_lat   = (/33.76/)
   site_lon   = (/-84.4/)
   minlat     =  33.0
   maxlat     =  34.5
   minlon     = -85.5
   maxlon     = -83.5

;  SETUP DATE PERIOD
   start_year = 2013
   start_month= 1
   start_day  = 1
   start_hour = 0
   end_year   = 2013
   end_month  = 1
   end_day    = 15
   end_hour   = 23
   start_jd   = doubletoint(greg2jul(start_year, start_month, start_day, end_hour))
   end_jd     = doubletoint(greg2jul(end_year, end_month, end_day, end_hour))

;  DECLARE VARIABLES FOR SUBROUTINE process_day_viirs
   tmpnday    = 31
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

;  DECLARE VARIABLES FOR SUBSOURINTE read_site_pm_raw.ncl
   nrows      = 600
   site_date  = new((/nrows, 4/), integer, bv1)
   site_pm    = new((/nrows, 3/), float, bv2)

;  CALL process_day_viirs.ncl TO GET FILE INFO FROM FILE NAME
   process_day_viirs \
   (vdir, vrflist, logic_leap, nday, startinx, endinx, \
    year, mon, date, times, timee, dayname, daynum)

;  DECLARE ARRAY FOR SUBROUTINE read_site_pm_raw.ncl TO READ 
;  LIU'S SITE OBSERVED PM
   read_site_pm_raw \
   (sdir, sfname, bv0, bv1, bv2, start_jd, end_jd, start_hour, end_hour, \
    site_date, site_pm)
;  print(site_pm)

;  DECLARE FINAL OUPUT FOR PLOT
   select_aod    = new((nday), float, bv2)
   select_aodstd = new((nday), float, bv2)
   select_pm     = new((nday), float, bv2)
   select_pmstd  = new((nday), float, bv2)
   select_sza    = new((nday), float, bv2)

;  DECLARE VARIABLES FOR SUBROUTINE read_viirs_aod_1day.ncl
   mnp        = 768
   mnl        = 4064
   mfactor    = 5
   tmnp       = mnp*mfactor
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   maod       = new((/tmnp, mnl/), float, bv2)
   maod_qf    = new((/tmnp, mnl/), integer, bv1)
   msza       = new((/tmnp, mnl/), float, bv2)

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
     (vdir, bv0, iday, startinx, endinx, filename1, filename2, \
      mlat, mlon, maod_qf, maod, msza)

;  CALL SUBROUTINE select_viirs_site.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
     select_viirs_site \
    (iday, bv2, site_lat, site_lon, year(iday), mon(iday), date(iday),          \
     times(iday), site_date, site_pm, mlat, mlon, maod, msza, select_aod(iday), \
     select_aodstd(iday), select_sza(iday), select_pm(iday))

print(select_pm(iday))
    end do

print(select_aod)
print(select_pm)
;=================================================================================
;  PLOT ALL THE DATA INTO SCATTER PLOT
;=================================================================================
   month_display = year(0) + "-" + mon(0)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, minlat, maxlat, minlon, maxlon, \
               site_lon, site_lat, mpplot, plot)

;  CALL SUBROUTINE plot_scatter_viirs_site.ncl TO PLOT SCATTER PLOT
   plot_scatter_viirs_site \
   (wks, nday, month_display, select_aod, select_pm, awplot)
   end do
end
