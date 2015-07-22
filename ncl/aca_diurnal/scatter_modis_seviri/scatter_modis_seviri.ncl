;  $: scatter_modis_seviri.ncl V01 07/21/2015 20:42 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter_modis_seviri.ncl READS THE OUTPUT FILE OF MODIS 
;  AND SEVIRI VARIABLES, AND PLOT THE SCATTER PLOTS OF VARIOUS VARIABLES.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) READ BOTH MODIS AND SEVIRI DATA FROM OUTPUT FILES GENERATE BY 
;       compare_modis_seviri.ncl;
;  (2 ) DO VARIABLE LOOP TO PLOT EACH VARIABLE AS SCATTER PLOTS.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/21/2015)
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
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_scatter_modis_seviri_reg.ncl"
begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/scatter_modis_seviri/"
   plot_name  = "1plt_scatter_modis_seviri_v02"
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

;  PARAMETER FOR THE FILE TO BE READ
   nvariable        = 16
   variable_name    = new((/nvariable/), string)
   nline            = 4000
   modis_seviri     = new((/nvariable, nline/), float, bv2)
   modis_seviri_all = new((/nfilename, nvariable, nline/), float, bv2)
   iloop = 0
;  DO FILENAME LOOP TO READ AND PLOT EACH VARIABLE
   do ifilename = 0, nfilename-1
      stime = str_get_cols(filename(ifilename), 13, 22)
;  CALL SUBROUTINE read_ascii_modis_seviri.ncl TO READ SELECTED MODIS AND SEVIRI
;  DATA
      read_ascii_modis_seviri \
      (dir, filename(ifilename), nvariable, \
      variable_name, modis_seviri)

;  DO VARIABLE LOOP TO PLOT EACH VARIABLE
      do ivariable = 2, 8
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  CALL SUBROUTINE plot_scatter_modis_seviri_reg.ncl TO PLOT SCATTER PLOTS
         plot_scatter_modis_seviri_reg \
         (wks, stime, ivariable, \
         modis_seviri(ivariable, :), modis_seviri(ivariable+7, :))
      end do
      modis_seviri_all(iloop, :, :) = modis_seviri
      iloop = iloop + 1
   end do

   sdate = "2008 06"
;  DO VARIABLE LOOP TO PLOT EACH VARIABLE
   do ivariable = 2, 8
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  CALL SUBROUTINE plot_scatter_modis_seviri_reg.ncl TO PLOT SCATTER PLOTS
      plot_scatter_modis_seviri_reg      \
      (wks, sdate, ivariable,            \
      modis_seviri_all(:, ivariable, :), \
      modis_seviri_all(:, ivariable+7, :))
   end do
end
