;  $ID: collect_ncep_fnl_tymd_latitude.ncl V01 08/10/2015 21:37 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE collect_ncep_fnl_tymd_latitude.ncl COLLECTS THE NCEP FNL DATA FOR 
;  TOTAL, YEAR, MONTH, AND DAY CALCULATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) iloop_total         (a scalar):# OF LOOPS                         [   ]
;  (2 ) start_lon_ind1      (a scalar):START INDEX OF 1ST PART OF FNL DATA[   ]
;  (3 ) end_lon_ind1        (a scalar):END INDEX OF 1ST PART OF FNL DATA  [   ]
;  (4 ) start_lon_ind2      (a scalar):START INDEX OF 2ND PART OF FNL DATA[   ]
;  (5 ) end_lon_ind2        (a scalar):END INDEX OF 2ND PART OF FNL DATA  [   ]
;  (6 ) start_nlon_0_com1   (a scalar):START INDEX OF 1ST PART OF COLLECTED FNL DATA[   ]
;  (7 ) end_nlon_0_com1     (a scalar):END INDEX OF 1ST PART OF COLLECTED FNL DATA  [   ]
;  (8 ) start_nlon_0_com2   (a scalar):START INDEX OF 2ND PART OF COLLECTED FNL DATA[   ]
;  (9 ) end_nlon_0_com2     (a scalar):END INDEX OF 2ND PART OF COLLECTED FNL DATA  [   ]
;  (10) lon                      (1-D):ORIGINALLY NCEP FNL LONGITUDE      [DEG]
;  (11) hgt_hour                 (2-D):HOURLY GEOPOTENTIAL HEIGHT         [gpm]
;  (12) tmpc_hour                (2-D):HOURLY TEMPERATURE                 [C  ]
;  (13) tdc_hour                 (2-D):HOURLY DEW POINT TEMPERATURE       [C  ]
;  (14) u_hour                   (2-D):HOURLY U-WIND COMPONENT            [m/s]
;  (15) v-hour                   (2-D):HOURLY V-WIND COMPONENT            [m/s]
;  (16) wspd_hour                (2-D):HOURLY WIND SPEED                  [m/s]
;  (17) wdir_hour                (2-D):HOURLY WIND DIRECTION              [DEG]
;  (18) lon_total                (1-D):SELECTED LONGITUDE -180~180        [DEG]
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
undef("collect_ncep_fnl_tymd_latitude")
procedure collect_ncep_fnl_tymd_latitude \
          (iloop_total          :integer,                             \;INPUT
           start_lon_ind1       :integer, end_lon_ind1       :integer,\;INPUT
           start_lon_ind2       :integer, end_lon_ind2       :integer,\;INPUT
           start_nlon_0_com1    :integer, end_nlon_0_com1    :integer,\;INPUT
           start_nlon_0_com2    :integer, end_nlon_0_com2    :integer,\;INPUT
           lon                  :float,                               \;INPUT
           hgt_hour             :float,   tmpc_hour          :float,  \;INPUT
           tdc_hour             :float,   u_hour             :float,  \;INPUT
           v_hour               :float,   vvel_hour          :float,  \;INPUT
           wspd_hour            :float,   wdir_hour          :float,  \;INPUT
           lon_total            :float,                               \;INPUT
           hgt_total            :float,   tmpc_total         :float,  \;OUTPUT
           tdc_total            :float,   u_total            :float,  \;OUTPUT
           v_total              :float,   vvel_total         :float,  \;OUTPUT
           wspd_total           :float,   wdir_total         :float)   ;OUTPUT

begin

;  CONVERT LONGITUDE FROM 0~360 TO -180~180
   lon = where(lon .ge. 180, lon-360, lon)

;  COLLECT ALL THE DATA
   lon_total(start_nlon_0_com1:end_nlon_0_com1)                  = \
   lon(start_lon_ind2:end_lon_ind2)
   lon_total(start_nlon_0_com2:end_nlon_0_com2)                  = \
   lon(start_lon_ind1:end_lon_ind1)
   hgt_total (iloop_total, :, start_nlon_0_com1:end_nlon_0_com1) = \
   hgt_hour (:, start_lon_ind2:end_lon_ind2)
   hgt_total (iloop_total, :, start_nlon_0_com2:end_nlon_0_com2) = \
   hgt_hour (:, start_lon_ind1:end_lon_ind1   )
   tmpc_total(iloop_total, :, start_nlon_0_com1:end_nlon_0_com1) = \
   tmpc_hour(:, start_lon_ind2:end_lon_ind2)
   tmpc_total(iloop_total, :, start_nlon_0_com2:end_nlon_0_com2) = \
   tmpc_hour(:, start_lon_ind1:end_lon_ind1   )
   tdc_total (iloop_total, :, start_nlon_0_com1:end_nlon_0_com1) = \
   tdc_hour (:, start_lon_ind2:end_lon_ind2)
   tdc_total (iloop_total, :, start_nlon_0_com2:end_nlon_0_com2) = \
   tdc_hour (:, start_lon_ind1:end_lon_ind1   )
   u_total   (iloop_total, :, start_nlon_0_com1:end_nlon_0_com1) = \
   u_hour   (:, start_lon_ind2:end_lon_ind2)
   u_total   (iloop_total, :, start_nlon_0_com2:end_nlon_0_com2) = \
   u_hour   (:, start_lon_ind1:end_lon_ind1   )
   v_total   (iloop_total, :, start_nlon_0_com1:end_nlon_0_com1) = \
   v_hour   (:, start_lon_ind2:end_lon_ind2)
   v_total   (iloop_total, :, start_nlon_0_com2:end_nlon_0_com2) = \
   v_hour   (:, start_lon_ind1:end_lon_ind1   )
   vvel_total(iloop_total, :, start_nlon_0_com1:end_nlon_0_com1) = \
   vvel_hour(:, start_lon_ind2:end_lon_ind2)
   vvel_total(iloop_total, :, start_nlon_0_com2:end_nlon_0_com2) = \
   vvel_hour(:, start_lon_ind1:end_lon_ind1   )
   wspd_total(iloop_total, :, start_nlon_0_com1:end_nlon_0_com1) = \
   wspd_hour(:, start_lon_ind2:end_lon_ind2)
   wspd_total(iloop_total, :, start_nlon_0_com2:end_nlon_0_com2) = \
   wspd_hour(:, start_lon_ind1:end_lon_ind1   )
   wdir_total(iloop_total, :, start_nlon_0_com1:end_nlon_0_com1) = \
   wdir_hour(:, start_lon_ind2:end_lon_ind2)
   wdir_total(iloop_total, :, start_nlon_0_com2:end_nlon_0_com2) = \
   wdir_hour(:, start_lon_ind1:end_lon_ind1   )      

return
end
