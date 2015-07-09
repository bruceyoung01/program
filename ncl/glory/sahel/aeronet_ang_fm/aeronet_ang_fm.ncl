; $ID: aeronet_ang_fm.ncl V01 05/11/2012 15:52 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM aeronet_ang_fm READS AND PLOTS ANGSTROM EXPONENT AND FINE MODE 
;  FRACTION FROM AERONET.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/11/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/add_markers.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_aeronet_data_allpoints.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/calculate_aeronet_daily_average_std.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_trend_daily2.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_aeronet_line_ang_fmf_v02")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET DIRECTORY AND FILE NAME LIST
   dir        = "/home/bruce/sshfs/shw/data/aeronet/sahel/2008/aeronet_sahel_200802_allpoints/"
   fnamelist  = "ONEILL_15_both"
   fname      = asciiread(dir + fnamelist, -1, "string")
   nsites     = dimsizes(fname)
   lfnamelist  = "lev20_both"
   lfname      = asciiread(dir + lfnamelist, -1, "string")

;  SET UP LIMITED REGION
   minlat     =-15.0
   maxlat     = 35.0
   minlon     =-25.0
   maxlon     = 45.0

;  DEFINE START AND END OF YEAR, MONTH, DAY, AND HOUR
   start_year = 2008
   end_year   = 2008
   start_month= 2
   end_month  = 2
   start_day  = 1
   end_day    = 29
   start_hour = 0
   end_hour   = 23

   nhour      = 24
   noitem     = 30
   nlitem     = 60
   nhourly    = 999 ; # OF HOURS PER MONTH
   nday       = 29  ; # OF DAYS
;  VARIABLES FROM LEVEL 20:
;  AERONET AOD(675nm)      lsitem = 3
;  440-870 ANGSTROM        lsitem = 34
;  VARIABLES FROM ONEILL 20:
;  TOTAL AOD (500nm)       ositem = 0
;  FIND MODE AOD (500nm)   ositem = 1
;  COARSE MODE AOD (500nm) ositem = 2
;  FINE MODE FRACTION      ositem = 3
   lsitem      = 34
   ositem      = 3

;  DEFINE MISSING VALUE
   bv1        = -999
   bv2        = -999.
   sitename   = new(1, string)
   longitude  = new(1, float, bv2)
   latitude   = new(1, float, bv2)
   elevation  = new(1, float, bv2)
   nfiles     = new(1, integer, bv1)
   header     = new(  noitem, string)
   lsitename  = new(1, string)
   llongitude = new(1, float, bv2)
   llatitude  = new(1, float, bv2)
   lelevation = new(1, float, bv2)
   lheader    = new(  nlitem, string)
   date       = new((/nhourly, 4/), integer, bv1)
   ldate      = new((/nhourly, 4/), integer, bv1)
   mpplot     = new(1, graphic)
   plot       = new(1, graphic)
   awplot     = new(1, graphic)

;============================AERONET SITES=====================================
;  DO LOOP # OF SITES
   do i = 0, nsites-1
    iselect = 0
    print("WORKING ON SITES : " + i + " OF " + nsites)
;  READ THE WHOLE FILE NAME LIST FOR AERONET AOD INFO
    sdata            = asciiread(dir + fname(i), -1, "string")
    nlines           = dimsizes(sdata)-5
    lsdata           = asciiread(dir + lfname(i), -1, "string")
    lnlines          = dimsizes(lsdata)-5
    year             = new(nlines, integer, bv1)
    month            = new(nlines, integer, bv1)
    day              = new(nlines, integer, bv1)
    hour             = new(nlines, integer, bv1)
    lyear            = new(lnlines, integer, bv1)
    lmonth           = new(lnlines, integer, bv1)
    lday             = new(lnlines, integer, bv1)
    lhour            = new(lnlines, integer, bv1)
    aod_raw          = new((/nlines, noitem/), float, bv2)
    aod_daily        = new((/nday, noitem/), float, bv2)
    aod_daily_std    = new((/nday, noitem/), float, bv2)
    aod_monthly      = new(noitem, float, bv2)
    laod_raw         = new((/lnlines, nlitem/), float, bv2)
    laod_daily       = new((/nday, nlitem/), float, bv2)
    laod_daily_std   = new((/nday, nlitem/), float, bv2)
    laod_monthly     = new(nlitem, float, bv2)

;  CALL SUBROUTINE read_aeronet_data TO READ OUT AERONET SITE INFO AND AOD
;  FROM ONEILL20 FILE NAME
    read_aeronet_data_allpoints \
   (dir, fname(i), year, month, day, hour, sitename, \
    longitude, latitude, elevation, header, aod_raw)

;  FROM LEV20 FILE NAME
    read_aeronet_data_allpoints \
   (dir, lfname(i), lyear, lmonth, lday, lhour, lsitename, \
    llongitude, llatitude, lelevation, lheader, laod_raw)

;  CALL SUBROUTINE calculate_aeronet_daily_average TO COMPUTE THE DAILY 
;  AVERAGE OF AERONET AOD DATASETS
    calculate_aeronet_daily_average_std           \
   (start_year, end_year, start_month, end_month, \
    start_day, end_day, nlines, year, month, day, \
    aod_raw, bv2, date, aod_daily, aod_daily_std)

    calculate_aeronet_daily_average_std \
   (start_year, end_year, start_month, end_month,     \
    start_day, end_day, lnlines, lyear, lmonth, lday, \
    laod_raw, bv2, ldate, laod_daily, laod_daily_std)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map \
   (wks, minlat, maxlat, minlon, maxlon, \
    longitude, latitude, mpplot)

;  CALL FUNCTION runave.ncl TO CALCULATE RUNNING AVERAGE
    aod_monthly       = dim_avg_n(aod_daily, 0)
    laod_monthly      = dim_avg_n(laod_daily, 0)

;  CALL SUBROUTINE plot_trend_daily TO PLOT THE TREND LINE
    plot_trend_daily2 \
   (wks, sitename, year, month, date, aod_daily(:, ositem),\
    laod_daily(:, lsitem), aod_daily_std(:, ositem),  \
    laod_daily_std(:, lsitem),                        \
    aod_monthly(ositem), laod_monthly(lsitem),        \
    nday, bv1, bv2, mpplot,                           \
    awplot)

    delete([/sdata, lsdata, nlines, lnlines, year, lyear, month, \
             lmonth, day, lday, hour, lhour, aod_raw, laod_raw,  \
             aod_daily, aod_daily_std, laod_daily, laod_daily_std/])
    system("date")
 end do ; END OF IS LOOP
end
