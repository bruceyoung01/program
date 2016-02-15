;  $ID: contour_grid_sum_regrid_method1.ncl V01 09/01/2015 15:49 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_sum_regrid_method1 READS GRIDDED GLOBAL ACA DATA 
;  GENERATED FROM DR. ZHIBO ZHANG, PLOTS CALIOP CLOUD FRACTION OR ACA FREQUENCY 
;  AS CONTOUR WITH RASTERFILL.
;  THREE METHODS ARE USED TO CALCULATE :
;  (1 ) COUNT/TOTAL_COUNT
;  (2 ) FREQUENCY/TOTAL_DAY
;  (3 ) FREQUENCY/TOTAL_AVAILABLE_POINT
;  HERE IS METHOD 1.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) SET UP BASIC INFO: 
;       OUTPUT FILES, DIRECTORY, MISSING VALUE, REGION LIMITS, TIME, SWITCH;
;  (2 ) DO YEAR, MONTH, AND DAY LOOPS;
;  (3 ) SELECT ACA DATA FILE BASED ON THE YEAR, MONTH, DAY, DAYTIME/NIGHTTIME,
;       ADJUST/NOADJUST;
;  (4 ) READ VARIABLES FROM ACA DATA FILE;
;  (5 ) GET THE INDICES FOR DIFFERENT CASES:
;       REGION, ACA, CLEAR, CLOUD, CLOUD_ONLY;
;  (6 ) SUM THE CALIOP TOTAL COUNT, CALIOP CLOUD COUNT, ACA COUNT FOR MONTH, 
;       SEASON, AND YEAR;
;  (7 ) CALCULATE CLOUD FRACTION AND ACA FREQUENCY FROM CALIOP TOTAL COUNT, 
;       CALIOP CLOUD COUNT, AND ACA COUNT;
;  (8 ) PLOT DAILY IMAGE;
;  (9 ) END OF DAY LOOP;
;  (10) CALCULATE CLOUD FRACTION AND ACA FREQUENCY FROM CALIOP TOTAL COUNT, 
;       CALIOP CLOUD COUNT, AND ACA COUNT;
;  (11) PLOT MONTHLY IMAGE;
;  (12) END OF MONTH LOOP;
;  (13) CALCULATE CLOUD FRACTION AND ACA FREQUENCY FROM CALIOP TOTAL COUNT, 
;       CALIOP CLOUD COUNT, AND ACA COUNT;
;  (14) PLOT SEASONAL IMAGE;
;  (15) END OF YEAR LOOP;
;  (16) CALCULATE CLOUD FRACTION AND ACA FREQUENCY FROM CALIOP TOTAL COUNT, 
;       CALIOP CLOUD COUNT, AND ACA COUNT;
;  (17) PLOT YEAR LOOP.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2015)
;  (2 ) MODIFIED FROM contour_grid_sum_method1.ncl BY ADDING THE RGRID FROM 1
;       DEGREE TO 2 DEGREE SPATIAL RESOLUTION USING ESMF REGRIDDING.
;       (BRUCE, 09/01/2015)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_aca_grid_file.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_region_aca_clear_cloud.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/sum_month_seasonal_year_method1.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/pixel_to_grid_ESMF.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/calculate_cf_aca_fre_method1.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
;  DEFINE A STRING FOR DIFFERENT CASES
;  THE CASES INCLUDING region, aca, clear, cloud, cloud_only
   scase      = "cloud"
;  RESTRICTION FOR FILE
;  FOR DAY TIME, don = "d"; FOR NIGHT TIME, don = "n"
   don        = "n"
;  FOR ADJUST just = "_adjust"; FOR NOADJUST just = "oadjust"
   just       = "_adjust"
;  FOR ACA FREQUENCY = "aca_fre"; FOR CLOUD FRACTION = "cf"
   para       = "cf"
   dir_plot   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_sum_regrid/"
   wks        = gsn_open_wks(type, dir_plot + "1plot_contour_grid_sum_regrid_method1_" + \
                             para + "_" + scase + "_" + don + "_v02")
   gsn_define_colormap(wks,"BlGrYeOrReVi200")

;  DATA DIRECTORY
   wdir       = "/home/vy57456/zzbatmos_common/Exchange/For_Zhifeng/ACA_Data/"
   filelist   = "Global_list_2007_2014"
   wname      = asciiread(wdir+filelist, -1, "string")
   nwname     = dimsizes(wname)

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)
;  GRID SIZE TO GRID PIXEL LEVEL DATA INTO GRIDDED LEVEL DATA
   lat_grid_size = 2.0
   lon_grid_size = 2.0

;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2007
   start_month= 7
   end_month  = 10
   start_day  = 1

;  SET UP SEASONAL STRING: -DJF, -MMA, JJA, SON
   sstring    = " Jul-Oct"
;  METHOD 1 FORMULA; n IS COUNT
   formula1   = "  [n/~F34~e~F21~(n)]"

;  SWITCH FOR SELECTED REGION
   switch_select_region = False
;  SWITHC FOR LAND AND SEA MASK
   switch_landsea_mask  = True

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = False
   logic_plot_monthly  = False
   logic_plot_seasonal = False
   logic_plot_yearly   = True

;  DEFINE THE GLOBAL GRID ARRAY TO HOLD ALL THE DAILY DATA
   nlat       = 180
   nlon       = 360

;  SET UP GLOBAL REGION
   gminlat    =-89.0
   gmaxlat    = 89.0
   gminlon    =-179.0
   gmaxlon    = 179.0

;  DEFINE ARRAY FOR GRIDDED LATITUDE AND LONGITUDE ARRAY
   nglat      = floattoint((gmaxlat-gminlat)/lat_grid_size) + 2
   nglon      = floattoint((gmaxlon-gminlon)/lon_grid_size) + 2
   lat_grid_1d= new((/nglat/), float, bv2)
   lon_grid_1d= new((/nglon/), float, bv2)
   lat_grid_2d= new((/nglat, nglon/), float, bv2)
   lon_grid_2d= new((/nglat, nglon/), float, bv2)

;  CALL SUBROUTINE grid_lat_lon.ncl TO GENERATE GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (gminlat, gmaxlat, gminlon, gmaxlon, lat_grid_size, lon_grid_size, \
   lat_grid_1d, lon_grid_1d, lat_grid_2d, lon_grid_2d)

;  PREDEFINE THE TOTAL SELECTED SAMPLES IN THE STUDY REGION
;  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;  CAUTION: VARIOUS VARIABLE DEPENDING ON THE STUDY REGION SIZE
;  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   ndim_index = 200
;  SELECTED FILE NAME
   sfilename  = new(1, string)

;  DO YEAR LOOP
   if (logic_plot_yearly) then
      CALIOP_total_count_yearly = new((/nlat, nlon/), integer, bv1)
      CALIOP_total_count_yearly = 0
      CALIOP_cloud_count_yearly = new((/nlat, nlon/), integer, bv1)
      CALIOP_cloud_count_yearly = 0
      CALIOP_ACA_count_yearly   = new((/nlat, nlon/), integer, bv1)
      CALIOP_ACA_count_yearly   = 0
      CALIOP_cf_yearly          = new((/nlat, nlon/),   float, bv2)
      CALIOP_cf_yearly          = 0
      CALIOP_ACA_fre_yearly     = new((/nlat, nlon/),   float, bv2)
      CALIOP_ACA_fre_yearly     = 0
      CALIOPg_cf_yearly         = new((/nglat, nglon/), float, bv2)
      CALIOPg_ACA_fre_yearly    = new((/nglat, nglon/), float, bv2)
   end if
   iyear_loop = 0
   do iyear = start_year, end_year
      if (logic_plot_seasonal) then
         CALIOP_total_count_seasonal = new((/nlat, nlon/), integer, bv1)
         CALIOP_total_count_seasonal = 0
         CALIOP_cloud_count_seasonal = new((/nlat, nlon/), integer, bv1)
         CALIOP_cloud_count_seasonal = 0
         CALIOP_ACA_count_seasonal   = new((/nlat, nlon/), integer, bv1)
         CALIOP_ACA_count_seasonal   = 0
         CALIOP_cf_seasonal          = new((/nlat, nlon/),   float, bv2)
         CALIOP_ACA_fre_seasonal     = new((/nlat, nlon/),   float, bv2)
         CALIOPg_cf_seasonal         = new((/nglat, nglon/), float, bv2)
         CALIOPg_ACA_fre_seasonal    = new((/nglat, nglon/), float, bv2)
      end if

;  DO MONTH LOOP
      imonth_loop = 0
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year = days_in_month(iyear, imonth)
         if (logic_plot_monthly) then
            CALIOP_total_count_monthly = new((/nlat, nlon/), integer, bv1)
            CALIOP_total_count_monthly = 0
            CALIOP_cloud_count_monthly = new((/nlat, nlon/), integer, bv1)
            CALIOP_cloud_count_monthly = 0
            CALIOP_ACA_count_monthly   = new((/nlat, nlon/), integer, bv1)
            CALIOP_ACA_count_monthly   = 0
            CALIOP_cf_monthly          = new((/nlat, nlon/),   float, bv2)
            CALIOP_ACA_fre_monthly     = new((/nlat, nlon/),   float, bv2)
            CALIOPg_cf_monthly         = new((/nglat, nglon/), float, bv2)
            CALIOPg_ACA_fre_monthly    = new((/nglat, nglon/), float, bv2)
         end if
;  DO DAY LOOP
         iday_loop = 0
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTES
            logic_filename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            sitime  = siyear + "-" + simonth + "-" + siday
            print("Now Processing : " + sitime)
            if (logic_plot_daily) then
               CALIOP_total_count_daily = new((/nlat, nlon/),   integer, bv1)
               CALIOP_total_count_daily = 0
               CALIOP_cloud_count_daily = new((/nlat, nlon/),   integer, bv1)
               CALIOP_cloud_count_daily = 0
               CALIOP_ACA_count_daily   = new((/nlat, nlon/),   integer, bv1)
               CALIOP_ACA_count_daily   = 0
               CALIOP_cf_daily          = new((/nlat, nlon/),   float,   bv2)
               CALIOP_ACA_fre_daily     = new((/nlat, nlon/),   float,   bv2)
               CALIOPg_cf_daily         = new((/nglat, nglon/), float,   bv2)
               CALIOPg_ACA_fre_daily    = new((/nglat, nglon/), float,   bv2)
            end if

;  READ THE FILE DEPENDING ON THE YEAR, MONTH, DAY, AND DAYTIME AND NIGHTTIME
;  CALL SUBROUTINE select_aca_grid_file.ncl TO GET FILE NAME
            select_aca_grid_file \
            (wname, iyear, imonth, iday, don, just, sfilename, logic_filename)

            if (.not.logic_filename) then
               continue
            end if
;  CLEAR ALL THE VARIABLES BEFORE USING THEM
            if (iday   .gt. 1           .or. \
                imonth .gt. start_month .or. \
                iyear  .gt. start_year) then
               delete([/lat, lon,                                         \
                        sampled_grids_lat_index, sampled_grids_lon_index, \
                        CALIOP_total_count, CALIOP_cloud_count,           \
                        CALIOP_ACA_count, CALIOP_ACA_count_sum/])
            end if

;  READ VARIABLES FROM GRID FILE
            a                       = addfile(wdir + sfilename + ".nc", "r")
            lat                     = a->lat_grids
            lon                     = a->lon_grids
            sampled_grids_lat_index = a->sampled_grids_lat_index
            sampled_grids_lon_index = a->sampled_grids_lon_index
            CALIOP_total_count      = a->CALIOP_total_count
            CALIOP_cloud_count      = a->CALIOP_cloud_count
            CALIOP_ACA_count        = a->CALIOP_ACA_count
            CALIOP_ACA_count_sum    = dim_sum_n(CALIOP_ACA_count, 1)

;  DEFINE OUTPUT ARRARY FOR SUBROUTINE region_aca_clear.ncl
            index               = new((/ndim_index/), integer, bv1)
            index_region        = new((/ndim_index/), integer, bv1)
            index_aca           = new((/ndim_index/), integer, bv1)
            index_clear         = new((/ndim_index/), integer, bv1)
            index_cloud         = new((/ndim_index/), integer, bv1)
            index_cloud_only    = new((/ndim_index/), integer, bv1)

;  CALL SUBROUTINE select_region_aca_clear_cloud.ncl TO SELECT DATA IN THE STUDY REGION 
;  AND JUDGE WHETHER THE GRID IS ACA, CLEAR, CLOUD, AND CLOUD ONLY
            select_region_aca_clear_cloud                      \
            (minlat, maxlat, minlon, maxlon, lat, lon,         \
             sampled_grids_lat_index, sampled_grids_lon_index, \
             CALIOP_cloud_count, CALIOP_ACA_count,             \
             index_region, index_aca, index_clear, index_cloud, index_cloud_only)

            index = index_cloud
;  DEFINE THE ACTUAL SIZE OF index_aca AND index_clear
            if (all(ismissing(index))) then
               continue
            else
               dim_index_real    = ind(.not.ismissing(index))
               if (all(ismissing(dim_index_real))) then
                  delete([/dim_index_real/])
                  continue
               end if
            end if
           if (logic_plot_daily) then
;  CALL SUBROUTINE sum_month_seasonal_year_method1.ncl TO SUM ALL THE DATA TOGETHER
           sum_month_seasonal_year_method1                                \
           (index, switch_select_region,                                  \
            sampled_grids_lat_index, sampled_grids_lon_index,             \
            CALIOP_total_count, CALIOP_cloud_count, CALIOP_ACA_count_sum, \
            CALIOP_total_count_daily, CALIOP_cloud_count_daily,           \
            CALIOP_ACA_count_daily)
;  CALL SUBROUTINE calculate_cf_aca_fre_method1.ncl TO CALCULATE CLOUD FRACTION AND ACA FREQUENCY
            calculate_cf_aca_fre_method1                                  \
            (bv2, CALIOP_total_count_daily, CALIOP_cloud_count_daily,     \
            CALIOP_ACA_count_daily, CALIOP_cf_daily, CALIOP_ACA_fre_daily)
           end if
           if (logic_plot_monthly) then
;  CALL SUBROUTINE sum_month_seasonal_year_method1.ncl TO SUM ALL THE DATA TOGETHER
           sum_month_seasonal_year_method1                                \
           (index, switch_select_region,                                  \
            sampled_grids_lat_index, sampled_grids_lon_index,             \
            CALIOP_total_count, CALIOP_cloud_count, CALIOP_ACA_count_sum, \
            CALIOP_total_count_monthly, CALIOP_cloud_count_monthly,       \
            CALIOP_ACA_count_monthly)
           end if
           if (logic_plot_seasonal) then
;  CALL SUBROUTINE sum_month_seasonal_year_method1.ncl TO SUM ALL THE DATA TOGETHER
           sum_month_seasonal_year_method1                                \
           (index, switch_select_region,                                  \
            sampled_grids_lat_index, sampled_grids_lon_index,             \
            CALIOP_total_count, CALIOP_cloud_count, CALIOP_ACA_count_sum, \
            CALIOP_total_count_seasonal, CALIOP_cloud_count_seasonal,     \
            CALIOP_ACA_count_seasonal)
           end if
           if (logic_plot_yearly) then
;  CALL SUBROUTINE sum_month_seasonal_year_method1.ncl TO SUM ALL THE DATA TOGETHER
           sum_month_seasonal_year_method1                                \
           (index, switch_select_region,                                  \
            sampled_grids_lat_index, sampled_grids_lon_index,             \
            CALIOP_total_count, CALIOP_cloud_count, CALIOP_ACA_count_sum, \
            CALIOP_total_count_yearly, CALIOP_cloud_count_yearly,         \
            CALIOP_ACA_count_yearly)
           end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_daily) then
               stime = sitime + " " + scase + " " + don + formula1
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE 1 DEGREE DATA INTO 2 DEGREE DATA
               pixel_to_grid_ESMF                                  \
               (bv2, lat, lon, gminlat, gmaxlat, gminlon, gmaxlon, \
               lat_grid_size, lon_grid_size, CALIOP_cf_daily, CALIOPg_cf_daily)

               CALIOP_cf_daily      = where(ismissing(CALIOP_cf_daily), 0.0, CALIOP_cf_daily)
               CALIOP_ACA_fre_daily = where(ismissing(CALIOP_ACA_fre_daily), 0.0, CALIOP_ACA_fre_daily)
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
               plot_contour_grid_landmask \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat_grid_1d, lon_grid_1d, CALIOPg_cf_daily, stime)
            if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_map \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat_pg, lon_pg)
            end if
            end if
            iday_loop   = iday_loop   + 1
            imonth_loop = imonth_loop + 1
            iyear_loop  = iyear_loop  + 1
            delete([/dim_index_real/])
         end do ; iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (logic_plot_monthly) then
            smonthly = siyear  + "-" + simonth + " " + scase + " " + don + formula1
;  CALL SUBROUTINE calculate_cf_aca_fre_method1.ncl TO CALCULATE CLOUD FRACTION AND ACA FREQUENCY
            calculate_cf_aca_fre_method1 \
            (bv2, CALIOP_total_count_monthly, CALIOP_cloud_count_monthly, \
            CALIOP_ACA_count_monthly, CALIOP_cf_monthly, CALIOP_ACA_fre_monthly)

            CALIOP_cf_monthly      = where(ismissing(CALIOP_cf_monthly), 0.0, CALIOP_cf_monthly)
            CALIOP_ACA_fre_monthly = where(ismissing(CALIOP_ACA_fre_monthly), 0.0, CALIOP_ACA_fre_monthly)
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE 1 DEGREE DATA INTO 2 DEGREE DATA
            pixel_to_grid_ESMF                                  \
            (bv2, lat, lon, gminlat, gmaxlat, gminlon, gmaxlon, \
            lat_grid_size, lon_grid_size, CALIOP_cf_monthly, CALIOPg_cf_monthly)
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
            plot_contour_grid_landmask \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_grid_1d, lon_grid_1d, CALIOPg_cf_monthly, smonthly)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
         end if
      end do ; imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT SEASONAL IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (logic_plot_seasonal) then
         sseasonal = siyear + sstring + " " + scase + " " + don + formula1
;  CALL SUBROUTINE calculate_cf_aca_fre_method1.ncl TO CALCULATE CLOUD FRACTION AND ACA FREQUENCY
         calculate_cf_aca_fre_method1                                    \
         (bv2, CALIOP_total_count_seasonal, CALIOP_cloud_count_seasonal, \
         CALIOP_ACA_count_seasonal, CALIOP_cf_seasonal, CALIOP_ACA_fre_seasonal)

         CALIOP_cf_seasonal      = where(ismissing(CALIOP_cf_seasonal), 0.0, CALIOP_cf_seasonal)
         CALIOP_ACA_fre_seasonal = where(ismissing(CALIOP_ACA_fre_seasonal), 0.0, CALIOP_ACA_fre_seasonal)
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE 1 DEGREE DATA INTO 2 DEGREE DATA
         pixel_to_grid_ESMF                                  \  
         (bv2, lat, lon, gminlat, gmaxlat, gminlon, gmaxlon, \
         lat_grid_size, lon_grid_size, CALIOP_cf_seasonal, CALIOPg_cf_seasonal)
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT SEASONAL IMAGE WITH BACKGROUND MAP ON IT
         plot_contour_grid_landmask            \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat_grid_1d, lon_grid_1d, CALIOPg_cf_seasonal, sseasonal)
      if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
         polygon_map                           \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat_pg, lon_pg)
      end if
      end if
   end do ; iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (logic_plot_yearly) then
      syearly = sprinti("%0.4i", start_year) + "-" + \
                sprinti("%0.4i", end_year)   + " " + \
                sstring + " " + scase + " " + don + formula1
;  CALL SUBROUTINE calculate_cf_aca_fre_method1.ncl TO CALCULATE CLOUD FRACTION AND ACA FREQUENCY
      calculate_cf_aca_fre_method1 \
      (bv2, CALIOP_total_count_yearly, CALIOP_cloud_count_yearly, \
      CALIOP_ACA_count_yearly, CALIOP_cf_yearly, CALIOP_ACA_fre_yearly)

      CALIOP_cf_yearly      = where(CALIOP_cf_yearly .eq. 0.0, bv2, CALIOP_cf_yearly)
      CALIOP_ACA_fre_yearly = where(CALIOP_ACA_fre_yearly .eq. 0.0, bv2, CALIOP_ACA_fre_yearly)
printMinMax(CALIOP_cf_yearly, 0)
printVarSummary(CALIOP_cf_yearly)
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE 1 DEGREE DATA INTO 2 DEGREE DATA
      pixel_to_grid_ESMF                                  \
      (bv2, lat, lon, gminlat, gmaxlat, gminlon, gmaxlon, \
      lat_grid_size, lon_grid_size, CALIOP_cf_yearly, CALIOPg_cf_yearly)
printMinMax(CALIOPg_cf_yearly, 0)
printVarSummary(CALIOPg_cf_yearly)

;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT YEARLY IMAGE WITH BACKGROUND MAP ON IT
      plot_contour_grid_landmask            \
      (wks, minlat, maxlat, minlon, maxlon, \
      lat_grid_1d, lon_grid_1d, CALIOPg_cf_yearly, syearly)
   if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
      polygon_map                           \
      (wks, minlat, maxlat, minlon, maxlon, \
      lat_pg, lon_pg)
   end if
   end if
end
