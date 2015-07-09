;  ID: trend_line_epa_liu_filter.ncl V01 15:22 04/01/2013 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_epa_liu_filter READS EPA HOURLY PM2.5 DATA AND LIU'S 
;  FILTER-BASED PM2.5 DATA, AND MATCH THEM EACH OTHER, PLOTS TREND LINE IMAGE 
;  WITH ALL THE STATISTICS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/01/2013)
;******************************************************************************
;
;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/correlation.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/add_markers.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/markern_map_diff.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/convert_utc_to_local_all.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_liu_filter_daily.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/convert_date_order_day_epa.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/convert_date_order_day_liu.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_trend_daily2_pm_epa_liu_filter.ncl"

begin
;  SETUP WORKSTATION
   type = "x11"
;  type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_trend_line_epa_liu_filter_v02")
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
   lfname     = "filter_summary_data.txt"
   llat       = (/ 33.7975/)
   llon       = (/-84.3239/)

;  START DATE AND END DATE
   start_year = 2013
   start_month= 1
   start_day  = 5
   start_hour = 1
   end_year   = 2013
   end_month  = 2
   end_day    = 5
   end_hour   = 24
   nhour      = 24
   half_day   = -12
   time_lag   = -5
   ttime_lag  = half_day + time_lag
   start_jul  = doubletoint(greg2jul(start_year, start_month, start_day, start_hour-1))
   end_jul    = doubletoint(greg2jul(end_year, end_month, end_day, end_hour-1))
   nsmp       = end_jul - start_jul

;  DECLARE VARIABLES FOR SUBSOURINTE read_epa_pm_hourly_allsite.ncl
   nrows1     = 60000
   ename      = new((/nrows1, 1/), string,  bv0)
   egeo       = new((/nrows1, 2/), float,   bv2)
   eudate     = new((/nrows1, 4/), integer, bv1)
   epm        = new((/nrows1, 1/), float,   bv2)

;  CALL SUBROUTINE read_epa_pm_hourly_allsite.ncl TO READ 
;  EPA OBSERVED PM
   read_epa_pm_hourly_allsite \
   (edir, efname, ename, egeo, eudate, epm)

;  DECLARE ARRAY FOR SUBROUTINE convert_utc_to_local_all.ncl
   edate = new((/nrows1, 4/), integer, bv1)

;  CALL SUBROUTINE convert_utc_to_local_all.ncl TO CONVERT EPA UTC TIME 
;  TO ATLANTA LOCAL TIME
   convert_utc_to_local_all \
   (eudate(:, 0), eudate(:, 1), eudate(:, 2), eudate(:, 3), ttime_lag, \
     edate(:, 0),  edate(:, 1),  edate(:, 2),  edate(:, 3))

;  DECLARE THE ARRAY FOR SUBROUTINE read_liu_filter_daily.ncl
   nrows2    = 40
   ldate     = new((/nrows2, 4/), integer, bv1)
   lweight   = new((/nrows2, 3/), float,   bv2)
   lvolume   = new((/nrows2, 3/), float,   bv2)
   lpm       = new((/nrows2, 4/), float,   bv2)

;  CALL SUBROUTINE read_liu_filter_daily.ncl TO READ LIU'S FILTER-BASED DATA
   read_liu_filter_daily \
   (ldir, lfname, ldate, lweight, lvolume, lpm)

;  DECLEAR TWO ARRAYS TO HOLD EPA AND LIU'S DATA, RESPECTIVELY
   select_epm    = new((/nsite, nsmp/), float, bv2)
   select_epmstd = new((/nsite, nsmp/), float, bv2)
   select_lpm    = new((/nsmp/), float, bv2)
   select_lpmstd = new((/nsmp/), float, bv2)

;  DECLARE TWO GRAPHIC ARRAY FOR marker2_map.ncl
   mpplot     = new((/1/), graphic)

;  DO SITE LOOP
   do isite = 0, nsite-1
    select_lpm = 0.0
   
;  CALL SUBROUTINE convert_date_order_day_epa.ncl AND convert_date_order_day_liu.ncl 
;  TO CONVERT EPA AND LIU'S DATA TO DATE ORDER
    convert_date_order_day_epa \
    (bv2, epa_id(isite), start_year, start_month, start_day, start_hour, \
     nsmp, ename, edate, epm, select_epm(isite, :), select_epmstd(isite, :))
   
    convert_date_order_day_liu \
    (bv2, start_year, start_month, start_day, start_hour, \
     nsmp, ldate, lpm, select_lpm, select_lpmstd)
   
;  CALL SUBROUTINE markern_map_diff.ncl TO PLOT SITE MARKER ON THE MAP
    all_lat = (/elat(isite), llat/)
    all_lon = (/elon(isite), llon/)
    markern_map_diff \
    (wks, minlat, maxlat, minlon, maxlon, \
     all_lon, all_lat, mpplot)

;  CALL SUBROUTINE plot_trend_daily2_pm_epa_liu_filter.ncl TO PLOT TREND LINE OF EPA AND LIU
    plot_trend_daily2_pm_epa_liu_filter \
    (wks, epa_id(isite), select_epm(isite, :), select_lpm, mpplot)

   end do

end
