;  $ID: calculate_grid_average_ncep_fnl_latitude.ncl V01 08/09/2015 10:58 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_grid_average_ncep_fnl_latitude.ncl CALCULATES THE GRID 
;  AVERAGE OF SELECTED VARIABLES FROM NCEP FNL FILE. THE AVERAGED GRID SIZE CAN 
;  BE FLEXIBLE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) lat2         (1-D):REGRID LATITUDE SIZE                           [DEG]
;  (2 ) ilat    (a scalar):INDEX OF lat2                                  [   ]
;  (3 ) minlon  (a scalar):MINIMUM LONGITUDE OF THE STUDY REGION          [DEG]
;  (4 ) maxlon  (a scalar):MAXIMUM LONGITUDE OF THE STUDY REGION          [DEG]
;  (5 ) lat          (1-D):NCEP FNL LATITUDE                              [DEG]
;  (6 ) lon          (1-D):NCEP FNL LONGITUDE                             [DEG]
;  (7 ) hgt          (3-D):NCEP FNL GEOPOTENTIAL HEIGHT                   [gpm]
;  (8 ) tmpc         (3-D):NCEP FNL TEMPERATURE                           [C  ]
;  (9 ) tdc          (3-D):NCEP FNL DEW POINT TEMPERATURE                 [C  ]
;  (10) wspd         (3-D):NCEP FNL WIND SPEED                            [m/s]
;  (11) wdir         (3-D):NCEP FNL WIND DIRECTION                        [DEG]
;  (12) hgt_hour     (1-D):SELECTED NCEP FNL GEOPOTENTIAL HEIGHT          [gpm]
;  (13) tmpc_hour    (1-D):SELECTED NCEP FNL TEMPERATURE                  [C  ]
;  (14) tdc_hour     (1-D):SELECTED NCEP FNL DEW POINT TEMPERATURE        [C  ]
;  (15) wspd_hour    (1-D):SELECTED NCEP FNL WIND SPEED                   [m/s]
;  (16) wdir_hour    (1-D):SELECTED NCEP FNL WIND DIRECTION               [DEG]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/09/2015)
;******************************************************************************
undef("calculate_grid_average_ncep_fnl_latitude")
procedure calculate_grid_average_ncep_fnl_latitude \
          (lat2         :numeric, ilat     :integer,\;INPUT
           minlon       :numeric, maxlon   :numeric,\;INPUT
           lat          :float,   lon      :float,  \;INPUT
           hgt          :float,   tmpc     :float,  \;INPUT
           tdc          :float,   wspd     :float,  \;INPUT
           wdir         :float,                     \;INPUT
           hgt_hour     :float,   tmpc_hour:float,  \;OUTPUT
           tdc_hour     :float,   wspd_hour:float,  \;OUTPUT
           wdir_hour    :float)                      ;OUTPUT

begin

;  SINCE NCEP FNL LONGITUDE IS FROM 0~360. 
;  OUR STUDY REGION IS -20~20. SO CONVERT 0~360 TO -180~180
   lon = where(lon .ge. 180, lon-360, lon)

;  SELECT THE INDICES OF LATITUDE AND LONGITUDE WITH SELECTED GRID
   index_lat = ind(lat .gt. lat2(ilat) .and. \
                   lat .le. lat2(ilat+1))
   index_lon = ind(lon .ge. minlon .and. \
                   lon .le. maxlon)

   if (.not.all(ismissing(index_lat)) .and. \
       .not.all(ismissing(index_lon))) then
      hgt_hour  = dim_avg_n(dim_avg_n(hgt(:, index_lat, index_lon), 1), 1)
      tmpc_hour = dim_avg_n(dim_avg_n(tmpc(:, index_lat, index_lon), 1), 1)
      tdc_hour  = dim_avg_n(dim_avg_n(tdc(:, index_lat, index_lon), 1), 1)
      wspd_hour = dim_avg_n(dim_avg_n(wspd(:, index_lat, index_lon), 1), 1)
      wdir_hour = dim_avg_n(dim_avg_n(wdir(:, index_lat, index_lon), 1), 1)
   end if

return
end
