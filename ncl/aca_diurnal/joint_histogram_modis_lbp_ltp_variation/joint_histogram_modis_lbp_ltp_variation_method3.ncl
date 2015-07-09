;  $ID: joint_histogram_modis_lbp_ltp_variation_diff_method3.ncl V01 05/17/2015 17:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM joint_histogram_modis_lbp_ltp_variatin_diff_method3 READS GRIDDED 
;  GLOBAL ACA DATA GENERATED FROM DR. ZHIBO ZHANG, SELECTS GRIDS DEPENDING ON 
;  CALIOP OBSERVATIONS OF AEROSOL AND CLOUD RELATIVE POSITION, TO GET CLEAR 
;  GRID AND ACA GRID, AND DETERMINES VERTICAL POSITION BASED ON CLOUD TOP 
;  PRESSURE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/17/2015)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_aca_grid_file.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_region_aca_clear_cloud.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_joint_histogram_modis_lbp_ltp.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_profile_errorbar_method3.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_joint_histogram_modis_lbp_ltp_variation_method3_aca_terra_2014_v10")
   gsn_define_colormap(wks,"MPL_gist_yarg")

;  DATA DIRECTORY
   wdir       = "/home/vy57456/zzbatmos_common/Exchange/For_Zhifeng/ACA_Data/"
   filelist   = "Global_list_2007_2014"
   wname      = asciiread(wdir+filelist, -1, "string")
   nwname     = dimsizes(wname)

;==============================================================================
;  SETUP MISSING VALUES; STUDY REGION, AND PAPRAMETERS
;==============================================================================
;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.
   zero1      = 0
   zero2      = 0.0

;  SET UP LIMITED REGION
   minlat     =-20.0
   maxlat     = 00.0
   minlon     =-10.0
   maxlon     = 10.0

;  SET UP THE START TIME AND END TIME
   start_year = 2014
   end_year   = 2014
   start_month= 8
   end_month  = 9
   start_day  = 1

;  SET UP SEASONAL STRING: -DJF, -MMA, JJA, SON
   sstring    = "JJA"

;  RESTRICTION FOR FILE
;  FOR DAY TIME, don = "d"; FOR NIGHT TIME, don = "n"
   don        = "d"
;  FOR ADJUST just = "_adjust"; FOR NOADJUST just = "oadjust"
   just       = "_adjust"

;  SINCE TERRA HAS MISSING VALUE ALONG S15DEG~S20DEG, 
;  THIS IS A SWITCH TO MATCH AQUA WITH TERRA
;  SWITCH FOR TERRA AND AQUA MATCH
   switch_atmatch       = True

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = False
   logic_plot_monthly  = True
   logic_plot_seasonal = True
   logic_plot_yearly   = True

;  SETUP PARAMETERS FROM .nc FILE HEADER INFO
   naerosol_type = 6
   ncot          = 11
   nctp          = 13
;==============================================================================

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

;  CALCULATE TOTAL SELECTED SAMPLES FROM ALL THE DATA
   tndim_index_year = tnday_year*ndim_index
   Terra_cot_ctp_hist_sum_year   = new((/tndim_index_year, nctp, ncot/),    float,   bv2)
   CALIOP_ACA_lbp_mean_avg_year  = new((/tndim_index_year, naerosol_type/), float, zero2)
   CALIOP_ACA_ltp_mean_avg_year  = new((/tndim_index_year, naerosol_type/), float, zero2)
;  DO YEAR LOOP
   tndim_index_real_year = 0
   iyear_loop   = 0
   tnday_season = 0
   do iyear = start_year, end_year
;  CALCULATE TOTAL DAYS FOR EACH YEAR DEPENDING ON
;  THE YEAR IS LEAP YEAR OR NON-LEAP YEAR
;  start_month AND end_month
      do iiimonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year     = days_in_month(iyear, iiimonth)
         tnday_season = tnday_season + lon_year
      end do
      if (iyear .gt. start_year) then
         delete([/Terra_cot_ctp_hist_sum_season,  \
                  CALIOP_ACA_lbp_mean_avg_season, \
                  CALIOP_ACA_ltp_mean_avg_season/])
      end if
;  CALCULATE TOTAL SELECTED SAMPLES FOR EACH SEASON
      tndim_index_season = tnday_season*ndim_index
      Terra_cot_ctp_hist_sum_season   = new((/tndim_index_season, nctp, ncot/),    float,   bv2)
      CALIOP_ACA_lbp_mean_avg_season  = new((/tndim_index_season, naerosol_type/), float, zero2)
      CALIOP_ACA_ltp_mean_avg_season  = new((/tndim_index_season, naerosol_type/), float, zero2)
;  DO MONTH LOOP
      tndim_index_real_season = 0
      imonth_loop = 0
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year = days_in_month(iyear, imonth)
;  TOTAL DAY IN imonth
         tnday_month = lon_year
         tndim_index_month = tnday_month*ndim_index
         if (iyear  .gt. start_year .or. \
             imonth .gt. start_month) then
            delete([/Terra_cot_ctp_hist_sum_month,  \
                     CALIOP_ACA_lbp_mean_avg_month, \
                     CALIOP_ACA_ltp_mean_avg_month/])
         end if

;  DEFINE NEW ARRAY FOR MONTHLY Terra_cot_ctp_hist
         Terra_cot_ctp_hist_sum_month    = new((/tndim_index_month, nctp, ncot/),    float,   bv2)
         CALIOP_ACA_lbp_mean_avg_month   = new((/tndim_index_month, naerosol_type/), float, zero2)
         CALIOP_ACA_ltp_mean_avg_month   = new((/tndim_index_month, naerosol_type/), float, zero2)
;  DO DAY LOOP
         tndim_index_real_month = 0
         iday_loop = 0
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTES
            logic_filename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
            print("Now Processing : " + stime)

;  CALL SUBROUTINE select_aca_grid_file.ncl TO READ FILE NAMES
            select_aca_grid_file \
            (wname, iyear, imonth, iday, don, just, sfilename, logic_filename)

            if (.not.logic_filename) then
               continue
            end if

;  CLEAR ALL THE VARIABLES BEFORE USING THEM
            if (iday   .gt. 1 .or.           \
                imonth .gt. start_month .or. \
                iyear  .gt. start_year) then
               delete([/lat_grids, lon_grids,                             \
                        sampled_grids_lat_index, sampled_grids_lon_index, \
                        CALIOP_cloud_count,                               \
                        CALIOP_ACA_count, CALIOP_ACA_lbp_mean,            \
                        CALIOP_ACA_ltp_mean,                              \
                        Terra_cot_ctp_hist, Terra_cot_ctp_hist1,          \
                        Terra_cf_total_mean, Aqua_cf_total_mean,          \
                        Aqua_cot_ctp_hist/])
            end if


;  DEFINE NEW ARRAY FOR DAILY Terra_cot_ctp_hist
            Terra_cot_ctp_hist_sum_day  = new((/ndim_index, nctp, ncot/),    float,   bv2)
            CALIOP_ACA_lbp_mean_avg_day = new((/ndim_index, naerosol_type/), float, zero2)
            CALIOP_ACA_ltp_mean_avg_day = new((/ndim_index, naerosol_type/), float, zero2)
;  READ VARIABLES FROM GRID FILE
            a = addfile(wdir + sfilename + ".nc", "r")
            lat_grids               = a->lat_grids
            lon_grids               = a->lon_grids
            COT_boundary            = a->COT_boundary
            CTP_boundary            = a->CTP_boundary
            sampled_grids_lat_index = a->sampled_grids_lat_index
            sampled_grids_lon_index = a->sampled_grids_lon_index
            CALIOP_cloud_count      = a->CALIOP_cloud_count
            CALIOP_ACA_count        = a->CALIOP_ACA_count
            CALIOP_ACA_lbp_mean     = a->CALIOP_ACA_lbp_mean
            CALIOP_ACA_ltp_mean     = a->CALIOP_ACA_ltp_mean
            Terra_cot_ctp_hist      = a->Terra_cot_ctp_hist
            Terra_cf_total_mean     = a->Terra_cf_total_mean
            Aqua_cot_ctp_hist       = a->Aqua_cot_ctp_hist
            Aqua_cf_total_mean      = a->Aqua_cf_total_mean
            Terra_cot_ctp_hist@_FillValue = bv1
            Terra_cf_total_mean@_FillValue= bv2
            Aqua_cot_ctp_hist@_FillValue  = bv1
            Aqua_cf_total_mean@_FillValue = bv2
            CALIOP_ACA_lbp_mean@_FillValue= zero2
            CALIOP_ACA_ltp_mean@_FillValue= zero2
;  SWITCH FOR TERRA AND AQUA MATCH
            if (switch_atmatch) then
            Aqua_cf_total_mean      = where(.not.ismissing(Terra_cf_total_mean), Aqua_cf_total_mean, bv2)
            Aqua_cot_ctp_hist       = where(.not.ismissing(Terra_cot_ctp_hist), Aqua_cot_ctp_hist, bv1)
            end if
;  DECIDE WHICH TO PLOT : TERRA OR AQUA
            Terra_cot_ctp_hist     = Terra_cot_ctp_hist
            Terra_cf_total_mean    = Terra_cf_total_mean


;  DEFINE OUTPUT ARRARY FOR SUBROUTINE select_region_aca_clear_cloud.ncl
            index               = new((/ndim_index/), integer, bv1)
            index_region        = new((/ndim_index/), integer, bv1)
            index_aca           = new((/ndim_index/), integer, bv1)
            index_clear         = new((/ndim_index/), integer, bv1)
            index_cloud         = new((/ndim_index/), integer, bv1)
            index_cloud_only    = new((/ndim_index/), integer, bv1)
            Terra_cot_ctp_hist1 = new((dimsizes(Terra_cot_ctp_hist)), float, bv2)

;  CALL SUBROUTINE select_region_aca_clear_cloud.ncl TO SELECT DATA IN THE STUDY REGION AND 
;  JUDGE WHETHER THE GRID IS CLEAR OR ACA
            select_region_aca_clear_cloud \
            (minlat, maxlat, minlon, maxlon, lat_grids, lon_grids, \
             sampled_grids_lat_index, sampled_grids_lon_index,     \
             CALIOP_cloud_count, CALIOP_ACA_count,                 \
             index_region, index_aca, index_clear, index_cloud, index_cloud_only)

            index = index_aca
;  DEFINE THE ACTUAL SIZE OF index_aca AND index_clear
            if (all(ismissing(index))) then
               continue
            else
               dim_index_real    = ind(.not.ismissing(index))
               ndim_index_real   = dimsizes(dim_index_real)
               if (all(ismissing(dim_index_real))) then
                  delete([/dim_index_real/])
                  continue
               end if
            end if
;  CALCULATE THE REAL HISTOGRAM DEPENDING ON TERRA CLOUD FRACTION
            nsample = dimsizes(sampled_grids_lat_index)
            do isample = 0, nsample-1
               if (.not.all(ismissing(Terra_cot_ctp_hist(isample, :, :)))) then
                  Terra_cot_ctp_hist1(isample, :, :) = Terra_cf_total_mean(isample)*      \
                                                       Terra_cot_ctp_hist(isample, :, :)/ \
                                                   sum(Terra_cot_ctp_hist(isample, :, :))
               end if
            end do

;  CALCULATE TOTAL Terra_cot_ctp_hist
            if (ndim_index_real .eq. 1) then
               Terra_cot_ctp_hist_sum_day(0, :, :)                          = \
               Terra_cot_ctp_hist1(index(dim_index_real), :, :)
               Terra_cot_ctp_hist_sum_month(tndim_index_real_month, :, :)   = \
               Terra_cot_ctp_hist1(index(dim_index_real), :, :)
               Terra_cot_ctp_hist_sum_season(tndim_index_real_season, :, :) = \
               Terra_cot_ctp_hist1(index(dim_index_real), :, :)
               Terra_cot_ctp_hist_sum_year(tndim_index_real_year, :, :)     = \
               Terra_cot_ctp_hist1(index(dim_index_real), :, :)
            else
               Terra_cot_ctp_hist_sum_day(0:ndim_index_real-1, :, :)                                                    = \
               Terra_cot_ctp_hist1(index(dim_index_real), :, :)
               Terra_cot_ctp_hist_sum_month(tndim_index_real_month:(tndim_index_real_month+ndim_index_real-1), :, :)    = \
               Terra_cot_ctp_hist1(index(dim_index_real), :, :)
               Terra_cot_ctp_hist_sum_season(tndim_index_real_season:(tndim_index_real_season+ndim_index_real-1), :, :) = \
               Terra_cot_ctp_hist1(index(dim_index_real), :, :)
               Terra_cot_ctp_hist_sum_year(tndim_index_real_year:(tndim_index_real_year+ndim_index_real-1), :, :)       = \
               Terra_cot_ctp_hist1(index(dim_index_real), :, :)
            end if

;  PROCESS CALIOP_ACA_lbp_mean DATA
            CALIOP_ACA_lbp_mean_avg = dim_avg_n(CALIOP_ACA_lbp_mean(index(dim_index_real), :), 0)
            if (ndim_index_real .eq. 1) then
               CALIOP_ACA_lbp_mean_avg_day(0, :)                          = \
               CALIOP_ACA_lbp_mean(index(dim_index_real), :)
               CALIOP_ACA_lbp_mean_avg_month(tndim_index_real_month, :)   = \
               CALIOP_ACA_lbp_mean(index(dim_index_real), :)
               CALIOP_ACA_lbp_mean_avg_season(tndim_index_real_season, :) = \
               CALIOP_ACA_lbp_mean(index(dim_index_real), :)
               CALIOP_ACA_lbp_mean_avg_year(tndim_index_real_year, :)     = \
               CALIOP_ACA_lbp_mean(index(dim_index_real), :)
            else
               CALIOP_ACA_lbp_mean_avg_day(0:ndim_index_real-1, :)                                                    = \
               CALIOP_ACA_lbp_mean(index(dim_index_real), :)
               CALIOP_ACA_lbp_mean_avg_month(tndim_index_real_month:(tndim_index_real_month+ndim_index_real-1), :)    = \
               CALIOP_ACA_lbp_mean(index(dim_index_real), :)
               CALIOP_ACA_lbp_mean_avg_season(tndim_index_real_season:(tndim_index_real_season+ndim_index_real-1), :) = \
               CALIOP_ACA_lbp_mean(index(dim_index_real), :)
               CALIOP_ACA_lbp_mean_avg_year(tndim_index_real_year:(tndim_index_real_year+ndim_index_real-1), :)       = \
               CALIOP_ACA_lbp_mean(index(dim_index_real), :)
            end if
;  PROCESS CALIOP_ACA_ltp_mean DATA
            CALIOP_ACA_ltp_mean_avg = dim_avg_n(CALIOP_ACA_ltp_mean(index(dim_index_real), :), 0)
            if (ndim_index_real .eq. 1) then
               CALIOP_ACA_ltp_mean_avg_day(0, :)                          = \
               CALIOP_ACA_ltp_mean(index(dim_index_real), :)
               CALIOP_ACA_ltp_mean_avg_month(tndim_index_real_month, :)   = \
               CALIOP_ACA_ltp_mean(index(dim_index_real), :)
               CALIOP_ACA_ltp_mean_avg_season(tndim_index_real_season, :) = \
               CALIOP_ACA_ltp_mean(index(dim_index_real), :)
               CALIOP_ACA_ltp_mean_avg_year(tndim_index_real_year, :)     = \
               CALIOP_ACA_ltp_mean(index(dim_index_real), :)
            else
               CALIOP_ACA_ltp_mean_avg_day(0:ndim_index_real-1, :)                                                    = \
               CALIOP_ACA_ltp_mean(index(dim_index_real), :)
               CALIOP_ACA_ltp_mean_avg_month(tndim_index_real_month:(tndim_index_real_month+ndim_index_real-1), :)    = \
               CALIOP_ACA_ltp_mean(index(dim_index_real), :) 
               CALIOP_ACA_ltp_mean_avg_season(tndim_index_real_season:(tndim_index_real_season+ndim_index_real-1), :) = \
               CALIOP_ACA_ltp_mean(index(dim_index_real), :) 
               CALIOP_ACA_ltp_mean_avg_year(tndim_index_real_year:(tndim_index_real_year+ndim_index_real-1), :)       = \
               CALIOP_ACA_ltp_mean(index(dim_index_real), :) 
            end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_daily) then
            CALIOP_ACA_lbp_mean_avg_daily = dim_avg_n(CALIOP_ACA_lbp_mean_avg_day, 0)
            CALIOP_ACA_ltp_mean_avg_daily = dim_avg_n(CALIOP_ACA_ltp_mean_avg_day, 0)
            Terra_cot_ctp_hist_sum_daily  = dim_avg_n(Terra_cot_ctp_hist_sum_day,  0)
;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_ltp.ncl TO PLOT
            plot_joint_histogram_modis_lbp_ltp      \
            (wks, COT_boundary, CTP_boundary,       \
             Terra_cot_ctp_hist_sum_daily*100,      \
             CALIOP_ACA_lbp_mean_avg,               \
             CALIOP_ACA_ltp_mean_avg, stime)
;  CALL SUBROUTINE plot_profile_errorbar_method3.ncl TO PLOT PROFILE WITH ERROR BAR
            plot_profile_errorbar_method3          \
            (wks, bv2, COT_boundary, CTP_boundary, \
             Terra_cot_ctp_hist_sum_day)
            end if
            tndim_index_real_month  = tndim_index_real_month  + ndim_index_real
            tndim_index_real_season = tndim_index_real_season + ndim_index_real
            tndim_index_real_year   = tndim_index_real_year   + ndim_index_real
            iday_loop   = iday_loop   + 1
            imonth_loop = imonth_loop + 1
            iyear_loop  = iyear_loop  + 1
            delete([/dim_index_real/])
         end do ; iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (logic_plot_monthly) then
         smonthly = siyear + "-" + simonth
         CALIOP_ACA_lbp_mean_avg_monthly = dim_avg_n(CALIOP_ACA_lbp_mean_avg_month, 0)
         CALIOP_ACA_ltp_mean_avg_monthly = dim_avg_n(CALIOP_ACA_ltp_mean_avg_month, 0)
         Terra_cot_ctp_hist_sum_monthly  = dim_avg_n(Terra_cot_ctp_hist_sum_month,  0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp.ncl TO PLOT MONTHLY HISTOGRAM
         plot_joint_histogram_modis_lbp_ltp        \
         (wks, COT_boundary, CTP_boundary,         \
          Terra_cot_ctp_hist_sum_monthly*100,      \
          CALIOP_ACA_lbp_mean_avg_monthly,         \
          CALIOP_ACA_ltp_mean_avg_monthly, smonthly)
;  CALL SUBROUTINE plot_profile_errorbar_method3.ncl TO PLOT PROFILE WITH ERROR BAR
         plot_profile_errorbar_method3          \
         (wks, bv2, COT_boundary, CTP_boundary, \
          Terra_cot_ctp_hist_sum_month)
          
         end if
      end do ; imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT SEASONAL IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (logic_plot_seasonal) then
      sseasonal = siyear + " " + sstring
      CALIOP_ACA_lbp_mean_avg_seasonal = dim_avg_n(CALIOP_ACA_lbp_mean_avg_season, 0)
      CALIOP_ACA_ltp_mean_avg_seasonal = dim_avg_n(CALIOP_ACA_ltp_mean_avg_season, 0)
      Terra_cot_ctp_hist_sum_seasonal  = dim_avg_n(Terra_cot_ctp_hist_sum_season,  0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_ltp.ncl TO PLOT SEASONAL HISTOGRAM
      plot_joint_histogram_modis_lbp_ltp          \
      (wks, COT_boundary, CTP_boundary,           \
       Terra_cot_ctp_hist_sum_seasonal*100,       \
       CALIOP_ACA_lbp_mean_avg_seasonal,          \
       CALIOP_ACA_ltp_mean_avg_seasonal, sseasonal)
;  CALL SUBROUTINE plot_profile_errorbar_method3.ncl TO PLOT PROFILE WITH ERROR BAR
      plot_profile_errorbar_method3          \
      (wks, bv2, COT_boundary, CTP_boundary, \
       Terra_cot_ctp_hist_sum_season)
      end if
   end do ; iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (logic_plot_yearly) then
   syearly = sprinti("%0.4i", start_year) + "-" + \
             sprinti("%0.4i", end_year)   + " " + sstring
   CALIOP_ACA_lbp_mean_avg_yearly = dim_avg_n(CALIOP_ACA_lbp_mean_avg_year, 0)
   CALIOP_ACA_ltp_mean_avg_yearly = dim_avg_n(CALIOP_ACA_ltp_mean_avg_year, 0)
   Terra_cot_ctp_hist_sum_yearly  = dim_avg_n(Terra_cot_ctp_hist_sum_year,  0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_ltp.ncl TO PLOT YEARLY HISTOGRAM
   plot_joint_histogram_modis_lbp_ltp      \
   (wks, COT_boundary, CTP_boundary,       \
    Terra_cot_ctp_hist_sum_yearly*100,     \
    CALIOP_ACA_lbp_mean_avg_yearly,        \
    CALIOP_ACA_ltp_mean_avg_yearly, syearly)
;  CALL SUBROUTINE plot_profile_errorbar_method3.ncl TO PLOT PROFILE WITH ERROR BAR
   plot_profile_errorbar_method3          \
   (wks, bv2, COT_boundary, CTP_boundary, \
    Terra_cot_ctp_hist_sum_year)
   end if
end
