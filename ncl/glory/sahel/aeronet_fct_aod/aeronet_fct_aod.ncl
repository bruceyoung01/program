; $ID: aeronet_fct_aod.ncl V01 05/12/2012 13:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM aeronet_fct_aod READS AND PLOTS FINE MODE AOD, COARSE MODE AOD, AND 
;  TOTAL AOD FROM AERONET.
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/read_aeronet_data.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/calculate_aeronet_daily_average_std.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/plot_trend_daily3.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_aeronet_line_fct_aod_2008_0201_0229_daily_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET DIRECTORY AND FILE NAME LIST
   dir        = "/home/bruce/sshfs/pfw/data/aeronet/sahel/2008/aeronet_sahel_200802/"
   fnamelist  = "ONEILL_20_select"
   fname      = asciiread(dir + fnamelist, -1, "string")
   nsites     = dimsizes(fname)

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
;  AERONET AOD(675nm)      lsitem = 6
;  440-870 ANGSTROM        lsitem = 37
;  VARIABLES FROM ONEILL 20:
;  TOTAL AOD (500nm)       ositem = 3
;  FIND MODE AOD (500nm)   ositem = 4
;  COARSE MODE AOD (500nm) ositem = 5
;  FINE MODE FRACTION      ositem = 6
   ositem1      = 4
   ositem2      = 5
   ositem3      = 3

;  DEFINE MISSING VALUE
   bv1        = -999
   bv2        = -999.
   sitename   = new(1, string)
   longitude  = new(1, float, bv2)
   latitude   = new(1, float, bv2)
   elevation  = new(1, float, bv2)
   nfiles     = new(1, integer, bv1)
   header     = new(  noitem, string)
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
    sdata            = asciiread(dir + fname(i), -1, "string")
    nlines           = dimsizes(sdata)-5
    year             = new(nlines, integer, bv1)
    month            = new(nlines, integer, bv1)
    day              = new(nlines, integer, bv1)
    hour             = new(nlines, integer, bv1)
    aod_raw          = new((/nlines, noitem/), float, bv2)
    aod_daily        = new((/nday, noitem/), float, bv2)
    aod_daily_std    = new((/nday, noitem/), float, bv2)
    aod_monthly      = new(noitem, float, bv2)

;  CALL SUBROUTINE read_aeronet_data TO READ OUT AERONET SITE INFO AND AOD
;  FROM ONEILL20 FILE NAME
    read_aeronet_data(dir, fname(i), year, month, day, hour, sitename, \
                      longitude, latitude, elevation, header, aod_raw)

;  CALL SUBROUTINE calculate_aeronet_daily_average TO COMPUTE THE DAILY 
;  AVERAGE OF AERONET AOD DATASETS
    calculate_aeronet_daily_average_std \
         (start_year, end_year, start_month, end_month, \
          start_day, end_day, nlines, year, month, day, \
          aod_raw, bv2, date, aod_daily, aod_daily_std)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, longitude, latitude, mpplot, plot)
;  CALL FUNCTION runave.ncl TO CALCULATE RUNNING AVERAGE
    aod_monthly       = dim_avg_n(aod_daily, 0)

;  CALL SUBROUTINE plot_trend_daily TO PLOT THE TREND LINE
    plot_trend_daily3 \
            (wks, sitename, year, month, date, aod_daily(:, ositem1),\
             aod_daily(:, ositem2), aod_daily(:, ositem3),           \
             aod_daily_std(:, ositem1), aod_daily_std(:, ositem2),   \
             aod_daily_std(:, ositem3), aod_monthly(ositem1),        \
             aod_monthly(ositem2), aod_monthly(ositem3),             \
             nday, bv1, bv2, mpplot, awplot)

    delete([/sdata, nlines, year, month, day, hour, aod_raw, aod_daily, aod_daily_std/])
    system("date")
 end do ; END OF IS LOOP
end
