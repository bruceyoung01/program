; $ID: modis_wrf_aod_scatter.ncl V01 06/17/2012 15:21 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM modis_wrf_aod_scatter READS MODIS AOD AND WRFCHEM AOD, AND PLOTS 
;  SCATTER PLOT AND CORRELATION BETWEEN THEM.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/17/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/ydn2md.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_wrfchem_data.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/interpolate_aod.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_modis_aod_day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/pixel_to_grid_distance.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_scatter_modis_wrf.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_modis_wrf_aod_scatter_sahel_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv1        = -999
   bv2        = -999.

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/"
   sfile      = "wrfout_d01_2008-02*_10*"

;  SET DIRECTORY ADN FILE NAME FOR MODIS AOD
   mdir       = "/home/bruce/sshfs/pfw/data/satellite/MODIS/sahel/mod04/"
   mflist     = "MOD04_200802" 
;  loro IS A JUDGE USED TO JUDGE LAND_AOD, OCEAN_AOD, OR LAND_OCEAN_AOD
   loro       = "land_ocean"
   mfname     = asciiread(mdir + mflist, -1, "string")
   nmfname    = dimsizes(mfname)

;  SET UP LIMITED REGION
;                    OMALINK  NE_NEST2     NE_NEST1    NE      WA       CA     SAHEL  LARGE-SAHEL
   minlat     =-15.0 ;40.5    ;39.5       ; 30.0    ; 25.0   ; 30.0    ; 10    ;-15.0 ;-45.0
   maxlat     = 35.0 ;41.5    ;42.0       ; 43.0    ; 45.0   ; 45.0    ; 45    ; 35.0 ; 65.0
   minlon     =-25.0 ;-97.0   ;-99.0      ;-115.0   ;-115.0  ;-130.0   ;-115   ;-25.0 ;-55.0
   maxlon     = 45.0 ;-95.5   ;-94.5      ;-93.0    ;-90.0   ;-110.0   ;-65    ; 45.0 ; 75.0

;  DEFINE WAVELENGTHES TO INTERPOLATE THE EXACT SAME WAVELENGTH 
;  BETWEEN WRFCHEM AND AERONET, UNIT IS MICROMETER
   lambda1    = 0.4
   lambda2    = 0.6
   lambda     = 0.5
;  FACTOR BETWEEN AERONET AND WRFCHEM
   factor     = 1.8
;  DEFINE START AND END OF YEAR, MONTH, DAY, AND HOUR
   start_year = 2008
   end_year   = 2008
   start_month= 2
   end_month  = 2
   start_day  = 1
   end_day    = 29
   start_hour = 0
   end_hour   = 23
   start_jd   = cd_inv_calendar(start_year, start_month, start_day, start_hour, 0, 0, "days", 0)
   end_jd     = cd_inv_calendar(end_year, end_month, end_day, end_hour, 0, 0, "days", 0)
   nday       = tointeger(end_jd-start_jd) + 1

;  DECLARE WRFCHEM DOMAIN DIMENSION
   nwlat      = 73
   nwlon      = 99
   nwlev      = 27
   ntime      = 19
   ndim       = nwlat*nwlon

;  DECLARE VARIABLE FOR SUBROUTINE read_wrfchem_data.ncl
   wtime      = new((/nday, ntime/), character)
   wlat       = new((/nwlat, nwlon/), float, bv2)
   wlon       = new((/nwlat, nwlon/), float, bv2)
   aod1       = new((/nday, nwlev, nwlat, nwlon/), float, bv2)
   aod2       = new((/nday, nwlev, nwlat, nwlon/), float, bv2)
   aod        = new((/nday, nwlev, nwlat, nwlon/), float, bv2)
   waodstd    = new((/nday, nwlat, nwlon/), float, bv2)
   waodstd_mon= new((/nwlat, nwlon/), float, bv2)
   waod_monthly = new(1, float, bv2)

;  DEFINE MODIS VARIABLES FOR SUBROUTINE read_modis_aod_day.ncl
   minpixel   = 0
   mnp        = 203
   mnl        = 135
   mfactor    = 100
   tmnp       = mnp*mfactor
   myear      = new((/tmnp, mnl, nday/), integer, bv1)
   mmonth     = new((/tmnp, mnl, nday/), integer, bv1)
   mday       = new((/tmnp, mnl, nday/), integer, bv1)
   mhour      = new((/tmnp, mnl, nday/), integer, bv1)
   mlat       = new((/tmnp, mnl, nday/), float, bv2)
   mlon       = new((/tmnp, mnl, nday/), float, bv2)
   maod       = new((/tmnp, mnl, nday/), float, bv2)
   maod_qf    = new((/tmnp, mnl, nday/), integer, bv1)

;  DEFINE 3-DIMENSIONAL ARRAY FOR LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
   gmaod      = new((/nwlat, nwlon, nday/), float, bv2)
   gmcon      = new((/nwlat, nwlon, nday/), integer, bv1)
   gmstd      = new((/nwlat, nwlon, nday/), float, bv2)
   gmstd_mon  = new((/nwlat, nwlon/), float, bv2)
   maod_monthly = new(1, float, bv2)
   plot       = new(1, graphic)

   system("date")

;  CALL SUBROUTINE read_wrfchem_data.ncl TO READ WRFCHEM TIME
;  LATITUDE, LONGITUDE, AOD(400nm, 600nm)
   read_wrfchem_data \
     (wdir, sfile, wtime, wlat, wlon, aod1, aod2)

;  CALL SUBROUTINE interpolate_aod.ncl TO INTERPOLATE 
;  400nm AND 600nm TO 550nm
   interpolate_aod \
     (lambda1, aod1, lambda2, aod2, lambda, \
      aod)

   aod = aod*factor
;  CALL SUBROUTINE read_modis_aod_day.ncl TO READ MODIS AOD DATA
   read_modis_aod_day \
     (mdir, mfname, nmfname, bv1, bv2, loro, \
      myear, mmonth, mday, mhour,      \
      mlat, mlon, maod, maod_qf)

;  CALL SUBROUTINE pixel_to_grid_distance.ncl TO GRID MODIS DATA
   pixel_to_grid_distance \
     (bv1, bv2, wlat, wlon, \
      nwlat, nwlon, mlat, mlon, minpixel, maod,   \
      gmaod, gmcon, gmstd)

;  ASSIGN 0.0 VALUE WITH MISSING VALUE
   aod   = where(aod   .eq. 0.0, bv2, aod  )
   gmaod = where(gmaod .eq. 0.0, bv2, gmaod)

;  PLOT WRF-CHEM VS MODIS SCATTER PLOTS FOR EACH DAY
   do i = 0, nday-1
    taod       = dim_sum_n(aod(i, :, :, :), 0)
    oned_taod  = ndtooned(taod)
    oned_gmaod = ndtooned(gmaod(:, :, i))
    wday       = charactertostring(wtime(i, 0:9))

;  CALL plot_scatter_modis_wrf.ncl TO PLOT SCATTER PLOT 
;  BETWEEN MODIS AND WRF-CHEM
    plot_scatter_modis_wrf\
      (wks, ndim, wday, oned_taod, oned_gmaod, \
       waodstd, gmstd, waod_monthly, maod_monthly, plot)
   end do

;==============================================================================
;  PLOT WRF-CHEM VS MODIS SCATTER PLOTS FOR MONTHLY
   taod_mon        = dim_avg_n(aod, 0)
   ttaod_mon       = dim_sum_n(taod_mon, 0)
   gmaod_mon       = dim_sum_n(gmaod, 2)
   oned_ttaod_mon  = ndtooned(ttaod_mon)
   oned_waodstd_mon= ndtooned(waodstd_mon)
   oned_gmaod_mon  = ndtooned(gmaod_mon)
   oned_gmstd_mon  = ndtooned(gmstd_mon)
   wmonth          = charactertostring(wtime(0, 0:6))

;  CALL plot_scatter_modis_wrf.ncl TO PLOT SCATTER PLOT 
;  BETWEEN MODIS AND WRF-CHEM
    plot_scatter_modis_wrf\
      (wks, ndim, wmonth, oned_ttaod_mon, oned_gmaod_mon, \
       oned_waodstd_mon, oned_gmstd_mon, waod_monthly, maod_monthly, plot)
system("date")
print("WELL DONE BRUCE !!!")

end
