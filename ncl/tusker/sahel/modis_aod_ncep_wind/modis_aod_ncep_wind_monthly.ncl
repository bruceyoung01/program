; $ID : modis_aod_ncep_wind_contour_monthly.ncl V01 07/24/2012 11:02 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM modis_aod_ncep_wind_contour_monthly READS MODIS AOD (MOD04/MYD04) 
;  AND NCEP/NCAR REANALYSIS DATA, GRIDS MODIS AOD, PLOTS GRIDED MODIS AOD WITH 
;  CONTOUR AND NCEP/NCAR WIND WITH VECTOR.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/29/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/int2string.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/ydn2md.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/process_day_mod04.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_modis_aod_1day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/pixel_to_grid_degree_1day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_vector_aod_diff_dim.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_modis_dbaod550_land_ncep_wind_contour_monthly_sahel_v03")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.

;  OPEN NCEP/NCAR REANALYSES FILES
;  LIST THE NC FILES AND READ NC FILES
   ncep_dir   = "/home/bruce/sshfs/tw/parallel/data/NCEP/sahel/"
   uncep_file = "uwnd.mon.mean_pressure_level.nc"
   vncep_file = "vwnd.mon.mean_pressure_level.nc"
   
;  SET DIRECTORY ADN FILE NAME FOR MODIS AOD
   mdir       = "/home/bruce/sshfs/shw/data/satellite/MODIS/sahel/myd04_large/"
   mflist     = "MYD04_200802" 
;  loro IS A JUDGE USED TO JUDGE 
;  LAND_AOD   : "land"
;  OCEAN_AOD  : "ocean"
;  LAND_OCEAN_AOD : "land_ocean"
;  DEEP BLUE AOD 550nm LAND : "deep_blue_550_land"
;  DEEP BLUE AOD LAND AT 412nm, 470nm, 660nm: "deep_blue_land"
   loro       = "deep_blue_550_land"
   mfname     = asciiread(mdir + mflist, -1, "string")
   nmfname    = dimsizes(mfname)

;  SET UP LIMITED REGION
;                    OMALINK  NE_NEST2     NE_NEST1    NE      WA       CA     SAHEL  LARGE-SAHEL
   minlat     =-45.0 ;40.5    ;39.5       ; 30.0    ; 25.0   ; 30.0    ; 10    ;-15.0 ;-45.0
   maxlat     = 65.0 ;41.5    ;42.0       ; 43.0    ; 45.0   ; 45.0    ; 45    ; 35.0 ; 65.0
   minlon     =-55.0 ;-97.0   ;-99.0      ;-115.0   ;-115.0  ;-130.0   ;-115   ;-25.0 ;-55.0
   maxlon     = 75.0 ;-95.5   ;-94.5      ;-93.0    ;-90.0   ;-110.0   ;-65    ; 45.0 ; 75.0
;  GRID INTERVAL
   lat_interval = 0.5
   lon_interval = 0.5
;  CALCULATE GRID SIZE DEPENDING ON GRID INTERVAL AND REGION LIMIT
   nlat       = floattoint((maxlat-minlat)/lat_interval) + 1
   nlon       = floattoint((maxlon-minlon)/lon_interval) + 1

;  NCEP MONTHLY MEANS FROM 1948/01 TO PRESENT(NOW 2012/04)
   start_year = 1948
   start_month= 1
   start_day  = 1
   nhour      = 24
   syear      = 2008
   smonth     = 2
   month_display = int2string(syear) + "-" + int2string(smonth)
   logic_leap = "leap"
;  PRESSURE LEVEL FOR NCEP MONTHLY WIND DATA
   plevel     = 3

;  READ NCEP MONTHLY WIND DATA
   uwinda     = addfile(ncep_dir + uncep_file, "r")
   vwinda     = addfile(ncep_dir + vncep_file, "r")
   uwind1     = uwinda->uwnd(:, plevel, :, :)
   uoffset    = uwind1@add_offset
   uscale     = uwind1@scale_factor
   uwind      = (uwind1*uscale) + uoffset
   vwind1     = vwinda->vwnd(:, plevel, :, :)
   voffset    = vwind1@add_offset
   vscale     = vwind1@scale_factor
   vwind      = (vwind1*uscale) + uoffset
   lat        = uwinda->lat
   lon        = uwinda->lon
;  CONVERT LATITUDE AND LONGITUDE TO 2D
   nlata      = dimsizes(lat)
   nlona      = dimsizes(lon)
   new_lata   = new((/nlata, nlona/), float)
   new_lona   = new((/nlata, nlona/), float)
   do i = 0, nlata-1
    do j = 0, nlona-1
     new_lata(i, j) = lat(i)
     new_lona(i, j) = lon(j)
    end do
   end do
   uwind@lat2d= new_lata
   uwind@lon2d= new_lona
   vwind@lat2d= new_lata
   vwind@lon2d= new_lona
   time       = uwinda->time
   new_time   = (time-time(0))/nhour + \
                greg2jul(start_year, start_month, start_day, -1)
   greg_time  = jul2greg(new_time)

   index      = ind(greg_time(:, 0) .eq. syear .and. \
                    greg_time(:, 1) .eq. smonth)

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   tmpnday    = 40
   nday       = new(1, integer, bv1)
   startinx   = new(tmpnday, integer, bv1)
   endinx     = new(tmpnday, integer, bv1)
   year       = new(tmpnday, integer, bv1)
   mon        = new(tmpnday, integer, bv1)
   date       = new(tmpnday, integer, bv1)
   times      = new(tmpnday, string,  bv0)
   timee      = new(tmpnday, string,  bv0)
   dayname    = new(tmpnday, string,  bv0)
   daynum     = new(tmpnday, integer, bv1)

;  CALL SUBROUTINE process_day_mod04.ncl TO READ OUT INFO FROM MODIS FILE NAME
   process_day_mod04(mdir, mflist, logic_leap,         \
                     nday, startinx, endinx, year, mon,\
                     date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl
   minpixel   = 0
   mnp        = 203
   mnl        = 135
   mfactor    = 60
   tmnp       = mnp*mfactor
   mlat       = new((/nday, tmnp, mnl/), float, bv2)
   mlon       = new((/nday, tmnp, mnl/), float, bv2)
   maod       = new((/nday, tmnp, mnl/), float, bv2)
   maod_qf    = new((/nday, tmnp, mnl/), integer, bv1)

;  DECLARE VARIABLES FOR SUBROUTINE pixel_to_grid_degree_1day.ncl
   grid_lat   = new((/nday, nlat, nlon/), float, bv2)
   grid_lon   = new((/nday, nlat, nlon/), float, bv2)
   grid_aod   = new((/nday, nlat, nlon/), float, bv2)

;  DO DAY LOOP
   maod     = 0.0
   grid_aod = 0.0
   icount   = 0
   do iday = 0, 0;nday-1

    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_modis_aod_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  AOD QUALITY FLAG, AND AOD FOR ONE DAY.
    read_modis_aod_1day \
    (mdir, bv0, iday, startinx, endinx, mfname, loro, \
     mlat(iday, :, :), mlon(iday, :, :),              \
     maod_qf(iday, :, :), maod(iday, :, :))

;  CALL SUBROUTINE pixel_to_grid_degree_1day.ncl TO GRID AOD DATA
    pixel_to_grid_degree_1day \
    (lat_interval, lon_interval, minlat, maxlat, minlon, maxlon, \
     nlat, nlon, mlat(iday, :, :), mlon(iday, :, :),             \
     maod_qf(iday, :, :), maod(iday, :, :),                      \
     grid_lat(iday, :, :), grid_lon(iday, :, :), grid_aod(iday, :, :))

    grid_aod@lat2d = grid_lat(iday, :, :)
    grid_aod@lon2d = grid_lon(iday, :, :)

;  CALL SUBROUTINE plot_wrf_contour_vector_aod_diff_dim.ncl TO PLOT 
;  AOD CONTOUR AND WIND VECTOR
    plot_wrf_contour_vector_aod_diff_dim  \
    (wks, minlat, maxlat, minlon, maxlon, \
     date_display, uwind(index, :, :),    \
     vwind(index, :, :), grid_aod(iday, :, :))

    delete([/date_display/])
   end do

   print("=========================================================")
   print("              START TO PROCESS MONTHLY DATA")
;  START TO PLOT MONTHLY AVERAGE AOD AND WIND
   grid_aod_monthly         = dim_avg_n_Wrap(grid_aod, 0)
;  CALL SUBROUTINE plot_wrf_contour_vector_aod_diff_dim.ncl TO PLOT 
;  AOD CONTOUR AND WIND VECTOR
   plot_wrf_contour_vector_aod_diff_dim  \
   (wks, minlat, maxlat, minlon, maxlon, \
    month_display, uwind(index, :, :),   \
    vwind(index, :, :), grid_aod_monthly)

end
