; $ID: aeronet_modis_trend_line_daily_interpolate.ncl V01 05/21/2012 09:24 
;      BRUCE EXP$
;
;******************************************************************************
;  PROGRAM aeronet_modis_trend_line_daily_interpolate IS USED TO PLOT THE 
;  TREND LINE AMONG AERONET AOD, WRFCHEM AOD, AND MODIS AOD WITH THE SAME 
;  WAVELENGTH(AERONET AND WRFCHEM, BUT MODIS), AND PLOT IT OUT AS LINE PLOT.
;  (BRUCE 05/21/2012)
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/21/2012)
;  (2 ) ADD CORRELATION INFO BY BRUCE. (02/19/2012)
;  (3 ) ADD TO CALCULATE WRFCHEM WAVELENGTH AOD 
;       THE SAME AS AERONET AOD WAVELENGTH BY BRUCE. (04/20/2012)
;  (4 ) MODIFIED FROM aeronet_trend_line_daily_interpolate.ncl. (05/21/2012)
;******************************************************************************
;

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/add_markers.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/ndectobin.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/ydn2md.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_aeronet_data_allpoints.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_modis_aod_aeronet.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/calculate_aeronet_hourly_average.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/point_modis_aeronet_daily_hour.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/point_wrfchem_aeronet_daily_interpolate.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_trend_daily3_wam.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_aeronet_modis_trend_line_sahel_dust_smoke_v03")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET DIRECTORY AND FILE NAME LIST FOR AERONET
   dir        = "/home/bruce/sshfs/shw/data/aeronet/sahel/2008/aeronet_sahel_200802_allpoints/"
   fnamelist  = "lev20"
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

;  SET UP LIMITED REGION
   minlat     =-15.0
   maxlat     = 35.0
   minlon     =-25.0
   maxlon     = 45.0

   nhour      = 24
   nitem      = 60
   nhourly    = 744 ; # OF HOURS PER MONTH
   nday       = 29 ; # OF DAYS
;  NOTE: AERONET AOD(675nm)   sitem=6
;        AERONET AOD(500nm)   sitem=3
;        FIND MODE AOD (500nm)sitem=4
   sitem      = 3
;  DEFINE WAVELENGTHES TO INTERPOLATE THE EXACT SAME WAVELENGTH 
;  BETWEEN WRFCHEM AND AERONET, UNIT IS MICROMETER
   lambda1    = 0.4
   lambda2    = 0.6
   lambda     = 0.5
;  FACTOR BETWEEN AERONET AND WRFCHEM
   factor     = 1.0
;  DEFINE START AND END OF YEAR, MONTH, DAY, AND HOUR
   start_year = 2008
   end_year   = 2008
   start_month= 2
   end_month  = 2
   start_day  = 1
   end_day    = 29
   start_hour = 0
   end_hour   = 23
;  DEFINE THRESHOLD LATITUDE AND LONGITUDE AND DISTANCE
   thre_lat   = 1.
   thre_lon   = 1.
   thre_dis   = 25.


;  DEFINE MISSING VALUE
   bv1        = -999
   bv2        = -999.
   sitename   = new(1, string)
   longitude  = new(1, float, bv2)
   latitude   = new(1, float, bv2)
   elevation  = new(1, float, bv2)
   nfiles     = new(1, integer, bv1)
   header     = new((/nitem/), string)
   date       = new((/nhourly, 4/), integer, bv1)
   mpplot     = new(1, graphic)
   awplot     = new(1, graphic)

;============================AERONET SITES=====================================
;  DO LOOP # OF SITES
   do i = 0, 0;nsites-1
    system("date")
    iselect = 0
    print("WORKING ON SITES : " + i + " OF " + nsites)
;  READ THE WHOLE FILE NAME LIST FOR AERONET AOD INFO
    sdata            = asciiread(dir + fname(i), -1, "string")
    nlines           = dimsizes(sdata)-5
    year             = new((/nlines/), integer, bv1)
    month            = new((/nlines/), integer, bv1)
    day              = new((/nlines/), integer, bv1)
    hour             = new((/nlines/), integer, bv1)
    aod_raw          = new((/nlines, nitem/), float, bv2)
    aod_hourly       = new((/nhourly, nitem/), float, bv2)
    saod_daily       = new((/nday, nitem/), float, bv2)
    saod_daily_std   = new((/nday, nitem/), float, bv2)
    isaod_daily      = new((/nday, nitem/), float, bv2)
    isaod_daily_std  = new((/nday, nitem/), float, bv2)
    saod_monthly     = new((/nitem/), float, bv2)
    swpm25_daily     = new((/nday/), float, bv2)
    swpm25_daily_std = new((/nday/), float, bv2)
    iswpm25_daily    = new((/nday/), float, bv2)
    iswpm25_daily_std= new((/nday/), float, bv2)
    swpm25_monthly   = new(1, float, bv2)
    swpm25_daily1    = new((/nday/), float, bv2)
    swpm25_daily_std1= new((/nday/), float, bv2)
    swpm25_monthly1  = new(1, float, bv2)
    swpm25_daily2    = new((/nday/), float, bv2)
    swpm25_daily_std2= new((/nday/), float, bv2)
    swpm25_monthly2  = new(1, float, bv2)

;  DEFINE VARIABLES FOR read_modis_aod_aeronet
    n_np       = 50000
    myear      = new((/n_np/), integer, bv1)
    mmonth     = new((/n_np/), integer, bv1)
    mday       = new((/n_np/), integer, bv1)
    mhour      = new((/n_np/), integer, bv1)
    mlat       = new((/n_np/), float, bv2)
    mlon       = new((/n_np/), float, bv2)
    maod       = new((/n_np/), float, bv2)
    maod_qf    = new((/n_np/), integer, bv1)

    syear      = new((/nday/), integer, bv1)
    smonth     = new((/nday/), integer, bv1)
    sday       = new((/nday/), integer, bv1)
    shour      = new((/nday/), integer, bv1)
    smaod      = new((/nday/), float, bv2)
    aod_hourly_std = new((/nhourly, nitem/), float, bv2)
    saod_dailym= new((/nday, nitem/), float, bv2)
    saod_stdm  = new((/nday, nitem/), float, bv2)
    smaod_std  = new((/nday/), float, bv2)
    smaod_monthly = new(1, float, bv2)
    saod_monthlym = new((/nitem/), float, bv2)

;  CALL SUBROUTINE read_aeronet_data_allpoints TO READ OUT AERONET SITE INFO AND AOD
    read_aeronet_data_allpoints \
    (dir, fname(i), year, month, day, hour, sitename, \
     longitude, latitude, elevation, header, aod_raw)

;  CALL SUBROUTINE read_modis_aod_aeronet.ncl TO READ LATITUDE, LONGITUDE, AND
;  AOD DATA
    read_modis_aod_aeronet \
    (mdir, mfname, nmfname, bv1, bv2,        \
     latitude, longitude, thre_lat, thre_lon,\
     myear, mmonth, mday, mhour,             \
     mlat, mlon, maod, maod_qf)

;  CALL SUBROUTINE calculate_aeronet_hourly_average TO COMPUTE THE HOURLY 
;  AVERAGE OF AERONET AOD DATASETS
    calculate_aeronet_hourly_average \
    (nlines, year, month, day, hour, \
     aod_raw, date, aod_hourly)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, minlat, maxlat, minlon, maxlon, \
               longitude, latitude, mpplot)

;  CALL SUBROUTINE point_wrfchem_aeronet_daily TO SELECT WRFCHEM DATA 
;  DEPENDING ON AERONET SITE INFO
    point_wrfchem_aeronet_daily_interpolate \
    (wdir, sfile, iselect, date, nhour,  \
     nitem, longitude, latitude, nhourly,\
     aod_hourly, lambda1,                \
     lambda2, lambda, nfiles,            \
     saod_daily, swpm25_daily1,          \
     swpm25_daily2, swpm25_daily,        \
     saod_daily_std, swpm25_daily_std1,  \
     swpm25_daily_std2, swpm25_daily_std,\
     saod_monthly, swpm25_monthly1,      \
     swpm25_monthly2, swpm25_monthly)

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

;  CALL FUNCTION runave.ncl TO CALCULATE RUNNING AVERAGE
;   factor            = saod_monthly(sitem)/swpm25_monthly
    print("FACTOR  = " + factor)
    swpm25_daily      = swpm25_daily*factor
    swpm25_daily_std  = swpm25_daily_std*factor
    swpm25_monthly    = swpm25_monthly*factor
    nave              = 1
    opt               = 1
    dim               = 0
    isaod_daily       = runave_n(saod_daily, nave, opt, dim)
    isaod_daily_std   = runave_n(saod_daily_std, nave, opt, dim)
    iswpm25_daily     = runave_n(swpm25_daily, nave, opt, dim)
    iswpm25_daily_std = runave_n(swpm25_daily_std, nave, opt, dim)
    isaod_monthly     = dim_avg_n(isaod_daily, 0)
    iswpm25_monthly   = avg(iswpm25_daily)
    ismaod_monthly    = avg(smaod)

;  CALL SUBROUTINE plot_trend_daily3_wam TO PLOT THE TREND LINE
    plot_trend_daily3_wam \
    (wks, sitename, year, month, date, isaod_daily(:, sitem),      \
     iswpm25_daily, smaod, isaod_daily_std(:, sitem), iswpm25_daily_std,\
     smaod_std, isaod_monthly(sitem), iswpm25_monthly, ismaod_monthly,  \
     nday, bv1, bv2, mpplot, awplot)

    delete([/sdata, nlines, year, month, day, hour, aod_raw,     \
             aod_hourly, saod_daily, saod_dailym, saod_daily_std,\
             saod_stdm, swpm25_daily1,                           \
             swpm25_daily_std1, swpm25_daily2, swpm25_daily_std2,\
             swpm25_daily, swpm25_daily_std/])
    system("date")
 end do ; END OF IS LOOP
end
