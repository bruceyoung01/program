;  ID: trend_line_liu_filter_ratio.ncl V01 15:22 04/01/2013 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_liu_filter_ratio READS LIU'S FILTER-BASED PM2.5 DATA, 
;  COMPUTES THE RATIO OF LIU'S GRIMM PM2.5 AND EPA-TYPE PM2.5, AND FINALLY
;  PLOTS TREND LINE IMAGE WITH ALL THE STATISTICS.
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
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/markern_map.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/convert_utc_to_local_all.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_liu_filter_daily.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/convert_date_order_day_epa.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/convert_date_order_day_liu.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_trend_daily_pm_liu_filter_ratio.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_trend_line_epa_liu_filter_ratio_v01")
   gsn_define_colormap(wks, "BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   minlat     =  33.0
   maxlat     =  34.5
   minlon     = -85.0
   maxlon     = -83.5

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

;  DECLARE THE ARRAY FOR SUBROUTINE read_liu_filter_daily.ncl
   nrows2    = 40
   ldate     = new((/nrows2, 4/), integer, bv1)
   lweight   = new((/nrows2, 3/), float,   bv2)
   lvolume   = new((/nrows2, 3/), float,   bv2)
   lpm       = new((/nrows2, 4/), float,   bv2)

;  CALL SUBROUTINE read_liu_filter_daily.ncl TO READ LIU'S FILTER-BASED DATA
   read_liu_filter_daily \
   (ldir, lfname, ldate, lweight, lvolume, lpm)

;  DECLEAR TWO ARRAYS TO HOLD LIU'S DATA, RESPECTIVELY
   select_lpm    = new((/nsmp, 4/), float, bv2)
   select_lpmstd = new((/nsmp, 4/), float, bv2)
   ratio         = new((/nsmp/),    float, bv2)

;  DECLARE TWO GRAPHIC ARRAY FOR marker2_map.ncl
   mpplot     = new((/1/), graphic)

;  CALL SUBROUTINE convert_date_order_day_liu.ncl TO CONVERT EPA AND LIU'S DATA TO DATE ORDER   
   convert_date_order_day_liu \
   (bv2, start_year, start_month, start_day, start_hour, \
    nsmp, ldate, lpm, select_lpm, select_lpmstd)

;  CALL SUBROUTINE markern_map.ncl TO PLOT SITE MARKER ON THE MAP
   markern_map \
   (wks, minlat, maxlat, minlon, maxlon, \
    llon, llat, mpplot)
   ratio = select_lpm(:, 3)/select_lpm(:, 0)

;  CALL SUBROUTINE plot_trend_daily_pm_liu_filter_ratio.ncl TO PLOT TREND LINE OF LIU DATA RATIO
   plot_trend_daily_pm_liu_filter_ratio \
   (wks, ratio, mpplot)

end
