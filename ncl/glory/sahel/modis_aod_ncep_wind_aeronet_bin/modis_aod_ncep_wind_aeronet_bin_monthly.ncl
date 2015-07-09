; $ID : modis_aod_ncep_wind_aeronet_bin_monthly.ncl V01 07/24/2012 11:02 
;       BRUCE EXP$
;
;******************************************************************************
;  PROGRAM modis_aod_ncep_wind_aeronet_bin_monthly READS MODIS DAILY AOD 
;  (MOD04/MYD04) AND NCEP/NCAR REANALYSIS DAILY WIND FIELD DATA, AND AERONET 
;  DAILY AOD, GRIDS MODIS AOD, INTERPOLATES AERONET DAILY AOD AT 440nm AND 
;  675nm TO 550nm. PLOTS GRIDED MODIS AOD WITH CONTOUR AND NCEP/NCAR WIND WITH 
;  VECTOR, AND OVERLAID WITH AERONET DAILY AOD AT 550nm.
;
;  SUBROUTINES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/29/2012)
;  (2 ) ADVANCES FOR THIS PROGRAM :
;       bin_sum IS USED IN THIS PROGRAM. SO IT HAS NOT THE FATAL ISSUE OF 
;       COSTING TOO MUCH TIME TO RUN FOR 
;       modis_aod_ncep_wind_aeronet_total_monthly.ncl. (04/06/2013)
;  (3 ) ADD NCEP WIND DAILY AVERAGE AND AERONET DAILY AOD AT 550nm ON DAILY 
;       MODIS AOD AT 550nm CONTOUR PLOT. AND FINALLY PLOT MODIS MONTHLY AOD AT 
;       550nm WITH CONTOUR AND OVERLAID WITH NCEP MONTHLY WIND FIELD AND 
;       AERONET MONTHLY AVERAGED AOD AT 550nm. (04/10/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/int2string.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/interpolate_aod.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/ydn2md.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_ncep_wind_daily.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_ncep_wind_monthly.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/process_day_mod04.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_aeronet_data_daily.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_aeronet_data_monthly.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/bin_sum_modis_aod_1day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/sum_aod_dbaod.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_vector_aod_diff_dim_aeronet.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_modis_aod_ncep_wind_aeronet_bin_monthly_myd_v01")
   gsn_define_colormap(wks,"WhAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   izero      = 0
   fzero      = 0.0

;  OPEN NCEP/NCAR REANALYSES FILES
;  LIST THE NC FILES AND READ NC FILES
   ncep_dir   = "/home/bruce/sshfs/tw/parallel/data/NCEP/sahel/"
   duncep_file= "uwnd.sig995.2008_daily.nc"
   dvncep_file= "vwnd.sig995.2008_daily.nc"
   uncep_file = "uwnd.mon.mean_surface.nc"
   vncep_file = "vwnd.mon.mean_surface.nc"

;  SET UP DIRECTORY AND FILE NAME FOR AERONET DAILY AND MONTHLY DATA
   dadir      = "/home/bruce/sshfs/shw/data/aeronet/sahel/2008/aeronet_sahel_200802_daily/"
   daflist    = "lev20"
   dafname    = asciiread(dadir + daflist, -1, "string")
   ndafname   = dimsizes(dafname)
   ndsites    = ndafname
   nditem     = 66-3
;  675nm Nditem1 : 4
;  440nm Nditem2 : 13
   Nditem1    = 4
   Nditem2    = 13
   adir       = "/home/bruce/sshfs/shw/data/aeronet/sahel/2008/aeronet_sahel_2008_monthly/"
   aflist     = "lev20"
   afname     = asciiread(adir + aflist, -1, "string")
   nafname    = dimsizes(afname)
   nsites     = nafname
   Nmonth     = 2
   nitem      = 116-1
;  675nm Nitem1 : 4
;  440nm Nitem2 : 13
   Nitem1     = 4
   Nitem2     = 13

;  SET DIRECTORY ADN FILE NAME FOR MODIS AOD
   mdir       = "/home/bruce/sshfs/shw/data/satellite/MODIS/sahel/myd04_large/"
   mflist     = "MYD04_200802" 
   mfname     = asciiread(mdir + mflist, -1, "string")
   nmfname    = dimsizes(mfname)
;  loro IS A JUDGE USED TO JUDGE 
;  LAND_AOD   : "land"
;  OCEAN_AOD  : "ocean"
;  LAND_OCEAN_AOD : "land_ocean"
;  DEEP BLUE AOD 550nm LAND : "deep_blue_550_land"
;  DEEP BLUE AOD LAND AT 412nm, 470nm, 660nm: "deep_blue_land"
;  ALL OF THESE REFERED TO MOD04/MYD04 DATA PROPERTIES
   loro       = "deep_blue_550_land"

;  ============================================================================
;  PREPARE GRIDDED LATITUDE AND LONGITUDE
;  ============================================================================
;  SET UP LIMITED REGION
;                        SMALL ;LARGE
   minlat       = -45.0 ;-15.0 ;-45.0
   maxlat       =  65.0 ; 35.0 ; 65.0
   minlon       = -55.0 ;-25.0 ;-55.0
   maxlon       =  75.0 ; 45.0 ; 75.0
;  GRID INTERVAL
   lat_interval = 0.5
   lon_interval = 0.5
   nlat         = floattoint((maxlat-minlat)/lat_interval) + 1
   nlon         = floattoint((maxlon-minlon)/lon_interval) + 1
;  DECLARE ARRAY FOR SUBROUTINE grid_lat_lon.ncl
   grid_lat     = new((/nlat/), float, bv2)
   grid_lon     = new((/nlon/), float, bv2)
   grid_lat2d   = new((/nlat, nlon/), float)
   grid_lon2d   = new((/nlat, nlon/), float)

;  CALL SUBROUTINE grid_lat_lon.ncl TO GET GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (minlat, maxlat, minlon, maxlon, lat_interval, lon_interval, \
    grid_lat, grid_lon, grid_lat2d, grid_lon2d)

;  ============================================================================
;  NCEP PROCESS
;  ============================================================================
;  SET UP DAILY NCEP INFO
   tnday       = 366
   numday      = 31
;  SET UP MONTHLY NCEP INFO
   syear       = 2008
   smonth      = 2
   month_display = int2string(syear) + "-" + int2string(smonth)
   logic_leap  = "leap"
;  DECLARE ARRAY FOR SUBROUTINE read_ncep_wind_monthly.ncl
   nlat_ncep   = 73
   nlon_ncep   = 144
   uwind       = new((/nlat_ncep, nlon_ncep/), float, bv2)
   vwind       = new((/nlat_ncep, nlon_ncep/), float, bv2)
;  DECLARE ARRAY FOR SUBROUTINE read_ncep_wind_daily.ncl
   duwind      = new((/tnday, nlat_ncep, nlon_ncep/), float, bv2)
   dvwind      = new((/tnday, nlat_ncep, nlon_ncep/), float, bv2)

;  CALL SUBROUTINE read_ncep_wind_daily.ncl TO READ NCEP DAILY WIND DATA
   read_ncep_wind_daily \
   (ncep_dir, duncep_file, dvncep_file, duwind, dvwind)

;  CALL SUBROUTINE read_ncep_wind_monthly.ncl TO READ NCEP MONTHLY WIND DATA
   read_ncep_wind_monthly \
   (ncep_dir, uncep_file, vncep_file, syear, smonth, uwind, vwind)

;  ============================================================================
;  MODIS PROCESS
;  ============================================================================
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

;  ============================================================================
;  AERONET PROCESS
;  ============================================================================

;  READ THE WHOLE FILE NAME LIST FOR MONTHLY AERONET AOD INFO
   adata      = asciiread(adir + afname(0), -1, "string")
   nline      = dimsizes(adata)-5
;  DECLARE ARRAY FOR SUBROUTINE read_aeronet_data_monthly.ncl
   aheader    = new((/nitem/),  string,  bv0)
   asitename  = new((/nsites/), string,  bv0)
   alongitude = new((/nsites/), float,   bv2)
   alatitude  = new((/nsites/), float,   bv2)
   aelevation = new((/nsites/), float,   bv2)
   ayear      = new((/nsites, nline/), integer, bv1)
   amonth     = new((/nsites, nline/), integer, bv1)
   aaod_raw   = new((/nsites, nline, nitem/), float, bv2)
;  DECLARE ARRAY FOR SUBROUTINE read_aeronet_data_daily
   daheader   = new((/nditem/),  string,  bv0)
   dayear     = new((/nsites, nday/), integer, bv1)
   damonth    = new((/nsites, nday/), integer, bv1)
   daday      = new((/nsites, nday/), integer, bv1)
   daaod_raw  = new((/nsites, nday, nditem/), float, bv2)

;  DO # OF SITE LOOP TO READ ALL THE AERONET SITES
   do isite = 0, nsites-1

;  CALL SUBROUTINE read_aeronet_data_daily TO READ OUT DAILY AERONET SITE INFO AND AOD
    read_aeronet_data_daily \
    (dadir, dafname(isite), nday, dayear(isite, :), damonth(isite, :), daday(isite, :), \
     asitename(isite), alongitude(isite), alatitude(isite),   \
     aelevation(isite), daheader, daaod_raw(isite, :, :))

;  CALL SUBROUTINE read_aeronet_data_monthly TO READ OUT MONTHLY AERONET SITE INFO AND AOD
    read_aeronet_data_monthly \
    (adir, afname(isite), ayear(isite, :), amonth(isite, :), \
     asitename(isite), alongitude(isite), alatitude(isite),   \
     aelevation(isite), aheader, aaod_raw(isite, :, :))
   end do

;  DECLARE ARRAY FOR SUBROUTINE interpolate_aod.ncl
   wavelength1= 675.0
   wavelength2= 440.0
   wavelength = 550.0
   daaod      = new((/nsites, nday/), float, bv2)
   aaod       = new((/nsites/), float, bv2)

;  CALL SUBROUTINE interpolate_aod.ncl TO INTERPOLATE DAILY AOD
   interpolate_aod \
   (wavelength1, daaod_raw(:, :, Nditem1-1), wavelength2, daaod_raw(:, :, Nditem2-1), \
    wavelength,  daaod)

;  CALL SUBROUTINE interpolate_aod.ncl TO INTERPOLATE DAILY AOD
   interpolate_aod \
   (wavelength1, aaod_raw(:, Nmonth-1, Nitem1-1), wavelength2, aaod_raw(:, Nmonth-1, Nitem2-1), \
    wavelength,  aaod)

;  DECLARE VARIABLES FOR SUBROUTINE bin_sum_modis_aod_1day.ncl
   grid_aod     = new((/nlat, nlon/), float, bv2)
   grid_aod_ct  = new((/nlat, nlon/), integer, bv1)
   grid_aod_monthly   = new((/nlat, nlon/), float, bv2)
   grid_aod_monthly12 = new((/2, nlat, nlon/), float, bv2)

;  DO DAY LOOP
   icount   = 0
   do iday = 0, nday-1
    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday)
    print("DATE : " + date_display)

    grid_aod    = (/fzero/)
    grid_aod_ct = (/izero/)

;  CALL SUBROUTINE bin_sum_modis_aod_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  AOD QUALITY FLAG, AND AOD FOR ONE DAY.
    bin_sum_modis_aod_1day \
    (mdir, mfname, bv0, iday, loro, startinx, endinx, \
     grid_lat, grid_lon, grid_aod, grid_aod_ct)

    grid_aod@lat2d = grid_lat2d
    grid_aod@lon2d = grid_lon2d

;  CALL SUBROUTINE plot_wrf_contour_vector_aod_diff_dim_aeronet.ncl TO PLOT 
;  AOD CONTOUR AND WIND VECTOR, AND AERONET AOD
    plot_wrf_contour_vector_aod_diff_dim_aeronet  \
    (wks, minlat, maxlat, minlon, maxlon, alatitude, alongitude,       \
     daaod(:, iday), date_display, duwind(numday+iday, :, :), dvwind(numday+iday, :, :), grid_aod)
     grid_aod_monthly12 = (/grid_aod_monthly, grid_aod/)
     grid_aod_monthly   =dim_sum_n_Wrap(grid_aod_monthly12, 0)
     icount = icount + 1
    delete([/date_display/])
   end do

   print("=========================================================")
   print("              START TO PROCESS MONTHLY DATA")
;  START TO PLOT MONTHLY AVERAGE AOD AND WIND
   grid_aod_monthly       = grid_aod_monthly/icount
   grid_aod_monthly@lat2d = grid_lat2d
   grid_aod_monthly@lon2d = grid_lon2d

;  CALL SUBROUTINE plot_wrf_contour_vector_aod_diff_dim_aeronet.ncl TO PLOT 
;  AOD CONTOUR AND WIND VECTOR
   plot_wrf_contour_vector_aod_diff_dim_aeronet  \
   (wks, minlat, maxlat, minlon, maxlon, alatitude, alongitude,        \
    aaod, month_display, uwind, vwind, grid_aod_monthly)

end
