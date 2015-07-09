; $ID: sum_month_seasonal_year_method1.ncl V01 06/02/2015 14:07 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE sum_month_seasonal_year_method1 SUMS ALL THE DATA FOR MONTHLY, SEASONAL, 
;  AND YEARLY CALCULATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
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
