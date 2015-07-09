;  $ID: contour_grid_sum_modis_method3.ncl V01 06/01/2015 15:01 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_sum_modis_method3 READS GRIDDED GLOBAL ACA DATA GENERATED 
;  FROM DR. ZHIBO ZHANG, PLOTS MODIS CLOUD FRACTION OR ACA FREQUENCY AS 
;  CONTOUR WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2015)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_aca_grid_file.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_region_aca_clear_cloud.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_contour_grid_sum_modis_method3_cf_cloud_terra_v05")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

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
;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2007
   start_month= 6
   end_month  = 6
   start_day  = 1

;  SET UP SEASONAL STRING: -DJF, -MMA, JJA, SON
   sstring    = "JJA"
;  RESTRICTION FOR FILE
;  FOR DAY TIME, don = "d"; FOR NIGHT TIME, don = "n"
   don        = "d"
;  FOR ADJUST just = "_adjust"; FOR NOADJUST just = "oadjust"
   just       = "_adjust"

;  SWITCH FOR SELECTED REGION
   switch_select_region = True
;  SWITHC FOR LAND AND SEA MASK
   switch_landsea_mask  = True
;  SINCE TERRA HAS MISSING VALUE ALONG S15DEG~S20DEG, 
;  THIS IS A SWITCH TO MATCH AQUA WITH TERRA
;  SWITCH FOR TERRA AND AQUA MATCH
   switch_atmatch       = True

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = True
   logic_plot_monthly  = True
   logic_plot_seasonal = True
   logic_plot_yearly   = True

;  DEFINE THE GLOBAL GRID ARRAY TO HOLD ALL THE DAILY DATA
   nlat       = 180
   nlon       = 360

;  PREDEFINE THE TOTAL SELECTED SAMPLES IN THE STUDY REGION
;  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;  CAUTION: VARIOUS VARIABLE DEPENDING ON THE STUDY REGION SIZE
;  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   ndim_index = 200
;  SELECTED FILE NAME
   sfilename  = new(1, string)

;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA:
;  READ THE FILE DEPENDING ON THE YEAR, MONTH, DAY, AND DAYTIME AND NIGHTTIME
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  CALCULATE TOTAL YEARS
   ntyear     = end_year - start_year + 1
;  CALCULATE TOTAL DAYS FOR ALL THE YEARS DEPENDING ON
;  start_year AND end_year
;  start_month AND end_month
   tnday_year = 0
   do iiyear = start_year, end_year
      do iimonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year   = days_in_month(iiyear, iimonth)
         tnday_year = tnday_year + lon_year
      end do
   end do

   MODIS_cf_year = new((/tnday_year, nlat, nlon/),   float, bv2)
;  DO YEAR LOOP
   iyear_loop   = 0
   tnday_season = 0
   do iyear = start_year, end_year
;  CALCULATE TOTAL DAYS FOR EACH YEAR DEPENDING ON
;  THE YEAR IS LEAP YEAR OR NON-LEAP YEAR
;  start_month AND end_month
      do iiimonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year     = days_in_month(iiiyear, iiimonth)
         tnday_season = tnday_season + lon_year
      end do
      MODIS_cf_season = new((/tnday_season, nlat, nlon/),   float, bv2)

;  DO MONTH LOOP
      imonth_loop = 0
      do imonth = start_month, end_month
;  TOTAL DAY IN imonth
         tnday_month     = lon_year
         MODIS_cf_month  = new((/tnday_month, nlat, nlon/),   float, bv2)

;  DO DAY LOOP
         iday_loop = 0
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTES
            logic_filename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
            print("Now Processing : " + stime)
            MODIS_cf_day      = new((/1, nlat, nlon/),   float, bv2)

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
                        CALIOP_cloud_count, CALIOP_ACA_count,             \
                        Terra_cf_total_mean/])
            end if

;  READ VARIABLES FROM GRID FILE
            a                       = addfile(wdir + sfilename + ".nc", "r")
            lat                     = a->lat_grids
            lon                     = a->lon_grids
            sampled_grids_lat_index = a->sampled_grids_lat_index
            sampled_grids_lon_index = a->sampled_grids_lon_index
            CALIOP_cloud_count      = a->CALIOP_cloud_count
            CALIOP_ACA_count        = a->CALIOP_ACA_count
            Terra_cf_total_mean     = a->Terra_cf_total_mean
            Aqua_cf_total_mean      = a->Aqua_cf_total_mean
            Terra_cf_total_mean@_FillValue = bv2
            Aqua_cf_total_mean@_FillValue  = bv2
;  SWITCH FOR TERRA AND AQUA MATCH
            if (switch_atmatch) then
            Aqua_cf_total_mean      = where(.not.ismissing(Terra_cf_total_mean), Aqua_cf_total_mean, bv2)
            end if
;  DECIDE WHICH TO PLOT : TERRA OR AQUA
            Terra_cf_total_mean     = Aqua_cf_total_mean

;  @@@@@@@@@@@@@@@@@@@@@@SWITCH FOR REGION SELECTION@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (switch_select_region) then
;  ======================WITH SELECTING THE REGION======================================
;  DEFINE OUTPUT ARRARY FOR SUBROUTINE region_aca_clear.ncl
            index               = new((/ndim_index/), integer, bv1)
            index_region        = new((/ndim_index/), integer, bv1)
            index_aca           = new((/ndim_index/), integer, bv1)
            index_clear         = new((/ndim_index/), integer, bv1)
            index_cloud         = new((/ndim_index/), integer, bv1)
            index_cloud_only    = new((/ndim_index/), integer, bv1)

;  CALL SUBROUTINE select_region_aca_clear_cloud.ncl TO SELECT DATA IN THE STUDY REGION AND 
;  JUDGE WHETHER THE GRID IS ACA, CLEAR, CLOUD, AND CLOUD ONLY
            select_region_aca_clear_cloud                      \
            (minlat, maxlat, minlon, maxlon, lat, lon,         \
             sampled_grids_lat_index, sampled_grids_lon_index, \
             CALIOP_cloud_count, CALIOP_ACA_count,             \
             index_region, index_aca, index_clear, index_cloud, index_cloud_only)

             index = index_cloud
;  DEFINE THE ACTUAL SIZE OF index
            if (all(ismissing(index))) then
               continue
            else
               dim_index_real  = ind(.not.ismissing(index))
               ndim_index_real = dimsizes(dim_index_real)
               if (all(ismissing(dim_index_real))) then
                  delete([/dim_index_real/])
                  continue
               end if
            end if
;  SUM MONTHLY, SEASONAL, AND YEARLY TOTAL
            do iindex = 0, ndim_index_real-1
              MODIS_cf_day(0, sampled_grids_lat_index(index(iindex)),        \
                              sampled_grids_lon_index(index(iindex))) =    \
                              (/Terra_cf_total_mean(index(iindex))/)
              MODIS_cf_month(iday_loop, sampled_grids_lat_index(index(iindex)),    \
                             sampled_grids_lon_index(index(iindex))) =    \
                             (/Terra_cf_total_mean(index(iindex))/)
              MODIS_cf_season(imonth_loop, sampled_grids_lat_index(index(iindex)), \
                              sampled_grids_lon_index(index(iindex))) = \
                              (/Terra_cf_total_mean(index(iindex))/)
              MODIS_cf_year(iyear_loop, sampled_grids_lat_index(index(iindex)),    \
                            sampled_grids_lon_index(index(iindex))) =   \
                            (/Terra_cf_total_mean(index(iindex))/)
            end do
            delete([/dim_index_real/])
         else
;  ======================WITHOUT SELECTING THE REGION=================================
;  SUM MONTHLY TOTAL
            nsample = dimsizes(sampled_grids_lat_index)
            do isample = 0, nsample-1
              MODIS_cf_day(0, sampled_grids_lat_index(isample),      \
                              sampled_grids_lon_index(isample)) =    \
                              (/Terra_cf_total_mean(isample)/)
              MODIS_cf_month(iday_loop, sampled_grids_lat_index(isample),    \
                             sampled_grids_lon_index(isample)) =    \
                             (/Terra_cf_total_mean(isample)/)
              MODIS_cf_season(imonth_loop, sampled_grids_lat_index(isample), \
                              sampled_grids_lon_index(isample)) =    \
                              (/Terra_cf_total_mean(isample)/)
              MODIS_cf_year(iyear_loop, sampled_grids_lat_index(isample),    \
                            sampled_grids_lon_index(isample)) =   \
                            (/Terra_cf_total_mean(isample)/)
           end do
        end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_daily) then
               MODIS_cf_daily = dim_avg_n(MODIS_cf_day, 0)
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT DAILY IMAGE WITH BACKGROUND MAP ON IT
               plot_contour_grid_backgroundmap_landmask \
               (wks, minlat, maxlat, minlon, maxlon,    \
               lat, lon, MODIS_cf_daily, stime)
            if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_map \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat_pg, lon_pg)
            end if
            end if
            delete([/MODIS_cf_day/])
            iday_loop   = iday_loop   + 1
            imonth_loop = imonth_loop + 1
            iyear_loop  = iyear_loop  + 1
         end do ; iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (logic_plot_monthly) then
            smonthly = siyear + "-" + simonth
            MODIS_cf_monthly    = dim_avg_n(MODIS_cf_month, 0)
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
            plot_contour_grid_landmask \
            (wks, minlat, maxlat, minlon, maxlon,    \
            lat, lon, MODIS_cf_monthly, smonthly)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
         end if
         delete([/MODIS_cf_month/])
      end do ; imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT SEASONAL IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (logic_plot_seasonal) then
         sseasonal = siyear + " " + sstring
         MODIS_cf_seasonal = dim_avg_n(MODIS_cf_season, 0)

;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT SEASONAL IMAGE WITH BACKGROUND MAP ON IT
            plot_contour_grid_landmask \
            (wks, minlat, maxlat, minlon, maxlon,    \
            lat, lon, MODIS_cf_seasonal, sseasonal)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
      end if
      delete([/MODIS_cf_season/])
   end do ; iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (logic_plot_yearly) then
      syearly         = sprinti("%0.4i", start_year) + "-" + \
                        sprinti("%0.4i", end_year)   + " " + sstring
      MODIS_cf_yearly = dim_avg_n(MODIS_cf_year, 0)

;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT YEARLY IMAGE WITH BACKGROUND MAP ON IT
         plot_contour_grid_landmask \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat, lon, MODIS_cf_yearly, syearly)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
   end if
   delete([/MODIS_cf_year/])
end
