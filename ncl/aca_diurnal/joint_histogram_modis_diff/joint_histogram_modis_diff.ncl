;  $ID: joint_histogram_modis_diff.ncl V01 05/17/2015 17:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM joint_histogram_modis_diff READS GRIDDED GLOBAL ACA DATA GENERATED 
;  FROM DR. ZHIBO ZHANG, SELECTS GRIDS DEPENDING ON CALIOP OBSERVATIONS OF 
;  AEROSOL AND CLOUD RELATIVE POSITION, TO GET CLEAR GRID AND ACA GRID, AND 
;  DETERMINES VERTICAL POSITION BASED ON CLOUD TOP PRESSURE.
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
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_region_aca_clear.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_histogram_terra_aqua_cot_ctp_hist_aca_diff.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_joint_histogram_modis_terra_aqua_diff_v01")
   gsn_define_colormap(wks,"NCV_blu_red")

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
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2007
   start_month= 7
   end_month  = 7
   start_day  = 1

;  RESTRICTION FOR FILE
;  FOR DAY TIME, don = "d"; FOR NIGHT TIME, don = "n"
   don        = "d"
;  FOR ADJUST just = "_adjust"; FOR NOADJUST just = "oadjust"
   just       = "oadjust"
;  SETUP PARAMETERS FROM .nc FILE HEADER INFO
   ncot       = 11
   nctp       = 13
;==============================================================================

   sfilename  = new(1, string)

;  READ THE FILE DEPENDING ON THE YEAR, MONTH, DAY, AND DAYTIME AND NIGHTTIME
;  DO YEAR LOOP
   do iyear = start_year, end_year
      if (isleapyear(iyear)) then
         lon_year = dleap_year
      else
         lon_year = ndleap_year
      end if
;  DO MONTH LOOP
      do imonth = start_month, end_month
;  DO DAY LOOP
         iday_loop = 0
;  DEFINE NEW ARRAY FOR MONTHLY Terra_cot_ctp_hist AND Aqua_cot_ctp_hist
         Terra_cot_ctp_hist_sum_monthly = new((/nctp, ncot/), integer, bv1)
         Terra_cot_ctp_hist_sum_monthly = 0
         Aqua_cot_ctp_hist_sum_monthly  = new((/nctp, ncot/), integer, bv1)
         Aqua_cot_ctp_hist_sum_monthly  = 0
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year   = days_in_month(iyear, imonth)
         do iday = start_day, lon_year
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
            print("Now Processing : " + stime)

;  CLEAR ALL THE VARIABLES BEFORE USING THEM
            if (iday .gt. 1) then
               delete([/lat_grids, lon_grids,                             \
                        sampled_grids_lat_index, sampled_grids_lon_index, \
                        CALIOP_cloud_count,                               \
                        CALIOP_ACA_count, CALIOP_ACA_lbp_mean,            \
                        Terra_cot_ctp_hist, Terra_cot_ctp_hist1,          \
                        Aqua_cot_ctp_hist, Aqua_cot_ctp_hist1/])
            end if

;  CALL SUBROUTINE select_aca_grid_file.ncl TO READ VARIABLES
            select_aca_grid_file \
            (wname, iyear, imonth, iday, don, just, sfilename)

;  READ VARIABLES FROM GRID FILE
            a                       = addfile(wdir + sfilename + ".nc", "r")
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
            Aqua_cot_ctp_hist       = a->Aqua_cot_ctp_hist

;  DEFINE OUTPUT ARRARY FOR SUBROUTINE region_aca_clear.ncl
            ndim_index          = 200
            index_aca           = new((/ndim_index/), integer, bv1)
            index_clear         = new((/ndim_index/), integer, bv1)
            Terra_cot_ctp_hist1 = new((dimsizes(Terra_cot_ctp_hist)), integer, bv1)

;  CALL SUBROUTINE select_region_aca_clear.ncl TO SELECT DATA IN THE STUDY REGION AND 
;  JUDGE WHETHER THE GRID IS CLEAR OR ACA
            select_region_aca_clear \
            (minlat, maxlat, minlon, maxlon, lat_grids, lon_grids, \
             sampled_grids_lat_index, sampled_grids_lon_index,     \
             CALIOP_cloud_count, CALIOP_ACA_count, index_aca, index_clear)
;  DEFINE THE ACTUAL SIZE OF index_aca AND index_clear
            if (all(ismissing(index_aca))   .or. \
                all(ismissing(index_clear))) then
               continue
            else
               dim_index_aca_real    = ind(.not.ismissing(index_aca))
               dim_index_clear_real  = ind(.not.ismissing(index_clear))
               ndim_index_aca_real   = dimsizes(dim_index_aca_real)
               ndim_index_clear_real = dimsizes(dim_index_clear_real)
            end if

;  CALCULATE TOTAL Terra_cot_ctp_hist
            Terra_cot_ctp_hist1     = where(Terra_cot_ctp_hist .lt. 0, zero1, Terra_cot_ctp_hist)
            Terra_cot_ctp_hist_sum  = dim_sum_n(Terra_cot_ctp_hist1(dim_index_aca_real, :, :), 0)
            Terra_cot_ctp_hist_sum_monthly = Terra_cot_ctp_hist_sum_monthly + Terra_cot_ctp_hist_sum
;  CALCULATE TOTAL Aqua_cot_ctp_hist
            Aqua_cot_ctp_hist1      = new((dimsizes(Aqua_cot_ctp_hist)), integer, bv1)
            Aqua_cot_ctp_hist1      = where(Aqua_cot_ctp_hist .lt. 0, zero1, Terra_cot_ctp_hist)
            Aqua_cot_ctp_hist_sum   = dim_sum_n(Aqua_cot_ctp_hist1(dim_index_aca_real, :, :), 0)
            Aqua_cot_ctp_hist_sum_monthly    = Aqua_cot_ctp_hist_sum_monthly + Aqua_cot_ctp_hist_sum
            Terra_Aqua_cot_ctp_hist_sum_diff = Aqua_cot_ctp_hist_sum - Terra_cot_ctp_hist_sum
            

;  CALL SUBROUTINE plot_histogram_terra_aqua_cot_ctp_hist_aca_diff.ncl TO PLOT
            plot_histogram_terra_aqua_cot_ctp_hist_aca_diff \
            (wks, COT_boundary, CTP_boundary,     \
            Terra_Aqua_cot_ctp_hist_sum_diff, stime)
            delete([/dim_index_aca_real, dim_index_clear_real/])
            iday_loop = iday_loop + 1
         end do ; iday
         Terra_cot_ctp_hist_sum_monthly = Terra_cot_ctp_hist_sum_monthly/iday_loop
         Aqua_cot_ctp_hist_sum_monthly  = Aqua_cot_ctp_hist_sum_monthly/iday_loop
         Terra_Aqua_cot_ctp_hist_sum_monthly_diff = Aqua_cot_ctp_hist_sum_monthly - Terra_cot_ctp_hist_sum_monthly

;  CALL SUBROUTINE plot_histogram_terra_aqua_cot_ctp_hist_aca_diff.ncl TO PLOT MONTHLY HISTOGRAM
         smonthly = siyear + "-" + simonth
         plot_histogram_terra_aqua_cot_ctp_hist_aca_diff \
         (wks, COT_boundary, CTP_boundary,     \
         Terra_Aqua_cot_ctp_hist_sum_monthly_diff, smonthly)
      end do ; imonth
   end do ; iyear
end
