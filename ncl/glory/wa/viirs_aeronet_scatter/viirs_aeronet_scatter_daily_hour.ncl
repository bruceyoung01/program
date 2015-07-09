; $ID: viirs_aeronet_scatter_daily_hour.ncl V01 04/23/2012 10:06 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_aeronet_scatter_daily_hour
;  (1 ) READS NPP VIIRS VAOOO DATA AND INFO.
;  VAOOO_npp_d20120331_t2032472_e2034114_b02206_c20120401030451240471_noaa_ops.h5
;  (2 ) READS AEROENT SITES DATA
;  (3 ) CALCULATES AERONET HOURLY AVERAGE
;  (4 ) SELECTS AERONET HOURLY AVERAGE DEPENDING ON NPP VIIRS DATA
;  (5 ) PLOTS MAP WITH AEROENT SITE ON IT
;  (6 ) USING AERONET HOURLY AVERAGE AOD AS DAILY AVERAGE AND 
;       PLOTS SCATTER OF VIIRS AND AERONET AND CALCULATES CORRELATION FACTORS
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/23/2012)
;  (2 ) MODIFIED FROM viirs_aeronet_trend_line_daily.ncl. (05/02/2012)
;  (3 ) MODIFIED FROM viirs_aeronet_trend_line_daily_hour.ncl. (05/04/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/ndectobin.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/add_markers.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/filename_match_viirs.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/read_viirs_va_aeronet.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/read_aeronet_data.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/interpolate_aod.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/calculate_aeronet_hourly_average_std.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/point_viirs_aeronet_daily_hour.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/plot_scatter_viirs_aeronet.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_viirs_aeronet_scatter_daily_hour_wa_qf_v01")
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

;  SET UP STUDY REGION
;                        TEXAS    ; WA     ; SAHEL   GLOBAL
   maxlat     = 45.0     ;40.0    ; 45.0   ; 35.0     90.0
   minlat     = 30.0     ;25.0    ; 30.0   ;-10.0    -90.0
   maxlon     =-110.0    ;-90.0   ;-110.0  ; 45.0    180.0
   minlon     =-130.0    ;-110.0  ;-130.0  ;-25.0   -180.0 

;  SELECTED AERONET ITEM
   sitem1     = 12 ; 500nm
   lambda1    = 0.5
   sitem2     = 6  ; 675nm
   lambda2    = 0.675
   lambda     = 0.55
;  SPECIFY A VISUAL ITEM AS THE INTERPOLATED AOD ITEM
   sitem      = 0

;  DEFINE START AND END OF YEAR, MONTH, DAY, AND HOUR
   start_year = 2012
   end_year   = 2012
   start_month= 2
   end_month  = 2
   start_day  = 1
   end_day    = 29
   start_hour = 0
   end_hour   = 23
;  DEFINE THRESHOLD LATITUDE AND LONGITUDE AND DISTANCE
   thre_lat   = 0.5
   thre_lon   = 0.5
   thre_dis   = 25.0
;  DEFINE ARRAY FOR DIFFERENT SUBROUTINES
   n_new      = 2000
   new_vfname = new(n_new, string)
   new_gfname = new(n_new, string)
   nfiles     = new(1, integer, bv1)

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
;  THESE VARIABLES NEED TO REDEFINE WHILE DO LOOP
    nitem      = 60
    sdata      = asciiread(dir + fname(i), -1, "string")
    nlines     = dimsizes(sdata)-5
    year       = new(nlines, integer, bv1)
    month      = new(nlines, integer, bv1)
    day        = new(nlines, integer, bv1)
    hour       = new(nlines, integer, bv1)
    aod_raw    = new((/nlines, nitem/), float, bv0)
    aod_int    = new((/nlines, nitem/), float, bv0)

;  DEFINE VARIABLES FOR read_viirs_va_aeronet
    n_np       = 500000
    vyear      = new(n_np, integer, bv1)
    vmonth     = new(n_np, integer, bv1)
    vday       = new(n_np, integer, bv1)
    vhour      = new(n_np, integer, bv1)
    vlat       = new(n_np, float, bv2)
    vlon       = new(n_np, float, bv2)
    vaod       = new(n_np, float, bv3)
    vaod_qf    = new(n_np, integer, bv1)
;  DEFINE VARIABLES
    nday       = 29  ; # OF DAYS
    nhourly    = 999 ; # OF HOURS PER MONTH
    sitename   = new(1, string)
    alongitude = new(1, float, bv2)
    alatitude  = new(1, float, bv2)
    elevation  = new(1, float, bv2)
    header     = new(nitem, string)
    aod_hourly = new((/nhourly, nitem/), float, bv2)
    aod_hourly_std = new((/nhourly, nitem/), float, bv2)
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

;  CALL SUBROUTINE read_aeronet_data.ncl TO READ AERONET DATA
    read_aeronet_data(dir, fname(i), year, month, day, hour, sitename, \
                      alongitude, alatitude, elevation, header, aod_raw)

;  CALL SUBROUTINE read_viirs_va.ncl TO READ LATITUDE, LONGITUDE, AND
;  AOD DATA
    read_viirs_va_aeronet(vdir, new_vfname, new_gfname, nfiles, \
                          bv3, bv4, alatitude, alongitude,      \
                          thre_lat, thre_lon,                   \
                          vyear, vmonth, vday, vhour,           \
                          vlat, vlon, vaod, vaod_qf)

;  CALL SUBROUTINE interpolate_aod.ncl TO INTERPOLATE AERONET AOD
    interpolate_aod(lambda1, aod_raw(:, sitem1), lambda2, aod_raw(:, sitem2), \
                    lambda, aod_int(:, sitem))

;  CALL SUBROUTINE calculate_aeronet_hourly_average TO COMPUTE THE HOURLY 
;  AVERAGE OF AERONET AOD DATASETS
    calculate_aeronet_hourly_average_std \
                    (bv2, start_year, end_year, start_month, end_month,\
                     start_day, end_day, start_hour, end_hour, nitem,  \
                     year, month, day, hour, aod_int,                  \
                     date, aod_hourly, aod_hourly_std)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, minlat, maxlat, minlon, maxlon, \
               alongitude, alatitude, mpplot, plot)

;  CALL SUBROUTINE point_viirs_aeronet_daily.ncl TO SELECT NPP VIIRS 
;  DATA DEPENDING ON AERONET SITE INFO
    point_viirs_aeronet_daily_hour \
                             (bv2, nitem, sitem, start_year, end_year,\
                              start_month, end_month, start_day,      \
                              end_day, thre_lat, thre_lon, thre_dis,  \
                              vyear, vmonth, vday, vhour, vlat, vlon, \
                              vaod, vaod_qf, date, alatitude,         \
                              alongitude, aod_hourly, aod_hourly_std, \
                              syear, smonth, sday, svaod, svaod_std,  \
                              svaod_monthly, saod_daily, saod_std,    \
                              saod_monthly)
    if(num(.not.ismissing(svaod)) .ge. 3 .and. \
       num(.not.ismissing(saod_daily)) .ge. 3)then
;  CALL SUBROUTINE plot_scatter_viirs_aeronet.ncl TO PLOT SCATTER BETWEEN NPP VIIRS
;  AND AERONET
     plot_scatter_viirs_aeronet \
                 (wks, sitename, nday, sitem, saod_daily, svaod,          \
                  saod_std, svaod_std, saod_monthly, svaod_monthly,mpplot,\
                  awplot)
    end if
    delete([/sdata, year, month, \
             day, hour, aod_raw, aod_int/])
    system("date")
   end do
end
