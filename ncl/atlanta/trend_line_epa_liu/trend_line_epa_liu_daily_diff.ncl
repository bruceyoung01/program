;  $ID: trend_line_epa_liu_daily_diff.ncl V01 03/07/2013 11:47 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_epa_liu_daily_diff READS EPA HOURLY DATA AND LIU'S HOURLY 
;  DATA, AND PLOT DAILY TREND LINE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/07/2013)
;******************************************************************************
;  LOAD PROCEDURES AND FUNCTIONS
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/correlation.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/add_markers.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/markern_map_diff.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_liu_pm_hourly.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/convert_date_order_day_epa.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/convert_date_order_day_liu.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/convert_utc_to_local_all.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_trend_daily_pm_epa_liu_diff.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_trend_line_epa_liu_daily_diff_v05")
   gsn_define_colormap(wks, "BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   minlat     =  33.0
   maxlat     =  34.5
   minlon     = -85.0
   maxlon     = -83.5

;  SETUP EPA SITE OBERVATION INFO
   edir       = "/shared/aerosol/bruceyoung01/data/atlanta/epa/"
   efname     = "AQS_PM25_hourly.txt"
   epa_id     = (/"130770002", "130890002", "131210055", "131350002", \
                  "131510002"/)
   elat       = (/ 33.4040,  33.6880,  33.7206,  33.9631,  33.4336/)
   elon       = (/-84.7460, -84.2905, -84.3574, -84.0692, -84.1617/)
   nsite      = dimsizes(epa_id)

;  SETUP LIU'S OBSERVATION INFO
   ldir       = "/shared/aerosol/bruceyoung01/data/atlanta/liu/"
   lfname1    = "Hourly_average.txt"
   lfname2    = "hourly_GRIMM_PM25_concentration.csv"
   llat       = (/ 33.7975/)
   llon       = (/-84.3239/)

;  START DATE AND END DATE
   start_year = 2012
   start_month= 8
   start_day  = 1
   start_hour = 1
   end_year   = 2013
   end_month  = 1
   end_day    = 31
   end_hour   = 24
   nhour      = 24
   time_lag   = -5
   start_jul  = doubletoint(greg2jul(start_year, start_month, start_day, start_hour-1))
   end_jul    = doubletoint(greg2jul(end_year, end_month, end_day, end_hour-1))
   nsmp       = end_jul - start_jul

;  DECLARE VARIABLES FOR SUBSOURINTE read_epa_pm_hourly_allsite.ncl
   nrows      = 60000
   ename      = new((/nrows, 1/), string,  bv0)
   egeo       = new((/nrows, 2/), float,   bv2)
   edate      = new((/nrows, 4/), integer, bv1)
   eudate     = new((/nrows, 4/), integer, bv1)
   epm        = new((/nrows, 1/), float,   bv2)

;  DECLARE ARRAY FOR SUBROUTINE read_liu_pm_hourly.ncl TO LIU'S DATA
   nrows1     = 600
   ldate1     = new((/nrows1, 4/), integer, bv1)
   lpm1       = new((/nrows1, 4/), float,   bv2)
   nrows2     = 635
   ldate2     = new((/nrows2, 4/), integer, bv1)
   lpm2       = new((/nrows2, 1/), float,   bv2)

;  DECLEAR TWO ARRAYS TO HOLD EPA AND LIU'S DATA, RESPECTIVELY
   select_epm    = new((/nsite, nsmp/), float, bv2)
   select_epmstd = new((/nsite, nsmp/), float, bv2)
   select_lpm    = new((/2, nsmp/), float, bv2)
   select_lpm1   = new((/nsmp/), float, bv2)
   select_lpmstd1= new((/nsmp/), float, bv2)
   select_lpm2   = new((/nsmp/), float, bv2)
   select_lpmstd2= new((/nsmp/), float, bv2)

;  DECLARE TWO GRAPHIC ARRAY FOR marker2_map.ncl
   mpplot     = new((/1/), graphic)
   plot       = new((/1/), graphic)

;  CALL SUBROUTINE read_epa_pm_hourly_allsite.ncl TO READ
;  EPA OBSERVED PM
   read_epa_pm_hourly_allsite \
   (edir, efname, ename, egeo, edate, epm)

;  CALL SUBROUTINE convert_utc_to_local_all.ncl TO CONVERT UTC TIME TO
;  LOCAL TIME
   convert_utc_to_local_all \
   (edate(:, 0), edate(:, 1), edate(:, 2), edate(:, 3), time_lag, \
    eudate(:, 0), eudate(:, 1), eudate(:, 2), eudate(:, 3))

;  CALL SUBROUTINE read_liu_pm_hourly.ncl TO READ LIU'S DATA
   read_liu_pm_hourly \
   (ldir, lfname1, ldate1, lpm1)

   read_liu_pm_hourly \
   (ldir, lfname2, ldate2, lpm2)

;  DO SITE LOOP
   do isite = 0, nsite-1
    select_lpm = 0.0

;  CALL SUBROUTINE convert_date_order_day_epa.ncl AND convert_date_order_day_liu.ncl 
;  TO CONVERT EPA AND LIU'S DATA TO DATE ORDER
    convert_date_order_day_epa \
    (bv2, epa_id(isite), start_year, start_month, start_day, start_hour, \
     nsmp, ename, eudate, epm, select_epm(isite, :), select_epmstd(isite, :))

    convert_date_order_day_liu \
    (bv2, start_year, start_month, start_day, start_hour, \
     nsmp, ldate1, lpm1, select_lpm1, select_lpmstd1)

    convert_date_order_day_liu \
    (bv2, start_year, start_month, start_day, start_hour, \
     nsmp, ldate2, lpm2, select_lpm2, select_lpmstd2)

    select_lpm           = (/select_lpm1, select_lpm2/)
    select_lpm_all       = dim_sum_n(select_lpm, 0)
    diff_pm              = select_lpm_all - select_epm(isite, :)
;print(epa_id(isite))
;print(select_lpm_all + "==" + select_epm(isite, :))

;  CALL SUBROUTINE markern_map_diff.ncl TO PLOT SITE MARKER ON THE MAP
    all_lat = (/elat(isite), llat/)
    all_lon = (/elon(isite), llon/)
    markern_map_diff \
    (wks, minlat, maxlat, minlon, maxlon, \
     all_lon, all_lat, mpplot)

;  CALL SUBROUTINE plot_trend_daily_pm_epa_liu_diff.ncl 
;  TO PLOT TREND LINE OF DIFFERENCE BETWEEN EPA AND LIU
    plot_trend_daily_pm_epa_liu_diff \
    (wks, epa_id(isite), diff_pm, mpplot)

   end do

end
