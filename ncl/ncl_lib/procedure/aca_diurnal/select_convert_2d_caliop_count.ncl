;  $ID: select_convert_2d_caliop_count.ncl V01 08/29/2015 16:55 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_convert_2d_caliop_count.ncl SELECTS THE CALIOP COUNTS BASED 
;  ON THE VARIOUS CASES, INCLUDING CALIOP_total_count, CALIOP_cloud_count, AND 
;  CALIOP_ACA_count, THEN CONVERTS THE 1-D COUNT TO 2-D COUNT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) index    (1-D):INDEX FOR REGION, ACA, CLEAR, CLOUD, OR CLOUD ONLY [---]
;  (2 ) switch_select_region (logical):SWITCH WHETHER TO CONSIDER THE REGION 
;                                      LIMITATION OR NOT                  [---]
;  (3 ) sampled_grids_lat_index (1-D):SELECTED LATITUDE INDEX             [---]
;  (4 ) sampled_grids_lon_index (1-D):SELECTED LONGITUDE INDEX            [---]
;  (5 ) CALIOP_total_count      (1-D):CALIOP TOTAL COUNT                  [---]
;  (6 ) CALIOP_cloud_count      (1-D):CALIOP CLOUD COUNT                  [---]
;  (7 ) CALIOP_ACA_count        (1-D):CALIOP ACA COUNT                    [---]
;  (8 ) CALIOP_total_count_grid (2-D):2-D SELECTED CALIOP TOTAL COUNT     [---]
;  (9 ) CALIOP_cloud_count_grid (2-D):2-D SELECTED CALIOP CLOUD COUNT     [---]
;  (10) CALIOP_ACA_count_grid   (2-D):2-D SELECTED CALIOP ACA COUNT       [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/29/2015)
;******************************************************************************

undef("select_convert_2d_caliop_count")
procedure select_convert_2d_caliop_count \
          (index                  :integer, switch_select_region    :logical, \ ;INPUT
           sampled_grids_lat_index:short,   sampled_grids_lon_index :short,   \ ;INPUT
           CALIOP_total_count     :integer, CALIOP_cloud_count      :integer, \ ;INPUT
           CALIOP_ACA_count       :integer,                                   \ ;INPUT
           CALIOP_total_count_grid:integer, CALIOP_cloud_count_grid :integer, \ ;OUTPUT
           CALIOP_ACA_count_grid  :integer)                                     ;OUTPUT

begin
;  DEFINE THE ACTUAL SIZE OF index_region
   dim_index_real  = ind(.not.ismissing(index))
   ndim_index_real = dimsizes(dim_index_real)

;  SELECT COUNT AND ASSIGN IT TO THE 2-D COUNT
   if (switch_select_region) then
      do iindex = 0, ndim_index_real-1
        CALIOP_total_count_grid(sampled_grids_lat_index(index(iindex)),   \
                                sampled_grids_lon_index(index(iindex))) = \
                                (/CALIOP_total_count(index(iindex))/)
        CALIOP_cloud_count_grid(sampled_grids_lat_index(index(iindex)),   \
                                sampled_grids_lon_index(index(iindex))) = \
                                (/CALIOP_cloud_count(index(iindex))/)
        CALIOP_ACA_count_grid(sampled_grids_lat_index(index(iindex)),     \
                              sampled_grids_lon_index(index(iindex))) =   \
                              (/CALIOP_ACA_count(index(iindex))/)
      end do
      delete([/dim_index_real/])
   else
;  ======================WITHOUT SELECTING THE REGION=================================
      nsample = dimsizes(sampled_grids_lat_index)
      do isample = 0, nsample-1
        CALIOP_total_count_grid(sampled_grids_lat_index(isample),    \
                                sampled_grids_lon_index(isample)) =  \
                                (/CALIOP_total_count(isample)/)
        CALIOP_cloud_count_grid(sampled_grids_lat_index(isample),    \
                                sampled_grids_lon_index(isample)) =  \
                                (/CALIOP_cloud_count(isample)/)
        CALIOP_ACA_count_grid(sampled_grids_lat_index(isample),      \
                              sampled_grids_lon_index(isample)) =    \
                              (/CALIOP_ACA_count(isample)/)
      end do
   end if

return
end
