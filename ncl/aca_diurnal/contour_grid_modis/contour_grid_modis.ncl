;  $ID: contour_grid_modis.ncl V01 07/20/2015 09:13 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_modis.ncl READS MODIS PIXEL DATA (.h5 FILE), 
;  AND PLOT IT.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) READ MODIS PRODUCT DAY BY DAY;
;  (2 ) PLOT THE VARIABLE IN THE STUDY REGION.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/08/2013)
;  (2 ) MODIFIED FROM viirs_contour_pixel_dnb_nfile.ncl. (03/26/2013)
;  (3 ) MODIFIED FROM modis_contour_pixel_aod.ncl. (BRUCE, 07/20/2015)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/process_day_mod04.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_modis_aod_1day.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_modis_pixel_aod.ncl"

begin
;  SETUP WORKSTATION
   type     = "x11"
;  type     = "pdf"
;  type     = "png"
   dir_plot = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_modis/"
   wks      = gsn_open_wks(type, dir_plot + "1plt_contour_grid_modis_ang_v02")
   gsn_define_colormap(wks, "BlAqGrYeOrReVi200")

; INPUT
   dir        = "/home/vy57456/zzbatmos_common/Data/MODIS/aca_diurnal/MYD04_L2/2008/"
   flist      = "filelist_MYD04_L2"

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   minlat     = -30.0
   maxlat     =  10.0
   minlon     = -20.0
   maxlon     =  20.0

;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)

;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename   = asciiread(dir + flist, -1, "string")

   logic_leap = "leap"
   loro       = "Angstrom_Exponent_1_Ocean"
;  loro       = "Effective_Optical_Depth_Best_Ocean"

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   tmpnday    = 122
   nday       = new(1, integer, bv1)
   startinx   = new(tmpnday, integer, bv1)
   endinx     = new(tmpnday, integer, bv1)
   year       = new(tmpnday, integer, bv1)
   mon        = new(tmpnday, integer, bv1)
   date       = new(tmpnday, integer, bv1)
   times      = new(tmpnday, string,  bv0)
   timee      = new(tmpnday, string,  bv0)
   dayname    = new(tmpnday, string,  bv0)
   daynum     = new(tmpnday, integer, bv1)

;  CALL process_day_mod04.ncl TO GET FILE INFO FROM FILE NAME
   process_day_mod04 \
   (dir, flist, logic_leap, nday, startinx, endinx, \
    year, mon, date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl
   mnp        = 203
   mnl        = 135
   mfactor    = 15
   tmnp       = mnp*mfactor
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   maod       = new((/tmnp, mnl/), float, bv2)
   maod_qf    = new((/tmnp, mnl/), integer, bv1)

   do iday = 0, nday-1
      system("date")
      date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday) + "-" + timee(iday)
      print("DATE : " + date_display)

      mlat = 0.0
      mlon = 0.0
      maod = 0.0
;  CALL SUBROUTINE read_modis_aod_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  AOD QUALITY FLAG, AND AOD FOR ONE DAY.
      read_modis_aod_1day \
      (dir, bv0, iday, startinx, endinx, filename, loro, \
      mlat, mlon, maod_qf, maod)

      maod@lat2d = mlat
      maod@lon2d = mlon
;  CALL SUBROUTINE plot_modis_pixel_aod.ncl TO PLOT IMAGE.
      plot_modis_pixel_aod \
      (wks, date_display, minlat, maxlat, minlon, maxlon, \
      mlat, mlon, maod)

;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
      polygon_map \
      (wks, minlat, maxlat, minlon, maxlon, \
      lat_pg, lon_pg)

   end do
end
