;  $ID: scatter_epa_viirs_hourly.ncl V01 02/06/2013 14:00 BUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter_epa_viirs_hourly READS PM CONCENTRATION FROM EPA OBSERVATION 
;  OVER ATLANTA AND PICKS UP THE POINTS IN VIIRS BASED ON DIFFERENT SITES INFO 
;  AND TIME.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/06/2013)
;  (2 ) MODIFIED FROM scatter_epa_viirs.ncl. (02/06/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/process_day_viirs.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/select_viirs_epa_hourly.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/plot_scatter_viirs_epa.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_epa_viirs_grid_hourly_atlanta_v03_005_excellent_test")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")
   
;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"

;  SETUP VIIRS DATA INFO
   vdir       = "/home/bruce/sshfs/shw/data/satellite/NPP/atlanta/all_data/night/"
   vgflist    = "GDNBO_list_excellent"
   vrflist    = "SVDNB_list_excellent"
;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename1  = asciiread(vdir + vgflist, -1, "string")
   filename2  = asciiread(vdir + vrflist, -1, "string")
   nfile      = dimsizes(filename1)

;  SETUP SITE OBERVATION INFO
   sdir       = "/home/bruce/sshfs/shw/data/atlanta/epa/"
   sfname     = "AQS_PM25_hourly.txt"
;  site_id    = (/"131350002", "130630091", "130670003", "132230003", \
;                 "130890002", "130892001", "131210032", "131210039", \
;                 "131210055", "130670004", "130770002", "131510002"/)
;  site_id    = (/"131350002", "130890002", "131210055", "130770002", \
;                 "131510002"/)
   site_id    = (/"130770002"/)
   nsite      = dimsizes(site_id)
   minlat     = 33.0
   maxlat     = 34.5
   minlon     = -85.5
   maxlon     = -83.5

;  DECLARE VARIABLES FOR SUBROUTINE process_day_viirs
   tmpnday    = 200
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

;  DECLARE VARIABLES FOR SUBSOURINTE read_epa_pm_hourly_allsite.ncl
   nrows      = 46000
   site_name  = new((/nrows, 1/), string, bv0)
   site_geo   = new((/nrows, 2/), float, bv2)
   site_date  = new((/nrows, 4/), integer, bv1)
   site_pm    = new((/nrows, 1/), float, bv2)

;  CALL process_day_viirs.ncl TO GET FILE INFO FROM FILE NAME
   process_day_viirs \
   (vdir, vrflist, logic_leap, nday, startinx, endinx, \
    year, mon, date, times, timee, dayname, daynum)

;  DECLARE ARRAY FOR SUBROUTINE read_epa_pm_hourly_allsite.ncl TO READ 
;  EPA OBSERVED PM
   read_epa_pm_hourly_allsite \
   (sdir, sfname, site_name, site_geo, site_date, site_pm)

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
   do isite = 0, 0;nsite-1
;  DECLARE FINAL OUPUT FOR PLOT FOR SUBROUTINE select_viirs_epa_hourly.ncl
   site_lat      = new(1,      float, bv2)
   site_lon      = new(1,      float, bv2)
   select_aod    = new((nday), float, bv2)
   select_aodstd = new((nday), float, bv2)
   select_pm     = new((nday), float, bv2)
   select_pmstd  = new((nday), float, bv2)
   select_sza    = new((nday), float, bv2)

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

;  CALL SUBROUTINE select_viirs_site_hourly.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
     select_viirs_epa_hourly \
    (iday, bv2, site_id(isite), site_name, site_geo, year(iday), mon(iday), date(iday), \
     times(iday), site_date, site_pm, mlat, mlon, maod, msza, site_lat, site_lon,       \
     select_aod(iday), select_aodstd(iday), select_sza(iday), select_pm(iday))

    end do
print(site_id(isite))
print(select_aod)
print(select_pm)
;=================================================================================
;  PLOT ALL THE DATA INTO SCATTER PLOT
;=================================================================================
   month_display = year(0) + "-" + mon(0)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, minlat, maxlat, minlon, maxlon, \
               site_lon, site_lat, mpplot, plot)

;  CALL SUBROUTINE plot_scatter_viirs_epa.ncl TO PLOT SCATTER PLOT
   plot_scatter_viirs_epa \
   (wks, site_id(isite), nday, month_display, select_aod, select_pm, awplot)
   delete([/site_lat, site_lon, select_aod, select_pm, select_aodstd, select_sza/])
  end do
end
