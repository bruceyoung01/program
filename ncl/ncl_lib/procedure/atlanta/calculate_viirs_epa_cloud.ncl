;  $ID: calculate_viirs_epa_cloud.ncl v01 02/27/2013 11:52 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_viirs_epa_cloud CALCULATES SELECTED THE AVERAGE OF VIIRS 
;  AND EPA DATA, AND SELECTS THE DATA WITH CLEAR SKY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv2      (float, 1-D, (1)):                                       [---]
;       MISSING VALUE FOR FLOAT DATA.
;  (2 ) pm_data  (float, 2-D, (:, 2)):                                  [ug/m3]
;       EPA SITE PM2.5 DATA.
;  (3 ) rad_data (float, 2-D, (:, 25)):                         [Wm-2str-1um-1]
;       SELECTED VIIRS RADIANCE DATA.
;  (4 ) c_data   (integer, 1-D, (:)):                                     [---]
;       CLOUD AND CLEAR INFO DATABASE. 1 IS CLOUDY, 0 IS CLEAR.
;  (5 ) pm_avg   (float, 1-D, (:)):                                     [ug/m3]
;       AVERAGE OF EPA SITE HOURLY DATA
;  (6 ) rad_avg  (float, 1-D, (:)):                             [Wm-2str-1um-1]
;       AVERAGE OF SELECTED VIIRS RADIANCE DATA.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/27/2013)
;******************************************************************************
undef("calculate_viirs_epa_cloud")
procedure calculate_viirs_epa_cloud \
          (bv2          :float,    pm_data      :float,   \; INPUT
          rad_data      :float,    c_data       :integer, \; INPUT
          pm_avg        :float,    rad_avg      :float)    ; OUTPUT

begin
;  CALCULATE THE AVERAGE OF VIIRS DATA AND EPA DATA
   pm_avg  = dim_avg_n(pm_data, 1)
   rad_avg = dim_avg_n(rad_data, 1)

;  SELECTS THE DATA WITH CLEAR SKY
;  1 IS CLOUDY; 0 IS CLEAR
   index1  = ind(c_data(:, 0) .eq. 1)
   if (.not.all(ismissing(index1))) then
    pm_avg(index1)  = bv2
    rad_avg(index1) = bv2
   end if
   delete([/index1/])
return
end
