; $ID: contour_grid_modis_mod08.ncl V01 06/10/2015 08:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_modis_mod08 READS MODIS MOD08/MYD08 DATA, PLOTS AS 
;  CONTOUR WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/10/2015)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/function/int2string.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_modis_mod08_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_modis_mod08.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_contour_grid_modis_mod08_v01")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_common/Data/MODIS/MODIS_C6_D3/MOD08_D3/"
   filelist   = "filelist_MOD08"

;  DEFINE BAD VALUE
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2007
   start_month= 6
   end_month  = 6
   start_day  = 1

;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = True

;  SATELLITE NAME
   satename   = "MODIS"

   sfilename  = new((/1/), string)

;  DO YEAR LOOP
   do iyear = start_year, end_year

;  DO MONTH LOOP
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year    = days_in_month(iyear, imonth)
;  DO DAY LOOP
         iday_loop = 0
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTS
            logic_filename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
            print("Date : " + stime)
;  CALL SUBROUTINE select_modis_mod08_filename.ncl TO SELECT MODIS MOD08/MYD08 FILE NAME
            select_modis_mod08_filename \
            (dir, filelist, iyear, imonth, iday, \
             sfilename, logic_filename)
            if (.not.logic_filename) then
               print("----------------------------------------------------------")
               print("File name does not exist")
               continue
            end if
            print("Now Processing : " + sfilename)

;  READ VARIABLES FROM MOD08/MYD08
            a    = addfile(dir + sfilename, "r")
            lat  = a->YDim
            lon  = a->XDim
            lwp  = a->Cloud_Water_Path_Liquid_Mean

            if (logic_plot_daily) then
;  CALL SUBROUTINE plot_contour_grid_landmask_modis_mod08.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
               plot_contour_grid_landmask_modis_mod08 \
               (wks, minlat, maxlat, minlon, maxlon,  \
               lat, lon, lwp, stime)
            if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_map \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat_pg, lon_pg)
            end if
            end if
            delete([/lat, lon, lwp/])
         end do ; iday
      end do ; imonth
   end do ; iyear
end
