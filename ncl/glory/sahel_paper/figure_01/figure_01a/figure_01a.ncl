; $ID: figure_01a.ncl V01 04/28/2013 22:53 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM figure_01a READS TOPOGRAPHY FROM WRF met_em FILE AND 
;  WIND FROM NCEP, AND PLOTS THEM TOGETHER.
;
;******************************************************************************
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/28/2013)
;******************************************************************************


;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "../../subroutine/gsn_csm_epa.ncl"
load "../../subroutine/WRFUserARW.ncl"
load "../../subroutine/int2string.ncl"
load "../../subroutine/plot_wrf_contour_vector_topo.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_figure_01a_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET UP DIRECTORY AND FILE NAMES OF NCEP DATA
   dir        = "../data/figure_01/figure_01a/post_data/"
;  topoSSURE
   topof       = "met_em.d01.2008-01-02_01:00:00.nc"
;  U AND V WIND
   uwindf     = "uwnd.mon.mean_surface.nc"
   vwindf     = "vwnd.mon.mean_surface.nc"

;  SET UP LIMITED REGION
   minlat     = -45.0
   maxlat     =  65.0
   minlon     = -55.0
   maxlon     =  75.0

;  NCEP MONTHLY MEANS FROM 1948/01 TO topoSENT(NOW 2012/04)
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
   topoa      = addfile(dir + topof, "r")
   uwinda     = addfile(dir + uwindf, "r")
   vwinda     = addfile(dir + vwindf, "r")
   topo       = topoa->HGT_M
   topo@lat2d = topoa->XLAT_M(0, :, :)
   topo@lon2d = topoa->XLONG_M(0, :, :)
   uwind      = uwinda->uwnd
   vwind      = vwinda->vwnd
   lat        = uwinda->lat
   lon        = uwinda->lon
   time       = uwinda->time
;  EXTEND THE DATA TO LONGITUDE=360.0
   nlat       = dimsizes(lat)
   nlon       = dimsizes(lon)
   ntime      = dimsizes(time)
   new_lat    = new((/nlat, nlon+1/), float)
   new_lon    = new((/nlat, nlon+1/), float)
   new_uwind  = new((/ntime, nlat, nlon+1/), float)
   new_vwind  = new((/ntime, nlat, nlon+1/), float)
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
   new_uwind(:, :, 0:nlon-1) = uwind
   new_uwind(:, :, nlon)     = uwind(:, :, 0)
   new_vwind(:, :, 0:nlon-1) = vwind
   new_vwind(:, :, nlon)     = vwind(:, :, 0)
   new_uwind@lat2d = new_lat
   new_uwind@lon2d = new_lon
   new_vwind@lat2d = new_lat
   new_vwind@lon2d = new_lon
;  SELECT SPECIFIC TIME
   new_time   = (time-time(0))/nhour + \
                greg2jul(start_year, start_month, start_day, -1)
   greg_time  = jul2greg(new_time)

   index      = ind(greg_time(:, 0) .eq. syear .and. \
                    greg_time(:, 1) .eq. smonth)
   if(.not.all(ismissing(index)))then
;  CALL SUBROUTINE plot_wrf_contour_vector_topo.ncl TO PLOT CONTOUR 
;  AND VECTOR 
    plot_wrf_contour_vector_topo \
             (wks, minlat, maxlat, minlon, maxlon, stime, \
              new_uwind(index, :, :), new_vwind(index, :, :), \
              topo(0, :, :), \
              plot)
   end if

end
