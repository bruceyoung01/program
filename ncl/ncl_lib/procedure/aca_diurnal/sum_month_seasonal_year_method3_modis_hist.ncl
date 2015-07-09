; $ID: sum_month_seasonal_year_method3_modis_hist.ncl V01 06/02/2015 14:07 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE sum_month_seasonal_year_method3_modis_hist SUMS ALL THE DATA FOR 
;  MONTHLY, SEASONAL, AND YEARLY CALCULATION.
;
;  THREE METHODS ARE USED TO CALCULATE :
;  (1 ) COUNT/TOTAL_COUNT
;  (2 ) FREQUENCY/TOTAL_DAY
;  (3 ) FREQUENCY/TOTAL_AVAILABLE_POINT
;  HERE IS METHOD 3.
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/02/2015)
;******************************************************************************

undef("sum_month_seasonal_year_method3_modis_hist")
procedure sum_month_seasonal_year_method3_modis_hist \
          (index                  :integer, iloop                   :integer, \ ;INPUT
           switch_select_region   :logical,                                   \ ;INPUT
           sampled_grids_lat_index:short,   sampled_grids_lon_index :short,   \ ;INPUT
           Terra_cf_total_mean    :float,                                     \ ;INPUT
           Terra_cf_time          :float)                                       ;OUTPUT

begin

;  DEFINE THE ACTUAL SIZE OF index_region
         dim_index_real  = ind(.not.ismissing(index))
         ndim_index_real = dimsizes(dim_index_real)

         if (switch_select_region) then
;  SUM MONTHLY TOTAL
            do iindex = 0, ndim_index_real-1
              Terra_cf_time(iloop, sampled_grids_lat_index(index(iindex)), \
                            sampled_grids_lon_index(index(iindex))) =      \
                            (/Terra_cf_total_mean(index(iindex))/)
            end do
            delete([/dim_index_real/])
         else
;  ======================WITHOUT SELECTING THE REGION=================================
;  SUM MONTHLY TOTAL
            nsample = dimsizes(sampled_grids_lat_index)
            do isample = 0, nsample-1
              Terra_cf_time(iloop, sampled_grids_lat_index(isample), \
                            sampled_grids_lon_index(isample)) =      \
                            (/Terra_cf_total_mean(isample)/)
            end do
         end if

return
end
