; $ID: sum_month_seasonal_year_method3.ncl V01 06/02/2015 14:07 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE sum_month_seasonal_year_method3 SUMS ALL THE DATA FOR 
;  MONTHLY, SEASONAL, AND YEARLY CALCULATION.
;
;  THREE METHODS ARE USED TO CALCULATE :
;  (1 ) COUNT/TOTAL_COUNT
;  (2 ) FREQUENCY/TOTAL_DAY
;  (3 ) FREQUENCY/TOTAL_AVAILABLE_POINT
;  HERE IS METHOD 3.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) index    (1-D):INDEX FOR REGION, ACA, CLEAR, CLOUD, OR CLOUD ONLY [---]
;  (2 ) iloop    (1-D):LOOP NUMBERS                                       [---]
;  (3 ) switch_select_region (logical):SWITCH WHETHER TO CONSIDER THE REGION 
;                                      LIMITATION OR NOT                  [---]
;  (4 ) sampled_grids_lat_index (1-D):SELECTED LATITUDE INDEX             [---]
;  (5 ) sampled_grids_lon_index (1-D):SELECTED LONGITUDE INDEX            [---]
;  (6 ) CALIOP_cf               (1-D):CALIOP CLOUD FRACTION               [---]
;  (7 ) CALIOP_ACA_fre          (1-D):CALIOP ACA FREQUENCY                [---]
;  (8 ) CALIOP_cf_time          (1-D):CALIOP CLOUD FRACTION FOR DAY, MONTH, YEAR
;                                                                         [---]
;  (9 ) CALIOP_ACA_fre_time     (1-D):CALIOP ACA FREQUENCY FOR DAY, MONTH, YEAR
;                                                                         [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/02/2015)
;******************************************************************************

undef("sum_month_seasonal_year_method3")
procedure sum_month_seasonal_year_method3 \
          (index                  :integer, iloop                   :integer, \ ;INPUT
           switch_select_region   :logical,                                   \ ;INPUT
           sampled_grids_lat_index:short,   sampled_grids_lon_index :short,   \ ;INPUT
           CALIOP_cf              :float,   CALIOP_ACA_fre          :float,   \ ;INPUT
           CALIOP_cf_time         :float,   CALIOP_ACA_fre_time     :float)     ;OUTPUT

begin

;  DEFINE THE ACTUAL SIZE OF index_region
   dim_index_real  = ind(.not.ismissing(index))
   ndim_index_real = dimsizes(dim_index_real)

   if (switch_select_region) then
;  SUM MONTHLY TOTAL
      do iindex = 0, ndim_index_real-1
        CALIOP_cf_time(iloop, sampled_grids_lat_index(index(iindex)), \
                       sampled_grids_lon_index(index(iindex))) =      \
                       (/CALIOP_cf(index(iindex))/)
        CALIOP_ACA_fre_time(iloop, sampled_grids_lat_index(index(iindex)), \
                            sampled_grids_lon_index(index(iindex))) =      \
                            (/CALIOP_ACA_fre(index(iindex))/)
      end do
      delete([/dim_index_real/])
   else
;  ======================WITHOUT SELECTING THE REGION=================================
;  SUM MONTHLY TOTAL
      nsample = dimsizes(sampled_grids_lat_index)
      do isample = 0, nsample-1
        CALIOP_cf_time(iloop, sampled_grids_lat_index(isample), \
                       sampled_grids_lon_index(isample)) =      \
                       (/CALIOP_cf(isample)/)
        CALIOP_ACA_fre_time(iloop, sampled_grids_lat_index(isample), \
                            sampled_grids_lon_index(isample)) =      \
                            (/CALIOP_ACA_fre(isample)/)
      end do
   end if

return
end
