;  $ID: select_region_aca_clear.ncl V01 05/17/2015 10:33 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_region_aca_clear SELECTS THE DATA IN THE STUDY REGION 
;  AND JUDGE WHETHER IT IS CLEAR OR ACA BASED ON CALIOP_ACA_count.
;
;  VARIABALES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/17/2015)
;******************************************************************************

undef("select_region_aca_clear")
procedure select_region_aca_clear \
          (minlat       :float,    maxlat         :float,     \ ;INPUT
           minlon       :float,    maxlon         :float,     \ ;INPUT
           lat_grids    :float,    lon_grids      :float,     \ ;INPUT
           sampled_grids_lat_index                :short,     \ ;INPUT
           sampled_grids_lon_index                :short,     \ ;INPUT
           CALIOP_cloud_count                     :integer,   \ ;INPUT
           CALIOP_ACA_count                       :integer,   \ ;INPUT
           index_region :integer,                             \ ;INPUT
           index_aca    :integer,  index_clear    :integer)     ;OUTPUT

begin

;  SELECT THE DATA IN THE STUDY REGION
   index_region_temp = \
                 ind(lat_grids(sampled_grids_lat_index) .ge. minlat .and. \
                     lat_grids(sampled_grids_lat_index) .le. maxlat .and. \
                     lon_grids(sampled_grids_lon_index) .ge. minlon .and. \
                     lon_grids(sampled_grids_lon_index) .le. maxlon)
   ndim_index_region = dimsizes(index_region_temp)
   index_region(0:(ndim_index_region-1)) = index_region_temp

;  SELECT THE DATA IN THE STUDY REGION AND WITH ACA
   index_aca_temp = \
                 ind(lat_grids(sampled_grids_lat_index) .ge. minlat .and. \
                     lat_grids(sampled_grids_lat_index) .le. maxlat .and. \
                     lon_grids(sampled_grids_lon_index) .ge. minlon .and. \
                     lon_grids(sampled_grids_lon_index) .le. maxlon .or.  \
                     CALIOP_ACA_count(:, 0) .gt. 0                  .or.  \
                     CALIOP_ACA_count(:, 1) .gt. 0                  .or.  \
                     CALIOP_ACA_count(:, 2) .gt. 0                  .or.  \
                     CALIOP_ACA_count(:, 3) .gt. 0                  .or.  \
                     CALIOP_ACA_count(:, 4) .gt. 0                  .or.  \
                     CALIOP_ACA_count(:, 5) .gt. 0)
   ndim_index_aca = dimsizes(index_aca_temp)
   index_aca(0:(ndim_index_aca-1)) = index_aca_temp

;  SELECT THE DATA IN THE STUDY REGION AND WITH CLEAR
   index_clear_temp \
               = ind(lat_grids(sampled_grids_lat_index) .ge. minlat .and. \
                     lat_grids(sampled_grids_lat_index) .le. maxlat .and. \
                     lon_grids(sampled_grids_lon_index) .ge. minlon .and. \
                     lon_grids(sampled_grids_lon_index) .le. maxlon .and. \
                     CALIOP_cloud_count .eq. 0                      .and. \
                     CALIOP_ACA_count(:, 0) .eq. 0                  .and. \
                     CALIOP_ACA_count(:, 1) .eq. 0                  .and. \
                     CALIOP_ACA_count(:, 2) .eq. 0                  .and. \
                     CALIOP_ACA_count(:, 3) .eq. 0                  .and. \
                     CALIOP_ACA_count(:, 4) .eq. 0                  .and. \
                     CALIOP_ACA_count(:, 5) .eq. 0)
   ndim_index_clear = dimsizes(index_clear_temp)
   index_clear(0:(ndim_index_clear-1)) = index_clear_temp

return
end
