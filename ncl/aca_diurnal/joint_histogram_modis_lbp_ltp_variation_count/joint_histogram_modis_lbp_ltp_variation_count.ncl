;  $ID: joint_histogram_modis_lbp_ltp_variation_count.ncl V01 05/17/2015 17:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM joint_histogram_modis_lbp_ltp_variation_count READS GRIDDED GLOBAL ACA DATA 
;  GENERATED FROM DR. ZHIBO ZHANG, SELECTS GRIDS DEPENDING ON CALIOP 
;  OBSERVATIONS OF AEROSOL AND CLOUD RELATIVE POSITION, TO GET CLEAR GRID AND 
;  ACA GRID, AND DETERMINES VERTICAL POSITION BASED ON CLOUD TOP PRESSURE.
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
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_joint_histogram_modis_lbp_ltp_count.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_profile_errorbar_count.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_joint_histogram_modis_lbp_ltp_variation_count_aca_terra_v07")
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
   start_year = 2007
   end_year   = 2014
   start_month= 6
   end_month  = 8
   start_day  = 1

;  SET UP SEASONAL STRING: -DJF, -MMA, JJA, SON
   sstring    = "JJA"

;  RESTRICTION FOR FILE
;  FOR DAY TIME, dorn = "d"; FOR NIGHT TIME, dorn = "n"
   dorn       = "d"
;  FOR ADJUST just = "_adjust"; FOR NOADJUST just = "oadjust"
   just       = "_adjust"
;  SETUP PARAMETERS FROM .nc FILE HEADER INFO
   naerosol_type = 6
   ncot       = 11
   nctp       = 13
;==============================================================================

   sfilename  = new(1, string)

;  CALCULATE TOTAL YEARS
   total_nyear = end_year - start_year + 1
;  CALCULATE TOTAL DAYS DEPENDING ON
;  start_year AND end_year
;  start_month AND end_month
   total_nday = 0
   do iiyear = start_year, end_year
      do iimonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year = days_in_month(iiyear, iimonth)
         total_nday = total_nday + lon_year
      end do
   end do
;  READ THE FILE DEPENDING ON THE YEAR, MONTH, DAY, AND DAYTIME AND NIGHTTIME

;  DO YEAR LOOP
      iyear_loop = 0
      Terra_cot_ctp_hist_sum_yearly = new((/nctp, ncot/), float, bv2)
      Terra_cot_ctp_hist_sum_yearly = 0.0
      CALIOP_ACA_lbp_mean_avg_year  = new((/total_nday*total_nyear, naerosol_type/), float, bv2)
      CALIOP_ACA_ltp_mean_avg_year  = new((/total_nday*total_nyear, naerosol_type/), float, bv2)
   do iyear = start_year, end_year
;  DO MONTH LOOP
      imonth_loop = 0
      Terra_cot_ctp_hist_sum_seasonal = new((/nctp, ncot/), float, bv2)
      Terra_cot_ctp_hist_sum_seasonal = 0.0
      CALIOP_ACA_lbp_mean_avg_season  = new((/total_nday, naerosol_type/), float, bv2)
      CALIOP_ACA_ltp_mean_avg_season  = new((/total_nday, naerosol_type/), float, bv2)
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year = days_in_month(iyear, imonth)
         if (iyear_loop  .gt. 0 .or. \
             imonth_loop .gt. 0) then
            delete([/CALIOP_ACA_lbp_mean_avg_month, \
                     CALIOP_ACA_ltp_mean_avg_month/])
         end if
;  DO DAY LOOP
         iday_loop = 0
;  DEFINE NEW ARRAY FOR MONTHLY Terra_cot_ctp_hist
         Terra_cot_ctp_hist_sum_monthly = new((/nctp, ncot/), float, bv2)
         Terra_cot_ctp_hist_sum_monthly = 0.0
         CALIOP_ACA_lbp_mean_avg_monthly= new((/naerosol_type/), float, bv2)
         CALIOP_ACA_lbp_mean_avg_monthly= 0.0
         CALIOP_ACA_lbp_mean_avg_month  = new((/lon_year(imonth-1), naerosol_type/), float, bv2)
         CALIOP_ACA_ltp_mean_avg_monthly= new((/naerosol_type/), float, bv2)
         CALIOP_ACA_ltp_mean_avg_monthly= 0.0
         CALIOP_ACA_ltp_mean_avg_month  = new((/lon_year(imonth-1), naerosol_type/), float, bv2)
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTES
            logic_filename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
            print("Now Processing : " + stime)

;  CALL SUBROUTINE select_aca_grid_file.ncl TO READ VARIABLES
            select_aca_grid_file \
            (wname, iyear, imonth, iday, dorn, just, sfilename, logic_filename)

            if (.not.logic_filename) then
               continue
            end if

;  CLEAR ALL THE VARIABLES BEFORE USING THEM
            if (iyear_loop  .gt. 0 .or. \
                imonth_loop .gt. 0 .or. \
                iday_loop   .gt. 0) then
               delete([/lat_grids, lon_grids,                             \
                        sampled_grids_lat_index, sampled_grids_lon_index, \
                        CALIOP_total_count, CALIOP_cloud_count,           \
                        CALIOP_ACA_count, CALIOP_ACA_lbp_mean,            \
                        CALIOP_ACA_ltp_mean,                              \
                        Terra_cot_ctp_hist,  Terra_cot_ctp_hist1,         \
                        Terra_cf_total_mean/])
            end if

;  READ VARIABLES FROM GRID FILE
            a                       = addfile(wdir + sfilename + ".nc", "r")
            lat_grids               = a->lat_grids
            lon_grids               = a->lon_grids
            COT_boundary            = a->COT_boundary
            CTP_boundary            = a->CTP_boundary
            sampled_grids_lat_index = a->sampled_grids_lat_index
            sampled_grids_lon_index = a->sampled_grids_lon_index
            CALIOP_total_count      = a->CALIOP_total_count
            CALIOP_cloud_count      = a->CALIOP_cloud_count
            CALIOP_ACA_count        = a->CALIOP_ACA_count
            CALIOP_ACA_lbp_mean     = a->CALIOP_ACA_lbp_mean
            CALIOP_ACA_ltp_mean     = a->CALIOP_ACA_ltp_mean
            Terra_cot_ctp_hist      = a->Terra_cot_ctp_hist
            Terra_cf_total_mean     = a->Terra_cf_total_mean
            Terra_cot_ctp_hist@_FillValue = bv1
            Terra_cf_total_mean@_FillValue= bv2

;  DEFINE OUTPUT ARRARY FOR SUBROUTINE select_region_aca_clear_cloud.ncl
            ndim_index             = 500
            index                  = new((/ndim_index/), integer, bv1)
            index_region           = new((/ndim_index/), integer, bv1)
            index_aca              = new((/ndim_index/), integer, bv1)
            index_clear            = new((/ndim_index/), integer, bv1)
            index_cloud            = new((/ndim_index/), integer, bv1)
            index_cloud_only       = new((/ndim_index/), integer, bv1)
            Terra_cot_ctp_hist1    = new((dimsizes(Terra_cot_ctp_hist)), float, bv2)
            Terra_cot_ctp_hist1    = 0.0
            Terra_cot_ctp_hist_sum = new((/nctp, ncot/), float, bv2)
            Terra_cot_ctp_hist_sum = 0.0

;  CALL SUBROUTINE select_region_aca_clear_cloud.ncl TO SELECT DATA IN THE STUDY REGION AND 
;  JUDGE WHETHER THE GRID IS ACA, CLEAR, CLOUD, AND CLOUD ONLY
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
               if (ndim_index_real .le. 1) then
                  delete([/dim_index_real/])
                  continue
               end if
            end if

;  CALCULATE TOTAL Terra_cot_ctp_hist
            if (all(ismissing(Terra_cot_ctp_hist(dim_index_real, :, :)))) then
                delete([/dim_index_real/])
                continue
            else if (sum(Terra_cot_ctp_hist(dim_index_real, :, :)) .eq. 0.0) then
                delete([/dim_index_real/])
                continue
            end if
            end if
            Terra_cot_ctp_hist1             = where(ismissing(Terra_cot_ctp_hist), 0.0, Terra_cot_ctp_hist)
            Terra_cot_ctp_hist_sum          = dim_sum_n(Terra_cot_ctp_hist1(dim_index_real, :, :), 0)/ \
                                              ndim_index_real
            Terra_cot_ctp_hist_sum_monthly  = Terra_cot_ctp_hist_sum_monthly  + Terra_cot_ctp_hist_sum
            Terra_cot_ctp_hist_sum_seasonal = Terra_cot_ctp_hist_sum_seasonal + Terra_cot_ctp_hist_sum
            Terra_cot_ctp_hist_sum_yearly   = Terra_cot_ctp_hist_sum_yearly   + Terra_cot_ctp_hist_sum
            Terra_cot_ctp_hist_sum          = where(Terra_cot_ctp_hist_sum .le. 0.0, bv1, Terra_cot_ctp_hist_sum)

;  PROCESS CALIOP_ACA_lbp_mean DATA
            CALIOP_ACA_lbp_mean     = where(CALIOP_ACA_lbp_mean .eq. 0.0, bv2, CALIOP_ACA_lbp_mean)
            CALIOP_ACA_lbp_mean@_FillValue = bv2
            CALIOP_ACA_lbp_mean_avg = dim_avg_n(CALIOP_ACA_lbp_mean, 0)
            CALIOP_ACA_lbp_mean_avg_month(iday_loop, :)    = CALIOP_ACA_lbp_mean_avg
            CALIOP_ACA_lbp_mean_avg_season(imonth_loop, :) = CALIOP_ACA_lbp_mean_avg
            CALIOP_ACA_lbp_mean_avg_year(iyear_loop, :)    = CALIOP_ACA_lbp_mean_avg

;  PROCESS CALIOP_ACA_ltp_mean DATA
            CALIOP_ACA_ltp_mean     = where(CALIOP_ACA_ltp_mean .eq. 0.0, bv2, CALIOP_ACA_ltp_mean)
            CALIOP_ACA_ltp_mean@_FillValue = bv2
            CALIOP_ACA_ltp_mean_avg = dim_avg_n(CALIOP_ACA_ltp_mean, 0)
            CALIOP_ACA_ltp_mean_avg_month(iday_loop, :)    = CALIOP_ACA_ltp_mean_avg
            CALIOP_ACA_ltp_mean_avg_season(imonth_loop, :) = CALIOP_ACA_ltp_mean_avg
            CALIOP_ACA_ltp_mean_avg_year(iyear_loop, :)    = CALIOP_ACA_ltp_mean_avg

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_ltp_count.ncl TO PLOT
            plot_joint_histogram_modis_lbp_ltp_count \
            (wks, COT_boundary, CTP_boundary,  \
            Terra_cot_ctp_hist_sum,            \
            CALIOP_ACA_lbp_mean_avg,           \
            CALIOP_ACA_ltp_mean_avg, stime)
;  CALL SUBROUTINE plot_profile_errorbar_count.ncl TO PLOT PROFILE WITH ERROR BAR
            plot_profile_errorbar_count            \
            (wks, bv2, COT_boundary, CTP_boundary, \
             Terra_cot_ctp_hist_sum)
;print("Terra_cot_ctp_hist1 = " + sum(Terra_cot_ctp_hist1))
;print("Terra_cot_ctp_hist_sum = " + sum(Terra_cot_ctp_hist_sum))
;print("Terra_cf_total_mean = " + avg(Terra_cf_total_mean))
            delete([/dim_index_real/])
            iday_loop   = iday_loop   + 1
            imonth_loop = imonth_loop + 1
            iyear_loop  = iyear_loop  + 1
         end do ; iday
         Terra_cot_ctp_hist_sum_monthly  = Terra_cot_ctp_hist_sum_monthly/iday_loop
         CALIOP_ACA_lbp_mean_avg_monthly = dim_avg_n(CALIOP_ACA_lbp_mean_avg_month, 0)
         CALIOP_ACA_ltp_mean_avg_monthly = dim_avg_n(CALIOP_ACA_ltp_mean_avg_month, 0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_ltp_count.ncl TO PLOT MONTHLY HISTOGRAM
         smonthly = siyear + "-" + simonth
         plot_joint_histogram_modis_lbp_ltp_count   \
         (wks, COT_boundary, CTP_boundary,    \
          Terra_cot_ctp_hist_sum_monthly,     \
          CALIOP_ACA_lbp_mean_avg_monthly,    \
          CALIOP_ACA_ltp_mean_avg_monthly, smonthly)
;  CALL SUBROUTINE plot_profile_errorbar.ncl TO PLOT PROFILE WITH ERROR BAR
         plot_profile_errorbar_count            \
         (wks, bv2, COT_boundary, CTP_boundary, \
          Terra_cot_ctp_hist_sum_monthly)
      end do ; imonth
      Terra_cot_ctp_hist_sum_seasonal  = Terra_cot_ctp_hist_sum_seasonal/imonth_loop
      CALIOP_ACA_lbp_mean_avg_seasonal = dim_avg_n(CALIOP_ACA_lbp_mean_avg_season, 0)
      CALIOP_ACA_ltp_mean_avg_seasonal = dim_avg_n(CALIOP_ACA_ltp_mean_avg_season, 0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_ltp_count.ncl TO PLOT SEASONAL HISTOGRAM
      sseasonal = siyear + " " + sstring
      plot_joint_histogram_modis_lbp_ltp_count    \
      (wks, COT_boundary, CTP_boundary,     \
       Terra_cot_ctp_hist_sum_seasonal,     \
       CALIOP_ACA_lbp_mean_avg_seasonal,    \
       CALIOP_ACA_ltp_mean_avg_seasonal, sseasonal)
;  CALL SUBROUTINE plot_profile_errorbar_count.ncl TO PLOT PROFILE WITH ERROR BAR
      plot_profile_errorbar_count            \
      (wks, bv2, COT_boundary, CTP_boundary, \
       Terra_cot_ctp_hist_sum_seasonal)
   end do ; iyear

   Terra_cot_ctp_hist_sum_yearly  = Terra_cot_ctp_hist_sum_yearly/iyear_loop
   CALIOP_ACA_lbp_mean_avg_yearly = dim_avg_n(CALIOP_ACA_lbp_mean_avg_year, 0)
   CALIOP_ACA_ltp_mean_avg_yearly = dim_avg_n(CALIOP_ACA_ltp_mean_avg_year, 0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_ltp_count.ncl TO PLOT YEARLY HISTOGRAM
   syearly = sprinti("%0.4i", start_year) + "-" + \
             sprinti("%0.4i", end_year)   + " " + sstring
   plot_joint_histogram_modis_lbp_ltp_count  \
   (wks, COT_boundary, CTP_boundary,   \
    Terra_cot_ctp_hist_sum_yearly,     \
    CALIOP_ACA_lbp_mean_avg_yearly,    \
    CALIOP_ACA_ltp_mean_avg_yearly, syearly)
;  CALL SUBROUTINE plot_profile_errorbar_count.ncl TO PLOT PROFILE WITH ERROR BAR
   plot_profile_errorbar_count            \
   (wks, bv2, COT_boundary, CTP_boundary, \
   Terra_cot_ctp_hist_sum_yearly)

end
