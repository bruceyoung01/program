;  $ID: viirs_contour_pixel_dnb_nfile.ncl V01 01/08/2013 15:05 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_dnb_nfile READS VIIRS PIXEL DATA (.h5 FILE), 
;  AND PLOT IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/08/2013)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/atlanta/process_day_svdnb.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/atlanta/plot_viirs_pixel_rad.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png" 
   wks  = gsn_open_wks(type, "1plt_Atlanta_pixel_dnb_700nm_201301_v02")
   gsn_define_colormap(wks, "gsdtol")
   setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 100000000
   end setvalues

; INPUT
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/NPP/atlanta/all_data/night/"
   gdnbolist  = "GDNBO_list_201301"
   svdnblist  = "SVDNB_list_201301"
   slat       = "Latitude"
   slon       = "Longitude"
   saot       = "Radiance"
   nfile      = 2
   nfactor    = 10000000

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   minlat     = 33.0
   maxlat     = 34.5
   minlon     = -85.5
   maxlon     = -83.5

;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename1  = asciiread(dir + gdnbolist, -1, "string")
   filename2  = asciiread(dir + svdnblist, -1, "string")
   nfile      = dimsizes(filename1)

   logic_leap = "leap"

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   tmpnday    = 31
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

;  CALL process_day_svdnb.ncl TO GET FILE INFO FROM FILE NAME
   process_day_svdnb \
   (dir, svdnblist, logic_leap, nday, startinx, endinx, \
    year, mon, date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl
   mnp        = 768
   mnl        = 4064
   mfactor    = 5
   tmnp       = mnp*mfactor
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   maod       = new((/tmnp, mnl/), float, bv2)
   maod_qf    = new((/tmnp, mnl/), integer, bv1)
   msza       = new((/tmnp, mnl/), float, bv2)

   do iday = 0, nday-1
    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
    print("DATE : " + date_display)

    mlat = 0.0
    mlon = 0.0
    maod = 0.0
;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
    read_viirs_rad_1day \
    (dir, bv0, iday, startinx, endinx, filename1, filename2, \
     mlat, mlon, maod_qf, maod, msza)

     maod = maod*nfactor

;  CALL SUBROUTINE plot_viirs_pixel_rad.ncl TO PLOT WHITE-BLACK IMAGE.
    plot_viirs_pixel_rad \
    (wks, date_display, maod)
  end do
end
