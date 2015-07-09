; $ID: sum_month_seasonal_year_method2.ncl V01 06/02/2015 14:07 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE sum_month_seasonal_year_method2 SUMS ALL THE DATA FOR MONTHLY, SEASONAL, 
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

undef("sum_month_seasonal_year_method2")
procedure sum_month_seasonal_year_method2 \
          (index                  :integer, switch_select_region    :logical, \ ;INPUT
           sampled_grids_lat_index:short,   sampled_grids_lon_index :short,   \ ;INPUT
           CALIOP_cf              :float,   CALIOP_ACA_fre          :float,   \ ;INPUT
           CALIOP_cf_time         :float,   CALIOP_ACA_fre_time     :float)

begin

;  DEFINE THE ACTUAL SIZE OF index_region
         dim_index_real  = ind(.not.ismissing(index))
         ndim_index_real = dimsizes(dim_index_real)

         if (switch_select_region) then
;  SUM MONTHLY TOTAL
            do iindex = 0, ndim_index_real-1
              CALIOP_cf_time(sampled_grids_lat_index(index(iindex)),   \
                             sampled_grids_lon_index(index(iindex))) = \
              CALIOP_cf_time(sampled_grids_lat_index(index(iindex)),   \
                             sampled_grids_lon_index(index(iindex))) + \
                             (/CALIOP_cf(index(iindex))/)
              CALIOP_ACA_fre_time(sampled_grids_lat_index(index(iindex)),   \
                                  sampled_grids_lon_index(index(iindex))) = \
              CALIOP_ACA_fre_time(sampled_grids_lat_index(index(iindex)),   \
                                  sampled_grids_lon_index(index(iindex))) + \
                                  (/CALIOP_ACA_fre(index(iindex))/)
            end do
            delete([/index_region, dim_index_real/])
         else
;  ======================WITHOUT SELECTING THE REGION=================================
;  SUM MONTHLY TOTAL
            nsample = dimsizes(sampled_grids_lat_index)
            do isample = 0, nsample-1
              CALIOP_cf_time(sampled_grids_lat_index(isample),   \
                             sampled_grids_lon_index(isample)) = \
              CALIOP_cf_time(sampled_grids_lat_index(isample),   \
                             sampled_grids_lon_index(isample)) + \
                             (/CALIOP_cf(isample)/)
              CALIOP_ACA_fre_time(sampled_grids_lat_index(isample),   \
                                  sampled_grids_lon_index(isample)) = \
              CALIOP_ACA_fre_time(sampled_grids_lat_index(isample),   \
                                  sampled_grids_lon_index(isample)) + \
                                  (/CALIOP_ACA_fre(isample)/)
            end do
         end if

return
end
