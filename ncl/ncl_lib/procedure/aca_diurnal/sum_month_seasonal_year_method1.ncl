; $ID: sum_month_seasonal_year_method1.ncl V01 06/02/2015 14:07 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE sum_month_seasonal_year_method1 SUMS ALL THE DATA FOR MONTHLY, 
;  SEASONAL, AND YEARLY CALCULATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) index          (1-D):SELECTED INDEX FOR VARIOUS CASES, INCLUDING 
;                            REGION, ACA, CLEAR, CLOUD, AND CLOUD_ONLY    [---]
;  (2 ) switch_select_region (logic):SWITCH FOR OPENNING THE REGION SELECTION 
;                                    OR NOT                               [---]
;  (3 ) sampled_grids_lat_index (1-D):SAMPLED GRIDS INDEX OF LATITUDE     [---]
;  (4 ) sampled_grids_lon_index (1-D):SAMPLED GRIDS INDEX OF LONGITUDE    [---]
;  (5 ) CALIOP_total_count      (1-D):CALIOP TOTAL COUNT                  [---]
;  (6 ) CALIOP_cloud_count      (1-D):CALIOP CLOUD COUNT                  [---]
;  (7 ) CALIOP_ACA_count_sum    (1-D):CALIOP ACA COUNT FOR VARIOUS AEROSOL 
;                                     TYPES                               [---]
;  (8 ) CALIOP_total_count_time (2-D):CALIOP TOTAL COUNT FOR SPECIFIC TIME[---]
;  (9 ) CALIOP_cloud_count_time (2-D):CALIOP CLOUD COUNT FOR SPECIFIC TIME[---]
;  (10) CALIOP_ACA_count_time   (2-D):CALIOP ACA COUNT FOR SPECIFIC TIME  [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/02/2015)
;******************************************************************************

undef("sum_month_seasonal_year_method1")
procedure sum_month_seasonal_year_method1 \
          (index                  :integer, switch_select_region    :logical, \ ;INPUT
           sampled_grids_lat_index:short,   sampled_grids_lon_index :short,   \ ;INPUT
           CALIOP_total_count     :integer, CALIOP_cloud_count      :integer, \ ;INPUT
           CALIOP_ACA_count_sum   :integer,                                   \ ;INPUT
           CALIOP_total_count_time:integer, CALIOP_cloud_count_time :integer, \ ;OUTPUT
           CALIOP_ACA_count_time  :integer)                                     ;OUTPUT

begin

;  DEFINE THE ACTUAL SIZE OF index_region
          dim_index_real  = ind(.not.ismissing(index))
          ndim_index_real = dimsizes(dim_index_real)

         if (switch_select_region) then
;  SUM MONTHLY TOTAL
            do iindex = 0, ndim_index_real-1
              CALIOP_total_count_time(sampled_grids_lat_index(index(iindex)),   \
                                      sampled_grids_lon_index(index(iindex))) = \
              CALIOP_total_count_time(sampled_grids_lat_index(index(iindex)),   \
                                      sampled_grids_lon_index(index(iindex))) + \
                                      (/CALIOP_total_count(index(iindex))/)
              CALIOP_cloud_count_time(sampled_grids_lat_index(index(iindex)),   \
                                      sampled_grids_lon_index(index(iindex))) = \
              CALIOP_cloud_count_time(sampled_grids_lat_index(index(iindex)),   \
                                      sampled_grids_lon_index(index(iindex))) + \
                                      (/CALIOP_cloud_count(index(iindex))/)
              CALIOP_ACA_count_time(sampled_grids_lat_index(index(iindex)),     \
                                    sampled_grids_lon_index(index(iindex))) =   \
              CALIOP_ACA_count_time(sampled_grids_lat_index(index(iindex)),     \
                                    sampled_grids_lon_index(index(iindex))) +   \
                                    (/CALIOP_ACA_count_sum(index(iindex))/)
            end do
            delete([/dim_index_real/])
         else
;  ======================WITHOUT SELECTING THE REGION=================================
;  SUM MONTHLY TOTAL
            nsample = dimsizes(sampled_grids_lat_index)
            do isample = 0, nsample-1
               CALIOP_total_count_time(sampled_grids_lat_index(isample),   \
                                       sampled_grids_lon_index(isample)) = \
               CALIOP_total_count_time(sampled_grids_lat_index(isample),   \
                                       sampled_grids_lon_index(isample)) + \
                                       (/CALIOP_total_count(isample)/)
               CALIOP_cloud_count_time(sampled_grids_lat_index(isample),   \
                                       sampled_grids_lon_index(isample)) = \
               CALIOP_cloud_count_time(sampled_grids_lat_index(isample),   \
                                       sampled_grids_lon_index(isample)) + \
                                       (/CALIOP_cloud_count(isample)/)
               CALIOP_ACA_count_time(sampled_grids_lat_index(isample),     \
                                     sampled_grids_lon_index(isample)) =   \
               CALIOP_ACA_count_time(sampled_grids_lat_index(isample),     \
                                     sampled_grids_lon_index(isample)) +   \
                                     (/CALIOP_ACA_count_sum(isample)/)
            end do
         end if

return
end
