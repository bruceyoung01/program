; $ID: aeronet_trend_line_daily.ncl V01 01/16/2012 14:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM aeronet_trend_line_daily IS USED TO PLOT THE TREND LINE
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/read_aeronet_data.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/calculate_aeronet_hourly_average.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/point_wrfchem_aeronet_daily.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_trend_daily.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_line_pm25_2008_0201_0229_daily_v02_fb_ndust_fm")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET DIRECTORY AND FILE NAME LIST
   dir        = "/media/disk/data/aeronet/sahel/2008/aeronet_sahel_200802/"
   fnamelist  = "ONEILL_20_select"
   fname      = asciiread(dir + fnamelist, -1, "string")
   nsites     = dimsizes(fname)

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/"
   sfile      = "wrfout_d01_2008-02*"
   nhour      = 24
   nitem      = 60
   nhourly    = 999 ; # OF HOURS PER MONTH
   nday       = 29  ; # OF DAYS
;  NOTE: AERONET AOD(675nm)   sitem=6
;        FIND MODE AOD (500nm)sitem=4
   sitem      = 4
;  FACTOR BETWEEN AERONET AND WRFCHEM
   factor     = 3.0

;  DEFINE MISSING VALUE
   bv1        = -999
   bv2        = -999.
   sitename   = new(1, string)
   longitude  = new(1, float, bv2)
   latitude   = new(1, float, bv2)
   elevation  = new(1, float, bv2)
   nfiles     = new(1, integer, bv1)
   header     = new(  nitem, string)
   date       = new((/nhourly, 4/), integer, bv1)
   mpplot     = new(1, graphic)
   plot       = new(1, graphic)
   awplot     = new(1, graphic)

;============================AERONET SITES=====================================
;  DO LOOP # OF SITES
   do i = 0, nsites-1
    iselect = 0
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
    saod_daily = new((/nday, nitem/), float, bv2)
    saod_daily_std = new((/nday, nitem/), float, bv2)
    saod_monthly   = new(nitem, float, bv2)
    swpm25_daily     = new(nday, float, bv2)
    swpm25_daily_std = new(nday, float, bv2)
    swpm25_monthly   = new(1, float, bv2)

;  CALL SUBROUTINE read_aeronet_data TO READ OUT AERONET SITE INFO AND AOD
    read_aeronet_data(dir, fname(i), year, month, day, hour, sitename, \
                      longitude, latitude, elevation, header, aod_raw)

;  CALL SUBROUTINE calculate_aeronet_hourly_average TO COMPUTE THE HOURLY 
;  AVERAGE OF AERONET AOD DATASETS
    calculate_aeronet_hourly_average(nlines, year, month, day, hour,    \
                                     aod_raw, date, aod_hourly)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, longitude, latitude, mpplot, plot)

;  CALL SUBROUTINE point_wrfchem_aeronet_daily TO SELECT WRFCHEM DATA 
;  DEPENDING ON AERONET SITE INFO
    point_wrfchem_aeronet_daily(wdir, sfile, iselect, date, nhour,  \
                                nitem, longitude, latitude, nhourly,\
                                aod_hourly, factor, nfiles,         \
                                saod_daily, swpm25_daily,           \
                                saod_daily_std, swpm25_daily_std,   \
                                saod_monthly, swpm25_monthly)

;  CALL SUBROUTINE plot_trend_daily TO PLOT THE TREND LINE
    plot_trend_daily(wks, sitename, year, month, date, saod_daily,  \
                     swpm25_daily, saod_daily_std, swpm25_daily_std,\
                     saod_monthly, swpm25_monthly, sitem, nlines,   \
                     nday, bv1, bv2, mpplot,                        \
                     awplot)

    delete([/sdata, nlines, year, month, day, hour, aod_raw,        \
             aod_hourly, saod_daily, saod_daily_std, swpm25_daily,  \
             swpm25_daily_std/])
    system("date")
 end do ; END OF IS LOOP
end
