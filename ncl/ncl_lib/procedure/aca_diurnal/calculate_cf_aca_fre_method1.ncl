; $ID: calculate_cf_aca_fre_method1.ncl V01 06/02/2015 14:33 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_cf_aca_fre_method1 CALCULATES CLOUD FRACTION AND ACA FREQUENCY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv2                  (scalar):MISSING VALUE FOR FLOAT             [---]
;  (2 ) CALIOP_total_count_time (1-D):CALIOP TOTAL COUNT                  [---]
;  (3 ) CALIOP_cloud_count_time (1-D):CALIOP CLOUD COUNT                  [---]
;  (4 ) CALIOP_ACA_count_time   (1-D):CALIOP ACA COUNT                    [---]
;  (5 ) CALIOP_cf_time          (1-D):CALIOP CLOUD FRACTION               [---]
;  (6 ) CALIOP_ACA_fre_time     (1-D):CALIOP ACA FREQUENCY                [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/02/2015)
;******************************************************************************

undef("calculate_cf_aca_fre_method1")
procedure calculate_cf_aca_fre_method1 \
          (bv2                     :float,                                     \
           CALIOP_total_count_time :integer, CALIOP_cloud_count_time :integer, \
           CALIOP_ACA_count_time   :integer,                                   \
           CALIOP_cf_time          :float,   CALIOP_ACA_fre_time     :float)

begin

;  CALCULATE DAILY CLOUD FRACTION AND ACA FREQUENCY
;  CALIOP_ACA_fre_daily INCLUDES MISSING VALUES
   CALIOP_total_count_time_1d = ndtooned(CALIOP_total_count_time)
   CALIOP_cloud_count_time_1d = ndtooned(CALIOP_cloud_count_time)
   CALIOP_ACA_count_time_1d   = ndtooned(CALIOP_ACA_count_time)
   CALIOP_cf_time_1d          = new(dimsizes(CALIOP_cloud_count_time_1d), float, bv2)
   CALIOP_ACA_fre_time_1d     = new(dimsizes(CALIOP_cloud_count_time_1d), float, bv2)

   index1 = ind(.not.ismissing(CALIOP_total_count_time_1d) .and. \
                               CALIOP_total_count_time_1d .gt. 0)
   CALIOP_cf_time_1d(index1) = CALIOP_cloud_count_time_1d(index1)/ \
                       int2flt(CALIOP_total_count_time_1d(index1))
   CALIOP_cf_time = onedtond(CALIOP_cf_time_1d, dimsizes(CALIOP_cf_time))

   index2 = ind(.not.ismissing(CALIOP_cloud_count_time_1d) .and. \
                               CALIOP_cloud_count_time_1d .gt. 0)
   CALIOP_ACA_fre_time_1d(index2) = CALIOP_ACA_count_time_1d(index2)/ \
                            int2flt(CALIOP_cloud_count_time_1d(index2))
   CALIOP_ACA_fre_time = onedtond(CALIOP_ACA_fre_time_1d, dimsizes(CALIOP_ACA_fre_time))
   delete([/index1, index2/])
return
end
