;  $ID: modis_contour_pixel_aod.ncl V01 03/26/2013 10:25 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM modis_contour_pixel_aod READS MODIS PIXEL DATA (.h5 FILE), 
;  AND PLOT IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/08/2013)
;  (2 ) MODIFIED FROM viirs_contour_pixel_dnb_nfile.ncl. (03/26/2013)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/process_day_mod04.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/read_modis_aod_1day.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/plot_modis_pixel_aod.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png" 
   wks  = gsn_open_wks(type, "1plt_sahel_pixel_aod_v01_test_2")
   gsn_define_colormap(wks, "BlAqGrYeOrReVi200")
   setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 100000000
   end setvalues

; INPUT
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/MODIS/sahel/myd04/"
   flist      = "MYD04_200802"

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.
   minlat     = -15.0
   maxlat     =  35.0
   minlon     = -25.0
   maxlon     =  45.0

;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename   = asciiread(dir + flist, -1, "string")

   logic_leap = "leap"
;  loro       = "land_ocean"
   loro       = "deep_blue_550_land"

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   tmpnday    = 29
   nday       = new(1, integer, bv1)
   startinx   = new(tmpnday, integer, bv1)
   endinx     = new(tmpnday, integer, bv1)
   year       = new(tmpnday, integer, bv1)
   mon        = new(tmpnday, integer, bv1)
   date       = new(tmpnday, integer, bv1)
   times      = new(tmpnday, integer, bv1)
   timee      = new(tmpnday, integer, bv1)
   dayname    = new(tmpnday, string,  bv0)
   daynum     = new(tmpnday, integer, bv1)

;  CALL process_day_mod04.ncl TO GET FILE INFO FROM FILE NAME
   process_day_mod04 \
   (dir, flist, logic_leap, nday, startinx, endinx, \
    year, mon, date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl
   mnp        = 203
   mnl        = 135
   mfactor    = 20
   tmnp       = mnp*mfactor

   do iday = 0, 0;nday-1
    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
    print("DATE : " + date_display)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   maod       = new((/tmnp, mnl/), float, bv2)
   maod_qf    = new((/tmnp, mnl/), integer, bv1)

;  CALL SUBROUTINE read_modis_aod_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  AOD QUALITY FLAG, AND AOD FOR ONE DAY.
    read_modis_aod_1day \
    (dir, bv0, iday, startinx, endinx, filename, loro, \
     mlat, mlon, maod_qf, maod)

;  CALL SUBROUTINE plot_modis_pixel_aod.ncl TO PLOT IMAGE.
    plot_modis_pixel_aod \
    (wks, date_display, minlat, maxlat, minlon, maxlon, maod)
  end do
end
