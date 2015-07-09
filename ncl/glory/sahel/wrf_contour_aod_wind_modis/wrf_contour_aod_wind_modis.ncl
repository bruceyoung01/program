; $ID: wrf_contour_aod_wind_modis.ncl V01 08/12/2012 11:57 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_aod_wind_modis READS SELECTED WRFCHEM DATA DEPENDING 
;  ON MODIS OBSERVATION, AND PLOT AOD OVERLAID WITH WIND FOR DAILY AND MONTHLY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/12/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/int2string.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/interpolate_aod.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/ydn2md.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/process_day_wrf.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/process_day_mod04.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/select_wrf_modis.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_wrf_modis.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_variable_aod.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_aod_wind_modis_sahel_v01_dust")
   gsn_define_colormap(wks,"WhAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_800_fb_dust/"
   wfilelist  = "wrfout_d01_2008"
   wfilename  = asciiread(wdir + wfilelist, -1, "string")
   nwfilename = dimsizes(wfilename)

;  SET DIRECTORY ADN FILE NAME FOR MODIS AOD
   mdir       = "/home/bruce/sshfs/pfw/data/satellite/MODIS/sahel/mod04/"
   mflist     = "MOD04_200802"
   mfname     = asciiread(mdir + mflist, -1, "string")
   nmfname    = dimsizes(mfname)
;  loro IS A JUDGE USED TO JUDGE LAND_AOD, OCEAN_AOD, OR LAND_OCEAN_AOD
   loro       = "land_ocean"
   logic_leap = "leap"

;  SET UP LIMITED REGION
;                    SAHEL  LARGE-SAHEL
   minlat     =-15.0 ;-15.0 ;-45.0
   maxlat     = 35.0 ; 35.0 ; 65.0
   minlon     =-25.0 ;-25.0 ;-55.0
   maxlon     = 45.0 ; 45.0 ; 75.0

;  DEFINE WAVELENGTHES TO INTERPOLATE THE EXACT SAME WAVELENGTH 
;  BETWEEN WRFCHEM AND AERONET, UNIT IS MICROMETER
   lambda1    = 0.4
   lambda2    = 0.6
   lambda     = 0.5

;  DECLARE VARIABLES FOR SUBROUTINE process_day_wrf
   wtmpnday   = 40
   wnday      = new(1, integer, bv1)
   wstartinx  = new(wtmpnday, integer, bv1)
   wendinx    = new(wtmpnday, integer, bv1)
   wyear      = new(wtmpnday, integer, bv1)
   wmon       = new(wtmpnday, integer, bv1)
   wdate      = new(wtmpnday, integer, bv1)
   wtimes     = new(wtmpnday, string,  bv0)
   wtimee     = new(wtmpnday, string,  bv0)
   wdayname   = new(wtmpnday, string,  bv0)
   wdaynum    = new(wtmpnday, integer, bv1)

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   mtmpnday   = 40
   mnday      = new(1, integer, bv1)
   mstartinx  = new(mtmpnday, integer, bv1)
   mendinx    = new(mtmpnday, integer, bv1)
   myear      = new(mtmpnday, integer, bv1)
   mmon       = new(mtmpnday, integer, bv1)
   mdate      = new(mtmpnday, integer, bv1)
   mtimes     = new(mtmpnday, string,  bv0)
   mtimee     = new(mtmpnday, string,  bv0)
   mdayname   = new(mtmpnday, string,  bv0)
   mdaynum    = new(mtmpnday, integer, bv1)

;  CALL SUBROUTINE process_day_wrf.ncl TO READ OUT INFO FROM WRF OUTPUT FILE NAME
   process_day_wrf(wdir, wfilelist, logic_leap,             \
                     wnday, wstartinx, wendinx, wyear, wmon,\
                     wdate, wtimes, wtimee, wdayname, wdaynum)

;  CALL SUBROUTINE process_day_mod04.ncl TO READ OUT INFO FROM MODIS FILE NAME
   process_day_mod04(mdir, mflist, logic_leap,              \
                     mnday, mstartinx, mendinx, myear, mmon,\
                     mdate, mtimes, mtimee, mdayname, mdaynum)

;  DECLARE VARIABLES FOR SUBROUTINE select_wrf_modis
   swstartinx = new(1, integer, bv1)
   swendinx   = new(1, integer, bv1)

;  DECLARE VARIABLES FOR SUBROUTINE read_wrf_modis
   nwlat      = 73
   nwlat_stag = 74
   nwlon      = 99
   nwlon_stag = 100
   nwlev      = 27
   ntime      = 19
   wlat       = new((/nwlat, nwlon/), float, bv2)
   wlon       = new((/nwlat, nwlon/), float, bv2)
   avg_aod1   = new((/mnday, nwlat, nwlon/), float, bv2)
   avg_aod2   = new((/mnday, nwlat, nwlon/), float, bv2)
   avg_aod    = new((/mnday, nwlat, nwlon/), float, bv2)

;  DO MODIS nday LOOP TO SELECT THE SAME TIME STEP OF WRF-CHEM WITH MODIS
   do iday = 0, mnday-1

    system("date")
    date_display = stringtocharacter(myear(iday) + "-" + mmon(iday) + "-" + mdate(iday))
    print("DATE : " + date_display)

;  CALL SUBROUTINE select_wrf_modis.ncl TO GET SELECTED WRF-CHEM DATA INDEX
    select_wrf_modis(iday, myear, mmon, mdate, mtimes, mtimee, wfilename, \
                     swstartinx, swendinx)

;  CALL SUBROUTINE read_wrf_modis.ncl TO READ SELECTED WRF-CHEM DATA 
;  BASED ON MODIS
    read_wrf_modis(wdir, wfilename, swstartinx, swendinx, \
                   wlat, wlon,                            \
                   avg_aod1(iday, :, :), avg_aod2(iday, :, :))

;  CALL SUBROUTINE interpolate_aod.ncl TO INTERPOLATE 
;  400nm AND 600nm TO 550nm
    interpolate_aod \
     (lambda1, avg_aod1(iday, :, :), lambda2, avg_aod2(iday, :, :), lambda, \
      avg_aod(iday, :, :))
    avg_aod@lat2d = wlat
    avg_aod@lon2d = wlon

;  CALL SUBROUTINE plot_wrf_contour_variable_aod.ncl TO PLOT AOD
    plot_wrf_contour_variable_aod \
     (wks, minlat, maxlat, minlon, maxlon, avg_aod(iday, :, :), date_display)

    delete(date_display)

   end do

   print("=========================================================")
   print("              START TO PROCESS MONTHLY DATA")
;  START TO PLOT MONTHLY AVERAGE AOD AND WIND
   avg_aod_monthly = dim_avg_n_Wrap(avg_aod, 0)
   month_display   = stringtocharacter(myear(0) + "-" + mmon(0))
;  CALL SUBROUTINE plot_wrf_contour_variable_aod.ncl TO PLOT AOD
    plot_wrf_contour_variable_aod \
     (wks, minlat, maxlat, minlon, maxlon, avg_aod_monthly, month_display)


end
