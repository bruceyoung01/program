; $ID: ncep_pre_wind_monthly.ncl V01 05/15/2012 16:04 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM ncep_pre_wind_monthly READS CDC Derived NCEP Reanalysis Products 
;  Surface Level, INCLUDING PRESSURE AND WIND, AND PLOTS THEM TOGETHER.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/15/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/int2string.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_vector_ncep_pre.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_ncep_pre_wind_monthly_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET UP DIRECTORY AND FILE NAMES OF NCEP DATA
   dir        = "/home/bruce/Desktop/"
;  PRESSURE
   pref       = "pres.mon.mean.nc"
;  U AND V WIND
   uwindf     = "uwnd.mon.mean.nc"
   vwindf     = "vwnd.mon.mean.nc"

;  SET UP LIMITED REGION
;                           WA       CA     SAHEL
   minlat     = -15.0     ; 30.0    ;10    ;-15.0
   maxlat     =  35.0     ; 45.0    ;45    ; 35.0
   minlon     = -25.0     ;-130.0   ;-115  ;-25.0
   maxlon     =  45.0     ;-110.0   ;-65   ; 45.0

;  NCEP MONTHLY MEANS FROM 1948/01 TO PRESENT(NOW 2012/04)
   start_year = 1948
   start_month= 1
   start_day  = 1
;  SPECIFIC YEAR, MONTH
   syear      = 2008
   smonth     = 2
   stime      = int2string(syear) + "-" + int2string(smonth)
;  TIME STEP FOR ONE DAY
   nhour      = 24

;  DEFINE GRAPHIC
   plot       = new(1, graphic)
;  READ FILES
   prea       = addfile(dir + pref, "r")
   uwinda     = addfile(dir + uwindf, "r")
   vwinda     = addfile(dir + vwindf, "r")
   pres       = prea->pres
   uwind      = uwinda->uwnd
   vwind      = vwinda->vwnd
   lat        = prea->lat
   lon        = prea->lon
   time       = prea->time
   new_time   = (time-time(0))/nhour + \
                greg2jul(start_year, start_month, start_day, -1)
   greg_time  = jul2greg(new_time)

   index      = ind(greg_time(:, 0) .eq. syear .and. \
                    greg_time(:, 1) .eq. smonth)
   if(.not.all(ismissing(index)))then
;  CALL SUBROUTINE plot_wrf_contour_vector_ncep_pre.ncl TO PLOT CONTOUR 
;  AND VECTOR 
    plot_wrf_contour_vector_ncep_pre \
             (wks, minlat, maxlat, minlon, maxlon, stime, \
              uwind(index, :, :), vwind(index, :, :), pres(index, :, :), \
              plot)
   end if

end
