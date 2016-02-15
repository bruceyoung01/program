;  $ID: calculate_zonal_average_ncep_fnl_longitude.ncl V01 08/09/2015 20:18 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_zonal_average_ncep_fnl_longitude.ncl CALCULATES THE ZONAL 
;  AVERAGE OF SELECTED VARIABLES FROM NCEP FNL FILE. THE AVERAGED ZONE SIZE CAN 
;  BE FLEXIBLE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) lon2         (1-D):REGRID LONGITUDE SIZE                          [DEG]
;  (2 ) ilon    (a scalar):INDEX OF lon2                                  [   ]
;  (3 ) minlat  (a scalar):MINIMUM LATITUDE OF THE STUDY REGION           [DEG]
;  (4 ) maxlat  (a scalar):MAXIMUM LATITUDE OF THE STUDY REGION           [DEG]
;  (5 ) lat          (1-D):NCEP FNL LATITUDE                              [DEG]
;  (6 ) lon          (1-D):NCEP FNL LONGITUDE                             [DEG]
;  (7 ) hgt          (3-D):NCEP FNL GEOPOTENTIAL HEIGHT                   [gpm]
;  (8 ) tmpc         (3-D):NCEP FNL TEMPERATURE                           [C  ]
;  (9 ) tdc          (3-D):NCEP FNL DEW POINT TEMPERATURE                 [C  ]
;  (10) u            (3-D):NCEP FNL U-WIND COMPONENT                      [m/s]
;  (11) v            (3-D):NCEP FNL V-WIND COMPONENT                      [m/s]
;  (12) vvel         (3-D):NCEP FNL VERTICAL VELOCITY (PRESSURE)         [Pa/s]
;  (13) wspd         (3-D):NCEP FNL WIND SPEED                            [m/s]
;  (14) wdir         (3-D):NCEP FNL WIND DIRECTION                        [DEG]
;  (15) hgt_hour     (2-D):SELECTED NCEP FNL GEOPOTENTIAL HEIGHT          [gpm]
;  (16) tmpc_hour    (2-D):SELECTED NCEP FNL TEMPERATURE                  [C  ]
;  (17) tdc_hour     (2-D):SELECTED NCEP FNL DEW POINT TEMPERATURE        [C  ]
;  (18) u_hour       (2-D):SELECTED NCEP FNL U-WIND COMPONENT             [m/s]
;  (19) v_hour       (2-D):SELECTED NCEP FNL V-WIND COMPONENT             [m/s]
;  (16) vvel_hour    (2-D):SELECTED NCEP FNL VERTICAL VELOCITY (PRESSURE)[Pa/s]
;  (17) wspd_hour    (2-D):SELECTED NCEP FNL WIND SPEED                   [m/s]
;  (18) wdir_hour    (2-D):SELECTED NCEP FNL WIND DIRECTION               [DEG]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/09/2015)
;******************************************************************************
undef("calculate_zonal_average_ncep_fnl_longitude")
procedure calculate_zonal_average_ncep_fnl_longitude \
          (lon2         :numeric, ilon         :integer,\;INPUT
           minlat       :numeric, maxlat       :numeric,\;INPUT
           lat          :float,   lon          :float,  \;INPUT
           hgt          :float,   tmpc         :float,  \;INPUT
           tdc          :float,   u            :float,  \;INPUT
           v            :float,   vvel         :float,  \;INPUT
           wspd         :float,   wdir         :float,  \;INPUT
           hgt_hour     :float,   tmpc_hour    :float,  \;OUTPUT
           tdc_hour     :float,   u_hour       :float,  \;OUTPUT
           v_hour       :float,   vvel_hour    :float,  \;OUTPUT
           wspd_hour    :float,   wdir_hour    :float)   ;OUTPUT

begin

;  CONVERT LONGITUDE FROM 0~360 TO -180~180
   lon = where(lon .ge. 180, lon-360, lon)

;  SELECT THE INDICES OF LONGITUDE WITH SELECTED GRID
   index_lon = ind(lon .gt. lon2(ilon) .and. \
                   lon .le. lon2(ilon+1))

   if (.not.all(ismissing(index_lon))) then
      hgt_hour  = dim_avg_n(hgt (:, :, index_lon), 2)
      tmpc_hour = dim_avg_n(tmpc(:, :, index_lon), 2)
      tdc_hour  = dim_avg_n(tdc (:, :, index_lon), 2)
      u_hour    = dim_avg_n(u   (:, :, index_lon), 2)
      v_hour    = dim_avg_n(v   (:, :, index_lon), 2)
      vvel_hour = dim_avg_n(vvel(:, :, index_lon), 2)
      wspd_hour = dim_avg_n(wspd(:, :, index_lon), 2)
      wdir_hour = dim_avg_n(wdir(:, :, index_lon), 2)
   end if

return
end
