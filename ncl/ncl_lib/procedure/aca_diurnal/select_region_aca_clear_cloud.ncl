;  $ID: select_region_aca_clear_cloud.ncl V01 05/21/2015 09:54 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_region_aca_clear_cloud SELECTS THE DATA IN THE STUDY REGION 
;  AND JUDGE WHETHER IT IS CLEAR, ACA, OR CLOUD BASED ON CALIOP_ACA_count.
;
;  VARIABALES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/17/2015)
;******************************************************************************

undef("select_region_aca_clear_cloud")
procedure select_region_aca_clear_cloud \
          (minlat      :float,    maxlat         :float,     \ ;INPUT
           minlon      :float,    maxlon         :float,     \ ;INPUT
           lat_grids   :float,    lon_grids      :float,     \ ;INPUT
           sampled_grids_lat_index               :short,     \ ;INPUT
           sampled_grids_lon_index               :short,     \ ;INPUT
           CALIOP_cloud_count                    :integer,   \ ;INPUT
           CALIOP_ACA_count                      :integer,   \ ;INPUT
           index_region :integer,                            \ ;INPUT
           index_aca    :integer,  index_clear   :integer,   \ ;OUTPUT
           index_cloud  :integer,  index_cloud_only)           ;OUTPUT

begin

;  SELECT THE DATA IN THE STUDY REGION
   index_region_temp = \
                 ind(lat_grids(sampled_grids_lat_index) .ge. minlat .and. \
                     lat_grids(sampled_grids_lat_index) .le. maxlat .and. \
                     lon_grids(sampled_grids_lon_index) .ge. minlon .and. \
                     lon_grids(sampled_grids_lon_index) .le. maxlon)
   if (all(ismissing(index_region_temp))) then
      ndim_index_region = 0
      print("NO DATA FOR THE REGION")
   else
      ndim_index_region = dimsizes(index_region_temp)
;print("region " + ndim_index_region)
      index_region(0:(ndim_index_region-1)) = index_region_temp
   end if

;  SELECT THE DATA IN THE STUDY REGION AND WITH ACA
   CALIOP_ACA_count_sum = dim_sum_n(CALIOP_ACA_count, 1)
   index_aca_temp = \
                 ind(lat_grids(sampled_grids_lat_index) .ge. minlat .and. \
                     lat_grids(sampled_grids_lat_index) .le. maxlat .and. \
                     lon_grids(sampled_grids_lon_index) .ge. minlon .and. \
                     lon_grids(sampled_grids_lon_index) .le. maxlon .and. \
                     CALIOP_ACA_count_sum .gt. 0)
   if (all(ismissing(index_aca_temp))) then
      ndim_index_aca = 0
      print("NO DATA FOR ACA")
   else
      ndim_index_aca = dimsizes(index_aca_temp)
;print("aca " + ndim_index_aca)
      index_aca(0:(ndim_index_aca-1)) = index_aca_temp
   end if

;  SELECT THE DATA IN THE STUDY REGION AND WITH CLEAR
   index_clear_temp \
               = ind(lat_grids(sampled_grids_lat_index) .ge. minlat .and. \
                     lat_grids(sampled_grids_lat_index) .le. maxlat .and. \
                     lon_grids(sampled_grids_lon_index) .ge. minlon .and. \
                     lon_grids(sampled_grids_lon_index) .le. maxlon .and. \
                     CALIOP_cloud_count .eq. 0                      .and. \
                     CALIOP_ACA_count_sum .eq. 0)
   if (all(ismissing(index_clear_temp))) then
      ndim_index_clear = 0
      print("NO DATA FOR CLEAR")
   else
      ndim_index_clear = dimsizes(index_clear_temp)
;print("clear " + ndim_index_clear)
      index_clear(0:(ndim_index_clear-1)) = index_clear_temp
   end if

;  SELECT THE DATA IN THE STUDY REGION AND WITH CLOUD
   index_cloud_temp \
               = ind(lat_grids(sampled_grids_lat_index) .ge. minlat .and. \
                     lat_grids(sampled_grids_lat_index) .le. maxlat .and. \
                     lon_grids(sampled_grids_lon_index) .ge. minlon .and. \
                     lon_grids(sampled_grids_lon_index) .le. maxlon .and. \
                     CALIOP_cloud_count .gt. 0)
   if (all(ismissing(index_cloud_temp))) then
      ndim_index_cloud = 0
      print("NO DATA FOR CLOUD")
   else
      ndim_index_cloud = dimsizes(index_cloud_temp)
;print("cloud " + ndim_index_cloud)
      index_cloud(0:(ndim_index_cloud-1)) = index_cloud_temp
   end if

;  SELECT THE DATA IN THE STUDY REGION AND WITH CLOUD ONLY
   index_cloud_only_temp \
               = ind(lat_grids(sampled_grids_lat_index) .ge. minlat .and. \
                     lat_grids(sampled_grids_lat_index) .le. maxlat .and. \
                     lon_grids(sampled_grids_lon_index) .ge. minlon .and. \
                     lon_grids(sampled_grids_lon_index) .le. maxlon .and. \
                     CALIOP_cloud_count .gt. 0                      .and. \
                     CALIOP_ACA_count_sum .eq. 0)
   if (all(ismissing(index_cloud_only_temp))) then
      ndim_index_cloud_only = 0
      print("NO DATA FOR CLOUD ONLY")
   else
      ndim_index_cloud_only = dimsizes(index_cloud_only_temp)
;print("cloud only" + ndim_index_cloud_only)
      index_cloud_only(0:(ndim_index_cloud_only-1)) = index_cloud_only_temp
   end if

;  print("region=" + ndim_index_region + "||" + "aca=" + ndim_index_aca + "||"     + \
;        "clear=" + ndim_index_clear   + "||" + "cloud=" + ndim_index_cloud + "||" + \
;        "cloud only=" + ndim_index_cloud_only)
   total_ndim_index = ndim_index_clear + ndim_index_cloud
   total_ndim_aca   = ndim_index_cloud - ndim_index_cloud_only
   if (ndim_index_region .ne. total_ndim_index) .and. \
       ndim_index_aca    .ne. total_ndim_aca then
      print("N/A or ERROR : Total selected grids =/ Region grids, please check SUBROUTINE : select_region_aca_clear_cloud.ncl")
      print("region=" + ndim_index_region + "||" + "aca=" + ndim_index_aca + "||"     + \
            "clear=" + ndim_index_clear   + "||" + "cloud=" + ndim_index_cloud + "||" + \
            "cloud only=" + ndim_index_cloud_only)
   end if

return
end
