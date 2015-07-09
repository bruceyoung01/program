;  $ID: joint_histogram_modis_lbp_diff_terra.ncl V01 05/17/2015 17:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM joint_histogram_modis_lbp_diff_terra READS GRIDDED GLOBAL ACA DATA 
;  GENERATED FROM DR. ZHIBO ZHANG, SELECTS GRIDS DEPENDING ON CALIOP 
;  OBSERVATIONS OF AEROSOL AND CLOUD RELATIVE POSITION, TO GET CLEAR GRID AND 
;  ACA GRID, AND DETERMINES VERTICAL POSITION BASED ON CLOUD TOP PRESSURE. 
;  COMPARE THE DIFFERENCE BETWEEN ACA AND CLOUD ONLY CASES FOR TERRA OR AQUA.
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
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_joint_histogram_modis_lbp_diff.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_joint_histogram_modis_lbp_diff_terra_v06")
   gsn_define_colormap(wks,"BlWhRe")

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
   end_year   = 2008
   start_month= 6
   end_month  = 8
   start_day  = 1

;  SET UP SEASONAL STRING: -DJF, -MMA, JJA, SON
   sstring    = "JJA"

;  RESTRICTION FOR FILE
;  FOR DAY TIME, don = "d"; FOR NIGHT TIME, don = "n"
   don        = "d"
;  FOR ADJUST just = "_adjust"; FOR NOADJUST just = "oadjust"
   just       = "_adjust"
;  SETUP PARAMETERS FROM .nc FILE HEADER INFO
   naerosol_type = 6
   ncot       = 11
   nctp       = 13
;==============================================================================

   sfilename  = new(1, string)

;  CALCULATE TOTAL DAYS DEPENDING ON
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
;  READ THE FILE DEPENDING ON THE YEAR, MONTH, DAY, AND DAYTIME AND NIGHTTIME
;  DO YEAR LOOP
   iyear_loop = 0
   Terra_cot_ctp_hist_suma_yearly       = new((/nctp, ncot/), float, bv2)
   Terra_cot_ctp_hist_suma_yearly       = 0
   Terra_cot_ctp_hist_sumb_yearly       = new((/nctp, ncot/), float, bv2)
   Terra_cot_ctp_hist_sumb_yearly       = 0
   Terra_cot_ctp_hist_sumab_yearly_diff = new((/nctp, ncot/), float, bv2)
   Terra_cot_ctp_hist_sumab_yearly_diff = 0
   CALIOP_ACA_lbp_mean_avg_year         = new((/tnday_year, naerosol_type/), float, bv2)
   do iyear = start_year, end_year
      do iiimonth = start_month, end_month
         lon_year     = days_in_month(iyear, iiimonth)
         tnday_season = tnday_season + lon_year
      end do
;  DO MONTH LOOP
      imonth_loop = 0
      Terra_cot_ctp_hist_suma_seasonal       = new((/nctp, ncot/), float, bv2)
      Terra_cot_ctp_hist_suma_seasonal       = 0
      Terra_cot_ctp_hist_sumb_seasonal       = new((/nctp, ncot/), float, bv2)
      Terra_cot_ctp_hist_sumb_seasonal       = 0
      Terra_cot_ctp_hist_sumab_seasonal_diff = new((/nctp, ncot/), float, bv2)
      Terra_cot_ctp_hist_sumab_seasonal_diff = 0
      CALIOP_ACA_lbp_mean_avg_season         = new((/tnday_season, naerosol_type/), float, bv2)
      do imonth = start_month, end_month
         if (iyear_loop  .gt. 0 .or. \
             imonth_loop .gt. 0) then
            delete([/CALIOP_ACA_lbp_mean_avg_month/])
         end if

;  DO DAY LOOP
         iday_loop = 0
;  DEFINE NEW ARRAY FOR MONTHLY Terra_cot_ctp_hist
         Terra_cot_ctp_hist_suma_monthly          = new((/nctp, ncot/), float, bv2)
         Terra_cot_ctp_hist_suma_monthly          = 0
         Terra_cot_ctp_hist_sumb_monthly          = new((/nctp, ncot/), float, bv2)
         Terra_cot_ctp_hist_sumb_monthly          = 0
         Terra_cot_ctp_hist_sumab_monthly_diff    = new((/nctp, ncot/), float, bv2)
         Terra_cot_ctp_hist_sumab_monthly_diff    = 0
         CALIOP_ACA_lbp_mean_avg                  = new((/naerosol_type/), float, bv2)
         CALIOP_ACA_lbp_mean_avg                  = 0.0
         CALIOP_ACA_lbp_mean_avg_monthly          = new((/naerosol_type/), float, bv2)
         CALIOP_ACA_lbp_mean_avg_monthly          = 0.0
         CALIOP_ACA_lbp_mean_avg_month            = new((/lon_year, naerosol_type/), float, bv2)
         lon_year = days_in_month(iyear, imonth)
         do iday = start_day, lon_year
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
            print("Now Processing : " + stime)

;  CLEAR ALL THE VARIABLES BEFORE USING THEM
            if (iyear_loop  .gt. 0 .or. \
                imonth_loop .gt. 0 .or. \
                iday_loop   .gt. 0) then
               delete([/lat_grids, lon_grids,                             \
                        sampled_grids_lat_index, sampled_grids_lon_index, \
                        CALIOP_cloud_count,                               \
                        CALIOP_ACA_count, CALIOP_ACA_lbp_mean,            \
                        Terra_cot_ctp_hist, Terra_cot_ctp_hist1a,         \
                        Terra_cot_ctp_hist1b, Terra_cot_ctp_hist1,        \
                        Terra_cf_total_mean/])
            end if

;  CALL SUBROUTINE select_aca_grid_file.ncl TO READ VARIABLES
            select_aca_grid_file \
            (wname, iyear, imonth, iday, don, just, sfilename)

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
            Terra_cot_ctp_hist      = a->Terra_cot_ctp_hist
            Terra_cf_total_mean     = a->Terra_cf_total_mean

;  DEFINE OUTPUT ARRARY FOR SUBROUTINE select_region_aca_clear_cloud.ncl
            ndim_index          = 500
            index_region        = new((/ndim_index/),   integer, bv1)
            index_aca           = new((/ndim_index/), integer, bv1)
            index_clear         = new((/ndim_index/), integer, bv1)
            index_cloud         = new((/ndim_index/), integer, bv1)
            index_cloud_only    = new((/ndim_index/), integer, bv1)
            Terra_cot_ctp_hist1 = new((dimsizes(Terra_cot_ctp_hist)), float, bv2)
            Terra_cot_ctp_hist1 = 0.0
            Terra_cot_ctp_hist1a= new((dimsizes(Terra_cot_ctp_hist)), float, bv2)
            Terra_cot_ctp_hist1a= 0.0
            Terra_cot_ctp_hist1b= new((dimsizes(Terra_cot_ctp_hist)), float, bv2)
            Terra_cot_ctp_hist1b= 0.0

;  CALL SUBROUTINE select_region_aca_clear_cloud.ncl TO SELECT DATA IN THE STUDY REGION AND 
;  JUDGE WHETHER THE GRID IS CLEAR OR ACA
            select_region_aca_clear_cloud \
            (minlat, maxlat, minlon, maxlon, lat_grids, lon_grids, \
             sampled_grids_lat_index, sampled_grids_lon_index,     \
             CALIOP_cloud_count, CALIOP_ACA_count,                 \
             index_region, index_aca, index_clear, index_cloud, index_cloud_only)
;  DEFINE THE ACTUAL SIZE OF index_aca AND index_clear
            if (all(ismissing(index_cloud)) .or. \
                all(ismissing(index_cloud_only))) then
               continue
            else
               dim_index_real_cloud       = ind(.not.ismissing(index_cloud))
               ndim_index_real_cloud      = dimsizes(dim_index_real_cloud)
               dim_index_real_cloud_only  = ind(.not.ismissing(index_cloud_only))
               ndim_index_real_cloud_only = dimsizes(dim_index_real_cloud_only)
               if (ndim_index_real_cloud      .le. 1 .or. \
                   ndim_index_real_cloud_only .le. 1) then
                  delete([/dim_index_real_cloud/])
                  delete([/dim_index_real_cloud_only/])
                  continue
               end if
            end if

;  CALCULATE THE REAL HISTOGRAM DEPENDING ON TERRA CLOUD FRACTION
            nsample = dimsizes(sampled_grids_lat_index)
            do isample = 0, nsample-1
               if (.not.ismissing(Terra_cf_total_mean(isample)) .and. \
                   .not.all(ismissing(Terra_cot_ctp_hist(isample, :, :)))) then
                  Terra_cot_ctp_hist1(isample, :, :) = Terra_cf_total_mean(isample)* \
                                                       Terra_cot_ctp_hist(isample, :, :)
                  if (.not.all(ismissing(Terra_cot_ctp_hist1(isample, :, :))) .and. \
                                     sum(Terra_cot_ctp_hist1(isample, :, :)) .ne. 0.0) then
                     Terra_cot_ctp_hist1(isample, :, :) = Terra_cot_ctp_hist1(isample, :, :)/ \
                                                      sum(Terra_cot_ctp_hist1(isample, :, :))
                  end if
               end if
            end do

;  CALCULATE TOTAL Terra_cot_ctp_hist WITH THE RESTRICTION 1
            if (sum(Terra_cot_ctp_hist1(dim_index_real_cloud_only, :, :)) .eq. 0) then
                delete([/dim_index_real_cloud, dim_index_real_cloud_only/])
               continue
            end if
            Terra_cot_ctp_hist1a             = where(ismissing(Terra_cot_ctp_hist1), 0.0, Terra_cot_ctp_hist1)
            Terra_cot_ctp_hist_suma          = dim_sum_n(Terra_cot_ctp_hist1a(dim_index_real_cloud_only, :, :), 0)/ \
                                                     sum(Terra_cot_ctp_hist1a(dim_index_real_cloud_only, :, :))
            Terra_cot_ctp_hist_suma_monthly  = Terra_cot_ctp_hist_suma_monthly + Terra_cot_ctp_hist_suma
            Terra_cot_ctp_hist_suma_seasonal = Terra_cot_ctp_hist_suma_seasonal + Terra_cot_ctp_hist_suma
            Terra_cot_ctp_hist_suma_yearly   = Terra_cot_ctp_hist_suma_yearly + Terra_cot_ctp_hist_suma
            Terra_cot_ctp_hist_suma  = where(Terra_cot_ctp_hist_suma .le. 0, bv1, Terra_cot_ctp_hist_suma)

;  CALCULATE TOTAL Terra_cot_ctp_hist WITH THE RESTRICTION 2
            if (sum(Terra_cot_ctp_hist1(dim_index_real_cloud, :, :)) .eq. 0) then
                delete([/dim_index_real_cloud, dim_index_real_cloud_only/])
               continue
            end if
            Terra_cot_ctp_hist1b             = where(ismissing(Terra_cot_ctp_hist1), 0.0, Terra_cot_ctp_hist1)
            Terra_cot_ctp_hist_sumb          = dim_sum_n(Terra_cot_ctp_hist1b(dim_index_real_cloud, :, :), 0)/ \
                                                     sum(Terra_cot_ctp_hist1b(dim_index_real_cloud, :, :))
            Terra_cot_ctp_hist_sumb_monthly  = Terra_cot_ctp_hist_sumb_monthly + Terra_cot_ctp_hist_sumb
            Terra_cot_ctp_hist_sumb_seasonal = Terra_cot_ctp_hist_sumb_seasonal + Terra_cot_ctp_hist_sumb
            Terra_cot_ctp_hist_sumb_yearly   = Terra_cot_ctp_hist_sumb_yearly + Terra_cot_ctp_hist_sumb
            Terra_cot_ctp_hist_sumb   = where(Terra_cot_ctp_hist_sumb .le. 0, bv1, Terra_cot_ctp_hist_sumb)

            Terra_cot_ctp_hist_sumab_diff = Terra_cot_ctp_hist_sumb - Terra_cot_ctp_hist_suma
;  PROCESS CALIOP_ACA_lbp_mean DATA
            CALIOP_ACA_lbp_mean     = where(CALIOP_ACA_lbp_mean .eq. 0.0, bv2, CALIOP_ACA_lbp_mean)
            CALIOP_ACA_lbp_mean@_FillValue = bv2
            CALIOP_ACA_lbp_mean_avg = dim_avg_n(CALIOP_ACA_lbp_mean, 0)
            CALIOP_ACA_lbp_mean_avg_month(iday_loop, :)    = CALIOP_ACA_lbp_mean_avg
            CALIOP_ACA_lbp_mean_avg_season(imonth_loop, :) = CALIOP_ACA_lbp_mean_avg
            CALIOP_ACA_lbp_mean_avg_year(iyear_loop, :)    = CALIOP_ACA_lbp_mean_avg

;  CALL SUBROUTINE plot_histogram_terra_aqua_cot_ctp_hist_lbp_diff.ncl TO PLOT
;           plot_histogram_terra_aqua_cot_ctp_hist_lbp_diff \
;           (wks, COT_boundary, CTP_boundary,               \
;            Terra_aqua_cot_ctp_hist_sum_diff,              \
;            CALIOP_ACA_lbp_mean_avg, stime)
             delete([/dim_index_real_cloud, dim_index_real_cloud_only/])
            iday_loop   = iday_loop   + 1
            imonth_loop = imonth_loop + 1
            iyear_loop  = iyear_loop  + 1
         end do ; iday
         Terra_cot_ctp_hist_sumab_monthly_diff = (Terra_cot_ctp_hist_sumb_monthly - Terra_cot_ctp_hist_suma_monthly)/iday_loop
         CALIOP_ACA_lbp_mean_avg_monthly       = dim_avg_n(CALIOP_ACA_lbp_mean_avg_month, 0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_diff.ncl TO PLOT MONTHLY HISTOGRAM
         smonthly = siyear + "-" + simonth
         plot_joint_histogram_modis_lbp_diff             \
         (wks, COT_boundary, CTP_boundary,               \
          Terra_cot_ctp_hist_sumab_monthly_diff*100,  \
          CALIOP_ACA_lbp_mean_avg_monthly, smonth)
      end do ; imonth
      Terra_cot_ctp_hist_suma_seasonal = where(Terra_cot_ctp_hist_suma_seasonal .le. 0, bv1, Terra_cot_ctp_hist_suma_seasonal)
      Terra_cot_ctp_hist_sumb_seasonal = where(Terra_cot_ctp_hist_sumb_seasonal .le. 0, bv1, Terra_cot_ctp_hist_sumb_seasonal)
      Terra_cot_ctp_hist_sumab_seasonal_diff = (Terra_cot_ctp_hist_sumb_seasonal - Terra_cot_ctp_hist_suma_seasonal)/imonth_loop
      CALIOP_ACA_lbp_mean_avg_seasonal = dim_avg_n(CALIOP_ACA_lbp_mean_avg_season, 0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_diff.ncl TO PLOT SEASONAL HISTOGRAM
      sseasonal = siyear + " " + sstring
      plot_joint_histogram_modis_lbp_diff             \
      (wks, COT_boundary, CTP_boundary,               \
       Terra_cot_ctp_hist_sumab_seasonal_diff*100, \
       CALIOP_ACA_lbp_mean_avg_seasonal, sseasonal)
   end do ; iyear
   Terra_cot_ctp_hist_suma_yearly = where(Terra_cot_ctp_hist_suma_yearly .le. 0, bv1, Terra_cot_ctp_hist_suma_yearly)
   Terra_cot_ctp_hist_sumb_yearly = where(Terra_cot_ctp_hist_sumb_yearly .le. 0, bv1, Terra_cot_ctp_hist_sumb_yearly)
   Terra_cot_ctp_hist_sumab_yearly_diff = (Terra_cot_ctp_hist_sumb_yearly - Terra_cot_ctp_hist_suma_yearly)/iyear_loop
   CALIOP_ACA_lbp_mean_avg_yearly = dim_avg_n(CALIOP_ACA_lbp_mean_avg_year, 0)

;  CALL SUBROUTINE plot_joint_histogram_modis_lbp_diff.ncl TO PLOT YEARLY HISTOGRAM
   syearly = sprinti("%0.4i", start_year) + "-" + \
             sprinti("%0.4i", end_year)   + " " + sstring
   plot_joint_histogram_modis_lbp_diff             \
   (wks, COT_boundary, CTP_boundary,               \
    Terra_cot_ctp_hist_sumab_yearly_diff*100, \
    CALIOP_ACA_lbp_mean_avg_yearly, syearly)
end
