; $ID: aeronet_modis_trend_line_daily.ncl V01 01/16/2012 14:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM aeronet_modis_trend_line_daily IS USED TO PLOT THE TREND LINE
;  BETWEEN AERONET AOD AND WRFCHEM PM2.5 SIMULATED CONCENTRATION, AND PLOT IT 
;  OUT AS LINE PLOT.(BRUCE 01/16/2012)
;
;  VARIABLES:
;  ============================================================================
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/16/2012)
;  (2 ) ADD CORRELATION INFO. (02/19/2012)
;******************************************************************************
;

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_aeronet_data.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/calculate_aeronet_hourly_average.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/point_wrfchem_aeronet_daily.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/point_modis_aeronet_daily_hour.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_trend_daily3_wam.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_aeronet_modis_trend_line_daily_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET DIRECTORY AND FILE NAME LIST
   dir        = "/home/bruce/sshfs/shw/data/aeronet/sahel/2008/aeronet_sahel_200802/"
   fnamelist  = "ONEILL_20"
   fname      = asciiread(dir + fnamelist, -1, "string")
   nsites     = dimsizes(fname)

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_dust_650/wrfout/"
   sfile      = "wrfout_d01_2008-02*"

;  SET DIRECTORY ADN FILE NAME FOR MODIS AOD
   mdir       = "/home/bruce/sshfs/shw/data/satellite/MODIS/sahel/mod04/"
   mflist     = "MOD04_200802"
   mfname     = asciiread(mdir + mflist, -1, "string")
   nmfname    = dimsizes(mfname)

   nhour      = 24
   nitem      = 60
   nhourly    = 999 ; # OF HOURS PER MONTH
   nday       = 29  ; # OF DAYS
;  NOTE: AERONET AOD(675nm)   sitem=6
;        AERONET AOD(500nm)   sitem=3
;        FIND MODE AOD (500nm)sitem=4
   sitem      = 3
;  FACTOR BETWEEN AERONET AND WRFCHEM
   factor     = 1.0

;  DEFINE MISSING VALUE
   bv1        = -999
   bv2        = -999.
   minlat     = -15.0
   maxlat     =  35.0
   minlon     = -25.0
   maxlon     =  45.0
   sitename   = new(1, string)
   longitude  = new(1, float, bv2)
   latitude   = new(1, float, bv2)
   elevation  = new(1, float, bv2)
   nfiles     = new(1, integer, bv1)
   header     = new(  nitem, string)
   date       = new((/nhourly, 4/), integer, bv1)
   mpplot     = new(1, graphic)
   awplot     = new(1, graphic)

;============================AERONET SITES=====================================
;  DO LOOP # OF SITES
   do i = 0, nsites-1
    iselect = 0
    system("date")
    print("WORKING ON SITES : " + i + " OF " + nsites)
;  READ THE WHOLE FILE NAME LIST FOR AERONET AOD INFO
    sdata      = asciiread(dir + fname(i), -1, "string")
    nlines     = dimsizes(sdata)-5
    year       = new(nlines, integer, bv1)
    month      = new(nlines, integer, bv1)
    day        = new(nlines, integer, bv1)
    hour       = new(nlines, integer, bv1)
    aod_raw    = new((/nlines, nitem/), float, bv2)
    aod_hourly = new((/nhourly, nitem/), float, bv2)
    saod_daily       = new((/nday, nitem/), float, bv2)
    saod_dailym      = new((/nday, nitem/), float, bv2)
    smaod            = new((/nday, nitem/), float, bv2)
    saod_daily_std   = new((/nday, nitem/), float, bv2)
    saod_stdm        = new((/nday, nitem/), float, bv2)
    smaod_std        = new((/nday, nitem/), float, bv2)
    saod_monthly     = new(nitem, float, bv2)
    saod_monthlym    = new(nitem, float, bv2)
    smaod_monthly    = new(nitem, float, bv2)
    swpm25_daily     = new(nday, float, bv2)
    swpm25_daily_std = new(nday, float, bv2)
    swpm25_monthly   = new(1, float, bv2)

;  CALL SUBROUTINE read_aeronet_data TO READ OUT AERONET SITE INFO AND AOD
    read_aeronet_data \
   (dir, fname(i), year, month, day, hour, sitename, \
    longitude, latitude, elevation, header, aod_raw)

;  CALL SUBROUTINE calculate_aeronet_hourly_average TO COMPUTE THE HOURLY 
;  AVERAGE OF AERONET AOD DATASETS
    calculate_aeronet_hourly_average   \
   (nlines, year, month, day, hour,    \
    aod_raw, date, aod_hourly)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map \
   (wks, minlat, maxlat, minlon, maxlon, \
    longitude, latitude, mpplot)

;  CALL SUBROUTINE point_wrfchem_aeronet_daily TO SELECT WRFCHEM DATA 
;  DEPENDING ON AERONET SITE INFO
    point_wrfchem_aeronet_daily \
   (wdir, sfile, iselect, date, nhour,  \
    nitem, longitude, latitude, nhourly,\
    aod_hourly, nfiles,                 \
    saod_daily, swpm25_daily,           \
    saod_daily_std, swpm25_daily_std,   \
    saod_monthly, swpm25_monthly)

;  CALL SUBROUTINE point_modis_aeronet_daily.ncl TO SELECT MODIS 
;  DATA DEPENDING ON AERONET SITE INFO
    point_modis_aeronet_daily_hour \
   (bv2, nitem, sitem, start_year, end_year,\
    start_month, end_month, start_day,      \
    end_day, thre_lat, thre_lon, thre_dis,  \
    myear, mmonth, mday, mhour, mlat, mlon, \
    maod, maod_qf, date, latitude,          \
    longitude, aod_hourly, aod_hourly_std,  \
    syear, smonth, sday, smaod, smaod_std,  \
    smaod_monthly, saod_dailym, saod_stdm,  \
    saod_monthlym)

;  CALL SUBROUTINE plot_trend_daily3_wam TO PLOT THE TREND LINE
    plot_trend_daily3_wam \
   (wks, sitename, year, month, date, saod_daily,  \
    swpm25_daily, smaod, saod_daily_std,           \
    swpm25_daily_std, smaod_std,                   \
    saod_monthly, swpm25_monthly, smaod_monthly,   \
    nday, bv1, bv2, mpplot,                        \
    awplot)

    delete([/sdata, nlines, year, month, day, hour, aod_raw,        \
             aod_hourly, saod_daily, saod_daily_std, swpm25_daily,  \
             swpm25_daily_std, smaod, smaod_std/])
    system("date")
 end do ; END OF IS LOOP
end
