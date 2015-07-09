; $ID: ncep_prec_monthly.ncl V01 05/15/2012 16:04 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM ncep_pre_monthly READS CDC Derived NCEP Reanalysis Products 
;  Surface Level, INCLUDING PRECIPITATION, AND PLOTS IT.
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_variable_prec.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_ncep_prec_monthly_v01_200802")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET UP DIRECTORY AND FILE NAMES OF NCEP DATA
   dir        = "/home/bruce/sshfs/tw/parallel/data/NCEP/sahel/"
;  PRECIPITATION
   precf      = "pr_wtr.eatm.mon.mean_surface.nc"

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

;  READ FILES
   preca      = addfile(dir + precf, "r")
   prec       = preca->pr_wtr
   lat        = preca->lat
   lon        = preca->lon
   time       = preca->time
;  EXTEND THE DATA TO LONGITUDE=360.0
   nlat       = dimsizes(lat)
   nlon       = dimsizes(lon)
   ntime      = dimsizes(time)
   new_lat    = new((/nlat, nlon+1/), float)
   new_lon    = new((/nlat, nlon+1/), float)
   new_prec   = new((/ntime, nlat, nlon+1/), float)
;  CONVERT LATITUDE AND LONGITUDE TO 2D
   do i = 0, nlat-1
    do j = 0, nlon
     new_lat(i, j) = lat(i)
     if (j .lt. nlon) then
      new_lon(i, j) = lon(j)
     else if (j .eq. nlon) then
      new_lon(i, j) = 360.0
     end if
     end if
    end do
   end do
   new_prec(:, :, 0:nlon-1) = prec
   new_prec(:, :, nlon)     = prec(:, :, 0)
   new_prec@lat2d = new_lat
   new_prec@lon2d = new_lon
;  SELECT SPECIFIC TIME
   new_time   = (time-time(0))/nhour + \
                greg2jul(start_year, start_month, start_day, -1)
   greg_time  = jul2greg(new_time)

   index      = ind(greg_time(:, 0) .eq. syear .and. \
                    greg_time(:, 1) .eq. smonth)
   if(.not.all(ismissing(index)))then
;  CALL SUBROUTINE plot_wrf_contour_variable_prec.ncl TO PLOT CONTOUR 
;  AND VECTOR 
    plot_wrf_contour_variable_prec \
             (wks, minlat, maxlat, minlon, maxlon, \
              new_prec(index, :, :), stime)
   end if

end
