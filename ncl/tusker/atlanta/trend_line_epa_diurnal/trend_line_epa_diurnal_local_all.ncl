;  $ID: trend_line_epa_diurnal_local_all.ncl V01 02/24/2013 16:02 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_epa_diurnal_local_all READS EPA PM OBSERVATION AND 
;  CALCULATES DIURNAL VARIATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/24/2013)
;******************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_pm_hourly_allsite.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/calculate_epa_diurnal.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/convert_utc_to_local.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_trend_line_epa_diurnal_all.ncl"


begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png" 
   wks  = gsn_open_wks(type, "1plt_trend_line_epa_diurnal_local_all_v01")
   gsn_define_colormap(wks, "BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.

;  SETUP SITE OBERVATION INFO
   sdir       = "/shared/aerosol/bruceyoung01/data/atlanta/epa/"
   sfname     = "AQS_PM25_hourly.txt"
;  site_id    = (/"131350002", "130630091", "130670003", "132230003", \
;                 "130890002", "130892001", "131210032", "131210039", \
;                 "131210055", "130670004", "130770002", "131510002"/)
   site_id    = (/"130770002", "130890002", "131210055", "131350002", \
                  "131510002"/)
;  site_id    = (/"130770002"/)
   nsite      = dimsizes(site_id)

;  DEFINE MARKER AND COLOR FOR TREND LINE
   marker     = (/4, 4, 4, 4, 4, 4/)
   linecolor  = (/"red", "red", "red", "red", "red", "blue"/)
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

;  DECLARE ARRAY FOR SUBROUTINE calculate_epa_diurnal.ncl
   nhour             = 24
   select_geo_utc    = new((/2/),     float, bv2)
   select_pm_avg_utc = new((/nsite, nhour/), float, bv2)
   select_pm_std_utc = new((/nsite, nhour/), float, bv2)

;  DECLARE ARRAY FOR SUBROUTINE convert_utc_to_local.ncl
   select_pm_avg_local = new((/nsite, nhour/), float, bv2)
   select_pm_std_local = new((/nsite, nhour/), float, bv2)
   plot                = new((/nsite+1/), graphic)
   plot1               = new((/nsite+1/), graphic)

;  DO SITE LOOP
   do isite = 0, nsite-1
    select_pm     = 0.0
    select_pm_std = 0.0
;  DO HOUR LOOP
    do ihour = 0, nhour-1

;  CALL SUBROUTINE calculate_epa_diurnal.ncl TO CALCULATE HOURLY AVERAGE, 
;  STADNDARD DEVIATION, AND TOTAL AVERAGE.
     calculate_epa_diurnal \
    (ihour, site_id(isite), site_name, site_geo, site_date, site_pm, \
     select_geo_utc, select_pm_avg_utc(isite, ihour), select_pm_std_utc(isite, ihour))
    end do

;  CALL SUBROUTINE convert_utc_to_local.ncl TO CONVERT UTC TIME TO
;  LOCAL TIME
    convert_utc_to_local \
   (select_pm_avg_utc(isite, :), select_pm_std_utc(isite, :), \
    select_pm_avg_local(isite, :), select_pm_std_local(isite, :))

;  CALL SUBROUTINE plot_trend_line_epa_diurnal_all.ncl TO EPA DIURNAL VARIATION
    plot_trend_line_epa_diurnal_all \
   (wks, site_id(isite), select_pm_avg_local(isite, :), select_pm_std_local(isite, :), \
    avg(select_pm_avg_local(isite, :)), nhour, marker(isite), linecolor(isite),        \
    plot(isite), plot1(isite))
   end do

;  ====================PROCESS TOTAL SITES AVERAGE=============================
   select_pm_avg_local_all = dim_avg_n(select_pm_avg_local, 0)
   select_pm_std_local_all = dim_avg_n(select_pm_std_local, 0)

;  CALL SUBROUTINE plot_trend_line_epa_diurnal.ncl TO EPA DIURNAL VARIATION
    plot_trend_line_epa_diurnal_all \
   (wks, site_id(0), select_pm_avg_local_all, select_pm_std_local_all,    \
    avg(select_pm_avg_local_all), nhour, marker(isite), linecolor(isite), \
    plot(isite), plot1(isite))

    gsn_panel(wks, plot, (/nsite+1, 1/), False)
end
