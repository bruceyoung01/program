;  $ID: trend_line_site_wrfchem_pm.ncl V01 11/07/2012 22:00 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_site_wrfchem_pm READS OBSERVATION DATA FROM SITES AND 
;  WRFCHEM, AND PLOT TREND LINE WITH CORRELATION INFO.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (11/07/2012)
;******************************************************************************

;  LOAD LIBRARIES AND FUNTIONS
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/read_site_pm.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/read_wrf_site_pm.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/plot_trend_hourly2_pm.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_trend_line_site_wrfchem_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET SITE DATA DIRECTORY
   site_dir           = "/home/bruce/sshfs/tw/parallel/data/atlanta/sample_Liu/201208/"
   site_pmlist        = "pm.list"
   site_pmfilename    = asciiread(site_dir + site_pmlist,    -1, "string")
   n_site_pmfilename  = dimsizes(site_pmfilename)

;  SITE INFO
   site_lat           = (/ 33.7806,  33.8378,  33.8589,  33.8547,  33.8069,  33.8242/)
   site_lon           = (/-84.6306, -84.6850, -84.5778, -84.7153, -84.5292, -84.5531/)
;  SET WRFCHEM DATA DIRECTORY
   wrfchem_dir        = "/mnt/sdb/data/wrf/atlanta/"
   wrfchem_filename   = "wrfout_d03_2012-08*"

;  DEFINE MISSING VALUE
   bv1                = -999
   bv2                = -999.
;  SET UP TIME
   start_year         = 2012
   end_year           = 2012
   start_month        = 8
   end_month          = 8
   start_day          = 1
   end_day            = 31
   start_hour         = 0
   end_hour           = 23

;  SET UP LIMITED REGION
   minlat     = 33.0
   maxlat     = 34.0
   minlon     =-85.0
   maxlon     =-84.0
;  CONVERT CALENDAR DATE TO JULIAN DATE
   start_jd           = doubletoint(greg2jul(start_year, start_month, start_day, end_hour))
   end_jd             = doubletoint(greg2jul(end_year, end_month, end_day, end_hour))
;  GET ALL THE HOUR NEEDED
   nhour              = (end_jd - start_jd + 1)*24
;  DECLARE ARRAY FOR SITE
   ndatespe           = 4
   nspe               = 3
   site_name          = new((/1/), string)
   site_date          = new((/nhour, ndatespe/), integer, bv1)
   site_pm            = new((/nhour, nspe/),     float,   bv2)
;  DECLARE ARRAY FOR WRFCHEM
   npm                = 2
   wdate              = new((/nhour, ndatespe/), integer, bv1)
   wpm                = new((/nhour, npm/),      float,   bv2)
   mpplot             = new(1, graphic)
   plot               = new(1, graphic)


;  DO THE SITE LOOP TO PROCESS DATA
   do i = 0, n_site_pmfilename - 1

    ; CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, minlat, maxlat, minlon, maxlon, \
               site_lon(i), site_lat(i), mpplot, plot)

    ; CALL PROCEDURE read_site_pm.ncl TO READ SITE DATA
    read_site_pm(site_dir, site_pmfilename(i), bv1, bv2, start_jd, end_jd, \
                 start_hour, end_hour, site_name, site_date, site_pm)

    ; CALL PROCEDURE read_wrf_site_pm.ncl TO READ WRFCHEM DATA
    read_wrf_site_pm(wrfchem_dir, wrfchem_filename, site_lat(i), site_lon(i), \
                     bv1, bv2, start_jd, end_jd, start_hour, end_hour,        \
                     wdate, wpm)

    ; CALL PROCEDURE plot_trend_hourly2_pm.ncl TO PLOT TREND LINE OBS vs WRF-Chem
    plot_trend_hourly2_pm(wks, site_name, site_pm(:, 1), wpm(:, 1), nhour, mpplot)

   end do

end
