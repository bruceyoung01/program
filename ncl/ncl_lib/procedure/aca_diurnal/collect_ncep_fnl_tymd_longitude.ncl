;  $ID: collect_ncep_fnl_tymd_longitude.ncl V01 08/10/2015 21:37 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE collect_ncep_fnl_tymd_longitude.ncl COLLECTS THE NCEP FNL DATA FOR 
;  TOTAL, YEAR, MONTH, AND DAY CALCULATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) iloop_total         (a scalar):# OF LOOPS                         [   ]
;  (2 ) start_lat_ind1      (a scalar):START INDEX OF 1ST PART OF FNL DATA[   ]
;  (3 ) end_lat_ind1        (a scalar):END INDEX OF 1ST PART OF FNL DATA  [   ]
;  (6 ) start_nlat_0_com1   (a scalar):START INDEX OF 1ST PART OF COLLECTED FNL DATA[   ]
;  (7 ) end_nlat_0_com1     (a scalar):END INDEX OF 1ST PART OF COLLECTED FNL DATA  [   ]
;  (10) lat                      (1-D):ORIGINALLY NCEP FNL LATITUDE       [DEG]
;  (11) hgt_hour                 (2-D):HOURLY GEOPOTENTIAL HEIGHT         [gpm]
;  (12) tmpc_hour                (2-D):HOURLY TEMPERATURE                 [C  ]
;  (13) tdc_hour                 (2-D):HOURLY DEW POINT TEMPERATURE       [C  ]
;  (14) u_hour                   (2-D):HOURLY U-WIND COMPONENT            [m/s]
;  (15) v-hour                   (2-D):HOURLY V-WIND COMPONENT            [m/s]
;  (16) wspd_hour                (2-D):HOURLY WIND SPEED                  [m/s]
;  (17) wdir_hour                (2-D):HOURLY WIND DIRECTION              [DEG]
;  (18) lat_total                (1-D):SELECTED LATITUDE -90~90           [DEG]
;  (19) hgt_total                (3-D):TOTALLY GEOPOTENTIAL HEIGHT        [gpm]
;  (20) tmpc_total               (3-D):TOTALLY TEMPERATURE                [C  ]
;  (21) tdc_total                (3-D):TOTALLY DEW POINT TEMPERATURE      [C  ]
;  (22) u_total                  (3-D):TOTALLY U-WIND COMPONENT           [m/s]
;  (23) v-total                  (3-D):TOTALLY V-WIND COMPONENT           [m/s]
;  (24) wspd_total               (3-D):TOTALLY WIND SPEED                 [m/s]
;  (25) wdir_total               (3-D):TOTALLY WIND DIRECTION             [DEG]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/10/2015)
;******************************************************************************
undef("collect_ncep_fnl_tymd_longitude")
procedure collect_ncep_fnl_tymd_longitude \
          (iloop_total          :integer,                             \;INPUT
           start_lat_ind1       :integer, end_lat_ind1       :integer,\;INPUT
           start_nlat_0_com1    :integer, end_nlat_0_com1    :integer,\;INPUT
           lat                  :float,                               \;INPUT
           hgt_hour             :float,   tmpc_hour          :float,  \;INPUT
           tdc_hour             :float,   u_hour             :float,  \;INPUT
           v_hour               :float,   vvel_hour          :float,  \;INPUT
           wspd_hour            :float,   wdir_hour          :float,  \;INPUT
           lat_total            :float,                               \;INPUT
           hgt_total            :float,   tmpc_total         :float,  \;OUTPUT
           tdc_total            :float,   u_total            :float,  \;OUTPUT
           v_total              :float,   vvel_total         :float,  \;OUTPUT
           wspd_total           :float,   wdir_total         :float)   ;OUTPUT

begin

;  COLLECT ALL THE DATA
   lat_total(start_nlat_0_com1:end_nlat_0_com1)                  = \
   lat(start_lat_ind1:end_lat_ind1)
   hgt_total (iloop_total, :, start_nlat_0_com1:end_nlat_0_com1) = \
   hgt_hour (:, start_lat_ind1:end_lat_ind1)
   tmpc_total(iloop_total, :, start_nlat_0_com1:end_nlat_0_com1) = \
   tmpc_hour(:, start_lat_ind1:end_lat_ind1)
   tdc_total (iloop_total, :, start_nlat_0_com1:end_nlat_0_com1) = \
   tdc_hour (:, start_lat_ind1:end_lat_ind1)
   u_total   (iloop_total, :, start_nlat_0_com1:end_nlat_0_com1) = \
   u_hour   (:, start_lat_ind1:end_lat_ind1)
   v_total   (iloop_total, :, start_nlat_0_com1:end_nlat_0_com1) = \
   v_hour   (:, start_lat_ind1:end_lat_ind1)
   vvel_total(iloop_total, :, start_nlat_0_com1:end_nlat_0_com1) = \
   vvel_hour(:, start_lat_ind1:end_lat_ind1)
   wspd_total(iloop_total, :, start_nlat_0_com1:end_nlat_0_com1) = \
   wspd_hour(:, start_lat_ind1:end_lat_ind1)
   wdir_total(iloop_total, :, start_nlat_0_com1:end_nlat_0_com1) = \
   wdir_hour(:, start_lat_ind1:end_lat_ind1)

return
end
