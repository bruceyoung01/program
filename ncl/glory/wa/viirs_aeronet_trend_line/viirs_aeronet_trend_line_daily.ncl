; $ID: viirs_aeronet_trend_line_daily.ncl V01 04/23/2012 10:06 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_aeronet_trend_line_daily
;  (1 ) READS NPP VIIRS VAOOO DATA AND INFO.
;  VAOOO_npp_d20120331_t2032472_e2034114_b02206_c20120401030451240471_noaa_ops.h5
;  (2 ) READS AEROENT SITES DATA
;  (3 ) CALCULATES AERONET DAILY AVERAGE
;  (4 ) SELECTS AEROENT DAILY AVERAGE DEPENDING ON NPP VIIRS DATA
;  (5 ) PLOTS MAP WITH AEROENT SITE ON IT
;  (6 ) PLOTS TREND LINE OF VIIRS AND AERONET AND CALCULATES CORRELATION FACTORS
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/23/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/filename_match_viirs.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/read_viirs_va_aeronet.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/read_aeronet_data.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/calculate_aeronet_hourly_average.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/point_viirs_aeronet_daily.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_trend_daily.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_viirs_aeronet_trend_line_daily_wa_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = -999.
   bv1        = -999
   bv2        = -999.3
   bv3        =  65529.
   bv4        =  65535.

;  SET UP NPP VIIRS DATA DIRECTORY AND FILE NAME LIST
   vdir       = "/home/bruce/sshfs/pfw/data/satellite/NPP/wa/"
   vflist     = "va_list"
   vfname     = asciiread(vdir + vflist, -1, "string")
   nvfname    = dimsizes(vfname)
;  SET UP NPP VIIRS GEOLOCATION INFO
   gflist     = "gaero_list"
   gfname     = asciiread(vdir + gflist, -1, "string")
   ngfname    = dimsizes(gfname)

;  SET UP AERONET DATA DIRECTORY AND FILENAME
   dir        = "/home/bruce/sshfs/pfw/data/aeronet/wa/"
   fnamelist  = "lev15_list"
   fname      = asciiread(dir + fnamelist, -1, "string")
   nsites     = dimsizes(fname)

;  DEFINE START AND END OF YEAR, MONTH, DAY, AND HOUR
   start_year = 2012
   end_year   = 2012
   start_month= 2
   end_month  = 2
   start_day  = 1
   end_day    = 29
;  DEFINE THRESHOLD LATITUDE AND LONGITUDE
   thre_lat   = 0.1
   thre_lon   = 0.1
;  DEFINE ARRAY FOR DIFFERENT SUBROUTINES
   n_new      = 2000
   new_vfname = new(n_new, string)
   new_gfname = new(n_new, string)
   nfiles     = new(1, integer, bv1)
   n_np       = 50000
   vyear      = new(n_np, integer, bv1)
   vmonth     = new(n_np, integer, bv1)
   vday       = new(n_np, integer, bv1)
   vhour      = new(n_np, integer, bv1)
   vlat       = new(n_np, float, bv2)
   vlon       = new(n_np, float, bv2)
   vaod       = new(n_np, float, bv3)
   vaod_qf    = new(n_np, float, bv3)

   nitem      = 60
   nhourly    = 999 ; # OF HOURS PER MONTH
   nday       = 29  ; # OF DAYS
   sitem      = 12
   sitename   = new(1, string)
   alongitude = new(1, float, bv2)
   alatitude  = new(1, float, bv2)
   elevation  = new(1, float, bv2)
   header     = new(nitem, string)
   aod_hourly = new((/nhourly, nitem/), float, bv2)
   date       = new((/nhourly, 4/), integer, bv1)
   saod_daily = new((/nday, nitem/), float, bv2)
   syear      = new(nday, integer, bv1)
   smonth     = new(nday, integer, bv1)
   sday       = new(nday, integer, bv1)
   shour      = new(nday, integer, bv1)
   svaod      = new(nday, float, bv2)
   saod_std   = new((/nday, nitem/), float, bv2)
   svaod_std  = new(nday, float, bv2)
   svaod_monthly = new(1, float, bv2)
   saod_monthly  = new(nitem, float, bv2)
   mpplot     = new(1, graphic)
   plot       = new(1, graphic)
   awplot     = new(1, graphic)

;  CALL SUBROUTINE filename_match_viirs.ncl TO MATCH
;  NPP VIIRS EDR AOD FILE NAME:
;  VAOOO_npp_d20120331_t2032472_e2034114_b02206_c20120401030451240471_noaa_ops.h5
;  NPP VIIRS EDR GEOLOCATION FILE NAME:
;  GAERO_npp_d20120201_t0909467_e0911109_b01362_c20120202145305252816_noaa_ops.h5
   filename_match_viirs(vdir, vfname, nvfname, gfname, ngfname, \
                        new_vfname, new_gfname, nfiles)

;============================AERONET SITES=====================================
;  DO LOOP # OF SITES
   do i = 0, nsites-1
   iselect = 0
   print("NOW WORKING ON : " + i + " OF " + nsites)
;  READ THE WHOLE FILE NAME LIST FOR AERONET AOD INFO
    sdata      = asciiread(dir + fname(i), -1, "string")
    nlines     = dimsizes(sdata)-5
    year       = new(nlines, integer, bv1)
    month      = new(nlines, integer, bv1)
    day        = new(nlines, integer, bv1)
    hour       = new(nlines, integer, bv1)
    aod_raw    = new((/nlines, nitem/), float, bv0)

;  CALL SUBROUTINE read_aeronet_data.ncl TO READ AERONET DATA
    read_aeronet_data(dir, fname(i), year, month, day, hour, sitename, \
                      alongitude, alatitude, elevation, header, aod_raw)

;  CALL SUBROUTINE read_viirs_va.ncl TO READ LATITUDE, LONGITUDE, AND
;  AOD DATA
    read_viirs_va_aeronet(vdir, new_vfname, new_gfname, nmfname,    \
                          bv3, bv4, alatitude, alongitude, thre_lat,\ 
                          thre_lon,                                 \
                          vyear, vmonth, vday, vhour,               \
                          vlat, vlon, vaod, vaod_qf)

;  CALL SUBROUTINE calculate_aeronet_hourly_average TO COMPUTE THE HOURLY 
;  AVERAGE OF AERONET AOD DATASETS
    calculate_aeronet_hourly_average(nlines, year, month, day, hour,   \
                                     aod_raw, date, aod_hourly)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, alongitude, alatitude, mpplot, plot)

;  CALL SUBROUTINE point_viirs_aeronet_daily.ncl TO SELECT NPP VIIRS 
;  DATA DEPENDING ON AERONET SITE INFO
    point_viirs_aeronet_daily(bv2, nitem, start_year, end_year,       \
                              start_month, end_month, start_day,      \
                              end_day, thre_lat, thre_lon,            \
                              vyear, vmonth, vday, vlat, vlon, vaod,  \
                              year, month, day,alatitude,alongitude,  \
                              aod_hourly,                             \
                              syear, smonth, sday, svaod, svaod_std,  \
                              svaod_monthly, saod_daily, saod_std,    \
                              saod_monthly)
;  CALL SUBROUTINE plot_trend_hourly.ncl TO PLOT TREND LINE BETWEEN NPP VIIRS
;  AND AERONET
    plot_trend_daily(wks, sitename, year, month, date, saod_daily,             \
                      svaod, saod_std, svaod_std, saod_monthly, svaod_monthly, \
                      sitem, nlines, nday, bv1, bv2, mpplot,                   \
                      awplot)
    delete([/sdata, nlines, year, month, \
             day, hour, aod_raw/])
    system("date")
   end do
end
