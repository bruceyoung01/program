;  $: contour_grid_modis_seviri.ncl V01 07/21/2015 20:42 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_modis_seviri.ncl READS THE OUTPUT FILE OF MODIS 
;  AND SEVIRI VARIABLES, AND PLOT THE CONTOUR PLOTS OF VARIOUS VARIABLES.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) READ BOTH MODIS AND SEVIRI DATA FROM OUTPUT FILES GENERATE BY 
;       compare_modis_seviri.ncl;
;  (2 ) DO VARIABLE LOOP TO PLOT EACH VARIABLE AS CONTOUR ON THE MAP;
;  (3 ) CALCULATE MONTHLY AVERAGE AND PLOT IT.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/21/2015)
;  (2 ) ADD TO PLOT MONTHLY AVERAGE. (07/22/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_ascii_modis_seviri.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_modis_seviri_14var.ncl"
begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_modis_seviri/"
   plot_name  = "1plt_contour_grid_modis_seviri_v02"
   wks        = gsn_open_wks(type, plot_dir + plot_name)
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")


;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/compare_modis_seviri/"
   filelist   = "filelist_v01"
   filename   = asciiread(dir + filelist, -1, "string")
   nfilename  = dimsizes(filename)

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0

;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)

;  GRID SIZE TO GRID PIXEL LEVEL DATA INTO GRIDDED LEVEL DATA
   lat_grid_size = 0.25
   lon_grid_size = 0.25

;  DEFINE ARRAY FOR GRIDDED LATITUDE AND LONGITUDE ARRAY
   nlat          = floattoint((maxlat-minlat)/lat_grid_size) + 2
   nlon          = floattoint((maxlon-minlon)/lon_grid_size) + 2
   dim_2d        = (/nlat, nlon/)
   lat_grid_1d   = new((/nlat/), float, bv2)
   lon_grid_1d   = new((/nlon/), float, bv2)
   lat_grid_2d   = new(dim_2d, float, bv2)
   lon_grid_2d   = new(dim_2d, float, bv2)

;  CALL SUBROUTINE grid_lat_lon.ncl TO GENERATE GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (minlat, maxlat, minlon, maxlon, lat_grid_size, lon_grid_size, \
    lat_grid_1d, lon_grid_1d, lat_grid_2d, lon_grid_2d)

;  PARAMETER FOR THE FILE TO BE READ
   nvariable     = 16
   variable_name = new((/nvariable/), string)
   nline         = 4000
   modis_seviri  = new((/nvariable, nline/), float, bv2)
   data_3d_all   = new((/nfilename, nvariable, nlat, nlon/), float, bv2)
   iloop = 0
;  DO FILENAME LOOP TO READ AND PLOT EACH VARIABLE
   do ifilename = 0, nfilename-1
      stime = str_get_cols(filename(ifilename), 13, 22)
;  CALL SUBROUTINE read_ascii_modis_seviri.ncl TO READ SELECTED MODIS AND SEVIRI
;  DATA
      read_ascii_modis_seviri \
      (dir, filename(ifilename), nvariable, \
      variable_name, modis_seviri)

      lat        = modis_seviri(0, :)
      lon        = modis_seviri(1, :)
      data_3d    = new((/nvariable, nlat, nlon/), float, bv2)
;  CONVERT VARIABLE FROM 1-D TO 2-D WITH 1ST D IS LATITUDE, 2ND IS LONTITUDE
      do ilat = 0, nlat-1
         do ilon = 0, nlon-1
            index_latlon = ind(lat .eq. lat_grid_1d(ilat) .and. \
                               lon .eq. lon_grid_1d(ilon))
            if (.not.all(ismissing(index_latlon)) .and. \
                .not.all(ismissing(modis_seviri(:, index_latlon)))) then
               nindex_lat_lon = dimsizes(index_latlon)
               if (nindex_lat_lon .eq. 1) then
                  data_3d(:, ilat, ilon) = modis_seviri(:, index_latlon)
               else if (nindex_lat_lon .gt. 1)
                  data_3d(:, ilat, ilon) = dim_avg_n(modis_seviri(:, index_latlon), 1)
               end if
               end if
            end if
            delete([/index_latlon/])
         end do ;ilon
      end do ;ilat

;  DO VARIABLE LOOP TO PLOT EACH VARIABLE
;     do ivariable = 2, nvariable-1
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  CALL SUBROUTINE plot_contour_grid_modis_seviri_14var.ncl TO PLOT VARIABLES
;         plot_contour_grid_modis_seviri_14var \
;         (wks, ivariable, minlat, maxlat, minlon, maxlon, \
;         lat_grid_1d, lon_grid_1d, \
;         data_3d(ivariable, :, :), stime)

;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
;         polygon_map \
;         (wks, minlat, maxlat, minlon, maxlon, \
;         lat_pg, lon_pg)
;     end do
;  COLLECT THE TOTAL DATA
      data_3d_all(iloop, :, :, :) = data_3d
      iloop = iloop + 1
   end do

;  CACLULATE AVERAGE
   data_3d_all_avg = dim_avg_n(data_3d_all, 0)
   sdate           = "2008 06"
;  DO VARIABLE LOOP TO PLOT EACH VARIABLE
   do ivariable = 2, nvariable-1
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  CALL SUBROUTINE plot_contour_grid_modis_seviri_14var.ncl TO PLOT VARIABLES
      plot_contour_grid_modis_seviri_14var \
      (wks, ivariable, minlat, maxlat, minlon, maxlon, \
      lat_grid_1d, lon_grid_1d, \
      data_3d_all_avg(ivariable, :, :), sdate)

;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
      polygon_map \
      (wks, minlat, maxlat, minlon, maxlon, \
      lat_pg, lon_pg)
   end do
end
