; $ID: calculate_cf_aca_fre_method2.ncl V01 06/02/2015 14:33 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_cf_aca_fre_method2 CALCULATES CLOUD FRACTION AND ACA FREQUENCY.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/02/2015)
;******************************************************************************

undef("calculate_cf_aca_fre_method2")
procedure calculate_cf_aca_fre_method2 \
          (nlat                 :integer, nlon               :integer, \
           CALIOP_total_count   :integer, CALIOP_cloud_count :integer, \
           CALIOP_ACA_count_sum :integer,                              \
           CALIOP_cf            :float,   CALIOP_ACA_fre     :float)

begin

;  CALCULATE DAILY CLOUD FRACTION AND ACA FREQUENCY
;  CALIOP_ACA_fre_daily INCLUDES MISSING VALUES

   index1 = ind(.not.ismissing(CALIOP_total_count) .and. \
                               CALIOP_total_count .gt. 0)
   CALIOP_cf(index1) = CALIOP_cloud_count(index1)/ \
               int2flt(CALIOP_total_count(index1))

   index2 = ind(.not.ismissing(CALIOP_cloud_count) .and. \
                               CALIOP_cloud_count .gt. 0)
   CALIOP_ACA_fre(index2) = CALIOP_ACA_count_sum(index2)/ \
                    int2flt(CALIOP_cloud_count(index2))
   delete([/index1, index2/])
return
end
